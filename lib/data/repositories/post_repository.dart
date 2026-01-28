import '../../data/models/post_model.dart';
import '../../core/services/api_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/exceptions/cache_exception.dart';

/// Interfaz: Define qué métodos debe tener cualquier PostRepository
abstract class IPostRepository {
  Future<List<PostModel>> getPosts();
  Future<PostModel?> getPostDetail(int id);
  Future<void> toggleFavorite(int postId);
  Future<List<PostModel>> getFavorites();
  Future<void> clearCache();
}

/// Implementación concreta: Solo contiene lógica de datos, sin state management
class PostRepository implements IPostRepository {
  // Dependencias inyectadas
  final ApiService _apiService;
  final LocalStorageService _localStorage;
  final ConnectivityService _connectivity;

  PostRepository({
    required ApiService apiService,
    required LocalStorageService localStorage,
    required ConnectivityService connectivity,
  })  : _apiService = apiService,
        _localStorage = localStorage,
        _connectivity = connectivity;

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      // Intenta obtener de API (sin verificar conexión primero)
      print('🌐 Cargando posts desde API...');
      final apiPostsJson = await _apiService.getPosts();
      final apiPosts = apiPostsJson
          .map((json) => PostModel.fromJson(json))
          .toList();

      // Guarda en caché
      await _localStorage.savePosts(apiPosts);
      print('✅ ${apiPosts.length} posts guardados en caché desde API');
      return apiPosts;
    } catch (e) {
      // Si API falla, intenta caché como fallback
      print('❌ Falló carga desde API: $e');
      print('📡 Intentando cargar desde caché...');
      
      try {
        final cachedPosts = await _localStorage.getCachedPosts();
        if (cachedPosts.isNotEmpty) {
          print('✅ ${cachedPosts.length} posts cargados desde caché');
          // Lanza excepción especial para indicar que vino del caché
          throw CacheException(
            message: 'Posts cargados desde caché',
            itemCount: cachedPosts.length,
          );
        }
      } catch (cacheError) {
        if (cacheError is CacheException) {
          rethrow; // Re-lanza la excepción de caché
        }
      }

      // Si no hay caché, lanza el error original
      print('⚠️ No hay caché disponible');
      rethrow;
    }
  }

  @override
  Future<PostModel?> getPostDetail(int id) async {
    try {
      // 1. Buscar en caché primero
      final cachedPost = await _localStorage.getPost(id);

      // 2. Si está en caché y es reciente (< 30 min), usarlo
      if (cachedPost != null &&
          cachedPost.cachedAt != null &&
          DateTime.now().difference(cachedPost.cachedAt!) <
              Duration(minutes: 30)) {
        return cachedPost;
      }

      // 3. Verificar conexión
      final hasConnection = _connectivity.isConnected.value;

      if (hasConnection) {
        // 4. Obtener de API
        final postJson = await _apiService.getPostDetail(id);
        final post = PostModel.fromJson(postJson);

        // 5. Actualizar caché
        await _localStorage.updatePost(post);

        return post;
      }

      // 6. Si no hay internet pero hay en caché (aunque viejo)
      if (cachedPost != null) {
        return cachedPost;
      }

      throw Exception('No se puede obtener el post');
    } catch (e) {
      print('❌ Error en getPostDetail: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleFavorite(int postId) async {
    try {
      // 1. Obtener el post
      final post = await getPostDetail(postId);

      if (post == null) {
        throw Exception('Post no encontrado');
      }

      // 2. Cambiar estado de favorito
      final updatedPost = post.copyWith(isFavorite: !post.isFavorite);

      // 3. Guardar en caché
      await _localStorage.updatePost(updatedPost);
      print('❤️ Favorito actualizado para post $postId');
    } catch (e) {
      print('❌ Error en toggleFavorite: $e');
      rethrow;
    }
  }

  @override
  Future<List<PostModel>> getFavorites() async {
    try {
      // Obtener todos los posts cacheados
      final cachedPosts = await _localStorage.getCachedPosts();

      // Filtrar solo los favoritos
      return cachedPosts.where((post) => post.isFavorite).toList();
    } catch (e) {
      print('❌ Error en getFavorites: $e');
      rethrow;
    }
  }

  /// Obtiene TODO el caché (independientemente si están expirados)
  Future<List<PostModel>> getAllCachedPosts() async {
    try {
      final box = _localStorage.getCachedPostsBox();
      final allPosts = box.values.whereType<PostModel>().toList();
      allPosts.sort((a, b) => a.id.compareTo(b.id));
      return allPosts;
    } catch (e) {
      print('❌ Error en getAllCachedPosts: $e');
      return [];
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _localStorage.clearCache();
      print('🗑️ Caché limpiado');
    } catch (e) {
      print('❌ Error en clearCache: $e');
      rethrow;
    }
  }
}
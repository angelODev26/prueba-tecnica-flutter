import '../../data/models/post_model.dart';
import '../../core/services/api_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/connectivity_service.dart';

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
      // Verifica conexión
      final hasConnection = _connectivity.isConnected.value;

      if (hasConnection) {
        // Intenta obtener de API
        print('🌐 Cargando posts desde API...');
        final apiPostsJson = await _apiService.getPosts();
        final apiPosts = apiPostsJson
            .map((json) => PostModel.fromJson(json))
            .toList();

        // Guarda en caché
        await _localStorage.savePosts(apiPosts);
        print('✅ Posts guardados en caché');
        return apiPosts;
      }

      // Sin conexión → intenta caché
      print('📡 Sin conexión. Intentando caché...');
      final cachedPosts = await _localStorage.getCachedPosts();

      if (cachedPosts.isNotEmpty) {
        print('✅ Posts cargados desde caché (${cachedPosts.length})');
        return cachedPosts;
      }

      // Sin conexión y sin caché
      print('⚠️ No hay conexión y no hay datos en caché');
      throw Exception('No hay conexión y no hay datos en caché');
    } catch (e) {
      print('❌ Error en getPosts: $e');

      // Último intento: caché como fallback
      try {
        final cachedPosts = await _localStorage.getCachedPosts();
        if (cachedPosts.isNotEmpty) {
          print('⚠️ Usando caché como fallback');
          return cachedPosts;
        }
      } catch (_) {}

      rethrow; // Lanza error para que Controller lo maneje
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
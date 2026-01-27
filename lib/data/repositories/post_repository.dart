import '../../data/models/post_model.dart';
import '../../core/services/api_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/connectivity_service.dart';

// Interfaz: Define qué métodos debe tener cualquier PostRepository
abstract class IPostRepository {
  Future<List<PostModel>> getPosts({bool forceRefresh = false});
  Future<PostModel> getPostDetail(int id);
  Future<void> toggleFavorite(int postId);
  Future<List<PostModel>> getFavorites();
  Future<void> clearCache();
}

// Implementación concreta: La que usará nuestra app
class PostRepository implements IPostRepository {
  // Dependencias que necesitamos
  final ApiService _apiService;
  final LocalStorageService _localStorage;
  final ConnectivityService _connectivity;
  
  // Constructor: Recibe las dependencias desde fuera (inyección)
  PostRepository({
    required ApiService apiService,
    required LocalStorageService localStorage,
    required ConnectivityService connectivity,
  }) : _apiService = apiService,
       _localStorage = localStorage,
       _connectivity = connectivity;
  
  @override
  Future<List<PostModel>> getPosts({bool forceRefresh = false}) async {
    try {
      // 1. Verificar conexión a internet
      final hasConnection = await _connectivity.isConnectedAsync;
      
      // 2. Si hay internet y no forzamos refresh → API
      if (hasConnection && !forceRefresh) {
        final postsJson = await _apiService.getPosts();
        final posts = postsJson.map((json) => PostModel.fromJson(json)).toList();
        
        // 3. Guardar en caché para futuro offline
        await _localStorage.savePosts(posts);
        
        return posts;
      }
      
      // 4. Si no hay internet O forceRefresh → Caché
      final cachedPosts = await _localStorage.getCachedPosts();
      
      if (cachedPosts.isNotEmpty) {
        return cachedPosts;
      }
      
      // 5. Si no hay nada en caché → Error
      throw Exception('No hay conexión y no hay datos en caché');
      
    } catch (e) {
      print('Error en PostRepository.getPosts: $e');
      rethrow;
    }
  }
  
  @override
  Future<PostModel> getPostDetail(int id) async {
    try {
      // 1. Buscar en caché primero
      final cachedPost = await _localStorage.getPost(id);
      
      // 2. Si está en caché y es reciente (< 30 min), usarlo
      if (cachedPost != null && 
          cachedPost.cachedAt != null &&
          DateTime.now().difference(cachedPost.cachedAt!) < Duration(minutes: 30)) {
        return cachedPost;
      }
      
      // 3. Verificar conexión
      final hasConnection = await _connectivity.isConnectedAsync;
      
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
      print('Error en PostRepository.getPostDetail: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> toggleFavorite(int postId) async {
    try {
      // 1. Obtener el post
      final post = await getPostDetail(postId);
      
      // 2. Cambiar estado de favorito
      final updatedPost = post.copyWith(isFavorite: !post.isFavorite);
      
      // 3. Guardar en caché
      await _localStorage.updatePost(updatedPost);
      
    } catch (e) {
      print('Error en PostRepository.toggleFavorite: $e');
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
      print('Error en PostRepository.getFavorites: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> clearCache() async {
    await _localStorage.clearCache();
  }
}
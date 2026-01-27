import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/post_model.dart';

class LocalStorageService {
  static const String _postsBoxName = 'posts_cache';
  static const String _settingsBoxName = 'app_settings';
  static const String _lastUpdateKey = 'posts_last_update';
  static const Duration _cacheDuration = Duration(hours: 24);
  
  Box _getPostsBox() {
    try {
      return Hive.box(_postsBoxName);
    } catch (e) {
      throw Exception('posts_cache box no fue inicializada en main.dart: $e');
    }
  }

  Box _getSettingsBox() {
    try {
      return Hive.box(_settingsBoxName);
    } catch (e) {
      throw Exception('app_settings box no fue inicializada en main.dart: $e');
    }
  }
  
  /// Guarda posts en caché con timestamp
  Future<void> savePosts(List<PostModel> posts) async {
    final box = _getPostsBox();
    final settingsBox = _getSettingsBox();
    final now = DateTime.now();
    
    // Usa copyWith porque cachedAt es final
    for (final post in posts) {
      final postWithTimestamp = post.copyWith(cachedAt: now);
      await box.put(post.id, postWithTimestamp);
    }
    
    await settingsBox.put(_lastUpdateKey, now.toIso8601String());
    print('✅ ${posts.length} posts guardados en caché');
  }
  
  /// Obtiene posts en caché si están válidos (no expirados)
  Future<List<PostModel>> getCachedPosts() async {
    final box = _getPostsBox();
    
    if (box.isEmpty) {
      print('⚠️ Cache vacío');
      return [];
    }
    
    final now = DateTime.now();
    final validPosts = box.values.whereType<PostModel>().where((post) {
      if (post.cachedAt == null) return false;
      final isValid = now.difference(post.cachedAt!) < _cacheDuration;
      return isValid;
    }).toList();
    
    validPosts.sort((a, b) => a.id.compareTo(b.id));
    print('✅ ${validPosts.length} posts válidos recuperados del caché');
    
    return validPosts;
  }
  
  /// Obtiene un post específico del caché
  Future<PostModel?> getPost(int id) async {
    final box = _getPostsBox();
    final post = box.get(id);
    return post is PostModel ? post : null;
  }
  
  /// Actualiza un post existente (ej: toggle favorito)
  Future<void> updatePost(PostModel post) async {
    final box = _getPostsBox();
    // Usa copyWith para actualizar timestamp
    final updatedPost = post.copyWith(cachedAt: DateTime.now());
    await box.put(post.id, updatedPost);
  }
  
  /// Limpia todo el caché
  Future<void> clearCache() async {
    final box = _getPostsBox();
    await box.clear();
    print('🗑️ Cache limpiado');
  }
  
  /// Verifica si hay datos en caché
  Future<bool> hasCachedData() async {
    final box = _getPostsBox();
    return box.isNotEmpty;
  }

  /// Obtiene la última vez que se actualizó el caché
  Future<DateTime?> getLastUpdateTime() async {
    final settingsBox = _getSettingsBox();
    final lastUpdate = settingsBox.get(_lastUpdateKey);
    return lastUpdate != null ? DateTime.parse(lastUpdate) : null;
  }
}
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/post_model.dart';

class LocalStorageService {
  static const String _postsBoxName = 'posts_cache';
  static const Duration _cacheDuration = Duration(minutes: 1);
  
  Future<Box<PostModel>> _openPostsBox() async {
    if (!Hive.isBoxOpen(_postsBoxName)) {
      return await Hive.openBox<PostModel>(_postsBoxName);
    }
    return Hive.box<PostModel>(_postsBoxName);
  }
  
  Future<void> savePosts(List<PostModel> posts) async {
    final box = await _openPostsBox();
    
    for (final post in posts) {
      await box.put(post.id, post);
    }
    
    final settingsBox = Hive.box('app_settings');
    await settingsBox.put('posts_last_update', DateTime.now().toIso8601String());
  }
  
  Future<List<PostModel>> getCachedPosts() async {
    final box = await _openPostsBox();
    final now = DateTime.now();
    
    final validPosts = box.values.where((post) {
      if (post.cachedAt == null) return false;
      return now.difference(post.cachedAt!) < _cacheDuration;
    }).toList();
    
    validPosts.sort((a, b) => a.id.compareTo(b.id));
    
    return validPosts;
  }
  
  Future<PostModel?> getPost(int id) async {
    final box = await _openPostsBox();
    return box.get(id);
  }
  
  Future<void> updatePost(PostModel post) async {
    final box = await _openPostsBox();
    await box.put(post.id, post);
  }
  
  Future<void> clearCache() async {
    final box = await _openPostsBox();
    await box.clear();
  }
  
  Future<bool> hasCachedData() async {
    final box = await _openPostsBox();
    return box.isNotEmpty;
  }
}
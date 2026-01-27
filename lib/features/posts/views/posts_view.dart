import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/posts_controller.dart';

class PostsView extends GetView<PostsController> {
  const PostsView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          Obx(() => controller.isOffline.value
              ? const Icon(Icons.wifi_off, color: Colors.orange)
              : const Icon(Icons.wifi, color: Colors.green)),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.offAllNamed('/auth');
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${controller.error.value}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadPosts(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () => controller.refreshPosts(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.posts.length,
            itemBuilder: (context, index) {
              final post = controller.posts[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${post.id}'),
                  ),
                  title: Text(post.title),
                  subtitle: Text(
                    post.body.length > 50 
                      ? '${post.body.substring(0, 50)}...'
                      : post.body,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      post.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: post.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => controller.toggleFavorite(post.id),
                  ),
                  onTap: () {
                    Get.toNamed('/posts/${post.id}');
                  },
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.refreshPosts(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
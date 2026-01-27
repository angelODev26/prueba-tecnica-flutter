import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PostsView extends StatelessWidget {
  const PostsView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.article),
              ),
              title: Text('Post ${index + 1}'),
              subtitle: const Text('Descripción del post...'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.toNamed('/posts/${index + 1}');
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
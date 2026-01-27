import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PostDetailView extends StatelessWidget {
  final int postId;
  
  const PostDetailView({super.key, required this.postId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post #$postId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título del Post #$postId',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  child: Icon(Icons.person, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Autor: Usuario'),
                const Spacer(),
                Chip(
                  label: const Text('Categoría'),
                  backgroundColor: Colors.blue[50],
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Este es el contenido detallado del post. Aquí iría la información completa obtenida desde la API.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
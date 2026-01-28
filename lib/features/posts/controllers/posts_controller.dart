import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/exceptions/cache_exception.dart';

class PostsController extends GetxController {
  final PostRepository postRepository;
  final ConnectivityService connectivityService = Get.find();
  
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isOffline = true.obs; // Inicia en true (offline por defecto)

  PostsController({required this.postRepository});

  @override
  void onReady() {
    super.onReady();
    
    // Actualiza isOffline INMEDIATAMENTE con el estado actual
    isOffline.value = !connectivityService.isConnected.value;
    
    // Escucha cambios en la conexión en TIEMPO REAL
    ever(connectivityService.isConnected, (_) {
      isOffline.value = !connectivityService.isConnected.value;
      print('🔄 Conexión cambió: ${connectivityService.isConnected.value}');
    });
    
    // Carga los posts después de configurar el listener
    loadPosts();
  }

  Future<void> loadPosts() async {
    isLoading.value = true;
    error.value = '';

    try {
      final fetchedPosts = await postRepository.getPosts();
      
      if (fetchedPosts.isEmpty) {
        error.value = 'No hay posts disponibles';
        isOffline.value = true;
      } else {
        posts.assignAll(fetchedPosts);
        error.value = '';
        isOffline.value = false; // Cargó desde API = Online
        print('✅ Posts cargados desde API');
        Get.snackbar(
          '📡 Modo Online',
          'Mostrando ${fetchedPosts.length} posts desde API',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
        );
      }
    } on CacheException catch (e) {
      // Detecta que cargó desde caché
      print('📡 ${e.message}');
      isOffline.value = true;
      error.value = '';
      
      // Obtiene los posts del caché
      final allCached = await postRepository.getAllCachedPosts();
      if (allCached.isNotEmpty) {
        posts.assignAll(allCached);
        Get.snackbar(
          '📡 Modo Offline',
          'Mostrando ${e.itemCount} posts en caché',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      // Otros errores
      print('❌ Falló carga desde API: $e');
      isOffline.value = true;
      
      // Intenta caché como último recurso
      final allCached = await postRepository.getAllCachedPosts();
      if (allCached.isNotEmpty) {
        posts.assignAll(allCached);
        Get.snackbar(
          '📡 Modo Offline',
          'Mostrando ${allCached.length} posts en caché',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.orange,
        );
        error.value = '';
      } else {
        error.value = 'No hay conexión y no hay datos en caché';
        Get.snackbar(
          'Error',
          'No se pudieron cargar los posts',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
      print('🔌 isOffline: ${isOffline.value}');
    }
  }

  Future<void> refreshPosts() async {
    await loadPosts();
  }

  void toggleFavorite(int postId) async {
    try {
      await postRepository.toggleFavorite(postId);

      final index = posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = posts[index];
        final updatedPost = post.copyWith(isFavorite: !post.isFavorite);
        posts[index] = updatedPost;
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar favorito');
    }
  }

  /// Limpia el caché y recarga los posts desde la API
  Future<void> clearCache() async {
    try {
      await postRepository.clearCache();
      Get.snackbar(
        '🗑️ Caché limpiado',
        'Cargando posts desde API...',
        snackPosition: SnackPosition.BOTTOM,
      );
      // Recarga los posts después de limpiar caché
      await loadPosts();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo limpiar el caché');
    }
  }
}
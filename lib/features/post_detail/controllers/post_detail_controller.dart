import 'package:get/get.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/post_repository.dart';
import '../../posts/controllers/posts_controller.dart';

class PostDetailController extends GetxController {
  final PostRepository postRepository;
  final int postId;

  final Rx<PostModel?> post = Rx<PostModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  PostDetailController({
    required this.postRepository,
    required this.postId,
  });

  @override
  void onReady() {
    super.onReady();
    loadPostDetail();
  }

  Future<void> loadPostDetail() async {
    isLoading.value = true;
    error.value = '';

    try {
      final fetchedPost = await postRepository.getPostDetail(postId);

      if (fetchedPost == null) {
        error.value = 'Post no encontrado';
      } else {
        post.value = fetchedPost;
        print('✅ Post #$postId cargado correctamente');
      }
    } catch (e) {
      error.value = 'Error: $e';
      print('❌ Error cargando post #$postId: $e');
      Get.snackbar('Error', 'No se pudo cargar el post');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleFavorite() async {
    try {
      await postRepository.toggleFavorite(postId);
      
      // Actualiza el post local
      final updatedPost = post.value?.copyWith(
        isFavorite: !(post.value?.isFavorite ?? false),
      );
      post.value = updatedPost;
      
      // 🔑 IMPORTANTE: Actualizar también en la lista del PostsController
      if (Get.isRegistered<PostsController>()) {
        final postsController = Get.find<PostsController>();
        final index = postsController.posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          postsController.posts[index] = updatedPost!;
          print('✅ Favorito actualizado en lista: post #$postId');
        }
      }
      
      print('❤️ Favorito actualizado para post $postId');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar favorito');
    }
  }
}

import 'package:get/get.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/post_repository.dart';

class PostsController extends GetxController {
  final PostRepository postRepository;
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isOffline = false.obs;

  PostsController({required this.postRepository});

  @override
  void onReady() {
    super.onReady();
    loadPosts();
  }

  Future<void> loadPosts() async {
    isLoading.value = true;
    error.value = '';
    isOffline.value = false;

    try {
      final fetchedPosts = await postRepository.getPosts();
      
      if (fetchedPosts.isEmpty) {
        error.value = 'No hay posts disponibles';
        isOffline.value = true;
      } else {
        posts.assignAll(fetchedPosts);
      }
    } catch (e) {
      error.value = 'Error: $e';
      isOffline.value = true;
      Get.snackbar(
        'Error',
        'No se pudieron cargar los posts',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
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
}
import 'package:get/get.dart';
import '../controllers/post_detail_controller.dart';

class PostDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Obtiene el postId de los parámetros de la ruta
    final postId = int.tryParse(Get.parameters['id'] ?? '0') ?? 0;

    Get.lazyPut(() => PostDetailController(
      postRepository: Get.find(),
      postId: postId,
    ));
  }
}

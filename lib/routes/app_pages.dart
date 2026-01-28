import 'package:get/get.dart';
import '../features/auth/views/auth_view.dart';
import '../features/auth/bindings/auth_binding.dart';
import '../features/posts/views/posts_view.dart';
import '../features/post_detail/views/post_detail_view.dart';
import '../features/posts/bindings/posts_binding.dart';
import '../features/post_detail/bindings/post_detail_binding.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.auth;
  
  static final routes = [
    // Auth
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // Login
    GetPage(
      name: AppRoutes.login,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    
    // Register
    GetPage(
      name: AppRoutes.register,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    
    // Post List
    GetPage(
      name: AppRoutes.posts,
      page: () => const PostsView(),
      binding: PostsBinding(), // <-- AÑADE ESTO
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    
    // Post Detail
    GetPage(
      name: AppRoutes.postDetail,
      page: () => const PostDetailView(),
      binding: PostDetailBinding(),
      transition: Transition.cupertino,
    ),
  ];
}
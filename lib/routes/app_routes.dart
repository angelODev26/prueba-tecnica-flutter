abstract class AppRoutes {
  // Rutas principales
  static const String initial = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  
  // Subrutas de autenticación
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  
  // Rutas de posts
  static const String posts = '/posts';
  static const String postDetail = '$posts/:id';
  static const String postCreate = '$posts/create';
  static const String postEdit = '$posts/edit/:id';
  
  // Rutas de perfil
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // Métodos de ayuda
  static String getPostDetailPath(int id) => '$posts/$id';
  static String getPostEditPath(int id) => '$posts/edit/$id';
}
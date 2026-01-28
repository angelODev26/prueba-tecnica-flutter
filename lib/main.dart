import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'package:prueba_tecnica/data/models/post_model.dart';
import 'package:prueba_tecnica/data/models/user_model.dart';
import 'core/bindings/initial_bindings.dart';
import 'core/services/local_storage_service.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  // 1. Inicializar binding de Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inicializar Firebase (SOLO en plataformas soportadas: Android, iOS, Web)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente');
  } catch (e) {
    print('⚠️ Firebase no disponible en esta plataforma: $e');
    print('⚠️ La app continuará sin autenticación Firebase');
  }
  
  // 3. Cargar variables de entorno
  await dotenv.load(fileName: ".env");
  
  // 4. Inicializar Hive (base de datos local)
  await Hive.initFlutter();
  
  // 5. Registrar adaptadores
  Hive.registerAdapter(PostModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  
  // 6. Abrir boxes de Hive
  await Hive.openBox('app_settings');
  await Hive.openBox('posts_cache');
  await Hive.openBox('session_box');
  await Hive.openBox<UserModel>('users');
  
  // 7. Verificar si hay usuario autenticado (para auto-login)
  final localStorage = LocalStorageService();
  final hasUser = await localStorage.hasAuthenticatedUser();
  
  // Si Firebase NO está disponible, ir directo a posts (sin auth)
  String initialRoute;
  try {
    Firebase.app(); // Verifica si Firebase está disponible
    initialRoute = hasUser ? AppRoutes.posts : AppRoutes.auth;
  } catch (e) {
    print('⚠️ Firebase no disponible - Saltando autenticación');
    initialRoute = AppRoutes.posts; // Ir directo a posts sin auth
  }
  
  // 8. Ejecutar la aplicación
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Prueba Técnica',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      initialBinding: InitialBindings(),
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
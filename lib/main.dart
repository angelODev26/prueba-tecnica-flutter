import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'routes/app_pages.dart';
import 'package:prueba_tecnica/data/models/post_model.dart';

Future<void> main() async {
  // 1. Inicializar binding de Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Cargar variables de entorno
  await dotenv.load(fileName: ".env");
  
  // 3. Inicializar Hive (base de datos local)
  await Hive.initFlutter();
  
  // 4. Registrar adaptadores (se añadirán después)
  Hive.registerAdapter(PostModelAdapter());
  
  // 5. Abrir boxes de Hive
  await Hive.openBox('app_settings');
  await Hive.openBox('posts_cache');
  await Hive.openBox('session_box');
  
  // 6. Ejecutar la aplicación
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Prueba Técnica',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
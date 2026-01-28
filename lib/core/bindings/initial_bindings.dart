import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../data/repositories/post_repository.dart';
import 'package:firebase_core/firebase_core.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // 1. Servicios globales (singletons - una sola instancia en toda la app)
    Get.lazyPut(() => ApiService(), fenix: true);
    
    // AuthService SOLO si Firebase está inicializado
    try {
      Firebase.app(); // Verifica si Firebase está inicializado
      Get.lazyPut(() => AuthService(), fenix: true);
      print('✅ AuthService registrado');
    } catch (e) {
      print('⚠️ AuthService NO registrado (Firebase no disponible)');
    }
    
    Get.lazyPut(() => ConnectivityService(), fenix: true);
    Get.lazyPut(() => LocalStorageService(), fenix: true);
    
    // 2. Repositorios (dependen de servicios)
    Get.lazyPut(() => PostRepository(
      apiService: Get.find<ApiService>(),
      localStorage: Get.find<LocalStorageService>(),
      connectivity: Get.find<ConnectivityService>(),
    ), fenix: true);
    
    // 3. Controllers se pondrán en sus propios bindings por feature
  }
}
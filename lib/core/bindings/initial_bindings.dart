import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../data/repositories/post_repository.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // 1. Servicios globales (singletons - una sola instancia en toda la app)
    Get.lazyPut(() => ApiService(), fenix: true);
    Get.lazyPut(() => AuthService(), fenix: true);
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
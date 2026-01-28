import 'package:get/get.dart';
import 'package:prueba_tecnica/core/services/auth_service.dart';
import 'package:prueba_tecnica/core/services/local_storage_service.dart';
import 'package:prueba_tecnica/features/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Verificar si AuthService está disponible
    if (!Get.isRegistered<AuthService>()) {
      print('⚠️ AuthService no disponible - Binding omitido');
      return; // No registrar nada
    }

    // AuthService está registrado en InitialBindings, solo obtener instancia
    final authService = Get.find<AuthService>();
    final localStorage = Get.find<LocalStorageService>();

    // Registrar AuthController
    Get.lazyPut(() => AuthController(
          authService: authService,
          localStorage: localStorage,
        ));
  }
}

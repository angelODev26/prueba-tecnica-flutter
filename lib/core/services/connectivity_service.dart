import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _setupListener();
  }
  
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      isConnected.value = _isConnected(result);
    } catch (e) {
      print('Error checking connectivity: $e');
      isConnected.value = false;
    }
  }
  
  void _setupListener() {
    _connectivity.onConnectivityChanged.listen((result) {
      final connected = _isConnected(result);
      isConnected.value = connected;
      
      // Opcional: Mostrar notificación cuando cambia el estado
      if (connected) {
        Get.snackbar(
          'Conectado',
          'Tienes conexión a internet',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Sin conexión',
          'Modo offline activado',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    });
  }
  
  bool _isConnected(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }
  
  Future<bool> get isConnectedAsync async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }
}
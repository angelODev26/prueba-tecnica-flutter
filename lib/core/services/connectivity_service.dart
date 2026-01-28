import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initConnectivityAndListener();
  }

  /// Inicializa la conexión y LUEGO configura el listener
  /// Evita carrera de condiciones
  Future<void> _initConnectivityAndListener() async {
    // Primero: espera a que se complete la verificación inicial
    await _initConnectivity();
    
    // Luego: configura el listener (ahora sabemos el estado correcto)
    _setupListener();
  }
  
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      isConnected.value = _isConnected(result);
      print('📡 Estado inicial de conexión: ${isConnected.value}');
    } catch (e) {
      print('Error checking connectivity: $e');
      isConnected.value = false;
    }
  }
  
  void _setupListener() {
    _connectivity.onConnectivityChanged.listen((result) {
      final connected = _isConnected(result);
      final wasConnected = isConnected.value;
      
      // Solo actualiza si cambió
      if (connected != wasConnected) {
        isConnected.value = connected;
        
        // Mostrar notificación cuando CAMBIA el estado (no al inicio)
        if (connected) {
          print('🟢 Conectado a internet');
          Get.snackbar(
            'Conectado',
            'Tienes conexión a internet',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        } else {
          print('🔴 Desconectado de internet');
          Get.snackbar(
            'Sin conexión',
            'Modo offline activado',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        }
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
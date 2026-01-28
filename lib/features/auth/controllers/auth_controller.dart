import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prueba_tecnica/routes/app_routes.dart';
import 'package:prueba_tecnica/core/services/auth_service.dart';
import 'package:prueba_tecnica/core/services/local_storage_service.dart';
import 'package:prueba_tecnica/data/models/user_model.dart';

class AuthController extends GetxController {
  final AuthService authService;
  final LocalStorageService localStorage;

  AuthController({
    required this.authService,
    required this.localStorage,
  });

  /// Determina si estamos en modo registro (true) o login (false)
  final RxBool isRegistering = true.obs;

  /// Campos del formulario
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString passwordConfirm = ''.obs;

  /// Estados de carga y error
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  /// Controla si la contraseña es visible o no
  final RxBool isObscured = true.obs;

  /// GlobalKey para validar el formulario
  late GlobalKey<FormState> formKey;

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
  }

  /// Alterna entre modo registro e inicio de sesión
  void toggleAuthMode() {
    isRegistering.toggle();
    clearForm();
    error.value = '';
  }

  /// Alterna la visibilidad de la contraseña
  void toggleObscured() {
    isObscured.toggle();
  }

  /// Valida el formulario y realiza registro
  Future<void> register() async {
    error.value = '';

    // Validar formulario
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validación adicional: contraseñas coinciden
    if (password.value != passwordConfirm.value) {
      error.value = 'Las contraseñas no coinciden';
      return;
    }

    try {
      isLoading.value = true;

      // Registrar usuario con Firebase Auth
      final firebaseUser = await authService.register(
        email: email.value,
        password: password.value,
      );

      if (firebaseUser != null) {
        // Crear modelo de usuario para Hive
        final user = UserModel(
          userId: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        // Guardar usuario en Hive
        await localStorage.saveUser(user);

        // Mostrar éxito
        Get.snackbar(
          '✅ Éxito',
          'Cuenta creada correctamente',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Navegar a posts
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offNamed(AppRoutes.posts);
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        '❌ Error',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Valida el formulario y realiza login
  Future<void> login() async {
    error.value = '';

    // Validar formulario
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      // Iniciar sesión con Firebase Auth
      final firebaseUser = await authService.login(
        email: email.value,
        password: password.value,
      );

      if (firebaseUser != null) {
        // Crear modelo de usuario para Hive
        final user = UserModel(
          userId: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        // Guardar usuario en Hive
        await localStorage.saveUser(user);

        // Mostrar éxito
        Get.snackbar(
          '✅ Bienvenido',
          'Sesión iniciada correctamente',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Navegar a posts
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offNamed(AppRoutes.posts);
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        '❌ Error',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Realiza logout
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await authService.logout();
      await localStorage.clearUser();
      Get.offNamed(AppRoutes.auth);
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Error al cerrar sesión: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Limpia los campos del formulario
  void clearForm() {
    email.value = '';
    password.value = '';
    passwordConfirm.value = '';
    formKey.currentState?.reset();
  }
}

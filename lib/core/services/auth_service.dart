import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Obtiene el usuario actual autenticado
  User? get currentUser => _firebaseAuth.currentUser;

  /// Verifica si hay usuario autenticado
  bool get isAuthenticated => currentUser != null;

  /// Registra un nuevo usuario con email y contraseña
  /// Lanza excepciones con mensajes descriptivos
  Future<User?> register({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('✅ Usuario registrado: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String mensaje = _parseAuthError(e.code);
      print('❌ Error de registro: $mensaje');
      throw mensaje;
    } catch (e) {
      print('❌ Error desconocido: $e');
      throw 'Error al registrar usuario: $e';
    }
  }

  /// Inicia sesión con email y contraseña
  /// Lanza excepciones con mensajes descriptivos
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('✅ Sesión iniciada: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String mensaje = _parseAuthError(e.code);
      print('❌ Error de login: $mensaje');
      throw mensaje;
    } catch (e) {
      print('❌ Error desconocido: $e');
      throw 'Error al iniciar sesión: $e';
    }
  }

  /// Cierra la sesión del usuario actual
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      print('✅ Sesión cerrada');
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
      throw 'Error al cerrar sesión: $e';
    }
  }

  /// Convierte códigos de error de Firebase a mensajes en español
  String _parseAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres)';
      case 'invalid-email':
        return 'El email no es válido';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      default:
        return 'Error de autenticación: $code';
    }
  }
}

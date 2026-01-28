import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prueba_tecnica/core/utils/validators.dart';
import 'package:prueba_tecnica/features/auth/controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.isRegistering.value ? 'Registro' : 'Inicio de Sesión',
        )),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Obx(() => Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título
                  Text(
                    controller.isRegistering.value
                        ? '📝 Crear Cuenta'
                        : '🔐 Iniciar Sesión',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email TextField
                  TextFormField(
                    initialValue: controller.email.value,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'tu@email.com',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => Validators.validateEmail(value),
                    onChanged: (value) => controller.email.value = value,
                  ),
                  const SizedBox(height: 16),

                  // Password TextField
                  TextFormField(
                    initialValue: controller.password.value,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Mínimo 6 caracteres',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: Obx(
                        () => IconButton(
                          icon: Icon(
                            controller.isObscured.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: controller.toggleObscured,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: controller.isObscured.value,
                    validator: (value) => Validators.validatePassword(value),
                    onChanged: (value) => controller.password.value = value,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password (solo en registro)
                  if (controller.isRegistering.value)
                    Column(
                      children: [
                        TextFormField(
                          initialValue: controller.passwordConfirm.value,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: Obx(
                              () => IconButton(
                                icon: Icon(
                                  controller.isObscured.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: controller.toggleObscured,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: controller.isObscured.value,
                          validator: (value) =>
                              Validators.validateNotEmpty(value, 'Confirmación'),
                          onChanged: (value) =>
                              controller.passwordConfirm.value = value,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Mensaje de error
                  if (controller.error.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade400),
                        ),
                        child: Text(
                          controller.error.value,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ),

                  // Botón principal (Register/Login)
                  ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (controller.isRegistering.value) {
                              controller.register();
                            } else {
                              controller.login();
                            }
                          },
                    icon: controller.isLoading.value
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.7),
                              ),
                            ),
                          )
                        : Icon(
                            controller.isRegistering.value
                                ? Icons.person_add
                                : Icons.login,
                          ),
                    label: Text(
                      controller.isLoading.value
                          ? 'Procesando...'
                          : controller.isRegistering.value
                              ? 'Registrarse'
                              : 'Iniciar Sesión',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Toggle entre registro/login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.isRegistering.value
                            ? '¿Ya tienes cuenta? '
                            : '¿No tienes cuenta? ',
                      ),
                      GestureDetector(
                        onTap: controller.toggleAuthMode,
                        child: Text(
                          controller.isRegistering.value
                              ? 'Inicia sesión'
                              : 'Regístrate',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}
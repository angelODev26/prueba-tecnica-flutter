# 🚀 Prueba Técnica Flutter - Aplicación Móvil Escalable

## 📋 Descripción
Aplicación Flutter desarrollada como prueba técnica, implementando arquitectura escalable con GetX, Hive para persistencia local y consumo de API REST.

## 🏗️ Arquitectura
- **Patrón**: Clean Architecture + Feature-First
- **State Management**: GetX (Controllers + Bindings)
- **Persistencia**: Hive (NoSQL local)
- **Networking**: HTTP Client + Repository Pattern
- **Navegación**: GetX Navigation

## 🛠️ Tecnologías
| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| Flutter | 3.22.0+ | Framework principal |
| GetX | 4.6.5+ | State Management + DI |
| Hive | 2.2.3+ | Base de datos local |
| HTTP | 1.1.0+ | Consumo de APIs |
| Connectivity Plus | 5.0.2+ | Detección de conexión |

## 📁 Estructura del Proyecto
lib/
├── core/ # Configuraciones globales
├── data/ # Capa de datos (models, repositories)
├── features/ # Módulos por funcionalidad
├── routes/ # Configuración de rutas
└── main.dart # Punto de entrada

## 🚀 Funcionalidades
- ✅ Autenticación con persistencia de sesión
- ✅ Listado de posts con cache offline/online
- ✅ Detalle de posts con navegación
- ✅ Validación de formularios
- ✅ Manejo de errores y estados de carga

## ⚙️ Instalación
```bash
# 1. Clonar repositorio
git clone https://github.com/tuusuario/prueba-tecnica-flutter.git

# 2. Entrar al directorio
cd prueba-tecnica-flutter

# 3. Obtener dependencias
flutter pub get

# 4. Generar adaptadores Hive
flutter pub run build_runner build

# 5. Ejecutar aplicación
flutter run
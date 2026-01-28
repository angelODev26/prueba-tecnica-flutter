# 🚀 Prueba Técnica Flutter - Aplicación Escalable con GetX, Hive y Firebase

## 📋 Descripción

Aplicación Flutter con arquitectura escalable, autenticación Firebase, caché offline inteligente y navegación robusta con GetX. Implementa **Clean Architecture + Feature-First pattern** para máxima mantenibilidad y escalabilidad.

**Estado Actual**: ✅ Compilado, testeado en Android Xiaomi (HyperOS)
- APK Debug: 406 MB (símbolos de debug)
- APK Release: 47.8 MB (optimizado) ✅

---

## 🏗️ Arquitectura

### Patrón Arquitectónico
- **Clean Architecture** + **Feature-First**: Cada feature es independiente y auto-contenida
- **3 Capas**:
  - **Features**: UI (Views) + Lógica (Controllers) + Inyección (Bindings)
  - **Data**: Modelos tipados + Repositorio con abstracción
  - **Core**: Servicios globales + Excepciones + Constantes

### State Management con GetX
```dart
// Observables reactivos
final RxList<PostModel> posts = <PostModel>[].obs;
final RxBool isLoading = false.obs;

// En UI: Obx(() => ...) se reconstruye automáticamente
```

### Persistencia: Hive + Caché Inteligente
```
API Request
    ↓
┌─ Éxito → Hive Cache (guardado automático)
└─ Error → Fallback a Hive Cache Existente
```

### Conectividad: Offline-First
- Monitoreo real-time con `Connectivity Plus`
- Caché automático en primera carga
- Fallback offline si no hay internet
- Auto-login desde sesión en Hive

---

## 🛠️ Stack Tecnológico

| Componente | Versión | Rol |
|-----------|---------|-----|
| **Flutter** | 3.22.0+ | Framework multiplataforma |
| **Dart** | 3.0.0+ | Lenguaje |
| **GetX** | 4.6.5+ | State Management + Routing + DI |
| **Firebase Auth** | 5.7.0+ | Autenticación Email/Password |
| **Firebase Core** | 3.15.2+ | Inicialización Firebase |
| **Hive** | 2.2.3+ | Base de datos local NoSQL |
| **HTTP** | 1.1.0+ | Cliente REST |
| **Connectivity Plus** | 5.0.2+ | Detección de conexión |

### Build System (Android)
```
Gradle: 8.3
AGP (Android Gradle Plugin): 8.3.0
Kotlin: 1.9.0
minSdk: 23 (requerido por Firebase)
targetSdk: 34
```

**⚠️ Configuración Java (IMPORTANTE):**
```
Java instalado (sistema): 17 OpenJDK (Ubuntu)
Java detectado por Flutter: 21 Temurin (SDKMAN)

PROBLEMA: Gradle 8.3 + AGP 8.3.0 NO soporta Java 21 (jlink incompatible)
SOLUCIÓN: Forzar Java 17 al compilar con: export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

---

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── bindings/
│   │   └── initial_bindings.dart          # 🔗 Registro global de servicios
│   ├── constants/
│   │   └── api_constants.dart             # 🌐 URLs y config API
│   ├── exceptions/
│   │   └── cache_exception.dart           # ⚠️ Excepciones personalizadas
│   ├── services/
│   │   ├── api_service.dart               # 🔌 Cliente HTTP REST
│   │   ├── auth_service.dart              # 🔐 Wrapper Firebase Auth
│   │   ├── connectivity_service.dart      # 📡 Monitoreo de conexión
│   │   └── local_storage_service.dart     # 💾 Abstracción Hive
│   └── utils/
│       └── validators.dart                # ✔️ Validadores de formularios
│
├── data/
│   ├── models/
│   │   ├── post_model.dart                # 📝 @HiveType(typeId: 0)
│   │   ├── post_model.g.dart              # 🔧 Generado: Hive adapter
│   │   ├── user_model.dart                # 👤 @HiveType(typeId: 1)
│   │   └── user_model.g.dart              # 🔧 Generado: Hive adapter
│   └── repositories/
│       └── post_repository.dart           # 📦 Repository pattern con fallback
│
├── features/
│   ├── auth/                              # 🔐 Feature: Autenticación
│   │   ├── bindings/auth_binding.dart
│   │   ├── controllers/auth_controller.dart
│   │   └── views/auth_view.dart           # 📋 Formulario registro/login
│   │
│   ├── posts/                             # 📱 Feature: Listado
│   │   ├── bindings/posts_binding.dart
│   │   ├── controllers/posts_controller.dart
│   │   └── views/posts_view.dart          # 📄 Listado + RefreshIndicator
│   │
│   └── post_detail/                       # 📖 Feature: Detalle
│       ├── bindings/post_detail_binding.dart
│       ├── controllers/post_detail_controller.dart
│       └── views/post_detail_view.dart    # 📄 Detalle completo
│
├── routes/
│   ├── app_pages.dart                     # 🗺️ Rutas GetX con bindings
│   └── app_routes.dart                    # 🔗 Constantes de rutas
│
├── main.dart                              # 🎯 Punto de entrada
├── firebase_options.dart                  # 🔥 Config Firebase auto-generada
└── .env                                   # 🔒 Variables de entorno (gitignored)
```

---

## 🎯 Flujos Principales

### 1️⃣ Autenticación (Firebase + Persistencia)
```
┌──────────────────┐
│   Auth Screen    │ → Valida email + password
└────────┬─────────┘
         │ register(email, password)
         ↓
┌──────────────────────┐
│   Firebase Auth      │ → Crea usuario o inicia sesión
└────────┬─────────────┘
         │ UserCredential
         ↓
┌──────────────────────────┐
│ LocalStorageService      │ → Guarda UserModel en Hive (session_box)
└────────┬─────────────────┘
         │ ✅ success
         ↓
┌──────────────────┐
│  Posts Screen    │ ← Navega automáticamente
└──────────────────┘

🔄 PRÓXIMA EJECUCIÓN: main.dart detecta hasAuthenticatedUser() → auto-login a /posts
```

### 2️⃣ Carga de Posts (Online/Offline)
```
USER → "Cargar posts" (Pull to Refresh)
   ↓
PostsController.loadPosts()
   ↓
┌────────────────────┐
│ Check Connectivity │
└────┬───────────────┘
     │
  YES (Online)       NO (Offline)
     │                 │
     ↓                 ↓
┌─────────────┐   ┌──────────────┐
│ API Request │   │ Load Caché   │
│ (100 posts) │   │ (immediate)  │
└─────┬───────┘   └───────┬──────┘
      │                   │
      └─────────┬─────────┘
                ↓
         ┌──────────────┐
         │ Hive.savePosts() │ (solo en 1er fetch)
         └────────┬─────────┘
                  ↓
         ┌──────────────────┐
         │ Controller updates│ posts.assignAll()
         │ RxList           │
         └────────┬─────────┘
                  ↓
         ┌──────────────────┐
         │ UI Rebuilds      │ (Obx() reactiva)
         │ ListView visible │
         └──────────────────┘
```

### 3️⃣ Logout Seguro (Cierra sesión completamente)
```
USER → Tap "Logout"
  ↓
Dialog de confirmación
  ↓
PostsController.logout()
  ↓
┌──────────────────────┐
│ AuthService.logout() │ → Firebase signOut()
└────────┬─────────────┘
         │
         ↓
┌────────────────────────────┐
│ LocalStorageService        │ → Hive.clearUser() (borra session_box)
│ .clearUser()               │
└────────┬───────────────────┘
         │
         ↓
┌──────────────────┐
│ Auth Screen      │ ← Requiere internet para next login
└──────────────────┘

🔒 IMPORTANTE: Logout borra Firebase Auth + Hive session
```

---

## 🚀 Funcionalidades Implementadas

| Funcionalidad | Estado | Detalles |
|--------------|--------|----------|
| **Autenticación Firebase** | ✅ | Email/Password con manejo de errores en español |
| **Sesión Persistente** | ✅ | Auto-login desde Hive al abrir app |
| **Listado de Posts** | ✅ | 100 posts con paginación visual |
| **Caché Offline** | ✅ | Carga desde caché si no hay internet |
| **Favoritos** | ✅ | Toggle + persistencia en Hive |
| **Detalle de Post** | ✅ | Con información completa del autor |
| **Logout Seguro** | ✅ | Limpia Firebase Auth + Hive completamente |
| **Validación Formularios** | ✅ | Email regex + password mínimo 6 caracteres |
| **Error Handling** | ✅ | Snackbars automáticos + fallbacks |
| **Conectividad** | ✅ | Icono WiFi real-time + detección offline |

---

## ⚙️ Instalación y Configuración

### Requisitos Previos
```bash
# Verificar versiones
flutter --version              # 3.22.0+
dart --version                 # 3.0.0+
java -version                  # 17 (compilación) o 21
```

- **Android SDK**: API 23+ (minSdk para Firebase)
- **Firebase Project**: Creado en [console.firebase.google.com](https://console.firebase.google.com)

### Pasos de Instalación

#### 1️⃣ Clonar Repositorio
```bash
git clone https://github.com/angelODev26/prueba-tecnica-flutter.git
cd prueba-tecnica-flutter
```

#### 2️⃣ Obtener Dependencias
```bash
flutter pub get
```

#### 3️⃣ Configurar Variables de Entorno
```bash
# Crear .env en raíz
cat > .env << EOF
API_BASE_URL=https://jsonplaceholder.typicode.com
EOF
```

#### 4️⃣ Generar Adaptadores Hive (CRÍTICO)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Si falla, limpiar:
```bash
flutter clean && flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 5️⃣ Ejecutar en Android

**Debug (con reloads rápidos):**
```bash
# En Linux/WSL: Usar Java 17 para evitar incompatibilidad jlink
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
flutter run -d <device-id>  # Obtenido de: flutter devices
```

**O compilar APK directamente:**
```bash
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 flutter build apk --debug
# Resultado: build/app/outputs/flutter-apk/app-debug.apk
```

#### 6️⃣ Compilar Release (Producción)
```bash
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 flutter build apk --release
# Resultado: build/app/outputs/flutter-apk/app-release.apk (47.8 MB)
```

---

## 🔥 Configuración Firebase

> **⚠️ OBLIGATORIO PARA CADA DESARROLLADOR**
> 
> El archivo `google-services.json` **NO está en el repositorio** (por seguridad).
> Cada desarrollador debe **crear su propio proyecto Firebase** o **recibir el archivo compartido**.
> Sin este archivo, la app **crashea al iniciar**.

### Opción A: Usar Proyecto Firebase Compartido (RECOMENDADO para esta prueba)
Si recibiste `google-services.json` por correo o GitHub:

**Paso 1: Descargar/Descomprimir**
```bash
# Si recibiste por correo:
# 1. Descargar el correo adjunto: google-services.json
# 2. Guardar en tu carpeta de descargas

# Si recibiste en repositorio Git:
git clone <repo>
cd prueba-tecnica-flutter
```

**Paso 2: Copiar el archivo a Android**
```bash
# Desde la carpeta descargas (si lo recibiste por correo):
cp ~/Descargas/google-services.json ./android/app/

# O si está en el correo comprimido:
unzip google-services.zip -d ./android/app/

# Verificar que existe:
ls -lh android/app/google-services.json  # Debe mostrar el archivo (~2-3 KB)
```

**Paso 3: Instalar dependencias y ejecutar**
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
# ✅ App debe iniciar sin errores de Firebase
```

**Si la app crashea al iniciar:**
- Verifica que `google-services.json` esté en `android/app/` (NO en otra carpeta)
- Ejecuta: `flutter clean && flutter pub get && flutter run`

### Opción B: Crear Proyecto Firebase Individual (Desarrollo)

#### 1. Crear Proyecto en Firebase Console
1. Ir a [Firebase Console](https://console.firebase.google.com)
2. **"Crear Proyecto"** → Nombre: `prueba-tecnica` (o tu nombre)
3. **"Agregar aplicación"** → Seleccionar **Android**
4. Paquete: `com.example.prueba_tecnica` ⚠️ **Debe coincidir exactamente**
5. Descargar `google-services.json`

#### 2. Integrar en Proyecto
```bash
# Copiar a Android
cp ~/Descargas/google-services.json android/app/

# Verificar que existe
ls -lh android/app/google-services.json  # Debe mostrar ~2-3 KB

# Ya está configurado en android/build.gradle:
# classpath 'com.google.gms:google-services:4.4.0'
```

#### 3. Habilitar Autenticación
- En Firebase Console → **Authentication** → **Sign-in method**
- Habilitar: **Email/Password** (toggle a ON)
- Guardar cambios

#### 4. Verificar Configuración
```bash
# Si firebase_options.dart no existe, regenerar:
# flutterfire configure --project=<tu-proyecto-id>

# Ejecutar app
flutter run
# ✅ Si funciona: Firebase configurado correctamente
# ❌ Si crashea: Revisar que google-services.json esté en android/app/
```

---

## 🎮 Guía de Uso

### Flujo Típico del Usuario

#### 1. **Primera Ejecución**
- App abre en pantalla `/auth` (no hay sesión)
- Elige: **Registrarse** o **Ingresar**

#### 2. **Registro**
- Email: `user@example.com`
- Password: `123456` (mínimo 6 caracteres)
- Tap **"Registrarse"** → Crea usuario en Firebase
- Automáticamente navega a `/posts`

#### 3. **Listado de Posts**
- Ve 100 posts de la API
- **Pull to Refresh**: Actualiza desde API
- **Corazón**: Toggle favorito (❤️ persistente en Hive)
- **Tap en post**: Ve detalle con información del autor
- **Icono WiFi**: Verde = online, Naranja = offline

#### 4. **Detalle de Post**
- Información completa: Título, autor, contenido
- **Botón atrás**: Vuelve al listado
- **Favorito**: Toggle persistente

#### 5. **Logout**
- Menú superior → **Logout**
- Confirma en dialog
- Limpia sesión completamente
- Requiere internet para siguiente login

---

## 🐛 Troubleshooting

### 🔴 Error: "Could not find main class worker.org.gradle.process.internal.worker.GradleWorkerMain"
```bash
# Causa: Caché Gradle corrupta
# Solución:
rm -rf ~/.gradle/caches android/.gradle build/
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
flutter clean && flutter pub get
flutter build apk --debug
```

### 🔴 Error: "minSdkVersion 21 cannot be smaller than version 23"
```bash
# Causa: Firebase requiere API 23
# Solución: Ya está en android/app/build.gradle:
minSdk = 23  ✅
```

### 🔴 Error: "Unsupported class file major version 65"
```bash
# Causa: Java 21 (Flutter) vs Java 17 (Gradle incompatible)
# Solución:
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
flutter build apk --debug
```

### 🔴 Error: "Type 'List<Object?>' is not a subtype of 'PigeonUserDetails?'"
```bash
# Causa: Firebase versiones antiguas (4.14.0)
# Solución: Ya actualizado a 5.7.0 en pubspec.yaml ✅
```

### 🔴 APK muy grande (406 MB)
```bash
# Causa: Es normal para Debug (incluye símbolos)
# Solución: Compilar Release (47.8 MB):
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 flutter build apk --release
```

---

## 📊 Tamaños y Rendimiento

| Métrica | Valor | Nota |
|---------|-------|------|
| **APK Debug** | 406 MB | Símbolos de debug incluidos |
| **APK Release** | 47.8 MB | Optimizado con ProGuard/R8 ✅ |
| **Lib/ Size** | 236 KB | Código fuente limpio |
| **Build Time** | ~3-5 min | Primera compilación debug |
| **Hot Reload** | ~1s | Después de cambios sin lógica |
| **Startup Time** | ~2s | En dispositivo físico |

---

## 🔐 Seguridad

### ✅ Implementado
- Logout limpia **Firebase Auth** + **Hive session**
- Credenciales **NO se guardan** tras logout
- Validación de email con **regex**
- Password mínimo **6 caracteres**
- Manejo seguro de excepciones (sin stacktraces al usuario)

## 📝 Licencia
**MIT License** - Libre para uso educativo y comercial

---

## 👨‍💻 Autor
**Angel Developer**

---

**Última actualización**: 28 de Enero de 2026 ✅

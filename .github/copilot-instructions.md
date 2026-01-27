# Copilot Instructions for Prueba Técnica Flutter

## Project Overview
This is a **Flutter application** using **Clean Architecture + Feature-First** pattern. It demonstrates scalable mobile development with GetX for state management, Hive for local persistence, and HTTP for API integration.

**Key Tech Stack:** Flutter 3.22.0+, GetX 4.6.5, Hive 2.2.3, HTTP 1.1.0, Connectivity Plus 5.0.2

---

## Architecture Layers (Critical to Understand)

### 1. **Feature-First Structure** (`lib/features/`)
Each feature (auth, posts, post_detail) is **self-contained** with:
- `controllers/` - GetX controllers managing state via Rx observables (RxList, RxBool, RxString)
- `bindings/` - GetX dependency injection for that feature only
- `views/` - UI widgets displaying data
- `widgets/` - Reusable UI components within the feature

**Pattern:** Features depend on `data/` and `core/` layers, never on other features.

### 2. **Data Layer** (`lib/data/`)
Implements Repository Pattern with abstraction:
- **Models** (`post_model.dart`) - Data transfer objects with `@HiveType()` annotations for Hive persistence
- **Repositories** (`post_repository.dart`) - Implements `IPostRepository` interface; bridges API/cache/controller

**Key Logic in PostRepository:**
```dart
// Checks internet → fetches from API → caches in Hive
// Falls back to cached data if offline
// Manages togglFavorite, getFavorites, clearCache
```

### 3. **Core Layer** (`lib/core/`)
Provides global singletons:
- **Services** - `ApiService`, `LocalStorageService`, `ConnectivityService`
- **Bindings** - `InitialBindings` registers all global services (fenix: true for persistent lifecycle)
- **Constants** - `ApiConstants`, `AppRoutes`
- **Theme, Utils** - Shared styling and helper functions

---

## Critical Data Flow
1. **UI (View)** calls method on GetX `Controller`
2. **Controller** calls `Repository` method
3. **Repository** checks `ConnectivityService` → calls `ApiService` OR `LocalStorageService`
4. **ApiService** makes HTTP request, handles errors with status codes (400, 401, 403, 404, 500)
5. **LocalStorageService** reads/writes Hive boxes ('posts_cache', 'session_box', 'app_settings')
6. **Controller** updates Rx observables (posts.assignAll, isLoading.value, error.value)
7. **View** rebuilds via Obx() when Rx variables change

---

## Developer Workflows

### Setup (First Run)
```bash
flutter pub get                    # Install dependencies
flutter pub run build_runner build # Generate Hive adapters (required for models)
flutter run                        # Start development app
```

### During Development
- **Edit models** → Run `build_runner` again to regenerate adapters
- **Add feature** → Copy structure: features/posts/ → features/new_feature/
- **Register feature** in `app_pages.dart` with GetPage and binding
- **Add service** → Inject in `InitialBindings` with `Get.lazyPut()`

### Common Tasks
- **Toggle offline mode** → Change `ConnectivityService` logic for testing cache
- **Add API endpoint** → Create method in `ApiService`, then repository wrapper
- **Handle errors** → Wrap in try-catch, call `Get.snackbar()` for user feedback

---

## Key Patterns & Conventions

### GetX Dependency Injection
- **Global services** (InitialBindings): `Get.lazyPut(() => Service(), fenix: true)`
- **Feature controllers** (Feature-specific Binding): `Get.lazyPut(() => Controller(repository: Get.find()))`
- **Retrieval:** `Get.find<ServiceName>()`

### State Management with Observables
```dart
final RxList<PostModel> posts = <PostModel>[].obs;  // Observable list
final RxBool isLoading = false.obs;                 // Observable bool

posts.assignAll(newList);  // Replace entire list (triggers Obx rebuild)
posts[0] = updatedItem;    // Modify individual item
isLoading.value = true;    // Update bool

// In UI: Obx(() => Text(controller.isLoading.value ? 'Loading...' : 'Ready'))
```

### Hive Persistence
- Models decorated with `@HiveType(typeId: 0)` and field `@HiveField(n)`
- Boxes opened in `main.dart`: `await Hive.openBox('box_name')`
- Accessed via `LocalStorageService` (wrapper around raw Hive calls)

### Error Handling
- **ApiService** throws descriptive exceptions: `'API Error: 404 Not Found'`, `'Request timeout...'`, `'Network error...'`
- **Repository** catches and re-throws or handles gracefully (e.g., fallback to cache)
- **Controller** catches and displays `Get.snackbar()` to user

### Connectivity-Aware Architecture
`ConnectivityService` extends `GetxService` (lifecycle-aware singleton). Used to:
- Skip API calls when offline
- Serve cached data instead
- Prevent "no connection" exceptions

---

## Integration Points & Dependencies
- **Navigation:** GetX routes defined in [app_pages.dart](lib/routes/app_pages.dart) and [app_routes.dart](lib/routes/app_routes.dart)
- **External APIs:** Configured in [ApiConstants](lib/core/constants/api_constants.dart) (base URL from .env)
- **Local DB:** Hive boxes initialized in [main.dart](lib/main.dart)
- **Firebase:** Imported but not fully integrated (optional feature)

---

## When Making Changes
1. **Adding a new endpoint?** → Update ApiService → Add Repository method → Call from Controller
2. **New observable state?** → Declare as Rx field in Controller → Wrap UI in Obx()
3. **Changing model structure?** → Update `@HiveField` decorators → Run build_runner
4. **New feature?** → Create features/{name}/ with controllers/, views/, bindings/
5. **Testing offline?** → Mock ConnectivityService to return false in tests

---

## File References
- [main.dart](lib/main.dart) - App initialization, Hive setup
- [PostsController](lib/features/posts/controllers/posts_controller.dart) - Example state management
- [PostRepository](lib/data/repositories/post_repository.dart) - Example repository pattern
- [ApiService](lib/core/services/api_service.dart) - HTTP client with error handling
- [InitialBindings](lib/core/bindings/initial_bindings.dart) - Global service registration

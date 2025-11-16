# 🧭 Sistema de Navegación con GoRouter

Sistema de navegación profesional y escalable para Flutter con soporte completo para deep linking, web y navegación avanzada.

## 📋 Contenido

- [Características](#-características)
- [Estructura de Archivos](#-estructura-de-archivos)
- [Configuración](#-configuración)
- [Uso Básico](#-uso-básico)
- [Agregar Nuevas Páginas](#-agregar-nuevas-páginas)
- [Navegación Avanzada](#-navegación-avanzada)
- [Deep Linking](#-deep-linking)
- [Guards de Navegación](#-guards-de-navegación)

## ✨ Características

✅ **Deep Linking** automático para Android/iOS/Web  
✅ **Soporte Web** completo con URLs amigables  
✅ **Navegación tipada** con rutas constantes  
✅ **Guards de navegación** para control de acceso  
✅ **Observador de rutas** para analytics  
✅ **Manejo de errores** 404 personalizado  
✅ **Transiciones personalizadas** entre páginas  
✅ **Extensiones útiles** para facilitar la navegación  
✅ **100% escalable** - fácil agregar nuevas rutas  

## 📁 Estructura de Archivos

```
lib/app/config/go_route/
├── app_router.dart          # Configuración principal del router
├── app_routes.dart          # Definición de todas las rutas
├── route_observer.dart      # Observador para analytics
├── route_extensions.dart    # Extensiones útiles
├── go_route.dart           # Barrel file (exporta todo)
└── README.md               # Esta documentación
```

## ⚙️ Configuración

### 1. Actualiza tu `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:opn_test_guardia_civil/app/config/go_route/go_route.dart';
import 'package:opn_test_guardia_civil/app/config/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OPN Test Guardia Civil',
      
      // 🎨 Temas
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      
      // 🧭 Router
      routerConfig: AppRouter.router,
      
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### 2. Configuración de Deep Linking (Android)

Edita `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
  <application ...>
    <activity ...>
      <!-- Deep Links -->
      <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        
        <!-- Reemplaza con tu dominio -->
        <data
          android:scheme="https"
          android:host="tuapp.com" />
      </intent-filter>
    </activity>
  </application>
</manifest>
```

### 3. Configuración de Deep Linking (iOS)

Edita `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>tuapp</string>
    </array>
  </dict>
</array>
```

## 🚀 Uso Básico

### Navegar entre páginas

```dart
import 'package:go_router/go_router.dart';
import 'package:opn_test_guardia_civil/app/config/go_route/go_route.dart';

// Navegar reemplazando la página actual
context.go(AppRoutes.home);

// Navegar apilando una nueva página
context.push(AppRoutes.profile);

// Navegar hacia atrás
context.pop();

// Navegar con datos
context.push(AppRoutes.profile, extra: userData);
```

### Usando las extensiones

```dart
// Importa las extensiones
import 'package:opn_test_guardia_civil/app/config/go_route/go_route.dart';

// Pop seguro (no crashea si no hay páginas)
context.safePop();

// Obtener ruta actual
final currentRoute = context.currentRoute;

// Verificar si estamos en una ruta específica
if (context.isCurrentRoute(AppRoutes.home)) {
  // Hacer algo
}

// Navegar y esperar resultado
final result = await context.pushForResult<String>(AppRoutes.settings);
```

## 📄 Agregar Nuevas Páginas

### Paso 1: Crear tu página con la variable estática `route`

```dart
// lib/presentation/pages/example/example_page.dart
import 'package:flutter/material.dart';
import 'package:opn_test_guardia_civil/app/config/go_route/go_route.dart';

class ExamplePage extends StatelessWidget {
  // ✅ Variable estática con la ruta
  static const String route = '/example';
  
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplo'),
      ),
      body: Center(
        child: Text('Esta es una página de ejemplo'),
      ),
    );
  }
}
```

### Paso 2: Agregar la ruta a `app_routes.dart`

```dart
abstract class AppRoutes {
  // ...rutas existentes...
  
  /// Página de ejemplo
  static const String example = ExamplePage.route; // ✅ Usa la variable estática
}
```

### Paso 3: Agregar la ruta a `app_router.dart`

```dart
// En el array routes de AppRouter
GoRoute(
  path: AppRoutes.example,
  name: 'example',
  pageBuilder: (context, state) => _buildPageWithTransition(
    context: context,
    state: state,
    child: const ExamplePage(),
  ),
),
```

### Paso 4: Navegar a tu nueva página

```dart
// Desde cualquier parte de tu app
context.go(AppRoutes.example);
// o
context.go(ExamplePage.route); // Ambas funcionan igual
```

## 🎯 Navegación Avanzada

### Rutas con parámetros

```dart
// Definir ruta con parámetros
abstract class AppRoutes {
  static const String userProfile = '/user/:id';
}

// Configurar en AppRouter
GoRoute(
  path: AppRoutes.userProfile,
  name: 'userProfile',
  builder: (context, state) {
    final userId = state.pathParameters['id']!;
    return UserProfilePage(userId: userId);
  },
),

// Navegar con parámetros
context.go('/user/123');
// o usando la extensión
context.go(AppRoutes.userProfile.withParams({'id': '123'}));
```

### Query Parameters

```dart
// Navegar con query params
context.go(AppRoutes.search.withQuery({'q': 'flutter', 'page': '1'}));
// Resultado: /search?q=flutter&page=1

// Leer query params
final searchQuery = context.queryParams['q'];
```

### Navegación con datos (extra)

```dart
// Enviar datos complejos
final userData = UserModel(name: 'Juan', age: 25);
context.push(AppRoutes.profile, extra: userData);

// Recibir en la página destino
GoRoute(
  path: AppRoutes.profile,
  builder: (context, state) {
    final userData = state.extra as UserModel;
    return ProfilePage(user: userData);
  },
),
```

## 🔗 Deep Linking

Los deep links funcionan automáticamente una vez configurado:

```dart
// URLs que funcionan automáticamente:
// https://tuapp.com/home
// https://tuapp.com/profile
// https://tuapp.com/user/123
// myapp://settings
```

### Testear Deep Links

**Android:**
```bash
adb shell am start -W -a android.intent.action.VIEW \
  -d "https://tuapp.com/profile" com.tu.paquete
```

**iOS:**
```bash
xcrun simctl openurl booted "https://tuapp.com/profile"
```

## 🔒 Guards de Navegación

Para proteger rutas (ejemplo: requerir autenticación):

```dart
// En AppRouter, modifica el redirect:
redirect: (context, state) {
  // Obtener estado de autenticación
  final isAuthenticated = AuthService.instance.isAuthenticated;
  final isPublicRoute = AppRoutes.isPublicRoute(state.matchedLocation);
  
  // Redirigir a login si no está autenticado
  if (!isAuthenticated && !isPublicRoute) {
    return AppRoutes.login;
  }
  
  // Redirigir a home si ya está autenticado e intenta ir a login
  if (isAuthenticated && state.matchedLocation == AppRoutes.login) {
    return AppRoutes.home;
  }
  
  return null; // null = permitir navegación
},
```

## 📊 Analytics

El `AppRouteObserver` registra automáticamente todas las navegaciones. Para integrar analytics:

```dart
// En route_observer.dart, modifica _logNavigation:
void _logNavigation(...) {
  // ...código existente...
  
  // Enviar a Firebase Analytics
  FirebaseAnalytics.instance.logScreenView(
    screenName: routeName,
    screenClass: route.settings.name,
  );
  
  // O tu servicio de analytics preferido
  AnalyticsService.trackPageView(routeName);
}
```

## 🎨 Transiciones Personalizadas

Para cambiar las transiciones entre páginas, modifica `_buildPageWithTransition` en `app_router.dart`:

```dart
// Transición Slide (deslizar)
transitionsBuilder: (context, animation, secondaryAnimation, child) {
  return SlideTransition(
    position: animation.drive(
      Tween(begin: const Offset(1, 0), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeInOut)),
    ),
    child: child,
  );
},

// Transición Scale (escalar)
transitionsBuilder: (context, animation, secondaryAnimation, child) {
  return ScaleTransition(
    scale: animation,
    child: child,
  );
},
```

## 🐛 Debugging

Para ver logs de navegación en la consola:

```dart
// Los logs aparecen automáticamente en modo debug:
// 🧭 [PUSH] /home (from: /)
// 🧭 [POP] /home (from: /profile)
```

Ver historial de navegación:

```dart
final history = AppRouteObserver.routeHistory;
print('Páginas visitadas: $history');
```

## 📚 Recursos Adicionales

- [GoRouter Documentación Oficial](https://pub.dev/packages/go_router)
- [Flutter Deep Linking](https://docs.flutter.dev/ui/navigation/deep-linking)
- [Flutter Web URLs](https://docs.flutter.dev/ui/navigation/url-strategies)

---

**¿Preguntas o problemas?** Revisa los comentarios en los archivos de código o consulta la documentación oficial de GoRouter.


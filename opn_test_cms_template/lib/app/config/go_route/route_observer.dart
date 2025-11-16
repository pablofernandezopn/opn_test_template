import 'package:flutter/material.dart';

/// 👀 Observador de Rutas de la Aplicación
///
/// Este observador permite hacer tracking de la navegación para:
/// - 📊 Analytics (Firebase, Mixpanel, etc.)
/// - 🐛 Debugging y logging
/// - 📈 Métricas de navegación
///
/// **Eventos que captura:**
/// - Navegación a nuevas rutas
/// - Regreso a rutas anteriores
/// - Reemplazo de rutas
///
/// **Uso:**
/// Se configura automáticamente en AppRouter
class AppRouteObserver extends NavigatorObserver {
  /// Lista de rutas visitadas (útil para debug)
  static final List<String> _routeHistory = [];

  /// Obtiene el historial de rutas
  static List<String> get routeHistory => List.unmodifiable(_routeHistory);

  /// Cuando se navega a una nueva ruta (push)
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation('PUSH', route, previousRoute);
  }

  /// Cuando se retrocede a una ruta anterior (pop)
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigation('POP', route, previousRoute);
  }

  /// Cuando se reemplaza una ruta
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _logNavigation('REPLACE', newRoute, oldRoute);
    }
  }

  /// Cuando se elimina una ruta
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _logNavigation('REMOVE', route, previousRoute);
  }

  /// Registra la navegación
  void _logNavigation(
    String action,
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    final routeName = route.settings.name ?? 'unknown';
    final previousRouteName = previousRoute?.settings.name ?? 'none';

    // Agregar al historial
    if (action == 'PUSH' || action == 'REPLACE') {
      _routeHistory.add(routeName);
    }

    // Log en consola (solo en debug)
    debugPrint('🧭 [$action] $routeName (from: $previousRouteName)');

    // TODO: Enviar evento a analytics
    // Ejemplo con Firebase Analytics:
    // FirebaseAnalytics.instance.logScreenView(
    //   screenName: routeName,
    //   screenClass: route.settings.name,
    // );

    // TODO: Enviar evento a Crashlytics para debugging
    // FirebaseCrashlytics.instance.log('Navigation: $action to $routeName');
  }

  /// Limpia el historial de rutas
  static void clearHistory() {
    _routeHistory.clear();
  }

  /// Obtiene la última ruta visitada
  static String? get lastRoute {
    return _routeHistory.isNotEmpty ? _routeHistory.last : null;
  }

  /// Obtiene la cantidad de rutas en el historial
  static int get historyLength => _routeHistory.length;
}


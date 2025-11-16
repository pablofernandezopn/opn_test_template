import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 🛠️ Extensiones útiles para navegación con GoRouter
///
/// Estas extensiones facilitan tareas comunes de navegación
/// y proporcionan métodos convenientes para usar con GoRouter
extension GoRouterExtensions on BuildContext {
  /// Navega hacia atrás de forma segura
  /// Si no hay rutas en el stack, no hace nada
  void safePop() {
    if (canPop()) {
      pop();
    }
  }

  /// Navega hacia atrás con un valor de retorno
  void popWithResult<T>(T result) {
    pop(result);
  }

  /// Reemplaza la ruta actual y limpia todo el stack
  void goAndClearStack(String location) {
    go(location);
    // El stack se limpia automáticamente con go()
  }

  /// Navega a una ruta y espera un resultado
  Future<T?> pushForResult<T>(String location) async {
    return push<T>(location);
  }

  /// Verifica si la ruta actual coincide con la ruta dada
  bool isCurrentRoute(String route) {
    final currentRoute = GoRouterState.of(this).matchedLocation;
    return currentRoute == route;
  }

  /// Obtiene la ruta actual
  String get currentRoute {
    return GoRouterState.of(this).matchedLocation;
  }

  /// Obtiene los parámetros de la ruta actual
  Map<String, String> get routeParams {
    return GoRouterState.of(this).pathParameters;
  }

  /// Obtiene los query parameters de la ruta actual
  Map<String, String> get queryParams {
    return GoRouterState.of(this).uri.queryParameters;
  }

  /// Navega hacia atrás hasta encontrar una ruta específica
  void popUntilRoute(String targetRoute) {
    while (canPop() && !isCurrentRoute(targetRoute)) {
      pop();
    }
  }
}

/// Extensión para obtener parámetros de forma tipada
extension RouteParamsExtension on Map<String, String> {
  /// Obtiene un parámetro como int
  int? getInt(String key) {
    final value = this[key];
    return value != null ? int.tryParse(value) : null;
  }

  /// Obtiene un parámetro como double
  double? getDouble(String key) {
    final value = this[key];
    return value != null ? double.tryParse(value) : null;
  }

  /// Obtiene un parámetro como bool
  bool? getBool(String key) {
    final value = this[key];
    if (value == null) return null;
    return value.toLowerCase() == 'true' || value == '1';
  }

  /// Obtiene un parámetro con un valor por defecto
  String getOrDefault(String key, String defaultValue) {
    return this[key] ?? defaultValue;
  }
}

/// Extensión para construir rutas con parámetros de forma segura
extension RouteBuilderExtension on String {
  /// Construye una ruta con path parameters
  /// Ejemplo: '/user/:id'.withParams({'id': '123'}) => '/user/123'
  String withParams(Map<String, String> params) {
    var route = this;
    params.forEach((key, value) {
      route = route.replaceAll(':$key', value);
    });
    return route;
  }

  /// Construye una ruta con query parameters
  /// Ejemplo: '/search'.withQuery({'q': 'flutter'}) => '/search?q=flutter'
  String withQuery(Map<String, String> queryParams) {
    if (queryParams.isEmpty) return this;

    final query = queryParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return contains('?') ? '$this&$query' : '$this?$query';
  }

  /// Combina path params y query params
  String withParamsAndQuery(
    Map<String, String> pathParams,
    Map<String, String> queryParams,
  ) {
    return withParams(pathParams).withQuery(queryParams);
  }
}


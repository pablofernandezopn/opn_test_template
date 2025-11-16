/// 🔗 Servicio de Deep Links
///
/// Este servicio maneja todos los deep links entrantes a la aplicación.
/// Soporta tanto esquemas personalizados (opngc://) como URLs web (https://).
///
/// **Características:**
/// - Escucha deep links cuando la app está cerrada o en background
/// - Escucha deep links cuando la app está en foreground
/// - Extrae la ruta y parámetros del deep link
/// - Se integra con GoRouter para la navegación
///
/// **Uso:**
/// ```dart
/// // Inicializar el servicio
/// await deepLinkService.initialize();
///
/// // Escuchar deep links
/// deepLinkService.linkStream.listen((uri) {
///   // Manejar el deep link
/// });
/// ```
library;

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:opn_test_template/app/config/deep_link_config.dart';

class DeepLinkService {
  DeepLinkService();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Stream de deep links entrantes
  Stream<Uri> get linkStream => _appLinks.uriLinkStream;

  /// Inicializa el servicio de deep links
  ///
  /// Este método debe llamarse al inicio de la aplicación para:
  /// 1. Obtener el deep link inicial (si la app fue abierta con uno)
  /// 2. Escuchar futuros deep links mientras la app está abierta
  Future<void> initialize() async {
    try {
      // Verificar si hay un deep link inicial (app abierta desde cerrada)
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('🔗 Deep Link inicial detectado: $initialUri');
      }
    } catch (e) {
      debugPrint('❌ Error al obtener deep link inicial: $e');
    }
  }

  /// Obtiene el deep link inicial (si existe)
  ///
  /// Retorna null si la app no fue abierta mediante un deep link
  Future<Uri?> getInitialLink() async {
    try {
      return await _appLinks.getInitialLink();
    } catch (e) {
      debugPrint('❌ Error al obtener deep link inicial: $e');
      return null;
    }
  }

  /// Extrae la ruta del deep link
  ///
  /// Ejemplos:
  /// - yourscheme://home → /home
  /// - https://yourdomain.com/test-config → /test-config
  /// - yourscheme://topic-test?id=123 → /topic-test
  String? extractRoute(Uri uri) {
    try {
      // Si es esquema personalizado (opngc://), el path es el host
      if (uri.scheme == DeepLinkConfig.scheme) {
        final route = uri.host.isEmpty ? uri.path : '/${uri.host}${uri.path}';
        return route.isEmpty ? '/home' : route;
      }

      // Si es URL web (https://), usar el path directamente
      if (uri.scheme == 'https' || uri.scheme == 'http') {
        return uri.path.isEmpty ? '/home' : uri.path;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error al extraer ruta del deep link: $e');
      return null;
    }
  }

  /// Extrae los parámetros de query del deep link
  ///
  /// Ejemplo:
  /// - opngc://test-config?topicId=123&mode=practice
  ///   → {topicId: 123, mode: practice}
  Map<String, String> extractQueryParameters(Uri uri) {
    return uri.queryParameters;
  }

  /// Construye una ruta completa con parámetros para GoRouter
  ///
  /// Ejemplo:
  /// - uri: opngc://test-config?topicId=123
  /// - Retorna: /test-config?topicId=123
  String buildRouteWithParams(Uri uri) {
    final route = extractRoute(uri);
    if (route == null) return '/home';

    final params = extractQueryParameters(uri);
    if (params.isEmpty) return route;

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$route?$queryString';
  }

  /// Valida si un deep link es válido para esta app
  bool isValidDeepLink(Uri uri) {
    // Validar esquema personalizado
    if (uri.scheme == DeepLinkConfig.scheme) {
      return true;
    }

    // Validar URL web
    if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host == DeepLinkConfig.domain) {
      return true;
    }

    return false;
  }

  /// Escucha deep links y ejecuta un callback
  ///
  /// Este método es útil para manejar deep links en tiempo real
  /// mientras la app está abierta.
  ///
  /// Ejemplo:
  /// ```dart
  /// deepLinkService.listenToLinks((uri) {
  ///   final route = deepLinkService.buildRouteWithParams(uri);
  ///   context.go(route);
  /// });
  /// ```
  void listenToLinks(void Function(Uri uri) onLink) {
    _linkSubscription?.cancel();
    _linkSubscription = linkStream.listen(
      (uri) {
        if (isValidDeepLink(uri)) {
          debugPrint('🔗 Deep Link recibido: $uri');
          onLink(uri);
        } else {
          debugPrint('⚠️ Deep Link inválido: $uri');
        }
      },
      onError: (err) {
        debugPrint('❌ Error en deep link stream: $err');
      },
    );
  }

  /// Detiene la escucha de deep links
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}

/// 🔗 Configuración de Deep Links
///
/// Esta clase centraliza la configuración de deep links para la aplicación.
/// Lee las variables del archivo .env para facilitar cambios entre entornos.
///
/// ⚠️ DEPRECADO: Estos valores deben configurarse por flavor en FlavorConfig
///
/// **Esquema personalizado:** Definido en .env (DEEP_LINK_SCHEME)
/// **Dominio web:** Definido en .env (DEEP_LINK_DOMAIN)
///
/// Ejemplo de uso:
/// ```dart
/// // URL personalizada
/// yourscheme://home
///
/// // URL web (Universal Link / App Link)
/// https://yourdomain.com/home
/// ```
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeepLinkConfig {
  /// Dominio web para App Links (Android) y Universal Links (iOS)
  /// Por defecto: 'example.com' (debe configurarse en .env por flavor)
  /// ⚠️ DEPRECADO: Usar FlavorConfig.domain
  static String get domain =>
      dotenv.env['DEEP_LINK_DOMAIN'] ?? 'example.com';

  /// Esquema de URL personalizado (sin ://)
  /// Por defecto: 'opnapp' (debe configurarse en .env por flavor)
  /// ⚠️ DEPRECADO: Usar FlavorConfig.deepLinkScheme
  static String get scheme =>
      dotenv.env['DEEP_LINK_SCHEME'] ?? 'opnapp';

  /// URL base completa para deep links web
  /// Ejemplo: 'https://oposicionesguardiacivil.online'
  static String get baseUrl => 'https://$domain';

  /// Genera una URL de deep link personalizada
  ///
  /// Ejemplo:
  /// ```dart
  /// DeepLinkConfig.createCustomLink('/home')
  /// // Retorna: 'yourscheme://home'
  /// ```
  static String createCustomLink(String path) {
    // Quitar el '/' inicial si existe
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$scheme://$cleanPath';
  }

  /// Genera una URL web para Universal Links / App Links
  ///
  /// Ejemplo:
  /// ```dart
  /// DeepLinkConfig.createWebLink('/home')
  /// // Retorna: 'https://yourdomain.com/home'
  /// ```
  static String createWebLink(String path) {
    // Asegurar que el path empiece con '/'
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$cleanPath';
  }

  /// Verifica si una URL es un deep link válido de esta app
  static bool isValidDeepLink(String url) {
    return url.startsWith('$scheme://') ||
           url.startsWith('https://$domain') ||
           url.startsWith('http://$domain');
  }

  /// Lista de todas las rutas soportadas por la app
  /// Útil para validación y generación de links
  static const List<String> supportedRoutes = [
    '/welcome',
    '/onboarding',
    '/home',
    '/loading',
    '/topic-test',
    '/preview-topic',
    '/preview-topic-group',
    '/test-config',
    '/test',
    '/survival-test',
    '/pomodoro',
    '/history',
    '/history-test-review',
    '/history-final-test-review',
    '/favorites',
    '/favorite-question',
    '/challenges',
    '/challenge-detail',
    '/ranking',
    '/group-ranking',
    '/opn-ranking',
    '/stats',
    '/ai-chat',
    '/login',
    '/signin',
    '/register',
    '/signup',
    '/forgot-password',
    '/success',
    '/profile',
    '/settings',
    '/chat-settings',
  ];
}
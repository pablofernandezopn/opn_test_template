import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;

/// Configuración de API Keys para RevenueCat según entorno y plataforma
class RevenueCatKeys {
  RevenueCatKeys._();

  /// Obtiene la API key apropiada según la plataforma y el entorno
  static String getApiKey() {
    if (Platform.isAndroid) {
      return _getAndroidKey();
    } else if (Platform.isIOS || Platform.isMacOS) {
      return _getAppleKey();
    }

    throw UnsupportedError('Plataforma no soportada para RevenueCat');
  }

  /// Obtiene la key de Android según el entorno
  static String _getAndroidKey() {
    // En debug o profile, usar key de testing
    if (kDebugMode || !kReleaseMode) {
      return _androidDebugKey;
    }

    // En release, usar key de producción
    return _androidProductionKey;
  }

  /// Obtiene la key de Apple (iOS/macOS)
  static String _getAppleKey() {
    // Apple usa la misma key para todos los entornos
    // (RevenueCat gestiona los entornos internamente en el dashboard)
    return _appleKey;
  }

  // --- API Keys ---

  /// Key de Android para debug/testing
  static const String _androidDebugKey = 'test_VSJEHGJVEjvWMxEHkHPmeAKnpWI';

  /// Key de Android para producción
  static const String _androidProductionKey = 'goog_uJONRiTYgctXejWQFcoCnposFye';

  /// Key de Apple (iOS/macOS)
  static const String _appleKey = 'appl_RYptibFqrvLPgMZEzxbsGfHMfqs';

  // --- Getters para información ---

  /// Retorna true si estamos usando keys de testing
  static bool get isUsingTestKey {
    if (Platform.isAndroid) {
      return !kReleaseMode;
    }
    return false; // Apple usa la misma key para todos los entornos
  }

  /// Retorna el nombre del entorno actual
  static String get currentEnvironment {
    if (kReleaseMode) return 'production';
    if (kDebugMode) return 'debug';
    return 'profile';
  }
}
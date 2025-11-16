/// 🎨 Configuración de Flavors
///
/// Esta clase centraliza toda la configuración específica de cada flavor.
/// Cada app (Guardia Civil, Policía Nacional, etc.) tiene su propio config.json
/// que define colores, textos, URLs, credenciales, etc.
///
/// **Estructura de archivos por flavor:**
/// ```
/// flavors/
///   guardia_civil/
///     config.json          <- Configuración del flavor
///     .env.guardia_civil   <- Variables de entorno
///     android/
///       upload-keystore.jks
///       key.properties
///     ios/
///       ...
///     assets/
///       images/
///         logo.png
/// ```
///
/// **Uso:**
/// ```dart
/// // Inicializar al arrancar la app
/// await FlavorConfig.initialize('guardia_civil');
///
/// // Acceder a la configuración
/// final appName = FlavorConfig.instance.appName;
/// final primaryColor = FlavorConfig.instance.primaryColor;
/// ```
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuración global del flavor actual
class FlavorConfig {
  FlavorConfig._({
    required this.flavorName,
    required this.appName,
    required this.organizationName,
    required this.domain,
    required this.website,
    required this.supportEmail,
    required this.termsUrl,
    required this.privacyUrl,
    required this.packageName,
    required this.bundleId,
    required this.deepLinkScheme,
    required this.deepLinkDomain,
    required this.primaryColor,
    required this.primaryLight,
    required this.primaryDark,
    required this.primaryContainer,
    required this.secondaryColor,
    required this.secondaryContainer,
    required this.accentColor,
    required this.tertiaryContainer,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.errorColor,
    required this.successColor,
    required this.warningColor,
    required this.logoPath,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.disclaimerText,
    required this.welcomeSubtitle,
  });

  // ════════════════════════════════════════════════════════════════
  // INFORMACIÓN BÁSICA
  // ════════════════════════════════════════════════════════════════

  /// Nombre del flavor (ej: 'guardia_civil', 'policia_nacional')
  final String flavorName;

  /// Nombre de la aplicación (ej: 'OPN Test Guardia Civil')
  final String appName;

  /// Nombre de la organización (ej: 'Oposiciones Guardia Civil')
  final String organizationName;

  /// Dominio principal (ej: 'oposicionesguardiacivil.online')
  final String domain;

  /// URL del sitio web (ej: 'www.oposicionesguardiacivil.online')
  final String website;

  /// Email de soporte (ej: 'hola@oposicionesguardiacivil.online')
  final String supportEmail;

  /// URL de términos y condiciones
  final String termsUrl;

  /// URL de política de privacidad
  final String privacyUrl;

  // ════════════════════════════════════════════════════════════════
  // IDENTIFICADORES DE PLATAFORMA
  // ════════════════════════════════════════════════════════════════

  /// Package name de Android (ej: 'com.isyfu.opn.guardiacivil')
  final String packageName;

  /// Bundle ID de iOS (ej: 'com.isyfu.opn.guardiacivil')
  final String bundleId;

  // ════════════════════════════════════════════════════════════════
  // DEEP LINKS
  // ════════════════════════════════════════════════════════════════

  /// Esquema de deep link (ej: 'opngc')
  final String deepLinkScheme;

  /// Dominio para App Links / Universal Links
  final String deepLinkDomain;

  // ════════════════════════════════════════════════════════════════
  // COLORES Y BRANDING
  // ════════════════════════════════════════════════════════════════

  /// Color primario de la app (usado para botones principales, AppBar, etc.)
  final Color primaryColor;

  /// Color primario más claro (para hover, estados presionados)
  final Color primaryLight;

  /// Color primario más oscuro
  final Color primaryDark;

  /// Color del contenedor primario
  final Color primaryContainer;

  /// Color secundario (acciones secundarias)
  final Color secondaryColor;

  /// Color del contenedor secundario
  final Color secondaryContainer;

  /// Color de acento/terciario (highlights, badges)
  final Color accentColor;

  /// Color del contenedor terciario
  final Color tertiaryContainer;

  /// Color de fondo principal
  final Color backgroundColor;

  /// Color de superficie (cards, dialogs)
  final Color surfaceColor;

  /// Color de error
  final Color errorColor;

  /// Color de éxito/success
  final Color successColor;

  /// Color de advertencia/warning
  final Color warningColor;

  /// Ruta al logo (ej: 'flavors/guardia_civil/assets/images/logo.png')
  final String logoPath;

  // ════════════════════════════════════════════════════════════════
  // SERVICIOS BACKEND
  // ════════════════════════════════════════════════════════════════

  /// URL de Supabase
  final String supabaseUrl;

  /// Clave anónima de Supabase
  final String supabaseAnonKey;

  // ════════════════════════════════════════════════════════════════
  // TEXTOS PERSONALIZADOS
  // ════════════════════════════════════════════════════════════════

  /// Descargo de responsabilidad
  final String disclaimerText;

  /// Subtítulo de bienvenida
  final String welcomeSubtitle;

  // ════════════════════════════════════════════════════════════════
  // SINGLETON
  // ════════════════════════════════════════════════════════════════

  static FlavorConfig? _instance;

  /// Instancia singleton del flavor actual
  static FlavorConfig get instance {
    if (_instance == null) {
      throw Exception(
        'FlavorConfig no ha sido inicializado. '
        'Llama a FlavorConfig.initialize(flavorName) antes de usarlo.',
      );
    }
    return _instance!;
  }

  /// Verifica si FlavorConfig ha sido inicializado
  static bool get isInitialized => _instance != null;

  // ════════════════════════════════════════════════════════════════
  // INICIALIZACIÓN
  // ════════════════════════════════════════════════════════════════

  /// Inicializa la configuración del flavor
  ///
  /// Debe llamarse al inicio de la app, antes de runApp():
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await FlavorConfig.initialize('guardia_civil');
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// Carga el archivo `flavors/{flavorName}/config.json`
  static Future<void> initialize(String flavorName) async {
    try {
      // Cargar archivo de configuración
      final configPath = 'flavors/$flavorName/config.json';
      final configString = await rootBundle.loadString(configPath);
      final configJson = json.decode(configString) as Map<String, dynamic>;

      // Parsear colores del config.json
      final colors = configJson['branding']['colors'] as Map<String, dynamic>;

      _instance = FlavorConfig._(
        flavorName: flavorName,

        // Información básica
        appName: configJson['app']['name'] as String,
        organizationName: configJson['app']['organizationName'] as String,
        domain: configJson['app']['domain'] as String,
        website: configJson['app']['website'] as String,
        supportEmail: configJson['app']['supportEmail'] as String,
        termsUrl: configJson['app']['termsUrl'] as String,
        privacyUrl: configJson['app']['privacyUrl'] as String,

        // Identificadores
        packageName: configJson['identifiers']['packageName'] as String,
        bundleId: configJson['identifiers']['bundleId'] as String,

        // Deep links
        deepLinkScheme: configJson['deepLinks']['scheme'] as String,
        deepLinkDomain: configJson['deepLinks']['domain'] as String,

        // Colores completos
        primaryColor: _colorFromHex(colors['primary'] as String),
        primaryLight: _colorFromHex(colors['primaryLight'] as String),
        primaryDark: _colorFromHex(colors['primaryDark'] as String),
        primaryContainer: _colorFromHex(colors['primaryContainer'] as String),
        secondaryColor: _colorFromHex(colors['secondary'] as String),
        secondaryContainer: _colorFromHex(colors['secondaryContainer'] as String),
        accentColor: _colorFromHex(colors['accent'] as String),
        tertiaryContainer: _colorFromHex(colors['tertiaryContainer'] as String),
        backgroundColor: _colorFromHex(colors['background'] as String),
        surfaceColor: _colorFromHex(colors['surface'] as String),
        errorColor: _colorFromHex(colors['error'] as String),
        successColor: _colorFromHex(colors['success'] as String),
        warningColor: _colorFromHex(colors['warning'] as String),
        logoPath: configJson['branding']['logoPath'] as String,

        // Servicios
        supabaseUrl: configJson['services']['supabase']['url'] as String,
        supabaseAnonKey: configJson['services']['supabase']['anonKey'] as String,

        // Textos
        disclaimerText: configJson['texts']['disclaimer'] as String,
        welcomeSubtitle: configJson['texts']['welcomeSubtitle'] as String,
      );

      debugPrint('✅ FlavorConfig inicializado: $flavorName');
      debugPrint('   App: ${_instance!.appName}');
      debugPrint('   Domain: ${_instance!.domain}');
      debugPrint('   Package: ${_instance!.packageName}');
    } catch (e, stackTrace) {
      debugPrint('❌ Error al inicializar FlavorConfig: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════

  /// Convierte un string hexadecimal en Color
  ///
  /// Soporta formatos:
  /// - '#RRGGBB'
  /// - '#AARRGGBB'
  /// - 'RRGGBB'
  /// - 'AARRGGBB'
  static Color _colorFromHex(String hexString) {
    final buffer = StringBuffer();

    // Quitar '#' si existe
    if (hexString.startsWith('#')) {
      hexString = hexString.substring(1);
    }

    // Si no tiene alpha, agregar FF
    if (hexString.length == 6) {
      buffer.write('FF');
    }

    buffer.write(hexString);
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Obtiene la URL completa a partir de un path
  String getFullUrl(String path) {
    return 'https://$domain$path';
  }

  /// Obtiene una URL de deep link personalizada
  String getDeepLink(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$deepLinkScheme://$cleanPath';
  }

  /// Obtiene una URL de App Link / Universal Link
  String getAppLink(String path) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return 'https://$deepLinkDomain$cleanPath';
  }

  // ════════════════════════════════════════════════════════════════
  // DEBUG
  // ════════════════════════════════════════════════════════════════

  /// Imprime toda la configuración (útil para debugging)
  void printConfig() {
    debugPrint('');
    debugPrint('🎨 ═══════════════════════════════════════════════════════');
    debugPrint('   FLAVOR CONFIGURATION: $flavorName');
    debugPrint('   ═══════════════════════════════════════════════════════');
    debugPrint('   App Name:          $appName');
    debugPrint('   Organization:      $organizationName');
    debugPrint('   Domain:            $domain');
    debugPrint('   Website:           $website');
    debugPrint('   Support Email:     $supportEmail');
    debugPrint('   ───────────────────────────────────────────────────────');
    debugPrint('   Package Name:      $packageName');
    debugPrint('   Bundle ID:         $bundleId');
    debugPrint('   ───────────────────────────────────────────────────────');
    debugPrint('   Deep Link Scheme:  $deepLinkScheme');
    debugPrint('   Deep Link Domain:  $deepLinkDomain');
    debugPrint('   ───────────────────────────────────────────────────────');
    debugPrint('   Primary Color:     $primaryColor');
    debugPrint('   Secondary Color:   $secondaryColor');
    debugPrint('   Accent Color:      $accentColor');
    debugPrint('   Logo Path:         $logoPath');
    debugPrint('   ───────────────────────────────────────────────────────');
    debugPrint('   Supabase URL:      $supabaseUrl');
    debugPrint('   ═══════════════════════════════════════════════════════');
    debugPrint('');
  }
}

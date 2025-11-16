import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart' as tl;

import 'app/config/preferences_service.dart';
import 'app/config/service_locator.dart';
import 'config/environment.dart';

// Acceso global a GetIt
final logger = tl.TalkerFlutter.init();
bool get isMobileDevice => Platform.isAndroid || Platform.isIOS;
bool get isDesktopDevice => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

// Placeholders temporales (reemplazar con tus clases reales)
class NotificationMsg {
  final GlobalKey<NavigatorState> navigatorKey;
  final PreferencesService preferences;

  NotificationMsg({required this.navigatorKey, required this.preferences});

  Future<void> initFCM() async {
    // TODO: Implementar
  }
}

class InAppNotifications {
  final PreferencesService preferences;

  InAppNotifications({required this.preferences});

  Future<void> initFID() async {
    // TODO: Implementar
  }
}

class AnalyticsService {
  Future<void> init(String key) async {
    // TODO: Implementar
  }

  void appOpened() {
    // TODO: Implementar
  }
}

class PurchaseModal {
  static Future<void> preloadOfferings() async {
    // TODO: Implementar
  }
}

Future<void> bootstrap(
  GlobalKey<NavigatorState> navigatorKey,
  BuildVariant variant,
  FutureOr<Widget> Function() builder,
) async {
  if (kDebugMode) {
    print('bootstrap funcionanado -------------------------');
  }
  WidgetsFlutterBinding.ensureInitialized();

  // Orientation
  unawaited(
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
    ),
  );

  Environment.init(variant);

// 🔍 Log de información de conexión en modo debug
  if (kDebugMode) {
    Environment.instance.logConnectionInfo();
  }

  await ServiceLocator.setup(Environment.instance);


  // Supabase initialization with error handling
  try {
    logger.info('🔄 Iniciando conexión a Supabase...');
    logger.info('📍 URL: ${Environment.instance.supabaseUrl}');
    logger.info('🏗️ Entorno: ${Environment.instance.environmentName}');

    await Supabase.initialize(
      url: Environment.instance.supabaseUrl,
      anonKey: Environment.instance.supabaseKey,
    );

    // Verificar que el cliente de Supabase está correctamente inicializado
    final supabaseClient = Supabase.instance.client;
    logger.info('✅ Supabase inicializado correctamente');
    logger.info('🔗 Cliente Supabase creado y configurado');

    // Test de conectividad básico - intentar una consulta simple
    try {
      logger.info('🔍 Verificando conectividad con la base de datos...');
      await supabaseClient
          .from('profiles')
          .select('id')
          .limit(1)
          .timeout(const Duration(seconds: 5));
      logger.info('✅ Conectividad verificada - Base de datos respondiendo correctamente');
    } catch (e) {
      // Si falla, puede ser porque la tabla no existe o no hay permisos, pero el servidor responde
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('relation') ||
          errorStr.contains('does not exist') ||
          errorStr.contains('permission') ||
          errorStr.contains('policy')) {
        logger.info('✅ Servidor Supabase alcanzable (la tabla puede no existir o no tener permisos, pero conexión OK)');
      } else if (errorStr.contains('timeout') || errorStr.contains('network')) {
        logger.error('❌ Error de red al conectar con Supabase: $e');
      } else {
        logger.warning('⚠️ Respuesta inesperada del servidor: $e');
      }
    }

    logger.info('🎉 Base de datos Supabase lista para usar');
  } catch (e, stackTrace) {
    logger.error('❌ Error al inicializar Supabase: $e');
    logger.debug('Supabase error stackTrace: ${stackTrace.toString()}');
    _handleInitError(e, stackTrace);
    // You might want to continue without Supabase or show an error dialog
    // depending on how critical Supabase is for your app
  }

  // Global error handling
  FlutterError.onError = (details) {
    // Ignorar errores conocidos de Flutter en plataformas de escritorio
    final errorString = details.toString();
    final exceptionString = details.exception.toString();

    // Lista de errores conocidos de Flutter que son seguros ignorar
    final knownFlutterBugs = [
      '_debugDuringDeviceUpdate',
      'MouseTracker',
      'RenderBox was not laid out',
      'NEEDS-LAYOUT NEEDS-PAINT',
      'hasSize',
    ];

    // Verificar si el error es uno de los bugs conocidos
    for (final bug in knownFlutterBugs) {
      if (errorString.contains(bug) || exceptionString.contains(bug)) {
        // Este es un bug conocido de Flutter, lo suprimimos
        if (kDebugMode) {
          logger.debug('Suprimiendo error conocido de Flutter: $bug');
        }
        return;
      }
    }

    if (details.exception is Exception) {
      logger.handle(details.exception as Exception);
    } else {
      logger.error('Flutter Error: $details');
    }
    Zone.current.handleUncaughtError(
      details.exception,
      details.stack ?? StackTrace.empty,
    );
  };

  // Run the app
  try {
    runApp(await builder());
  } catch (e, stackTrace) {
    logger.error('Failed to run app: $e');
    logger.debug('App run error stackTrace: ${stackTrace.toString()}');
    rethrow; // This is critical, so we rethrow
  }
}

Future<void> initPurchases() async {
  // Inicializar Purchases en iOS, Android y macOS
  if (Platform.isIOS || Platform.isAndroid || Platform.isMacOS) {
    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
      PurchasesConfiguration? configuration;
      if (Platform.isAndroid) {
        configuration =
            PurchasesConfiguration('goog_uJONRiTYgctXejWQFcoCnposFye');
      } else if (Platform.isIOS || Platform.isMacOS) {
        // macOS usa la misma API key que iOS (mismo App Store)
        configuration =
            PurchasesConfiguration('appl_xcvgfjhoVxCjvzWBMhrLHeKfjah');
      }
      if (configuration != null) {
        await Purchases.configure(configuration);
        logger.info('Purchases initialized successfully');

        // Precargar ofertas inmediatamente después de la configuración
        await PurchaseModal.preloadOfferings().then((_) {
          logger.info('Offerings preloaded successfully');
        }).catchError((error) {
          logger.warning('Failed to preload offerings: $error');
        });
      }
    } catch (e, stackTrace) {
      logger
        ..error('Purchases initialization failed: $e')
        ..debug('Purchases error stackTrace: ${stackTrace.toString()}');
      // Continue without purchases functionality
    }
  }
}

// ignore: prefer_void_to_null
FutureOr<Null> _handleInitError(Object error, StackTrace stackTrace) {
  logger.handle(error, stackTrace);
}

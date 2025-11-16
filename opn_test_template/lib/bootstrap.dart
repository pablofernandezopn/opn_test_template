import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart' as tl;

import 'app/config/preferences_service.dart';
import 'app/config/revenue_cat_keys.dart';
import 'app/config/service_locator.dart';
import 'app/features/loading/cubit/video_loading_cubit.dart';
import 'app/shared/services/deep_link_service.dart';
import 'app/shared/services/purchase_service.dart';
import 'app/shared/services/firebase_messaging_service.dart';
import 'config/environment.dart';

// Acceso global a GetIt
final logger = tl.TalkerFlutter.init();
bool get isMobileDevice => Platform.isAndroid || Platform.isIOS;
bool get isDesktopDevice => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

class AnalyticsService {
  Future<void> init(String key) async {
    // TODO: Implementar
  }

  void appOpened() {
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

  // Cargar variables de entorno
  try {
    await dotenv.load(fileName: '.env');
    logger.info('✅ Variables de entorno cargadas correctamente');
  } catch (e) {
    logger.warning('⚠️ No se pudo cargar el archivo .env: $e');
    // La app continuará con valores por defecto
  }

  // Inicializar locale español para formateo de fechas
  await initializeDateFormatting('es_ES', null);

  // Orientation - detectar si es móvil o tableta
  // En móviles (< 600px): solo vertical
  // En tabletas (>= 600px): permitir rotación
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final physicalSize = view.physicalSize;
  final devicePixelRatio = view.devicePixelRatio;
  final logicalWidth = physicalSize.width / devicePixelRatio;
  final logicalHeight = physicalSize.height / devicePixelRatio;
  final shortestSide = logicalWidth < logicalHeight ? logicalWidth : logicalHeight;

  // Si el lado más corto es menor a 600px, es un móvil
  final isMobileSize = shortestSide < 600;

  if (isMobileSize && isMobileDevice) {
    // Móvil: solo orientación vertical
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]),
    );
    logger.info('📱 Dispositivo móvil detectado - bloqueando rotación a vertical');
  } else {
    // Tableta o pantalla grande: permitir todas las orientaciones
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]),
    );
    logger.info('📱 Tableta/Pantalla grande detectada - permitiendo rotación');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Barra de estado negra
      statusBarBrightness: Brightness.dark, // Iconos claros en iOS
      statusBarIconBrightness: Brightness.light, // Iconos claros en Android
      systemNavigationBarColor: Colors.black, // Barra de navegación negra
      systemNavigationBarIconBrightness: Brightness.light, // Iconos claros
    ),
  );

  Environment.init(variant);

// 🔍 Log de información de conexión en modo debug
  if (kDebugMode) {
    Environment.instance.logConnectionInfo();
  }

  await ServiceLocator.setup(Environment.instance);

  // Inicializar servicio de deep linking
  try {
    final deepLinkService = getIt<DeepLinkService>();
    await deepLinkService.initialize();
    logger.info('✅ Servicio de Deep Links inicializado');
  } catch (e) {
    logger.warning('⚠️ Error al inicializar Deep Links: $e');
    // La app continuará sin deep links
  }

  await initPurchases().onError(_handleInitError);

  /// OneSignal initialization
  if (isMobileDevice) {
    try {
      // debugging
      logger.info('Initializing OneSignal...');
      await Future.wait([
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose),
      ]).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          logger.warning('OneSignal debug setup timeout - continuando');
          return [];
        },
      );
      OneSignal.initialize('10502b58-fbed-4dd6-8655-7af9e2369408');
      logger.info('OneSignal initialized');
    } catch (e) {
      logger.error('OneSignal initialization failed: $e');
      // Continuar sin OneSignal
    }

    // Verificar si el onboarding está completado
    final onboardingCompleted =
        (await getIt<PreferencesService>().get('onboarding_completed')) == 'true';

    // Si el onboarding está completado, verificar permisos de notificaciones
    // IMPORTANTE: Solo se ejecuta si el onboarding YA está completado
    // En la primera vez (durante el onboarding), esto NO se ejecutará
    if (onboardingCompleted) {
      // Configurar el listener para esperar a que el video termine
      unawaited(_waitForVideoAndShowNotifications(navigatorKey));
    }

    // Firebase initialization with proper error handling
    bool firebaseInitialized = false;
    try {
      await Firebase.initializeApp().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          logger.warning('Firebase initialization timeout - continuando sin Firebase');
          throw TimeoutException('Firebase initialization timeout');
        },
      );
      firebaseInitialized = true;
      logger.info('Firebase initialized successfully');
    } catch (e, stackTrace) {
      logger
        ..error('Firebase initialization failed: $e')
        ..debug('Firebase error stackTrace: ${stackTrace.toString()}');
      // Continue without Firebase instead of throwing
      firebaseInitialized = false;
    }

    // Only initialize Firebase-dependent services if Firebase was successful
    if (firebaseInitialized) {
      // Configurar el handler de mensajes en background
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      try {
        await FirebaseMessagingService(
          navigatorKey: navigatorKey,
          preferences: getIt<PreferencesService>(),
        ).initFCM().timeout(
          const Duration(seconds: 8),
          onTimeout: () {
            logger.warning('FCM initialization timeout - continuando sin FCM');
            throw TimeoutException('FCM initialization timeout');
          },
        );
        logger.info('FCM notifications initialized');
      } catch (e, stackTrace) {
        logger.error('FCM initialization failed: $e');
        logger.debug('FCM error stackTrace: ${stackTrace.toString()}');
        // Continue without FCM notifications
      }

      try {
        await FirebaseInstallationService(preferences: getIt<PreferencesService>())
            .initFID().timeout(
          const Duration(seconds: 8),
          onTimeout: () {
            logger.warning('In-app notifications initialization timeout - continuando');
            throw TimeoutException('In-app notifications initialization timeout');
          },
        );
        logger.info('In-app notifications initialized');
      } catch (e, stackTrace) {
        logger.error('In-app notifications initialization failed: $e');
        logger.debug(
            'In-app notifications error stackTrace: ${stackTrace.toString()}');
        // Continue without in-app notifications
      }
    } else {
      logger.warning(
          'Skipping Firebase-dependent services due to Firebase initialization failure');
    }
  }

  // Analytics initialization with error handling
  if (!isDesktopDevice) {
    try {
      logger.info('Initializing Amplitude...');
      await AnalyticsService().init('26e8e315718d5fc6243c4d444dd966b5').timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          logger.warning('Amplitude initialization timeout - continuando sin analytics');
          throw TimeoutException('Amplitude initialization timeout');
        },
      );
      AnalyticsService().appOpened();
      logger.info('Amplitude initialized successfully');
    } catch (e, stackTrace) {
      logger.error('Amplitude initialization failed: $e');
      logger.debug('Amplitude error stackTrace: ${stackTrace.toString()}');
      // Continue without analytics
    }
  }

  // Supabase initialization with error handling
  bool supabaseConnected = false;
  try {
    logger.info('🔄 Iniciando conexión a Supabase...');
    logger.info('📍 URL: ${Environment.instance.supabaseUrl}');
    logger.info('🏗️ Entorno: ${Environment.instance.environmentName}');

    await Supabase.initialize(
      url: Environment.instance.supabaseUrl,
      anonKey: Environment.instance.supabaseKey,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        logger.warning('Supabase initialization timeout - continuando sin Supabase');
        throw TimeoutException('Supabase initialization timeout');
      },
    );

    // Verificar que el cliente de Supabase está correctamente inicializado
    final supabaseClient = Supabase.instance.client;
    logger.info('✅ Supabase inicializado correctamente');
    logger.info('🔗 Cliente Supabase creado y configurado');

    // Test de conectividad básico - intentar una consulta simple
    try {
      logger.info('🔍 Verificando conectividad con la base de datos...');
      await supabaseClient
          .from('users')
          .select('id')
          .limit(1)
          .timeout(const Duration(seconds: 5));
      logger.info('✅ Conectividad verificada - Base de datos respondiendo correctamente');
      supabaseConnected = true;
    } catch (e) {
      // Si falla, puede ser porque la tabla no existe o no hay permisos, pero el servidor responde
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('relation') ||
          errorStr.contains('does not exist') ||
          errorStr.contains('could not find') ||
          errorStr.contains('permission') ||
          errorStr.contains('policy')) {
        logger.info('✅ Servidor Supabase alcanzable (la tabla puede no existir o no tener permisos, pero conexión OK)');
        supabaseConnected = true;
      } else if (errorStr.contains('timeout') || errorStr.contains('network') || errorStr.contains('connection refused')) {
        logger.error('❌ Error de red al conectar con Supabase: $e');
        supabaseConnected = false;
      } else {
        logger.warning('⚠️ Respuesta inesperada del servidor: $e');
        supabaseConnected = false;
      }
    }

    if (supabaseConnected) {
      logger.info('🎉 Base de datos Supabase lista para usar');
    } else {
      logger.warning('⚠️ Supabase no disponible - La app funcionará en modo offline limitado');
    }
  } catch (e, stackTrace) {
    logger.error('❌ Error al inicializar Supabase: $e');
    logger.debug('Supabase error stackTrace: ${stackTrace.toString()}');
    supabaseConnected = false;
    _handleInitError(e, stackTrace);
    // Continue without Supabase - the app will show connection error when needed
  }

  // Guardar el estado de conexión en PreferencesService
  try {
    await getIt<PreferencesService>().set('supabase_connected', supabaseConnected ? 'true' : 'false');
  } catch (e) {
    logger.warning('Failed to save Supabase connection status: $e');
  }

  // Global error handling
  FlutterError.onError = (details) {
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

      // Obtener la API key apropiada según plataforma y entorno
      final apiKey = RevenueCatKeys.getApiKey();

      logger.info(
        'Initializing Purchases with ${RevenueCatKeys.currentEnvironment} key '
        '(${RevenueCatKeys.isUsingTestKey ? "TEST" : "PRODUCTION"})'
      );

      final configuration = PurchasesConfiguration(apiKey);

      // Timeout de 10 segundos para la configuración inicial
      await Purchases.configure(configuration).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          logger.warning('RC: Configure timeout después de 10 segundos, continuando sin RC');
          throw TimeoutException('RevenueCat configure timeout');
        },
      );

      logger.info('Purchases initialized successfully');

      // Precargar ofertas con timeout
      await PurchaseService.instance.preloadOfferings().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          logger.warning('RC: Preload offerings timeout después de 5 segundos');
          return false;
        },
      ).then((success) {
        if (success) {
          logger.info('Offerings preloaded successfully');
        } else {
          logger.warning('Failed to preload offerings');
        }
      }).catchError((error) {
        logger.warning('Failed to preload offerings: $error');
      });
    } catch (e, stackTrace) {
      logger
        ..error('Purchases initialization failed (la app continuará sin RC): $e')
        ..debug('Purchases error stackTrace: ${stackTrace.toString()}');
      // Continue without purchases functionality
    }
  }
}

// ignore: prefer_void_to_null
FutureOr<Null> _handleInitError(Object error, StackTrace stackTrace) {
  logger.handle(error, stackTrace);
}

/// Espera a que el video termine antes de mostrar el diálogo de notificaciones
Future<void> _waitForVideoAndShowNotifications(
    GlobalKey<NavigatorState> navigatorKey) async {
  try {
    final videoLoadingCubit = getIt<VideoLoadingCubit>();

    // Si el video ya terminó, mostrar el diálogo inmediatamente
    if (videoLoadingCubit.state) {
      await Future.delayed(const Duration(milliseconds: 500));
      final hasPermission = OneSignal.Notifications.permission;
      logger.info('Checking notification permission after video: $hasPermission');
      if (!hasPermission) {
        await _showNotificationPermissionDialog(navigatorKey);
      }

      return;
    }

    // Si el video no ha terminado, esperar a que termine
    logger.info('Waiting for video to finish before showing notification dialog...');

    // Polling cada 500ms para verificar si el video terminó
    while (!videoLoadingCubit.state) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Video terminó, esperar un poco más para asegurar que la navegación completó
    await Future.delayed(const Duration(milliseconds: 1000));

    // Verificar permisos y mostrar diálogo si es necesario
    final hasPermission = OneSignal.Notifications.permission;
    logger.info('Video finished. Checking notification permission: $hasPermission');
    if (!hasPermission) {
      await _showNotificationPermissionDialog(navigatorKey);
    }
  } catch (e) {
    logger.error('Error waiting for video to show notifications: $e');
  }
}

/// Muestra un diálogo pidiendo permiso para notificaciones
Future<void> _showNotificationPermissionDialog(
    GlobalKey<NavigatorState> navigatorKey) async {
  final context = navigatorKey.currentContext;
  if (context == null || !context.mounted) return;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      final theme = Theme.of(dialogContext);
      return AlertDialog(
        icon: Icon(
          Icons.notifications_active_outlined,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        title: const Text('Activa las notificaciones'),
        content: const Text(
          'Te avisaremos cuando haya nuevos test, recordatorios de estudio o resultados importantes.',
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Ahora no'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                await OneSignal.Notifications.requestPermission(true);
              } catch (e) {
                logger.error('Error requesting notification permission: $e');
              }
            },
            child: const Text('Activar'),
          ),
        ],
      );
    },
  );
}

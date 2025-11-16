import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../bootstrap.dart';
import '../../config/preferences_service.dart';

/// Servicio para manejar Firebase Cloud Messaging (FCM)
/// Obtiene y guarda el token de FCM para notificaciones push
class FirebaseMessagingService {
  final GlobalKey<NavigatorState> navigatorKey;
  final PreferencesService preferences;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  FirebaseMessagingService({
    required this.navigatorKey,
    required this.preferences,
  });

  /// Inicializa Firebase Cloud Messaging y obtiene el token
  Future<void> initFCM() async {
    try {
      logger.info('🔔 Initializing FCM...');

      // Solicitar permisos de notificación
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      logger.info('FCM permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Obtener el token de FCM
        final token = await _messaging.getToken();

        if (token != null) {
          logger.info('✅ FCM Token obtained: ${token.substring(0, 20)}...');

          // Guardar el token en preferencias
          await preferences.set('fcm_token', token);
          logger.info('✅ FCM Token saved to preferences');

          // Configurar listener para cuando el token se actualice
          _messaging.onTokenRefresh.listen((newToken) {
            logger.info('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
            preferences.set('fcm_token', newToken);
          });

          // Configurar manejadores de mensajes
          _setupMessageHandlers();
        } else {
          logger.warning('⚠️ FCM Token is null');
        }
      } else {
        logger.warning('⚠️ Notification permissions not granted');
      }
    } catch (e, stackTrace) {
      logger.error('❌ Error initializing FCM: $e');
      logger.debug('FCM error stackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Configura los manejadores de mensajes de FCM
  void _setupMessageHandlers() {
    // Manejar mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.info('📬 FCM message received (foreground): ${message.messageId}');

      if (kDebugMode) {
        logger.debug('Message data: ${message.data}');
        logger.debug('Notification: ${message.notification?.title} - ${message.notification?.body}');
      }

      // Aquí puedes agregar lógica para mostrar notificaciones in-app
      _showInAppNotification(message);
    });

    // Manejar cuando el usuario toca una notificación y la app está en background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logger.info('📬 FCM notification opened (background): ${message.messageId}');

      if (kDebugMode) {
        logger.debug('Message data: ${message.data}');
      }

      // Aquí puedes agregar lógica para navegar a una pantalla específica
      _handleNotificationTap(message);
    });

    // Verificar si la app se abrió desde una notificación cuando estaba terminada
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        logger.info('📬 FCM notification opened (terminated): ${message.messageId}');
        _handleNotificationTap(message);
      }
    });
  }

  /// Muestra una notificación in-app cuando la app está en primer plano
  void _showInAppNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    // Mostrar un SnackBar con la notificación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (notification.title != null)
              Text(
                notification.title!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (notification.body != null) Text(notification.body!),
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () => _handleNotificationTap(message),
        ),
      ),
    );
  }

  /// Maneja cuando el usuario toca una notificación
  void _handleNotificationTap(RemoteMessage message) {
    logger.info('🔔 Handling notification tap for: ${message.messageId}');

    // Aquí puedes agregar lógica de navegación basada en los datos del mensaje
    final data = message.data;

    if (data.containsKey('route')) {
      final route = data['route'] as String;
      logger.info('Navigating to route: $route');

      // Navegar usando el NavigatorKey global
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        // Pequeña pausa para asegurar que la app está lista
        Future.delayed(const Duration(milliseconds: 300), () {
          if (navigatorKey.currentContext != null) {
            // Usar GoRouter para navegar
            // Nota: GoRouter.of(context).go(route) o .push(route)
            // Dependiendo de si quieres reemplazar la ruta o apilar
            navigatorKey.currentContext!.go(route);
            logger.info('✅ Navigation completed to: $route');
          }
        });
      } else {
        logger.warning('⚠️ Cannot navigate: context is null or not mounted');
      }
    } else {
      logger.debug('No route specified in notification data');
    }
  }

  /// Obtiene el token actual de FCM (útil para debugging)
  Future<String?> getCurrentToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      logger.error('Error getting current FCM token: $e');
      return null;
    }
  }

  /// Elimina el token de FCM (útil para logout)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      await preferences.remove('fcm_token');
      logger.info('✅ FCM token deleted');
    } catch (e) {
      logger.error('Error deleting FCM token: $e');
    }
  }
}

/// Servicio para manejar Firebase Installation ID (FID)
/// Usado para Firebase In-App Messaging
class FirebaseInstallationService {
  final PreferencesService preferences;

  FirebaseInstallationService({required this.preferences});

  /// Inicializa Firebase Installations y obtiene el FID
  Future<void> initFID() async {
    try {
      logger.info('🔧 Initializing Firebase Installations...');

      // Obtener el Firebase Installation ID
      final fid = await FirebaseInstallations.instance.getId();

      logger.info('✅ Firebase Installation ID obtained: ${fid.substring(0, 20)}...');

      // Guardar el FID en preferencias
      await preferences.set('fid_token', fid);
      logger.info('✅ FID saved to preferences');

      // Listener para cuando el FID cambie
      FirebaseInstallations.instance.onIdChange.listen((newFid) {
        logger.info('🔄 FID changed: ${newFid.substring(0, 20)}...');
        preferences.set('fid_token', newFid);
      });
    } catch (e, stackTrace) {
      logger.error('❌ Error initializing Firebase Installations: $e');
      logger.debug('FID error stackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene el FID actual (útil para debugging)
  Future<String> getCurrentFID() async {
    try {
      return await FirebaseInstallations.instance.getId();
    } catch (e) {
      logger.error('Error getting current FID: $e');
      rethrow;
    }
  }

  /// Elimina la instalación actual de Firebase (útil para testing)
  Future<void> deleteInstallation() async {
    try {
      await FirebaseInstallations.instance.delete();
      await preferences.remove('fid_token');
      logger.info('✅ Firebase Installation deleted');
    } catch (e) {
      logger.error('Error deleting Firebase Installation: $e');
    }
  }
}

/// Handler para mensajes en background
/// Debe ser una función top-level o estática
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  logger.info('📬 Handling FCM background message: ${message.messageId}');

  if (kDebugMode) {
    logger.debug('Background message data: ${message.data}');
    logger.debug('Background notification: ${message.notification?.title}');
  }
}
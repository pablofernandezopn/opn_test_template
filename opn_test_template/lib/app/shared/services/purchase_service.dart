import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../../bootstrap.dart';

/// Servicio para gestionar las compras in-app con RevenueCat
class PurchaseService {
  PurchaseService._();

  static final PurchaseService _instance = PurchaseService._();
  static PurchaseService get instance => _instance;

  /// Indica si las offerings ya fueron precargadas
  bool _offeringsPreloaded = false;

  /// Offerings cacheadas
  Offerings? _cachedOfferings;

  /// Indica si hay una precarga en progreso para evitar múltiples llamadas simultáneas
  bool _isPreloading = false;

  /// Completer para sincronizar múltiples llamadas de precarga
  Completer<void>? _preloadCompleter;

  /// Precarga las offerings de RevenueCat para acelerar la visualización posterior
  ///
  /// Esta función debe llamarse al inicio de la app, después de configurar
  /// Purchases, para que cuando el usuario quiera ver el paywall, la respuesta
  /// sea instantánea.
  ///
  /// Returns: `true` si la precarga fue exitosa, `false` en caso contrario
  Future<bool> preloadOfferings() async {
    // Si ya están precargadas, retornar inmediatamente
    if (_offeringsPreloaded && _cachedOfferings != null) {
      logger.debug('Offerings already preloaded, skipping');
      return true;
    }

    // Si hay una precarga en progreso, esperar a que termine
    if (_isPreloading && _preloadCompleter != null) {
      logger.debug('Preload already in progress, waiting...');
      await _preloadCompleter!.future;
      return _offeringsPreloaded;
    }

    // Iniciar nueva precarga
    _isPreloading = true;
    _preloadCompleter = Completer<void>();

    try {
      logger.info('Preloading RevenueCat offerings...');

      // Obtener offerings de RevenueCat
      _cachedOfferings = await Purchases.getOfferings();

      if (_cachedOfferings == null) {
        logger.warning('No offerings available from RevenueCat');
        _offeringsPreloaded = false;
        return false;
      }

      // Verificar que haya al menos una offering
      if (_cachedOfferings!.all.isEmpty) {
        logger.warning('RevenueCat offerings are empty');
        _offeringsPreloaded = false;
        return false;
      }

      _offeringsPreloaded = true;
      logger.info('RevenueCat offerings preloaded successfully');
      logger.debug('Available offerings: ${_cachedOfferings!.all.keys.join(", ")}');

      return true;
    } catch (e, stackTrace) {
      logger.error('Failed to preload RevenueCat offerings: $e');
      logger.debug('Stacktrace: $stackTrace');
      _offeringsPreloaded = false;
      _cachedOfferings = null;
      return false;
    } finally {
      _isPreloading = false;
      _preloadCompleter?.complete();
      _preloadCompleter = null;
    }
  }

  /// Muestra el paywall de RevenueCat UI
  ///
  /// Esta función muestra la UI nativa de RevenueCat para que el usuario
  /// pueda ver y comprar suscripciones.
  ///
  /// [context] - BuildContext necesario para mostrar el paywall
  /// [offeringIdentifier] - Identificador opcional de la offering a mostrar.
  ///                        Si es null, se mostrará la offering actual (default)
  ///
  /// Returns: `PaywallResult` con el resultado de la interacción
  Future<PaywallResult?> showPaywall({
    required BuildContext context,
    String? offeringIdentifier,
  }) async {
    // Verificar que estamos en una plataforma soportada
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
      logger.warning('Paywall not supported on this platform');
      _showPlatformNotSupportedDialog(context);
      return null;
    }

    try {
      logger.info('Showing RevenueCat paywall...');

      // Si las offerings no están precargadas, intentar cargarlas ahora
      if (!_offeringsPreloaded || _cachedOfferings == null) {
        logger.debug('Offerings not preloaded, loading now...');
        final success = await preloadOfferings();

        if (!success) {
          logger.error('Failed to load offerings before showing paywall');
          if (context.mounted) {
            _showErrorDialog(
              context,
              'No hay suscripciones disponibles en este momento. Intenta más tarde.',
            );
          }
          return null;
        }
      }

      // Determinar qué offering mostrar
      final offering = offeringIdentifier != null
          ? _cachedOfferings!.all[offeringIdentifier]
          : _cachedOfferings!.current;

      if (offering == null) {
        logger.error('Offering not found: ${offeringIdentifier ?? "current"}');
        if (context.mounted) {
          _showErrorDialog(
            context,
            'No se pudo cargar la información de suscripciones.',
          );
        }
        return null;
      }

      logger.debug('Showing offering: ${offering.identifier}');

      // Mostrar el paywall usando RevenueCat UI
      final result = await RevenueCatUI.presentPaywall(
        offering: offering,
      );

      logger.info('Paywall result: ${result.name}');
      return result;

    } catch (e, stackTrace) {
      logger.error('Error showing paywall: $e');
      logger.debug('Stacktrace: $stackTrace');

      if (context.mounted) {
        _showErrorDialog(
          context,
          'Ocurrió un error al mostrar las suscripciones. Intenta nuevamente.',
        );
      }

      return null;
    }
  }

  /// Obtiene las offerings actuales
  ///
  /// Si ya están cacheadas, retorna el cache. Si no, las obtiene de RevenueCat.
  Future<Offerings?> getOfferings() async {
    if (_cachedOfferings != null) {
      return _cachedOfferings;
    }

    try {
      _cachedOfferings = await Purchases.getOfferings();
      return _cachedOfferings;
    } catch (e, stackTrace) {
      logger.error('Failed to get offerings: $e');
      logger.debug('Stacktrace: $stackTrace');
      return null;
    }
  }

  /// Invalida el cache de offerings
  ///
  /// Útil cuando se necesita forzar una recarga de offerings
  void invalidateCache() {
    logger.debug('Invalidating offerings cache');
    _cachedOfferings = null;
    _offeringsPreloaded = false;
  }

  /// Verifica si el usuario tiene una suscripción activa
  ///
  /// [entitlementIdentifier] - Identificador del entitlement a verificar
  ///
  /// Returns: `true` si el usuario tiene el entitlement activo
  Future<bool> hasActiveEntitlement(String entitlementIdentifier) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlements = customerInfo.entitlements.all;

      if (entitlements.containsKey(entitlementIdentifier)) {
        final entitlement = entitlements[entitlementIdentifier];
        return entitlement?.isActive ?? false;
      }

      return false;
    } catch (e, stackTrace) {
      logger.error('Failed to check entitlement: $e');
      logger.debug('Stacktrace: $stackTrace');
      return false;
    }
  }

  /// Restaura las compras del usuario
  ///
  /// Returns: CustomerInfo actualizado después de restaurar
  Future<CustomerInfo?> restorePurchases() async {
    try {
      logger.info('Restoring purchases...');
      // Timeout de 5 segundos para evitar bloqueos
      final customerInfo = await Purchases.restorePurchases().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          logger.warning('RC: RestorePurchases timeout después de 5 segundos');
          throw TimeoutException('RevenueCat restore timeout');
        },
      );
      logger.info('Purchases restored successfully');
      return customerInfo;
    } catch (e, stackTrace) {
      logger.error('Failed to restore purchases (continuando sin RC): $e');
      logger.debug('Stacktrace: $stackTrace');
      return null;
    }
  }

  // --- Helper methods para mostrar diálogos ---

  void _showPlatformNotSupportedDialog(BuildContext context) {
    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        icon: const Icon(Icons.info_outline, size: 48),
        title: const Text('No disponible'),
        content: const Text(
          'Las suscripciones no están disponibles en esta plataforma.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        icon: const Icon(Icons.error_outline, size: 48, color: Colors.red),
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
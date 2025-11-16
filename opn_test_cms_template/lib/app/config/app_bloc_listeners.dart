import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bootstrap.dart';
import '../authentification/auth/cubit/auth_cubit.dart';
import '../authentification/auth/cubit/auth_state.dart';
import '../features/specialties/cubit/cubit.dart';
import '../features/specialties/view/components/user_specialty_selection_dialog.dart';
import 'go_route/app_routes.dart';

/// 🎯 Listeners Globales de la Aplicación
///
/// Centraliza los listeners que reaccionan a cambios en los Cubits globales.
/// Actualmente maneja la navegación automática según el estado de autenticación.
class AppBlocListeners {
  static bool _specialtyDialogShown = false;
  static List<BlocListener> listeners(GlobalKey<NavigatorState> navigatorKey) {
    return [
      BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) {
          // Escuchar cambios en el estado de autenticación
          final statusChanged = previous.status != current.status;

          // Escuchar cambios en la especialidad del usuario
          // IMPORTANTE: Solo reaccionar si realmente cambió de un valor a otro
          // No reaccionar si ambos son el mismo valor (incluyendo null)
          final previousSpecialtyId = previous.user.specialtyId;
          final currentSpecialtyId = current.user.specialtyId;
          final specialtyChanged = previousSpecialtyId != currentSpecialtyId;

          if (statusChanged) {
            logger.debug(
                '🎯 Auth status changed: ${previous.status} → ${current.status}');
          }

          if (specialtyChanged) {
            logger.debug(
                '🎯 User specialty changed: $previousSpecialtyId → $currentSpecialtyId');
          }

          // Solo escuchar si el STATUS cambió O si la SPECIALTY cambió de un valor a otro
          // No reaccionar a otros cambios del usuario (como avatar, nombre, etc.)
          return statusChanged || specialtyChanged;
        },
        listener: (context, state) {
          logger.info('🎯 Auth state changed to: ${state.status}');
          _handleAuthStateChange(context, state);
        },
      ),
    ];
  }

  static void _handleAuthStateChange(BuildContext context, AuthState state) {
    if (!context.mounted) return;

    final currentLocation = _getCurrentLocation(context);

    switch (state.status) {
      case AuthStatus.authenticated:
        _navigateIfAuthenticated(context, state, currentLocation);
        break;

      case AuthStatus.unauthenticated:
        _navigateToSignIn(context, currentLocation);
        break;

      case AuthStatus.appAccessError:
        _showAccessError(context);
        break;

      case AuthStatus.unknown:
        // No hacer nada, esperando estado definitivo
        break;
    }

    // Mostrar alerta si la app está desactualizada
    if (state.deviceInfo?.deprecated ?? false) {
      _showDeprecatedVersionAlert(context, state);
    }
  }

  static String _getCurrentLocation(BuildContext context) {
    try {
      return GoRouter.of(context)
          .routerDelegate
          .currentConfiguration
          .uri
          .toString();
    } catch (e) {
      return AppRoutes.signin;
    }
  }

  static void _navigateIfAuthenticated(
    BuildContext context,
    AuthState state,
    String currentLocation,
  ) {
    // Verificar que realmente hay token
    final hasToken =
        state.token.isNotEmpty || (state.user.token?.isNotEmpty ?? false);

    if (!hasToken) {
      logger.warning('⚠️ User authenticated but no token found');
      return;
    }

    // Verificar si el usuario necesita seleccionar especialidad
    // SOLO mostrar el diálogo si está en una pantalla pública (login/inicial)
    // NO mostrar si está en perfil u otras pantallas privadas
    final isInPublicScreen = currentLocation == AppRoutes.signin ||
        currentLocation == AppRoutes.initial;

    if (state.user.specialtyId == null && isInPublicScreen) {
      logger.info('ℹ️ User has no specialty, showing selection dialog');
      _showSpecialtySelectionDialog(context);
      return;
    }

    // Si el usuario ya tiene especialidad, navegar a home solo si está en pantalla pública
    if (isInPublicScreen && state.user.specialtyId != null && context.mounted) {
      logger.debug('✅ User has specialty, navigating to home');
      context.go(AppRoutes.home);
    }
  }

  static void _showSpecialtySelectionDialog(BuildContext context) {
    if (!context.mounted || _specialtyDialogShown) return;

    // Marcar que el diálogo ya se mostró
    _specialtyDialogShown = true;

    // Cargar especialidades si no están cargadas
    final specialtyCubit = context.read<SpecialtyCubit>();
    if (specialtyCubit.state.activeSpecialties.isEmpty) {
      specialtyCubit.loadSpecialties();
    }

    // Mostrar el diálogo después de que el frame se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        UserSpecialtySelectionDialog.show(context).then((_) {
          // Resetear la bandera cuando el diálogo se cierre
          _specialtyDialogShown = false;
        });
      }
    });
  }

  static void _navigateToSignIn(BuildContext context, String currentLocation) {
    if (currentLocation != AppRoutes.signin && context.mounted) {
      logger.debug('❌ User unauthenticated, navigating to sign in');
      context.go(AppRoutes.signin);
    }
  }

  static void _showAccessError(BuildContext context) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Error de Acceso'),
        content: const Text(
          'No tienes acceso a esta aplicación.\n\n'
          'Por favor, contacta con soporte.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.signin);
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  static void _showDeprecatedVersionAlert(
      BuildContext context, AuthState state) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Actualización Disponible'),
        content: Text(
          'Hay una nueva versión disponible de la aplicación.\n\n'
          'Versión actual: ${state.deviceInfo?.numberVersion ?? "Desconocida"}\n\n'
          'Por favor, actualiza la aplicación para continuar.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Abrir la tienda de aplicaciones
              Navigator.of(context).pop();
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}

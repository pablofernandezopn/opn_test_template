import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../authentification/auth/cubit/auth_cubit.dart';
import '../authentification/auth/cubit/auth_state.dart';
import '../features/loading/cubit/loading_cubit.dart';
import '../features/loading/cubit/video_loading_cubit.dart';
import '../features/specialty/cubit/specialty_cubit.dart';
import '../features/specialty/view/components/specialty_selection_dialog.dart';
import 'go_route/app_routes.dart';

/// 🎯 Listeners Globales de la Aplicación
class AppBlocListeners {
  static bool _isPhoneDialogOpen = false;
  static bool _isSpecialtyDialogOpen = false;
  static bool _hasNavigatedToHome = false;
  static bool _safetyTimeoutStarted = false;

  /// 🔒 TIMEOUT DE SEGURIDAD GLOBAL: Si después de 15 segundos no hemos navegado, forzar navegación
  static void _startSafetyTimeout(BuildContext context) {
    if (_safetyTimeoutStarted) return;
    _safetyTimeoutStarted = true;

    Future.delayed(const Duration(seconds: 15), () {
      if (!_hasNavigatedToHome && context.mounted) {
        debugPrint('⚠️ Safety timeout (15s) - Forzando navegación a home');
        final authState = context.read<AuthCubit>().state;
        if (authState.status == AuthStatus.authenticated) {
          // Forzar que ambos cubits estén listos
          context.read<LoadingCubit>().markReady();
          context.read<VideoLoadingCubit>().markVideoFinished();
          _hasNavigatedToHome = true;
          context.go(AppRoutes.home);
        }
      }
    });
  }

  /// Obtiene la lista de listeners globales
  static List<BlocListener> listeners(GlobalKey<NavigatorState> navigatorKey) {
    return [
      // 🔐 AUTH LISTENER
      BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) {
          debugPrint('🔐 [LISTEN_WHEN] previous: ${previous.status}, current: ${current.status}');

          // No procesar cambios mientras el diálogo de teléfono está abierto
          if (_isPhoneDialogOpen) {
            debugPrint('🔐 [LISTEN_WHEN] Phone dialog is open, skipping');
            return false;
          }

          // Solo cambios de estado de auth
          final shouldListen = previous.status != current.status &&
              current.status != AuthStatus.unknown;

          debugPrint('🔐 [LISTEN_WHEN] shouldListen: $shouldListen');
          return shouldListen;
        },
        listener: (context, state) {
          debugPrint('🔐 [AUTH_LISTENER] Listener executed with state: ${state.status}');

          // Iniciar timeout de seguridad cuando el usuario se autentica
          if (state.status == AuthStatus.authenticated) {
            _startSafetyTimeout(context);
          }
          // Navegación como antes
          _handleAuthStateChange(context, state);
        },
      ),
      // 📊 DATA LOADING LISTENER
      BlocListener<LoadingCubit, bool>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, dataReady) {
          debugPrint('📊 AppBlocListeners: LoadingCubit cambió a $dataReady');

          // Si LoadingCubit se resetea (true -> false), resetear también la navegación
          if (!dataReady) {
            debugPrint('🔄 AppBlocListeners: LoadingCubit reseteado, permitiendo nueva navegación');
            _hasNavigatedToHome = false;
            _safetyTimeoutStarted = false;
            return;
          }

          if (!context.mounted) return;
          final authState = context.read<AuthCubit>().state;
          if (authState.status != AuthStatus.authenticated) {
            debugPrint('📊 AppBlocListeners: Usuario no autenticado, ignorando');
            return;
          }

          // Verificar si tanto los datos como el video están listos
          final videoReady = context.read<VideoLoadingCubit>().state;
          debugPrint('📊 AppBlocListeners: dataReady=$dataReady, videoReady=$videoReady');

          String currentLocation = AppRoutes.welcome;
          try {
            currentLocation = GoRouterState.of(context).uri.toString();
          } catch (_) {}

          // Solo navegar a home si AMBOS están listos y no hemos navegado ya
          if (dataReady && videoReady && !_hasNavigatedToHome) {
            if (currentLocation != AppRoutes.home) {
              debugPrint('✅ AppBlocListeners: Navegando a home desde $currentLocation');
              _hasNavigatedToHome = true;
              context.go(AppRoutes.home);
            }
          } else {
            debugPrint('⏳ AppBlocListeners: Esperando (dataReady=$dataReady, videoReady=$videoReady, hasNavigated=$_hasNavigatedToHome)');
          }
        },
      ),
      // 🎬 VIDEO LOADING LISTENER
      BlocListener<VideoLoadingCubit, bool>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, videoReady) {
          debugPrint('🎬 AppBlocListeners: VideoLoadingCubit cambió a $videoReady');
          if (!context.mounted) return;
          final authState = context.read<AuthCubit>().state;
          if (authState.status != AuthStatus.authenticated) {
            debugPrint('🎬 AppBlocListeners: Usuario no autenticado, ignorando');
            return;
          }

          // Verificar si tanto los datos como el video están listos
          final dataReady = context.read<LoadingCubit>().state;
          debugPrint('🎬 AppBlocListeners: dataReady=$dataReady, videoReady=$videoReady');

          String currentLocation = AppRoutes.welcome;
          try {
            currentLocation = GoRouterState.of(context).uri.toString();
          } catch (_) {}

          // Solo navegar a home si AMBOS están listos y no hemos navegado ya
          if (dataReady && videoReady && !_hasNavigatedToHome) {
            if (currentLocation != AppRoutes.home) {
              debugPrint('✅ AppBlocListeners: Navegando a home desde $currentLocation (trigger: video)');
              _hasNavigatedToHome = true;
              context.go(AppRoutes.home);
            }
          } else {
            debugPrint('⏳ AppBlocListeners: Esperando (dataReady=$dataReady, videoReady=$videoReady, hasNavigated=$_hasNavigatedToHome)');
          }
        },
      ),
    ];
  }

  /// Maneja los cambios en el estado de autenticación (simplificado)
  static void _handleAuthStateChange(BuildContext context, AuthState state) async {
    if (!context.mounted) return;

    debugPrint('🔐 [AUTH_LISTENER] Estado de autenticación: ${state.status}');

    // Obtener ubicación actual
    String currentLocation = AppRoutes.welcome; // Default
    try {
      currentLocation = GoRouterState.of(context).uri.toString();
      debugPrint('🔐 [AUTH_LISTENER] Ubicación actual: $currentLocation');
    } catch (e) {
      // Ignorar error, usar default
      debugPrint('🔐 [AUTH_LISTENER] Error obteniendo ubicación: $e');
    }

    switch (state.status) {
      case AuthStatus.authenticated:
      // Si autenticado y tiene token, ir a success si no está ahí
        debugPrint('🔐 [AUTH_LISTENER] Usuario autenticado');
        final hasToken = state.token.isNotEmpty || (state.user.token?.isNotEmpty ?? false);
        if (hasToken && (currentLocation == AppRoutes.welcome ||
            currentLocation == AppRoutes.signin ||
            currentLocation == AppRoutes.signup ||
            currentLocation == AppRoutes.initial)) {
          final loadingReady = context.read<LoadingCubit>().state;
          debugPrint('🔐 [AUTH_LISTENER] Navegando a ${loadingReady ? 'home' : 'loading'}');
          context.go(loadingReady ? AppRoutes.home : AppRoutes.loading);
        }
        // El diálogo de teléfono se mostrará después del video y navegación
        // Ver bootstrap.dart -> _waitForVideoAndShowNotifications
        // El TopicCubit se actualiza automáticamente al escuchar cambios en AuthCubit
        break;

      case AuthStatus.unauthenticated:
      // Si no autenticado, ir a welcome si no está ahí
        debugPrint('🔐 [AUTH_LISTENER] Usuario no autenticado');
        if (currentLocation != AppRoutes.welcome &&
            currentLocation != AppRoutes.signin &&
            currentLocation != AppRoutes.signup) {
          debugPrint('🔐 [AUTH_LISTENER] Navegando a welcome');
          context.go(AppRoutes.welcome);
        }
        break;

      case AuthStatus.connectionError:
      // Si hay error de conexión, mostrar pantalla de error
        debugPrint('❌ [AUTH_LISTENER] Error de conexión detectado');
        if (currentLocation != AppRoutes.connectionError) {
          debugPrint('❌ [AUTH_LISTENER] Navegando a pantalla de error de conexión');
          context.go(AppRoutes.connectionError);
        } else {
          debugPrint('❌ [AUTH_LISTENER] Ya estamos en la pantalla de error de conexión');
        }
        break;

      case AuthStatus.unknown:
      case AuthStatus.appAccessError:
      // No hacer nada o manejar error simple
        debugPrint('🔐 [AUTH_LISTENER] Estado desconocido o error de acceso');
        break;
    }
  }

  /// Verifica si el usuario tiene teléfono registrado
  /// Esta función se llama desde home_page.dart cuando el usuario llega a la home
  static Future<void> ensurePhoneCaptured(BuildContext context) async {
    if (!context.mounted) return;

    final authCubit = context.read<AuthCubit>();
    final phone = authCubit.state.user.phone ?? '';

    if (phone.trim().isNotEmpty || _isPhoneDialogOpen) return;

    _isPhoneDialogOpen = true;
    try {
      await _showPhoneDialog(context);
      // Esperar un poco más después de cerrar el diálogo para evitar conflictos
      await Future.delayed(const Duration(milliseconds: 200));
    } finally {
      // Asegurarse de resetear el flag incluso si hay error
      _isPhoneDialogOpen = false;
    }
  }

  static Future<void> _showPhoneDialog(BuildContext context) async {
    if (!context.mounted) return;
    final authCubit = context.read<AuthCubit>();
    final controller = TextEditingController(text: authCubit.state.user.phone ?? '');
    String? error;
    var isSubmitting = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogCtx, setState) {
            final colors = Theme.of(dialogCtx).colorScheme;
            final textTheme = Theme.of(dialogCtx).textTheme;

            Future<void> submit() async {
              if (isSubmitting) return;
              final value = controller.text.trim();
              final digits = value.replaceAll(RegExp(r'\D'), '');

              if (digits.length < 6) {
                if (!dialogContext.mounted) return;
                setState(() {
                  error = 'Introduce un teléfono válido.';
                });
                return;
              }

              setState(() {
                error = null;
                isSubmitting = true;
              });

              try {
                await authCubit.updatePhone(value);

                // Cerrar el diálogo y devolver true para indicar éxito
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              } catch (e) {
                if (!dialogContext.mounted) return;
                setState(() {
                  error = 'No se pudo guardar el teléfono. Intenta de nuevo.';
                  isSubmitting = false;
                });
              }
            }

            return PopScope(
              canPop: false,
              child: AlertDialog(
                title: const Text('Añade tu teléfono'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Necesitamos tu número para completar tu perfil y poder contactarte si es necesario.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Ej. 600123456',
                          errorText: error,
                        ),
                        onSubmitted: (_) => submit(),
                      ),
                    ],
                  ),
                ),
                actions: [
                  FilledButton(
                    onPressed: isSubmitting ? null : submit,
                    child: isSubmitting
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colors.onPrimary,
                              ),
                            ),
                          )
                        : const Text('Guardar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // Esperar a que el diálogo termine de animarse antes de hacer dispose
    await Future.delayed(const Duration(milliseconds: 300));
    controller.dispose();

    // Mostrar mensaje de éxito fuera del scope del diálogo
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teléfono guardado correctamente.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Verifica si el usuario tiene especialidad seleccionada
  /// Esta función se llama desde home_page.dart después de la captura del teléfono
  static Future<void> ensureSpecialtySelected(BuildContext context) async {
    if (!context.mounted) return;

    final authCubit = context.read<AuthCubit>();
    final specialtyId = authCubit.state.user.specialtyId;

    if (specialtyId != null || _isSpecialtyDialogOpen) return;

    _isSpecialtyDialogOpen = true;
    try {
      // Inicializar el SpecialtyCubit con las especialidades de la academia del usuario
      final specialtyCubit = context.read<SpecialtyCubit>();
      final academyId = authCubit.state.user.academyId;

      await specialtyCubit.loadSpecialties(academyId);

      if (!context.mounted) return;

      // Mostrar el diálogo de selección de especialidad
      final result = await SpecialtySelectionDialog.show(context);

      // Esperar un poco después de cerrar el diálogo
      await Future.delayed(const Duration(milliseconds: 200));

      if (result == true && context.mounted) {
        debugPrint('✅ Especialidad seleccionada correctamente');
      }
    } catch (e) {
      debugPrint('❌ Error al mostrar diálogo de especialidad: $e');
    } finally {
      _isSpecialtyDialogOpen = false;
    }
  }
}

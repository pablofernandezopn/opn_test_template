import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/video_loading_cubit.dart';
import '../../../config/service_locator.dart';
import '../../../config/go_route/app_routes.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../authentification/auth/cubit/auth_state.dart';
import '../../../../config/environment.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({super.key});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('🎬 LoadingView: initState - Iniciando vista de carga simple');

    // Configurar animación de latido (pulsación)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Marcar inmediatamente que la vista está lista
    // (ya no esperamos video)
    _markAsReady();
  }

  void _markAsReady() {
    debugPrint('🎬 LoadingView: Marcando como lista');
    try {
      getIt<VideoLoadingCubit>().markVideoFinished();
      debugPrint('🎬 LoadingView: VideoLoadingCubit notificado correctamente');

      // Verificar si el usuario no está autenticado y navegar a welcome
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final authState = context.read<AuthCubit>().state;
          debugPrint('🎬 LoadingView: Verificando auth status después de marcar listo: ${authState.status}');

          if (authState.status == AuthStatus.unauthenticated) {
            debugPrint('🎬 LoadingView: Usuario no autenticado, navegando a welcome');
            context.go(AppRoutes.welcome);
          }
        }
      });
    } catch (e) {
      debugPrint('⚠️ LoadingView: Error al notificar VideoLoadingCubit: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el color primary del tema
    final primaryColor = Theme.of(context).colorScheme.primary;

    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        debugPrint('🎬 [LOADING_VIEW] listenWhen - previous: ${previous.status}, current: ${current.status}');
        return previous.status != current.status;
      },
      listener: (context, state) {
        debugPrint('🎬 [LOADING_VIEW] listener - state: ${state.status}');

        if (state.status == AuthStatus.connectionError) {
          debugPrint('❌ [LOADING_VIEW] Connection error detected in listener - Navigating to error screen');
          // Usar addPostFrameCallback para navegar después de que el frame actual termine
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(AppRoutes.connectionError);
            }
          });
        }
      },
      buildWhen: (previous, current) {
        // Rebuild cuando cambie el estado de autenticación
        return previous.status != current.status;
      },
      builder: (context, state) {
        debugPrint('🎬 [LOADING_VIEW] builder - state: ${state.status}');

        // Si hay error de conexión al construir, navegar inmediatamente
        if (state.status == AuthStatus.connectionError) {
          debugPrint('❌ [LOADING_VIEW] Connection error detected in builder - Navigating to error screen');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(AppRoutes.connectionError);
            }
          });
        }

        return Scaffold(
          backgroundColor: primaryColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo con animación de latido
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Image.asset(
                    'assets/images/opn_logos/opn-logo-shadow.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 48),
                // Nombre de la app desde config
                Text(
                  Environment.instance.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Indicador de carga
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


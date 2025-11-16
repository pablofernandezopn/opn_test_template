import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../config/web_bounders.dart';
import 'config/go_route/app_router.dart';
import 'config/service_locator.dart';
import 'config/theme/theme.dart';
import 'shared/services/deep_link_service.dart';

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    super.key,
    required this.navigatorKey,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  late final DeepLinkService _deepLinkService;

  @override
  void initState() {
    super.initState();
    // 🔑 CLAVE: Crear el router UNA SOLA VEZ en initState
    // para que no se reconstruya con cada cambio de estado
    _router = AppRouter.createRouter(widget.navigatorKey);

    // 🔗 Inicializar escucha de deep links
    _setupDeepLinking();
  }

  /// Configura la escucha de deep links
  void _setupDeepLinking() {
    _deepLinkService = getIt<DeepLinkService>();

    // Manejar deep link inicial (app abierta desde cerrada)
    _handleInitialDeepLink();

    // Escuchar deep links mientras la app está abierta
    _deepLinkService.listenToLinks((uri) {
      debugPrint('🔗 Deep Link recibido: $uri');
      final route = _deepLinkService.buildRouteWithParams(uri);
      debugPrint('📍 Navegando a: $route');

      // Usar el navigatorKey para navegar
      if (widget.navigatorKey.currentContext != null) {
        widget.navigatorKey.currentContext!.go(route);
      } else {
        // Si el context no está disponible, usar el router directamente
        _router.go(route);
      }
    });
  }

  /// Maneja el deep link inicial cuando la app se abre desde cerrada
  Future<void> _handleInitialDeepLink() async {
    try {
      final initialUri = await _deepLinkService.getInitialLink();
      if (initialUri != null && _deepLinkService.isValidDeepLink(initialUri)) {
        debugPrint('🔗 Deep Link inicial detectado: $initialUri');

        // Esperar a que el router esté listo
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final route = _deepLinkService.buildRouteWithParams(initialUri);
          debugPrint('📍 Navegando a ruta inicial: $route');

          if (widget.navigatorKey.currentContext != null) {
            widget.navigatorKey.currentContext!.go(route);
          } else {
            _router.go(route);
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error al manejar deep link inicial: $e');
    }
  }

  @override
  void dispose() {
    // Limpiar listeners de deep links
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 2400),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MaterialApp.router(
          title: 'OPN Test Guardia Civil',
          // 🎨 Configuración de temas
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,

          // 🧭 Usar el router creado en initState (estable)
          routerConfig: _router,

          // Ocultar banner de debug
          debugShowCheckedModeBanner: false,

          builder: (context, child) {
            return Container(
              color: Colors.black, // Fondo negro global desde el inicio
              child: AppWeb(
                dev: true, // Cambiar a false en producción para ocultar el indicador de breakpoint
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}

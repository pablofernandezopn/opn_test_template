import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../config/web_bounders.dart';
import 'config/go_route/app_router.dart';
import 'config/layout/cubit/cubit.dart';
import 'config/layout/cubit/state.dart';
import 'config/theme/theme.dart';

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

  @override
  void initState() {
    super.initState();
    // 🔑 CLAVE: Crear el router UNA SOLA VEZ en initState
    // para que no se reconstruya con cada cambio de estado
    _router = AppRouter.createRouter(widget.navigatorKey, context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppLayoutCubit, AppLayoutState, bool >(
      selector: (state) => state.isDarkMode,
      builder:(context, isDarkMode) => ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          scrollbars: false,
        ),
        child: MaterialApp.router(
            title: 'OPN Test Guardia Civil',

            // 🎨 Configuración de temas
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: isDarkMode?ThemeMode.dark:ThemeMode.light,

            // 🧭 Usar el router creado en initState (estable)
            routerConfig: _router,

            // Ocultar banner de debug
            debugShowCheckedModeBanner: false,

        ),
      ),
    );
  }
}

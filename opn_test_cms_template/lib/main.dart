import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/app.dart';
import 'app/config/app_bloc_providers.dart';
import 'bootstrap.dart';
import 'config/environment.dart';

void main() {
  // Configurar URL strategy para quitar el # en web
  // Esto hace que las URLs sean: /home en lugar de /#/home
  usePathUrlStrategy();

  // GlobalKey para navegación (necesario para el bootstrap)
  final navigatorKey = GlobalKey<NavigatorState>();

  // Ejecutar bootstrap con todas las inicializaciones
  bootstrap(
    navigatorKey,
    BuildVariant.development, // Cambiar según el entorno
    () => AppBlocProviders(
      navigatorKey: navigatorKey,
      child: MyApp(navigatorKey: navigatorKey),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:opn_test_template/bootstrap.dart';
import 'package:opn_test_template/config/environment.dart';

import 'app/app.dart';
import 'app/config/app_bloc_providers.dart';

void main() {
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

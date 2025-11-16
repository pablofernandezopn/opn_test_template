/// 🚀 Entry point para el flavor POLICÍA NACIONAL
///
/// Este archivo inicializa la app con la configuración específica
/// del flavor Policía Nacional.
///
/// **Para ejecutar:**
/// ```bash
/// # Development
/// flutter run -t lib/main_policia_nacional.dart --flavor policiaNacional
///
/// # Release APK
/// flutter build apk -t lib/main_policia_nacional.dart --flavor policiaNacional --release
///
/// # Release App Bundle
/// flutter build appbundle -t lib/main_policia_nacional.dart --flavor policiaNacional --release
/// ```
import 'package:flutter/material.dart';
import 'package:opn_test_template/bootstrap.dart';
import 'package:opn_test_template/config/environment.dart';
import 'package:opn_test_template/config/flavor_config.dart';

import 'app/app.dart';
import 'app/config/app_bloc_providers.dart';

void main() async {
  // 🎨 Inicializar Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // 🎨 Inicializar configuración del flavor
  await FlavorConfig.initialize('policia_nacional');

  // 📊 Imprimir configuración (solo en debug)
  FlavorConfig.instance.printConfig();

  // 🔑 GlobalKey para navegación (necesario para el bootstrap)
  final navigatorKey = GlobalKey<NavigatorState>();

  // 🚀 Ejecutar bootstrap con todas las inicializaciones
  bootstrap(
    navigatorKey,
    BuildVariant.production, // Policía Nacional siempre en producción
    () => AppBlocProviders(
      navigatorKey: navigatorKey,
      child: MyApp(navigatorKey: navigatorKey),
    ),
  );
}
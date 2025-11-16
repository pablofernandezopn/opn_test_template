
/// 🚀 Entry point para el flavor GUARDIA CIVIL
///
/// Este archivo inicializa la app con la configuración específica
/// del flavor Guardia Civil.
///
/// **Para ejecutar:**
/// ```bash
/// # Development
/// flutter run -t lib/main_guardia_civil.dart --flavor guardiaCivil
///
/// # Release APK
/// flutter build apk -t lib/main_guardia_civil.dart --flavor guardiaCivil --release
///
/// # Release App Bundle
/// flutter build appbundle -t lib/main_guardia_civil.dart --flavor guardiaCivil --release
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
  await FlavorConfig.initialize('guardia_civil');

  // 📊 Imprimir configuración (solo en debug)
  FlavorConfig.instance.printConfig();

  // 🔑 GlobalKey para navegación (necesario para el bootstrap)
  final navigatorKey = GlobalKey<NavigatorState>();

  // 🚀 Ejecutar bootstrap con todas las inicializaciones
  bootstrap(
    navigatorKey,
    BuildVariant.production, // Guardia Civil siempre en producción
    () => AppBlocProviders(
      navigatorKey: navigatorKey,
      child: MyApp(navigatorKey: navigatorKey),
    ),
  );
}

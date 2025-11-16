import 'package:flutter/material.dart';

/// Splash screen mostrado durante la inicialización de la app
///
/// Esta página se muestra mientras:
/// - Se verifica la sesión de autenticación (AuthCubit.check())
/// - Se restauran los tokens desde SharedPreferences
/// - Se cargan los datos iniciales necesarios
///
/// Una vez que AuthStatus cambia de 'unknown' a 'authenticated' o 'unauthenticated',
/// el router redirigirá automáticamente a la página correspondiente.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const String route = '/splash';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o icono de la app
            Icon(
              Icons.shield,
              size: 80,
              color: colorScheme.primary,
            ),

            const SizedBox(height: 32),

            // Nombre de la app
            Text(
              'OPN Test Guardia Civil',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 48),

            // Indicador de carga
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            // Texto de estado
            Text(
              'Iniciando...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

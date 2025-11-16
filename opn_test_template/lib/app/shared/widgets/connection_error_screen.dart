import 'package:flutter/material.dart';

/// Pantalla de error de conexión que se muestra cuando no se puede conectar con el servidor
class ConnectionErrorScreen extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const ConnectionErrorScreen({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono de error
                Icon(
                  Icons.cloud_off_rounded,
                  size: 120,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 32),

                // Título
                Text(
                  'Sin conexión',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Mensaje
                Text(
                  customMessage ??
                      'No se pudo establecer conexión con el servidor.\n'
                          'Por favor, verifica tu conexión a internet e inténtalo de nuevo.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Botón de reintentar
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Información adicional
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 Consejos:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildTip(
                        context,
                        '• Verifica que estés conectado a internet',
                      ),
                      _buildTip(
                        context,
                        '• Si estás usando Supabase local, asegúrate de que esté iniciado',
                      ),
                      _buildTip(
                        context,
                        '• Intenta cambiar entre WiFi y datos móviles',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTip(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
      ),
    );
  }
}


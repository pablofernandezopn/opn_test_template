import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../bootstrap.dart';

/// Servicio para verificar la conectividad con Supabase
class ConnectivityService {
  /// Verifica si Supabase está disponible
  /// Retorna true si la conexión es exitosa, false en caso contrario
  static Future<bool> checkSupabaseConnection() async {
    try {
      logger.info('🔍 Verificando conectividad con Supabase...');

      final supabaseClient = Supabase.instance.client;

      // Intentar una consulta simple con timeout corto
      await supabaseClient
          .from('users')
          .select('id')
          .limit(1)
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              logger.warning('⏱️ Timeout verificando conectividad');
              throw Exception('Timeout');
            },
          );

      logger.info('✅ Supabase está disponible');
      return true;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();

      // Si es error de tabla/permisos, el servidor está disponible
      if (errorStr.contains('relation') ||
          errorStr.contains('does not exist') ||
          errorStr.contains('could not find') ||
          errorStr.contains('permission') ||
          errorStr.contains('policy')) {
        logger.info('✅ Servidor Supabase alcanzable (tabla/permisos diferentes)');
        return true;
      }

      // Si es error de conexión, el servidor no está disponible
      if (errorStr.contains('connection refused') ||
          errorStr.contains('timeout') ||
          errorStr.contains('network') ||
          errorStr.contains('socketexception')) {
        logger.error('❌ Supabase no disponible: $e');
        return false;
      }

      logger.warning('⚠️ Error inesperado verificando conectividad: $e');
      return false;
    }
  }

  /// Verifica si hay conectividad y lanza una excepción amigable si no hay
  static Future<void> ensureConnection() async {
    final isConnected = await checkSupabaseConnection();

    if (!isConnected) {
      throw Exception(
        'No se puede conectar con el servidor. '
        'Por favor, verifica tu conexión a internet e inténtalo de nuevo.',
      );
    }
  }
}


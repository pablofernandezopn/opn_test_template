import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/saved_test_config.dart';

/// Repositorio para gestionar configuraciones de test guardadas
class SavedTestConfigRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  static const String _tableName = 'saved_test_configs';

  /// Obtiene todas las configuraciones guardadas de un usuario
  Future<List<SavedTestConfig>> getUserConfigs(int userId) async {
    try {
      print('📥 [SAVED_CONFIG_REPO] Obteniendo configs del usuario: $userId');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final configs = (response as List)
          .map((json) => SavedTestConfig.fromJson(json))
          .toList();

      print('✅ [SAVED_CONFIG_REPO] ${configs.length} configuraciones obtenidas');
      return configs;
    } catch (e) {
      print('❌ [SAVED_CONFIG_REPO] Error obteniendo configs: $e');
      rethrow;
    }
  }

  /// Guarda una nueva configuración
  Future<SavedTestConfig> saveConfig(SavedTestConfig config) async {
    try {
      print('💾 [SAVED_CONFIG_REPO] Guardando config: ${config.configName}');

      // Preparar datos para insertar (sin id, created_at, updated_at)
      final data = {
        'user_id': config.userId,
        'config_name': config.configName,
        'num_questions': config.numQuestions,
        'answer_display_mode': config.answerDisplayMode,
        'difficulties': config.difficulties,
        'selected_topic_ids': config.selectedTopicIds,
        'test_modes': config.testModes,
      };

      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      final savedConfig = SavedTestConfig.fromJson(response);
      print('✅ [SAVED_CONFIG_REPO] Config guardada con ID: ${savedConfig.id}');
      return savedConfig;
    } catch (e) {
      print('❌ [SAVED_CONFIG_REPO] Error guardando config: $e');

      // Detectar error de nombre duplicado
      if (e.toString().contains('saved_test_configs_user_config_unique')) {
        throw Exception('Ya existe una configuración con ese nombre');
      }

      rethrow;
    }
  }

  /// Actualiza una configuración existente
  Future<SavedTestConfig> updateConfig(SavedTestConfig config) async {
    try {
      if (config.id == null) {
        throw Exception('No se puede actualizar una config sin ID');
      }

      print('🔄 [SAVED_CONFIG_REPO] Actualizando config: ${config.configName}');

      final data = {
        'config_name': config.configName,
        'num_questions': config.numQuestions,
        'answer_display_mode': config.answerDisplayMode,
        'difficulties': config.difficulties,
        'selected_topic_ids': config.selectedTopicIds,
        'test_modes': config.testModes,
      };

      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', config.id!)
          .select()
          .single();

      final updatedConfig = SavedTestConfig.fromJson(response);
      print('✅ [SAVED_CONFIG_REPO] Config actualizada');
      return updatedConfig;
    } catch (e) {
      print('❌ [SAVED_CONFIG_REPO] Error actualizando config: $e');

      // Detectar error de nombre duplicado
      if (e.toString().contains('saved_test_configs_user_config_unique')) {
        throw Exception('Ya existe una configuración con ese nombre');
      }

      rethrow;
    }
  }

  /// Elimina una configuración
  Future<void> deleteConfig(int configId) async {
    try {
      print('🗑️ [SAVED_CONFIG_REPO] Eliminando config: $configId');

      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', configId);

      print('✅ [SAVED_CONFIG_REPO] Config eliminada');
    } catch (e) {
      print('❌ [SAVED_CONFIG_REPO] Error eliminando config: $e');
      rethrow;
    }
  }

  /// Obtiene una configuración específica por ID
  Future<SavedTestConfig?> getConfigById(int configId) async {
    try {
      print('🔍 [SAVED_CONFIG_REPO] Buscando config: $configId');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', configId)
          .maybeSingle();

      if (response == null) {
        print('⚠️ [SAVED_CONFIG_REPO] Config no encontrada');
        return null;
      }

      final config = SavedTestConfig.fromJson(response);
      print('✅ [SAVED_CONFIG_REPO] Config encontrada: ${config.configName}');
      return config;
    } catch (e) {
      print('❌ [SAVED_CONFIG_REPO] Error buscando config: $e');
      rethrow;
    }
  }

  /// Verifica si existe una configuración con ese nombre para el usuario
  Future<bool> configNameExists(int userId, String configName) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .eq('config_name', configName)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ [SAVED_CONFIG_REPO] Error verificando nombre: $e');
      return false;
    }
  }
}
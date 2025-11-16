import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/ai_model.dart';
import '../model/chat_user_preferences.dart';

/// Repositorio para manejar las preferencias de chat del usuario
class ChatPreferencesRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Obtiene todos los modelos de IA disponibles
  Future<List<AiModel>> getAvailableModels() async {
    try {
      final response = await _supabase
          .from('ai_models')
          .select()
          .eq('is_active', true)
          .order('speed_rating', ascending: false);

      return (response as List)
          .map((json) => AiModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener modelos de IA: $e');
    }
  }

  /// Obtiene las preferencias del usuario
  /// Si no existen, devuelve preferencias por defecto
  Future<ChatUserPreferences> getUserPreferences(int userId) async {
    try {
      final response = await _supabase
          .from('chat_user_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // No existen preferencias, devolver las por defecto
        return ChatUserPreferences.defaultPreferences(userId);
      }

      return ChatUserPreferences.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al obtener preferencias: $e');
    }
  }

  /// Crea o actualiza las preferencias del usuario
  Future<ChatUserPreferences> upsertUserPreferences(
    ChatUserPreferences preferences,
  ) async {
    try {
      final data = preferences.toJson();

      // Remover id si es null para el insert
      if (data['id'] == null) {
        data.remove('id');
      }

      final response = await _supabase
          .from('chat_user_preferences')
          .upsert(
            data,
            onConflict: 'user_id',
          )
          .select()
          .single();

      return ChatUserPreferences.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al guardar preferencias: $e');
    }
  }

  /// Elimina las preferencias del usuario (restaurar a defaults)
  Future<void> deleteUserPreferences(int userId) async {
    try {
      await _supabase
          .from('chat_user_preferences')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Error al eliminar preferencias: $e');
    }
  }

  /// Obtiene un modelo específico por su ID
  Future<AiModel?> getModelById(int modelId) async {
    try {
      final response = await _supabase
          .from('ai_models')
          .select()
          .eq('id', modelId)
          .maybeSingle();

      if (response == null) return null;

      return AiModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al obtener modelo: $e');
    }
  }

  /// Obtiene las preferencias completas del usuario incluyendo el modelo
  Future<Map<String, dynamic>> getUserPreferencesWithModel(int userId) async {
    try {
      final preferences = await getUserPreferences(userId);
      AiModel? model;

      if (preferences.aiModelId != null) {
        model = await getModelById(preferences.aiModelId!);
      }

      return {
        'preferences': preferences,
        'model': model,
      };
    } catch (e) {
      throw Exception('Error al obtener preferencias completas: $e');
    }
  }
}

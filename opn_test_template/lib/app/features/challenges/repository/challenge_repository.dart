import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/challenge_model.dart';
import '../../../../bootstrap.dart';

class ChallengeRepository {
  SupabaseClient get _supabaseClient => Supabase.instance.client;

  /// Obtiene las impugnaciones del usuario actual con paginación
  /// [offset] indica desde qué posición empezar
  /// [limit] indica cuántos registros obtener (por defecto 20)
  /// [userId] el ID del usuario
  Future<List<Challenge>> fetchUserChallenges({
    required int userId,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _supabaseClient
          .from('challenge')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => Challenge.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.error('Error fetching user challenges: $e');
      throw Exception('Error fetching user challenges: $e');
    }
  }

  /// Obtiene todas las impugnaciones con paginación (para admin/tutor)
  Future<List<Challenge>> fetchAllChallenges({
    int offset = 0,
    int limit = 20,
    int? academyId,
  }) async {
    try {
      dynamic query = _supabaseClient
          .from('challenge')
          .select()
          .order('created_at', ascending: false);

      if (academyId != null) {
        query = query.eq('academy_id', academyId);
      }

      final response = await query.range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => Challenge.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.error('Error fetching all challenges: $e');
      throw Exception('Error fetching all challenges: $e');
    }
  }

  /// Crea una nueva impugnación
  Future<Challenge> createChallenge(Challenge challenge) async {
    try {
      final response = await _supabaseClient
          .from('challenge')
          .insert(challenge.toJson())
          .select()
          .single();

      return Challenge.fromJson(response);
    } catch (e) {
      logger.error('Error creating challenge: $e');
      throw Exception('Error creating challenge: $e');
    }
  }

  /// Actualiza una impugnación existente
  Future<Challenge> updateChallenge(int id, Challenge challenge) async {
    try {
      final response = await _supabaseClient
          .from('challenge')
          .update(challenge.toJson())
          .eq('id', id)
          .select()
          .single();

      return Challenge.fromJson(response);
    } catch (e) {
      logger.error('Error updating challenge: $e');
      throw Exception('Error updating challenge: $e');
    }
  }

  /// Obtiene una impugnación específica por su ID
  Future<Challenge?> fetchChallengeById(int id) async {
    try {
      final response = await _supabaseClient
          .from('challenge')
          .select()
          .eq('id', id)
          .limit(1);

      if ((response as List).isEmpty) return null;
      return Challenge.fromJson(response.first);
    } catch (e) {
      logger.error('Error fetching challenge by id: $e');
      return null;
    }
  }

  /// Elimina una impugnación (soft delete: marca como cerrada)
  Future<void> closeChallenge(int id) async {
    try {
      await _supabaseClient
          .from('challenge')
          .update({'open': false})
          .eq('id', id);
    } catch (e) {
      logger.error('Error closing challenge: $e');
      throw Exception('Error closing challenge: $e');
    }
  }

  /// Cuenta el total de impugnaciones del usuario
  Future<int> countUserChallenges({required int userId}) async {
    try {
      final response = await _supabaseClient
          .from('challenge')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      logger.error('Error counting user challenges: $e');
      return 0;
    }
  }

  /// Obtiene los detalles completos de un challenge con pregunta, opciones y topic
  Future<Map<String, dynamic>?> fetchChallengeDetails(int challengeId) async {
    try {
      // Obtener el challenge
      final challengeResponse = await _supabaseClient
          .from('challenge')
          .select()
          .eq('id', challengeId)
          .single();

      final challenge = Challenge.fromJson(challengeResponse);

      // Obtener la pregunta con sus opciones
      final questionResponse = await _supabaseClient
          .from('questions')
          .select('*, question_options(*)')
          .eq('id', challenge.questionId ?? 0)
          .single();

      // Obtener el topic
      final topicResponse = await _supabaseClient
          .from('topic')
          .select()
          .eq('id', challenge.topicId ?? 0)
          .single();

      return {
        'challenge': challenge,
        'question': questionResponse,
        'topic': topicResponse,
      };
    } catch (e) {
      logger.error('Error fetching challenge details: $e');
      return null;
    }
  }
}
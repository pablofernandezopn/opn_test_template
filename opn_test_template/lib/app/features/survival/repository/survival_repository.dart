import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../bootstrap.dart';
import '../model/survival_session.dart';
import '../model/survival_question_response.dart';
import '../model/survival_answer_response.dart';

/// Repositorio para gestionar el modo supervivencia
class SurvivalRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Inicia una nueva sesión de supervivencia
  Future<SurvivalSession> startSession({
    required int userId,
    required int academyId,
    int? topicTypeId,
    int? specialtyId,
  }) async {
    try {
      logger.info('🎮 [SURVIVAL] Starting new session for user: $userId');

      final response = await _supabase.functions.invoke(
        'survival-mode',
        body: {
          'action': 'start_session',
          'userId': userId,
          'academyId': academyId,
          if (topicTypeId != null) 'topicTypeId': topicTypeId,
          if (specialtyId != null) 'specialtyId': specialtyId,
        },
      );

      logger.info('✅ [SURVIVAL] Response status: ${response.status}');

      if (response.status != 200) {
        throw Exception('Error en edge function: ${response.data}');
      }

      final data = response.data;
      if (data == null) {
        throw Exception('Edge function no retornó datos');
      }

      final session = SurvivalSession.fromJson(data as Map<String, dynamic>);
      logger.info('✅ [SURVIVAL] Session created: ${session.id}');

      return session;
    } catch (e) {
      logger.error('❌ [SURVIVAL] Error starting session: $e');
      rethrow;
    }
  }

  /// Obtiene la siguiente pregunta para la sesión
  Future<SurvivalQuestionResponse> getNextQuestion({
    required int sessionId,
  }) async {
    try {
      logger.info('🎯 [SURVIVAL] Getting next question for session: $sessionId');

      final response = await _supabase.functions.invoke(
        'survival-mode',
        body: {
          'action': 'get_next_question',
          'sessionId': sessionId,
        },
      );

      logger.info('✅ [SURVIVAL] Response status: ${response.status}');

      if (response.status != 200) {
        throw Exception('Error en edge function: ${response.data}');
      }

      final data = response.data;
      if (data == null) {
        throw Exception('Edge function no retornó datos');
      }

      final questionResponse = SurvivalQuestionResponse.fromJson(
        data as Map<String, dynamic>,
      );

      logger.info(
        '✅ [SURVIVAL] Question received: ${questionResponse.hasQuestion ? "Yes" : "No"}, '
        'GameOver: ${questionResponse.gameOver}',
      );

      return questionResponse;
    } catch (e) {
      logger.error('❌ [SURVIVAL] Error getting next question: $e');
      rethrow;
    }
  }

  /// Registra una respuesta y actualiza la sesión
  Future<SurvivalAnswerResponse> submitAnswer({
    required int sessionId,
    required int questionId,
    required int? selectedOptionId,
    required bool wasCorrect,
    int? timeTakenSeconds,
  }) async {
    try {
      logger.info('📝 [SURVIVAL] Submitting answer for session: $sessionId');
      logger.info('   Question: $questionId, Correct: $wasCorrect');

      final response = await _supabase.functions.invoke(
        'survival-mode',
        body: {
          'action': 'submit_answer',
          'sessionId': sessionId,
          'questionId': questionId,
          'selectedOptionId': selectedOptionId,
          'wasCorrect': wasCorrect,
          if (timeTakenSeconds != null) 'timeTakenSeconds': timeTakenSeconds,
        },
      );

      logger.info('✅ [SURVIVAL] Response status: ${response.status}');

      if (response.status != 200) {
        throw Exception('Error en edge function: ${response.data}');
      }

      final data = response.data;
      if (data == null) {
        throw Exception('Edge function no retornó datos');
      }

      final answerResponse = SurvivalAnswerResponse.fromJson(
        data as Map<String, dynamic>,
      );

      logger.info(
        '✅ [SURVIVAL] Answer recorded. Lives: ${answerResponse.session.livesRemaining}, '
        'GameOver: ${answerResponse.gameOver}',
      );

      return answerResponse;
    } catch (e) {
      logger.error('❌ [SURVIVAL] Error submitting answer: $e');
      rethrow;
    }
  }

  /// Obtiene una sesión por su ID
  Future<SurvivalSession?> getSession(int sessionId) async {
    try {
      logger.info('📖 [SURVIVAL] Getting session: $sessionId');

      final response = await _supabase
          .from('survival_sessions')
          .select()
          .eq('id', sessionId)
          .maybeSingle();

      if (response == null) {
        logger.warning('⚠️ [SURVIVAL] Session not found: $sessionId');
        return null;
      }

      return SurvivalSession.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      logger.error('❌ [SURVIVAL] Error getting session: $e');
      rethrow;
    }
  }

  /// Obtiene las sesiones activas del usuario
  Future<List<SurvivalSession>> getActiveSessions({
    required int userId,
  }) async {
    try {
      logger.info('📖 [SURVIVAL] Getting active sessions for user: $userId');

      final response = await _supabase
          .from('survival_sessions')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final sessions = (response as List)
          .map((json) => SurvivalSession.fromJson(json as Map<String, dynamic>))
          .toList();

      logger.info('✅ [SURVIVAL] Found ${sessions.length} active sessions');

      return sessions;
    } catch (e) {
      logger.error('❌ [SURVIVAL] Error getting active sessions: $e');
      rethrow;
    }
  }

  /// Obtiene el historial de sesiones completadas del usuario
  Future<List<SurvivalSession>> getSessionHistory({
    required int userId,
    int limit = 20,
  }) async {
    try {
      logger.info('📖 [SURVIVAL] Getting session history for user: $userId');

      final response = await _supabase
          .from('survival_sessions')
          .select()
          .eq('user_id', userId)
          .eq('is_active', false)
          .order('ended_at', ascending: false)
          .limit(limit);

      final sessions = (response as List)
          .map((json) => SurvivalSession.fromJson(json as Map<String, dynamic>))
          .toList();

      logger.info('✅ [SURVIVAL] Found ${sessions.length} completed sessions');

      return sessions;
    } catch (e) {
      logger.error('❌ [SURVIVAL] Error getting session history: $e');
      rethrow;
    }
  }

  /// Obtiene las respuestas incorrectas de una sesión para revisión
  Future<Map<String, dynamic>> getIncorrectAnswers({
    required int sessionId,
  }) async {
    try {
      logger.info('📖 [SURVIVAL] Getting incorrect answers for session: $sessionId');

      final response = await _supabase.functions.invoke(
        'survival-mode',
        body: {
          'action': 'get_incorrect_answers',
          'sessionId': sessionId,
        },
      );

      logger.info('✅ [SURVIVAL] Response status: ${response.status}');

      if (response.status != 200) {
        throw Exception('Error en edge function: ${response.data}');
      }

      final data = response.data;
      if (data == null) {
        throw Exception('Edge function no retornó datos');
      }

      logger.info('✅ [SURVIVAL] Found incorrect answers');

      return data as Map<String, dynamic>;
    } catch (e) {
      logger.error('❌ [SURVIVAL] Error getting incorrect answers: $e');
      rethrow;
    }
  }

  /// Obtiene todas las respuestas de una sesión para revisión
  /// Retorna un mapa con las preguntas agrupadas: questionId -> datos de pregunta
  Future<Map<int, SessionAnswerData>> getSessionAnswers({
    required int sessionId,
  }) async {
    try {
      logger.info('📖 [SURVIVAL] Getting session answers for: $sessionId');

      // Usar RPC para llamar a la función SQL (más rápido que edge function)
      final response = await _supabase.rpc(
        'get_survival_session_answers',
        params: {'p_session_id': sessionId},
      ) as List<dynamic>;

      logger.info('✅ [SURVIVAL] Found ${response.length} answer records');

      // Agrupar por question_id
      final Map<int, SessionAnswerData> answersMap = {};

      for (final row in response) {
        final questionId = row['question_id'] as int;
        final optionId = row['option_id'] as int;

        if (!answersMap.containsKey(questionId)) {
          // Primera vez que vemos esta pregunta, crear el objeto
          answersMap[questionId] = SessionAnswerData(
            questionId: questionId,
            questionText: row['question_text'] as String,
            questionTip: row['question_tip'] as String?,
            selectedOptionId: row['selected_option_id'] as int?,
            wasCorrect: row['was_correct'] as bool,
            timeTakenSeconds: row['time_taken_seconds'] as int?,
            answeredAt: DateTime.parse(row['answered_at'] as String),
            options: [],
          );
        }

        // Añadir la opción a la lista
        answersMap[questionId]!.options.add(
          SessionOptionData(
            id: optionId,
            answer: row['option_answer'] as String,
            optionOrder: row['option_order'] as int,
            isCorrect: row['option_is_correct'] as bool,
          ),
        );
      }

      logger.info('✅ [SURVIVAL] Processed ${answersMap.length} questions');

      return answersMap;
    } catch (e) {
      logger.error('❌ [SURVIVAL] Error getting session answers: $e');
      rethrow;
    }
  }

  /// Elimina una sesión (solo para testing o limpieza)
  Future<void> deleteSession(int sessionId) async {
    try {
      logger.info('🗑️ [SURVIVAL] Deleting session: $sessionId');

      await _supabase
          .from('survival_sessions')
          .delete()
          .eq('id', sessionId);

      logger.info('✅ [SURVIVAL] Session deleted');
    } catch (e) {
      logger.error('❌ [SURVIVAL] Error deleting session: $e');
      rethrow;
    }
  }
}

/// Datos de una respuesta de sesión con pregunta y opciones
class SessionAnswerData {
  final int questionId;
  final String questionText;
  final String? questionTip;
  final int? selectedOptionId;
  final bool wasCorrect;
  final int? timeTakenSeconds;
  final DateTime answeredAt;
  final List<SessionOptionData> options;

  SessionAnswerData({
    required this.questionId,
    required this.questionText,
    required this.questionTip,
    required this.selectedOptionId,
    required this.wasCorrect,
    required this.timeTakenSeconds,
    required this.answeredAt,
    required this.options,
  });
}

/// Datos de una opción de respuesta
class SessionOptionData {
  final int id;
  final String answer;
  final int optionOrder;
  final bool isCorrect;

  SessionOptionData({
    required this.id,
    required this.answer,
    required this.optionOrder,
    required this.isCorrect,
  });
}
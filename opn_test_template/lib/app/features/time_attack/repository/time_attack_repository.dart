import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/time_attack_session.dart';
import '../model/time_attack_question_response.dart';
import '../model/time_attack_answer_response.dart';
import '../../questions/model/question_model.dart';
import '../../questions/model/question_option_model.dart';

/// Repositorio para operaciones del modo contra reloj
class TimeAttackRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Inicia una nueva sesión de contra reloj
  Future<TimeAttackSession> startSession({
    required int userId,
    required int academyId,
    required int timeLimitSeconds,
    int? topicTypeId,
    int? specialtyId,
  }) async {
    final response = await _supabase.functions.invoke(
      'time-attack-mode',
      body: {
        'action': 'start_session',
        'userId': userId,
        'academyId': academyId,
        'timeLimitSeconds': timeLimitSeconds,
        if (topicTypeId != null) 'topicTypeId': topicTypeId,
        if (specialtyId != null) 'specialtyId': specialtyId,
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to start time attack session: ${response.data}');
    }

    return TimeAttackSession.fromJson(response.data as Map<String, dynamic>);
  }

  /// Obtiene la siguiente pregunta para la sesión
  Future<TimeAttackQuestionResponse> getNextQuestion({
    required int sessionId,
  }) async {
    final response = await _supabase.functions.invoke(
      'time-attack-mode',
      body: {
        'action': 'get_next_question',
        'sessionId': sessionId,
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to get next question: ${response.data}');
    }

    final data = response.data as Map<String, dynamic>;

    // Parsear la respuesta manualmente para manejar los datos correctamente
    return TimeAttackQuestionResponse(
      success: data['success'] as bool,
      question: data['question'] != null
          ? Question.fromJson(data['question'] as Map<String, dynamic>)
          : null,
      options: data['options'] != null
          ? (data['options'] as List)
              .map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      session: data['session'] != null
          ? TimeAttackSession.fromJson(data['session'] as Map<String, dynamic>)
          : null,
      timeUp: data['time_up'] as bool?,
      message: data['message'] as String?,
    );
  }

  /// Envía una respuesta y actualiza la sesión
  Future<TimeAttackAnswerResponse> submitAnswer({
    required int sessionId,
    required int questionId,
    required int? selectedOptionId,
    required bool wasCorrect,
    required int timeTakenSeconds,
  }) async {
    final response = await _supabase.functions.invoke(
      'time-attack-mode',
      body: {
        'action': 'submit_answer',
        'sessionId': sessionId,
        'questionId': questionId,
        'selectedOptionId': selectedOptionId,
        'wasCorrect': wasCorrect,
        'timeTakenSeconds': timeTakenSeconds,
      },
    );

    if (response.status != 200) {
      throw Exception('Failed to submit answer: ${response.data}');
    }

    final data = response.data as Map<String, dynamic>;

    return TimeAttackAnswerResponse(
      success: data['success'] as bool,
      session: TimeAttackSession.fromJson(data['session'] as Map<String, dynamic>),
      timeUp: data['time_up'] as bool,
      finalScore: data['final_score'] as int?,
      pointsEarned: data['points_earned'] as int?,
    );
  }

  /// Obtiene una sesión por ID
  Future<TimeAttackSession?> getSession(int sessionId) async {
    final response = await _supabase
        .from('time_attack_sessions')
        .select()
        .eq('id', sessionId)
        .maybeSingle();

    if (response == null) return null;

    return TimeAttackSession.fromJson(response);
  }

  /// Obtiene todas las sesiones activas del usuario
  Future<List<TimeAttackSession>> getActiveSessions(int userId) async {
    final response = await _supabase
        .from('time_attack_sessions')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => TimeAttackSession.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene el historial de sesiones completadas del usuario
  Future<List<TimeAttackSession>> getSessionHistory({
    required int userId,
    int limit = 20,
  }) async {
    final response = await _supabase
        .from('time_attack_sessions')
        .select()
        .eq('user_id', userId)
        .eq('is_active', false)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => TimeAttackSession.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene las respuestas de una sesión para revisión
  Future<Map<int, SessionAnswerData>> getSessionAnswers({
    required int sessionId,
  }) async {
    final response = await _supabase.rpc(
      'get_time_attack_session_answers',
      params: {'p_session_id': sessionId},
    );

    final answersMap = <int, SessionAnswerData>{};

    for (final row in response as List) {
      final questionId = row['question_id'] as int;

      if (!answersMap.containsKey(questionId)) {
        answersMap[questionId] = SessionAnswerData(
          questionId: questionId,
          questionText: row['question_text'] as String,
          questionTip: row['question_tip'] as String?,
          selectedOptionId: row['selected_option_id'] as int?,
          wasCorrect: row['was_correct'] as bool?,
          timeTakenSeconds: row['time_taken_seconds'] as int?,
          options: [],
        );
      }

      answersMap[questionId]!.options.add(
            SessionOptionData(
              id: row['option_id'] as int,
              answer: row['option_answer'] as String,
              optionOrder: row['option_order'] as int,
              isCorrect: row['option_is_correct'] as bool,
            ),
          );
    }

    return answersMap;
  }
}

/// Datos de una respuesta de sesión para revisión
class SessionAnswerData {
  final int questionId;
  final String questionText;
  final String? questionTip;
  final int? selectedOptionId;
  final bool? wasCorrect;
  final int? timeTakenSeconds;
  final List<SessionOptionData> options;

  SessionAnswerData({
    required this.questionId,
    required this.questionText,
    this.questionTip,
    this.selectedOptionId,
    this.wasCorrect,
    this.timeTakenSeconds,
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
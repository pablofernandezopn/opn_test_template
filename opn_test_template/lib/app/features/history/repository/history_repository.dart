import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/user_test_model.dart';
import '../../questions/model/user_test_answer_model.dart';
import '../../questions/model/question_option_model.dart';

class HistoryRepository {
  SupabaseClient get _supabaseClient => Supabase.instance.client;

  /// Obtiene los tests de un usuario con paginación
  ///
  /// [userId] - ID del usuario
  /// [limit] - Número de tests a obtener (default 20)
  /// [offset] - Offset para paginación (default 0)
  /// [topicTypeFilter] - Filtro opcional por topic_type_id
  Future<List<UserTest>> fetchUserTests({
    required int userId,
    int limit = 20,
    int offset = 0,
    int? topicTypeFilter,
  }) async {
    var query = _supabaseClient
        .from('user_tests')
        .select()
        .eq('user_id', userId)
        // Removido el filtro .eq('finalized', true) para incluir tests pausados
        .eq('visible', true)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    // Si hay filtro por topic_type, necesitamos hacer una consulta especial
    // usando una subquery o función de Postgres
    if (topicTypeFilter != null) {
      // Usamos una función RPC personalizada en Supabase para filtrar por topic_type
      // Esta función debería existir en la base de datos
      // Por ahora, haremos el filtrado en cliente si no existe la función
      final response = await query;
      final tests = response.map((json) => UserTest.fromJson(json)).toList();

      // Obtener todos los topics para filtrar
      final allTopics = await _supabaseClient
          .from('topic')
          .select('id, topic_type_id')
          .eq('topic_type_id', topicTypeFilter);

      final topicIdsSet = allTopics.map((t) => t['id'] as int).toSet();

      // Filtrar tests que contengan al menos un topic del tipo especificado
      return tests.where((test) {
        return test.topicIds.any((topicId) => topicIdsSet.contains(topicId));
      }).toList();
    }

    final response = await query;
    return response.map((json) => UserTest.fromJson(json)).toList();
  }

  /// Obtiene un test específico por ID
  Future<UserTest?> fetchUserTestById(int testId) async {
    final response = await _supabaseClient
        .from('user_tests')
        .select()
        .eq('id', testId)
        .limit(1);

    if (response.isEmpty) return null;
    return UserTest.fromJson(response.first);
  }

  /// Obtiene el conteo total de tests de un usuario
  Future<int> getUserTestCount(int userId) async {
    final response = await _supabaseClient
        .from('user_tests')
        .select()
        .eq('user_id', userId)
        .eq('finalized', true)
        .eq('visible', true)
        .count(CountOption.exact);

    return response.count;
  }

  /// Obtiene estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats(int userId) async {
    final tests = await _supabaseClient
        .from('user_tests')
        .select()
        .eq('user_id', userId)
        .eq('finalized', true)
        .eq('visible', true);

    if (tests.isEmpty) {
      return {
        'total_tests': 0,
        'total_questions': 0,
        'total_correct': 0,
        'average_score': 0.0,
      };
    }

    final testList = tests.map((json) => UserTest.fromJson(json)).toList();

    final totalTests = testList.length;
    final totalQuestions = testList.fold<int>(0, (sum, test) => sum + test.totalAnswered);
    final totalCorrect = testList.fold<int>(0, (sum, test) => sum + test.rightQuestions);
    final averageScore = testList
            .where((test) => test.score != null)
            .fold<double>(0, (sum, test) => sum + (test.score ?? 0)) /
        testList.where((test) => test.score != null).length;

    return {
      'total_tests': totalTests,
      'total_questions': totalQuestions,
      'total_correct': totalCorrect,
      'average_score': averageScore,
    };
  }

  // ============================================================================
  // Métodos para gestión completa de user_tests (crear, actualizar, eliminar)
  // ============================================================================

  /// Obtiene un test por ID (sin filtros de finalized/visible)
  Future<UserTest?> fetchById(int id) async {
    final response = await _supabaseClient
        .from('user_tests')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return UserTest.fromJson(response);
  }

  /// Obtiene todos los tests de un usuario con filtros opcionales
  Future<List<UserTest>> fetchByUser(int userId, {bool? finalized, bool? visible}) async {
    var query = _supabaseClient.from('user_tests').select().eq('user_id', userId);
    if (finalized != null) {
      query = query.eq('finalized', finalized);
    }
    if (visible != null) {
      query = query.eq('visible', visible);
    }
    final response = await query.order('created_at', ascending: false);
    return (response as List)
        .map((json) => UserTest.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Crea un nuevo test de usuario
  Future<UserTest> createUserTest(UserTest userTest) async {
    final payload = userTest.toInsertMap();
    final response = await _supabaseClient
        .from('user_tests')
        .insert(payload)
        .select()
        .single();
    return UserTest.fromJson(response);
  }

  /// Crea respuestas de usuario para un test
  Future<void> createUserTestAnswers(
    int userTestId,
    Map<int, int?> selectedOptions,
    Map<int, List<QuestionOption>> questionOptions, {
    Map<int, List<int>?>? shuffledOptionIds,
  }) async {
    final List<Map<String, dynamic>> answers = [];
    int questionOrder = 1;

    for (final entry in selectedOptions.entries) {
      final questionId = entry.key;
      final selectedOptionId = entry.value;

      // Verificar si la respuesta es correcta
      bool? isCorrect;
      if (selectedOptionId != null && questionOptions.containsKey(questionId)) {
        final options = questionOptions[questionId]!;
        final selectedOption = options.firstWhere(
          (opt) => opt.id == selectedOptionId,
          orElse: () => options.first,
        );
        isCorrect = selectedOption.isCorrect;
      }

      // Obtener el orden shuffleado si está disponible
      final shuffledIds = shuffledOptionIds?[questionId];

      final answer = UserTestAnswer(
        userTestId: userTestId,
        questionId: questionId,
        selectedOptionId: selectedOptionId,
        correct: isCorrect,
        questionOrder: questionOrder++,
        shuffledOptionIds: shuffledIds?.isNotEmpty == true ? shuffledIds : null,
      );

      answers.add(answer.toInsertMap());
    }

    if (answers.isNotEmpty) {
      await _supabaseClient.from('user_test_answers').insert(answers);
    }
  }

  /// Actualiza un test de usuario
  Future<UserTest> updateUserTest(int id, UserTest userTest) async {
    final payload = userTest.toJson()..remove('id');
    payload.removeWhere((key, value) => value == null);
    final response = await _supabaseClient
        .from('user_tests')
        .update(payload)
        .eq('id', id)
        .select()
        .single();
    return UserTest.fromJson(response as Map<String, dynamic>);
  }

  /// Elimina un test de usuario
  Future<void> deleteUserTest(int id) async {
    await _supabaseClient.from('user_tests').delete().eq('id', id);
  }

  // ============================================================================
  // Métodos para gestión de respuestas de tests
  // ============================================================================

  /// Obtiene las respuestas de un test con las preguntas completas
  Future<List<UserTestAnswer>> fetchAnswers(int userTestId) async {
    final response = await _supabaseClient
        .from('user_test_answers')
        .select()
        .eq('user_test_id', userTestId)
        .order('question_order');
    return (response as List)
        .map((json) => UserTestAnswer.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene las respuestas de un test como objetos UserTestAnswer
  Future<List<UserTestAnswer>> fetchTestAnswersForReview(int userTestId) async {
    return await fetchAnswers(userTestId);
  }

  /// Obtiene las preguntas completas con opciones de un test desde user_test_answers
  Future<List<Map<String, dynamic>>> fetchTestQuestionsFromAnswers(int userTestId) async {
    try {
      print('🔍 [HISTORY_REPO] Fetching questions for user_test_id: $userTestId');

      // Primero obtener las respuestas ordenadas
      final answers = await fetchAnswers(userTestId);
      print('📋 [HISTORY_REPO] Found ${answers.length} answers');

      if (answers.isEmpty) {
        print('⚠️ [HISTORY_REPO] No answers found for this test');
        return [];
      }

      // Obtener los IDs de las preguntas
      final questionIds = answers.map((a) => a.questionId).toList();
      print('🔢 [HISTORY_REPO] Question IDs: $questionIds');

      // Cargar las preguntas (sin JOIN anidado)
      final questionsResponse = await _supabaseClient
          .from('questions')
          .select()
          .inFilter('id', questionIds);

      print('✅ [HISTORY_REPO] Fetched ${questionsResponse.length} questions from DB');

      // Cargar todas las opciones de estas preguntas
      final optionsResponse = await _supabaseClient
          .from('question_options')
          .select()
          .inFilter('question_id', questionIds);

      print('✅ [HISTORY_REPO] Fetched ${optionsResponse.length} options from DB');

      // Agrupar opciones por question_id
      final optionsByQuestionId = <int, List<Map<String, dynamic>>>{};
      for (final option in optionsResponse) {
        final questionId = option['question_id'] as int;
        optionsByQuestionId.putIfAbsent(questionId, () => []).add(option);
      }

      // Crear un mapa de preguntas por ID
      final questionsMap = <int, Map<String, dynamic>>{};
      for (final q in questionsResponse) {
        final questionId = q['id'] as int;
        final questionData = Map<String, dynamic>.from(q);
        // Agregar las opciones a la pregunta
        questionData['question_options'] = optionsByQuestionId[questionId] ?? [];
        questionsMap[questionId] = questionData;
      }

      // Construir la lista de preguntas en el orden correcto con las respuestas del usuario
      final result = <Map<String, dynamic>>[];
      for (final answer in answers) {
        final questionData = questionsMap[answer.questionId];
        if (questionData != null) {
          // Agregar información de la respuesta del usuario a la pregunta
          final questionWithAnswer = Map<String, dynamic>.from(questionData);
          questionWithAnswer['user_answer'] = {
            'selected_option_id': answer.selectedOptionId,
            'correct': answer.correct,
            'time_taken_seconds': answer.timeTakenSeconds,
            'question_order': answer.questionOrder,
            'difficulty_rating': answer.difficultyRating,
          };
          result.add(questionWithAnswer);
        } else {
          print('⚠️ [HISTORY_REPO] Question ${answer.questionId} not found in DB');
        }
      }

      print('✅ [HISTORY_REPO] Returning ${result.length} questions with answers');
      return result;
    } catch (e, stackTrace) {
      print('❌ [HISTORY_REPO] Error fetching test questions: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Inserta múltiples respuestas de test
  Future<List<UserTestAnswer>> insertUserTestAnswers(List<UserTestAnswer> answers) async {
    if (answers.isEmpty) return const [];
    final payload = answers.map((answer) => answer.toInsertMap()).toList();
    final response = await _supabaseClient
        .from('user_test_answers')
        .insert(payload)
        .select();
    return (response as List)
        .map((json) => UserTestAnswer.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Actualiza o inserta una respuesta (upsert)
  Future<UserTestAnswer> upsertAnswer(UserTestAnswer answer) async {
    final payload = answer.toJson()..remove('id');
    payload.removeWhere((key, value) => value == null);
    final response = await _supabaseClient
        .from('user_test_answers')
        .upsert(payload, onConflict: 'user_test_id,question_id')
        .select()
        .single();
    return UserTestAnswer.fromJson(response as Map<String, dynamic>);
  }

  /// Elimina todas las respuestas de un test
  Future<void> deleteAnswersForTest(int userTestId) async {
    await _supabaseClient.from('user_test_answers').delete().eq('user_test_id', userTestId);
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/question_model.dart';
import '../model/question_option_model.dart';

class QuestionRepository {
  final supabase = Supabase.instance.client;

  // CRUD para Question

  Future<List<Question>> fetchQuestions({
    int? topicId,
    int? academyId,
    int? specialtyId,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = supabase.from('questions').select();

      if (topicId != null) {
        query = query.eq('topic', topicId);
      }

      // Filtrar por academy_id si se proporciona
      if (academyId != null) {
        query = query.eq('academy_id', academyId);
      }

      // Ordenar por 'order' ascendente ANTES de aplicar limit/offset
      query = query.order('order', ascending: true);

      // Aplicar paginación si se especifica
      if (limit != null && offset != null) {
        final from = offset;
        final to = offset + limit - 1;
        query = query.range(from, to);
      }

      final response = await query;
      List<Question> questions =
          (response as List).map((json) => Question.fromJson(json)).toList();

      // Si se proporciona specialtyId, filtrar las questions por el specialty_id del topic
      if (specialtyId != null && questions.isNotEmpty) {
        // Obtener los topic IDs únicos de las questions
        final topicIds = questions.map((q) => q.topic).toSet().toList();

        // Consultar los topics que coinciden con la especialidad o son compartidos
        final topicsResponse = await supabase
            .from('topic')
            .select('id')
            .inFilter('id', topicIds)
            .or('specialty_id.eq.$specialtyId,specialty_id.is.null');

        // Crear un set con los IDs de topics válidos
        final validTopicIds =
            (topicsResponse as List).map((t) => t['id'] as int).toSet();

        // Filtrar questions que pertenezcan a topics válidos
        questions =
            questions.where((q) => validTopicIds.contains(q.topic)).toList();
      }

      return questions;
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }

  Future<Question> createQuestion(Question question) async {
    try {
      final response = await supabase
          .from('questions')
          .insert(question.toJson())
          .select()
          .single();
      return Question.fromJson(response);
    } catch (e) {
      throw Exception('Error creating question: $e');
    }
  }

  Future<Question> updateQuestion(int id, Question question) async {
    try {
      final response = await supabase
          .from('questions')
          .update(question.toJson())
          .eq('id', id)
          .select()
          .single();
      return Question.fromJson(response);
    } catch (e) {
      throw Exception('Error updating question: $e');
    }
  }

  Future<void> deleteQuestion(int id) async {
    try {
      await supabase.from('questions').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error deleting question: $e');
    }
  }

  /// Actualiza el orden de una pregunta específica
  Future<Question> updateQuestionOrder(int id, int newOrder) async {
    try {
      final response = await supabase
          .from('questions')
          .update({'order': newOrder})
          .eq('id', id)
          .select()
          .single();
      return Question.fromJson(response);
    } catch (e) {
      throw Exception('Error updating question order: $e');
    }
  }

  /// Actualiza el orden de múltiples preguntas en batch
  Future<void> updateQuestionsOrder(List<Map<String, dynamic>> updates) async {
    try {
      // Realizar múltiples updates en paralelo
      final futures = updates.map((update) {
        return supabase
            .from('questions')
            .update({'order': update['order']}).eq('id', update['id']);
      });

      await Future.wait(futures);
    } catch (e) {
      throw Exception('Error updating questions order: $e');
    }
  }

  // CRUD para QuestionOption

  Future<List<QuestionOption>> fetchQuestionOptions(int questionId) async {
    try {
      final response = await supabase
          .from('question_options')
          .select()
          .eq('question_id', questionId);
      return (response as List)
          .map((json) => QuestionOption.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching question options: $e');
    }
  }

  Future<List<QuestionOption>> fetchAllQuestionOptionsByTopic(int topicId,
      {int? academyId, int? specialtyId}) async {
    try {
      // Si se proporciona specialtyId, primero verificar que el topic sea válido para esa especialidad
      if (specialtyId != null) {
        final topicResponse = await supabase
            .from('topic')
            .select('id')
            .eq('id', topicId)
            .or('specialty_id.eq.$specialtyId,specialty_id.is.null')
            .maybeSingle();

        // Si el topic no es válido para esta especialidad, retornar lista vacía
        if (topicResponse == null) {
          return [];
        }
      }

      // Primero obtenemos todas las preguntas del topic
      var query = supabase.from('questions').select('id').eq('topic', topicId);

      // Filtrar por academy_id si se proporciona
      if (academyId != null) {
        query = query.eq('academy_id', academyId);
      }

      final questionsResponse = await query;

      final questionIds =
          (questionsResponse as List).map((q) => q['id'] as int).toList();

      if (questionIds.isEmpty) {
        return [];
      }

      // Luego obtenemos todas las opciones de esas preguntas
      final optionsResponse = await supabase
          .from('question_options')
          .select()
          .inFilter('question_id', questionIds);

      return (optionsResponse as List)
          .map((json) => QuestionOption.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching all question options by topic: $e');
    }
  }

  Future<QuestionOption> createQuestionOption(QuestionOption option) async {
    try {
      final response = await supabase
          .from('question_options')
          .insert(option.toJson())
          .select()
          .single();
      return QuestionOption.fromJson(response);
    } catch (e) {
      throw Exception('Error creating question option: $e');
    }
  }

  Future<QuestionOption> updateQuestionOption(
      int id, QuestionOption option) async {
    try {
      final response = await supabase
          .from('question_options')
          .update(option.toJson())
          .eq('id', id)
          .select()
          .single();
      return QuestionOption.fromJson(response);
    } catch (e) {
      throw Exception('Error updating question option: $e');
    }
  }

  Future<void> deleteQuestionOption(int id) async {
    try {
      await supabase.from('question_options').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error deleting question option: $e');
    }
  }

  /// Genera audios retro para múltiples preguntas
  ///
  /// Recibe una lista de objetos Question y usa su retroAudioText para generar el audio
  /// Retorna un mapa con los resultados y errores
  Future<Map<String, dynamic>> generateRetroTexts(
      List<Question> questions) async {
    // Validar que todos los elementos tengan los campos requeridos
    for (final question in questions) {
      if (question.id == null) {
        throw Exception('Todas las preguntas deben tener un ID válido');
      }
      if (question.retroAudioText.isEmpty) {
        throw Exception(
            'La pregunta ${question.id} no tiene retroAudioText configurado');
      }
    }

    // Convertir las preguntas al formato esperado por la edge function
    final questionsPayload = questions
        .map((q) => {
              'text': q.retroAudioText,
              'questionId': q.id!,
              'topicId': q.topic,
            })
        .toList();

    final response = await supabase.functions.invoke(
      'generate-retro-text',
      body: {
        'questions': questionsPayload,
      },
    );

    if (response.status != 200 && response.status != 207) {
      throw Exception('Error en edge function: ${response.data}');
    }

    final data = response.data;
    if (data == null) {
      throw Exception('Edge function no retornó datos');
    }

    return data as Map<String, dynamic>;
  }

  /// Genera audio retro para una sola pregunta
  ///
  /// Usa el retroAudioText de la pregunta o permite especificar uno custom
  Future<Map<String, dynamic>> generateRetroText(
    Question question, {
    String? customText,
  }) async {
    if (question.id == null) {
      throw Exception('La pregunta debe tener un ID válido');
    }

    final textToUse = customText ?? question.retroAudioText;

    if (textToUse.isEmpty) {
      throw Exception('No hay texto para generar el audio');
    }

    final response = await supabase.functions.invoke(
      'generate-retro-audio',
      body: {
        'text': textToUse,
        'questionId': question.id!,
        'topicId': question.topic,
      },
    );

    if (response.status != 200) {
      throw Exception('Error en edge function: ${response.data}');
    }

    final data = response.data;
    if (data == null || data['success'] != true) {
      throw Exception(
          'Edge function no retornó éxito: ${data?['error'] ?? 'Unknown error'}');
    }

    return data as Map<String, dynamic>;
  }

  /// Genera preguntas usando IA (OpenAI) a través de la edge function
  ///
  /// Parámetros:
  /// - [topicId]: ID del topic al que pertenecerán las preguntas
  /// - [topicName]: Nombre del topic (usado por la IA para contexto)
  /// - [numQuestions]: Número de preguntas a generar (default: 5)
  /// - [difficulty]: Nivel de dificultad (0: básica, 1: media, 2: avanzada, default: 0)
  /// - [numOptions]: Número de opciones por pregunta (default: 4)
  /// - [context]: Texto opcional del cual extraer las preguntas
  /// - [academyId]: ID de la academia (default: 1)
  /// - [saveToDatabase]: Si debe guardar las preguntas en la BD (default: true)
  ///
  /// Retorna un mapa con:
  /// - success: bool
  /// - questions: List de preguntas generadas
  /// - saved_ids: List de IDs si se guardaron en BD
  /// - message: String con mensaje de resultado
  Future<Map<String, dynamic>> generateQuestionsWithAI({
    required int topicId,
    required String topicName,
    int numQuestions = 5,
    int difficulty = 0,
    int numOptions = 4,
    String? context,
    int academyId = 1,
    bool saveToDatabase = true,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'generate_ai_questions',
        body: {
          'topic_id': topicId,
          'topic_name': topicName,
          'num_questions': numQuestions,
          'difficulty': difficulty,
          'num_options': numOptions,
          if (context != null) 'context': context,
          'academy_id': academyId,
          'save_to_database': saveToDatabase,
        },
      );

      if (response.status != 200) {
        throw Exception('Error en edge function: ${response.data}');
      }

      final data = response.data;
      if (data == null || data['success'] != true) {
        throw Exception(
            'Edge function no retornó éxito: ${data?['error'] ?? 'Unknown error'}');
      }

      return data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error generating questions with AI: $e');
    }
  }

  /// Genera el texto del retro audio usando IA para una pregunta
  Future<String> generateRetroAudioText(Question question) async {
    try {
      if (question.id == null) {
        throw Exception('La pregunta debe tener un ID válido');
      }

      final response = await Supabase.instance.client.functions.invoke(
        'generate_retro_audio_text',
        body: {
          'question_ids': [question.id],
          'batch_size': 1,
        },
      );

      if (response.status == 200 || response.status == 207) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;

        if (results.isNotEmpty) {
          final result = results[0] as Map<String, dynamic>;
          final generatedText = result['retro_audio_text'] as String;
          return generatedText;
        } else {
          throw Exception('No se generó ningún texto');
        }
      } else {
        throw Exception('Error al generar texto: ${response.status}');
      }
    } catch (e) {
      throw Exception('Error generating retro audio text: $e');
    }
  }
}

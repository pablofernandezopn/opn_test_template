import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../bootstrap.dart';
import '../model/question_model.dart';
import '../model/question_option_model.dart';

class QuestionRepository {
  SupabaseClient get supabase => Supabase.instance.client;

  // CRUD para Question

  Future<List<Question>> fetchQuestions({int? topicId, int? academyId}) async {
    try {
      var query = supabase.from('questions').select();

      if (topicId != null) {
        query = query.eq('topic', topicId);
      }

      // Filtrar por academy_id si se proporciona
      if (academyId != null) {
        query = query.eq('academy_id', academyId);
      }

      final response = await query;
      final questions = (response as List).map((json) => Question.fromJson(json)).toList();

      // Ordenar en el dispositivo por el campo 'order' ascendente
      questions.sort((a, b) => a.order.compareTo(b.order));

      return questions;
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }

  /// Obtiene preguntas específicas por sus IDs
  Future<List<Question>> fetchQuestionsByIds(List<int> questionIds) async {
    try {
      if (questionIds.isEmpty) return [];

      logger.debug('📚 [QUESTION_REPO] Fetching ${questionIds.length} questions by IDs');

      final response = await supabase
          .from('questions')
          .select()
          .inFilter('id', questionIds);

      final questions = (response as List)
          .map((json) => Question.fromJson(json))
          .toList();

      logger.debug('✅ [QUESTION_REPO] Fetched ${questions.length} questions');

      return questions;
    } catch (e) {
      logger.error('❌ [QUESTION_REPO] Error fetching questions by IDs: $e');
      throw Exception('Error fetching questions by IDs: $e');
    }
  }

  Future<Question> createQuestion(Question question) async {
    try {
      final response = await supabase.from('questions').insert(question.toJson()).select().single();
      return Question.fromJson(response);
    } catch (e) {
      throw Exception('Error creating question: $e');
    }
  }

  Future<Question> updateQuestion(int id, Question question) async {
    try {
      final response = await supabase.from('questions').update(question.toJson()).eq('id', id).select().single();
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
            .update({'order': update['order']})
            .eq('id', update['id']);
      });

      await Future.wait(futures);
    } catch (e) {
      throw Exception('Error updating questions order: $e');
    }
  }

  // CRUD para QuestionOption

  Future<List<QuestionOption>> fetchQuestionOptions(int questionId) async {
    try {
      final response = await supabase.from('question_options').select().eq('question_id', questionId);
      return (response as List).map((json) => QuestionOption.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching question options: $e');
    }
  }

  Future<List<QuestionOption>> fetchAllQuestionOptionsByTopic(int topicId, {int? academyId}) async {
    try {
      // Primero obtenemos todas las preguntas del topic
      var query = supabase
          .from('questions')
          .select()
          .eq('topic', topicId);


      // Filtrar por academy_id si se proporciona
      if (academyId != null) {
        query = query.eq('academy_id', academyId);
      }

      final questionsResponse = await query;
      logger.debug('Fetching questions for topicId: $topicId with academyId: $academyId');
      logger.debug('Constructed query: ${questionsResponse.toString()}');
      final questionIds = (questionsResponse as List)
          .map((q) => q['id'] as int)
          .toList();

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

  /// Obtiene las opciones para múltiples preguntas por sus IDs
  Future<List<QuestionOption>> fetchOptionsForQuestions(List<int> questionIds) async {
    try {
      if (questionIds.isEmpty) return [];

      final response = await supabase
          .from('question_options')
          .select()
          .inFilter('question_id', questionIds);

      return (response as List)
          .map((json) => QuestionOption.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching options for questions: $e');
    }
  }

  Future<QuestionOption> createQuestionOption(QuestionOption option) async {
    try {
      final response = await supabase.from('question_options').insert(option.toJson()).select().single();
      return QuestionOption.fromJson(response);
    } catch (e) {
      throw Exception('Error creating question option: $e');
    }
  }

  Future<QuestionOption> updateQuestionOption(int id, QuestionOption option) async {
    try {
      final response = await supabase.from('question_options').update(option.toJson()).eq('id', id).select().single();
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
}

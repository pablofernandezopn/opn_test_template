import 'package:supabase_flutter/supabase_flutter.dart';
import '../../questions/model/question_model.dart';
import '../model/test_config.dart';
import '../model/test_mode.dart';

/// Repositorio para gestionar tests
/// Solo se encarga de llamar a la edge function para generar tests
class TestRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Genera un test usando la edge function de Supabase
  /// Retorna una lista de preguntas con sus opciones
  Future<List<Question>> generateTestWithEdgeFunction(
    TestConfig config, {
    int? academyId,
  }) async {
    try {
      print('🚀 [TEST_REPOSITORY] Llamando edge function con config: $config');

      // Convertir topic IDs a formato esperado por la edge function
      // Todos los topics tienen peso igual (weight = 1)
      final topics = config.selectedTopicIds.map((id) => {
        'id': id,
        'weight': 1, // Peso igual para todos los topics
      }).toList();

      // Convertir dificultades a array de strings
      // Si la lista está vacía, no enviamos nada (todas las dificultades)
      final difficultiesArray = config.difficulties.map((d) => d.value).toList();

      final response = await _supabase.functions.invoke(
        'generate-custom-test', // Nombre correcto de la edge function
        body: {
          'topics': topics,
          'totalQuestions': config.numQuestions,
          if (academyId != null) 'academyId': academyId,
          // Enviar topicTypeId para filtrar preguntas por tipo de tema
          if (config.topicTypeId != null) 'topicTypeId': config.topicTypeId,
          // Enviar difficulties solo si hay alguna seleccionada específicamente
          if (difficultiesArray.isNotEmpty) 'difficulties': difficultiesArray,
        },
      );

      print('✅ [TEST_REPOSITORY] Respuesta de edge function: ${response.status}');

      if (response.status != 200) {
        throw Exception('Error en edge function: ${response.data}');
      }

      final data = response.data;
      if (data == null) {
        throw Exception('Edge function no retornó datos');
      }

      if (data['success'] != true) {
        throw Exception('Edge function retornó error: ${data['error'] ?? 'Unknown error'}');
      }

      if (data['questions'] == null) {
        throw Exception('Edge function no retornó preguntas');
      }

      // Parsear las preguntas
      final questions = (data['questions'] as List)
          .map((json) => Question.fromJson(json))
          .toList();

      print('✅ [TEST_REPOSITORY] ${questions.length} preguntas generadas');
      print('📊 [TEST_REPOSITORY] Distribución: ${data['distribution']}');

      return questions;
    } catch (e) {
      print('❌ [TEST_REPOSITORY] Error calling edge function: $e');
      rethrow;
    }
  }

  /// Genera un test usando la edge function de modos mixtos
  /// Soporta múltiples modos: topics, failed, skipped
  Future<List<Question>> generateMixedModeTest(
    TestConfig config, {
    required String userId,
    int? academyId,
    List<int>? availableTopicIds, // IDs de todos los topics del topic_type seleccionado
  }) async {
    try {
      print('🚀 [TEST_REPOSITORY] Llamando edge function de modo mixto con config: $config');
      print('   Modos seleccionados: ${config.testModes}');

      // Preparar body
      final Map<String, dynamic> body = {
        'modes': config.testModes.map((mode) => mode.value).toList(),
        'totalQuestions': config.numQuestions,
        'userId': userId,
        if (academyId != null) 'academyId': academyId,
        // Enviar topicTypeId para filtrar preguntas por tipo de tema
        if (config.topicTypeId != null) 'topicTypeId': config.topicTypeId,
      };

      // Si hay modo topics, agregar los topics seleccionados
      if (config.hasTopicsMode && config.selectedTopicIds.isNotEmpty) {
        body['topics'] = config.selectedTopicIds.map((id) => {
          'id': id,
          'weight': 1,
        }).toList();
      }

      // Si hay modos de repaso, filtrar por los topics disponibles del topic_type
      // Esto garantiza que solo se obtengan preguntas del topic_type seleccionado
      if (config.hasReviewMode) {
        if (config.selectedTopicIds.isNotEmpty) {
          // Si hay topics seleccionados, usarlos (caso mixto o usuario seleccionó algunos)
          body['topicIds'] = config.selectedTopicIds;
        } else if (availableTopicIds != null && availableTopicIds.isNotEmpty) {
          // Si no hay topics seleccionados, usar todos los disponibles del topic_type
          body['topicIds'] = availableTopicIds;
        }
      }

      // Agregar dificultades si están especificadas
      if (config.difficulties.isNotEmpty) {
        body['difficulties'] = config.difficulties.map((d) => d.value).toList();
      }

      print('📦 [TEST_REPOSITORY] Body de request: $body');

      final response = await _supabase.functions.invoke(
        'generate-mixed-mode-test',
        body: body,
      );

      print('✅ [TEST_REPOSITORY] Respuesta de edge function: ${response.status}');

      if (response.status != 200) {
        throw Exception('Error en edge function: ${response.data}');
      }

      final data = response.data;
      if (data == null) {
        throw Exception('Edge function no retornó datos');
      }

      if (data['success'] != true) {
        throw Exception('Edge function retornó error: ${data['error'] ?? 'Unknown error'}');
      }

      if (data['questions'] == null) {
        throw Exception('Edge function no retornó preguntas');
      }

      // Parsear las preguntas
      final questions = (data['questions'] as List)
          .map((json) => Question.fromJson(json))
          .toList();

      print('✅ [TEST_REPOSITORY] ${questions.length} preguntas generadas');
      print('📊 [TEST_REPOSITORY] Distribución por modo: ${data['modeDistribution']}');
      print('📊 [TEST_REPOSITORY] Distribución por tema: ${data['topicDistribution']}');

      if (data['message'] != null) {
        print('⚠️ [TEST_REPOSITORY] ${data['message']}');
      }

      return questions;
    } catch (e) {
      print('❌ [TEST_REPOSITORY] Error calling mixed-mode edge function: $e');
      rethrow;
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../bootstrap.dart';
import '../model/user_stats_model.dart';

class StatsRepository {
  SupabaseClient get _supabaseClient => Supabase.instance.client;

  /// Obtiene las estadísticas globales del usuario en topics Mock
  ///
  /// Utiliza la función SQL optimizada `get_user_mock_stats` para calcular
  /// todas las estadísticas en una sola query
  Future<UserStats> getUserMockStats({required int userId}) async {
    try {
      logger.debug('📊 [STATS_REPO] Fetching mock stats for user_id=$userId');

      final response = await _supabaseClient.rpc(
        'get_user_mock_stats',
        params: {'p_user_id': userId},
      );

      if (response == null) {
        logger.debug('⚠️ [STATS_REPO] No stats found, returning empty');
        return UserStats.empty();
      }

      logger.debug('✅ [STATS_REPO] Successfully fetched mock stats');
      return UserStats.fromJson(response as Map<String, dynamic>);
    } catch (e, stackTrace) {
      logger.error('❌ [STATS_REPO] Error fetching user mock stats: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene estadísticas detalladas por cada topic Mock
  ///
  /// Retorna una lista de estadísticas para cada topic que el usuario ha completado
  Future<List<TopicMockStats>> getTopicMockStats({required int userId}) async {
    try {
      logger.debug('📊 [STATS_REPO] Fetching topic mock stats for user_id=$userId');

      final response = await _supabaseClient.rpc(
        'get_user_topic_mock_stats',
        params: {'p_user_id': userId},
      ) as List<dynamic>;

      logger.debug('✅ [STATS_REPO] Fetched ${response.length} topic stats');

      return response
          .map((json) => TopicMockStats.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      logger.error('❌ [STATS_REPO] Error fetching topic mock stats: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene datos para gráficos de evolución temporal
  ///
  /// [userId] - ID del usuario
  /// [days] - Número de días hacia atrás (por defecto 30)
  ///
  /// Retorna puntos de datos ordenados cronológicamente
  Future<List<StatsDataPoint>> getMockEvolution({
    required int userId,
    int days = 30,
  }) async {
    try {
      logger.debug('📊 [STATS_REPO] Fetching mock evolution for user_id=$userId, days=$days');

      final response = await _supabaseClient.rpc(
        'get_user_mock_evolution',
        params: {
          'p_user_id': userId,
          'p_days': days,
        },
      ) as List<dynamic>;

      logger.debug('✅ [STATS_REPO] Fetched ${response.length} data points');

      return response
          .map((json) => StatsDataPoint.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      logger.error('❌ [STATS_REPO] Error fetching mock evolution: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Compara el rendimiento del usuario con el promedio en un topic
  ///
  /// [userId] - ID del usuario
  /// [topicId] - ID del topic
  ///
  /// Retorna un mapa con la comparación:
  /// - user_score: Puntuación del usuario
  /// - user_rank: Posición del usuario
  /// - average_score: Puntuación promedio
  /// - median_rank: Posición mediana
  /// - total_participants: Total de participantes
  /// - percentile: Percentil del usuario
  Future<Map<String, dynamic>> getTopicComparison({
    required int userId,
    required int topicId,
  }) async {
    try {
      logger.debug('📊 [STATS_REPO] Fetching comparison for user_id=$userId, topic_id=$topicId');

      final response = await _supabaseClient.rpc(
        'get_user_mock_comparison',
        params: {
          'p_user_id': userId,
          'p_topic_id': topicId,
        },
      );

      if (response == null) {
        logger.debug('⚠️ [STATS_REPO] No comparison data found');
        return {};
      }

      logger.debug('✅ [STATS_REPO] Successfully fetched comparison');
      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      logger.error('❌ [STATS_REPO] Error fetching topic comparison: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene el progreso/mejora del usuario en topics con múltiples intentos
  ///
  /// Solo retorna topics donde el usuario ha mejorado (attempts > 1)
  /// Ordenados por porcentaje de mejora (mayor primero)
  Future<List<Map<String, dynamic>>> getMockProgress({
    required int userId,
  }) async {
    try {
      logger.debug('📊 [STATS_REPO] Fetching mock progress for user_id=$userId');

      final response = await _supabaseClient.rpc(
        'get_user_mock_progress',
        params: {'p_user_id': userId},
      ) as List<dynamic>;

      logger.debug('✅ [STATS_REPO] Fetched ${response.length} progress items');

      return response.map((json) => json as Map<String, dynamic>).toList();
    } catch (e, stackTrace) {
      logger.error('❌ [STATS_REPO] Error fetching mock progress: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene estadísticas completas del usuario (global + por topic)
  ///
  /// Optimización: hace ambas llamadas en paralelo
  Future<(UserStats, List<TopicMockStats>)> getCompleteStats({
    required int userId,
  }) async {
    try {
      logger.debug('📊 [STATS_REPO] Fetching complete stats for user_id=$userId');

      final results = await Future.wait([
        getUserMockStats(userId: userId),
        getTopicMockStats(userId: userId),
      ]);

      logger.debug('✅ [STATS_REPO] Successfully fetched complete stats');

      return (
        results[0] as UserStats,
        results[1] as List<TopicMockStats>,
      );
    } catch (e, stackTrace) {
      logger.error('❌ [STATS_REPO] Error fetching complete stats: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene la evolución por topic_type agrupando datos desde topic_mock_rankings
  ///
  /// Retorna una lista de TopicTypeEvolutionData, uno por cada topic_type Mock
  /// donde el usuario tenga tests completados
  Future<List<TopicTypeEvolutionData>> getEvolutionByTopicType({
    required int userId,
  }) async {
    try {
      logger.debug('📊 [STATS_REPO] Fetching evolution by topic_type for user_id=$userId');

      // Query para obtener datos agrupados por topic_type
      final response = await _supabaseClient
          .from('topic_mock_rankings')
          .select('''
            topic_id,
            first_score,
            first_attempt_date,
            rank_position,
            topic:topic_id (
              id,
              topic_name,
              topic_type_id,
              topic_type:topic_type_id (
                id,
                topic_type_name,
                level
              )
            )
          ''')
          .eq('user_id', userId)
          .order('first_attempt_date', ascending: true);

      logger.debug('📊 [STATS_REPO] Response length: ${response.length}');

      // Agrupar por topic_type_id
      final Map<int, List<Map<String, dynamic>>> groupedByTopicType = {};

      for (final item in response) {
        final topic = item['topic'] as Map<String, dynamic>?;
        if (topic == null) continue;

        final topicType = topic['topic_type'] as Map<String, dynamic>?;
        if (topicType == null) continue;

        // Solo incluir topic_types de nivel Mock
        if (topicType['level'] != 'Mock') continue;

        final topicTypeId = topicType['id'] as int;

        if (!groupedByTopicType.containsKey(topicTypeId)) {
          groupedByTopicType[topicTypeId] = [];
        }

        groupedByTopicType[topicTypeId]!.add({
          'topic_type_id': topicTypeId,
          'topic_type_name': topicType['topic_type_name'],
          'topic_id': topic['id'],
          'topic_name': topic['topic_name'],
          'first_score': item['first_score'],
          'first_attempt_date': item['first_attempt_date'],
          'rank_position': item['rank_position'],
        });
      }

      logger.debug('✅ [STATS_REPO] Found ${groupedByTopicType.length} topic_types');

      // Convertir a TopicTypeEvolutionData
      final result = groupedByTopicType.entries.map((entry) {
        final topicTypeId = entry.key;
        final items = entry.value;

        // Tomar el primer item para obtener el nombre del topic_type
        final firstItem = items.first;

        final topics = items.map((item) {
          return TopicEvolutionLine(
            topicId: item['topic_id'] as int,
            topicName: item['topic_name'] as String,
            firstScore: (item['first_score'] as num).toDouble(),
            firstAttemptDate: DateTime.parse(item['first_attempt_date'] as String),
            rankPosition: item['rank_position'] as int?,
          );
        }).toList();

        return TopicTypeEvolutionData(
          topicTypeId: topicTypeId,
          topicTypeName: firstItem['topic_type_name'] as String,
          topics: topics,
        );
      }).toList();

      // Ordenar por topic_type_name
      result.sort((a, b) => a.topicTypeName.compareTo(b.topicTypeName));

      logger.debug('✅ [STATS_REPO] Successfully processed evolution by topic_type');

      return result;
    } catch (e, stackTrace) {
      logger.error('❌ [STATS_REPO] Error fetching evolution by topic_type: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../bootstrap.dart';
import '../model/ranking_entry_model.dart';
import '../model/group_ranking_entry_model.dart';

class RankingRepository {
  SupabaseClient get _supabaseClient => Supabase.instance.client;

  /// Número de items por página para paginación
  static const int pageSize = 20;

  /// Obtiene el ranking de un topic tipo Mock con paginación
  ///
  /// [topicId] - ID del topic para el cual obtener el ranking
  /// [page] - Número de página (empezando desde 0)
  /// [limit] - Cantidad de resultados por página (por defecto 20)
  ///
  /// Retorna una lista de [RankingEntry] ordenada por rank_position
  Future<List<RankingEntry>> fetchTopicRanking({
    required int topicId,
    int page = 0,
    int limit = pageSize,
  }) async {
    try {
      logger.debug('📊 [RANKING_REPO] Fetching ranking for topic_id=$topicId, page=$page, limit=$limit');

      final offset = page * limit;

      // Hacer JOIN con la tabla users para obtener información del usuario
      final response = await _supabaseClient
          .from('topic_mock_rankings')
          .select('''
            id,
            topic_id,
            user_id,
            topic_group_id,
            first_score,
            best_score,
            attempts,
            rank_position,
            last_attempt_date,
            first_attempt_date,
            created_at,
            updated_at,
            users!inner (
              username,
              display_name,
              profile_image,
              first_name,
              last_name
            )
          ''')
          .eq('topic_id', topicId)
          .order('rank_position', ascending: true)
          .range(offset, offset + limit - 1);

      logger.debug('✅ [RANKING_REPO] Fetched ${response.length} ranking entries');

      return response.map((json) {
        // Aplanar la estructura del JOIN
        final userData = json['users'] as Map<String, dynamic>;
        final flattenedJson = {
          ...json,
          'username': userData['username'],
          'display_name': userData['display_name'],
          'profile_image': userData['profile_image'],
          'first_name': userData['first_name'],
          'last_name': userData['last_name'],
        };
        flattenedJson.remove('users');

        return RankingEntry.fromJson(flattenedJson);
      }).toList();
    } catch (e, stackTrace) {
      logger.error('❌ [RANKING_REPO] Error fetching topic ranking: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene el ranking de un grupo de topics (topic_group)
  ///
  /// [topicGroupId] - ID del grupo de topics
  /// [page] - Número de página (empezando desde 0)
  /// [limit] - Cantidad de resultados por página
  ///
  /// Retorna una lista de [RankingEntry] de todos los topics del grupo
  Future<List<RankingEntry>> fetchTopicGroupRanking({
    required int topicGroupId,
    int page = 0,
    int limit = pageSize,
  }) async {
    try {
      logger.debug('📊 [RANKING_REPO] Fetching ranking for topic_group_id=$topicGroupId, page=$page, limit=$limit');

      final offset = page * limit;

      final response = await _supabaseClient
          .from('topic_mock_rankings')
          .select('''
            id,
            topic_id,
            user_id,
            topic_group_id,
            first_score,
            best_score,
            attempts,
            rank_position,
            last_attempt_date,
            first_attempt_date,
            created_at,
            updated_at,
            users!inner (
              username,
              display_name,
              profile_image,
              first_name,
              last_name
            )
          ''')
          .eq('topic_group_id', topicGroupId)
          .order('rank_position', ascending: true)
          .range(offset, offset + limit - 1);

      logger.debug('✅ [RANKING_REPO] Fetched ${response.length} ranking entries for group');

      return response.map((json) {
        final userData = json['users'] as Map<String, dynamic>;
        final flattenedJson = {
          ...json,
          'username': userData['username'],
          'display_name': userData['display_name'],
          'profile_image': userData['profile_image'],
          'first_name': userData['first_name'],
          'last_name': userData['last_name'],
        };
        flattenedJson.remove('users');

        return RankingEntry.fromJson(flattenedJson);
      }).toList();
    } catch (e, stackTrace) {
      logger.error('❌ [RANKING_REPO] Error fetching topic group ranking: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene la entrada del ranking de un usuario específico en un topic
  ///
  /// [topicId] - ID del topic
  /// [userId] - ID del usuario
  ///
  /// Retorna la [RankingEntry] del usuario o null si no ha participado
  Future<RankingEntry?> fetchUserRankingEntry({
    required int topicId,
    required int userId,
  }) async {
    try {
      logger.debug('📊 [RANKING_REPO] Fetching user ranking for topic_id=$topicId, user_id=$userId');

      final response = await _supabaseClient
          .from('topic_mock_rankings')
          .select('''
            id,
            topic_id,
            user_id,
            topic_group_id,
            first_score,
            best_score,
            attempts,
            rank_position,
            last_attempt_date,
            first_attempt_date,
            created_at,
            updated_at,
            users!inner (
              username,
              display_name,
              profile_image,
              first_name,
              last_name
            )
          ''')
          .eq('topic_id', topicId)
          .eq('user_id', userId)
          .limit(1);

      if (response.isEmpty) {
        logger.debug('⚠️ [RANKING_REPO] No ranking entry found for user');
        return null;
      }

      final json = response.first;
      final userData = json['users'] as Map<String, dynamic>;
      final flattenedJson = {
        ...json,
        'username': userData['username'],
        'display_name': userData['display_name'],
        'profile_image': userData['profile_image'],
        'first_name': userData['first_name'],
        'last_name': userData['last_name'],
      };
      flattenedJson.remove('users');

      logger.debug('✅ [RANKING_REPO] Found user ranking entry');
      return RankingEntry.fromJson(flattenedJson);
    } catch (e, stackTrace) {
      logger.error('❌ [RANKING_REPO] Error fetching user ranking entry: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene el número total de participantes en un topic
  Future<int> getTotalParticipants({required int topicId}) async {
    try {
      final response = await _supabaseClient
          .from('topic_mock_rankings')
          .select('id')
          .eq('topic_id', topicId)
          .count();

      return response.count;
    } catch (e, stackTrace) {
      logger.error('❌ [RANKING_REPO] Error getting total participants: $e');
      logger.debug('Stack trace: $stackTrace');
      return 0;
    }
  }

  /// Obtiene las mejores N puntuaciones de un topic
  ///
  /// [topicId] - ID del topic
  /// [limit] - Número de mejores puntuaciones a obtener (por defecto 10)
  ///
  /// Retorna una lista de [RankingEntry] con las mejores puntuaciones
  Future<List<RankingEntry>> getTopScores({
    required int topicId,
    int limit = 10,
  }) async {
    try {
      logger.debug('🏆 [RANKING_REPO] Fetching top $limit scores for topic_id=$topicId');

      final response = await _supabaseClient
          .from('topic_mock_rankings')
          .select('''
            id,
            topic_id,
            user_id,
            topic_group_id,
            first_score,
            best_score,
            attempts,
            rank_position,
            last_attempt_date,
            first_attempt_date,
            created_at,
            updated_at,
            users!inner (
              username,
              display_name,
              profile_image,
              first_name,
              last_name
            )
          ''')
          .eq('topic_id', topicId)
          .order('first_score', ascending: false)
          .limit(limit);

      logger.debug('✅ [RANKING_REPO] Fetched ${response.length} top scores');

      return response.map((json) {
        final userData = json['users'] as Map<String, dynamic>;
        final flattenedJson = {
          ...json,
          'username': userData['username'],
          'display_name': userData['display_name'],
          'profile_image': userData['profile_image'],
          'first_name': userData['first_name'],
          'last_name': userData['last_name'],
        };
        flattenedJson.remove('users');

        return RankingEntry.fromJson(flattenedJson);
      }).toList();
    } catch (e, stackTrace) {
      logger.error('❌ [RANKING_REPO] Error fetching top scores: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Verifica si hay más páginas disponibles
  Future<bool> hasMorePages({
    required int topicId,
    required int currentPage,
    int limit = pageSize,
  }) async {
    try {
      final totalParticipants = await getTotalParticipants(topicId: topicId);
      final totalPages = (totalParticipants / limit).ceil();
      return currentPage < totalPages - 1;
    } catch (e) {
      logger.error('❌ [RANKING_REPO] Error checking for more pages: $e');
      return false;
    }
  }

  // ============================================================================
  // MÉTODOS PARA RANKINGS DE GRUPOS (TOPIC GROUPS)
  // ============================================================================

  /// Obtiene el ranking consolidado de un topic_group
  ///
  /// Este método obtiene todos los rankings de los topics que pertenecen al grupo,
  /// agrupa por usuario y calcula el promedio de first_score para crear el ranking final.
  /// Solo incluye usuarios que han completado TODOS los topics del grupo.
  ///
  /// [topicGroupId] - ID del grupo de topics
  ///
  /// Retorna una lista de [GroupRankingEntry] ordenada por promedio descendente
  Future<List<GroupRankingEntry>> fetchGroupRanking({
    required int topicGroupId,
  }) async {
    try {
      logger.debug('📊 [RANKING_REPO] Fetching consolidated ranking for topic_group_id=$topicGroupId');

      // Primero, obtener todos los topic_ids del grupo
      final topicsResponse = await _supabaseClient
          .from('topic')
          .select('id')
          .eq('topic_group_id', topicGroupId)
          .eq('enabled', true);

      if (topicsResponse.isEmpty) {
        logger.debug('⚠️ [RANKING_REPO] No topics found in group');
        return [];
      }

      final topicIds = topicsResponse.map((t) => t['id'] as int).toList();
      final totalTopicsInGroup = topicIds.length;

      logger.debug('📋 [RANKING_REPO] Found ${topicIds.length} topics in group: $topicIds');

      // Obtener todos los rankings de esos topics
      final rankingsResponse = await _supabaseClient
          .from('topic_mock_rankings')
          .select('''
            topic_id,
            user_id,
            first_score,
            attempts,
            first_attempt_date,
            last_attempt_date,
            users!inner (
              username,
              display_name,
              profile_image,
              first_name,
              last_name
            )
          ''')
          .eq('topic_group_id', topicGroupId);

      logger.debug('📊 [RANKING_REPO] Fetched ${rankingsResponse.length} individual ranking entries');

      // Agrupar por usuario
      final Map<int, _UserGroupStats> userStats = {};

      for (final entry in rankingsResponse) {
        final userId = entry['user_id'] as int;
        final topicId = entry['topic_id'] as int;
        final firstScore = (entry['first_score'] as num).toDouble();
        final attempts = entry['attempts'] as int;
        final firstAttemptDate = DateTime.parse(entry['first_attempt_date'] as String);
        final lastAttemptDate = DateTime.parse(entry['last_attempt_date'] as String);
        final userData = entry['users'] as Map<String, dynamic>;

        if (!userStats.containsKey(userId)) {
          userStats[userId] = _UserGroupStats(
            userId: userId,
            username: userData['username'] as String,
            displayName: userData['display_name'] as String?,
            profileImage: userData['profile_image'] as String?,
            firstName: userData['first_name'] as String?,
            lastName: userData['last_name'] as String?,
          );
        }

        final stats = userStats[userId]!;
        stats.topicScores[topicId] = firstScore;
        stats.totalAttempts += attempts;

        if (stats.firstAttemptDate == null || firstAttemptDate.isBefore(stats.firstAttemptDate!)) {
          stats.firstAttemptDate = firstAttemptDate;
        }
        if (stats.lastAttemptDate == null || lastAttemptDate.isAfter(stats.lastAttemptDate!)) {
          stats.lastAttemptDate = lastAttemptDate;
        }
      }

      // Filtrar solo usuarios que completaron TODOS los topics del grupo
      final completeUserStats = userStats.values
          .where((stats) => stats.topicScores.length == totalTopicsInGroup)
          .toList();

      logger.debug('👥 [RANKING_REPO] ${completeUserStats.length} users completed all topics');

      // Calcular promedios y ordenar
      completeUserStats.sort((a, b) {
        final avgA = a.averageScore;
        final avgB = b.averageScore;
        final comparison = avgB.compareTo(avgA); // Descendente
        if (comparison != 0) return comparison;
        // Si tienen el mismo promedio, ordenar por fecha de primer intento
        return a.firstAttemptDate!.compareTo(b.firstAttemptDate!);
      });

      // Crear las entradas del ranking con posiciones
      final List<GroupRankingEntry> rankingEntries = [];
      for (int i = 0; i < completeUserStats.length; i++) {
        final stats = completeUserStats[i];
        rankingEntries.add(GroupRankingEntry(
          userId: stats.userId,
          username: stats.username,
          displayName: stats.displayName,
          profileImage: stats.profileImage,
          firstName: stats.firstName,
          lastName: stats.lastName,
          averageFirstScore: stats.averageScore,
          totalAttempts: stats.totalAttempts,
          topicsCompleted: stats.topicScores.length,
          totalTopicsInGroup: totalTopicsInGroup,
          rankPosition: i + 1,
          firstAttemptDate: stats.firstAttemptDate!,
          lastAttemptDate: stats.lastAttemptDate!,
        ));
      }

      logger.debug('✅ [RANKING_REPO] Created ${rankingEntries.length} group ranking entries');
      return rankingEntries;
    } catch (e, stackTrace) {
      logger.error('❌ [RANKING_REPO] Error fetching group ranking: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene la entrada del ranking de un usuario específico en un topic_group
  ///
  /// [topicGroupId] - ID del grupo de topics
  /// [userId] - ID del usuario
  ///
  /// Retorna la [GroupRankingEntry] del usuario o null si no ha completado todos los topics
  Future<GroupRankingEntry?> fetchUserGroupRankingEntry({
    required int topicGroupId,
    required int userId,
  }) async {
    try {
      logger.debug('📊 [RANKING_REPO] Fetching user group ranking for topic_group_id=$topicGroupId, user_id=$userId');

      final allRankings = await fetchGroupRanking(topicGroupId: topicGroupId);

      final userEntry = allRankings.where((entry) => entry.userId == userId).firstOrNull;

      if (userEntry == null) {
        logger.debug('⚠️ [RANKING_REPO] User has not completed all topics in group');
        return null;
      }

      logger.debug('✅ [RANKING_REPO] Found user group ranking entry: position ${userEntry.rankPosition}');
      return userEntry;
    } catch (e, stackTrace) {
      logger.error('❌ [RANKING_REPO] Error fetching user group ranking entry: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene el número total de participantes que completaron un topic_group
  Future<int> getTotalGroupParticipants({required int topicGroupId}) async {
    try {
      final rankings = await fetchGroupRanking(topicGroupId: topicGroupId);
      return rankings.length;
    } catch (e, stackTrace) {
      logger.error('❌ [RANKING_REPO] Error getting total group participants: $e');
      logger.debug('Stack trace: $stackTrace');
      return 0;
    }
  }
}

/// Clase helper para calcular estadísticas de usuario en un grupo
class _UserGroupStats {
  final int userId;
  final String username;
  final String? displayName;
  final String? profileImage;
  final String? firstName;
  final String? lastName;

  final Map<int, double> topicScores = {}; // topicId -> firstScore
  int totalAttempts = 0;
  DateTime? firstAttemptDate;
  DateTime? lastAttemptDate;

  _UserGroupStats({
    required this.userId,
    required this.username,
    this.displayName,
    this.profileImage,
    this.firstName,
    this.lastName,
  });

  double get averageScore {
    if (topicScores.isEmpty) return 0;
    final sum = topicScores.values.reduce((a, b) => a + b);
    return sum / topicScores.length;
  }
}
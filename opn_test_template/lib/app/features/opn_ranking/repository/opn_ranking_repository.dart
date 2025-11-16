import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../bootstrap.dart';
import '../model/opn_ranking_entry_model.dart';
import '../model/user_opn_index_current_model.dart';

class OpnRankingRepository {
  SupabaseClient get _supabaseClient => Supabase.instance.client;

  /// Número de items por página para paginación
  static const int pageSize = 20;

  /// Obtiene el ranking global OPN con paginación
  ///
  /// [page] - Número de página (empezando desde 0)
  /// [limit] - Cantidad de resultados por página (por defecto 20)
  ///
  /// Retorna una lista de [OpnRankingEntry] ordenada por opn_index descendente
  Future<List<OpnRankingEntry>> fetchOpnRanking({
    int page = 0,
    int limit = pageSize,
  }) async {
    try {
      logger.debug('📊 [OPN_RANKING_REPO] Fetching OPN ranking, page=$page, limit=$limit');

      final offset = page * limit;

      // Obtener el ranking más reciente de cada usuario
      // Usamos una subconsulta para obtener el calculated_at más reciente por usuario
      final response = await _supabaseClient
          .rpc('get_latest_opn_rankings', params: {
            'limit_count': limit,
            'offset_count': offset,
          });

      logger.debug('✅ [OPN_RANKING_REPO] Fetched ${response.length} ranking entries');

      return (response as List).map((json) {
        return OpnRankingEntry.fromJson(json as Map<String, dynamic>);
      }).toList();
    } catch (e, stackTrace) {
      logger.error('❌ [OPN_RANKING_REPO] Error fetching OPN ranking: $e');
      logger.debug('Stack trace: $stackTrace');

      // Fallback: intentar con query directa si el RPC no existe
      return _fetchOpnRankingFallback(page: page, limit: limit);
    }
  }

  /// Fallback method usando vista user_opn_index_current
  Future<List<OpnRankingEntry>> _fetchOpnRankingFallback({
    required int page,
    required int limit,
  }) async {
    try {
      logger.debug('📊 [OPN_RANKING_REPO] Using fallback method with user_opn_index_current');

      final offset = page * limit;

      // Obtener datos de la vista user_opn_index_current y hacer JOIN con users
      final response = await _supabaseClient
          .from('user_opn_index_current')
          .select('''
            user_id,
            opn_index,
            quality_trend_score,
            recent_activity_score,
            competitive_score,
            momentum_score,
            global_rank,
            calculated_at,
            users:user_id (
              username,
              display_name,
              profile_image,
              first_name,
              last_name
            )
          ''')
          .order('global_rank', ascending: true)
          .range(offset, offset + limit - 1);

      logger.debug('✅ [OPN_RANKING_REPO] Fetched ${response.length} ranking entries (fallback)');

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

        return OpnRankingEntry.fromJson(flattenedJson);
      }).toList();
    } catch (e, stackTrace) {
      logger.error('❌ [OPN_RANKING_REPO] Error in fallback method: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene la entrada del ranking de un usuario específico desde user_opn_index_current
  ///
  /// [userId] - ID del usuario
  ///
  /// Retorna la [OpnRankingEntry] actual del usuario o null si no existe
  Future<OpnRankingEntry?> fetchUserRankingEntry({
    required int userId,
  }) async {
    try {
      logger.debug('📊 [OPN_RANKING_REPO] Fetching user ranking for user_id=$userId');

      // Obtener el registro del usuario desde la vista
      final response = await _supabaseClient
          .from('user_opn_index_current')
          .select('''
            user_id,
            opn_index,
            quality_trend_score,
            recent_activity_score,
            competitive_score,
            momentum_score,
            global_rank,
            calculated_at,
            users:user_id (
              username,
              display_name,
              profile_image,
              first_name,
              last_name
            )
          ''')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        logger.debug('⚠️ [OPN_RANKING_REPO] No ranking entry found for user');
        return null;
      }

      final userData = response['users'] as Map<String, dynamic>;
      final flattenedJson = {
        ...response,
        'username': userData['username'],
        'display_name': userData['display_name'],
        'profile_image': userData['profile_image'],
        'first_name': userData['first_name'],
        'last_name': userData['last_name'],
      };
      flattenedJson.remove('users');

      logger.debug('✅ [OPN_RANKING_REPO] Found user ranking entry');
      return OpnRankingEntry.fromJson(flattenedJson);
    } catch (e, stackTrace) {
      logger.error('❌ [OPN_RANKING_REPO] Error fetching user ranking entry: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene el número total de participantes en el ranking OPN
  Future<int> getTotalParticipants() async {
    try {
      // Contar usuarios en la vista user_opn_index_current
      final response = await _supabaseClient
          .from('user_opn_index_current')
          .select('user_id')
          .count();

      return response.count;
    } catch (e, stackTrace) {
      logger.error('❌ [OPN_RANKING_REPO] Error getting total participants: $e');
      logger.debug('Stack trace: $stackTrace');
      return 0;
    }
  }

  /// Obtiene los mejores N usuarios del ranking OPN desde user_opn_index_current
  ///
  /// [limit] - Número de mejores usuarios a obtener (por defecto 10)
  ///
  /// Retorna una lista de [OpnRankingEntry] con los mejores índices OPN
  Future<List<OpnRankingEntry>> getTopScores({
    int limit = 10,
  }) async {
    try {
      logger.debug('🏆 [OPN_RANKING_REPO] Fetching top $limit scores');

      final response = await _supabaseClient
          .from('user_opn_index_current')
          .select('''
            user_id,
            opn_index,
            quality_trend_score,
            recent_activity_score,
            competitive_score,
            momentum_score,
            global_rank,
            calculated_at,
            users:user_id (
              username,
              display_name,
              profile_image,
              first_name,
              last_name
            )
          ''')
          .order('global_rank', ascending: true)
          .limit(limit);

      logger.debug('✅ [OPN_RANKING_REPO] Fetched ${response.length} top scores');

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

        return OpnRankingEntry.fromJson(flattenedJson);
      }).toList();
    } catch (e, stackTrace) {
      logger.error('❌ [OPN_RANKING_REPO] Error fetching top scores: $e');
      logger.debug('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Verifica si hay más páginas disponibles
  Future<bool> hasMorePages({
    required int currentPage,
    int limit = pageSize,
  }) async {
    try {
      final totalParticipants = await getTotalParticipants();
      final totalPages = (totalParticipants / limit).ceil();
      return currentPage < totalPages - 1;
    } catch (e) {
      logger.error('❌ [OPN_RANKING_REPO] Error checking for more pages: $e');
      return false;
    }
  }
}
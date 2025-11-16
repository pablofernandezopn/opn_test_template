import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/streak_data_model.dart';
import '../model/week_day_activity_model.dart';
import '../../../../bootstrap.dart';

class StreakRepository {
  final SupabaseClient _supabase;

  StreakRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Obtiene los datos completos de racha del usuario
  /// Utiliza la función RPC get_user_streak_data de la base de datos
  Future<StreakData> getUserStreakData(int userId) async {
    try {
      final response = await _supabase.rpc(
        'get_user_streak_data',
        params: {'p_user_id': userId},
      );

      if (response == null) {
        return StreakData.empty(userId);
      }

      // La respuesta viene como JSON desde la función PL/pgSQL
      return StreakData.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      logger.error('❌ [STREAK_REPO] Error fetching user streak data: $e');
      rethrow;
    }
  }

  /// Obtiene solo la actividad de la semana actual
  Future<List<WeekDayActivity>> getWeekActivity(int userId) async {
    try {
      final response = await _supabase.rpc(
        'get_week_activity',
        params: {'p_user_id': userId},
      ) as List<dynamic>;

      return response
          .map((activity) => WeekDayActivity.fromJson(activity as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.error('❌ [STREAK_REPO] Error fetching week activity: $e');
      rethrow;
    }
  }

  /// Obtiene los datos de racha desde la tabla users directamente
  /// Alternativa más rápida si solo necesitas current_streak y longest_streak
  Future<Map<String, dynamic>> getUserStreakSimple(int userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('current_streak, longest_streak, last_activity_date, streak_updated_at')
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      logger.error('❌ [STREAK_REPO] Error fetching simple user streak: $e');
      rethrow;
    }
  }

  /// Recalcula manualmente la racha del usuario
  /// Útil para sincronizar o corregir datos si es necesario
  Future<Map<String, dynamic>> recalculateUserStreak(int userId) async {
    try {
      final response = await _supabase.rpc(
        'calculate_user_streak',
        params: {'p_user_id': userId},
      );

      if (response is List && response.isNotEmpty) {
        final streakInfo = response.first as Map<String, dynamic>;

        // Actualizar en la tabla users
        await _supabase.from('users').update({
          'current_streak': streakInfo['current_streak'],
          'longest_streak': streakInfo['longest_streak'],
          'last_activity_date': streakInfo['last_activity_date'],
          'streak_updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);

        return streakInfo;
      }

      return {
        'current_streak': 0,
        'longest_streak': 0,
        'last_activity_date': null,
      };
    } catch (e) {
      logger.error('❌ [STREAK_REPO] Error recalculating user streak: $e');
      rethrow;
    }
  }

  /// Obtiene la vista de estadísticas de racha con badges
  Future<Map<String, dynamic>> getUserStreakStats(int userId) async {
    try {
      final response = await _supabase
          .from('user_streak_stats')
          .select()
          .eq('user_id', userId)
          .single();

      return response;
    } catch (e) {
      logger.error('❌ [STREAK_REPO] Error fetching user streak stats: $e');
      rethrow;
    }
  }

  /// Obtiene la actividad diaria detallada de un rango de fechas
  Future<List<Map<String, dynamic>>> getDailyActivity({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('user_daily_activity')
          .select()
          .eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('activity_date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('activity_date', endDate.toIso8601String());
      }

      // Aplicar el order después de los filtros
      final response = await query.order('activity_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logger.error('❌ [STREAK_REPO] Error fetching daily activity: $e');
      rethrow;
    }
  }

  /// Stream para escuchar cambios en la racha del usuario en tiempo real
  Stream<StreakData> watchUserStreakData(int userId) {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .asyncMap((rows) async {
          if (rows.isEmpty) return StreakData.empty(userId);

          final userData = rows.first;
          final weekActivity = await getWeekActivity(userId);

          return StreakData(
            userId: userId,
            currentStreak: userData['current_streak'] as int? ?? 0,
            longestStreak: userData['longest_streak'] as int? ?? 0,
            lastActivityDate: userData['last_activity_date'] != null
                ? DateTime.parse(userData['last_activity_date'] as String)
                : null,
            streakUpdatedAt: userData['streak_updated_at'] != null
                ? DateTime.parse(userData['streak_updated_at'] as String)
                : null,
            completedToday: userData['last_activity_date'] != null
                ? DateTime.parse(userData['last_activity_date'] as String)
                        .isAtSameMomentAs(DateTime.now()) ||
                    DateTime.parse(userData['last_activity_date'] as String)
                            .year ==
                        DateTime.now().year &&
                    DateTime.parse(userData['last_activity_date'] as String)
                            .month ==
                        DateTime.now().month &&
                    DateTime.parse(userData['last_activity_date'] as String)
                            .day ==
                        DateTime.now().day
                : false,
            weekActivity: weekActivity,
          );
        });
  }

  /// Obtiene el top de usuarios con mejores rachas
  Future<List<Map<String, dynamic>>> getTopStreaks({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id, username, current_streak, longest_streak, profile_image')
          .eq('deleted', false)
          .order('current_streak', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logger.error('❌ [STREAK_REPO] Error fetching top streaks: $e');
      rethrow;
    }
  }
}

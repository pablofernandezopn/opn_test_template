import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bootstrap.dart';
import '../repository/stats_repository.dart';
import 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final StatsRepository _repository;
  final int userId;

  StatsCubit(this._repository, {required this.userId}) : super(StatsState.initial());

  /// Carga las estadísticas completas del usuario
  ///
  /// [forceRefresh] - Si es true, ignora el caché y recarga los datos
  Future<void> loadStats({bool forceRefresh = false}) async {
    try {
      // Si los datos están frescos y no es un refresh forzado, no hacer nada
      if (!forceRefresh && state.isDataFresh) {
        logger.debug('📊 [STATS_CUBIT] Using cached stats');
        return;
      }

      emit(state.copyWith(status: StatsStatus.loading));

      logger.debug('📊 [STATS_CUBIT] Loading stats for user_id=$userId');

      // Cargar estadísticas globales y por topic en paralelo
      final (globalStats, topicStats) = await _repository.getCompleteStats(
        userId: userId,
      );

      logger.debug('✅ [STATS_CUBIT] Loaded ${topicStats.length} topic stats');

      emit(state.copyWith(
        status: StatsStatus.success,
        globalStats: globalStats,
        topicStats: topicStats,
        errorMessage: null,
        lastUpdated: DateTime.now(),
      ));
    } catch (e, stackTrace) {
      logger.error('❌ [STATS_CUBIT] Error loading stats: $e');
      logger.debug('Stack trace: $stackTrace');

      emit(state.copyWith(
        status: StatsStatus.error,
        errorMessage: 'Error al cargar las estadísticas: ${e.toString()}',
      ));
    }
  }

  /// Carga los datos de evolución para gráficos
  ///
  /// [days] - Número de días hacia atrás
  Future<void> loadEvolution({int days = 30}) async {
    try {
      logger.debug('📊 [STATS_CUBIT] Loading evolution data for $days days');

      final evolutionData = await _repository.getMockEvolution(
        userId: userId,
        days: days,
      );

      logger.debug('✅ [STATS_CUBIT] Loaded ${evolutionData.length} data points');

      emit(state.copyWith(
        evolutionData: evolutionData,
      ));
    } catch (e, stackTrace) {
      logger.error('❌ [STATS_CUBIT] Error loading evolution: $e');
      logger.debug('Stack trace: $stackTrace');
    }
  }

  /// Carga los datos de progreso/mejora
  Future<void> loadProgress() async {
    try {
      logger.debug('📊 [STATS_CUBIT] Loading progress data');

      final progressData = await _repository.getMockProgress(
        userId: userId,
      );

      logger.debug('✅ [STATS_CUBIT] Loaded ${progressData.length} progress items');

      emit(state.copyWith(
        progressData: progressData,
      ));
    } catch (e, stackTrace) {
      logger.error('❌ [STATS_CUBIT] Error loading progress: $e');
      logger.debug('Stack trace: $stackTrace');
    }
  }

  /// Carga la comparación con el promedio para un topic específico
  Future<void> loadTopicComparison({required int topicId}) async {
    try {
      logger.debug('📊 [STATS_CUBIT] Loading comparison for topic_id=$topicId');

      final comparisonData = await _repository.getTopicComparison(
        userId: userId,
        topicId: topicId,
      );

      logger.debug('✅ [STATS_CUBIT] Loaded comparison data');

      emit(state.copyWith(
        comparisonData: comparisonData,
        selectedTopicId: topicId,
      ));
    } catch (e, stackTrace) {
      logger.error('❌ [STATS_CUBIT] Error loading comparison: $e');
      logger.debug('Stack trace: $stackTrace');
    }
  }

  /// Carga la evolución por topic_type
  Future<void> loadEvolutionByTopicType() async {
    try {
      logger.debug('📊 [STATS_CUBIT] Loading evolution by topic_type');

      final evolutionByTopicType = await _repository.getEvolutionByTopicType(
        userId: userId,
      );

      logger.debug('✅ [STATS_CUBIT] Loaded ${evolutionByTopicType.length} topic_types');

      emit(state.copyWith(
        evolutionByTopicType: evolutionByTopicType,
      ));
    } catch (e, stackTrace) {
      logger.error('❌ [STATS_CUBIT] Error loading evolution by topic_type: $e');
      logger.debug('Stack trace: $stackTrace');
    }
  }

  /// Refresca todas las estadísticas
  Future<void> refresh() async {
    await loadStats(forceRefresh: true);
  }

  /// Limpia el estado
  void clear() {
    emit(StatsState.initial());
  }
}
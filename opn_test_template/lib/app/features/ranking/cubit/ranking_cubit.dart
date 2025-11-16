import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bootstrap.dart';
import '../model/ranking_entry_model.dart';
import '../repository/ranking_repository.dart';
import 'ranking_state.dart';

class RankingCubit extends Cubit<RankingState> {
  final RankingRepository _repository;
  final int? userId;

  RankingCubit(
    this._repository, {
    this.userId,
  }) : super(RankingState.initial());

  /// Carga el ranking inicial de un topic
  Future<void> loadTopicRanking({
    required int topicId,
    bool refresh = false,
  }) async {
    try {
      // Si ya estamos cargando o es un refresh, resetear el estado
      if (refresh || state.topicId != topicId) {
        emit(RankingState.initial().copyWith(
          status: RankingStatus.loading,
          topicId: topicId,
        ));
      } else if (state.isLoading) {
        // Ya está cargando, no hacer nada
        return;
      }

      logger.debug('📊 [RANKING_CUBIT] Loading ranking for topic_id=$topicId');

      // Cargar la primera página del ranking
      final entries = await _repository.fetchTopicRanking(
        topicId: topicId,
        page: 0,
      );

      // Obtener total de participantes
      final totalParticipants = await _repository.getTotalParticipants(
        topicId: topicId,
      );

      // Si el usuario está autenticado, obtener su entrada
      RankingEntry? userEntry;
      if (userId != null) {
        userEntry = await _repository.fetchUserRankingEntry(
          topicId: topicId,
          userId: userId!,
        );
      }

      // Verificar si hay más páginas
      final hasMore = entries.length >= RankingRepository.pageSize;

      logger.debug('✅ [RANKING_CUBIT] Loaded ${entries.length} entries, total participants: $totalParticipants');

      emit(state.copyWith(
        entries: entries,
        userEntry: userEntry,
        status: RankingStatus.success,
        currentPage: 0,
        hasMore: hasMore,
        totalParticipants: totalParticipants,
        topicId: topicId,
        errorMessage: null,
      ));
    } catch (e, stackTrace) {
      logger.error('❌ [RANKING_CUBIT] Error loading ranking: $e');
      logger.debug('Stack trace: $stackTrace');

      emit(state.copyWith(
        status: RankingStatus.error,
        errorMessage: 'Error al cargar el ranking: ${e.toString()}',
      ));
    }
  }

  /// Carga la siguiente página del ranking
  Future<void> loadMoreEntries() async {
    // Verificar que podemos cargar más
    if (!state.canLoadMore || state.topicId == null) {
      logger.debug('⚠️ [RANKING_CUBIT] Cannot load more entries');
      return;
    }

    try {
      emit(state.copyWith(status: RankingStatus.loadingMore));

      final nextPage = state.currentPage + 1;
      logger.debug('📊 [RANKING_CUBIT] Loading more entries, page=$nextPage');

      final newEntries = await _repository.fetchTopicRanking(
        topicId: state.topicId!,
        page: nextPage,
      );

      // Si no hay nuevas entradas, no hay más páginas
      final hasMore = newEntries.length >= RankingRepository.pageSize;

      logger.debug('✅ [RANKING_CUBIT] Loaded ${newEntries.length} more entries');

      emit(state.copyWith(
        entries: [...state.entries, ...newEntries],
        currentPage: nextPage,
        hasMore: hasMore,
        status: RankingStatus.success,
      ));
    } catch (e, stackTrace) {
      logger.error('❌ [RANKING_CUBIT] Error loading more entries: $e');
      logger.debug('Stack trace: $stackTrace');

      // No cambiar el status a error, solo registrar el error
      // El usuario puede seguir viendo los datos que ya tiene
      emit(state.copyWith(
        status: RankingStatus.success,
        errorMessage: 'Error al cargar más entradas',
      ));
    }
  }

  /// Carga el ranking de un grupo de topics
  Future<void> loadTopicGroupRanking({
    required int topicGroupId,
    bool refresh = false,
  }) async {
    try {
      if (refresh || state.topicGroupId != topicGroupId) {
        emit(RankingState.initial().copyWith(
          status: RankingStatus.loading,
          topicGroupId: topicGroupId,
        ));
      } else if (state.isLoading) {
        return;
      }

      logger.debug('📊 [RANKING_CUBIT] Loading ranking for topic_group_id=$topicGroupId');

      final entries = await _repository.fetchTopicGroupRanking(
        topicGroupId: topicGroupId,
        page: 0,
      );

      final hasMore = entries.length >= RankingRepository.pageSize;

      logger.debug('✅ [RANKING_CUBIT] Loaded ${entries.length} entries for group');

      emit(state.copyWith(
        entries: entries,
        status: RankingStatus.success,
        currentPage: 0,
        hasMore: hasMore,
        topicGroupId: topicGroupId,
        errorMessage: null,
      ));
    } catch (e, stackTrace) {
      logger.error('❌ [RANKING_CUBIT] Error loading group ranking: $e');
      logger.debug('Stack trace: $stackTrace');

      emit(state.copyWith(
        status: RankingStatus.error,
        errorMessage: 'Error al cargar el ranking del grupo: ${e.toString()}',
      ));
    }
  }

  /// Refresca el ranking actual
  Future<void> refresh() async {
    if (state.topicId != null) {
      await loadTopicRanking(
        topicId: state.topicId!,
        refresh: true,
      );
    } else if (state.topicGroupId != null) {
      await loadTopicGroupRanking(
        topicGroupId: state.topicGroupId!,
        refresh: true,
      );
    }
  }

  /// Obtiene el top N de puntuaciones
  Future<void> loadTopScores({
    required int topicId,
    int limit = 10,
  }) async {
    try {
      emit(state.copyWith(
        status: RankingStatus.loading,
        topicId: topicId,
      ));

      logger.debug('🏆 [RANKING_CUBIT] Loading top $limit scores for topic_id=$topicId');

      final entries = await _repository.getTopScores(
        topicId: topicId,
        limit: limit,
      );

      // Obtener entrada del usuario si está autenticado
      RankingEntry? userEntry;
      if (userId != null) {
        userEntry = await _repository.fetchUserRankingEntry(
          topicId: topicId,
          userId: userId!,
        );
      }

      logger.debug('✅ [RANKING_CUBIT] Loaded ${entries.length} top scores');

      emit(state.copyWith(
        entries: entries,
        userEntry: userEntry,
        status: RankingStatus.success,
        hasMore: false, // No hay paginación en top scores
        topicId: topicId,
        errorMessage: null,
      ));
    } catch (e, stackTrace) {
      logger.error('❌ [RANKING_CUBIT] Error loading top scores: $e');
      logger.debug('Stack trace: $stackTrace');

      emit(state.copyWith(
        status: RankingStatus.error,
        errorMessage: 'Error al cargar las mejores puntuaciones: ${e.toString()}',
      ));
    }
  }

  /// Limpia el estado
  void clear() {
    emit(RankingState.initial());
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bootstrap.dart';
import '../model/opn_ranking_entry_model.dart';
import '../repository/opn_ranking_repository.dart';
import 'opn_ranking_state.dart';

class OpnRankingCubit extends Cubit<OpnRankingState> {
  final OpnRankingRepository _repository;
  final int? userId;

  OpnRankingCubit(
    this._repository, {
    this.userId,
  }) : super(OpnRankingState.initial());

  /// Carga el ranking global OPN
  Future<void> loadOpnRanking({
    bool refresh = false,
  }) async {
    try {
      // Si ya estamos cargando o es un refresh, resetear el estado
      if (refresh) {
        emit(OpnRankingState.initial().copyWith(
          status: OpnRankingStatus.loading,
        ));
      } else if (state.isLoading) {
        // Ya está cargando, no hacer nada
        return;
      }

      logger.debug('📊 [OPN_RANKING_CUBIT] Loading OPN ranking');

      // Cargar la primera página del ranking
      final entries = await _repository.fetchOpnRanking(page: 0);

      // Obtener total de participantes
      final totalParticipants = await _repository.getTotalParticipants();

      // Si el usuario está autenticado, obtener su entrada
      OpnRankingEntry? userEntry;
      if (userId != null) {
        userEntry = await _repository.fetchUserRankingEntry(userId: userId!);
      }

      // Verificar si hay más páginas
      final hasMore = entries.length >= OpnRankingRepository.pageSize;

      logger.debug('✅ [OPN_RANKING_CUBIT] Loaded ${entries.length} entries, total participants: $totalParticipants');

      emit(state.copyWith(
        entries: entries,
        userEntry: userEntry,
        status: OpnRankingStatus.success,
        currentPage: 0,
        hasMore: hasMore,
        totalParticipants: totalParticipants,
        errorMessage: null,
      ));
    } catch (e, stackTrace) {
      logger.error('❌ [OPN_RANKING_CUBIT] Error loading ranking: $e');
      logger.debug('Stack trace: $stackTrace');

      emit(state.copyWith(
        status: OpnRankingStatus.error,
        errorMessage: 'Error al cargar el ranking: ${e.toString()}',
      ));
    }
  }

  /// Carga la siguiente página del ranking
  Future<void> loadMoreEntries() async {
    // Verificar que podemos cargar más
    if (!state.canLoadMore) {
      logger.debug('⚠️ [OPN_RANKING_CUBIT] Cannot load more entries');
      return;
    }

    try {
      emit(state.copyWith(status: OpnRankingStatus.loadingMore));

      final nextPage = state.currentPage + 1;
      logger.debug('📊 [OPN_RANKING_CUBIT] Loading more entries, page=$nextPage');

      final newEntries = await _repository.fetchOpnRanking(page: nextPage);

      // Si no hay nuevas entradas, no hay más páginas
      final hasMore = newEntries.length >= OpnRankingRepository.pageSize;

      logger.debug('✅ [OPN_RANKING_CUBIT] Loaded ${newEntries.length} more entries');

      emit(state.copyWith(
        entries: [...state.entries, ...newEntries],
        currentPage: nextPage,
        hasMore: hasMore,
        status: OpnRankingStatus.success,
      ));
    } catch (e, stackTrace) {
      logger.error('❌ [OPN_RANKING_CUBIT] Error loading more entries: $e');
      logger.debug('Stack trace: $stackTrace');

      // No cambiar el status a error, solo registrar el error
      // El usuario puede seguir viendo los datos que ya tiene
      emit(state.copyWith(
        status: OpnRankingStatus.success,
        errorMessage: 'Error al cargar más entradas',
      ));
    }
  }

  /// Refresca el ranking actual
  Future<void> refresh() async {
    await loadOpnRanking(refresh: true);
  }

  /// Obtiene el top N de puntuaciones
  Future<void> loadTopScores({
    int limit = 10,
  }) async {
    try {
      emit(state.copyWith(status: OpnRankingStatus.loading));

      logger.debug('🏆 [OPN_RANKING_CUBIT] Loading top $limit scores');

      final entries = await _repository.getTopScores(limit: limit);

      // Obtener entrada del usuario si está autenticado
      OpnRankingEntry? userEntry;
      if (userId != null) {
        userEntry = await _repository.fetchUserRankingEntry(userId: userId!);
      }

      logger.debug('✅ [OPN_RANKING_CUBIT] Loaded ${entries.length} top scores');

      emit(state.copyWith(
        entries: entries,
        userEntry: userEntry,
        status: OpnRankingStatus.success,
        hasMore: false, // No hay paginación en top scores
        errorMessage: null,
      ));
    } catch (e, stackTrace) {
      logger.error('❌ [OPN_RANKING_CUBIT] Error loading top scores: $e');
      logger.debug('Stack trace: $stackTrace');

      emit(state.copyWith(
        status: OpnRankingStatus.error,
        errorMessage: 'Error al cargar las mejores puntuaciones: ${e.toString()}',
      ));
    }
  }

  /// Limpia el estado
  void clear() {
    emit(OpnRankingState.initial());
  }
}
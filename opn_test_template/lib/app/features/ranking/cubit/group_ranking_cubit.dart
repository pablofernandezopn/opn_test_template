import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bootstrap.dart';
import '../model/group_ranking_entry_model.dart';
import '../repository/ranking_repository.dart';
import 'group_ranking_state.dart';

class GroupRankingCubit extends Cubit<GroupRankingState> {
  final RankingRepository _repository;
  final int? userId;

  GroupRankingCubit(
    this._repository, {
    this.userId,
  }) : super(GroupRankingState.initial());

  /// Carga el ranking consolidado de un topic_group
  ///
  /// Este método carga TODOS los rankings de una vez y luego implementa
  /// paginación en memoria para el scroll infinito.
  Future<void> loadGroupRanking({
    required int topicGroupId,
    bool refresh = false,
  }) async {
    try {
      // Si ya estamos cargando o es un refresh, resetear el estado
      if (refresh || state.topicGroupId != topicGroupId) {
        emit(GroupRankingState.initial().copyWith(
          status: GroupRankingStatus.loading,
          topicGroupId: topicGroupId,
        ));
      } else if (state.isLoading) {
        // Ya está cargando, no hacer nada
        return;
      }

      logger.debug('📊 [GROUP_RANKING_CUBIT] Loading group ranking for topic_group_id=$topicGroupId');

      // Cargar TODOS los rankings del grupo
      final allEntries = await _repository.fetchGroupRanking(
        topicGroupId: topicGroupId,
      );

      // Obtener entrada del usuario si está autenticado
      GroupRankingEntry? userEntry;
      if (userId != null) {
        userEntry = allEntries.where((entry) => entry.userId == userId).firstOrNull;
      }

      // Calcular la primera página para mostrar
      final firstPageSize = state.pageSize;
      final displayedEntries = allEntries.take(firstPageSize).toList();

      logger.debug('✅ [GROUP_RANKING_CUBIT] Loaded ${allEntries.length} total entries, displaying first ${displayedEntries.length}');

      emit(state.copyWith(
        allEntries: allEntries,
        displayedEntries: displayedEntries,
        userEntry: userEntry,
        status: GroupRankingStatus.success,
        currentDisplayIndex: displayedEntries.length,
        totalParticipants: allEntries.length,
        topicGroupId: topicGroupId,
        errorMessage: null,
      ));
    } catch (e, stackTrace) {
      logger.error('❌ [GROUP_RANKING_CUBIT] Error loading group ranking: $e');
      logger.debug('Stack trace: $stackTrace');

      emit(state.copyWith(
        status: GroupRankingStatus.error,
        errorMessage: 'Error al cargar el ranking del grupo: ${e.toString()}',
      ));
    }
  }

  /// Carga más entradas para el scroll infinito (paginación en memoria)
  Future<void> loadMoreEntries() async {
    // Verificar que podemos cargar más
    if (!state.canLoadMore) {
      logger.debug('⚠️ [GROUP_RANKING_CUBIT] Cannot load more entries');
      return;
    }

    try {
      emit(state.copyWith(status: GroupRankingStatus.loadingMore));

      // Simular un pequeño delay para UX (opcional)
      await Future.delayed(const Duration(milliseconds: 100));

      final currentIndex = state.currentDisplayIndex;
      final nextPageSize = state.pageSize;
      final endIndex = (currentIndex + nextPageSize).clamp(0, state.allEntries.length);

      // Obtener la siguiente página de la lista en memoria
      final newEntries = state.allEntries.sublist(currentIndex, endIndex);

      logger.debug('📊 [GROUP_RANKING_CUBIT] Loading more entries: $currentIndex to $endIndex');

      emit(state.copyWith(
        displayedEntries: [...state.displayedEntries, ...newEntries],
        currentDisplayIndex: endIndex,
        status: GroupRankingStatus.success,
      ));

      logger.debug('✅ [GROUP_RANKING_CUBIT] Now displaying ${state.displayedEntries.length} of ${state.allEntries.length} entries');
    } catch (e, stackTrace) {
      logger.error('❌ [GROUP_RANKING_CUBIT] Error loading more entries: $e');
      logger.debug('Stack trace: $stackTrace');

      // No cambiar el status a error, solo registrar
      emit(state.copyWith(
        status: GroupRankingStatus.success,
        errorMessage: 'Error al cargar más entradas',
      ));
    }
  }

  /// Refresca el ranking actual
  Future<void> refresh() async {
    if (state.topicGroupId != null) {
      await loadGroupRanking(
        topicGroupId: state.topicGroupId!,
        refresh: true,
      );
    }
  }

  /// Limpia el estado
  void clear() {
    emit(GroupRankingState.initial());
  }
}
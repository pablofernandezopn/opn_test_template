import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/ranking_entry_model.dart';

part 'ranking_state.freezed.dart';

enum RankingStatus { initial, loading, loadingMore, success, error }

@freezed
class RankingState with _$RankingState {
  const factory RankingState({
    /// Lista de entradas del ranking
    @Default([]) List<RankingEntry> entries,

    /// Entrada del usuario actual (si participa en el ranking)
    RankingEntry? userEntry,

    /// Estado actual de la carga
    @Default(RankingStatus.initial) RankingStatus status,

    /// Página actual (para paginación)
    @Default(0) int currentPage,

    /// Indica si hay más páginas disponibles
    @Default(true) bool hasMore,

    /// Total de participantes en el ranking
    @Default(0) int totalParticipants,

    /// Mensaje de error (si hay)
    String? errorMessage,

    /// ID del topic actual
    int? topicId,

    /// ID del grupo de topics (si aplica)
    int? topicGroupId,
  }) = _RankingState;

  const RankingState._();

  /// Helper para crear estado inicial
  factory RankingState.initial() => const RankingState();

  /// Verifica si está en estado de carga
  bool get isLoading => status == RankingStatus.loading;

  /// Verifica si está cargando más datos
  bool get isLoadingMore => status == RankingStatus.loadingMore;

  /// Verifica si tiene datos
  bool get hasData => entries.isNotEmpty;

  /// Verifica si está en estado de error
  bool get hasError => status == RankingStatus.error;

  /// Verifica si puede cargar más páginas
  bool get canLoadMore => hasMore && !isLoadingMore && !isLoading;
}
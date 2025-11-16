import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/opn_ranking_entry_model.dart';

part 'opn_ranking_state.freezed.dart';

enum OpnRankingStatus { initial, loading, loadingMore, success, error }

@freezed
class OpnRankingState with _$OpnRankingState {
  const factory OpnRankingState({
    /// Lista de entradas del ranking OPN
    @Default([]) List<OpnRankingEntry> entries,

    /// Entrada del usuario actual (si tiene índice OPN)
    OpnRankingEntry? userEntry,

    /// Estado actual de la carga
    @Default(OpnRankingStatus.initial) OpnRankingStatus status,

    /// Página actual (para paginación)
    @Default(0) int currentPage,

    /// Indica si hay más páginas disponibles
    @Default(true) bool hasMore,

    /// Total de participantes en el ranking
    @Default(0) int totalParticipants,

    /// Mensaje de error (si hay)
    String? errorMessage,
  }) = _OpnRankingState;

  const OpnRankingState._();

  /// Helper para crear estado inicial
  factory OpnRankingState.initial() => const OpnRankingState();

  /// Verifica si está en estado de carga
  bool get isLoading => status == OpnRankingStatus.loading;

  /// Verifica si está cargando más datos
  bool get isLoadingMore => status == OpnRankingStatus.loadingMore;

  /// Verifica si tiene datos
  bool get hasData => entries.isNotEmpty;

  /// Verifica si está en estado de error
  bool get hasError => status == OpnRankingStatus.error;

  /// Verifica si puede cargar más páginas
  bool get canLoadMore => hasMore && !isLoadingMore && !isLoading;
}
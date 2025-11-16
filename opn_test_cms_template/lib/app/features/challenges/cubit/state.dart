import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/challenge_model.dart';

part 'state.freezed.dart';

/// Enum para representar los estados de las operaciones
enum StatusNames { loading, done, error }

/// Clase Status para manejar estados de operaciones asíncronas
class Status {
  final StatusNames status;
  final String message;

  Status({
    required this.status,
    String? message,
  }) : message = message ?? '';

  // Factory methods
  factory Status.loading([String? message]) =>
      Status(status: StatusNames.loading, message: message);

  factory Status.done([String? message]) =>
      Status(status: StatusNames.done, message: message);

  factory Status.error([String? message]) =>
      Status(status: StatusNames.error, message: message);

  // Getters de conveniencia
  bool get isLoading => status == StatusNames.loading;
  bool get isDone => status == StatusNames.done;
  bool get isError => status == StatusNames.error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Status &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          message == other.message;

  @override
  int get hashCode => status.hashCode ^ message.hashCode;

  @override
  String toString() => 'Status(status: $status, message: $message)';
}

/// Estado del ChallengeCubit
@freezed
class ChallengeState with _$ChallengeState {
  const factory ChallengeState({
    /// Lista de impugnaciones cargadas
    @Default([]) List<Challenge> challenges,

    /// Impugnaciones pendientes (filtrado rápido)
    @Default([]) List<Challenge> pendingChallenges,

    /// Impugnación seleccionada en la tabla
    Challenge? selectedChallenge,

    /// Filtro actual de estado
    ChallengeStatus? statusFilter,

    /// Filtro de academia
    int? academyFilter,

    /// Término de búsqueda
    @Default('') String searchQuery,

    /// Estadísticas por estado
    @Default({}) Map<String, int> stats,

    /// Estado de la carga inicial de impugnaciones
    required Status fetchStatus,

    /// Estado de la creación de impugnación
    required Status createStatus,

    /// Estado de la actualización de impugnación
    required Status updateStatus,

    /// Estado de la eliminación de impugnación
    required Status deleteStatus,

    /// Estado del cambio de estado (aprobar/rechazar)
    required Status statusChangeStatus,

    /// Estado de la carga de estadísticas
    required Status statsStatus,

    /// Mensaje de error general
    String? error,

    // ============================================
    // Campos para paginación
    // ============================================

    /// Página actual (para paginación)
    @Default(0) int currentPage,

    /// Tamaño de página
    @Default(20) int pageSize,

    /// Indica si hay más datos para cargar
    @Default(true) bool hasMore,

    /// Indica si se está cargando más datos
    @Default(false) bool isLoadingMore,
  }) = _ChallengeState;

  const ChallengeState._();

  /// Helper para crear estado inicial
  factory ChallengeState.initial() => ChallengeState(
        fetchStatus: Status.done(),
        createStatus: Status.done(),
        updateStatus: Status.done(),
        deleteStatus: Status.done(),
        statusChangeStatus: Status.done(),
        statsStatus: Status.done(),
        error: null,
        currentPage: 0,
        pageSize: 20,
        hasMore: true,
        isLoadingMore: false,
      );

  /// Indica si hay alguna operación en curso
  bool get isLoading =>
      fetchStatus.isLoading ||
      createStatus.isLoading ||
      updateStatus.isLoading ||
      deleteStatus.isLoading ||
      statusChangeStatus.isLoading ||
      statsStatus.isLoading ||
      isLoadingMore;

  /// Indica si hay algún error en alguna operación
  bool get hasError =>
      fetchStatus.isError ||
      createStatus.isError ||
      updateStatus.isError ||
      deleteStatus.isError ||
      statusChangeStatus.isError ||
      statsStatus.isError;

  /// Obtiene el total de impugnaciones
  int get totalChallenges => challenges.length;

  /// Obtiene el total de impugnaciones pendientes
  int get totalPending => challenges.where((c) => c.state.isPending).length;

  /// Obtiene el total de impugnaciones aprobadas
  int get totalApproved => challenges.where((c) => c.state.isApproved).length;

  /// Obtiene el total de impugnaciones rechazadas
  int get totalRejected => challenges.where((c) => c.state.isRejected).length;

  /// Obtiene el contador de un estado específico
  int getCountForStatus(ChallengeStatus status) {
    return challenges.where((c) => c.state == status).length;
  }
}

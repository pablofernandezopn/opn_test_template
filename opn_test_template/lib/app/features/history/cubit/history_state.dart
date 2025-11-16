import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/user_test_model.dart';

part 'history_state.freezed.dart';

enum StatusNames { loading, done, error }

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

  // Necesario para Freezed
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

@freezed
class HistoryState with _$HistoryState {
  const factory HistoryState({
    @Default([]) List<UserTest> tests,
    @Default([]) List<UserTest> recentTests, // Los 3 más recientes para home
    required Status fetchHistoryStatus,
    required Status fetchRecentTestsStatus,
    required Status loadMoreStatus,
    int? selectedTopicTypeFilter, // Filtro por tipo de topic
    @Default(0) int currentPage,
    @Default(20) int pageSize,
    @Default(false) bool hasMore,
    String? error,
  }) = _HistoryState;

  const HistoryState._();

  // Helper para crear estado inicial
  factory HistoryState.initial() => HistoryState(
        fetchHistoryStatus: Status.done(),
        fetchRecentTestsStatus: Status.done(),
        loadMoreStatus: Status.done(),
        error: null,
      );
}
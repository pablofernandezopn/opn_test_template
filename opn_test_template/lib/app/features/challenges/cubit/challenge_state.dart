import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/challenge_model.dart';

part 'challenge_state.freezed.dart';

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
class ChallengeState with _$ChallengeState {
  const factory ChallengeState({
    @Default([]) List<Challenge> challenges,
    @Default(0) int currentPage,
    @Default(false) bool hasMoreData,
    required Status fetchChallengesStatus,
    required Status createChallengeStatus,
    required Status loadMoreStatus,
    String? error,
  }) = _ChallengeState;

  const ChallengeState._();

  // Helper para crear estado inicial
  factory ChallengeState.initial() => ChallengeState(
        fetchChallengesStatus: Status.done(),
        createChallengeStatus: Status.done(),
        loadMoreStatus: Status.done(),
        hasMoreData: true,
        error: null,
      );
}
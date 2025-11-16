import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:opn_test_guardia_civil_cms/app/features/memberships/model/membership_level_model.dart';

part 'state.freezed.dart';

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
class MembershipState with _$MembershipState {
  const factory MembershipState({
    @Default([]) List<MembershipLevel> membershipLevels,
    MembershipLevel? selectedMembershipLevel,
    required Status fetchMembershipLevelsStatus,
    required Status createMembershipLevelStatus,
    required Status updateMembershipLevelStatus,
    required Status deleteMembershipLevelStatus,
    required Status searchMembershipLevelsStatus,
    String? error,
    String? searchQuery,
    // Estadísticas
    @Default({}) Map<int, int> userCountByLevel,
    required Status fetchStatsStatus,
  }) = _MembershipState;

  const MembershipState._();

  // Helper para crear estado inicial
  factory MembershipState.initial() => MembershipState(
        fetchMembershipLevelsStatus: Status.done(),
        createMembershipLevelStatus: Status.done(),
        updateMembershipLevelStatus: Status.done(),
        deleteMembershipLevelStatus: Status.done(),
        searchMembershipLevelsStatus: Status.done(),
        fetchStatsStatus: Status.done(),
        error: null,
      );
}

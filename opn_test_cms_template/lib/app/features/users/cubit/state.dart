import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/model/user.dart';

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
class UserState with _$UserState {
  const factory UserState({
    @Default([]) List<User> users,
    User? selectedUser,
    required Status fetchUsersStatus,
    required Status createUserStatus,
    required Status updateUserStatus,
    required Status deleteUserStatus,
    required Status searchUsersStatus,
    String? error,
    String? searchQuery,
    // Nuevos campos para paginación
    @Default(0) int currentPage,
    @Default(20) int pageSize,
    @Default(true) bool hasMorePages,
    @Default(false) bool isLoadingMore,
  }) = _UserState;

  const UserState._();

  // Helper para crear estado inicial
  factory UserState.initial() => UserState(
        fetchUsersStatus: Status.done(),
        createUserStatus: Status.done(),
        updateUserStatus: Status.done(),
        deleteUserStatus: Status.done(),
        searchUsersStatus: Status.done(),
        error: null,
      );
}

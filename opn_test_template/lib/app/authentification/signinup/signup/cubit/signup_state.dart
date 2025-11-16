import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_state.freezed.dart';

@freezed
class SignUpState with _$SignUpState {
  const factory SignUpState({
    @Default(SignUpStatus.editing) SignUpStatus status,
    String? errorMessage,
    String? username,
    String? name,
    String? surname,
    String? email,
    String? password,
    String? phone,
    String? repeatedPassword,
    @Default(false) bool acceptPolicy,
  }) = _SignUpState;

  const SignUpState._();

  bool get isComplete =>
      (username?.isNotEmpty ?? false) &&
      (name?.isNotEmpty ?? false) &&
      (email?.isNotEmpty ?? false) &&
      (password?.isNotEmpty ?? false) &&
      (repeatedPassword?.isNotEmpty ?? false) &&
      (password == repeatedPassword) &&
      acceptPolicy;
}

enum SignUpStatus {
  editing,
  loading,
  done,
  error,
}

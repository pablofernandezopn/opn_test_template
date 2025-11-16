import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_state.freezed.dart';

enum SignInStatus {
  initial,
  editing,
  loading,
  done,
  error,
}

@freezed
class SignInState with _$SignInState {
  const factory SignInState({
    @Default(SignInStatus.initial) SignInStatus status,
    String? email,
    String? password,
    @Default(false) bool showPassword,
    String? errorMessage,
  }) = _SignInState;
}

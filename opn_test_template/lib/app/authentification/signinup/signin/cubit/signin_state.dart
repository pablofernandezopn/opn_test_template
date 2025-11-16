import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_state.freezed.dart';

@freezed
class SignInState with _$SignInState {
  const factory SignInState({
    @Default(SignInStatus.editing) SignInStatus status,
    String? email,
    String? password,
    String? errorMessage,
  }) = _SignInState;

  const SignInState._();

  bool get isComplete =>
      (email?.isNotEmpty ?? false) && (password?.isNotEmpty ?? false);
}

enum SignInStatus {
  editing,
  loading,
  done,
  error,
}

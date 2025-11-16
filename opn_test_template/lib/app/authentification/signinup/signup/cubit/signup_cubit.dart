import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_template/app/authentification/signinup/signup/cubit/signup_state.dart';

import '../../../../../bootstrap.dart';

import '../../../../config/preferences_service.dart';
import '../../../auth/model/wp_exception.dart';
import '../../../auth/repository/auth_repository.dart';


class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(
    this._preferences,
    this._authRepository,
  ) : super(const SignUpState());

  final AuthRepository _authRepository;

  final PreferencesService _preferences;

  void username(String? value) => emit(
        state.copyWith(status: SignUpStatus.editing, username: value?.trim()),
      );

  void name(String? value) => emit(
        state.copyWith(status: SignUpStatus.editing, name: value?.trim()),
      );

  void phone(String? value) =>
      emit(state.copyWith(status: SignUpStatus.editing, phone: value?.trim()));

  void surname(String? value) => emit(
        state.copyWith(status: SignUpStatus.editing, surname: value?.trim()),
      );

  void email(String? value) => emit(
        state.copyWith(status: SignUpStatus.editing, email: value?.trim()),
      );

  void password(String? value) => emit(
        state.copyWith(status: SignUpStatus.editing, password: value?.trim()),
      );

  void repeatedPassword(String? value) => emit(
        state.copyWith(
          status: SignUpStatus.editing,
          repeatedPassword: value?.trim(),
        ),
      );

  // ignore: avoid_positional_boolean_parameters
  void acceptPolicy(bool value) =>
      emit(state.copyWith(status: SignUpStatus.editing, acceptPolicy: value));

  bool isValidPhoneNumber(String phone) {
    return phone.length == 9;
  }

  Future<void> signUp() async {
    // Emit loading state
    emit(state.copyWith(status: SignUpStatus.loading));

    try {
      // Extract and validate required fields
      final name = state.name;
      final surname = state.surname;
      final username = state.username;
      final email = state.email;
      final password = state.password;
      final phone = state.phone;

      // Check for null values and emit error if any field is missing
      if ([name, surname, username, email, password, phone].contains(null)) {
        emit(state.copyWith(
          status: SignUpStatus.error,
          errorMessage: 'Todos los campos son obligatorios.',
        ));
        return;
      }
      // Validar el formato del número de teléfono
      if (!isValidPhoneNumber(phone!)) {
        emit(state.copyWith(
          status: SignUpStatus.error,
          errorMessage: 'El número de teléfono no es válido.',
        ));
        return;
      }
      // Attempt to sign up and sign in
      final token = await _authRepository.signUpAndSignIn(
          name: name!,
          surname: surname!,
          username: username!,
          email: email!,
          password: password!,
          phone: phone);

      if (token != null) {
        // Securely store the user token
        await _preferences.set('userGCToken', token);
        await _preferences.set('opnAppGCEmail', state.email!);
        await _preferences.set('opnAppGCPassWord', state.password!);


        emit(state.copyWith(status: SignUpStatus.done));
      } else {
        // Emit error if token is null
        emit(state.copyWith(
          status: SignUpStatus.error,
          errorMessage: 'Error durante el registro, no se pudo iniciar sesión.',
        ));

      }
    } catch (e) {
      // Handle specific WpException errors
      if (e is WpException) {
        print('WpException: ${e.toString()}');

        // Parse and emit a user-friendly error message
        //  final errorMessage = parseErrorMessage(FunctionException(e.errorData!) as FunctionException);

        // Emit the error message

        logger.info(e.errorData);
        final escapedMessageRegex =
            RegExp(r'\\"message\\"\s*:\s*\\"([^\\"]+)\\"');
        String? errorMessage =
            'Ha ocurrido un error desconocido. Inténtalo de nuevo.';
        try {
          errorMessage = escapedMessageRegex
              .firstMatch(
                e.errorData!,
              )
              ?.group(1);
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
        emit(state.copyWith(
          status: SignUpStatus.error,
          errorMessage: errorMessage.toString(),
        ));
      } else {
        // Handle unknown exceptions
        if (kDebugMode) {
          print('Unknown exception: $e');
        }
        emit(state.copyWith(
          status: SignUpStatus.error,
          errorMessage: 'Ha ocurrido un error desconocido. Inténtalo de nuevo.',
        ));
      }
    }
  }
}

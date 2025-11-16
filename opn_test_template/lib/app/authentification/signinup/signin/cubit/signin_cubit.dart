import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:opn_test_template/app/authentification/signinup/signin/cubit/signin_state.dart';

import '../../../../../bootstrap.dart';
import '../../../../../config/device_info.dart' hide isDesktopDevice;
import '../../../../config/preferences_service.dart';
import '../../../auth/model/wp_exception.dart';
import '../../../auth/repository/auth_repository.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit(this._authRepository, this._preferences, this._auth)
      : super(const SignInState());

  final AuthRepository _authRepository;
  final PreferencesService _preferences;
  final LocalAuthentication _auth;

  void email(String? value) => emit(
        state.copyWith(status: SignInStatus.editing, email: value?.trim()),
      );

  void password(String? value) => emit(
        state.copyWith(status: SignInStatus.editing, password: value?.trim()),
      );

  Future<void> checkBioLogin() async {
    final email = await _preferences.get('opnAppGCEmail');
    final password = await _preferences.get('opnAppGCPassWord');

    if (email != null && password != null) {
      final auth = LocalAuthentication();
      final canCheckBiometrics = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();
      final availableBiometrics = await auth.getAvailableBiometrics();

      if (canCheckBiometrics &&
          isDeviceSupported &&
          availableBiometrics.isNotEmpty &&
          !isDesktopDevice &&
          !isWeb) {
        await biometricLogin();
      }
    }
  }

  Future<void> biometricLogin() async {
    try {
      final isAuthenticated = await _auth.authenticate(
        localizedReason: 'Por favor, autentícate para iniciar sesión',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        final email = await _preferences.get('opnAppGCEmail');
        final password = await _preferences.get('opnAppGCPassWord');
        if (email != null && password != null) {
          emit(state.copyWith(password: password, email: email));
          // Intenta iniciar sesión con Supabase usando email y password
          final token =
              await _authRepository.signIn(email: email, password: password);

          // Se obtiene el nuevo token y se actualiza el header de Supabase
          if (token != null) {
            await _preferences.set('userGCToken', token);
            emit(state.copyWith(status: SignInStatus.done));
          } else {
            emit(state.copyWith(status: SignInStatus.error));
          }
        } else {
          // Si no existen las credenciales guardadas, se emite estado no autenticado
          emit(state.copyWith(status: SignInStatus.error));
        }
      }
    } catch (e) {
      logger.error('Error en biometricLogin: $e');
      emit(state.copyWith(status: SignInStatus.error));
    }
  }

  // Future<void> signIn() async {
  //   emit(state.copyWith(status: SignInStatus.loading, errorMessage: null));
  //   try {
  //     final token = await _authRepository.signIn(
  //       email: state.email!,
  //       password: state.password!,
  //     );
  //     if (token != null) {
  //       await _preferences.set('userToken', token);
  //       await _preferences.set('opnAppEmail', state.email!);
  //       await _preferences.set('opnAppPassWord', state.password!);

  //       AnalyticsService().track(
  //         'SIGN_IN',
  //         props: {'email': state.email},
  //       );

  //       emit(state.copyWith(status: SignInStatus.done));
  //     } else {
  //       logger.error('Null token');
  //       emit(state.copyWith(
  //         status: SignInStatus.error,
  //         errorMessage: 'No se pudo iniciar sesión. Inténtalo más tarde.',
  //       ));
  //     }
  //   } on WpException catch (e) {
  //     String msg;
  //     if (e.isInvalidCredentials) {
  //       msg = 'El usuario o la contraseña son incorrectos.';
  //     } else if (e.isServerError) {
  //       msg = 'El servidor no está disponible. Inténtalo más tarde.';
  //     } else {
  //       msg = e.errorMsg;
  //     }
  //     emit(state.copyWith(status: SignInStatus.error, errorMessage: msg));
  //   } catch (e) {
  //     logger.error('$e', e);
  //     emit(state.copyWith(
  //       status: SignInStatus.error,
  //       errorMessage:
  //           'Error inesperado al iniciar sesión. Inténtalo más tarde.',
  //     ));
  //   }
  // }

  Future<void> signIn() async {
    emit(state.copyWith(status: SignInStatus.loading, errorMessage: null));

    try {
      final token = await _authRepository.signIn(
        email: state.email!,
        password: state.password!,
      );

      if (token != null) {
        await _preferences.set('userGCToken', token);
        await _preferences.set('opnAppGCEmail', state.email!);
        await _preferences.set('opnAppGCPassWord', state.password!);

        // No emitas 'done' aquí, deja que el listener se encargue
        emit(state.copyWith(status: SignInStatus.done));
      } else {
        logger.error('Null token');
        emit(state.copyWith(
          status: SignInStatus.error,
          errorMessage: 'No se pudo iniciar sesión. Inténtalo más tarde.',
        ));
      }
    } on WpException catch (e) {
      // logger.error('[Cubit.signIn] ${e.status}: ${e.errorMsg}');
      logger.debug(e.toJson());
      String msg;
      if (e.isInvalidCredentials) {
        msg = 'El usuario o la contraseña son incorrectos.';
      } else if (e.isServerError) {
        msg = 'El servidor no está disponible. Inténtalo más tarde.';
      } else {
        msg = e.errorMsg;
      }
      emit(state.copyWith(status: SignInStatus.error, errorMessage: msg));
    } catch (e, st) {
      logger.error('[Cubit.signIn] Error inesperado', e, st);
      emit(state.copyWith(
        status: SignInStatus.error,
        errorMessage:
            'Error inesperado al iniciar sesión. Inténtalo más tarde.',
      ));
    }
  }
}

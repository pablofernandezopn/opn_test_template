import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/signinup/signin/cubit/signin_state.dart';
import '../../../../../bootstrap.dart';
import '../../../../../config/device_info.dart' hide isDesktopDevice;
import '../../../../config/preferences_service.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/repository/auth_repository.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit(this._authRepository, this._preferences, this._auth, this._authCubit)
      : super(const SignInState());

  final AuthRepository _authRepository;
  final PreferencesService _preferences;
  final LocalAuthentication _auth;
  final AuthCubit _authCubit; // Añadir AuthCubit

  void email(String? value) => emit(
        state.copyWith(status: SignInStatus.editing, email: value?.trim()),
      );

  void password(String? value) => emit(
        state.copyWith(status: SignInStatus.editing, password: value?.trim()),
      );

  void togglePasswordVisibility() =>
      emit(state.copyWith(showPassword: !state.showPassword));

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
          await signIn(); // Reutilizar el método signIn
        } else {
          emit(state.copyWith(status: SignInStatus.error));
        }
      }
    } catch (e) {
      logger.error('Error en biometricLogin: $e');
      emit(state.copyWith(status: SignInStatus.error));
    }
  }

  Future<void> signIn() async {
    emit(state.copyWith(status: SignInStatus.loading, errorMessage: null));

    try {
      final success = await _authCubit.signIn(
        email: state.email!,
        password: state.password!,
      );

      if (success) {
        await _preferences.set('opnAppGCEmail', state.email!);
        await _preferences.set('opnAppGCPassWord', state.password!);
        emit(state.copyWith(status: SignInStatus.done));
      } else {
        emit(state.copyWith(
          status: SignInStatus.error,
          errorMessage: 'Ocurrió un error al iniciar sesión',
        ));
      }
    } catch (e) {
      logger.error('[Cubit.signIn] Error: $e');
      emit(state.copyWith(
        status: SignInStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}

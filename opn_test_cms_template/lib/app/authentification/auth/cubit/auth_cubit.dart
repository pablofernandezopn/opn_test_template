import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/cubit/auth_state.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/model/user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../bootstrap.dart';
import '../../../config/preferences_service.dart';
import '../repository/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._preferences,
    this._authRepository,
  ) : super(AuthState(status: AuthStatus.unknown));

  final PreferencesService _preferences;
  final AuthRepository _authRepository;

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      logger.info('Attempting sign in for email: $email');

      final response = await _authRepository.signIn(
        email: email,
        password: password,
      );

      final user = response['user'] as CmsUser;
      final accessToken = response['accessToken'];
      final refreshToken = response['refreshToken'];

      // logger.info('testeo ${user.toJson()}');

      if (user == null || user.isEmpty) {
        logger.error('Sign in failed: user is null or empty');
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return false;
      }

      logger.info('Sign in successful, user received');

      await _preferences.set('accessToken', accessToken);
      await _preferences.set('refreshToken', refreshToken);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          token: accessToken,
          refreshToken: refreshToken,
        ),
      );

      logger.info('✅ State emitted: authenticated');
      return true;
    } on supa.AuthException catch (authError) {
      logger.error('AuthException in signIn:');
      logger.error('  Message: ${authError.message}');
      logger.error('  Status Code: ${authError.statusCode}');

      emit(state.copyWith(status: AuthStatus.unauthenticated));

      String userMessage;
      if (authError.message.contains('Invalid login credentials')) {
        userMessage =
            'Credenciales incorrectas. Verifica tu email y contraseña.';
      } else if (authError.message.contains('Email not confirmed')) {
        userMessage = 'Debes confirmar tu email antes de iniciar sesión.';
      } else if (authError.message.contains('User not found')) {
        userMessage = 'Usuario no encontrado. ¿Has registrado tu cuenta?';
      } else if (authError.statusCode == 429) {
        userMessage =
            'Demasiados intentos. Espera un momento e intenta nuevamente.';
      } else {
        userMessage = authError.message;
      }

      throw Exception(userMessage);
    } catch (e, stackTrace) {
      logger.error('Unexpected error in signIn: $e');
      logger.debug('StackTrace: $stackTrace');

      emit(state.copyWith(status: AuthStatus.unauthenticated));

      if (e.toString().contains('SocketException') ||
          e.toString().contains('NetworkException')) {
        throw Exception(
            'No se puede conectar al servidor. Verifica tu conexión a internet.');
      }

      rethrow;
    }
  }

  Future<void> check() async {
    try {
      logger.debug('Checking saved session...');

      final accessToken = await _preferences.get('accessToken');
      final refreshToken = await _preferences.get('refreshToken');

      if (accessToken == null ||
          accessToken.trim().isEmpty ||
          refreshToken == null ||
          refreshToken.trim().isEmpty) {
        logger.debug('No saved session found');
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }

      logger.debug('Tokens found, attempting to restore session...');

      // Intentar refrescar la sesión con el refreshToken
      final response = await _authRepository.refreshSession(refreshToken);
      final user = response['user'];
      final newAccessToken = response['accessToken'];
      final newRefreshToken = response['refreshToken'];

      if (user.isEmpty) {
        logger.error('Failed to refresh session, clearing tokens');
        await _clearTokens();
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }

      await _preferences.set('accessToken', newAccessToken);
      await _preferences.set('refreshToken', newRefreshToken);

      logger.info('Session restored successfully via refresh');

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          token: newAccessToken,
          refreshToken: newRefreshToken,
        ),
      );

      logger.info('✅ State emitted: authenticated from saved session');
    } catch (e, stackTrace) {
      logger.error('Error checking session: $e, clearing tokens');
      await _clearTokens();
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> checkCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;
      final version = packageInfo.version;

      final currentVersion = await _authRepository.getDeviceInfo(appName);

      if (currentVersion != null && (currentVersion.active ?? false)) {
        final serverVersion =
            int.parse(currentVersion.numberVersion!.split('.').join());
        final localVersion = int.parse(version.split('.').join());

        if (localVersion < serverVersion) {
          emit(state.copyWith(
              deviceInfo: currentVersion.copyWith(deprecated: true)));
        }
      }
    } catch (e) {
      logger.error('Error in checkCurrentVersion $e');
    }
  }

  Future<void> logout() async {
    try {
      await supa.Supabase.instance.client.auth.signOut();
      await _clearTokens();

      if (!kIsWeb && !isDesktopDevice) {
        await Purchases.logOut();
      }

      emit(state.copyWith(status: AuthStatus.unauthenticated));
      logger.info('✅ Logout successful');
    } catch (e, stackTrace) {
      logger.error('Error during logout: $e');
      logger.debug('StackTrace: $stackTrace');
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<bool> updateUser({
    required String username,
    required String nombre,
    required String apellido,
    String? email,
    String? phone,
    String? address,
    String? avatarUrl,
    int? specialtyId,
  }) async {
    if (state.status != AuthStatus.authenticated) {
      throw Exception('Usuario no autenticado.');
    }

    try {
      final updatedUser = await _authRepository.updateUser(
        userId: state.user.id,
        username: username,
        nombre: nombre,
        apellido: apellido,
        email: email,
        phone: phone,
        address: address,
        avatarUrl: avatarUrl,
        specialtyId: specialtyId,
      );

      if (updatedUser != null) {
        // Actualizar el estado con el nuevo usuario
        emit(state.copyWith(user: updatedUser));
        logger.info('AuthCubit state updated with new user data.');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      logger.error('Error updating user in AuthCubit: $e');
      rethrow; // Re-lanzar la excepción para que la UI la maneje
    }
  }

  /// Actualiza el usuario en el estado local sin hacer llamadas a la BD
  void updateUserState(CmsUser updatedUser) {
    if (state.status != AuthStatus.authenticated) {
      throw Exception('Usuario no autenticado.');
    }

    emit(state.copyWith(user: updatedUser));
    logger.info('User state updated locally.');
  }

  Future<void> _clearTokens() async {
    await _preferences.remove('accessToken');
    await _preferences.remove('refreshToken');
    await _preferences.remove('dailyFee');
    await _preferences.remove('dailyFeeDate');
  }

  void changeUri(Uri? uri) {
    emit(state.copyWith(uri: uri));
  }
}

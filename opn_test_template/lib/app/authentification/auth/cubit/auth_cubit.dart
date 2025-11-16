// ignore_for_file: avoid_dynamic_calls

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:opn_test_template/app/authentification/auth/model/user.dart';
import 'package:opn_test_template/app/authentification/auth/model/wp_exception.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../bootstrap.dart';
import '../../../config/preferences_service.dart';
import '../../../config/service_locator.dart';
import '../../../features/loading/cubit/loading_cubit.dart';
import '../repository/auth_repository.dart';
import '../../../features/academy/repository/academy_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
      this._preferences,
      this._authRepository,
      this._academyRepository,
      ) : super(AuthState(status: AuthStatus.unknown));

  final PreferencesService _preferences;
  final AuthRepository _authRepository;
  final AcademyRepository _academyRepository;

  /// Método para iniciar sesión
  /// Retorna true si el login fue exitoso, false en caso contrario
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      logger.info('Attempting sign in for email: $email');

      // 1. Llamar al repository para obtener el token
      final token = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (token == null || token.isEmpty) {
        logger.error('Sign in failed: token is null or empty');
        return false;
      }

      logger.info('Sign in successful, token received');

      // 2. Guardar el token en preferences
      await _preferences.set('userGCToken', token);

      // 3. Obtener los datos completos del usuario y actualizar el estado
      await check(firstStart: true);

      logger.info('User data loaded successfully');
      return true;

    } on WpException catch (wpError) {
      // Capturar y registrar el error específico de WordPress/API
      logger.error('WpException in signIn:');
      logger.error('  Status: ${wpError.status}');
      logger.error('  Message: ${wpError.errorMsg}');
      logger.error('  Reason: ${wpError.reason}');
      logger.error('  Data: ${wpError.errorData}');

      // Determinar el mensaje de error específico según el status
      String userMessage;

      switch (wpError.status) {
        case 401:
        case 403:
          userMessage = 'Credenciales incorrectas. Verifica tu email y contraseña.';
          break;
        case 404:
          userMessage = 'Usuario no encontrado. ¿Has registrado tu cuenta?';
          break;
        case 503:
          // Error de servicio no disponible
          if (wpError.errorData?.contains('name resolution failed') ?? false) {
            userMessage = 'No se puede conectar al servidor. Verifica tu conexión a internet.';
          } else {
            userMessage = 'El servicio no está disponible temporalmente. Intenta más tarde.';
          }
          break;
        case 500:
        case 502:
        case 504:
          userMessage = 'Error del servidor. Intenta nuevamente en unos momentos.';
          break;
        default:
          userMessage = wpError.errorMsg ?? 'Error al iniciar sesión. Intenta nuevamente.';
      }

      // Re-lanzar con el mensaje específico para que el UI lo muestre
      throw Exception(userMessage);

    } catch (e, stackTrace) {
      logger.error('Unexpected error in signIn: $e');
      logger.debug('StackTrace: $stackTrace');

      // Re-lanzar la excepción para que el UI pueda manejarla
      rethrow;
    }
  }

  /// Método para registrarse e iniciar sesión automáticamente
  /// Retorna true si el registro fue exitoso, false en caso contrario
  Future<bool> signUp({
    required String username,
    required String email,
    required String name,
    required String surname,
    required String password,
    required String phone,
  }) async {
    try {
      logger.info('Attempting sign up for email: $email');

      // 1. Llamar al repository para registrar y obtener el token
      final token = await _authRepository.signUpAndSignIn(
        username: username,
        email: email,
        name: name,
        surname: surname,
        password: password,
        phone: phone,
      );

      if (token == null || token.isEmpty) {
        logger.error('Sign up failed: token is null or empty');
        return false;
      }

      logger.info('Sign up successful, token received');

      // 2. Guardar el token en preferences
      await _preferences.set('userGCToken', token);

      // 3. Obtener los datos completos del usuario y actualizar el estado
      await check(firstStart: true);

      logger.info('User data loaded successfully after sign up');
      return true;

    } on WpException catch (wpError) {
      // Capturar y registrar el error específico de WordPress/API
      logger.error('WpException in signUp:');
      logger.error('  Status: ${wpError.status}');
      logger.error('  Message: ${wpError.errorMsg}');
      logger.error('  Reason: ${wpError.reason}');
      logger.error('  Data: ${wpError.errorData}');

      // Determinar el mensaje de error específico según el status
      String userMessage;

      switch (wpError.status) {
        case 409:
          userMessage = 'Este email o usuario ya está registrado. Intenta iniciar sesión.';
          break;
        case 400:
          userMessage = 'Datos inválidos. Verifica que todos los campos estén correctos.';
          break;
        case 503:
          // Error de servicio no disponible
          if (wpError.errorData?.contains('name resolution failed') ?? false) {
            userMessage = 'No se puede conectar al servidor. Verifica tu conexión a internet.';
          } else {
            userMessage = 'El servicio no está disponible temporalmente. Intenta más tarde.';
          }
          break;
        case 500:
        case 502:
        case 504:
          userMessage = 'Error del servidor. Intenta nuevamente en unos momentos.';
          break;
        default:
          userMessage = wpError.errorMsg ?? 'Error al registrarse. Intenta nuevamente.';
      }

      // Re-lanzar con el mensaje específico para que el UI lo muestre
      throw Exception(userMessage);

    } catch (e, stackTrace) {
      logger.error('Unexpected error in signUp: $e');
      logger.debug('StackTrace: $stackTrace');

      // Re-lanzar la excepción para que el UI pueda manejarla
      rethrow;
    }
  }

  Future<void> check({required bool firstStart}) async {
    final isMobile = !kIsWeb && !isDesktopDevice;
    // cleanup previous versions security
    unawaited(_preferences.remove('appGCToken'));
    logger.debug('Getting user...');

    final userToken = await _preferences.get('userGCToken');

    logger.debug('User token: $userToken');

    // 🔧 NO emitimos aquí para evitar múltiples emisiones
    // emit(state.copyWith(token: userToken ?? ''));

    var user = await _getUser(userToken);

    if (user.isEmpty) {
      // Si ya estamos en estado de error de conexión, no emitir unauthenticated
      if (state.status == AuthStatus.connectionError) {
        logger.debug('User is empty but connection error already emitted, not emitting unauthenticated');
        return;
      }

      // Solo emitir cuando tengamos el resultado final
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: User.empty,
        token: '',
        academy: null,
      ));
      getIt<LoadingCubit>().reset();
    } else {
      try {
        final now = DateTime.now().toUtc();
        await _authRepository.updateLastUsed(
          userId: user.id,
          lastUsed: now,
        );
        user = user.copyWith(lastUsed: now);
      } catch (e, stackTrace) {
        logger.error('Error updating lastUsed: $e');
        logger.debug('StackTrace: $stackTrace');
      }

      if (firstStart && isMobile) {
        // https://app.asana.com/0/1202451117261969/1204297809444911
        // OneSignal identification
        unawaited(
          OneSignal.login(user.id.toString()).then((value) {
            logger.debug('OS: setted ID');
          }).onError((error, stackTrace) {
            logger.error('OS: Set ID error: $error $stackTrace');
          }),
        );
        unawaited(
          OneSignal.User.addEmail(user.email ?? '').then((value) {
            logger.debug('OS: setted email');
          }).onError((error, stackTrace) {
            logger.error('OS: Set email error: $error $stackTrace');
          }),
        );
      }

      CustomerInfo? purchaseInfo;
      if (isMobile) {
        final uid = user.id.toString();
        // https://app.asana.com/0/1202451117261969/1204297809444911
        if (firstStart) {
          try {
            // Timeout de 5 segundos para evitar bloqueos si RC no responde
            final result = await Purchases.logIn(uid).timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                logger.warning('RC: Login timeout después de 5 segundos, continuando sin RC');
                throw TimeoutException('RevenueCat login timeout');
              },
            );

            logger.debug('RC: user log in: ${result.customerInfo}');

            unawaited(Purchases.setEmail(user.email ?? ''));
            unawaited(
              Purchases.setDisplayName(
                '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
              ),
            );
            unawaited(
              Purchases.setAttributes(
                {
                  'user_id': '${user.id}',
                  'membership_level': user.membershipLevelName,
                  'access_level': '${user.maxAccessLevel}',
                },
              ),
            );

            purchaseInfo = result.customerInfo;
          } catch (error, stackTrace) {
            logger.error('RC: Error en login (la app continuará sin RC): $error');
            logger.debug('RC: StackTrace: $stackTrace');
            purchaseInfo = null;
          }
        } else {
          // Subsequent calls
          try {
            // Timeout de 5 segundos para evitar bloqueos
            purchaseInfo = await Purchases.restorePurchases().timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                logger.warning('RC: RestorePurchases timeout después de 5 segundos, continuando sin RC');
                throw TimeoutException('RevenueCat restore timeout');
              },
            );
          } catch (error, stackTrace) {
            logger.error('RC: Error en restore (la app continuará sin RC): $error');
            logger.debug('RC: StackTrace: $stackTrace');
            purchaseInfo = null;
          }
        }
      }

      if (isMobile) {
        // Add OneSignal tags
        if (user.isPremiumOrBasic) {
          unawaited(
            OneSignal.User.addTags({'premium': 1}).then((value) {
              OneSignal.User.removeTag('freemium');
            }).onError((error, stackTrace) {
              logger.error('OS: Error setting tags: $error $stackTrace');
            }),
          );
        } else {
          unawaited(
            OneSignal.User.removeTag('premium').then((value) {
              OneSignal.User.addTags({'freemium': 1});
            }).onError((error, stackTrace) {
              logger.error('OS: Error setting tags: $error $stackTrace');
            }),
          );
        }

        try {
          final fcmToken = await _preferences.get('fcm_token') ?? '';
          // push notifications fcm
          if (fcmToken.isNotEmpty) {
            await _authRepository.updateFcmToken(user.id, fcmToken);
          }
        } catch (e) {
          logger.error('Error setting FCM token: $e');
        }

        try {
          final fidToken = await _preferences.get('fid_token') ?? '';
          if (fidToken.isNotEmpty) {
            await _authRepository.updateFidToken(user.id, fidToken);
          }
        } catch (e) {
          logger.error('Error setting FID token: $e');
        }
      }

      // logger if is betatester
      if (user.tester ?? false) {
        logger.info('User is a betatester');
      } else {
        logger.info('User is not a betatester');
      }

      // Debug final para verificar
      user.debugMembershipStatus();

      // Logs adicionales para debugging
      logger.info('📝 About to emit authenticated state:');
      logger.info('   user.token: ${user.token}');
      logger.info('   userToken: $userToken');

      // 🔧 NO configuramos header Authorization porque:
      // - Token WordPress solo es para Edge Functions (get_user, etc.)
      // - Queries directos a Supabase usan el anon key
      // - Las tablas tienen GRANT SELECT TO anon

      final tokenToUse = userToken ?? user.token ?? '';

      var academy = state.academy;
      if (user.academyId > 0) {
        academy =
            await _academyRepository.fetchAcademyById(user.academyId) ?? academy;
      } else {
        academy = null;
      }

      // ⭐ EMIT ÚNICO: Emitir con el user actualizado Y el token
      // Solo una vez, con todos los datos completos
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          token: tokenToUse,
          purchaseInfo: purchaseInfo,
          academy: academy,
        ),
      );

      // Log para debugging del listener
      logger.info('✅ State emitted: authenticated');
      logger.info('   Token in state: ${state.token}');
      logger.info('   Token not empty: ${state.token.isNotEmpty}');
    }
  }

  Future<User> _getUser(String? userToken) async {
    if (userToken != null && userToken.trim().isEmpty) {
      logger.error('UserToken is invalid or empty');
      return User.empty;
    }

    if (userToken == null) {
      logger.debug('UserToken is null');
      return User.empty;
    } else {
      // 🔧 NO emitimos aquí - el estado se emitirá una sola vez en check()
      // emit(state.copyWith(token: userToken));
      return _authRepository.getUser(userToken).then((value) {
        logger.debug('User obtained: ${value.toJson()}');
        return value;
      })
      // Try to fix startup errors
          .onError((error, stackTrace) {
        logger
          ..error('Error obtaining user: $error')
          ..error('$stackTrace');

        // Si es un error de conexión, emitir estado especial
        if (error is WpException &&
            (error.status == 503 || error.status == 504 ||
             error.reason == 'ConnectionError' || error.reason == 'TimeoutError')) {
          logger.error('Connection error detected - emitting connection error state');
          emit(state.copyWith(
            status: AuthStatus.connectionError,
            user: User.empty,
            token: '',
          ));
        } else {
          logger.error('Returning empty user');
        }

        return User.empty;
      });
    }
  }

  Future<void> checkCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;
      final version = packageInfo.version; // "2.6.3"
      final currentVersion = await _authRepository.getDeviceInfo(appName);

      if (currentVersion != null && (currentVersion.active ?? false)) {
        // Convertir versiones a números para comparar
        final serverVersion = int.parse(currentVersion.numberVersion!.split('.').join());
        final localVersion = int.parse(version.split('.').join());

        // Solo alertar si la versión local es MENOR que la del servidor
        if (localVersion < serverVersion) {
          emit(state.copyWith(
              deviceInfo: currentVersion.copyWith(deprecated: true)));
        }
      }
    } catch (e) {
      logger.error('Error in checkCurrentVersion $e');
    }
  }

  Future<void> updatePhone(String phone) async {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('El teléfono no puede estar vacío');
    }
    final currentUser = state.user;
    if (state.status != AuthStatus.authenticated || currentUser.id == 0) {
      logger.warning('Cannot update phone: user not authenticated');
      return;
    }

    try {
      await _authRepository.updatePhone(
        userId: currentUser.id,
        phone: trimmed,
      );
      emit(
        state.copyWith(
          user: currentUser.copyWith(phone: trimmed),
        ),
      );
      logger.info('Phone updated in state for user ${currentUser.id}');
    } catch (e, stackTrace) {
      logger.error('Error updating phone: $e');
      logger.debug('StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    final currentUser = state.user;
    if (state.status != AuthStatus.authenticated || currentUser.id == 0) {
      logger.warning('Cannot delete account: user not authenticated');
      throw Exception('Usuario no autenticado');
    }

    final token = state.token;
    if (token.isEmpty) {
      logger.warning('Cannot delete account: no token available');
      throw Exception('No hay token de autenticación disponible');
    }

    try {
      logger.info('Attempting to delete account for user ${currentUser.id}');

      // Llamar al repository para eliminar la cuenta
      await _authRepository.deleteAccount(userToken: token);

      logger.info('Account deleted successfully, logging out...');

      // Hacer logout después de eliminar la cuenta
      await logout();

    } catch (e, stackTrace) {
      logger.error('Error deleting account: $e');
      logger.debug('StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<void> logout() async {
    // Unset supabase custom token
    // SEE https://github.com/supabase/supabase-flutter/issues/479
    supa.Supabase.instance.client.headers.remove('Authorization');
    getIt<LoadingCubit>().reset();

    // FIXME 🔥🔥🔥 Being Freemium, if you logout and login again you'll get 20
    // FIXME (cont.) new questions. This state should be persisted in the
    // FIXME (cont.) database, not locally
    await _preferences.remove('userGCToken');
    await _preferences.remove('dailyFee');
    await _preferences.remove('dailyFeeDate');
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        user: User.empty,
        token: '',
        purchaseInfo: null,
        academy: null,
      ),
    );
    if (!kIsWeb && !isDesktopDevice) {
      try {
        // Timeout de 3 segundos para logout, no es crítico si falla
        await Purchases.logOut().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            logger.warning('RC: LogOut timeout después de 3 segundos, continuando');
            throw TimeoutException('RevenueCat logout timeout');
          },
        );
      } catch (e) {
        logger.error('RC: Error en logout (no afecta al cierre de sesión): $e');
      }
    }
  }

  Future<void> purchase({required CustomerInfo customerInfo}) async {
    emit(
      state.copyWith(
        purchaseInfo: customerInfo,
      ),
    );

    // Recargar el usuario para obtener las membresías actualizadas
    await check(firstStart: false);
  }

  Future<void> restorePurchases() async {
    try {
      await check(firstStart: false);
    } catch (e) {
      logger.error('Error in restore purchases $e');
    }
  }

  Future<void> updateDailyFee(int questions) async {
    final dailyFeeDate = await _dailyFeeDate();
    final today = DateTime.now();
    if (dailyFeeDate == null || today.difference(dailyFeeDate).inDays > 0) {
      await _preferences.set('dailyFee', questions.toString());
      final feeDate = DateTime(today.year, today.month, today.day);
      await _preferences.set('dailyFeeDate', feeDate.toIso8601String());
      return;
    }
    final dailyFee = await _dailyFee();
    await _preferences.set('dailyFee', (dailyFee + questions).toString());
  }

  Future<bool> hasDailyFee() async {
    final dailyFeeDate = await _dailyFeeDate();
    final dailyFee = await _dailyFee();

    return state.user.isPremiumOrBasic ||
        dailyFeeDate == null ||
        DateTime.now().difference(dailyFeeDate).inDays > 0 ||
        dailyFee < 20;
  }

  Future<DateTime?> _dailyFeeDate() async {
    final dateString = await _preferences.get('dailyFeeDate');
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  Future<int> _dailyFee() {
    return _preferences
        .get('dailyFee')
        .then((value) => value == null ? 0 : int.tryParse(value) ?? 0);
  }

  /// Actualiza el objetivo de preguntas del usuario
  Future<void> updateQuestionGoal(int newGoal) async {
    try {
      logger.info('Updating question goal to: $newGoal');

      // Actualizar en Supabase
      await _authRepository.updateQuestionGoal(
        userId: state.user.id,
        questionGoal: newGoal,
      );

      // Actualizar el estado local
      final updatedUser = state.user.copyWith(questionGoal: newGoal);
      emit(state.copyWith(user: updatedUser));

      logger.info('Question goal updated successfully');
    } catch (e, st) {
      logger.error('Error updating question goal: $e');
      logger.error('Stack trace: $st');
      rethrow;
    }
  }

  /// Refresca solo las estadísticas de preguntas del usuario
  Future<void> refreshQuestionStats() async {
    try {
      logger.info('Refreshing question stats for user: ${state.user.id}');

      // Obtener stats desde el repository
      final stats = await _authRepository.fetchUserQuestionStats(
        userId: state.user.id,
      );

      // Actualizar el estado local solo con los stats
      final updatedUser = state.user.copyWith(
        totalQuestions: stats['totalQuestions'],
        rightQuestions: stats['rightQuestions'],
        wrongQuestions: stats['wrongQuestions'],
      );

      emit(state.copyWith(user: updatedUser));

      logger.info('Question stats refreshed successfully');
    } catch (e, st) {
      logger.error('Error refreshing question stats: $e');
      logger.error('Stack trace: $st');
      rethrow;
    }
  }

  /// Refresca completamente los datos del usuario desde el backend
  /// Útil después de actualizar datos como la especialidad
  Future<void> refreshUser() async {
    try {
      logger.info('Refreshing user data for user: ${state.user.id}');

      // Obtener el usuario actualizado desde el backend
      final updatedUser = await _getUser(state.token);

      if (updatedUser != User.empty) {
        // Actualizar el estado con el usuario completo
        emit(state.copyWith(user: updatedUser));
        logger.info('User data refreshed successfully');
        logger.debug('Updated specialty_id: ${updatedUser.specialtyId}');
      } else {
        logger.error('Failed to refresh user: received empty user');
      }
    } catch (e, stackTrace) {
      logger.error('Error refreshing user data: $e');
      logger.debug('StackTrace: $stackTrace');
      // No lanzar error, mantener el estado actual
    }
  }

  void changeUri(Uri? uri) {
    emit(state.copyWith(uri: uri));
  }

  /// Actualiza la foto de perfil del usuario
  Future<void> updateProfileImage({
    required Uint8List imageBytes,
    required String extension,
    required String mimeType,
  }) async {
    try {
      if (state.user.isEmpty) {
        logger.warning('Cannot update profile image: user not authenticated');
        return;
      }

      logger.info('Updating profile image for user: ${state.user.id}');

      final imageUrl = await _authRepository.updateProfileImage(
        userId: state.user.id,
        imageBytes: imageBytes,
        extension: extension,
        mimeType: mimeType,
      );

      logger.info('Profile image updated successfully: $imageUrl');

      emit(
        state.copyWith(
          user: state.user.copyWith(profileImage: imageUrl),
        ),
      );
    } catch (e, stackTrace) {
      logger.error('Error updating profile image: $e');
      logger.debug('StackTrace: $stackTrace');
      rethrow;
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'dart:typed_data';
import 'package:opn_test_template/app/authentification/auth/model/user.dart';
import 'package:opn_test_template/app/authentification/auth/model/wp_exception.dart';
import 'package:opn_test_template/app/features/opn_ranking/model/user_opn_index_current_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../bootstrap.dart';
import '../model/device_info.dart';

class AuthRepository {
  AuthRepository();

  Future<String?> signUpAndSignIn({
    required String username,
    required String email,
    required String name,
    required String surname,
    required String password,
    required String phone,
  }) async {
    // Timeout de 10 segundos para evitar bloqueos
    return supa.Supabase.instance.client.functions.invoke(
      'login-register/v1/register',  // 🔧 Cambiado _ por -
      body: <String, dynamic>{
        'username': username,
        'first_name': name,
        'last_name': surname,
        'name': '$name $surname',
        'email': email,
        'password': password,
        'phone': phone,
      },
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        logger.error('Timeout during registration');
        throw TimeoutException('Registration timeout after 10 seconds');
      },
    ).then((result) {
      if (result.status != 200) {
        throw WpException.fromJson(result.data as Map<String, dynamic>);
      } else {
        // 🔧 Extraer token del objeto de respuesta
        final responseData = result.data as Map<String, dynamic>;
        return responseData['token'] as String?;
      }
    }).onError(
          (error, stackTrace) {
        if (error is WpException) {
          throw error;
        } else {
          throw WpException(
            status: 500,
            errorMsg: 'Error during sign up',
            reason: 'Internal error',
            errorData: jsonEncode({
              'error': '$error',
              'stackTrace': '$stackTrace',
            }),
          );
        }
      },
    );
  }

  Future<DeviceInfoModel?> getDeviceInfo(String appIdentifier) async {
    return supa.Supabase.instance.client
        .schema('general')
        .from('app_config')
        .select()
        .eq('app_identifier', appIdentifier)
        .then((value) {
      return value.isEmpty ? null : DeviceInfoModel.fromJson(value.first);
    }).onError((error, stackTrace) {
      logger.error('Error getting device info: $error');
      return DeviceInfoModel();
    });
  }

  Future<User> getUser(String userToken) async {
    logger.info('Getting user with WordPress token');

    try {
      // ✅ ÚNICA llamada necesaria - el backend devuelve TODO
      // Timeout de 10 segundos para evitar bloqueos
      final result = await supa.Supabase.instance.client.functions.invoke(
        'login-register/v1/get_user',
        headers: {
          'X-WordPress-Token': userToken,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          logger.error('Timeout getting user from WordPress API');
          throw TimeoutException('Failed to get user: timeout after 10 seconds');
        },
      );

      // Validar respuesta HTTP
      if (result.status != 200) {
        logger.error(
          'Server error getting user ${result.status}: ${result.data}',
        );
        throw Exception('Failed to get user: ${result.status}');
      }

      // Parsear respuesta
      final responseData = result.data as Map<String, dynamic>;

      // Validar estructura de respuesta
      if (responseData['success'] != true || !responseData.containsKey('user')) {
        logger.error('Invalid getUser response: $responseData');
        throw Exception('Invalid response format from server');
      }

      // Extraer datos del usuario (YA incluye membresías y todos los campos de Supabase)
      final userData = responseData['user'] as Map<String, dynamic>;

      final membershipsCount = (userData['user_memberships'] as List?)?.length ?? 0;
      logger.info('Complete user data received with $membershipsCount memberships');

      // ⭐ Agregar el token si tu modelo User lo necesita
      userData['token'] = userToken;

      // ⭐ Obtener el índice OPN actual con ranking actualizado desde la vista
      try {
        final userId = userData['id'] as int;
        final opnResponse = await supa.Supabase.instance.client
            .from('user_opn_index_current')
            .select('''
            user_id,
            opn_index,
            quality_trend_score,
            recent_activity_score,
            competitive_score,
            momentum_score,
            global_rank,
            calculated_at
          ''')
            .eq('user_id', userId)
            .maybeSingle();

        if (opnResponse != null) {
          // Usar fromJson para parsear la respuesta
          final opnIndexCurrent = UserOpnIndexCurrent.fromJson(opnResponse as Map<String, dynamic>);

          // Asignar el objeto al campo opn_index_data usando toHistoryJson para compatibilidad
          userData['opn_index_data'] = opnIndexCurrent.toHistoryJson();

          // También mantener los campos individuales por compatibilidad
          userData['opn_index'] = opnIndexCurrent.opnIndex;
          userData['opn_global_rank'] = opnIndexCurrent.globalRank;

          logger.info('OPN Index current loaded: ${opnIndexCurrent.opnIndex}, Rank: ${opnIndexCurrent.globalRank}');
        } else {
          logger.info('No OPN Index current found for user $userId');
        }
      } catch (e) {
        logger.warning('Error loading OPN Index current: $e');
        // No fallar si no se puede obtener el OPN index
      }

      // Crear el objeto User desde el JSON completo
      final user = User.fromJson(userData);

      logger.info('User object created successfully - ID: ${user.id}, Email: ${user.email}');

      return user;
    } on SocketException catch (e) {
      logger.error('Connection error getting user: $e');
      throw WpException(
        status: 503,
        errorMsg: 'No se puede conectar con el servidor. Por favor, verifica tu conexión a internet.',
        reason: 'ConnectionError',
        errorData: e.toString(),
      );
    } on TimeoutException catch (e) {
      logger.error('Timeout error getting user: $e');
      throw WpException(
        status: 504,
        errorMsg: 'El servidor tardó demasiado en responder. Por favor, inténtalo de nuevo.',
        reason: 'TimeoutError',
        errorData: e.toString(),
      );
    } catch (e, stackTrace) {
      logger.error('Unexpected error getting user: $e');
      logger.debug('StackTrace: $stackTrace');

      // Si el error contiene información de conexión rechazada
      if (e.toString().toLowerCase().contains('connection refused') ||
          e.toString().toLowerCase().contains('socketexception')) {
        throw WpException(
          status: 503,
          errorMsg: 'No se puede conectar con el servidor. Por favor, verifica tu conexión a internet.',
          reason: 'ConnectionError',
          errorData: e.toString(),
        );
      }

      throw WpException(
        status: 500,
        errorMsg: 'Error al obtener datos del usuario. Por favor, inténtalo de nuevo.',
        reason: 'UnexpectedError',
        errorData: e.toString(),
      );
    }
  }
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Timeout de 10 segundos para evitar bloqueos
      final result = await supa.Supabase.instance.client.functions.invoke(
        'login-register/v1/login',  // 🔧 Cambiado _ por -
        body: {'username': email, 'password': password},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          logger.error('Timeout during login');
          throw TimeoutException('Login timeout after 10 seconds');
        },
      );

      if (result.status == 200) {
        // 🔧 Extraer token del objeto de respuesta
        final responseData = result.data as Map<String, dynamic>;

        // El servidor devuelve: { success: true, token: "...", user: {...} }
        if (responseData['success'] == true && responseData.containsKey('token')) {
          logger.info('Login successful, token received');
          return responseData['token'] as String?;
        }

        logger.error('Login response missing token: $responseData');
        return null;
      }

      // Esto casi nunca se ejecutará porque Supabase lanza excepción en 4xx/5xx,
      // pero lo dejamos como fallback por si acaso
      if (result.data is Map<String, dynamic>) {
        throw WpException.fromJson(result.data as Map<String, dynamic>);
      }

      throw WpException(
        status: result.status,
        errorMsg: 'Error inesperado en el servidor.',
        reason: 'InvalidResponseFormat',
        errorData: result.data.toString(),
      );
    } on supa.FunctionException catch (fe) {
      // 👇 Aquí parseamos la FunctionException para crear un WpException
      final msg = fe.details['errorMsg'] as String? ??
          'Error de autenticación'; // depende de tu payload
      final status = fe.details['status'] as int? ?? fe.status ?? 500;

      throw WpException(
        status: status,
        errorMsg: msg,
        reason: fe.reasonPhrase,
        errorData: jsonEncode(fe.details),
      );
    } on WpException {
      rethrow;
    } catch (e, st) {
      throw WpException(
        status: 500,
        errorMsg: 'Error de conexión con el servidor. Intenta más tarde.',
        reason: e.runtimeType.toString(),
        errorData: jsonEncode({'error': e.toString(), 'stackTrace': '$st'}),
      );
    }
  }

  // Versión mejorada - más limpia y robusta
  Future<void> updateFcmToken(int userId, String fcmToken) async {
    logger.info('Updating FCM token for user: $userId');
    await supa.Supabase.instance.client.from('users').update({
      'fcm_token': fcmToken,
    }).eq('id', userId);
    // Si llegamos aquí, la operación fue exitosa
    logger.info('FCM token updated successfully for user: $userId');
  }

  Future<void> updateFidToken(int userId, String fidToken) async {
    logger.info('Updating FID token for user: $userId');
    await supa.Supabase.instance.client.from('users').update({
      'fid_token': fidToken,
    }).eq('id', userId);
    // Si llegamos aquí, la operación fue exitosa
    logger.info('FID token updated successfully for user: $userId');
  }

  Future<void> updateLastUsed({
    required int userId,
    required DateTime lastUsed,
  }) async {
    logger.info('Updating lastUsed for user: $userId');
    await supa.Supabase.instance.client.from('users').update({
      'lastUsed': lastUsed.toIso8601String(),
    }).eq('id', userId);
    logger.info('lastUsed updated successfully for user: $userId');
  }

  Future<void> updatePhone({
    required int userId,
    required String phone,
  }) async {
    logger.info('Updating phone for user: $userId');
    await supa.Supabase.instance.client
        .from('users')
        .update({'phone': phone}).eq('id', userId);
    logger.info('Phone updated successfully for user: $userId');
  }

  Future<void> deleteAccount({required String userToken}) async {
    logger.info('Deleting user account');

    try {
      final result = await supa.Supabase.instance.client.functions.invoke(
        'login-register/v1/delete_account',
        body: <String, dynamic>{
          'user_token': userToken,
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          logger.error('Timeout deleting account');
          throw TimeoutException('Delete account timeout after 15 seconds');
        },
      );

      if (result.status != 200) {
        final errorData = result.data as Map<String, dynamic>?;
        final errorMessage = errorData?['message'] as String? ??
            errorData?['error'] as String? ??
            'Error al eliminar la cuenta';

        logger.error('Error deleting account: $errorMessage');
        throw Exception(errorMessage);
      }

      logger.info('Account deleted successfully');
    } on SocketException catch (e) {
      logger.error('Network error deleting account: $e');
      throw Exception(
          'Error de conexión. Verifica tu conexión a internet e intenta nuevamente.');
    } on TimeoutException catch (e) {
      logger.error('Timeout deleting account: $e');
      throw Exception(
          'La solicitud tardó demasiado. Verifica tu conexión e intenta nuevamente.');
    } catch (e) {
      logger.error('Unexpected error deleting account: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error inesperado al eliminar la cuenta: $e');
    }
  }

  Future<void> updateQuestionGoal({
    required int userId,
    required int questionGoal,
  }) async {
    logger.info('Updating question_goal for user: $userId to $questionGoal');
    await supa.Supabase.instance.client
        .from('users')
        .update({'question_goal': questionGoal}).eq('id', userId);
    logger.info('Question goal updated successfully for user: $userId');
  }

  /// Obtiene solo las estadísticas de preguntas del usuario
  Future<Map<String, int>> fetchUserQuestionStats({
    required int userId,
  }) async {
    logger.info('Fetching question stats for user: $userId');
    final response = await supa.Supabase.instance.client
        .from('users')
        .select('totalQuestions, rightQuestions, wrongQuestions')
        .eq('id', userId)
        .single();

    logger.info('Question stats fetched successfully for user: $userId');
    return {
      'totalQuestions': response['totalQuestions'] as int? ?? 0,
      'rightQuestions': response['rightQuestions'] as int? ?? 0,
      'wrongQuestions': response['wrongQuestions'] as int? ?? 0,
    };
  }

  /// Actualiza la foto de perfil del usuario
  Future<String> updateProfileImage({
    required int userId,
    required Uint8List imageBytes,
    required String extension,
    required String mimeType,
  }) async {
    try {
      logger.info('Updating profile image for user: $userId');
      final supabase = supa.Supabase.instance.client;

      // Nombre del archivo
      final fileName = 'profiles/$userId.$extension';

      logger.info('Uploading image: $fileName');

      // Intentar subir a Supabase Storage
      try {
        await supabase.storage.from('users').uploadBinary(
              fileName,
              imageBytes,
              fileOptions: supa.FileOptions(
                upsert: true,
                contentType: mimeType,
              ),
            );
      } on supa.StorageException catch (storageError) {
        // Si el bucket no existe, crearlo y reintentar
        if (storageError.statusCode == '404' ||
            storageError.message.toLowerCase().contains('bucket not found')) {
          logger.info('Bucket "users" not found, creating it...');

          try {
            await supabase.storage.createBucket(
              'users',
              supa.BucketOptions(
                public: true,
                fileSizeLimit: '5242880', // 5MB limit
                allowedMimeTypes: const ['image/jpeg', 'image/png', 'image/jpg', 'image/webp'],
              ),
            );
            logger.info('Bucket "users" created successfully');
          } catch (createError) {
            // Si falla la creación (por ejemplo, ya existe), continuar
            logger.warning('Error creating bucket (may already exist): $createError');
          }

          // Reintentar la subida
          logger.info('Retrying image upload...');
          await supabase.storage.from('users').uploadBinary(
                fileName,
                imageBytes,
                fileOptions: supa.FileOptions(
                  upsert: true,
                  contentType: mimeType,
                ),
              );
        } else {
          // Si es otro error de storage, lanzarlo
          rethrow;
        }
      }

      // URL con timestamp para evitar caché
      final url = supabase.storage.from('users').getPublicUrl(fileName);
      final finalUrl = '$url?t=${DateTime.now().millisecondsSinceEpoch}';

      // Actualizar BD
      await supabase
          .from('users')
          .update({'profile_image': finalUrl}).eq('id', userId);

      logger.info('Profile image updated successfully for user: $userId');
      return finalUrl;
    } catch (e, stackTrace) {
      logger.error('Error updating profile image: $e');
      logger.debug('StackTrace: $stackTrace');
      throw Exception('Error subiendo imagen: $e');
    }
  }
}

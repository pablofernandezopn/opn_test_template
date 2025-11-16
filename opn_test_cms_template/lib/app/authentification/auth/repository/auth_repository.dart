import 'package:opn_test_guardia_civil_cms/app/authentification/auth/model/user.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/model/specialty.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../bootstrap.dart';
import '../model/device_info.dart';

class AuthRepository {
  AuthRepository();

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

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response =
          await supa.Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null && response.user != null) {
        final userUuid = response.user!.id;
        final accessToken = response.session!.accessToken;
        final refreshToken = response.session!.refreshToken;

        logger.info('Login successful, fetching user data for UUID: $userUuid');

        final userData = await supa.Supabase.instance.client
            .schema('public')
            .from('cms_users')
            .select('*, specialties!specialty_id(*)')
            .eq('user_uuid', userUuid)
            .single();

        // Crear el usuario con la especialidad completa
        final userDataWithSpecialty = Map<String, dynamic>.from(userData);

        // Mover el objeto specialties a specialty para que coincida con el modelo
        if (userData['specialties'] != null) {
          userDataWithSpecialty['specialty'] = userData['specialties'];
        }
        userDataWithSpecialty.remove('specialties');

        final cmsUser = CmsUser.fromJson(userDataWithSpecialty);

        logger.info('User data fetched successfully: ${cmsUser.username}');

        return {
          'user': cmsUser,
          'accessToken': accessToken,
          'refreshToken': refreshToken,
        };
      }

      logger.error('Login failed: no session created');
      throw Exception('Error de autenticación: No se pudo crear la sesión.');
    } on supa.AuthException catch (e) {
      logger.error('Auth error: ${e.message}');
      rethrow;
    } catch (e, st) {
      logger.error('Unexpected error during sign in: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error de conexión con el servidor. Intenta más tarde.');
    }
  }

  Future<Map<String, dynamic>> refreshSession(String refreshToken) async {
    try {
      final response =
          await supa.Supabase.instance.client.auth.refreshSession(refreshToken);

      if (response.session != null && response.user != null) {
        final userUuid = response.user!.id;
        final newAccessToken = response.session!.accessToken;
        final newRefreshToken = response.session!.refreshToken;

        logger
            .info('Session refreshed, fetching user data for UUID: $userUuid');

        final userData = await supa.Supabase.instance.client
            .schema('public')
            .from('cms_users')
            .select('*, specialties!specialty_id(*)')
            .eq('user_uuid', userUuid)
            .single();

        // Crear el usuario con la especialidad completa
        final userDataWithSpecialty = Map<String, dynamic>.from(userData);

        // Mover el objeto specialties a specialty para que coincida con el modelo
        if (userData['specialties'] != null) {
          userDataWithSpecialty['specialty'] = userData['specialties'];
        }
        userDataWithSpecialty.remove('specialties');

        final cmsUser = CmsUser.fromJson(userDataWithSpecialty);

        return {
          'user': cmsUser,
          'accessToken': newAccessToken,
          'refreshToken': newRefreshToken,
        };
      }

      throw Exception('No se pudo refrescar la sesión.');
    } on supa.AuthException catch (e) {
      logger.error('Auth error during refresh: ${e.message}');
      throw Exception(
          'La sesión ha expirado. Por favor, inicia sesión de nuevo.');
    } catch (e, st) {
      logger.error('Unexpected error during session refresh: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error de conexión. No se pudo refrescar la sesión.');
    }
  }

  /// Obtiene el usuario actual desde Supabase usando una sesión existente
  Future<CmsUser> getUser(String token) async {
    try {
      // Obtener la sesión actual de Supabase
      final session = supa.Supabase.instance.client.auth.currentSession;

      if (session == null || session.user == null) {
        logger.error('No active session found');
        return CmsUser.empty;
      }

      final userUuid = session.user!.id;
      logger.info('Fetching user data for UUID: $userUuid');

      // Obtener datos del usuario de la tabla cms_users con specialty
      final userData = await supa.Supabase.instance.client
          .schema('public')
          .from('cms_users')
          .select('*, specialties!specialty_id(*)')
          .eq('user_uuid', userUuid)
          .single();

      if (userData != null) {
        // Crear el usuario con la especialidad completa
        final userDataWithSpecialty = Map<String, dynamic>.from(userData);

        // Mover el objeto specialties a specialty para que coincida con el modelo
        if (userData['specialties'] != null) {
          userDataWithSpecialty['specialty'] = userData['specialties'];
        }
        userDataWithSpecialty.remove('specialties');

        final cmsUser =
            CmsUser.fromJson(userDataWithSpecialty).copyWith(token: token);
        logger.info('User data fetched successfully: ${cmsUser.username}');
        return cmsUser;
      } else {
        logger.error('User data not found in cms_users table');
        return CmsUser.empty;
      }
    } catch (e, st) {
      logger.error('Error getting user: $e');
      logger.error('Stack trace: $st');
      return CmsUser.empty;
    }
  }

  /// Actualiza los datos del usuario en cms_users
  Future<CmsUser?> updateUser({
    required int userId,
    String? username,
    String? nombre,
    String? apellido,
    String? email,
    String? phone,
    String? address,
    String? avatarUrl,
    int? specialtyId,
  }) async {
    try {
      logger.info('Updating user data for user ID: $userId');

      // Construir el mapa de actualización solo con campos no nulos
      final updateData = <String, dynamic>{};

      if (username != null) updateData['username'] = username;
      if (nombre != null) updateData['nombre'] = nombre;
      if (apellido != null) updateData['apellido'] = apellido;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (specialtyId != null) updateData['specialty_id'] = specialtyId;

      // Añadir timestamp de actualización
      updateData['updated_at'] = DateTime.now().toIso8601String();

      // Ejecutar la actualización con join para obtener los datos completos de la especialidad
      final response = await supa.Supabase.instance.client
          .schema('public')
          .from('cms_users')
          .update(updateData)
          .eq('id', userId)
          .select('*, specialties!specialty_id(*)')
          .single();

      if (response != null) {
        // Crear el usuario con la especialidad completa
        final userDataWithSpecialty = Map<String, dynamic>.from(response);

        // Mover el objeto specialties a specialty para que coincida con el modelo
        if (response['specialties'] != null) {
          userDataWithSpecialty['specialty'] = response['specialties'];
        }
        userDataWithSpecialty.remove('specialties');

        final updatedUser = CmsUser.fromJson(userDataWithSpecialty);
        logger.info('User updated successfully: ${updatedUser.username}');
        return updatedUser;
      } else {
        logger.error('Update failed: no response from server');
        return null;
      }
    } on supa.PostgrestException catch (e) {
      logger.error('Postgrest error updating user: ${e.message}');
      throw Exception('Error al actualizar el perfil: ${e.message}');
    } catch (e, st) {
      logger.error('Unexpected error updating user: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error inesperado al actualizar el perfil');
    }
  }

  /// Obtiene usuario por ID (útil para refrescar después de actualizar)
  Future<CmsUser?> getUserById(int userId, String token) async {
    try {
      logger.info('Fetching user by ID: $userId');

      final userData = await supa.Supabase.instance.client
          .schema('public')
          .from('cms_users')
          .select('*, specialties!specialty_id(*)')
          .eq('id', userId)
          .single();

      if (userData != null) {
        // Crear el usuario con la especialidad completa
        final userDataWithSpecialty = Map<String, dynamic>.from(userData);

        // Mover el objeto specialties a specialty para que coincida con el modelo
        if (userData['specialties'] != null) {
          userDataWithSpecialty['specialty'] = userData['specialties'];
        }
        userDataWithSpecialty.remove('specialties');

        final cmsUser =
            CmsUser.fromJson(userDataWithSpecialty).copyWith(token: token);
        logger.info('User fetched successfully by ID: ${cmsUser.username}');
        return cmsUser;
      } else {
        logger.error('User not found with ID: $userId');
        return null;
      }
    } catch (e, st) {
      logger.error('Error getting user by ID: $e');
      logger.error('Stack trace: $st');
      return null;
    }
  }
}

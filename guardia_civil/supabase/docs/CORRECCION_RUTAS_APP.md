# 🔧 Corrección de Rutas - App Móvil

## Problema Identificado

La app está usando rutas incorrectas que incluyen `/api/` en el path:

```dart
❌ 'login-register/api/v1/login'
❌ 'login-register/api/v1/register'
❌ 'login-register/api/v1/get_user'
```

Pero el servidor espera:

```dart
✅ 'login-register/v1/login'
✅ 'login-register/v1/register'
✅ 'login-register/v1/get_user'
```

## Correcciones Necesarias en `auth_repository.dart`

### 1. Login (signIn)
```dart
// ❌ ANTES
'login-register/api/v1/login'

// ✅ DESPUÉS
'login-register/v1/login'
```

### 2. Register (signUpAndSignIn)
```dart
// ❌ ANTES
'login-register/api/v1/register'

// ✅ DESPUÉS
'login-register/v1/register'
```

### 3. Get User (getUser)
```dart
// ❌ ANTES
'login-register/api/v1/get_user'

// ✅ DESPUÉS
'login-register/v1/get_user'
```

## Código Corregido Completo

```dart
import 'dart:convert';
import 'package:opn_test_guardia_civil/app/authentification/auth/model/user.dart';
import 'package:opn_test_guardia_civil/app/authentification/auth/model/wp_exception.dart';
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
    return supa.Supabase.instance.client.functions.invoke(
      'login-register/v1/register',  // ✅ CORREGIDO: removido /api/
      body: <String, dynamic>{
        'username': username,
        'first_name': name,
        'last_name': surname,
        'name': '$name $surname',
        'email': email,
        'password': password,
        'phone': phone,
      },
    ).then((result) {
      if (result.status != 200) {
        throw WpException.fromJson(result.data as Map<String, dynamic>);
      } else {
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
    final result = await supa.Supabase.instance.client.functions.invoke(
      'login-register/v1/get_user',  // ✅ CORREGIDO: removido /api/
      headers: {
        'Authorization': 'Bearer $userToken',
      },
    );

    if (result.status != 200) {
      logger.error(
        'Server error getting user ${result.status}: ${result.data}',
      );
      throw Exception('Failed to get user: ${result.status}');
    }

    // Getting the user from supabase with memberships
    final userData = await supa.Supabase.instance.client
        .from('users')
        .select('''
        *,
        user_memberships!inner(
          *,
          membership_level:membership_levels(*)
        )
      ''')
        .eq('id', result.data['id'])
        .single();

    final user = User.fromJson(userData);
    return user;
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await supa.Supabase.instance.client.functions.invoke(
        'login-register/v1/login',  // ✅ CORREGIDO: removido /api/
        body: {
          'email': email,      // ✅ Ahora acepta 'email'
          'password': password
        },
      );

      if (result.status == 200) {
        final responseData = result.data as Map<String, dynamic>;
        return responseData['token'] as String?;
      }

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
      final msg = fe.details['errorMsg'] as String? ??
          'Error de autenticación';
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

  Future<void> updateFcmToken(int userId, String fcmToken) async {
    logger.info('Updating FCM token for user: $userId');
    await supa.Supabase.instance.client.from('users').update({
      'fcm_token': fcmToken,
    }).eq('id', userId);
    logger.info('FCM token updated successfully for user: $userId');
  }

  Future<void> updateFidToken(int userId, String fidToken) async {
    logger.info('Updating FID token for user: $userId');
    await supa.Supabase.instance.client.from('users').update({
      'fid_token': fidToken,
    }).eq('id', userId);
    logger.info('FID token updated successfully for user: $userId');
  }
}
```

## Cambios Adicionales

También cambié el login para usar `'email'` en lugar de `'username'`:

```dart
// ✅ Ahora puedes usar cualquiera de los dos
body: {
  'email': email,      // Funciona con 'email'
  'password': password
},

// O también funciona:
body: {
  'username': email,   // Funciona con 'username'
  'password': password
},
```

## Resumen de Errores y Soluciones

| Endpoint | Ruta Incorrecta | Ruta Correcta | Estado |
|----------|----------------|---------------|---------|
| Login | `login-register/api/v1/login` | `login-register/v1/login` | ✅ Corregido |
| Register | `login-register/api/v1/register` | `login-register/v1/register` | ✅ Corregido |
| Get User | `login-register/api/v1/get_user` | `login-register/v1/get_user` | ✅ Corregido |

## Próximos Pasos

1. ✅ Actualizar `auth_repository.dart` con las rutas corregidas
2. ✅ Reconstruir la app
3. ✅ Probar el login
4. ✅ Verificar que funciona correctamente

---

**Causa del error 404**: La app enviaba `/api/v1/login` pero el servidor interpreta `api` como la versión (en lugar de `v1`), por eso dice `"version":"api"`.

**Solución**: Remover `/api/` de todas las rutas en la app.

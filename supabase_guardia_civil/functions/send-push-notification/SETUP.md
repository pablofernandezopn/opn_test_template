# Configuración de Notificaciones Push - Guía Paso a Paso

Esta guía te ayudará a configurar el sistema completo de notificaciones push para tu aplicación.

## 📋 Resumen del Sistema

El sistema de notificaciones push consta de 3 partes:

1. **App Flutter** (✅ Ya configurado)
   - Obtiene tokens FCM y FID al iniciar
   - Guarda tokens en `SharedPreferences`
   - Actualiza tokens en BD cuando el usuario inicia sesión

2. **Base de Datos** (✅ Ya configurado)
   - Tabla `users` con columnas `fcm_token` y `fid_token`
   - (Opcional) Tabla `notification_logs` para historial

3. **Edge Function** (🆕 Nuevo)
   - API para enviar notificaciones push
   - Busca el token del usuario en BD
   - Envía notificación usando Firebase Cloud Messaging

## 🚀 Pasos de Configuración

### Paso 1: Obtener Service Account de Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto (el mismo que usas en la app)
3. Click en el ícono de engranaje ⚙️ > **Project Settings**
4. Ve a la pestaña **Service Accounts**
5. Asegúrate de que esté seleccionado **Firebase Admin SDK**
6. Click en el botón **Generate new private key**
7. Se descargará un archivo JSON (ej: `opn-guardia-civil-firebase-adminsdk-xxxxx.json`)

⚠️ **IMPORTANTE**: Este archivo contiene credenciales sensibles. No lo compartas ni lo subas a git.

### Paso 2: Configurar Variables de Entorno en Supabase

Tienes dos opciones:

#### Opción A: Usando Supabase Dashboard (Recomendado)

1. Ve a tu proyecto en [Supabase Dashboard](https://app.supabase.com/)
2. Ve a **Project Settings** > **Edge Functions** > **Configuration**
3. Click en **Add secret**
4. Nombre: `FIREBASE_SERVICE_ACCOUNT_JSON`
5. Valor: Abre el archivo JSON descargado y copia TODO su contenido (debe ser un JSON válido de una sola línea o multilínea)
6. Click en **Save**

#### Opción B: Usando Supabase CLI

```bash
# Asegúrate de estar en el directorio del proyecto
cd /path/to/OPN_Test_Guardia_Civil

# Configura el secret (reemplaza con tu archivo)
supabase secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat /path/to/downloaded-service-account.json)"
```

### Paso 3: Desplegar la Edge Function

```bash
# Desde el directorio raíz del proyecto
cd /Users/pablofernandezlucas/Documents/Isyfu/opn_guardia_civil/OPN_Test_Guardia_Civil

# Desplegar la función
supabase functions deploy send-push-notification

# Verificar que se desplegó correctamente
supabase functions list
```

### Paso 4: (Opcional) Crear Tabla de Logs

Si quieres guardar un historial de notificaciones enviadas:

```bash
# Aplicar la migración
supabase db push

# O manualmente en el SQL Editor de Supabase Dashboard
# Copia y pega el contenido de: supabase/migrations/00018_create_notification_logs_table.sql
```

### Paso 5: Probar la Función

#### Opción A: Usando curl

```bash
# Edita el archivo de test con tus datos
nano supabase/functions/send-push-notification/test-notification.sh

# Actualiza estas variables:
# SUPABASE_URL="https://tu-proyecto.supabase.co"
# SUPABASE_ANON_KEY="tu-anon-key"

# Ejecuta el test
./supabase/functions/send-push-notification/test-notification.sh
```

#### Opción B: Desde Flutter

Agrega este helper a tu app:

```dart
// lib/app/shared/services/notification_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../bootstrap.dart';

class NotificationService {
  static Future<bool> sendNotificationToUser({
    required int userId,
    required String title,
    required String body,
    String? imageUrl,
    String? route,
    Map<String, String>? data,
  }) async {
    try {
      logger.info('📤 Sending notification to user $userId');

      final response = await Supabase.instance.client.functions.invoke(
        'send-push-notification',
        body: {
          'user_id': userId,
          'title': title,
          'body': body,
          if (imageUrl != null) 'image_url': imageUrl,
          if (route != null) 'route': route,
          if (data != null) 'data': data,
        },
      );

      if (response.status == 200) {
        logger.info('✅ Notification sent successfully');
        logger.debug('FCM Message ID: ${response.data['fcm_message_id']}');
        return true;
      } else {
        logger.error('❌ Failed to send notification: ${response.data['error']}');
        return false;
      }
    } catch (e, stackTrace) {
      logger.error('❌ Exception sending notification: $e');
      logger.debug('StackTrace: $stackTrace');
      return false;
    }
  }
}

// Uso
await NotificationService.sendNotificationToUser(
  userId: 123,
  title: '🎉 Nuevo logro',
  body: 'Has completado el nivel 10',
  imageUrl: 'https://example.com/achievement.png',
  route: '/achievements',
);
```

## ✅ Verificación

Para verificar que todo funciona:

1. **Verifica que el usuario tiene token FCM**:
   ```sql
   SELECT id, username, fcm_token, fid_token
   FROM users
   WHERE id = 1;
   ```

2. **Envía una notificación de prueba**:
   ```bash
   curl -X POST \
     https://tu-proyecto.supabase.co/functions/v1/send-push-notification \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer TU_ANON_KEY" \
     -d '{
       "user_id": 1,
       "title": "Test 🔔",
       "body": "Si ves esto, ¡funciona!"
     }'
   ```

3. **Revisa los logs**:
   ```bash
   supabase functions logs send-push-notification
   ```

## 🔍 Troubleshooting

### Error: "FIREBASE_SERVICE_ACCOUNT_JSON not found"

**Causa**: La variable de entorno no está configurada.

**Solución**:
1. Verifica en Supabase Dashboard > Edge Functions > Configuration
2. Asegúrate de que el nombre sea exactamente `FIREBASE_SERVICE_ACCOUNT_JSON`
3. Re-despliega la función después de agregar el secret

### Error: "User does not have a FCM token"

**Causa**: El usuario no ha iniciado sesión en la app o la app no pudo obtener el token.

**Solución**:
1. Abre la app en el dispositivo del usuario
2. Asegúrate de que el usuario inicie sesión
3. Verifica en los logs de Flutter que el token se obtuvo correctamente
4. Consulta la BD para confirmar que el token se guardó

### Error: "Failed to get access token"

**Causa**: El JSON del Service Account es inválido.

**Solución**:
1. Descarga nuevamente el Service Account desde Firebase Console
2. Verifica que el JSON sea válido (usa un validador JSON online)
3. Copia el JSON completo sin modificarlo
4. Actualiza el secret en Supabase

### La notificación no llega al dispositivo

**Posibles causas**:
1. El token FCM está desactualizado (los tokens expiran)
2. La app no está instalada o se desinstaló
3. Las notificaciones están deshabilitadas en configuración del dispositivo
4. El dispositivo está offline

**Solución**:
1. Pide al usuario que abra la app y vuelva a iniciar sesión
2. Verifica los permisos de notificaciones en el dispositivo
3. Revisa los logs de FCM en Firebase Console

## 📊 Monitoreo

### Ver logs en tiempo real

```bash
supabase functions logs send-push-notification --follow
```

### Ver notificaciones enviadas (si creaste la tabla de logs)

```sql
-- Últimas 10 notificaciones
SELECT
  nl.id,
  nl.title,
  nl.body,
  u.username,
  nl.sent_at
FROM notification_logs nl
JOIN users u ON u.id = nl.user_id
ORDER BY nl.sent_at DESC
LIMIT 10;

-- Estadísticas por usuario
SELECT * FROM notification_stats WHERE user_id = 1;
```

## 🔒 Seguridad

### Recomendaciones:

1. **Valida permisos antes de enviar notificaciones**:
   ```dart
   // Solo administradores pueden enviar notificaciones
   if (!currentUser.isAdmin) {
     throw Exception('No tienes permisos para enviar notificaciones');
   }
   ```

2. **Implementa rate limiting** para evitar spam

3. **No expongas la Service Role Key** en el cliente

4. **Usa RLS en notification_logs** (ya incluido en la migración)

## 📱 Uso en Producción

### Casos de uso comunes:

1. **Notificación cuando hay un nuevo test**:
   ```dart
   await NotificationService.sendNotificationToUser(
     userId: student.id,
     title: 'Nuevo test disponible 📝',
     body: 'Test de ${subject.name} - ${topic.name}',
     route: '/tests/${test.id}',
   );
   ```

2. **Recordatorio de estudio**:
   ```dart
   await NotificationService.sendNotificationToUser(
     userId: student.id,
     title: '⏰ Recordatorio de estudio',
     body: 'Llevas 3 días sin practicar. ¡Mantén tu racha!',
     route: '/home',
   );
   ```

3. **Notificación de resultados**:
   ```dart
   await NotificationService.sendNotificationToUser(
     userId: student.id,
     title: '📊 Resultados disponibles',
     body: 'Has obtenido ${score}% en el test de ${subject.name}',
     imageUrl: score >= 80
       ? 'https://cdn.example.com/success.png'
       : 'https://cdn.example.com/try-again.png',
     route: '/results/${test.id}',
   );
   ```

4. **Notificación con imagen**:
   ```dart
   await NotificationService.sendNotificationToUser(
     userId: student.id,
     title: '🎉 ¡Nuevo logro desbloqueado!',
     body: 'Has completado 100 tests exitosamente',
     imageUrl: 'https://cdn.example.com/achievement-100.png',
     route: '/achievements',
     data: {
       'achievement_id': '100_tests',
       'points': '500',
     },
   );
   ```

## 📚 Recursos Adicionales

- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Flutter Firebase Messaging](https://firebase.flutter.dev/docs/messaging/overview)

## 💡 Tips

1. **Personaliza las notificaciones**: Usa el nombre del usuario en el mensaje
2. **Usa emojis**: Hacen las notificaciones más atractivas
3. **Imágenes atractivas**: Usa imágenes de alta calidad (1200x600px recomendado)
4. **Testing**: Prueba en dispositivos reales Android y iOS
5. **Timing**: Envía notificaciones en horarios apropiados (no de madrugada)

## ❓ Soporte

Si tienes problemas:
1. Revisa los logs de la Edge Function
2. Verifica que el token FCM esté actualizado en la BD
3. Consulta la documentación de Firebase
4. Revisa los logs de la app Flutter
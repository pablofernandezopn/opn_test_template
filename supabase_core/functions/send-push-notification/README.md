# Send Push Notification Edge Function

Edge Function para enviar notificaciones push a usuarios específicos usando Firebase Cloud Messaging (FCM).

## Características

- ✅ Envío de notificaciones push a usuarios individuales
- ✅ Soporte para imágenes en notificaciones
- ✅ Datos personalizados y rutas de navegación
- ✅ Compatible con Android y iOS
- ✅ Registro de notificaciones enviadas (opcional)

## Configuración

### 1. Obtener el Service Account de Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. Ve a **Project Settings** (⚙️) > **Service Accounts**
4. Click en **Generate new private key**
5. Descarga el archivo JSON

### 2. Configurar variables de entorno

Agrega el contenido del archivo JSON a tus variables de entorno en Supabase:

```bash
# Opción 1: Desde el dashboard de Supabase
# Ve a Project Settings > Edge Functions > Add new secret
# Nombre: FIREBASE_SERVICE_ACCOUNT_JSON
# Valor: Pega todo el contenido del JSON descargado

# Opción 2: Usando Supabase CLI
supabase secrets set FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}'
```

### 3. Desplegar la función

```bash
# Desde el directorio raíz del proyecto
supabase functions deploy send-push-notification
```

## Uso

### Request

**Endpoint:** `POST /send-push-notification`

**Headers:**
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer YOUR_SUPABASE_ANON_KEY"
}
```

**Body:**
```json
{
  "user_id": 123,
  "title": "Título de la notificación",
  "body": "Mensaje de la notificación",
  "image_url": "https://example.com/image.png",  // Opcional
  "route": "/home/profile",  // Opcional - ruta para navegar
  "data": {  // Opcional - datos adicionales
    "key1": "value1",
    "key2": "value2"
  }
}
```

### Ejemplos

#### 1. Notificación simple

```bash
curl -X POST \
  https://your-project.supabase.co/functions/v1/send-push-notification \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -d '{
    "user_id": 123,
    "title": "Nuevo test disponible",
    "body": "Hay un nuevo test de matemáticas esperando por ti"
  }'
```

#### 2. Notificación con imagen

```bash
curl -X POST \
  https://your-project.supabase.co/functions/v1/send-push-notification \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -d '{
    "user_id": 123,
    "title": "¡Felicidades!",
    "body": "Has completado el nivel 5",
    "image_url": "https://example.com/celebration.png"
  }'
```

#### 3. Notificación con navegación

```bash
curl -X POST \
  https://your-project.supabase.co/functions/v1/send-push-notification \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -d '{
    "user_id": 123,
    "title": "Mensaje nuevo",
    "body": "Tienes un mensaje del profesor",
    "route": "/chat/123",
    "data": {
      "chat_id": "123",
      "sender_id": "456"
    }
  }'
```

### Desde Flutter/Dart

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> sendNotification({
  required int userId,
  required String title,
  required String body,
  String? imageUrl,
  String? route,
  Map<String, String>? data,
}) async {
  try {
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
      print('✅ Notification sent successfully');
      print('Message ID: ${response.data['fcm_message_id']}');
    } else {
      print('❌ Error: ${response.data['error']}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

// Ejemplo de uso
await sendNotification(
  userId: 123,
  title: 'Nuevo test disponible',
  body: 'Hay un nuevo test de matemáticas',
  imageUrl: 'https://example.com/math-icon.png',
  route: '/tests/456',
);
```

### Response

**Success (200):**
```json
{
  "success": true,
  "message": "Notification sent successfully",
  "fcm_message_id": "projects/your-project/messages/0:1234567890",
  "user": {
    "id": 123,
    "username": "juan_garcia",
    "email": "juan@example.com"
  }
}
```

**Error (400/404/500):**
```json
{
  "success": false,
  "error": "Error message",
  "details": "Detailed error information"
}
```

## Casos de error comunes

### User not found
```json
{
  "success": false,
  "error": "User not found"
}
```
**Solución:** Verifica que el `user_id` existe en la tabla `users`.

### User does not have FCM token
```json
{
  "success": false,
  "error": "User does not have a FCM token. The app may not be installed or notifications are disabled."
}
```
**Solución:** El usuario necesita:
1. Tener la app instalada
2. Haber iniciado sesión al menos una vez
3. Haber aceptado los permisos de notificaciones

### Firebase authentication error
```json
{
  "success": false,
  "error": "Failed to get access token"
}
```
**Solución:** Verifica que `FIREBASE_SERVICE_ACCOUNT_JSON` esté configurado correctamente.

## Estructura de datos soportada

### Notificación básica
- **title** (requerido): Título de la notificación
- **body** (requerido): Cuerpo del mensaje
- **user_id** (requerido): ID del usuario destinatario

### Campos opcionales
- **image_url**: URL completa de una imagen (PNG, JPG, etc.)
  - La imagen debe ser accesible públicamente
  - Tamaño recomendado: 2:1 (ej: 1200x600px)
  - Formatos soportados: PNG, JPG, JPEG, WebP

- **route**: Ruta de navegación en la app
  - Ejemplo: `/home`, `/chat/123`, `/profile`
  - La app debe tener configurado el router para manejar estas rutas

- **data**: Objeto con datos personalizados
  - Solo valores string: `{"key": "value"}`
  - La app puede leer estos datos cuando se recibe la notificación

## Formato de imágenes

Las imágenes en notificaciones tienen algunas limitaciones:

### Android
- Se muestra en la notificación expandida
- Relación de aspecto: 2:1 recomendado
- Tamaño máximo: 1MB

### iOS
- Se muestra cuando el usuario presiona la notificación
- Requiere extensión de servicio de notificación para renderizar
- Tamaño máximo: 10MB

### Ejemplo con imagen
```json
{
  "user_id": 123,
  "title": "Nueva actualización",
  "body": "Descubre las nuevas funcionalidades",
  "image_url": "https://tu-cdn.com/update-banner.png"
}
```

## Markdown y formato de texto

Firebase Cloud Messaging **no soporta Markdown** directamente. Sin embargo, puedes:

1. **Usar emojis**: ✅ Funcionan perfectamente
   ```json
   {
     "title": "🎉 ¡Felicidades!",
     "body": "Has ganado 100 puntos ⭐"
   }
   ```

2. **Usar saltos de línea**: En Android se respetan los `\n`
   ```json
   {
     "title": "Resumen del día",
     "body": "Preguntas: 50\nCorrectas: 45\nPorcentaje: 90%"
   }
   ```

3. **HTML básico**: Solo en algunas versiones de Android
   - No es confiable, mejor evitarlo

4. **Rich media**: Usar `image_url` para contenido visual

## Testing local

```bash
# Servir la función localmente
supabase functions serve send-push-notification --env-file supabase/functions/.env

# En otra terminal, probar la función
curl -X POST \
  http://localhost:54321/functions/v1/send-push-notification \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -d '{
    "user_id": 123,
    "title": "Test notification",
    "body": "This is a test"
  }'
```

## Logs y debugging

Los logs se pueden ver en:
- **Supabase Dashboard**: Project > Edge Functions > Logs
- **CLI**: `supabase functions logs send-push-notification`

## Tabla de logs (opcional)

Si quieres guardar un historial de notificaciones enviadas, crea esta tabla:

```sql
CREATE TABLE notification_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  image_url TEXT,
  fcm_response JSONB,
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice para consultas rápidas
CREATE INDEX idx_notification_logs_user_id ON notification_logs(user_id);
CREATE INDEX idx_notification_logs_sent_at ON notification_logs(sent_at DESC);
```

## Seguridad

La función usa `SUPABASE_SERVICE_ROLE_KEY` para acceder a la tabla de usuarios, por lo que puede leer todos los tokens FCM. Asegúrate de:

1. **No exponer la service role key** en el cliente
2. **Validar permisos** antes de llamar esta función
3. **Implementar rate limiting** si es necesario
4. **Usar RLS (Row Level Security)** en la tabla `notification_logs`

## Limitaciones

- **FCM tiene rate limits**: ~500 mensajes/segundo para mensajes individuales
- **Tokens pueden expirar**: Si un token falla, considera limpiarlo de la BD
- **Tamaño del payload**: Máximo 4KB para el mensaje completo
- **Imágenes**: Deben ser públicamente accesibles

## Soporte

Para más información sobre FCM:
- [FCM Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FCM API Reference](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages)
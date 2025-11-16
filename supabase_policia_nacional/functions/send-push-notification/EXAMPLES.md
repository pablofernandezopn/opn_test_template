# Ejemplos de Uso - Send Push Notification

Ejemplos prácticos de cómo enviar notificaciones push desde diferentes contextos.

## 📱 Desde Flutter/Dart

### 1. Servicio completo de notificaciones

```dart
// lib/app/shared/services/notification_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../bootstrap.dart';

class NotificationService {
  /// Envía una notificación push a un usuario específico
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
        final data = response.data as Map<String, dynamic>;
        logger.info('✅ Notification sent successfully');
        logger.debug('FCM Message ID: ${data['fcm_message_id']}');
        return true;
      } else {
        final data = response.data as Map<String, dynamic>;
        logger.error('❌ Failed to send notification: ${data['error']}');
        return false;
      }
    } catch (e, stackTrace) {
      logger.error('❌ Exception sending notification: $e');
      logger.debug('StackTrace: $stackTrace');
      return false;
    }
  }

  /// Envía notificaciones a múltiples usuarios
  static Future<Map<int, bool>> sendNotificationToMultipleUsers({
    required List<int> userIds,
    required String title,
    required String body,
    String? imageUrl,
    String? route,
    Map<String, String>? data,
  }) async {
    final results = <int, bool>{};

    for (final userId in userIds) {
      final success = await sendNotificationToUser(
        userId: userId,
        title: title,
        body: body,
        imageUrl: imageUrl,
        route: route,
        data: data,
      );
      results[userId] = success;

      // Pequeña pausa para no saturar el servidor
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return results;
  }
}
```

### 2. Ejemplos de uso específicos

```dart
// Ejemplo 1: Notificación de nuevo test
Future<void> notifyNewTest({
  required int studentId,
  required String subjectName,
  required String topicName,
  required int testId,
}) async {
  await NotificationService.sendNotificationToUser(
    userId: studentId,
    title: '📝 Nuevo test disponible',
    body: 'Test de $subjectName - $topicName',
    route: '/tests/$testId',
    data: {
      'test_id': testId.toString(),
      'type': 'new_test',
    },
  );
}

// Ejemplo 2: Notificación de resultados
Future<void> notifyTestResults({
  required int studentId,
  required String testName,
  required int score,
  required int testId,
}) async {
  final emoji = score >= 80 ? '🎉' : score >= 60 ? '👍' : '💪';
  final message = score >= 80
      ? '¡Excelente trabajo!'
      : score >= 60
          ? 'Buen trabajo, sigue así'
          : 'Sigue practicando, ¡tú puedes!';

  await NotificationService.sendNotificationToUser(
    userId: studentId,
    title: '$emoji Resultados disponibles',
    body: 'Has obtenido $score% en $testName. $message',
    route: '/results/$testId',
    data: {
      'test_id': testId.toString(),
      'score': score.toString(),
      'type': 'test_results',
    },
  );
}

// Ejemplo 3: Recordatorio de estudio
Future<void> sendStudyReminder({
  required int studentId,
  required String userName,
  required int daysSinceLastStudy,
}) async {
  await NotificationService.sendNotificationToUser(
    userId: studentId,
    title: '⏰ Recordatorio de estudio',
    body: '¡Hola $userName! Llevas $daysSinceLastStudy días sin practicar. ¡Mantén tu racha!',
    route: '/home',
    data: {
      'type': 'study_reminder',
      'days_since_last_study': daysSinceLastStudy.toString(),
    },
  );
}

// Ejemplo 4: Logro desbloqueado
Future<void> notifyAchievementUnlocked({
  required int studentId,
  required String achievementName,
  required String achievementDescription,
  required String achievementImageUrl,
  required int points,
}) async {
  await NotificationService.sendNotificationToUser(
    userId: studentId,
    title: '🎉 ¡Nuevo logro desbloqueado!',
    body: '$achievementName - $achievementDescription',
    imageUrl: achievementImageUrl,
    route: '/achievements',
    data: {
      'type': 'achievement',
      'achievement_name': achievementName,
      'points': points.toString(),
    },
  );
}

// Ejemplo 5: Mensaje del profesor
Future<void> notifyTeacherMessage({
  required int studentId,
  required String teacherName,
  required String message,
  required String chatId,
}) async {
  await NotificationService.sendNotificationToUser(
    userId: studentId,
    title: '💬 Mensaje de $teacherName',
    body: message.length > 50 ? '${message.substring(0, 50)}...' : message,
    route: '/chat/$chatId',
    data: {
      'type': 'chat_message',
      'chat_id': chatId,
      'sender_name': teacherName,
    },
  );
}

// Ejemplo 6: Notificar a todos los estudiantes de una clase
Future<void> notifyClassStudents({
  required List<int> studentIds,
  required String className,
  required String announcement,
}) async {
  final results = await NotificationService.sendNotificationToMultipleUsers(
    userIds: studentIds,
    title: '📢 Anuncio para $className',
    body: announcement,
    data: {
      'type': 'class_announcement',
      'class_name': className,
    },
  );

  // Log de resultados
  final successCount = results.values.where((success) => success).length;
  logger.info('Notificaciones enviadas: $successCount/${studentIds.length}');
}
```

### 3. Widget de ejemplo para enviar notificaciones desde admin

```dart
// lib/app/features/admin/view/send_notification_dialog.dart

import 'package:flutter/material.dart';
import '../../shared/services/notification_service.dart';

class SendNotificationDialog extends StatefulWidget {
  final int userId;
  final String userName;

  const SendNotificationDialog({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<SendNotificationDialog> createState() => _SendNotificationDialogState();
}

class _SendNotificationDialogState extends State<SendNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _routeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    _routeController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await NotificationService.sendNotificationToUser(
        userId: widget.userId,
        title: _titleController.text,
        body: _bodyController.text,
        imageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
        route: _routeController.text.isEmpty ? null : _routeController.text,
      );

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '✅ Notificación enviada a ${widget.userName}'
                  : '❌ Error al enviar notificación',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enviar notificación a ${widget.userName}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ej: Nuevo test disponible',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Mensaje *',
                  hintText: 'Ej: Hay un nuevo test de matemáticas',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El mensaje es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de imagen (opcional)',
                  hintText: 'https://example.com/image.png',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _routeController,
                decoration: const InputDecoration(
                  labelText: 'Ruta (opcional)',
                  hintText: '/tests/123',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _sendNotification,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar'),
        ),
      ],
    );
  }
}

// Uso del diálogo
void showSendNotificationDialog(BuildContext context, int userId, String userName) {
  showDialog(
    context: context,
    builder: (context) => SendNotificationDialog(
      userId: userId,
      userName: userName,
    ),
  );
}
```

## 🌐 Desde Node.js / TypeScript

```typescript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://your-project.supabase.co',
  'your-anon-key'
)

// Función para enviar notificación
async function sendPushNotification({
  userId,
  title,
  body,
  imageUrl,
  route,
  data
}: {
  userId: number
  title: string
  body: string
  imageUrl?: string
  route?: string
  data?: Record<string, string>
}) {
  try {
    const { data: result, error } = await supabase.functions.invoke(
      'send-push-notification',
      {
        body: {
          user_id: userId,
          title,
          body,
          ...(imageUrl && { image_url: imageUrl }),
          ...(route && { route }),
          ...(data && { data })
        }
      }
    )

    if (error) {
      console.error('Error:', error)
      return false
    }

    console.log('✅ Notification sent:', result.fcm_message_id)
    return true
  } catch (error) {
    console.error('Exception:', error)
    return false
  }
}

// Ejemplo de uso
await sendPushNotification({
  userId: 123,
  title: '🎉 Nuevo logro',
  body: 'Has completado el nivel 10',
  imageUrl: 'https://example.com/achievement.png',
  route: '/achievements'
})
```

## 🐍 Desde Python

```python
import requests
import json

SUPABASE_URL = "https://your-project.supabase.co"
SUPABASE_ANON_KEY = "your-anon-key"

def send_push_notification(
    user_id: int,
    title: str,
    body: str,
    image_url: str = None,
    route: str = None,
    data: dict = None
) -> bool:
    """
    Envía una notificación push a un usuario específico
    """
    url = f"{SUPABASE_URL}/functions/v1/send-push-notification"

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}"
    }

    payload = {
        "user_id": user_id,
        "title": title,
        "body": body
    }

    if image_url:
        payload["image_url"] = image_url
    if route:
        payload["route"] = route
    if data:
        payload["data"] = data

    try:
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()

        result = response.json()
        print(f"✅ Notification sent: {result.get('fcm_message_id')}")
        return True

    except requests.exceptions.RequestException as e:
        print(f"❌ Error: {e}")
        if hasattr(e.response, 'text'):
            print(f"Response: {e.response.text}")
        return False

# Ejemplo de uso
send_push_notification(
    user_id=123,
    title="🎉 Nuevo logro",
    body="Has completado el nivel 10",
    image_url="https://example.com/achievement.png",
    route="/achievements"
)
```

## 🔧 Desde cURL

### Notificación simple
```bash
curl -X POST \
  https://your-project.supabase.co/functions/v1/send-push-notification \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -d '{
    "user_id": 123,
    "title": "Test Simple",
    "body": "Esta es una notificación de prueba"
  }'
```

### Notificación con imagen
```bash
curl -X POST \
  https://your-project.supabase.co/functions/v1/send-push-notification \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -d '{
    "user_id": 123,
    "title": "🖼️ Con Imagen",
    "body": "Esta notificación incluye una imagen",
    "image_url": "https://picsum.photos/1200/600"
  }'
```

### Notificación completa
```bash
curl -X POST \
  https://your-project.supabase.co/functions/v1/send-push-notification \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -d '{
    "user_id": 123,
    "title": "🎉 Logro desbloqueado",
    "body": "Has completado 100 tests exitosamente",
    "image_url": "https://example.com/achievement.png",
    "route": "/achievements",
    "data": {
      "achievement_id": "100_tests",
      "points": "500"
    }
  }'
```

## 📊 Casos de uso avanzados

### 1. Cron job para recordatorios diarios

```typescript
// Ejecutar diariamente a las 9 AM
async function sendDailyReminders() {
  const { data: inactiveUsers } = await supabase
    .from('users')
    .select('id, username, last_activity')
    .lt('last_activity', new Date(Date.now() - 3 * 24 * 60 * 60 * 1000)) // 3 días
    .not('fcm_token', 'is', null)

  for (const user of inactiveUsers || []) {
    await sendPushNotification({
      userId: user.id,
      title: `⏰ ¡Hola ${user.username}!`,
      body: 'Llevas 3 días sin practicar. ¡No pierdas tu progreso!',
      route: '/home'
    })
  }
}
```

### 2. Notificación al completar un test

```dart
// En tu TestRepository o TestCubit
Future<void> submitTest(int testId, List<Answer> answers) async {
  // ... lógica para guardar respuestas y calcular score

  final score = calculateScore(answers);

  // Enviar notificación con resultados
  await NotificationService.sendNotificationToUser(
    userId: currentUserId,
    title: score >= 80 ? '🎉 ¡Excelente!' : '📊 Resultados listos',
    body: 'Has obtenido $score% en el test',
    route: '/results/$testId',
  );
}
```

### 3. Sistema de logros con notificaciones

```dart
class AchievementService {
  Future<void> checkAndUnlockAchievements(int userId) async {
    final achievements = await _getUnlockedAchievements(userId);

    for (final achievement in achievements) {
      // Guardar logro en BD
      await _saveAchievement(userId, achievement.id);

      // Enviar notificación
      await NotificationService.sendNotificationToUser(
        userId: userId,
        title: '🏆 ¡Nuevo logro desbloqueado!',
        body: achievement.name,
        imageUrl: achievement.imageUrl,
        route: '/achievements',
        data: {
          'achievement_id': achievement.id.toString(),
          'points': achievement.points.toString(),
        },
      );
    }
  }
}
```

## 🔔 Tips y mejores prácticas

1. **Personaliza los mensajes**: Usa el nombre del usuario
2. **Usa emojis**: Hacen las notificaciones más atractivas
3. **Sé conciso**: Máximo 2 líneas en el body
4. **Imágenes de calidad**: 1200x600px recomendado
5. **Horarios apropiados**: No envíes notificaciones de madrugada
6. **Rate limiting**: No envíes más de 1 notificación por usuario cada 5 minutos
7. **Testing**: Prueba en dispositivos reales
8. **Manejo de errores**: Siempre captura excepciones
9. **Logs**: Registra todas las notificaciones enviadas
10. **Feedback del usuario**: Permite desactivar ciertos tipos de notificaciones
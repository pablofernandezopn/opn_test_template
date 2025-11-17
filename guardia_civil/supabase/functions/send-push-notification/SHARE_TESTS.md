# Compartir Tests con Usuarios - Guía Completa

Esta guía explica cómo enviar notificaciones push a usuarios para compartir tests (individuales o grupales) usando el sistema de notificaciones.

## 📚 Rutas Disponibles

Se han creado rutas especiales que solo necesitan el **ID** del test, no objetos complejos:

| Tipo de Test | Ruta | Parámetros |
|--------------|------|------------|
| **Test Individual** | `/preview-topic/:topicId` | `topicId` (número) |
| **Test Grupal** | `/preview-topic-group/:topicGroupId` | `topicGroupId` (número) |

## 🎯 Cómo Funciona

```
1. Backend envía notificación con route: "/preview-topic/123"
2. Usuario toca la notificación
3. App navega a PreviewTopicByIdPage
4. Página carga el Topic/TopicGroup por ID
5. Se muestra PreviewTopicPage con toda la información
6. Usuario puede iniciar el test
```

## 📱 Ejemplos de Uso

### 1. Compartir un Topic Individual

```dart
// Desde Flutter
await Supabase.instance.client.functions.invoke(
  'send-push-notification',
  body: {
    'user_id': 123,
    'title': '📝 Nuevo test disponible',
    'body': 'Test de Constitución Española - 50 preguntas',
    'image_url': 'https://cdn.example.com/constitucion.png',
    'route': '/preview-topic/42',  // ← Topic ID = 42
    'data': {
      'topic_id': '42',
      'type': 'test_share',
    }
  },
);
```

### 2. Compartir un Test Grupal

```dart
// Desde Flutter
await Supabase.instance.client.functions.invoke(
  'send-push-notification',
  body: {
    'user_id': 456,
    'title': '🎯 Examen completo disponible',
    'body': 'Simulacro Guardia Civil 2024 - 100 preguntas en 3 partes',
    'image_url': 'https://cdn.example.com/simulacro.png',
    'route': '/preview-topic-group/15',  // ← TopicGroup ID = 15
    'data': {
      'topic_group_id': '15',
      'type': 'grouped_test_share',
    }
  },
);
```

### 3. Desde cURL (Testing)

#### Test Individual
```bash
curl -X POST \
  https://your-project.supabase.co/functions/v1/send-push-notification \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -d '{
    "user_id": 123,
    "title": "📝 Nuevo test disponible",
    "body": "Test de Derecho Penal - 30 preguntas",
    "image_url": "https://cdn.example.com/derecho-penal.png",
    "route": "/preview-topic/42"
  }'
```

#### Test Grupal
```bash
curl -X POST \
  https://your-project.supabase.co/functions/v1/send-push-notification \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -d '{
    "user_id": 456,
    "title": "🎯 Simulacro completo",
    "body": "Simulacro oficial - 100 preguntas",
    "image_url": "https://cdn.example.com/simulacro.png",
    "route": "/preview-topic-group/15"
  }'
```

### 4. Desde Node.js/TypeScript

```typescript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://your-project.supabase.co',
  'your-anon-key'
)

// Compartir test individual
async function shareTopicWithUser(
  userId: number,
  topicId: number,
  topicName: string,
  imageUrl?: string
) {
  const { data, error } = await supabase.functions.invoke(
    'send-push-notification',
    {
      body: {
        user_id: userId,
        title: '📝 Nuevo test disponible',
        body: `${topicName} está listo para practicar`,
        image_url: imageUrl,
        route: `/preview-topic/${topicId}`,
        data: {
          topic_id: topicId.toString(),
          type: 'test_share'
        }
      }
    }
  )

  if (error) throw error
  return data
}

// Compartir test grupal
async function shareTopicGroupWithUser(
  userId: number,
  topicGroupId: number,
  groupName: string,
  imageUrl?: string
) {
  const { data, error } = await supabase.functions.invoke(
    'send-push-notification',
    {
      body: {
        user_id: userId,
        title: '🎯 Examen completo disponible',
        body: `${groupName} - Simulacro oficial`,
        image_url: imageUrl,
        route: `/preview-topic-group/${topicGroupId}`,
        data: {
          topic_group_id: topicGroupId.toString(),
          type: 'grouped_test_share'
        }
      }
    }
  )

  if (error) throw error
  return data
}

// Uso
await shareTopicWithUser(123, 42, 'Constitución Española', 'https://...')
await shareTopicGroupWithUser(456, 15, 'Simulacro Guardia Civil 2024', 'https://...')
```

### 5. Compartir con Múltiples Usuarios

```typescript
// Compartir un test con todos los usuarios de un grupo
async function shareTopicWithGroup(
  userIds: number[],
  topicId: number,
  topicName: string,
  imageUrl?: string
) {
  const promises = userIds.map(userId =>
    supabase.functions.invoke('send-push-notification', {
      body: {
        user_id: userId,
        title: '📝 Nuevo test en grupo',
        body: `${topicName} disponible para todos`,
        image_url: imageUrl,
        route: `/preview-topic/${topicId}`,
        data: {
          topic_id: topicId.toString(),
          type: 'group_test_share'
        }
      }
    })
  )

  return await Promise.all(promises)
}

// Uso
const studentIds = [123, 456, 789, 101]
await shareTopicWithGroup(studentIds, 42, 'Test de Derecho', 'https://...')
```

## 🎨 Mejores Prácticas

### 1. Títulos Descriptivos

```dart
// ✅ Bueno - Específico y claro
'title': '📝 Test de Constitución - 50 preguntas'

// ❌ Malo - Muy genérico
'title': 'Nuevo test'
```

### 2. Descripción Completa

```dart
// ✅ Bueno - Información útil
'body': 'Constitución Española - 50 preguntas | 60 minutos | Nivel: Intermedio'

// ❌ Malo - Poco informativo
'body': 'Tienes un test nuevo'
```

### 3. Imágenes Atractivas

```dart
// Usa imágenes de calidad
'image_url': 'https://cdn.example.com/tests/constitucion-1200x600.png'

// Recomendaciones:
// - Tamaño: 1200x600px (ratio 2:1)
// - Formato: PNG o JPG
// - Peso máximo: 1MB
// - Acceso público
```

### 4. Datos Adicionales

```dart
'data': {
  'topic_id': '42',
  'topic_name': 'Constitución Española',
  'difficulty': 'intermediate',
  'duration_minutes': '60',
  'total_questions': '50',
  'type': 'test_share',
  'timestamp': DateTime.now().toIso8601String(),
}
```

## 🔍 Cómo Obtener los IDs

### Desde la Base de Datos

```sql
-- Obtener topics individuales
SELECT id, topic_name, total_questions, duration_minutes, image_url
FROM topics
WHERE academy_id = 1
ORDER BY created_at DESC;

-- Obtener topic groups
SELECT id, name, description, image_url
FROM topic_groups
WHERE academy_id = 1
ORDER BY created_at DESC;

-- Verificar que el usuario tiene FCM token
SELECT id, username, email, fcm_token
FROM users
WHERE id = 123;
```

### Desde Flutter

```dart
// Obtener todos los topics
final topics = await Supabase.instance.client
    .from('topics')
    .select()
    .eq('academy_id', academyId)
    .order('created_at', ascending: false);

// Obtener topic groups
final groups = await Supabase.instance.client
    .from('topic_groups')
    .select()
    .eq('academy_id', academyId);

// Compartir el primer topic con un usuario
if (topics.isNotEmpty) {
  final topic = topics[0];
  await shareTopicWithUser(
    userId: 123,
    topicId: topic['id'],
    topicName: topic['topic_name'],
    imageUrl: topic['image_url'],
  );
}
```

## 📊 Casos de Uso Reales

### 1. Notificar Nuevo Contenido

```dart
// Cuando agregas un nuevo test, notifica a todos los usuarios
Future<void> notifyNewTopicToAllUsers(Topic topic) async {
  // Obtener todos los usuarios con FCM token
  final users = await Supabase.instance.client
      .from('users')
      .select('id, username')
      .not('fcm_token', 'is', null);

  for (final user in users) {
    await Supabase.instance.client.functions.invoke(
      'send-push-notification',
      body: {
        'user_id': user['id'],
        'title': '🆕 Nuevo test disponible',
        'body': '${topic.topicName} - ${topic.totalQuestions} preguntas',
        'image_url': topic.imageUrl,
        'route': '/preview-topic/${topic.id}',
      },
    );

    // Pequeña pausa para no saturar
    await Future.delayed(Duration(milliseconds: 100));
  }
}
```

### 2. Recordatorio de Test Pendiente

```dart
// Enviar recordatorio a usuarios que no han completado un test
Future<void> sendTestReminder(int topicId, String topicName) async {
  // Obtener usuarios que no han completado el test
  final incompletedUsers = await Supabase.instance.client
      .from('users')
      .select('id, username')
      .not('fcm_token', 'is', null);

  // Aquí filtrarías los que ya completaron el test
  // (lógica específica según tu esquema de BD)

  for (final user in incompletedUsers) {
    await Supabase.instance.client.functions.invoke(
      'send-push-notification',
      body: {
        'user_id': user['id'],
        'title': '⏰ Recordatorio de test',
        'body': 'No olvides completar: $topicName',
        'route': '/preview-topic/$topicId',
      },
    );
  }
}
```

### 3. Anuncio de Simulacro

```dart
// Anunciar un simulacro oficial próximo
Future<void> announceOfficialSimulation(
  int topicGroupId,
  String groupName,
  DateTime scheduledDate,
) async {
  final users = await Supabase.instance.client
      .from('users')
      .select('id')
      .not('fcm_token', 'is', null);

  final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(scheduledDate);

  for (final user in users) {
    await Supabase.instance.client.functions.invoke(
      'send-push-notification',
      body: {
        'user_id': user['id'],
        'title': '🚨 Simulacro Oficial',
        'body': '$groupName - $dateStr ¡Prepárate!',
        'image_url': 'https://cdn.example.com/simulacro-oficial.png',
        'route': '/preview-topic-group/$topicGroupId',
        'data': {
          'scheduled_date': scheduledDate.toIso8601String(),
          'type': 'official_simulation',
        }
      },
    );
  }
}
```

## 🎓 Servicio Helper en Flutter

Crea un servicio centralizado para compartir tests:

```dart
// lib/app/shared/services/test_sharing_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../bootstrap.dart';

class TestSharingService {
  /// Comparte un test individual con un usuario
  static Future<bool> shareTopicWithUser({
    required int userId,
    required int topicId,
    required String topicName,
    int? totalQuestions,
    int? durationMinutes,
    String? imageUrl,
  }) async {
    try {
      logger.info('📤 Compartiendo topic $topicId con usuario $userId');

      final body = _buildTopicNotificationBody(
        topicName: topicName,
        totalQuestions: totalQuestions,
        durationMinutes: durationMinutes,
      );

      final response = await Supabase.instance.client.functions.invoke(
        'send-push-notification',
        body: {
          'user_id': userId,
          'title': '📝 Nuevo test disponible',
          'body': body,
          if (imageUrl != null) 'image_url': imageUrl,
          'route': '/preview-topic/$topicId',
          'data': {
            'topic_id': topicId.toString(),
            'topic_name': topicName,
            'type': 'test_share',
          }
        },
      );

      if (response.status == 200) {
        logger.info('✅ Test compartido exitosamente');
        return true;
      } else {
        logger.error('❌ Error compartiendo test: ${response.data['error']}');
        return false;
      }
    } catch (e, stackTrace) {
      logger.error('❌ Exception compartiendo test: $e');
      logger.debug('StackTrace: $stackTrace');
      return false;
    }
  }

  /// Comparte un test grupal con un usuario
  static Future<bool> shareTopicGroupWithUser({
    required int userId,
    required int topicGroupId,
    required String groupName,
    int? totalParts,
    int? totalQuestions,
    String? imageUrl,
  }) async {
    try {
      logger.info('📤 Compartiendo topic group $topicGroupId con usuario $userId');

      final body = _buildGroupNotificationBody(
        groupName: groupName,
        totalParts: totalParts,
        totalQuestions: totalQuestions,
      );

      final response = await Supabase.instance.client.functions.invoke(
        'send-push-notification',
        body: {
          'user_id': userId,
          'title': '🎯 Examen completo disponible',
          'body': body,
          if (imageUrl != null) 'image_url': imageUrl,
          'route': '/preview-topic-group/$topicGroupId',
          'data': {
            'topic_group_id': topicGroupId.toString(),
            'group_name': groupName,
            'type': 'grouped_test_share',
          }
        },
      );

      if (response.status == 200) {
        logger.info('✅ Test grupal compartido exitosamente');
        return true;
      } else {
        logger.error('❌ Error compartiendo test grupal: ${response.data['error']}');
        return false;
      }
    } catch (e, stackTrace) {
      logger.error('❌ Exception compartiendo test grupal: $e');
      logger.debug('StackTrace: $stackTrace');
      return false;
    }
  }

  static String _buildTopicNotificationBody({
    required String topicName,
    int? totalQuestions,
    int? durationMinutes,
  }) {
    final parts = <String>[topicName];

    if (totalQuestions != null) {
      parts.add('$totalQuestions preguntas');
    }

    if (durationMinutes != null) {
      parts.add('$durationMinutes min');
    }

    return parts.join(' | ');
  }

  static String _buildGroupNotificationBody({
    required String groupName,
    int? totalParts,
    int? totalQuestions,
  }) {
    final parts = <String>[groupName];

    if (totalParts != null) {
      parts.add('$totalParts partes');
    }

    if (totalQuestions != null) {
      parts.add('$totalQuestions preguntas');
    }

    return parts.join(' | ');
  }
}

// Uso en tu app
await TestSharingService.shareTopicWithUser(
  userId: 123,
  topicId: 42,
  topicName: 'Constitución Española',
  totalQuestions: 50,
  durationMinutes: 60,
  imageUrl: 'https://cdn.example.com/constitucion.png',
);
```

## ✅ Verificación

Para verificar que todo funciona:

1. **Verificar que el usuario tiene FCM token**:
   ```sql
   SELECT id, username, fcm_token
   FROM users
   WHERE id = 123;
   ```

2. **Enviar notificación de prueba**:
   ```bash
   curl -X POST https://your-project.supabase.co/functions/v1/send-push-notification \
     -H "Authorization: Bearer YOUR_KEY" \
     -d '{"user_id":123,"title":"Test","body":"Prueba","route":"/preview-topic/42"}'
   ```

3. **Revisar logs**:
   ```bash
   supabase functions logs send-push-notification
   ```

4. **En la app**, tocar la notificación debe:
   - Abrir la app
   - Cargar el Topic/TopicGroup
   - Mostrar la página de preview
   - Permitir iniciar el test

## 🔒 Seguridad

- Solo envía notificaciones a usuarios autorizados
- Valida que el topic/group existe antes de enviar
- Implementa rate limiting para evitar spam
- Usa los datos adicionales para tracking/analytics

## 📚 Recursos Adicionales

- [README.md](./README.md) - Documentación de la API
- [SETUP.md](./SETUP.md) - Guía de configuración
- [EXAMPLES.md](./EXAMPLES.md) - Más ejemplos
# Notificaciones Programadas de Topics - Documentación

Sistema automático para enviar notificaciones push cuando se publica un topic basado en el campo `publish_at`.

## 🎯 Qué Hace Esta Función

Esta Edge Function revisa periódicamente (mediante cron job) si hay topics o topic groups cuya fecha de publicación (`publish_at`) ya pasó y automáticamente:

1. ✅ Encuentra topics/groups con `publish_at <= ahora`
2. ✅ Que aún no han sido notificados (`notification_sent_at IS NULL`)
3. ✅ Envía notificaciones push a los usuarios correspondientes
4. ✅ Marca como notificado para no volver a enviar

## 📋 Requisitos Previos

### 1. Aplicar la migración

```bash
# Aplicar la migración que agrega notification_sent_at
supabase db push

# O manualmente ejecutar:
# supabase/migrations/00019_add_notification_sent_at_to_topics.sql
```

### 2. Desplegar las funciones

```bash
# Desplegar la función de notificaciones programadas
supabase functions deploy scheduled-topic-notifications

# Asegúrate de que send-push-notification esté desplegada también
supabase functions deploy send-push-notification
```

### 3. Configurar el Cron Job

Debes configurar un cron job en Supabase para que ejecute esta función automáticamente.

#### Opción A: Usando Supabase Dashboard

1. Ve a **Database** > **Cron Jobs** en tu proyecto de Supabase
2. Click en **Create a new cron job**
3. Configuración:
   - **Job name**: `publish-scheduled-topics`
   - **Schedule**: `0 * * * *` (cada hora)
   - **Command**:
     ```sql
     SELECT
       net.http_post(
         url:='https://your-project.supabase.co/functions/v1/scheduled-topic-notifications',
         headers:='{"Authorization": "Bearer YOUR_SERVICE_ROLE_KEY"}'::jsonb
       ) as request_id;
     ```

#### Opción B: Manualmente con SQL

```sql
-- Instalar la extensión pg_cron si no está instalada
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Crear el cron job (se ejecuta cada hora)
SELECT cron.schedule(
  'publish-scheduled-topics',  -- nombre del job
  '0 * * * *',                 -- cada hora en punto
  $$
  SELECT
    net.http_post(
      url:='https://your-project.supabase.co/functions/v1/scheduled-topic-notifications',
      headers:='{"Authorization": "Bearer YOUR_SERVICE_ROLE_KEY"}'::jsonb
    ) as request_id;
  $$
);
```

#### Opciones de Horario (Cron Syntax)

```bash
# Cada hora
'0 * * * *'

# Cada 30 minutos
'*/30 * * * *'

# Cada día a las 9 AM
'0 9 * * *'

# Cada día a las 9 AM y 6 PM
'0 9,18 * * *'

# De lunes a viernes a las 10 AM
'0 10 * * 1-5'
```

## 🔧 Configuración en la Base de Datos

### Campos Necesarios en Topics

```sql
-- Ver estructura de topics
SELECT
  id,
  topic_name,
  publish_at,           -- TIMESTAMPTZ - Fecha de publicación
  notification_sent_at  -- TIMESTAMPTZ - Cuando se envió notificación (NULL si no se ha enviado)
FROM topics;
```

### Campos Necesarios en Topic Groups

```sql
-- Ver estructura de topic_groups
SELECT
  id,
  name,
  publish_at,           -- TIMESTAMPTZ - Fecha de publicación
  notification_sent_at  -- TIMESTAMPTZ - Cuando se envió notificación
FROM topic_groups;
```

## 📅 Cómo Programar un Topic

### Desde SQL

```sql
-- Programar un topic para publicarse mañana a las 10 AM
UPDATE topics
SET publish_at = (NOW() + INTERVAL '1 day')::date + INTERVAL '10 hours'
WHERE id = 42;

-- Programar para una fecha específica
UPDATE topics
SET publish_at = '2024-12-25 09:00:00+00'::timestamptz
WHERE id = 42;

-- Ver cuándo se publicará
SELECT
  id,
  topic_name,
  publish_at,
  publish_at - NOW() as time_until_publish
FROM topics
WHERE id = 42;
```

### Desde Flutter

```dart
// Programar un topic para publicarse en el futuro
Future<void> scheduleTopicPublication(int topicId, DateTime publishAt) async {
  await Supabase.instance.client
      .from('topics')
      .update({'publish_at': publishAt.toIso8601String()})
      .eq('id', topicId);

  print('✅ Topic programado para: $publishAt');
}

// Ejemplo: Programar para mañana a las 10 AM
final tomorrow10AM = DateTime.now()
    .add(Duration(days: 1))
    .copyWith(hour: 10, minute: 0, second: 0);

await scheduleTopicPublication(42, tomorrow10AM);
```

## 🔍 Ver Topics Pendientes

### Usando las Vistas

```sql
-- Ver topics pendientes de notificar
SELECT * FROM topics_pending_notification;

-- Ver topic groups pendientes
SELECT * FROM topic_groups_pending_notification;

-- Ver cuántos hay pendientes
SELECT COUNT(*) FROM topics_pending_notification;
```

### Consulta Directa

```sql
-- Topics que deberían haberse publicado ya
SELECT
  id,
  topic_name,
  publish_at,
  notification_sent_at,
  NOW() - publish_at as overdue_by
FROM topics
WHERE publish_at IS NOT NULL
  AND publish_at <= NOW()
  AND notification_sent_at IS NULL
ORDER BY publish_at ASC;
```

## 🧪 Testing

### 1. Test Manual de la Función

```bash
# Ejecutar la función manualmente
curl -X POST \
  https://your-project.supabase.co/functions/v1/scheduled-topic-notifications \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json"
```

### 2. Ver Logs

```bash
# Ver logs en tiempo real
supabase functions logs scheduled-topic-notifications --follow

# Ver últimos logs
supabase functions logs scheduled-topic-notifications
```

### 3. Crear Topic de Prueba

```sql
-- Crear topic para publicarse en 1 minuto
INSERT INTO topics (
  topic_name,
  total_questions,
  duration_minutes,
  academy_id,
  topic_type_id,
  publish_at
) VALUES (
  'Test de Prueba Automático',
  10,
  15,
  1,
  1,
  NOW() + INTERVAL '1 minute'
);

-- Ver el topic creado
SELECT id, topic_name, publish_at, notification_sent_at
FROM topics
WHERE topic_name = 'Test de Prueba Automático';

-- Esperar 1-2 minutos y ejecutar manualmente la función
-- Luego verificar que notification_sent_at ya no es NULL
```

### 4. Resetear Notificación (Para Re-testing)

```sql
-- Resetear para poder volver a enviar notificación
SELECT reset_topic_notification(42);

-- O manualmente
UPDATE topics
SET notification_sent_at = NULL
WHERE id = 42;
```

## 📊 Monitoreo

### Ver Historial de Notificaciones

```sql
-- Topics que ya fueron notificados
SELECT
  id,
  topic_name,
  publish_at,
  notification_sent_at,
  notification_sent_at - publish_at as delay
FROM topics
WHERE notification_sent_at IS NOT NULL
ORDER BY notification_sent_at DESC;
```

### Ver Cron Jobs Activos

```sql
-- Ver todos los cron jobs configurados
SELECT * FROM cron.job;

-- Ver ejecuciones recientes
SELECT * FROM cron.job_run_details
ORDER BY start_time DESC
LIMIT 10;
```

## 🎯 Lógica de Filtrado de Usuarios

La función envía notificaciones según estos criterios:

### Topics Individuales

```
IF topic.is_premium == true:
  → Solo usuarios premium de esa academy
ELSE:
  → Todos los usuarios de esa academy con FCM token
```

### Topic Groups

```
→ Todos los usuarios de esa academy con FCM token
(sin filtro de premium)
```

### Código SQL Equivalente

```sql
-- Para topic regular
SELECT id FROM users
WHERE academy_id = :academy_id
  AND fcm_token IS NOT NULL;

-- Para topic premium
SELECT id FROM users
WHERE academy_id = :academy_id
  AND fcm_token IS NOT NULL
  AND is_premium = true;
```

## 🔔 Formato de las Notificaciones

### Topic Individual

```json
{
  "title": "📝 Nuevo test disponible",
  "body": "Constitución Española - 50 preguntas | 60 min",
  "image_url": "https://cdn.example.com/image.png",
  "route": "/preview-topic/42",
  "data": {
    "topic_id": "42",
    "topic_name": "Constitución Española",
    "type": "scheduled_topic_publish"
  }
}
```

### Topic Group

```json
{
  "title": "🎯 Nuevo examen completo disponible",
  "body": "Simulacro Guardia Civil 2024 - 3 partes",
  "image_url": "https://cdn.example.com/simulacro.png",
  "route": "/preview-topic-group/15",
  "data": {
    "topic_group_id": "15",
    "group_name": "Simulacro Guardia Civil 2024",
    "type": "scheduled_group_publish"
  }
}
```

## 📈 Ejemplo de Respuesta

```json
{
  "success": true,
  "message": "Scheduled notifications processed",
  "summary": {
    "timestamp": "2024-12-20T10:00:00.000Z",
    "topics": {
      "found": 2,
      "success": 2,
      "failed": 0
    },
    "topicGroups": {
      "found": 1,
      "success": 1,
      "failed": 0
    },
    "details": {
      "topics": {
        "total": 2,
        "success": 2,
        "failed": 0,
        "details": [
          {
            "topic_id": 42,
            "topic_name": "Constitución Española",
            "status": "success",
            "users_notified": 150,
            "users_failed": 0
          },
          {
            "topic_id": 43,
            "topic_name": "Derecho Penal",
            "status": "success",
            "users_notified": 85,
            "users_failed": 2
          }
        ]
      },
      "topicGroups": {
        "total": 1,
        "success": 1,
        "failed": 0,
        "details": [
          {
            "group_id": 15,
            "group_name": "Simulacro 2024",
            "status": "success",
            "users_notified": 200,
            "users_failed": 1
          }
        ]
      }
    }
  }
}
```

## ⚠️ Consideraciones Importantes

### 1. Zona Horaria

- Los timestamps deben estar en UTC
- Supabase convierte automáticamente a UTC
- En Flutter: `DateTime.toUtc()` o usa `.toIso8601String()`

### 2. Rate Limiting

- La función espera 100ms entre cada notificación
- Para muchos usuarios, el proceso puede tardar
- Considera ejecutar el cron menos frecuentemente si tienes muchos usuarios

### 3. Notificación Única

- Cada topic/group solo se notifica UNA vez
- Después de enviar, se marca `notification_sent_at`
- Para re-enviar, debes resetear manualmente

### 4. Usuarios Sin FCM Token

- Los usuarios sin token FCM se omiten automáticamente
- No se considera un error
- Revisa los logs para ver cuántos usuarios fueron notificados

## 🛠️ Troubleshooting

### El cron job no se ejecuta

```sql
-- Verificar que pg_cron está habilitado
SELECT * FROM pg_extension WHERE extname = 'pg_cron';

-- Ver errores de los jobs
SELECT * FROM cron.job_run_details
WHERE status != 'succeeded'
ORDER BY start_time DESC;
```

### No se envían notificaciones

1. **Verificar que hay topics pendientes**:
   ```sql
   SELECT * FROM topics_pending_notification;
   ```

2. **Verificar que hay usuarios con FCM token**:
   ```sql
   SELECT COUNT(*) FROM users WHERE fcm_token IS NOT NULL;
   ```

3. **Ejecutar función manualmente y revisar logs**:
   ```bash
   supabase functions logs scheduled-topic-notifications
   ```

### Notificaciones duplicadas

Si un topic se notifica múltiples veces:

```sql
-- Verificar notification_sent_at
SELECT id, topic_name, notification_sent_at
FROM topics
WHERE id = 42;

-- Si es NULL, el topic se notificará de nuevo
-- Asegúrate de que la función esté marcando correctamente
```

## 📚 Recursos Adicionales

- [Supabase Cron Jobs](https://supabase.com/docs/guides/database/extensions/pg_cron)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Cron Syntax](https://crontab.guru/)

## 🎉 Resumen

Con este sistema puedes:

1. ✅ Programar publicación de topics con `publish_at`
2. ✅ El sistema automáticamente envía notificaciones
3. ✅ Filtra usuarios según academy y premium
4. ✅ Evita notificaciones duplicadas
5. ✅ Funciona para topics individuales y grupales
6. ✅ Logs detallados para debugging
-- Migration: Add notification_sent_at to topics and topic_groups
-- Description: Agrega campo para rastrear cuándo se envió la notificación de publicación
-- Created: 2025-01-12

-- ==========================================
-- 1. AGREGAR COLUMNA A TOPIC
-- ==========================================

-- Agregar columna notification_sent_at a topic
ALTER TABLE public.topic
ADD COLUMN IF NOT EXISTS notification_sent_at TIMESTAMPTZ DEFAULT NULL;

-- Comentario
COMMENT ON COLUMN public.topic.notification_sent_at IS 'Timestamp de cuando se envió la notificación de publicación automática';

-- Índice para búsquedas eficientes
CREATE INDEX IF NOT EXISTS idx_topic_publish_at_notification
ON public.topic(published_at, notification_sent_at)
WHERE published_at IS NOT NULL AND notification_sent_at IS NULL;

-- ==========================================
-- 2. AGREGAR COLUMNA A TOPIC_GROUPS
-- ==========================================

-- Agregar columna notification_sent_at a topic_groups
ALTER TABLE public.topic_groups
ADD COLUMN IF NOT EXISTS notification_sent_at TIMESTAMPTZ DEFAULT NULL;

-- Comentario
COMMENT ON COLUMN public.topic_groups.notification_sent_at IS 'Timestamp de cuando se envió la notificación de publicación automática';

-- Índice para búsquedas eficientes
CREATE INDEX IF NOT EXISTS idx_topic_groups_published_at_notification
ON public.topic_groups(published_at, notification_sent_at)
WHERE published_at IS NOT NULL AND notification_sent_at IS NULL;

-- ==========================================
-- 3. FUNCIÓN HELPER PARA RESETEAR NOTIFICACIÓN
-- ==========================================

-- Función para resetear notification_sent_at (útil para testing)
CREATE OR REPLACE FUNCTION public.reset_topic_notification(topic_id_param BIGINT)
RETURNS VOID AS $$
BEGIN
  UPDATE public.topic
  SET notification_sent_at = NULL
  WHERE id = topic_id_param;

  RAISE NOTICE 'Notification reset for topic %', topic_id_param;
END;
$$ LANGUAGE plpgsql;

-- Función para resetear notification de topic group
CREATE OR REPLACE FUNCTION public.reset_topic_group_notification(topic_group_id_param BIGINT)
RETURNS VOID AS $$
BEGIN
  UPDATE public.topic_groups
  SET notification_sent_at = NULL
  WHERE id = topic_group_id_param;

  RAISE NOTICE 'Notification reset for topic group %', topic_group_id_param;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- 4. VISTA PARA VER TOPICS PENDIENTES
-- ==========================================

-- Vista de topics pendientes de notificar
CREATE OR REPLACE VIEW public.topics_pending_notification AS
SELECT
  id,
  topic_name,
  published_at,
  total_questions,
  duration_seconds / 60 as duration_minutes,
  is_premium,
  academy_id,
  image_url,
  NOW() - published_at as overdue_by
FROM public.topic
WHERE published_at IS NOT NULL
  AND published_at <= NOW()
  AND notification_sent_at IS NULL
ORDER BY published_at ASC;

COMMENT ON VIEW public.topics_pending_notification IS 'Topics que están listos para publicar pero aún no se ha enviado notificación';

-- Vista de topic groups pendientes de notificar
CREATE OR REPLACE VIEW public.topic_groups_pending_notification AS
SELECT
  id,
  name,
  published_at,
  academy_id,
  is_premium,
  NOW() - published_at as overdue_by
FROM public.topic_groups
WHERE published_at IS NOT NULL
  AND published_at <= NOW()
  AND notification_sent_at IS NULL
ORDER BY published_at ASC;

COMMENT ON VIEW public.topic_groups_pending_notification IS 'Topic groups que están listos para publicar pero aún no se ha enviado notificación';

-- ==========================================
-- 5. GRANTS
-- ==========================================

-- Permitir que service_role acceda a las funciones
GRANT EXECUTE ON FUNCTION public.reset_topic_notification TO service_role;
GRANT EXECUTE ON FUNCTION public.reset_topic_group_notification TO service_role;

-- Permitir que authenticated vea las vistas (solo lectura)
GRANT SELECT ON public.topics_pending_notification TO authenticated;
GRANT SELECT ON public.topic_groups_pending_notification TO authenticated;
-- Migration: Create notification_logs table
-- Description: Tabla para guardar un historial de notificaciones push enviadas
-- Created: 2025-01-12

-- Crear tabla de logs de notificaciones
CREATE TABLE IF NOT EXISTS public.notification_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  image_url TEXT,
  route TEXT,
  custom_data JSONB,
  fcm_response JSONB,
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Comentarios en las columnas
COMMENT ON TABLE public.notification_logs IS 'Historial de notificaciones push enviadas a usuarios';
COMMENT ON COLUMN public.notification_logs.user_id IS 'ID del usuario que recibió la notificación';
COMMENT ON COLUMN public.notification_logs.title IS 'Título de la notificación';
COMMENT ON COLUMN public.notification_logs.body IS 'Cuerpo del mensaje de la notificación';
COMMENT ON COLUMN public.notification_logs.image_url IS 'URL de la imagen incluida en la notificación (opcional)';
COMMENT ON COLUMN public.notification_logs.route IS 'Ruta de navegación asociada (opcional)';
COMMENT ON COLUMN public.notification_logs.custom_data IS 'Datos personalizados enviados con la notificación';
COMMENT ON COLUMN public.notification_logs.fcm_response IS 'Respuesta completa de Firebase Cloud Messaging';
COMMENT ON COLUMN public.notification_logs.sent_at IS 'Timestamp de cuando se envió la notificación';

-- Índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_notification_logs_user_id ON public.notification_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_logs_sent_at ON public.notification_logs(sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_notification_logs_user_sent ON public.notification_logs(user_id, sent_at DESC);

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION public.update_notification_logs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notification_logs_updated_at
  BEFORE UPDATE ON public.notification_logs
  FOR EACH ROW
  EXECUTE FUNCTION public.update_notification_logs_updated_at();

-- Habilitar Row Level Security (RLS)
ALTER TABLE public.notification_logs ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios autenticados pueden ver todos los logs de notificaciones
-- Nota: Si necesitas restringir a logs propios, deberías agregar un campo auth_user_id UUID
-- que mapee con auth.uid() en la tabla users
CREATE POLICY "Authenticated users can view notification logs"
  ON public.notification_logs
  FOR SELECT
  TO authenticated
  USING (true);

-- Política: Service role tiene acceso completo
CREATE POLICY "Service role has full access to notification logs"
  ON public.notification_logs
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Grant permissions
GRANT SELECT ON public.notification_logs TO authenticated;
GRANT ALL ON public.notification_logs TO service_role;

-- Crear vista para estadísticas de notificaciones (opcional)
CREATE OR REPLACE VIEW public.notification_stats AS
SELECT
  user_id,
  COUNT(*) as total_notifications,
  COUNT(*) FILTER (WHERE sent_at >= NOW() - INTERVAL '7 days') as last_7_days,
  COUNT(*) FILTER (WHERE sent_at >= NOW() - INTERVAL '30 days') as last_30_days,
  MAX(sent_at) as last_notification_sent,
  MIN(sent_at) as first_notification_sent
FROM public.notification_logs
GROUP BY user_id;

COMMENT ON VIEW public.notification_stats IS 'Estadísticas de notificaciones enviadas por usuario';

-- Grant permissions en la vista
GRANT SELECT ON public.notification_stats TO authenticated;
-- ============================================================================
-- Migration: 00026_saved_test_configs
-- Description: Crear tabla para guardar configuraciones de test de los usuarios
-- ============================================================================

-- Crear la tabla saved_test_configs
CREATE TABLE IF NOT EXISTS public.saved_test_configs (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  config_name TEXT NOT NULL,
  num_questions INT NOT NULL DEFAULT 10,
  answer_display_mode TEXT NOT NULL DEFAULT 'at_end',
  difficulties TEXT[] DEFAULT '{}',
  selected_topic_ids INT[] DEFAULT '{}',
  test_modes TEXT[] NOT NULL DEFAULT '{topics}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Restricciones
  CONSTRAINT saved_test_configs_num_questions_check CHECK (num_questions > 0),
  CONSTRAINT saved_test_configs_answer_display_mode_check CHECK (
    answer_display_mode IN ('immediate', 'at_end')
  ),
  CONSTRAINT saved_test_configs_config_name_not_empty CHECK (
    LENGTH(TRIM(config_name)) > 0
  ),
  CONSTRAINT saved_test_configs_user_config_unique UNIQUE (user_id, config_name)
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_saved_test_configs_user_id
  ON public.saved_test_configs(user_id);

CREATE INDEX IF NOT EXISTS idx_saved_test_configs_created_at
  ON public.saved_test_configs(created_at DESC);

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION public.update_saved_test_configs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_saved_test_configs_updated_at
  BEFORE UPDATE ON public.saved_test_configs
  FOR EACH ROW
  EXECUTE FUNCTION public.update_saved_test_configs_updated_at();

-- ============================================================================
-- Comentarios en la tabla y columnas para documentación
-- ============================================================================

COMMENT ON TABLE public.saved_test_configs IS
  'Configuraciones de test guardadas por los usuarios para acceso rápido';

COMMENT ON COLUMN public.saved_test_configs.id IS
  'Identificador único de la configuración';

COMMENT ON COLUMN public.saved_test_configs.user_id IS
  'ID del usuario propietario de la configuración';

COMMENT ON COLUMN public.saved_test_configs.config_name IS
  'Nombre personalizado para la configuración (debe ser único por usuario)';

COMMENT ON COLUMN public.saved_test_configs.num_questions IS
  'Número de preguntas en el test (10, 20, 50, 100)';

COMMENT ON COLUMN public.saved_test_configs.answer_display_mode IS
  'Modo de mostrar respuestas: immediate (inmediato) o at_end (al final)';

COMMENT ON COLUMN public.saved_test_configs.difficulties IS
  'Array de dificultades seleccionadas: easy, normal, hard. Vacío = todas';

COMMENT ON COLUMN public.saved_test_configs.selected_topic_ids IS
  'Array de IDs de topics seleccionados para el test';

COMMENT ON COLUMN public.saved_test_configs.test_modes IS
  'Array de modos de test: topics, failed, skipped, survival';

COMMENT ON COLUMN public.saved_test_configs.created_at IS
  'Fecha de creación de la configuración';

COMMENT ON COLUMN public.saved_test_configs.updated_at IS
  'Fecha de última actualización de la configuración';
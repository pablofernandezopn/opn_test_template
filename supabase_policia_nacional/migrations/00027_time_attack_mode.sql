-- ============================================================================
-- Migration 00027: Time Attack Mode
-- ============================================================================
-- Crea la infraestructura para el modo contra reloj (time attack)
-- Similar al modo supervivencia pero con límite de tiempo en lugar de vidas

-- ============================================================================
-- 1. Tabla principal: time_attack_sessions
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.time_attack_sessions (
  -- Identificación
  id SERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  academy_id BIGINT NOT NULL REFERENCES public.academies(id) ON DELETE CASCADE,
  topic_type_id BIGINT REFERENCES public.topic_type(id) ON DELETE SET NULL,
  specialty_id BIGINT REFERENCES public.specialties(id) ON DELETE SET NULL,

  -- Configuración del juego
  time_limit_seconds INT NOT NULL, -- Tiempo límite en segundos (120, 300, 600)
  time_remaining_seconds INT NOT NULL, -- Tiempo restante (actualizado por el cliente)

  -- Estadísticas del juego
  questions_answered INT NOT NULL DEFAULT 0,
  questions_correct INT NOT NULL DEFAULT 0,
  questions_seen BIGINT[] NOT NULL DEFAULT '{}',
  current_streak INT NOT NULL DEFAULT 0, -- Racha actual de respuestas correctas
  best_streak INT NOT NULL DEFAULT 0, -- Mejor racha alcanzada en la sesión

  -- Sistema de dificultad adaptativa
  current_level INT NOT NULL DEFAULT 1,
  difficulty_floor REAL NOT NULL DEFAULT 0.0,
  difficulty_ceiling REAL NOT NULL DEFAULT 0.3,

  -- Puntuación
  current_score INT NOT NULL DEFAULT 0, -- Puntuación acumulada
  final_score INT DEFAULT NULL, -- Puntuación final al terminar

  -- Control de sesión
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ended_at TIMESTAMPTZ DEFAULT NULL,
  last_activity_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Metadatos
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 2. Índices para optimización
-- ============================================================================

CREATE INDEX idx_time_attack_sessions_user_id ON public.time_attack_sessions(user_id);
CREATE INDEX idx_time_attack_sessions_is_active ON public.time_attack_sessions(is_active);
CREATE INDEX idx_time_attack_sessions_user_active ON public.time_attack_sessions(user_id, is_active);
CREATE INDEX idx_time_attack_sessions_academy_id ON public.time_attack_sessions(academy_id);

-- ============================================================================
-- 3. Row Level Security (RLS)
-- ============================================================================
-- Desactivar RLS temporalmente (similar a survival_sessions)
-- El usuario configurará las políticas correctas más tarde

ALTER TABLE public.time_attack_sessions DISABLE ROW LEVEL SECURITY;

COMMENT ON TABLE public.time_attack_sessions IS
'Tabla de sesiones de modo contra reloj. RLS desactivado temporalmente para desarrollo.';

-- ============================================================================
-- 4. Modificar tabla user_tests para vincular sesiones de contra reloj
-- ============================================================================

ALTER TABLE public.user_tests
ADD COLUMN IF NOT EXISTS time_attack_session_id BIGINT
REFERENCES public.time_attack_sessions(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_user_tests_time_attack_session
ON public.user_tests(time_attack_session_id);

-- ============================================================================
-- 5. Función RPC: get_time_attack_session_answers
-- ============================================================================
-- Obtiene todas las respuestas de una sesión de contra reloj para revisión

CREATE OR REPLACE FUNCTION public.get_time_attack_session_answers(p_session_id INTEGER)
RETURNS TABLE (
  question_id BIGINT,
  question_text TEXT,
  question_tip TEXT,
  selected_option_id BIGINT,
  was_correct BOOLEAN,
  time_taken_seconds INT,
  option_id BIGINT,
  option_answer TEXT,
  option_order INT,
  option_is_correct BOOLEAN,
  answered_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    q.id AS question_id,
    q.question AS question_text,
    q.tip AS question_tip,
    uta.selected_option_id,
    uta.correct AS was_correct,
    uta.time_taken_seconds,
    qo.id AS option_id,
    qo.answer AS option_answer,
    qo.option_order,
    qo.is_correct AS option_is_correct,
    uta.answered_at
  FROM user_tests ut
  INNER JOIN user_test_answers uta ON uta.user_test_id = ut.id
  INNER JOIN questions q ON q.id = uta.question_id
  INNER JOIN question_options qo ON qo.question_id = q.id
  WHERE ut.time_attack_session_id = p_session_id
  ORDER BY uta.answered_at, qo.option_order;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Otorgar permisos de ejecución
GRANT EXECUTE ON FUNCTION public.get_time_attack_session_answers(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_time_attack_session_answers(INTEGER) TO service_role;

-- ============================================================================
-- 6. Trigger para actualizar updated_at automáticamente
-- ============================================================================

CREATE OR REPLACE FUNCTION public.update_time_attack_sessions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_time_attack_sessions_updated_at
  BEFORE UPDATE ON public.time_attack_sessions
  FOR EACH ROW
  EXECUTE FUNCTION public.update_time_attack_sessions_updated_at();

-- ============================================================================
-- Fin de la migración
-- ============================================================================
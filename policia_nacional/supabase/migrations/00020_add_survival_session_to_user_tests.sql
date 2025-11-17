-- =====================================================
-- MIGRATION 20: VINCULAR USER_TESTS CON SURVIVAL_SESSIONS
-- =====================================================
-- Añade campo para vincular tests en historial con sesiones de supervivencia
-- permitiendo pausar y continuar partidas

-- Añadir columna survival_session_id a user_tests
ALTER TABLE public.user_tests
ADD COLUMN IF NOT EXISTS survival_session_id BIGINT,
ADD CONSTRAINT fk_user_tests_survival_session
    FOREIGN KEY (survival_session_id)
    REFERENCES public.survival_sessions(id)
    ON DELETE SET NULL;

-- Índice para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_user_tests_survival_session
ON public.user_tests(survival_session_id);

-- Comentario
COMMENT ON COLUMN public.user_tests.survival_session_id IS
'ID de la sesión de supervivencia asociada. Si no es null, permite continuar la partida desde el historial';
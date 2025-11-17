-- =====================================================
-- MIGRATION 19: SURVIVAL MODE
-- =====================================================
-- Descripción: Tabla y funciones para el modo supervivencia
-- Fecha: 2025-11-12
-- =====================================================

-- =====================================================
-- TABLA: survival_sessions
-- =====================================================
-- Almacena las sesiones de modo supervivencia de los usuarios

CREATE TABLE IF NOT EXISTS public.survival_sessions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    academy_id BIGINT NOT NULL,
    topic_type_id BIGINT,
    specialty_id BIGINT,
    lives_remaining INT DEFAULT 3 NOT NULL,
    current_level INT DEFAULT 1 NOT NULL,
    questions_answered INT DEFAULT 0 NOT NULL,
    questions_correct INT DEFAULT 0 NOT NULL,
    questions_seen BIGINT[] DEFAULT '{}' NOT NULL,
    difficulty_floor NUMERIC(5, 2) DEFAULT 0.0 NOT NULL,
    difficulty_ceiling NUMERIC(5, 2) DEFAULT 0.3 NOT NULL,
    started_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    ended_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true NOT NULL,
    final_score NUMERIC(10, 2),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Foreign keys
    CONSTRAINT fk_survival_sessions_user
        FOREIGN KEY (user_id)
        REFERENCES public.cms_users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_survival_sessions_academy
        FOREIGN KEY (academy_id)
        REFERENCES public.academies(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_survival_sessions_topic_type
        FOREIGN KEY (topic_type_id)
        REFERENCES public.topic_type(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_survival_sessions_specialty
        FOREIGN KEY (specialty_id)
        REFERENCES public.specialties(id)
        ON DELETE SET NULL,

    -- Constraints
    CONSTRAINT chk_lives_remaining_range
        CHECK (lives_remaining >= 0 AND lives_remaining <= 10),

    CONSTRAINT chk_current_level_positive
        CHECK (current_level > 0),

    CONSTRAINT chk_questions_answered_positive
        CHECK (questions_answered >= 0),

    CONSTRAINT chk_questions_correct_range
        CHECK (questions_correct >= 0 AND questions_correct <= questions_answered),

    CONSTRAINT chk_difficulty_range
        CHECK (difficulty_floor >= 0.0 AND difficulty_floor <= 1.0
           AND difficulty_ceiling >= 0.0 AND difficulty_ceiling <= 1.0
           AND difficulty_ceiling >= difficulty_floor)
);

-- Índices para optimizar consultas
CREATE INDEX idx_survival_sessions_user_id ON public.survival_sessions(user_id);
CREATE INDEX idx_survival_sessions_is_active ON public.survival_sessions(is_active);
CREATE INDEX idx_survival_sessions_user_active ON public.survival_sessions(user_id, is_active);
CREATE INDEX idx_survival_sessions_academy_id ON public.survival_sessions(academy_id);

-- Comentarios
COMMENT ON TABLE public.survival_sessions IS 'Sesiones de modo supervivencia donde el usuario responde preguntas con dificultad creciente y vidas limitadas';
COMMENT ON COLUMN public.survival_sessions.lives_remaining IS 'Número de vidas restantes (empieza en 3)';
COMMENT ON COLUMN public.survival_sessions.current_level IS 'Nivel actual del jugador (aumenta cada 5 preguntas)';
COMMENT ON COLUMN public.survival_sessions.questions_seen IS 'Array de IDs de preguntas ya mostradas en esta sesión';
COMMENT ON COLUMN public.survival_sessions.difficulty_floor IS 'Límite inferior del rango de dificultad actual';
COMMENT ON COLUMN public.survival_sessions.difficulty_ceiling IS 'Límite superior del rango de dificultad actual';

-- =====================================================
-- RPC FUNCTION: get_questions_by_difficulty_range
-- =====================================================
-- Obtiene preguntas aleatorias dentro de un rango de dificultad

CREATE OR REPLACE FUNCTION public.get_questions_by_difficulty_range(
    p_min_difficulty NUMERIC,
    p_max_difficulty NUMERIC,
    p_exclude_ids BIGINT[],
    p_academy_id BIGINT,
    p_topic_type_id BIGINT DEFAULT NULL,
    p_specialty_id BIGINT DEFAULT NULL,
    p_limit INT DEFAULT 10
)
RETURNS TABLE (
    id BIGINT,
    question TEXT,
    tip TEXT,
    topic BIGINT,
    article TEXT,
    question_image_url TEXT,
    retro_image_url TEXT,
    retro_audio_enable BOOLEAN,
    retro_audio_text TEXT,
    retro_audio_url TEXT,
    "order" INT,
    published BOOLEAN,
    shuffled BOOLEAN,
    num_answered INT,
    num_fails INT,
    num_empty INT,
    difficult_rate DOUBLE PRECISION,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    created_by UUID,
    challenge_by_tutor BOOLEAN,
    challenge_reason TEXT,
    academy_id BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        q.id,
        q.question,
        q.tip,
        q.topic,
        q.article,
        q.question_image_url,
        q.retro_image_url,
        q.retro_audio_enable,
        q.retro_audio_text,
        q.retro_audio_url,
        q."order",
        q.published,
        q.shuffled,
        q.num_answered,
        q.num_fails,
        q.num_empty,
        q.difficult_rate,
        q.created_at,
        q.updated_at,
        q.created_by,
        q.challenge_by_tutor,
        q.challenge_reason,
        q.academy_id
    FROM public.questions q
    INNER JOIN public.topic t ON q.topic = t.id
    WHERE q.published = true
        AND q.academy_id = p_academy_id
        AND q.id != ALL(COALESCE(p_exclude_ids, '{}'))
        AND q.difficult_rate IS NOT NULL
        AND q.difficult_rate BETWEEN p_min_difficulty AND p_max_difficulty
        -- Filtrar por topic_type si se especifica
        AND (p_topic_type_id IS NULL OR t.topic_type_id = p_topic_type_id)
        -- Filtrar por specialty si se especifica
        AND (p_specialty_id IS NULL OR t.specialty_id = p_specialty_id OR t.specialty_id IS NULL)
    ORDER BY RANDOM()
    LIMIT p_limit;
END;
$$;

COMMENT ON FUNCTION public.get_questions_by_difficulty_range IS 'Obtiene preguntas aleatorias filtradas por rango de dificultad, academia, tipo de tema y especialidad';

-- =====================================================
-- TRIGGER: update_survival_sessions_updated_at
-- =====================================================
-- Actualiza el campo updated_at automáticamente

CREATE OR REPLACE FUNCTION public.update_survival_sessions_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_update_survival_sessions_updated_at
    BEFORE UPDATE ON public.survival_sessions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_survival_sessions_updated_at();

-- =====================================================
-- RLS POLICIES para survival_sessions
-- =====================================================

-- Habilitar RLS
ALTER TABLE public.survival_sessions ENABLE ROW LEVEL SECURITY;

-- Policy: Los usuarios solo pueden ver sus propias sesiones
CREATE POLICY "Users can view their own survival sessions"
    ON public.survival_sessions
    FOR SELECT
    USING (auth.uid()::text = (SELECT user_uuid::text FROM public.cms_users WHERE id = survival_sessions.user_id));

-- Policy: Los usuarios pueden crear sus propias sesiones
CREATE POLICY "Users can create their own survival sessions"
    ON public.survival_sessions
    FOR INSERT
    WITH CHECK (auth.uid()::text = (SELECT user_uuid::text FROM public.cms_users WHERE id = survival_sessions.user_id));

-- Policy: Los usuarios pueden actualizar sus propias sesiones activas
CREATE POLICY "Users can update their own survival sessions"
    ON public.survival_sessions
    FOR UPDATE
    USING (auth.uid()::text = (SELECT user_uuid::text FROM public.cms_users WHERE id = survival_sessions.user_id));

-- Policy: Los usuarios pueden eliminar sus propias sesiones
CREATE POLICY "Users can delete their own survival sessions"
    ON public.survival_sessions
    FOR DELETE
    USING (auth.uid()::text = (SELECT user_uuid::text FROM public.cms_users WHERE id = survival_sessions.user_id));

-- Dar permisos a authenticated users
GRANT SELECT, INSERT, UPDATE, DELETE ON public.survival_sessions TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.survival_sessions_id_seq TO authenticated;

-- Dar permisos a service_role (para edge functions)
GRANT ALL ON public.survival_sessions TO service_role;
GRANT USAGE, SELECT ON SEQUENCE public.survival_sessions_id_seq TO service_role;

-- Dar permisos para ejecutar la función RPC
GRANT EXECUTE ON FUNCTION public.get_questions_by_difficulty_range TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_questions_by_difficulty_range TO service_role;
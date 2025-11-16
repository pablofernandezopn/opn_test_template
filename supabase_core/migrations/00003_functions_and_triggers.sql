-- =====================================================
-- MIGRATION 3: FUNCTIONS AND TRIGGERS
-- =====================================================
-- Descripción: Funciones y triggers del sistema
-- Fecha: 2025-11-05
-- =====================================================

SET statement_timeout = 0;
SET lock_timeout = 0;

-- =====================================================
-- SECCIÓN 1: TIMESTAMP TRIGGERS
-- =====================================================
-- Funciones y triggers para actualizar updated_at automáticamente

-- Función genérica para actualizar updated_at
CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";

-- Función específica para users que usa updatedAt (camelCase)
CREATE OR REPLACE FUNCTION "public"."update_users_updated_at"()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW."updatedAt" = NOW();
    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."update_users_updated_at"() OWNER TO "postgres";

-- Triggers de updated_at para cada tabla
CREATE TRIGGER "trg_academies_updated_at"
    BEFORE UPDATE ON "public"."academies"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."update_updated_at_column"();

CREATE TRIGGER "trg_specialties_updated_at"
    BEFORE UPDATE ON "public"."specialties"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."update_updated_at_column"();

CREATE TRIGGER "trg_users_updated_at"
    BEFORE UPDATE ON "public"."users"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."update_users_updated_at"();

CREATE TRIGGER "trg_topic_updated_at"
    BEFORE UPDATE ON "public"."topic"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."update_updated_at_column"();

CREATE TRIGGER "trg_questions_updated_at"
    BEFORE UPDATE ON "public"."questions"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."update_updated_at_column"();

CREATE TRIGGER "trg_challenge_updated_at"
    BEFORE UPDATE ON "public"."challenge"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."update_updated_at_column"();

CREATE TRIGGER "trg_user_tests_updated_at"
    BEFORE UPDATE ON "public"."user_tests"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."update_updated_at_column"();

-- =====================================================
-- SECCIÓN 2: QUESTION OPTIONS AUTO-GENERATION
-- =====================================================
-- Trigger para crear opciones en blanco cuando se crea una pregunta

CREATE OR REPLACE FUNCTION "public"."create_blank_question_options"()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    topic_options_count INT;
BEGIN
    -- Obtener el número de opciones del topic al que pertenece la pregunta
    SELECT t.options INTO topic_options_count
    FROM public.topic t
    WHERE t.id = NEW.topic;

    -- Si no se encuentra el topic o no tiene opciones definidas, usar 4 por defecto
    IF topic_options_count IS NULL THEN
        topic_options_count := 4;
    END IF;

    -- Insertar opciones vacías
    FOR i IN 1..topic_options_count LOOP
        INSERT INTO question_options (question_id, answer, is_correct, option_order)
        VALUES (NEW.id, '', false, i);
    END LOOP;

    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."create_blank_question_options"() OWNER TO "postgres";

CREATE TRIGGER "trg_create_blank_question_options"
    AFTER INSERT ON "public"."questions"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."create_blank_question_options"();

-- =====================================================
-- SECCIÓN 3: ANSWER CORRECTNESS CALCULATION
-- =====================================================
-- Calcular si una respuesta es correcta (para tests normales, no flashcards)

CREATE OR REPLACE FUNCTION "public"."calculate_answer_correctness"()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    correct_option_id bigint;
    is_flashcard BOOLEAN;
BEGIN
    -- Verificar si es modo flashcard
    SELECT is_flashcard_mode INTO is_flashcard
    FROM user_tests
    WHERE id = NEW.user_test_id;

    -- Si es flashcard, correct = NULL (no aplica concepto de correcta/incorrecta)
    IF is_flashcard THEN
        NEW.correct := NULL;
        RETURN NEW;
    END IF;

    -- LÓGICA ORIGINAL PARA TESTS NORMALES

    -- Obtener la opción correcta de la pregunta
    SELECT id
    INTO correct_option_id
    FROM question_options
    WHERE question_id = NEW.question_id
    AND is_correct = true
    LIMIT 1;

    -- Determinar si la respuesta es correcta
    IF NEW.selected_option_id IS NOT NULL AND correct_option_id IS NOT NULL THEN
        NEW.correct := (NEW.selected_option_id = correct_option_id);
    ELSE
        NEW.correct := NULL;  -- No respondida o sin opción correcta definida
    END IF;

    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."calculate_answer_correctness"() OWNER TO "postgres";

COMMENT ON FUNCTION "public"."calculate_answer_correctness"() IS 
'Calcula si una respuesta es correcta. Para flashcards retorna NULL (no aplica), para tests normales valida contra is_correct';

CREATE TRIGGER "trg_calculate_answer_correctness"
    BEFORE INSERT OR UPDATE ON "public"."user_test_answers"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."calculate_answer_correctness"();

-- =====================================================
-- SECCIÓN 4: FLASHCARD REVIEW SCHEDULE (SM-2 Algorithm)
-- =====================================================
-- Calcula próxima fecha de revisión para flashcards usando el algoritmo SM-2

CREATE OR REPLACE FUNCTION "public"."calculate_next_review_flashcard"(
    "p_difficulty_rating" character varying,
    "p_current_ease_factor" numeric,
    "p_current_interval_days" integer,
    "p_current_repetitions" integer
)
RETURNS TABLE(
    "next_review_date" timestamp with time zone,
    "new_interval_days" integer,
    "new_ease_factor" numeric,
    "new_repetitions" integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ease_factor numeric;
    v_interval_days integer;
    v_repetitions integer;
BEGIN
    -- Inicializar valores
    v_ease_factor := p_current_ease_factor;
    v_interval_days := p_current_interval_days;
    v_repetitions := p_current_repetitions;

    -- Ajustar según dificultad
    CASE p_difficulty_rating
        WHEN 'again' THEN
            -- Reiniciar intervalo, decrementar ease factor
            v_repetitions := 0;
            v_interval_days := 1;
            v_ease_factor := GREATEST(1.3, v_ease_factor - 0.2);

        WHEN 'hard' THEN
            -- Intervalo menor incremento
            v_repetitions := GREATEST(0, v_repetitions - 1);
            v_interval_days := GREATEST(1, CEIL(v_interval_days * 1.2));
            v_ease_factor := GREATEST(1.3, v_ease_factor - 0.15);

        WHEN 'medium' THEN
            -- Intervalo normal
            v_repetitions := v_repetitions + 1;
            IF v_repetitions = 1 THEN
                v_interval_days := 3;
            ELSIF v_repetitions = 2 THEN
                v_interval_days := 6;
            ELSE
                v_interval_days := CEIL(v_interval_days * v_ease_factor);
            END IF;

        WHEN 'easy' THEN
            -- Intervalo con incremento mayor
            v_repetitions := v_repetitions + 1;
            IF v_repetitions = 1 THEN
                v_interval_days := 4;
            ELSIF v_repetitions = 2 THEN
                v_interval_days := 7;
            ELSE
                v_interval_days := CEIL(v_interval_days * v_ease_factor * 1.3);
            END IF;
            v_ease_factor := v_ease_factor + 0.1;

        ELSE
            -- Default: mantener valores
            NULL;
    END CASE;

    -- Limitar ease_factor entre 1.3 y 2.5
    v_ease_factor := LEAST(2.5, GREATEST(1.3, v_ease_factor));

    -- Limitar intervalo máximo (ej: 365 días)
    v_interval_days := LEAST(365, v_interval_days);

    -- Retornar resultados
    RETURN QUERY SELECT
        (NOW() + (v_interval_days || ' days')::interval)::timestamp with time zone,
        v_interval_days,
        v_ease_factor,
        v_repetitions;
END;
$$;

ALTER FUNCTION "public"."calculate_next_review_flashcard"(character varying, numeric, integer, integer) OWNER TO "postgres";

COMMENT ON FUNCTION "public"."calculate_next_review_flashcard"(character varying, numeric, integer, integer) IS
'Implementa el algoritmo SM-2 de repetición espaciada para flashcards';

-- Trigger para actualizar schedule de flashcards
CREATE OR REPLACE FUNCTION "public"."update_flashcard_review_schedule"()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_result RECORD;
BEGIN
    -- Solo aplicar a respuestas con difficulty_rating (flashcards)
    IF NEW.difficulty_rating IS NOT NULL THEN
        -- Calcular próxima revisión
        SELECT * INTO v_result
        FROM calculate_next_review_flashcard(
            NEW.difficulty_rating,
            COALESCE(NEW.ease_factor, 2.5),
            COALESCE(NEW.review_interval_days, 1),
            COALESCE(NEW.repetitions, 0)
        );

        -- Actualizar campos
        NEW.next_review_date := v_result.next_review_date;
        NEW.review_interval_days := v_result.new_interval_days;
        NEW.ease_factor := v_result.new_ease_factor;
        NEW.repetitions := v_result.new_repetitions;
    END IF;

    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."update_flashcard_review_schedule"() OWNER TO "postgres";

CREATE TRIGGER "trg_update_flashcard_review_schedule"
    BEFORE INSERT OR UPDATE OF difficulty_rating ON "public"."user_test_answers"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."update_flashcard_review_schedule"();

-- =====================================================
-- SECCIÓN 5: USER TEST STATS UPDATE
-- =====================================================
-- Actualiza right_questions, wrong_questions y total_answered en user_tests

CREATE OR REPLACE FUNCTION "public"."update_user_test_stats"()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_is_flashcard BOOLEAN;
    v_right_count INTEGER;
    v_wrong_count INTEGER;
    v_total_count INTEGER;
    v_update_count INTEGER;
BEGIN
    -- Obtener si el test es modo flashcard
    SELECT is_flashcard_mode INTO v_is_flashcard
    FROM user_tests
    WHERE id = NEW.user_test_id;

    -- Calcular las estadísticas
    SELECT
        COUNT(*) FILTER (WHERE correct = true),
        COUNT(*) FILTER (WHERE correct = false),
        COUNT(*) FILTER (WHERE selected_option_id IS NOT NULL)
    INTO v_right_count, v_wrong_count, v_total_count
    FROM user_test_answers
    WHERE user_test_id = NEW.user_test_id;

    -- Si es flashcard, no actualizar right/wrong (solo total_answered)
    IF v_is_flashcard THEN
        UPDATE user_tests
        SET
            total_answered = v_total_count,
            updated_at = NOW()
        WHERE id = NEW.user_test_id;
    ELSE
        -- Tests normales: actualizar right, wrong y total
        UPDATE user_tests
        SET
            right_questions = v_right_count,
            wrong_questions = v_wrong_count,
            total_answered = v_total_count,
            updated_at = NOW()
        WHERE id = NEW.user_test_id;
    END IF;

    -- Verificar que el UPDATE funcionó
    GET DIAGNOSTICS v_update_count = ROW_COUNT;

    IF v_update_count = 0 THEN
        RAISE WARNING 'update_user_test_stats: No se actualizó ninguna fila para user_test_id=%', NEW.user_test_id;
    END IF;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'update_user_test_stats ERROR: %, user_test_id=%', SQLERRM, NEW.user_test_id;
        RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."update_user_test_stats"() OWNER TO "postgres";

CREATE TRIGGER "trg_update_user_test_stats"
    AFTER INSERT OR UPDATE ON "public"."user_test_answers"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."update_user_test_stats"();

-- =====================================================
-- SECCIÓN 6: MOCK RANKINGS
-- =====================================================
-- Sistema de rankings para tests Mock

-- Función para recalcular rankings de un topic
CREATE OR REPLACE FUNCTION "public"."recalculate_topic_rankings"("p_topic_id" bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    -- Recalcular posiciones usando first_score (no best_score)
    WITH ranked AS (
        SELECT
            id,
            ROW_NUMBER() OVER (ORDER BY first_score DESC, first_attempt_date ASC) AS position,
            COUNT(*) OVER () AS total
        FROM topic_mock_rankings
        WHERE topic_id = p_topic_id
    )
    UPDATE topic_mock_rankings tmr
    SET
        rank_position = ranked.position,
        total_participants = ranked.total,
        updated_at = NOW()
    FROM ranked
    WHERE tmr.id = ranked.id;
END;
$$;

ALTER FUNCTION "public"."recalculate_topic_rankings"(bigint) OWNER TO "postgres";

COMMENT ON FUNCTION "public"."recalculate_topic_rankings"(bigint) IS
'Recalcula las posiciones del ranking para un topic específico basándose en first_score';

-- Trigger para actualizar rankings cuando un test Mock se completa
CREATE OR REPLACE FUNCTION "public"."update_ranking_on_mock_complete"()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_topic_id BIGINT;
  v_topic_type_level TEXT;
  v_topic_group_id BIGINT;
  v_current_best_score NUMERIC;
  v_current_attempts INTEGER;
  v_should_recalculate BOOLEAN := false;
BEGIN
  -- Solo procesar si el test está finalizado con score
  -- NO verificar NEW.mock porque esa columna ya no existe
  IF NEW.finalized IS NOT TRUE OR NEW.score IS NULL THEN
    RETURN NEW;
  END IF;

  -- Verificar que el topic_ids tenga al menos un elemento
  IF array_length(NEW.topic_ids, 1) IS NULL OR array_length(NEW.topic_ids, 1) = 0 THEN
    RETURN NEW;
  END IF;

  -- Tomar el primer topic_id (asumiendo que un test Mock tiene un solo topic)
  v_topic_id := NEW.topic_ids[1];

  -- Ignorar topics virtuales (id <= 0, ej: Test de Estudio con id = -1)
  IF v_topic_id IS NULL OR v_topic_id <= 0 THEN
    RETURN NEW;
  END IF;

  -- Obtener level y topic_group_id del topic
  SELECT tt.level, t.topic_group_id
  INTO v_topic_type_level, v_topic_group_id
  FROM "public"."topic" t
  JOIN "public"."topic_type" tt ON t.topic_type_id = tt.id
  WHERE t.id = v_topic_id;

  -- Verificar que el topic existe (previene errores si fue eliminado)
  IF v_topic_type_level IS NULL THEN
    RETURN NEW;
  END IF;

  -- Solo procesar tests de tipo Mock (excluir Study y Flashcard)
  IF v_topic_type_level != 'Mock' THEN
    RETURN NEW;
  END IF;

  -- Obtener el ranking actual del usuario para este topic (si existe)
  SELECT best_score, attempts INTO v_current_best_score, v_current_attempts
  FROM "public"."topic_mock_rankings"
  WHERE topic_id = v_topic_id AND user_id = NEW.user_id;

  -- Si no existe entrada, crear una nueva (primer intento)
  IF v_current_best_score IS NULL THEN
    -- Primera vez: first_score y best_score son iguales
    INSERT INTO "public"."topic_mock_rankings" (
      topic_id,
      user_id,
      topic_group_id,
      first_score,
      best_score,
      attempts,
      first_attempt_date,
      last_attempt_date
    ) VALUES (
      v_topic_id,
      NEW.user_id,
      v_topic_group_id,
      NEW.score,
      NEW.score,
      1,
      NEW.created_at,
      NEW.created_at
    );
    v_should_recalculate := true;

  ELSE
    -- Actualizar entrada existente (intentos posteriores)
    IF NEW.score > v_current_best_score THEN
      -- Actualizar best_score si mejora
      UPDATE "public"."topic_mock_rankings"
      SET
        best_score = NEW.score,
        attempts = v_current_attempts + 1,
        last_attempt_date = NEW.created_at,
        updated_at = now()
      WHERE topic_id = v_topic_id AND user_id = NEW.user_id;
    ELSE
      -- Solo actualizar attempts y fecha
      UPDATE "public"."topic_mock_rankings"
      SET
        attempts = v_current_attempts + 1,
        last_attempt_date = NEW.created_at,
        updated_at = now()
      WHERE topic_id = v_topic_id AND user_id = NEW.user_id;
    END IF;
  END IF;

  -- Recalcular rankings SOLO si hay un nuevo usuario
  IF v_should_recalculate THEN
    PERFORM "public"."recalculate_topic_rankings"(v_topic_id);
  END IF;

  RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."update_ranking_on_mock_complete"() OWNER TO "postgres";

COMMENT ON FUNCTION "public"."update_ranking_on_mock_complete"() IS
'Actualiza el ranking cuando un usuario completa un test Mock. Valida que el topic_id sea válido (> 0 y exista). Excluye topics virtuales, Study y Flashcards del ranking.';

CREATE TRIGGER "trg_update_ranking_on_mock_complete"
    AFTER INSERT OR UPDATE OF finalized, score ON "public"."user_tests"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."update_ranking_on_mock_complete"();

-- =====================================================
-- SECCIÓN 6B: UPDATE USER GLOBAL STATS
-- =====================================================
-- Actualiza las estadísticas globales del usuario cuando finaliza un test

CREATE OR REPLACE FUNCTION "public"."update_user_global_stats"()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Solo actualizar si el test acaba de finalizarse (no flashcards)
    IF NEW.finalized = true AND (OLD.finalized = false OR OLD.finalized IS NULL)
       AND (NEW.is_flashcard_mode = false OR NEW.is_flashcard_mode IS NULL) THEN

        UPDATE users
        SET
            "totalQuestions" = "totalQuestions" + NEW.question_count,
            "rightQuestions" = "rightQuestions" + NEW.right_questions,
            "wrongQuestions" = "wrongQuestions" + NEW.wrong_questions,
            "updatedAt" = NOW()
        WHERE id = NEW.user_id;
    END IF;

    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."update_user_global_stats"() OWNER TO "postgres";

COMMENT ON FUNCTION "public"."update_user_global_stats"() IS
'Actualiza las estadísticas globales del usuario (totalQuestions, rightQuestions, wrongQuestions) cuando finaliza un test normal (no flashcards)';

CREATE TRIGGER "trg_update_user_global_stats"
    AFTER INSERT OR UPDATE OF finalized, right_questions, wrong_questions, question_count ON "public"."user_tests"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."update_user_global_stats"();

-- =====================================================
-- SECCIÓN 7: SPECIALTY ASSIGNMENT
-- =====================================================
-- Auto-asignar especialidad por defecto cuando se crea un usuario/topic

CREATE OR REPLACE FUNCTION "public"."assign_default_specialty"()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_default_specialty_id BIGINT;
BEGIN
    -- Si ya tiene specialty_id asignado, no hacer nada
    IF NEW.specialty_id IS NOT NULL THEN
        RETURN NEW;
    END IF;

    -- Buscar la especialidad por defecto de la academia
    SELECT id INTO v_default_specialty_id
    FROM specialties
    WHERE academy_id = NEW.academy_id
      AND is_default = true
      AND is_active = true
    LIMIT 1;

    -- Asignar si se encontró
    IF v_default_specialty_id IS NOT NULL THEN
        NEW.specialty_id := v_default_specialty_id;
    END IF;

    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."assign_default_specialty"() OWNER TO "postgres";

-- Triggers para auto-asignar specialty
CREATE TRIGGER "trg_users_assign_specialty"
    BEFORE INSERT ON "public"."users"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."assign_default_specialty"();

CREATE TRIGGER "trg_topic_assign_specialty"
    BEFORE INSERT ON "public"."topic"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."assign_default_specialty"();

-- =====================================================
-- SECCIÓN 8: TOPIC GROUP VALIDATION
-- =====================================================
-- Validar que todos los topics de un grupo sean del mismo topic_type

CREATE OR REPLACE FUNCTION "public"."validate_topic_group_same_type"()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_group_topic_type_id BIGINT;
    v_group_count INTEGER;
BEGIN
    -- Si no tiene topic_group_id, no validar
    IF NEW.topic_group_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- Obtener el topic_type_id predominante en el grupo
    SELECT topic_type_id, COUNT(*) as cnt
    INTO v_group_topic_type_id, v_group_count
    FROM topic
    WHERE topic_group_id = NEW.topic_group_id
      AND id != NEW.id  -- Excluir el topic actual
    GROUP BY topic_type_id
    ORDER BY cnt DESC
    LIMIT 1;

    -- Si hay topics en el grupo y el tipo no coincide, rechazar
    IF v_group_topic_type_id IS NOT NULL AND v_group_topic_type_id != NEW.topic_type_id THEN
        RAISE EXCEPTION 'Todos los topics de un grupo deben tener el mismo topic_type_id. Grupo % tiene tipo %, intentando insertar tipo %',
            NEW.topic_group_id, v_group_topic_type_id, NEW.topic_type_id;
    END IF;

    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."validate_topic_group_same_type"() OWNER TO "postgres";

CREATE TRIGGER "trg_validate_topic_group_same_type"
    BEFORE INSERT OR UPDATE OF topic_group_id, topic_type_id ON "public"."topic"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."validate_topic_group_same_type"();

-- =====================================================
-- SECCIÓN 9: AUTH USERS SYNC
-- =====================================================
-- Sincronizar usuarios de auth.users a cms_users

CREATE OR REPLACE FUNCTION "public"."sync_auth_users_to_cms"()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    default_role_id BIGINT := 4;  -- User/Alumno
    default_academy_id BIGINT := 1;  -- OPN
BEGIN
    INSERT INTO public.cms_users (
        user_uuid,
        email,
        role_id,
        academy_id,
        created_at,
        updated_at
    ) VALUES (
        NEW.id,
        NEW.email,
        default_role_id,
        default_academy_id,
        NOW(),
        NOW()
    )
    ON CONFLICT (user_uuid) DO NOTHING;

    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."sync_auth_users_to_cms"() OWNER TO "postgres";

-- Crear el trigger en auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.sync_auth_users_to_cms();

-- =====================================================
-- SECCIÓN 10: ACADEMY KPIS
-- =====================================================
-- Auto-crear KPIs cuando se crea una academia

CREATE OR REPLACE FUNCTION "public"."create_academy_kpis"()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.academy_kpis (academy_id)
    VALUES (NEW.id)
    ON CONFLICT (academy_id) DO NOTHING;

    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."create_academy_kpis"() OWNER TO "postgres";

CREATE TRIGGER "trg_create_academy_kpis"
    AFTER INSERT ON "public"."academies"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."create_academy_kpis"();

-- =====================================================
-- SECCIÓN 11: USER SPECIAL TOPICS FUNCTIONS
-- =====================================================
-- Funciones optimizadas para obtener topics especiales completados por el usuario

-- Función para obtener topics especiales del usuario (con paginación)
CREATE OR REPLACE FUNCTION "public"."get_user_special_topics"(
  p_user_id BIGINT,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  special_topic_id BIGINT,
  special_topic_title TEXT,
  total_attempts INTEGER,
  best_score NUMERIC,
  first_score NUMERIC,
  last_attempt_date TIMESTAMPTZ,
  first_attempt_date TIMESTAMPTZ,
  average_score NUMERIC,
  total_questions INTEGER,
  total_correct INTEGER,
  total_wrong INTEGER
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
  RETURN QUERY
  SELECT
    ut.special_topic AS special_topic_id,
    ut.special_topic_title,
    COUNT(ut.id)::INTEGER AS total_attempts,
    MAX(ut.score) AS best_score,
    FIRST_VALUE(ut.score) OVER (
      PARTITION BY ut.special_topic
      ORDER BY ut.created_at ASC
    ) AS first_score,
    MAX(ut.created_at) AS last_attempt_date,
    MIN(ut.created_at) AS first_attempt_date,
    AVG(ut.score) AS average_score,
    SUM(ut.question_count)::INTEGER AS total_questions,
    SUM(ut.right_questions)::INTEGER AS total_correct,
    SUM(ut.wrong_questions)::INTEGER AS total_wrong
  FROM "public"."user_tests" ut
  WHERE ut.user_id = p_user_id
    AND ut.special_topic IS NOT NULL
    AND ut.finalized = true
    AND ut.visible = true
  GROUP BY ut.special_topic, ut.special_topic_title
  ORDER BY MAX(ut.created_at) DESC, ut.special_topic DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

ALTER FUNCTION "public"."get_user_special_topics"(BIGINT, INTEGER, INTEGER) OWNER TO "postgres";

COMMENT ON FUNCTION "public"."get_user_special_topics"(BIGINT, INTEGER, INTEGER) IS
'Obtiene los topics especiales completados por un usuario con estadísticas agregadas.
Soporta paginación para scroll infinito.
Ordena por fecha de último intento (más recientes primero).';

-- Función para obtener IDs de topics completados por el usuario
CREATE OR REPLACE FUNCTION "public"."get_user_completed_topic_ids"(p_user_id BIGINT)
RETURNS TABLE (
  topic_id BIGINT,
  attempts INTEGER,
  best_score REAL,
  last_attempt_date TIMESTAMPTZ,
  rank_position INTEGER
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
  -- Retorna los IDs de topics que el usuario ha completado
  -- Incluye tanto de user_tests como de topic_mock_rankings
  RETURN QUERY
  WITH user_test_topics AS (
    -- Topics de user_tests (tests normales y especiales)
    SELECT
      t.topic_id,
      COUNT(ut.id)::INTEGER AS attempts,
      MAX(ut.score) AS best_score,
      MAX(ut.created_at) AS last_attempt_date
    FROM "public"."user_tests" ut
    CROSS JOIN LATERAL unnest(ut.topic_ids) AS t(topic_id)
    WHERE ut.user_id = p_user_id
      AND ut.finalized = true
      AND array_length(ut.topic_ids, 1) > 0
    GROUP BY t.topic_id
  ),
  ranking_topics AS (
    -- Topics del ranking (tests Mock)
    SELECT
      tmr.topic_id,
      tmr.attempts::INTEGER,
      tmr.best_score,
      tmr.last_attempt_date,
      tmr.rank_position
    FROM "public"."topic_mock_rankings" tmr
    WHERE tmr.user_id = p_user_id
  ),
  combined AS (
    -- Combinar ambas fuentes, sumando intentos si el topic aparece en ambas
    SELECT
      COALESCE(utt.topic_id, rt.topic_id) AS topic_id,
      COALESCE(utt.attempts, 0) + COALESCE(rt.attempts, 0) AS attempts,
      GREATEST(COALESCE(utt.best_score, 0), COALESCE(rt.best_score, 0)) AS best_score,
      GREATEST(COALESCE(utt.last_attempt_date, '1970-01-01'::timestamptz),
               COALESCE(rt.last_attempt_date, '1970-01-01'::timestamptz)) AS last_attempt_date,
      rt.rank_position
    FROM user_test_topics utt
    FULL OUTER JOIN ranking_topics rt ON utt.topic_id = rt.topic_id
  )
  SELECT
    combined.topic_id,
    combined.attempts,
    combined.best_score,
    combined.last_attempt_date,
    combined.rank_position
  FROM combined
  WHERE combined.topic_id IS NOT NULL
  ORDER BY combined.last_attempt_date DESC;
END;
$$;

ALTER FUNCTION "public"."get_user_completed_topic_ids"(BIGINT) OWNER TO "postgres";

COMMENT ON FUNCTION "public"."get_user_completed_topic_ids"(BIGINT) IS
'Obtiene todos los IDs de topics que el usuario ha completado al menos una vez.
Combina datos de user_tests y topic_mock_rankings para una vista completa.
Incluye estadísticas de intentos, mejor score y última fecha de intento.';

-- Índices adicionales para optimización
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE indexname = 'idx_user_tests_user_special_topic'
    ) THEN
        CREATE INDEX "idx_user_tests_user_special_topic"
        ON "public"."user_tests"("user_id", "special_topic", "created_at" DESC)
        WHERE "special_topic" IS NOT NULL AND "finalized" = true AND "visible" = true;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE indexname = 'idx_user_tests_topic_ids_gin'
    ) THEN
        CREATE INDEX "idx_user_tests_topic_ids_gin"
        ON "public"."user_tests" USING GIN ("topic_ids")
        WHERE "finalized" = true AND array_length("topic_ids", 1) > 0;
    END IF;
END $$;

-- Permisos
GRANT EXECUTE ON FUNCTION "public"."get_user_special_topics"(BIGINT, INTEGER, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION "public"."get_user_special_topics"(BIGINT, INTEGER, INTEGER) TO service_role;

GRANT EXECUTE ON FUNCTION "public"."get_user_completed_topic_ids"(BIGINT) TO authenticated;
GRANT EXECUTE ON FUNCTION "public"."get_user_completed_topic_ids"(BIGINT) TO service_role;

-- =====================================================
-- SECCIÓN 12: USER MOCK STATS FUNCTIONS
-- =====================================================
-- Funciones para obtener estadísticas de tests Mock

-- Función: Obtener estadísticas globales del usuario en Mock tests
CREATE OR REPLACE FUNCTION "public"."get_user_mock_stats"(p_user_id INT)
RETURNS JSON
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT json_build_object(
        'total_mock_tests', COUNT(DISTINCT tmr.topic_id)::integer,
        'average_score', COALESCE(AVG(tmr.first_score), 0),
        'best_score', COALESCE(MAX(tmr.best_score), 0),
        'total_attempts', COALESCE(SUM(tmr.attempts), 0)::integer,
        'average_rank_position', AVG(tmr.rank_position),
        'best_rank_position', MIN(tmr.rank_position),
        'top_3_count', COUNT(*) FILTER (WHERE tmr.rank_position <= 3)::integer,
        'top_10_count', COUNT(*) FILTER (WHERE tmr.rank_position <= 10)::integer,
        'last_attempt_date', MAX(tmr.last_attempt_date)
    ) INTO v_result
    FROM topic_mock_rankings tmr
    INNER JOIN topic t ON t.id = tmr.topic_id
    INNER JOIN topic_type tt ON tt.id = t.topic_type_id
    WHERE tmr.user_id = p_user_id
      AND tt.level = 'Mock'
      AND t.enabled = true
      AND t.published_at IS NOT NULL;

    RETURN v_result;
END;
$$;

ALTER FUNCTION "public"."get_user_mock_stats"(INT) OWNER TO "postgres";

COMMENT ON FUNCTION "public"."get_user_mock_stats"(INT) IS
'Obtiene estadísticas globales del usuario en todos los topics de tipo Mock';

-- Función: Obtener estadísticas detalladas por topic Mock
CREATE OR REPLACE FUNCTION "public"."get_user_topic_mock_stats"(p_user_id INT)
RETURNS TABLE (
    topic_id BIGINT,
    topic_name TEXT,
    first_score NUMERIC,
    best_score NUMERIC,
    attempts INT,
    rank_position INT,
    total_participants INT,
    first_attempt_date TIMESTAMPTZ,
    last_attempt_date TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        tmr.topic_id,
        t.topic_name,
        tmr.first_score,
        tmr.best_score,
        tmr.attempts,
        tmr.rank_position,
        (SELECT COUNT(*)::integer
         FROM topic_mock_rankings tmr_inner
         WHERE tmr_inner.topic_id = tmr.topic_id) AS total_participants,
        tmr.first_attempt_date,
        tmr.last_attempt_date
    FROM topic_mock_rankings tmr
    INNER JOIN topic t ON t.id = tmr.topic_id
    INNER JOIN topic_type tt ON tt.id = t.topic_type_id
    WHERE tmr.user_id = p_user_id
      AND tt.level = 'Mock'
      AND t.enabled = true
      AND t.published_at IS NOT NULL
    ORDER BY tmr.last_attempt_date DESC;
END;
$$;

ALTER FUNCTION "public"."get_user_topic_mock_stats"(INT) OWNER TO "postgres";

COMMENT ON FUNCTION "public"."get_user_topic_mock_stats"(INT) IS
'Obtiene estadísticas detalladas por cada topic Mock completado por el usuario';

-- Función: Obtener datos para gráficos de evolución
CREATE OR REPLACE FUNCTION "public"."get_user_mock_evolution"(p_user_id INT, p_days INT DEFAULT 30)
RETURNS TABLE (
    date TIMESTAMPTZ,
    score NUMERIC,
    topic_name TEXT,
    topic_id INT
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        tmr.last_attempt_date AS date,
        tmr.best_score AS score,
        t.topic_name,
        t.id AS topic_id
    FROM topic_mock_rankings tmr
    INNER JOIN topic t ON t.id = tmr.topic_id
    INNER JOIN topic_type tt ON tt.id = t.topic_type_id
    WHERE tmr.user_id = p_user_id
      AND tt.level = 'Mock'
      AND t.enabled = true
      AND t.published_at IS NOT NULL
      AND tmr.last_attempt_date >= NOW() - (p_days || ' days')::INTERVAL
    ORDER BY tmr.last_attempt_date ASC;
END;
$$;

ALTER FUNCTION "public"."get_user_mock_evolution"(INT, INT) OWNER TO "postgres";

COMMENT ON FUNCTION "public"."get_user_mock_evolution"(INT, INT) IS
'Obtiene datos para gráficos de evolución temporal del usuario en los últimos N días';

-- Función: Obtener comparación del usuario con el promedio
CREATE OR REPLACE FUNCTION "public"."get_user_mock_comparison"(p_user_id INT, p_topic_id INT)
RETURNS JSON
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT json_build_object(
        'user_score', tmr.first_score,
        'user_rank', tmr.rank_position,
        'average_score', (
            SELECT AVG(first_score)
            FROM topic_mock_rankings
            WHERE topic_id = p_topic_id
        ),
        'median_rank', (
            SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rank_position)
            FROM topic_mock_rankings
            WHERE topic_id = p_topic_id
        ),
        'total_participants', (
            SELECT COUNT(*)
            FROM topic_mock_rankings
            WHERE topic_id = p_topic_id
        ),
        'percentile', (
            SELECT CASE
                WHEN COUNT(*) > 0 THEN
                    ((COUNT(*) - tmr.rank_position) * 100.0 / COUNT(*))
                ELSE 0
            END
            FROM topic_mock_rankings
            WHERE topic_id = p_topic_id
        )
    ) INTO v_result
    FROM topic_mock_rankings tmr
    WHERE tmr.user_id = p_user_id
      AND tmr.topic_id = p_topic_id;

    RETURN v_result;
END;
$$;

ALTER FUNCTION "public"."get_user_mock_comparison"(INT, INT) OWNER TO "postgres";

COMMENT ON FUNCTION "public"."get_user_mock_comparison"(INT, INT) IS
'Compara el rendimiento del usuario con el promedio en un topic específico';

-- Función: Obtener progreso/mejora del usuario
CREATE OR REPLACE FUNCTION "public"."get_user_mock_progress"(p_user_id INT)
RETURNS TABLE (
    topic_id INT,
    topic_name TEXT,
    first_score NUMERIC,
    best_score NUMERIC,
    improvement_percentage NUMERIC,
    attempts INT
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        tmr.topic_id,
        t.topic_name,
        tmr.first_score,
        tmr.best_score,
        CASE
            WHEN tmr.first_score > 0 THEN
                ((tmr.best_score - tmr.first_score) / tmr.first_score * 100)
            ELSE 0
        END AS improvement_percentage,
        tmr.attempts
    FROM topic_mock_rankings tmr
    INNER JOIN topic t ON t.id = tmr.topic_id
    INNER JOIN topic_type tt ON tt.id = t.topic_type_id
    WHERE tmr.user_id = p_user_id
      AND tt.level = 'Mock'
      AND t.enabled = true
      AND t.published_at IS NOT NULL
      AND tmr.attempts > 1
    ORDER BY improvement_percentage DESC;
END;
$$;

ALTER FUNCTION "public"."get_user_mock_progress"(INT) OWNER TO "postgres";

COMMENT ON FUNCTION "public"."get_user_mock_progress"(INT) IS
'Obtiene el progreso/mejora del usuario en topics con múltiples intentos';

-- Permisos para funciones Mock stats
GRANT EXECUTE ON FUNCTION "public"."get_user_mock_stats"(INT) TO authenticated;
GRANT EXECUTE ON FUNCTION "public"."get_user_mock_stats"(INT) TO service_role;

GRANT EXECUTE ON FUNCTION "public"."get_user_topic_mock_stats"(INT) TO authenticated;
GRANT EXECUTE ON FUNCTION "public"."get_user_topic_mock_stats"(INT) TO service_role;

GRANT EXECUTE ON FUNCTION "public"."get_user_mock_evolution"(INT, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION "public"."get_user_mock_evolution"(INT, INT) TO service_role;

GRANT EXECUTE ON FUNCTION "public"."get_user_mock_comparison"(INT, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION "public"."get_user_mock_comparison"(INT, INT) TO service_role;

GRANT EXECUTE ON FUNCTION "public"."get_user_mock_progress"(INT) TO authenticated;
GRANT EXECUTE ON FUNCTION "public"."get_user_mock_progress"(INT) TO service_role;

-- =====================================================
-- SECCIÓN 7: UPDATE TOPIC STATS (PARTICIPANTS AND SCORES)
-- =====================================================
-- Actualiza estadísticas de la tabla topic cuando se completa un test con special_topic

CREATE OR REPLACE FUNCTION "public"."update_topic_stats_on_test_complete"()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_is_first_attempt BOOLEAN;
BEGIN
    -- Solo procesar si:
    -- 1. El test tiene special_topic (no es NULL)
    -- 2. El test está finalizado
    -- 3. El test tiene un score válido
    IF NEW.special_topic IS NULL
       OR NEW.finalized IS NOT TRUE
       OR NEW.score IS NULL THEN
        RETURN NEW;
    END IF;

    -- Solo actualizar cuando se finaliza el test (no estaba finalizado antes)
    IF TG_OP = 'UPDATE' AND OLD.finalized = TRUE THEN
        RETURN NEW;
    END IF;

    -- Verificar si es el primer test completado del usuario para este special_topic
    -- Contar tests previos finalizados (excluyendo el actual)
    SELECT NOT EXISTS (
        SELECT 1
        FROM user_tests
        WHERE user_id = NEW.user_id
          AND special_topic = NEW.special_topic
          AND finalized = true
          AND id != NEW.id
    ) INTO v_is_first_attempt;

    -- Actualizar estadísticas del topic
    UPDATE topic
    SET
        total_participants = CASE
            WHEN v_is_first_attempt THEN total_participants + 1
            ELSE total_participants
        END,
        total_score = total_score + NEW.score,
        updated_at = NOW()
    WHERE id = NEW.special_topic;

    RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."update_topic_stats_on_test_complete"() OWNER TO "postgres";

COMMENT ON FUNCTION "public"."update_topic_stats_on_test_complete"() IS
'Actualiza total_participants (solo primera vez por usuario) y total_score (siempre) de la tabla topic cuando se completa un test con special_topic. average_score se calcula automáticamente como columna generada.';

CREATE TRIGGER "trg_update_topic_stats_on_test_complete"
    AFTER INSERT OR UPDATE OF finalized, score ON "public"."user_tests"
    FOR EACH ROW
    EXECUTE FUNCTION "public"."update_topic_stats_on_test_complete"();

-- =====================================================
-- END OF MIGRATION
-- =====================================================

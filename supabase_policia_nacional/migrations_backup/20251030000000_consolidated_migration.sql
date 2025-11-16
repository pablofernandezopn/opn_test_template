-- =====================================================
-- MIGRACIÓN CONSOLIDADA - OPN Guardia Civil
-- =====================================================
-- Autor: Pablo Fernández Lucas
-- Fecha: 2025-10-30
-- Descripción: Migración consolidada que incluye todas las
--              migraciones previas del sistema en un solo archivo
-- 
-- Incluye:
--   - Schema inicial completo (update_from_local)
--   - Sistema de especialidades
--   - Trigger de sincronización auth.users -> users
--   - Academias y roles por defecto
--   - Fix de triggers en membership_levels
--   - Tabla de categorías
--   - Constraints de access_level
--   - Columnas order y category_id en topics
-- =====================================================




SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."challenge_state" AS ENUM (
    'pendiente',
    'resuelta',
    'rechazada'
);


ALTER TYPE "public"."challenge_state" OWNER TO "postgres";


CREATE TYPE "public"."topic_level" AS ENUM (
    'Mock',
    'Study',
    'Flashcard'
);


ALTER TYPE "public"."topic_level" OWNER TO "postgres";


COMMENT ON TYPE "public"."topic_level" IS 'Tipos de topics: Mock (simulacros), Study (estudio), Flashcard (tarjetas de estudio con spaced repetition)';



CREATE OR REPLACE FUNCTION "public"."calculate_answer_correctness"() RETURNS "trigger"
    LANGUAGE "plpgsql"
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


COMMENT ON FUNCTION "public"."calculate_answer_correctness"() IS 'Calcula si una respuesta es correcta. Para flashcards retorna NULL (no aplica), para tests normales valida contra is_correct';



CREATE OR REPLACE FUNCTION "public"."calculate_next_review_flashcard"("p_difficulty_rating" character varying, "p_current_ease_factor" numeric, "p_current_interval_days" integer, "p_current_repetitions" integer) RETURNS TABLE("next_review_date" timestamp with time zone, "new_interval_days" integer, "new_ease_factor" numeric, "new_repetitions" integer)
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_ease_factor DECIMAL(4,2);
    v_interval INTEGER;
    v_repetitions INTEGER;
BEGIN
    -- Inicializar valores
    v_ease_factor := p_current_ease_factor;
    v_interval := p_current_interval_days;
    v_repetitions := p_current_repetitions;

    -- Calcular según rating (basado en algoritmo SM-2 modificado estilo Anki)
    CASE p_difficulty_rating
        WHEN 'again' THEN
            -- No la sabía: reiniciar
            v_interval := 1;
            v_repetitions := 0;
            v_ease_factor := GREATEST(1.30, v_ease_factor - 0.20); -- Reducir facilidad

        WHEN 'hard' THEN
            -- Difícil: intervalo moderado
            v_interval := GREATEST(1, FLOOR(v_interval * 1.2));
            v_repetitions := v_repetitions + 1;
            v_ease_factor := GREATEST(1.30, v_ease_factor - 0.15);

        WHEN 'medium' THEN
            -- Medio: intervalo normal
            IF v_repetitions = 0 THEN
                v_interval := 1;
            ELSIF v_repetitions = 1 THEN
                v_interval := 6;
            ELSE
                v_interval := FLOOR(v_interval * v_ease_factor);
            END IF;
            v_repetitions := v_repetitions + 1;
            -- Ease factor se mantiene

        WHEN 'easy' THEN
            -- Fácil: intervalo largo
            IF v_repetitions = 0 THEN
                v_interval := 4;
            ELSE
                v_interval := FLOOR(v_interval * v_ease_factor * 1.3);
            END IF;
            v_repetitions := v_repetitions + 1;
            v_ease_factor := LEAST(2.50, v_ease_factor + 0.15); -- Aumentar facilidad

        ELSE
            -- Default: mantener valores actuales
            v_interval := 1;
    END CASE;

    -- Calcular fecha de próxima revisión
    RETURN QUERY SELECT
        (NOW() + (v_interval || ' days')::INTERVAL)::TIMESTAMPTZ,
        v_interval,
        v_ease_factor,
        v_repetitions;
END;
$$;


ALTER FUNCTION "public"."calculate_next_review_flashcard"("p_difficulty_rating" character varying, "p_current_ease_factor" numeric, "p_current_interval_days" integer, "p_current_repetitions" integer) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."calculate_next_review_flashcard"("p_difficulty_rating" character varying, "p_current_ease_factor" numeric, "p_current_interval_days" integer, "p_current_repetitions" integer) IS 'Calcula la próxima fecha de revisión usando algoritmo SM-2 modificado (estilo Anki) basado en el rating de dificultad';



CREATE OR REPLACE FUNCTION "public"."calculate_test_score"("test_id" bigint) RETURNS real
    LANGUAGE "plpgsql"
    AS $$DECLARE
  test_record RECORD;
  avg_penalty numeric;  -- Cambio de real a numeric
  calculated_score numeric;  -- Cambio de real a numeric
BEGIN
  -- Obtener datos del test
  SELECT right_questions, wrong_questions, question_count, topic_ids, special_topic
  INTO test_record
  FROM user_tests
  WHERE id = test_id;

  -- Si no hay preguntas, score = 0
  IF test_record.question_count = 0 THEN
    RETURN 0;
  END IF;

  -- Calcular penalty promedio según el tipo de test
  IF test_record.special_topic IS NOT NULL THEN
    -- Test de un solo topic: usar su penalty
    SELECT COALESCE(penalty, 0) INTO avg_penalty
    FROM topic t
    JOIN topic_type tt ON t.topic_type_id = tt.id
    WHERE t.id = test_record.special_topic;
  ELSE
    -- Test mixto: promedio de penalties de los topics
    SELECT COALESCE(AVG(tt.penalty), 0) INTO avg_penalty
    FROM topic t
    JOIN topic_type tt ON t.topic_type_id = tt.id
    WHERE t.id = ANY(test_record.topic_ids);
  END IF;

  -- Calcular score con penalización
  calculated_score := GREATEST(
    0,
    (test_record.right_questions - (test_record.wrong_questions * avg_penalty)) * 10.0 / test_record.question_count
  );

  RETURN ROUND(calculated_score, 2);  -- Ahora esto funcionará
END;$$;


ALTER FUNCTION "public"."calculate_test_score"("test_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_user_has_active_membership"("p_user_id" "uuid" DEFAULT NULL::"uuid", "p_wordpress_user_id" integer DEFAULT NULL::integer, "p_email" character varying DEFAULT NULL::character varying) RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_has_membership BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1 
        FROM public.user_memberships
        WHERE 
            (p_user_id IS NOT NULL AND user_id = p_user_id)
            OR (p_wordpress_user_id IS NOT NULL AND wordpress_user_id = p_wordpress_user_id)
            OR (p_email IS NOT NULL AND email = p_email)
        AND status = 'active'
        AND (expires_at IS NULL OR expires_at > NOW())
    ) INTO v_has_membership;
    
    RETURN v_has_membership;
END;
$$;


ALTER FUNCTION "public"."check_user_has_active_membership"("p_user_id" "uuid", "p_wordpress_user_id" integer, "p_email" character varying) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_academy_kpis"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  INSERT INTO public.academy_kpis (academy_id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."create_academy_kpis"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_blank_question_options"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$DECLARE
    num_options_to_create INTEGER;
    topic_id_to_use BIGINT;
    topic_level_value public.topic_level;
BEGIN
    -- Determinar qué topic usar
    topic_id_to_use := NEW.topic;

    -- Obtener el level del topic_type asociado
    SELECT tt.level
    INTO topic_level_value
    FROM topic t
    JOIN topic_type tt ON t.topic_type_id = tt.id
    WHERE t.id = topic_id_to_use;

    -- Si es Flashcard, siempre crear exactamente 2 opciones
    IF topic_level_value = 'Flashcard' THEN
        num_options_to_create := 2;

        -- Insertar 2 opciones específicas para flashcard
        INSERT INTO question_options (question_id, answer, is_correct, option_order)
        VALUES
            (NEW.id, 'Pregunta/Frente', false, 1),
            (NEW.id, 'Respuesta/Reverso', false, 2);

        RETURN NEW;
    END IF;

    -- Para otros tipos de topics, usar lógica original
    SELECT options
    INTO num_options_to_create
    FROM topic
    WHERE id = topic_id_to_use;

    -- Si no se encuentra el topic, usar el primer topic de la lista como fallback
    IF num_options_to_create IS NULL THEN
        SELECT options
        INTO num_options_to_create
        FROM topic
        WHERE enabled = true
        ORDER BY id ASC
        LIMIT 1;

        -- Si aún no hay opciones, usar 3 como valor por defecto
        IF num_options_to_create IS NULL THEN
            num_options_to_create := 3;
        END IF;
    END IF;

    -- Insertar las opciones en blanco
    INSERT INTO question_options (question_id, answer, is_correct, option_order)
    SELECT
        NEW.id,
        '', -- Un espacio para cumplir con validaciones
        false,
        generate_series(1, num_options_to_create);

    RETURN NEW;
END;$$;


ALTER FUNCTION "public"."create_blank_question_options"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."create_blank_question_options"() IS 'Crea opciones para nuevas preguntas. Para Flashcards crea exactamente 2 opciones etiquetadas, para otros tipos usa el número definido en topic.options';



CREATE OR REPLACE FUNCTION "public"."fn_adjust_question_count"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  total_questions int;
  impugnadas int;
  topic_questions int;
  is_psycho_with_config boolean;
BEGIN
  -- Verificar si el specialTopic es psicotécnico con convocatoria
  IF NEW."specialTopic" IS NOT NULL THEN
    SELECT
      t.questions,
      (t."isPsychoTechnical" = true AND t.mark_collection_config IS NOT NULL)
    INTO topic_questions, is_psycho_with_config
    FROM topics t
    WHERE t.id = NEW."specialTopic";

    -- Si es psicotécnico con convocatoria, usar topics.questions como límite
    IF COALESCE(is_psycho_with_config, false) THEN
      -- Usar solo las primeras topic_questions del array
      total_questions := LEAST(topic_questions, array_length(NEW.questions, 1));
    ELSE
      -- Comportamiento normal: usar todas las preguntas del array
      total_questions := array_length(NEW.questions, 1);
    END IF;
  ELSE
    -- Si no hay specialTopic, usar todas las preguntas del array
    total_questions := array_length(NEW.questions, 1);
  END IF;

  -- Contar cuántas de las primeras total_questions están impugnadas
  SELECT count(*)
  INTO impugnadas
  FROM (
    SELECT unnest(NEW.questions[1:total_questions]) AS qid
  ) sub
  JOIN questions q ON q.id = sub.qid
  WHERE COALESCE(q.challenge_by_tutor, false) = true;

  -- Asignar el nuevo question_count
  NEW.question_count := total_questions - impugnadas;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."fn_adjust_question_count"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."fn_adjust_question_count"() IS 'Ajusta question_count al insertar un user_tests, descontando preguntas impugnadas.
Para topics psicotécnicos con convocatoria (mark_collection_config), usa topics.questions
como límite en lugar de contar todas las preguntas del array.';



CREATE OR REPLACE FUNCTION "public"."fn_challenge_by_tutor_update"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  question_topic BIGINT;
BEGIN
  -- Solo si cambia el flag
  IF OLD.challenge_by_tutor IS DISTINCT FROM NEW.challenge_by_tutor THEN

    -- Obtener el topic de la pregunta
    question_topic := OLD.topic;

    /* FALSE -> TRUE  (impugnar / desactivar) */
    IF OLD.challenge_by_tutor = FALSE AND NEW.challenge_by_tutor = TRUE THEN

      -- 1) Actualizar contador en topics (solo si NO es psicotécnico con convocatoria)
      UPDATE topics
         SET questions = GREATEST(COALESCE(questions,0) - 1, 0)
       WHERE id = question_topic
         AND NOT ("isPsychoTechnical" = true AND mark_collection_config IS NOT NULL);

      -- 2) Guardar en historial y ajustar tests afectados
      WITH affected_tests AS (
        SELECT
          ut.id AS user_test_id,
          array_position(ut.questions, OLD.id) AS pos,
          ut.answers[array_position(ut.questions, OLD.id)] AS user_answer
        FROM user_tests ut
        WHERE ut.questions @> ARRAY[OLD.id]
          AND ut."specialTopic" = question_topic
      ),
      history_inserts AS (
        INSERT INTO removed_questions_history
          (user_test_id, question_id, was_correct, was_wrong)
        SELECT
          user_test_id,
          OLD.id,
          (user_answer = OLD.solution),
          (user_answer IS NOT NULL AND user_answer <> OLD.solution)
        FROM affected_tests
        RETURNING user_test_id, was_correct, was_wrong
      )
      UPDATE user_tests ut
         SET question_count   = ut.question_count - 1,
             "rightQuestions" = ut."rightQuestions" - CASE WHEN hi.was_correct THEN 1 ELSE 0 END,
             "wrongQuestions" = ut."wrongQuestions" - CASE WHEN hi.was_wrong THEN 1 ELSE 0 END
        FROM history_inserts hi
       WHERE ut.id = hi.user_test_id;

    /* TRUE -> FALSE  (reactivar) */
    ELSIF OLD.challenge_by_tutor = TRUE AND NEW.challenge_by_tutor = FALSE THEN

      -- 1) Actualizar contador en topics (solo si NO es psicotécnico con convocatoria)
      UPDATE topics
         SET questions = COALESCE(questions,0) + 1
       WHERE id = question_topic
         AND NOT ("isPsychoTechnical" = true AND mark_collection_config IS NOT NULL);

      -- 2) Restaurar contadores desde historial
      WITH history_data AS (
        SELECT
          rh.user_test_id,
          rh.was_correct,
          rh.was_wrong
        FROM removed_questions_history rh
        JOIN user_tests ut ON rh.user_test_id = ut.id
        WHERE rh.question_id = OLD.id
          AND ut."specialTopic" = question_topic
      )
      UPDATE user_tests ut
         SET question_count   = ut.question_count + 1,
             "rightQuestions" = ut."rightQuestions" + CASE WHEN hd.was_correct THEN 1 ELSE 0 END,
             "wrongQuestions" = ut."wrongQuestions" + CASE WHEN hd.was_wrong THEN 1 ELSE 0 END
        FROM history_data hd
       WHERE ut.id = hd.user_test_id;

      -- 3) Eliminar del historial
      DELETE FROM removed_questions_history
      WHERE question_id = OLD.id;

    END IF;

  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."fn_challenge_by_tutor_update"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."fn_challenge_by_tutor_update"() IS 'Actualiza automáticamente user_tests cuando se impugna o reactiva una pregunta.

Cuando se impugna (challenge_by_tutor: false → true):
- Guarda en historial si la respuesta era correcta/incorrecta
- Resta 1 a question_count, rightQuestions o wrongQuestions según corresponda
- Resta 1 a topics.questions (excepto psicotécnicos con convocatoria)

Cuando se reactiva (challenge_by_tutor: true → false):
- Restaura los contadores desde el historial
- Suma 1 a topics.questions (excepto psicotécnicos con convocatoria)
- Elimina la entrada del historial';



CREATE OR REPLACE FUNCTION "public"."get_user_membership_level"("p_user_id" "uuid" DEFAULT NULL::"uuid", "p_wordpress_user_id" integer DEFAULT NULL::integer, "p_email" character varying DEFAULT NULL::character varying) RETURNS TABLE("membership_level_name" character varying, "membership_level_slug" character varying, "expires_at" timestamp with time zone, "status" character varying)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ml.name,
        ml.slug,
        um.expires_at,
        um.status
    FROM public.user_memberships um
    JOIN public.membership_levels ml ON um.membership_level_id = ml.id
    WHERE 
        (p_user_id IS NOT NULL AND um.user_id = p_user_id)
        OR (p_wordpress_user_id IS NOT NULL AND um.wordpress_user_id = p_wordpress_user_id)
        OR (p_email IS NOT NULL AND um.email = p_email)
    AND um.status = 'active'
    AND (um.expires_at IS NULL OR um.expires_at > NOW())
    ORDER BY um.started_at DESC
    LIMIT 1;
END;
$$;


ALTER FUNCTION "public"."get_user_membership_level"("p_user_id" "uuid", "p_wordpress_user_id" integer, "p_email" character varying) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."recalculate_academy_kpis"("p_academy_id" bigint) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_total_users BIGINT;
  v_total_premium BIGINT;
  v_premium_plus BIGINT;
  v_total_questions BIGINT;
  v_total_tests BIGINT;
  v_users_today BIGINT;
  v_new_users_today BIGINT;
  v_answers_today BIGINT;
  v_flashcard_answers_today BIGINT;
BEGIN
  -- Contar usuarios totales
  SELECT COUNT(*) INTO v_total_users
  FROM users
  WHERE academy_id = p_academy_id;
  
  -- Contar usuarios premium (level 2)
  SELECT COUNT(DISTINCT um.user_id) INTO v_total_premium
  FROM user_memberships um
  JOIN users u ON u.id = um.user_id
  JOIN membership_levels ml ON ml.id = um.membership_level_id
  WHERE u.academy_id = p_academy_id
    AND um.status = 'active'
    AND ml.access_level = 2;
  
  -- Contar usuarios premium plus (level 3)
  SELECT COUNT(DISTINCT um.user_id) INTO v_premium_plus
  FROM user_memberships um
  JOIN users u ON u.id = um.user_id
  JOIN membership_levels ml ON ml.id = um.membership_level_id
  WHERE u.academy_id = p_academy_id
    AND um.status = 'active'
    AND ml.access_level = 3;
  
  -- Contar preguntas totales
  SELECT COUNT(*) INTO v_total_questions
  FROM questions
  WHERE academy_id = p_academy_id;
  
  -- Contar tests finalizados
  SELECT COUNT(*) INTO v_total_tests
  FROM user_tests ut
  JOIN users u ON u.id = ut.user_id
  WHERE u.academy_id = p_academy_id
    AND ut.finalized = TRUE;
  
  -- KPIs de hoy
  SELECT COUNT(*) INTO v_users_today
  FROM users
  WHERE academy_id = p_academy_id
    AND DATE("lastUsed") = CURRENT_DATE;
  
  SELECT COUNT(*) INTO v_new_users_today
  FROM users
  WHERE academy_id = p_academy_id
    AND DATE("createdAt") = CURRENT_DATE;
  
  -- Respuestas de hoy (tests normales)
  SELECT COUNT(*) INTO v_answers_today
  FROM user_test_answers uta
  JOIN user_tests ut ON ut.id = uta.user_test_id
  JOIN users u ON u.id = ut.user_id
  WHERE u.academy_id = p_academy_id
    AND DATE(uta.answered_at) = CURRENT_DATE
    AND (ut.is_flashcard_mode = FALSE OR ut.is_flashcard_mode IS NULL);
  
  -- Respuestas de hoy (flashcards)
  SELECT COUNT(*) INTO v_flashcard_answers_today
  FROM user_test_answers uta
  JOIN user_tests ut ON ut.id = uta.user_test_id
  JOIN users u ON u.id = ut.user_id
  WHERE u.academy_id = p_academy_id
    AND DATE(uta.answered_at) = CURRENT_DATE
    AND ut.is_flashcard_mode = TRUE;
  
  -- Actualizar KPIs
  UPDATE academy_kpis
  SET total_users = v_total_users,
      total_premium_users = v_total_premium,
      premium_plus_users = v_premium_plus,
      total_questions = v_total_questions,
      total_tests = v_total_tests,
      total_users_today = v_users_today,
      new_users_today = v_new_users_today,
      total_answers_today = v_answers_today,
      total_flashcard_answers_today = v_flashcard_answers_today,
      updated_at = NOW()
  WHERE academy_id = p_academy_id;
  
  RAISE NOTICE 'KPIs recalculados para academia %', p_academy_id;
END;
$$;


ALTER FUNCTION "public"."recalculate_academy_kpis"("p_academy_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."recalculate_questions_difficulty"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
begin
  -- Preguntas normales (basado en estadísticas)
  update questions q
  set difficult_rate = round(
    case when (num_answered + num_fails + num_empty) > 0 then
      ((num_fails + num_empty)::numeric / (num_answered + num_fails + num_empty))
    else 0 end, 3
  )
  where q.id not in (
    select distinct question_id from user_test_answers where difficulty_rating is not null
  );

  -- Flashcards (basado en difficulty_rating)
  update questions q
  set difficult_rate = round(avg_map.avg_difficulty::numeric, 3)
  from (
    select
      question_id,
      avg(
        case difficulty_rating
          when 'again' then 1.0
          when 'hard' then 0.75
          when 'medium' then 0.5
          when 'easy' then 0.25
        end
      ) as avg_difficulty
    from user_test_answers
    where difficulty_rating is not null
    group by question_id
  ) as avg_map
  where q.id = avg_map.question_id;
end;
$$;


ALTER FUNCTION "public"."recalculate_questions_difficulty"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."reset_academy_daily_kpis"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  UPDATE academy_kpis 
  SET total_users_today = 0,
      new_users_today = 0,
      total_answers_today = 0,
      total_flashcard_answers_today = 0;
END;
$$;


ALTER FUNCTION "public"."reset_academy_daily_kpis"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_topic_options_from_type"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Si no se especifica options o es el valor por defecto (3),
    -- obtener el valor de default_number_options del topic_type
    IF NEW.options IS NULL OR NEW.options = 3 THEN
        SELECT default_number_options
        INTO NEW.options
        FROM topic_type
        WHERE id = NEW.topic_type_id;

        -- Validar que se encontró el topic_type
        IF NEW.options IS NULL THEN
            RAISE EXCEPTION 'No se encontró topic_type con id %', NEW.topic_type_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_topic_options_from_type"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_user_test_defaults_from_topic"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    topic_record RECORD;
BEGIN
    -- Solo si hay special_topic, obtener datos de ese topic
    IF NEW.special_topic IS NOT NULL THEN
        SELECT options, total_questions
        INTO topic_record
        FROM topic
        WHERE id = NEW.special_topic;

        IF FOUND THEN
            -- Usar valores del special_topic
            IF NEW.options = 4 THEN  -- Solo si es el valor por defecto
                NEW.options := topic_record.options;
            END IF;
            NEW.question_count := topic_record.total_questions;
        END IF;
    ELSE
        -- Cuando special_topic = null, NO calcular question_count
        -- Mantener el valor que viene de la app
        -- Solo obtener options del primer topic si es necesario
        IF array_length(NEW.topic_ids, 1) > 0 AND NEW.options = 4 THEN
            SELECT options
            INTO topic_record
            FROM topic
            WHERE id = NEW.topic_ids[1];

            IF FOUND THEN
                NEW.options := topic_record.options;
            END IF;
        END IF;

        -- NEW.question_count se mantiene como viene de la app
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_user_test_defaults_from_topic"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_auth_users_to_cms"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'auth'
    AS $$
BEGIN
    -- Para INSERT y UPDATE
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        IF NEW.id IS NOT NULL THEN
            INSERT INTO public.cms_users (
                user_uuid,
                email,
                created_at,
                updated_at,
                username,
                nombre,
                apellido,
                role_id,
                academy_id  -- NUEVO: Asignar academia OPN por defecto
            ) VALUES (
                NEW.id,
                NEW.email,
                COALESCE(NEW.created_at, NOW()),
                NOW(),
                COALESCE(NEW.email, 'sin usuario'),
                'sin nombre',
                'sin apellido',
                4,
                1  -- NUEVO: Academia OPN por defecto
            )
            ON CONFLICT (user_uuid) DO UPDATE SET
                email = EXCLUDED.email,
                updated_at = NOW();
        END IF;
        RETURN NEW;
    END IF;

    -- Para DELETE
    IF TG_OP = 'DELETE' THEN
        IF OLD.id IS NOT NULL THEN
            UPDATE public.cms_users
            SET
                email = NULL,
                updated_at = NOW()
            WHERE user_uuid = OLD.id;
        END IF;
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."sync_auth_users_to_cms"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."sync_auth_users_to_cms"() IS 'Sincroniza usuarios de auth.users a cms_users asignando academy_id = 1 (OPN) por defecto';


-- Trigger para sincronizar usuarios de auth.users a cms_users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT OR UPDATE OR DELETE ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.sync_auth_users_to_cms();


CREATE OR REPLACE FUNCTION "public"."update_academies_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_academies_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_academy_daily_answers"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  user_academy_id BIGINT;
  is_flashcard BOOLEAN;
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- Obtener academy_id y tipo de test
    SELECT u.academy_id, ut.is_flashcard_mode 
    INTO user_academy_id, is_flashcard
    FROM users u
    JOIN user_tests ut ON ut.user_id = u.id
    WHERE ut.id = NEW.user_test_id;
    
    -- Solo contar si la respuesta es de hoy
    IF DATE(NEW.answered_at) = CURRENT_DATE THEN
      IF is_flashcard = TRUE THEN
        UPDATE academy_kpis 
        SET total_flashcard_answers_today = total_flashcard_answers_today + 1
        WHERE academy_id = user_academy_id;
      ELSE
        UPDATE academy_kpis 
        SET total_answers_today = total_answers_today + 1
        WHERE academy_id = user_academy_id;
      END IF;
    END IF;
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_academy_daily_answers"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_academy_daily_kpis_users"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- Solo contar si el usuario se creó hoy
    IF DATE(NEW."createdAt") = CURRENT_DATE THEN
      UPDATE academy_kpis 
      SET new_users_today = new_users_today + 1,
          total_users_today = total_users_today + 1
      WHERE academy_id = NEW.academy_id;
    END IF;
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_academy_daily_kpis_users"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_academy_kpi"("p_academy_id" bigint, "p_kpi_name" "text", "p_increment" bigint DEFAULT 1) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
  EXECUTE format(
    'UPDATE public.academy_kpis SET %I = %I + $1 WHERE academy_id = $2',
    p_kpi_name, p_kpi_name
  ) USING p_increment, p_academy_id;
END;
$_$;


ALTER FUNCTION "public"."update_academy_kpi"("p_academy_id" bigint, "p_kpi_name" "text", "p_increment" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_academy_kpis_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_academy_kpis_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_academy_premium_users"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  old_level INTEGER;
  new_level INTEGER;
BEGIN
  -- Obtener niveles de acceso
  IF TG_OP IN ('DELETE', 'UPDATE') THEN
    SELECT access_level INTO old_level
    FROM membership_levels
    WHERE id = OLD.membership_level_id;
  END IF;
  
  IF TG_OP IN ('INSERT', 'UPDATE') THEN
    SELECT access_level INTO new_level
    FROM membership_levels
    WHERE id = NEW.membership_level_id;
  END IF;

  IF TG_OP = 'INSERT' AND NEW.status = 'active' THEN
    -- Nuevo usuario premium activo
    IF new_level = 2 THEN
      UPDATE academy_kpis ak
      SET total_premium_users = total_premium_users + 1
      FROM users u
      WHERE ak.academy_id = u.academy_id AND u.id = NEW.user_id;
    ELSIF new_level = 3 THEN
      UPDATE academy_kpis ak
      SET premium_plus_users = premium_plus_users + 1
      FROM users u
      WHERE ak.academy_id = u.academy_id AND u.id = NEW.user_id;
    END IF;
    RETURN NEW;
    
  ELSIF TG_OP = 'DELETE' AND OLD.status = 'active' THEN
    -- Eliminar usuario premium activo
    IF old_level = 2 THEN
      UPDATE academy_kpis ak
      SET total_premium_users = total_premium_users - 1
      FROM users u
      WHERE ak.academy_id = u.academy_id AND u.id = OLD.user_id;
    ELSIF old_level = 3 THEN
      UPDATE academy_kpis ak
      SET premium_plus_users = premium_plus_users - 1
      FROM users u
      WHERE ak.academy_id = u.academy_id AND u.id = OLD.user_id;
    END IF;
    RETURN OLD;
    
  ELSIF TG_OP = 'UPDATE' THEN
    -- Cambio de estado o nivel de membresía
    IF OLD.status = 'active' AND NEW.status != 'active' THEN
      -- Usuario deja de estar activo
      IF old_level = 2 THEN
        UPDATE academy_kpis ak
        SET total_premium_users = total_premium_users - 1
        FROM users u
        WHERE ak.academy_id = u.academy_id AND u.id = OLD.user_id;
      ELSIF old_level = 3 THEN
        UPDATE academy_kpis ak
        SET premium_plus_users = premium_plus_users - 1
        FROM users u
        WHERE ak.academy_id = u.academy_id AND u.id = OLD.user_id;
      END IF;
    ELSIF OLD.status != 'active' AND NEW.status = 'active' THEN
      -- Usuario se activa
      IF new_level = 2 THEN
        UPDATE academy_kpis ak
        SET total_premium_users = total_premium_users + 1
        FROM users u
        WHERE ak.academy_id = u.academy_id AND u.id = NEW.user_id;
      ELSIF new_level = 3 THEN
        UPDATE academy_kpis ak
        SET premium_plus_users = premium_plus_users + 1
        FROM users u
        WHERE ak.academy_id = u.academy_id AND u.id = NEW.user_id;
      END IF;
    ELSIF OLD.status = 'active' AND NEW.status = 'active' 
          AND OLD.membership_level_id != NEW.membership_level_id THEN
      -- Cambio de nivel de membresía (ambos activos)
      -- Restar el nivel anterior
      IF old_level = 2 THEN
        UPDATE academy_kpis ak
        SET total_premium_users = total_premium_users - 1
        FROM users u
        WHERE ak.academy_id = u.academy_id AND u.id = OLD.user_id;
      ELSIF old_level = 3 THEN
        UPDATE academy_kpis ak
        SET premium_plus_users = premium_plus_users - 1
        FROM users u
        WHERE ak.academy_id = u.academy_id AND u.id = OLD.user_id;
      END IF;
      
      -- Sumar el nuevo nivel
      IF new_level = 2 THEN
        UPDATE academy_kpis ak
        SET total_premium_users = total_premium_users + 1
        FROM users u
        WHERE ak.academy_id = u.academy_id AND u.id = NEW.user_id;
      ELSIF new_level = 3 THEN
        UPDATE academy_kpis ak
        SET premium_plus_users = premium_plus_users + 1
        FROM users u
        WHERE ak.academy_id = u.academy_id AND u.id = NEW.user_id;
      END IF;
    END IF;
    RETURN NEW;
  END IF;
  
  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_academy_premium_users"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_academy_total_questions"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE academy_kpis 
    SET total_questions = total_questions + 1
    WHERE academy_id = NEW.academy_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE academy_kpis 
    SET total_questions = total_questions - 1
    WHERE academy_id = OLD.academy_id;
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' AND OLD.academy_id != NEW.academy_id THEN
    -- Si cambia de academia
    UPDATE academy_kpis 
    SET total_questions = total_questions - 1
    WHERE academy_id = OLD.academy_id;
    
    UPDATE academy_kpis 
    SET total_questions = total_questions + 1
    WHERE academy_id = NEW.academy_id;
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_academy_total_questions"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_academy_total_tests"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  user_academy_id BIGINT;
BEGIN
  IF TG_OP = 'INSERT' AND NEW.finalized = TRUE THEN
    -- Obtener academy_id del usuario
    SELECT academy_id INTO user_academy_id
    FROM users
    WHERE id = NEW.user_id;
    
    UPDATE academy_kpis 
    SET total_tests = total_tests + 1
    WHERE academy_id = user_academy_id;
    RETURN NEW;
    
  ELSIF TG_OP = 'DELETE' AND OLD.finalized = TRUE THEN
    -- Obtener academy_id del usuario
    SELECT academy_id INTO user_academy_id
    FROM users
    WHERE id = OLD.user_id;
    
    UPDATE academy_kpis 
    SET total_tests = total_tests - 1
    WHERE academy_id = user_academy_id;
    RETURN OLD;
    
  ELSIF TG_OP = 'UPDATE' THEN
    -- Obtener academy_id del usuario
    SELECT academy_id INTO user_academy_id
    FROM users
    WHERE id = NEW.user_id;
    
    IF OLD.finalized = FALSE AND NEW.finalized = TRUE THEN
      -- Test se finaliza
      UPDATE academy_kpis 
      SET total_tests = total_tests + 1
      WHERE academy_id = user_academy_id;
    ELSIF OLD.finalized = TRUE AND NEW.finalized = FALSE THEN
      -- Test se desfinaliza (raro pero posible)
      UPDATE academy_kpis 
      SET total_tests = total_tests - 1
      WHERE academy_id = user_academy_id;
    END IF;
    RETURN NEW;
  END IF;
  
  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_academy_total_tests"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_academy_total_users"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE academy_kpis 
    SET total_users = total_users + 1
    WHERE academy_id = NEW.academy_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE academy_kpis 
    SET total_users = total_users - 1
    WHERE academy_id = OLD.academy_id;
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' AND OLD.academy_id != NEW.academy_id THEN
    -- Si cambia de academia (raro pero posible)
    UPDATE academy_kpis 
    SET total_users = total_users - 1
    WHERE academy_id = OLD.academy_id;
    
    UPDATE academy_kpis 
    SET total_users = total_users + 1
    WHERE academy_id = NEW.academy_id;
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_academy_total_users"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_challenge_timestamp"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_challenge_timestamp"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_flashcard_review_schedule"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_review_data RECORD;
    v_is_flashcard BOOLEAN;
BEGIN
    -- Verificar si el test es de flashcards
    SELECT is_flashcard_mode INTO v_is_flashcard
    FROM user_tests
    WHERE id = NEW.user_test_id;

    -- Solo aplicar si es flashcard mode y tiene difficulty_rating
    IF v_is_flashcard AND NEW.difficulty_rating IS NOT NULL THEN
        -- Calcular próxima revisión
        SELECT * INTO v_review_data
        FROM calculate_next_review_flashcard(
            NEW.difficulty_rating,
            COALESCE(NEW.ease_factor, 2.50),
            COALESCE(NEW.review_interval_days, 1),
            COALESCE(NEW.repetitions, 0)
        );

        -- Actualizar campos
        NEW.next_review_date := v_review_data.next_review_date;
        NEW.review_interval_days := v_review_data.new_interval_days;
        NEW.ease_factor := v_review_data.new_ease_factor;
        NEW.repetitions := v_review_data.new_repetitions;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_flashcard_review_schedule"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_flashcard_review_schedule"() IS 'Trigger que actualiza automáticamente next_review_date cuando se registra un difficulty_rating en flashcards';



CREATE OR REPLACE FUNCTION "public"."update_membership_levels_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_membership_levels_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_single_topic_stats"("topic_id" bigint) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    stats_record RECORD;
BEGIN
    -- Calcular estadísticas de user_tests finalizados para este special_topic
    SELECT
        COUNT(*) as participant_count,
        COALESCE(SUM(score), 0) as total_score_sum,
        COALESCE(MIN(score), 0) as min_score_val,
        COALESCE(MAX(score), 0) as max_score_val
    INTO stats_record
    FROM user_tests
    WHERE special_topic = topic_id
    AND finalized = true
    AND score IS NOT NULL;

    -- Actualizar las estadísticas en la tabla topic
    UPDATE topic
    SET
        total_participants = stats_record.participant_count,
        total_score = stats_record.total_score_sum::bigint,
        min_score = stats_record.min_score_val::integer,
        max_score = stats_record.max_score_val::integer
    WHERE id = topic_id;
END;
$$;


ALTER FUNCTION "public"."update_single_topic_stats"("topic_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_topic_duration_from_count"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$DECLARE
  v_time_by_question DOUBLE PRECISION;
  v_num_questions BIGINT;
BEGIN
  -- Obtener el time_by_question y total_questions del topic
  SELECT tt.time_by_question, t.total_questions
  INTO v_time_by_question, v_num_questions
  FROM topic t
  JOIN topic_type tt ON tt.id = t.topic_type_id
  WHERE t.id = COALESCE(NEW.topic, OLD.topic);

  -- Recalcular duración, redondeando hacia arriba
  UPDATE topic
  SET duration_seconds = CEIL(COALESCE(v_time_by_question * v_num_questions, 0))*60
  WHERE id = COALESCE(NEW.topic, OLD.topic);

  RETURN NULL;
END;$$;


ALTER FUNCTION "public"."update_topic_duration_from_count"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_topic_question_count_optimized"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Para INSERT: solo si la pregunta está publicada
    IF TG_OP = 'INSERT' THEN
        IF NEW.published = true THEN
            UPDATE topic
            SET total_questions = total_questions + 1
            WHERE id = NEW.topic;
        END IF;
        RETURN NEW;
    END IF;

    -- Para UPDATE: solo si cambió published o topic
    IF TG_OP = 'UPDATE' THEN
        -- Si cambió el estado published
        IF OLD.published != NEW.published THEN
            IF NEW.published = true THEN
                UPDATE topic SET total_questions = total_questions + 1 WHERE id = NEW.topic;
            ELSE
                UPDATE topic SET total_questions = total_questions - 1 WHERE id = NEW.topic;
            END IF;
        END IF;

        -- Si cambió de topic
        IF OLD.topic != NEW.topic THEN
            IF OLD.published = true THEN
                UPDATE topic SET total_questions = total_questions - 1 WHERE id = OLD.topic;
            END IF;
            IF NEW.published = true THEN
                UPDATE topic SET total_questions = total_questions + 1 WHERE id = NEW.topic;
            END IF;
        END IF;
        RETURN NEW;
    END IF;

    -- Para DELETE: solo si la pregunta estaba publicada
    IF TG_OP = 'DELETE' THEN
        IF OLD.published = true THEN
            UPDATE topic SET total_questions = total_questions - 1 WHERE id = OLD.topic;
        END IF;
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_topic_question_count_optimized"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_topic_questions_count"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    is_psycho_with_config boolean;
BEGIN
  -- Para INSERT: actualizar el topic de la nueva pregunta
  IF TG_OP = 'INSERT' THEN
    -- Verificar si es un topic psicotécnico con convocatoria
    SELECT ("isPsychoTechnical" = true AND mark_collection_config IS NOT NULL)
    INTO is_psycho_with_config
    FROM topics
    WHERE id = NEW.topic;

    -- Solo actualizar si NO es psicotécnico con convocatoria
    IF NOT COALESCE(is_psycho_with_config, false) THEN
      UPDATE topics
      SET questions = (
        SELECT COUNT(*)
        FROM questions
        WHERE topic = NEW.topic
      )
      WHERE id = NEW.topic;
    END IF;

    RETURN NEW;
  END IF;

  -- Para DELETE: actualizar el topic de la pregunta eliminada
  IF TG_OP = 'DELETE' THEN
    -- Verificar si es un topic psicotécnico con convocatoria
    SELECT ("isPsychoTechnical" = true AND mark_collection_config IS NOT NULL)
    INTO is_psycho_with_config
    FROM topics
    WHERE id = OLD.topic;

    -- Solo actualizar si NO es psicotécnico con convocatoria
    IF NOT COALESCE(is_psycho_with_config, false) THEN
      UPDATE topics
      SET questions = (
        SELECT COUNT(*)
        FROM questions
        WHERE topic = OLD.topic
      )
      WHERE id = OLD.topic;
    END IF;

    RETURN OLD;
  END IF;

  -- Para UPDATE: actualizar ambos topics si el topic cambió
  IF TG_OP = 'UPDATE' THEN
    -- Si cambió el topic, actualizar el anterior
    IF OLD.topic != NEW.topic THEN
      -- Verificar el topic antiguo
      SELECT ("isPsychoTechnical" = true AND mark_collection_config IS NOT NULL)
      INTO is_psycho_with_config
      FROM topics
      WHERE id = OLD.topic;

      IF NOT COALESCE(is_psycho_with_config, false) THEN
        UPDATE topics
        SET questions = (
          SELECT COUNT(*)
          FROM questions
          WHERE topic = OLD.topic
        )
        WHERE id = OLD.topic;
      END IF;
    END IF;

    -- Verificar el topic nuevo
    SELECT ("isPsychoTechnical" = true AND mark_collection_config IS NOT NULL)
    INTO is_psycho_with_config
    FROM topics
    WHERE id = NEW.topic;

    -- Solo actualizar si NO es psicotécnico con convocatoria
    IF NOT COALESCE(is_psycho_with_config, false) THEN
      UPDATE topics
      SET questions = (
        SELECT COUNT(*)
        FROM questions
        WHERE topic = NEW.topic
      )
      WHERE id = NEW.topic;
    END IF;

    RETURN NEW;
  END IF;

  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_topic_questions_count"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_topic_questions_count"() IS 'Actualiza automáticamente topics.questions cuando se insertan/eliminan/modifican preguntas.
EXCEPCIÓN: NO actualiza topics psicotécnicos con convocatoria (mark_collection_config),
para respetar ajustes manuales del número de preguntas a evaluar.';



CREATE OR REPLACE FUNCTION "public"."update_topic_stats_from_user_tests"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    topic_to_update bigint;
BEGIN
    -- Determinar qué topic(s) actualizar según la operación
    IF TG_OP = 'INSERT' THEN
        topic_to_update := NEW.special_topic;
    ELSIF TG_OP = 'UPDATE' THEN
        -- Si cambió el special_topic, actualizar ambos
        IF OLD.special_topic IS DISTINCT FROM NEW.special_topic THEN
            -- Actualizar el topic anterior si existía
            IF OLD.special_topic IS NOT NULL THEN
                PERFORM update_single_topic_stats(OLD.special_topic);
            END IF;
            topic_to_update := NEW.special_topic;
        ELSE
            topic_to_update := NEW.special_topic;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        topic_to_update := OLD.special_topic;
    END IF;

    -- Actualizar el topic si es necesario
    IF topic_to_update IS NOT NULL THEN
        PERFORM update_single_topic_stats(topic_to_update);
    END IF;

    -- Retornar el registro apropiado
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;


ALTER FUNCTION "public"."update_topic_stats_from_user_tests"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_user_memberships_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_user_memberships_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_user_test_stats"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    test_id bigint;
    stats_record RECORD;
    penalty_value numeric;
    score_value numeric;
    is_flashcard BOOLEAN;
BEGIN
    -- Determinar qué user_test actualizar
    IF TG_OP = 'DELETE' THEN
        test_id := OLD.user_test_id;
    ELSE
        test_id := NEW.user_test_id;
    END IF;

    -- Verificar si es modo flashcard
    SELECT is_flashcard_mode INTO is_flashcard
    FROM user_tests
    WHERE id = test_id;

    -- SI ES FLASHCARD: NO calcular right/wrong, solo count
    IF is_flashcard THEN
        SELECT COUNT(*) as total_answered_count
        INTO stats_record
        FROM user_test_answers
        WHERE user_test_id = test_id;

        -- Actualizar solo total_answered (no hay right/wrong en flashcards)
        UPDATE user_tests
        SET
            total_answered = stats_record.total_answered_count,
            updated_at = now()
        WHERE id = test_id;

        IF TG_OP = 'DELETE' THEN
            RETURN OLD;
        ELSE
            RETURN NEW;
        END IF;
    END IF;

    -- LÓGICA ORIGINAL PARA TESTS NORMALES (NO FLASHCARDS)

    -- Calcular estadísticas de las respuestas
    SELECT
        COUNT(*) as total_answered_count,
        COUNT(*) FILTER (WHERE correct = true) as right_count,
        COUNT(*) FILTER (WHERE correct = false) as wrong_count,
        COUNT(*) FILTER (WHERE correct IS NULL) as unanswered_count
    INTO stats_record
    FROM user_test_answers
    WHERE user_test_id = test_id;

    -- Obtener la penalización del topic_type
    SELECT COALESCE(tt.penalty, 0)
    INTO penalty_value
    FROM user_tests ut
    JOIN topic t ON (ut.special_topic = t.id OR t.id = ANY(ut.topic_ids))
    JOIN topic_type tt ON t.topic_type_id = tt.id
    WHERE ut.id = test_id
    LIMIT 1;

    penalty_value := COALESCE(penalty_value, 0);

    -- Calcular puntuación con penalización
    IF stats_record.total_answered_count > 0 THEN
        score_value := ROUND(
            ((stats_record.right_count - (stats_record.wrong_count * penalty_value))::numeric
             / stats_record.total_answered_count::numeric) * 10,
            2
        );
        score_value := GREATEST(score_value, 0);
    ELSE
        score_value := 0;
    END IF;

    -- Actualizar user_tests con las estadísticas calculadas
    UPDATE user_tests
    SET
        total_answered = stats_record.total_answered_count,
        right_questions = stats_record.right_count,
        wrong_questions = stats_record.wrong_count,
        score = score_value,
        updated_at = now()
    WHERE id = test_id;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;


ALTER FUNCTION "public"."update_user_test_stats"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_user_test_stats"() IS 'Actualiza estadísticas de user_tests. Para flashcards solo cuenta total_answered, para tests normales calcula right/wrong/score';



CREATE OR REPLACE FUNCTION "public"."update_user_tests_question_count"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    is_psycho_with_config boolean;
BEGIN
  -- Solo si cambia el número de preguntas
  IF (OLD.questions IS DISTINCT FROM NEW.questions) THEN

    -- Verificar si es un topic psicotécnico con convocatoria
    is_psycho_with_config := (NEW."isPsychoTechnical" = true AND NEW.mark_collection_config IS NOT NULL);

    -- Solo actualizar si NO es psicotécnico con convocatoria
    -- Los psicotécnicos con convocatoria usan adjust_psycho_question_count_and_recalculate()
    -- que calcula question_count correctamente descontando preguntas anuladas
    IF NOT COALESCE(is_psycho_with_config, false) THEN
      UPDATE user_tests
      SET question_count = NEW.questions
      WHERE "specialTopic" = NEW.id;
    END IF;

  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_user_tests_question_count"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_user_tests_question_count"() IS 'Actualiza user_tests.question_count cuando topics.questions cambia.
EXCEPCIÓN: NO actualiza topics psicotécnicos con convocatoria (mark_collection_config),
ya que estos usan adjust_psycho_question_count_and_recalculate() que calcula
question_count correctamente descontando preguntas impugnadas.';



CREATE OR REPLACE FUNCTION "public"."update_user_total_stats_optimized"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    user_to_update bigint;
    old_questions integer := 0;
    old_right integer := 0;
    old_wrong integer := 0;
    new_questions integer := 0;
    new_right integer := 0;
    new_wrong integer := 0;
BEGIN
    -- Ignorar tests de special_topic
    IF TG_OP = 'INSERT' AND NEW.special_topic IS NOT NULL THEN
        RETURN NEW;
    END IF;

    IF TG_OP = 'UPDATE' AND (OLD.special_topic IS NOT NULL AND NEW.special_topic IS NOT NULL) THEN
        RETURN NEW;
    END IF;

    IF TG_OP = 'DELETE' AND OLD.special_topic IS NOT NULL THEN
        RETURN OLD;
    END IF;

    -- Para INSERT: incrementar estadísticas del usuario
    IF TG_OP = 'INSERT' THEN
        IF NEW.finalized = true THEN
            UPDATE users
            SET
                "totalQuestions" = "totalQuestions" + COALESCE(NEW.question_count, 0),
                "rightQuestions" = "rightQuestions" + COALESCE(NEW.right_questions, 0),
                "wrongQuestions" = "wrongQuestions" + COALESCE(NEW.wrong_questions, 0),
                "updatedAt" = now()
            WHERE id = NEW.user_id;
        END IF;
        RETURN NEW;
    END IF;

    -- Para UPDATE: ajustar diferencias
    IF TG_OP = 'UPDATE' THEN
        user_to_update := NEW.user_id;

        IF OLD.finalized = true THEN
            old_questions := COALESCE(OLD.question_count, 0);
            old_right := COALESCE(OLD.right_questions, 0);
            old_wrong := COALESCE(OLD.wrong_questions, 0);
        END IF;

        IF NEW.finalized = true THEN
            new_questions := COALESCE(NEW.question_count, 0);
            new_right := COALESCE(NEW.right_questions, 0);
            new_wrong := COALESCE(NEW.wrong_questions, 0);
        END IF;

        -- Si cambió el user_id, actualizar ambos usuarios
        IF OLD.user_id != NEW.user_id THEN
            UPDATE users
            SET
                "totalQuestions" = "totalQuestions" - old_questions,
                "rightQuestions" = "rightQuestions" - old_right,
                "wrongQuestions" = "wrongQuestions" - old_wrong,
                "updatedAt" = now()
            WHERE id = OLD.user_id;

            UPDATE users
            SET
                "totalQuestions" = "totalQuestions" + new_questions,
                "rightQuestions" = "rightQuestions" + new_right,
                "wrongQuestions" = "wrongQuestions" + new_wrong,
                "updatedAt" = now()
            WHERE id = NEW.user_id;
        ELSE
            UPDATE users
            SET
                "totalQuestions" = "totalQuestions" + (new_questions - old_questions),
                "rightQuestions" = "rightQuestions" + (new_right - old_right),
                "wrongQuestions" = "wrongQuestions" + (new_wrong - old_wrong),
                "updatedAt" = now()
            WHERE id = user_to_update;
        END IF;
        RETURN NEW;
    END IF;

    -- Para DELETE: decrementar estadísticas del usuario
    IF TG_OP = 'DELETE' THEN
        IF OLD.finalized = true THEN
            UPDATE users
            SET
                "totalQuestions" = "totalQuestions" - COALESCE(OLD.question_count, 0),
                "rightQuestions" = "rightQuestions" - COALESCE(OLD.right_questions, 0),
                "wrongQuestions" = "wrongQuestions" - COALESCE(OLD.wrong_questions, 0),
                "updatedAt" = now()
            WHERE id = OLD.user_id;
        END IF;
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_user_total_stats_optimized"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."validate_flashcard_options"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    option_count INTEGER;
    topic_level_value public.topic_level;
BEGIN
    -- Obtener el level del topic asociado a la pregunta
    SELECT tt.level INTO topic_level_value
    FROM questions q
    JOIN topic t ON q.topic = t.id
    JOIN topic_type tt ON t.topic_type_id = tt.id
    WHERE q.id = NEW.question_id;

    -- Si es Flashcard, validar que solo tenga 2 opciones
    IF topic_level_value = 'Flashcard' THEN
        SELECT COUNT(*) INTO option_count
        FROM question_options
        WHERE question_id = NEW.question_id;

        -- Si ya tiene 2 opciones y se intenta agregar otra, rechazar
        IF option_count >= 2 AND TG_OP = 'INSERT' THEN
            RAISE EXCEPTION 'Las flashcards solo pueden tener exactamente 2 opciones (pregunta y respuesta)';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."validate_flashcard_options"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."validate_flashcard_options"() IS 'Valida que las preguntas tipo Flashcard tengan exactamente 2 opciones';



CREATE OR REPLACE FUNCTION "public"."validate_flashcard_topic_type"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Si level = 'Flashcard', default_number_options debe ser 2
    IF NEW.level = 'Flashcard' AND NEW.default_number_options != 2 THEN
        NEW.default_number_options := 2;
        RAISE NOTICE 'topic_type con level=Flashcard debe tener default_number_options=2. Valor ajustado automáticamente.';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."validate_flashcard_topic_type"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."validate_flashcard_topic_type"() IS 'Asegura que topic_type con level=Flashcard tenga default_number_options=2';


SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."academies" (
    "id" bigint NOT NULL,
    "name" character varying(255) NOT NULL,
    "slug" character varying(100) NOT NULL,
    "description" "text",
    "logo_url" "text",
    "website" "text",
    "contact_email" character varying(255),
    "contact_phone" character varying(50),
    "address" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "academies_email_check" CHECK ((("contact_email" IS NULL) OR (("contact_email")::"text" ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::"text"))),
    CONSTRAINT "academies_name_check" CHECK (("length"(TRIM(BOTH FROM "name")) > 0)),
    CONSTRAINT "academies_slug_check" CHECK ((("slug")::"text" ~ '^[a-z0-9_-]+$'::"text"))
);


ALTER TABLE "public"."academies" OWNER TO "postgres";


COMMENT ON TABLE "public"."academies" IS 'Academias o centros de formación. Cada academia tiene sus propios usuarios, topics y preguntas.';



COMMENT ON COLUMN "public"."academies"."slug" IS 'Identificador único en formato URL-friendly para la academia';



COMMENT ON COLUMN "public"."academies"."is_active" IS 'Indica si la academia está activa y puede operar';



ALTER TABLE "public"."academies" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."academies_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."academy_kpis" (
    "id" bigint NOT NULL,
    "academy_id" bigint NOT NULL,
    "total_users" bigint DEFAULT 0 NOT NULL,
    "total_premium_users" bigint DEFAULT 0 NOT NULL,
    "premium_plus_users" bigint DEFAULT 0 NOT NULL,
    "total_questions" bigint DEFAULT 0 NOT NULL,
    "total_tests" bigint DEFAULT 0 NOT NULL,
    "total_users_today" bigint DEFAULT 0 NOT NULL,
    "new_users_today" bigint DEFAULT 0 NOT NULL,
    "total_answers_today" bigint DEFAULT 0 NOT NULL,
    "total_flashcard_answers_today" bigint DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."academy_kpis" OWNER TO "postgres";


ALTER TABLE "public"."academy_kpis" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."academy_kpis_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."challenge" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" bigint,
    "question_id" bigint,
    "topic_id" bigint,
    "reason" "text",
    "state" "public"."challenge_state" DEFAULT 'pendiente'::"public"."challenge_state" NOT NULL,
    "reply" "text" DEFAULT ''::"text" NOT NULL,
    "editor_id" bigint,
    "open" boolean DEFAULT true NOT NULL,
    "tutor_uuid" "uuid",
    "academy_id" bigint DEFAULT 1 NOT NULL
);


ALTER TABLE "public"."challenge" OWNER TO "postgres";


COMMENT ON COLUMN "public"."challenge"."academy_id" IS 'Academia en la que se genera el challenge';



ALTER TABLE "public"."challenge" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."challenge_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."cms_users" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_uuid" "uuid" DEFAULT "gen_random_uuid"(),
    "academy_id" bigint DEFAULT 1 NOT NULL,
    "username" "text" DEFAULT 'sin usuario'::"text",
    "nombre" "text" DEFAULT 'sin nombre'::"text",
    "apellido" "text" DEFAULT 'sin apellido'::"text",
    "avatar_url" "text",
    "email" "text",
    "phone" "text",
    "address" "text",
    "role_id" bigint DEFAULT 4 NOT NULL,
    CONSTRAINT "cms_users_email_check" CHECK ((("email" IS NULL) OR ("email" ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::"text"))),
    CONSTRAINT "cms_users_username_check" CHECK (("length"(TRIM(BOTH FROM "username")) > 0))
);


ALTER TABLE "public"."cms_users" OWNER TO "postgres";


COMMENT ON COLUMN "public"."cms_users"."academy_id" IS 'Academia a la que pertenece el usuario editor/tutor';



ALTER TABLE "public"."cms_users" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."cms_users_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."membership_levels" (
    "id" bigint NOT NULL,
    "name" character varying(100) NOT NULL,
    "description" "text",
    "wordpress_rcp_id" integer,
    "wordpress_level_name" character varying(100),
    "revenuecat_product_ids" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "revenuecat_entitlement_id" character varying(100),
    "duration_days" integer,
    "is_recurring" boolean DEFAULT false,
    "trial_days" integer DEFAULT 0,
    "max_content_access" integer,
    "features" "jsonb",
    "price_usd" numeric(10,2),
    "price_eur" numeric(10,2),
    "currency_code" character varying(3) DEFAULT 'EUR'::character varying,
    "is_active" boolean DEFAULT true,
    "display_order" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "access_level" integer DEFAULT 1 NOT NULL,
    CONSTRAINT "membership_levels_access_level_check" CHECK ((("access_level" >= 1) AND ("access_level" <= 3))),
    CONSTRAINT "membership_levels_name_check" CHECK (("length"(TRIM(BOTH FROM "name")) > 0))
);


ALTER TABLE "public"."membership_levels" OWNER TO "postgres";


COMMENT ON TABLE "public"."membership_levels" IS 'Niveles de desbloqueo de la app. Las membresías de RCP (ofertas, descuentos) se mapean a estos 3 niveles según su wordpress_rcp_id';



COMMENT ON COLUMN "public"."membership_levels"."wordpress_rcp_id" IS 'ID del nivel de membresía en WordPress RCP - representa el NIVEL de desbloqueo (1=Freemium, 2=Premium, 3=Premium+)';



COMMENT ON COLUMN "public"."membership_levels"."revenuecat_product_ids" IS 'Array de IDs de productos en RevenueCat que desbloquean este nivel';



COMMENT ON COLUMN "public"."membership_levels"."access_level" IS 'Nivel de desbloqueo de contenido: 1=Freemium, 2=Premium, 3=Premium+';



ALTER TABLE "public"."membership_levels" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."membership_levels_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."question_options" (
    "id" bigint NOT NULL,
    "question_id" bigint NOT NULL,
    "answer" "text" NOT NULL,
    "is_correct" boolean DEFAULT false NOT NULL,
    "option_order" integer DEFAULT 1 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."question_options" OWNER TO "postgres";


COMMENT ON TABLE "public"."question_options" IS 'Opciones de respuesta para preguntas. El campo answer puede estar vacío temporalmente durante la creación.';



ALTER TABLE "public"."question_options" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."question_options_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."questions" (
    "id" bigint NOT NULL,
    "question" "text" NOT NULL,
    "tip" "text",
    "topic" bigint NOT NULL,
    "article" "text",
    "question_image_url" "text" DEFAULT ''::"text" NOT NULL,
    "retro_image_url" "text" DEFAULT ''::"text" NOT NULL,
    "retro_audio_enable" boolean DEFAULT false NOT NULL,
    "retro_audio_text" "text" DEFAULT ''::"text" NOT NULL,
    "question_order" integer,
    "published" boolean DEFAULT true NOT NULL,
    "shuffled" boolean,
    "num_answered" integer DEFAULT 0 NOT NULL,
    "num_fails" integer DEFAULT 0 NOT NULL,
    "num_empty" integer DEFAULT 0 NOT NULL,
    "difficult_rate" double precision,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "challenge_by_tutor" boolean DEFAULT false NOT NULL,
    "challenge_reason" "text",
    "academy_id" bigint DEFAULT 1 NOT NULL,
    "order" bigint DEFAULT '0'::bigint
);


ALTER TABLE "public"."questions" OWNER TO "postgres";


COMMENT ON COLUMN "public"."questions"."academy_id" IS 'Academia propietaria de la pregunta';



ALTER TABLE "public"."questions" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."questions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."removed_questions_history" (
    "user_test_id" bigint,
    "question_id" bigint,
    "was_correct" boolean,
    "was_wrong" boolean,
    "removed_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."removed_questions_history" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."role" (
    "id" bigint NOT NULL,
    "role_name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "role_name_check" CHECK (("length"(TRIM(BOTH FROM "role_name")) > 0))
);


ALTER TABLE "public"."role" OWNER TO "postgres";


ALTER TABLE "public"."role" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."role_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."topic" (
    "id" bigint NOT NULL,
    "topic_type_id" bigint NOT NULL,
    "topic_name" "text" NOT NULL,
    "description" "text",
    "enabled" boolean DEFAULT true NOT NULL,
    "is_premium" boolean DEFAULT false NOT NULL,
    "is_hidden_but_premium" boolean DEFAULT false NOT NULL,
    "published_at" timestamp with time zone,
    "total_participants" bigint DEFAULT 0 NOT NULL,
    "total_questions" bigint DEFAULT 0 NOT NULL,
    "total_score" bigint DEFAULT 0 NOT NULL,
    "average_score" numeric(5,2) GENERATED ALWAYS AS (
CASE
    WHEN ("total_participants" > 0) THEN "round"((("total_score")::numeric / ("total_participants")::numeric), 2)
    ELSE NULL::numeric
END) STORED,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "options" integer DEFAULT 3 NOT NULL,
    "max_score" integer DEFAULT 0,
    "min_score" integer DEFAULT 0,
    "academy_id" bigint DEFAULT 1 NOT NULL,
    "duration_seconds" bigint DEFAULT '0'::bigint,
    "manual_duration_seconds" bigint,
    "image_url" "text",
    CONSTRAINT "topic_name_check" CHECK (("length"("topic_name") > 0))
);


ALTER TABLE "public"."topic" OWNER TO "postgres";


COMMENT ON COLUMN "public"."topic"."options" IS 'Number of options by default in questions';



COMMENT ON COLUMN "public"."topic"."max_score" IS 'max_score';



COMMENT ON COLUMN "public"."topic"."academy_id" IS 'Academia propietaria del topic';



ALTER TABLE "public"."topic" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."topic_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."topic_type" (
    "id" bigint NOT NULL,
    "topic_type_name" "text" NOT NULL,
    "default_number_options" integer DEFAULT 4 NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "penalty" numeric DEFAULT 0.5,
    "level" "public"."topic_level" DEFAULT 'Study'::"public"."topic_level",
    "order_of_appearance" integer DEFAULT 0,
    "time_by_question" double precision DEFAULT '0.5'::double precision,
    CONSTRAINT "topic_type_name_check" CHECK (("length"("topic_type_name") > 0))
);


ALTER TABLE "public"."topic_type" OWNER TO "postgres";


COMMENT ON COLUMN "public"."topic_type"."penalty" IS 'Penalización por cada mala';



ALTER TABLE "public"."topic_type" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."topic_type_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."user_memberships" (
    "id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "membership_level_id" bigint NOT NULL,
    "status" character varying(50) DEFAULT 'active'::character varying,
    "started_at" timestamp with time zone DEFAULT "now"(),
    "expires_at" timestamp with time zone,
    "cancelled_at" timestamp with time zone,
    "auto_renews" boolean DEFAULT false,
    "renewal_grace_period_days" integer DEFAULT 3,
    "last_synced_at" timestamp with time zone DEFAULT "now"(),
    "sync_source" character varying(50),
    "sync_status" character varying(50) DEFAULT 'synced'::character varying,
    "sync_error" "text",
    "metadata" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "user_memberships_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['active'::character varying, 'inactive'::character varying, 'cancelled'::character varying, 'expired'::character varying, 'pending'::character varying])::"text"[]))),
    CONSTRAINT "user_memberships_sync_source_check" CHECK ((("sync_source")::"text" = ANY ((ARRAY['revenuecat'::character varying, 'wordpress'::character varying, 'manual'::character varying])::"text"[]))),
    CONSTRAINT "user_memberships_sync_status_check" CHECK ((("sync_status")::"text" = ANY ((ARRAY['synced'::character varying, 'pending'::character varying, 'error'::character varying])::"text"[])))
);


ALTER TABLE "public"."user_memberships" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_memberships" IS 'Membresías activas de usuarios sincronizadas con RevenueCat y WordPress. user_id es el mismo en Supabase, WordPress y RevenueCat';



COMMENT ON COLUMN "public"."user_memberships"."user_id" IS 'ID del usuario (mismo en users.id, WordPress user_id y RevenueCat app_user_id)';



COMMENT ON COLUMN "public"."user_memberships"."sync_source" IS 'Origen de la sincronización: revenuecat (webhook), wordpress (API), manual';



COMMENT ON COLUMN "public"."user_memberships"."sync_status" IS 'Estado de sincronización: synced, pending, error';



ALTER TABLE "public"."user_memberships" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."user_memberships_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."user_test_answers" (
    "id" bigint NOT NULL,
    "user_test_id" bigint NOT NULL,
    "question_id" bigint NOT NULL,
    "selected_option_id" bigint,
    "correct" boolean,
    "time_taken_seconds" integer,
    "question_order" integer NOT NULL,
    "challenge_by_tutor" boolean DEFAULT false NOT NULL,
    "answered_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "difficulty_rating" character varying(10),
    "next_review_date" timestamp with time zone,
    "review_interval_days" integer DEFAULT 1,
    "ease_factor" numeric(4,2) DEFAULT 2.50,
    "repetitions" integer DEFAULT 0,
    "time" bigint,
    CONSTRAINT "user_test_answers_difficulty_rating_check" CHECK ((("difficulty_rating" IS NULL) OR (("difficulty_rating")::"text" = ANY ((ARRAY['again'::character varying, 'hard'::character varying, 'medium'::character varying, 'easy'::character varying])::"text"[]))))
);


ALTER TABLE "public"."user_test_answers" OWNER TO "postgres";


COMMENT ON COLUMN "public"."user_test_answers"."difficulty_rating" IS 'Rating de dificultad para flashcards: again (no la sabía), hard (difícil), medium (media), easy (fácil)';



COMMENT ON COLUMN "public"."user_test_answers"."next_review_date" IS 'Fecha en que la flashcard debe ser revisada nuevamente (spaced repetition)';



COMMENT ON COLUMN "public"."user_test_answers"."review_interval_days" IS 'Intervalo en días hasta la próxima revisión';



COMMENT ON COLUMN "public"."user_test_answers"."ease_factor" IS 'Factor de facilidad (SM-2 algorithm), mayor = intervalo crece más rápido. Rango típico: 1.3-2.5';



COMMENT ON COLUMN "public"."user_test_answers"."repetitions" IS 'Número de veces que se ha revisado correctamente de forma consecutiva';



ALTER TABLE "public"."user_test_answers" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."user_test_answers_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."user_tests" (
    "id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "topic_ids" bigint[] NOT NULL,
    "options" smallint DEFAULT 4 NOT NULL,
    "right_questions" integer DEFAULT 0 NOT NULL,
    "wrong_questions" integer DEFAULT 0 NOT NULL,
    "question_count" integer DEFAULT 0 NOT NULL,
    "total_answered" integer DEFAULT 0 NOT NULL,
    "score" real,
    "finalized" boolean DEFAULT false NOT NULL,
    "visible" boolean DEFAULT true NOT NULL,
    "study_mode" boolean DEFAULT false NOT NULL,
    "study_failed" boolean DEFAULT false NOT NULL,
    "study_white" boolean DEFAULT false NOT NULL,
    "mock" boolean,
    "survival" boolean DEFAULT false,
    "mark_collection" boolean,
    "minutes" integer NOT NULL,
    "time_spent_millis" integer,
    "special_topic" bigint,
    "special_topic_title" "text",
    "difficulty_end" real,
    "number_of_lives" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_flashcard_mode" boolean DEFAULT false
);


ALTER TABLE "public"."user_tests" OWNER TO "postgres";


COMMENT ON COLUMN "public"."user_tests"."is_flashcard_mode" IS 'Indica si el test es una sesión de estudio con flashcards (no se cuentan right/wrong questions)';



ALTER TABLE "public"."user_tests" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."user_tests_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" bigint NOT NULL,
    "username" character varying NOT NULL,
    "email" "text",
    "first_name" "text",
    "last_name" "text",
    "phone" "text",
    "totalQuestions" bigint DEFAULT 0 NOT NULL,
    "rightQuestions" bigint DEFAULT 0 NOT NULL,
    "wrongQuestions" bigint DEFAULT 0 NOT NULL,
    "tester" boolean DEFAULT false,
    "lastUsed" timestamp with time zone,
    "fcm_token" "text",
    "fid_token" "text",
    "profile_image" "text",
    "unlocked_at" timestamp with time zone,
    "unlock_duration_minutes" integer DEFAULT 0,
    "enabled" boolean DEFAULT true,
    "tutorial" boolean DEFAULT false,
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "wordpress_user_id" bigint,
    "display_name" "text",
    "academy_id" bigint DEFAULT 1 NOT NULL
);


ALTER TABLE "public"."users" OWNER TO "postgres";


COMMENT ON COLUMN "public"."users"."wordpress_user_id" IS 'ID del usuario en WordPress. Usado para sincronización con WP.';



COMMENT ON COLUMN "public"."users"."display_name" IS 'Nombre completo para mostrar del usuario (de WordPress).';



COMMENT ON COLUMN "public"."users"."academy_id" IS 'Academia a la que pertenece el usuario final de la app';



ALTER TABLE "public"."users" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."users_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE ONLY "public"."academies"
    ADD CONSTRAINT "academies_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."academies"
    ADD CONSTRAINT "academies_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."academies"
    ADD CONSTRAINT "academies_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "public"."academy_kpis"
    ADD CONSTRAINT "academy_kpis_academy_id_key" UNIQUE ("academy_id");



ALTER TABLE ONLY "public"."academy_kpis"
    ADD CONSTRAINT "academy_kpis_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."challenge"
    ADD CONSTRAINT "challenge_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."cms_users"
    ADD CONSTRAINT "cms_users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."cms_users"
    ADD CONSTRAINT "cms_users_user_uuid_unique" UNIQUE ("user_uuid");



ALTER TABLE ONLY "public"."membership_levels"
    ADD CONSTRAINT "membership_levels_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."membership_levels"
    ADD CONSTRAINT "membership_levels_wordpress_rcp_id_key" UNIQUE ("wordpress_rcp_id");



ALTER TABLE ONLY "public"."question_options"
    ADD CONSTRAINT "question_options_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."questions"
    ADD CONSTRAINT "questions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."role"
    ADD CONSTRAINT "role_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."role"
    ADD CONSTRAINT "role_role_name_key" UNIQUE ("role_name");



ALTER TABLE ONLY "public"."topic"
    ADD CONSTRAINT "topic_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."topic_type"
    ADD CONSTRAINT "topic_type_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."topic_type"
    ADD CONSTRAINT "topic_type_topic_type_name_key" UNIQUE ("topic_type_name");



ALTER TABLE ONLY "public"."question_options"
    ADD CONSTRAINT "unique_question_order" UNIQUE ("question_id", "option_order");



ALTER TABLE ONLY "public"."user_test_answers"
    ADD CONSTRAINT "unique_user_test_question" UNIQUE ("user_test_id", "question_id");



ALTER TABLE ONLY "public"."user_memberships"
    ADD CONSTRAINT "user_memberships_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_test_answers"
    ADD CONSTRAINT "user_test_answers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_tests"
    ADD CONSTRAINT "user_tests_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_academies_is_active" ON "public"."academies" USING "btree" ("is_active") WHERE ("is_active" = true);



CREATE INDEX "idx_academies_name_lower" ON "public"."academies" USING "btree" ("lower"(("name")::"text"));



CREATE INDEX "idx_academies_slug" ON "public"."academies" USING "btree" ("slug");



CREATE INDEX "idx_academy_kpis_academy_id" ON "public"."academy_kpis" USING "btree" ("academy_id");



CREATE INDEX "idx_academy_kpis_updated_at" ON "public"."academy_kpis" USING "btree" ("updated_at" DESC);



CREATE INDEX "idx_challenge_academy_id" ON "public"."challenge" USING "btree" ("academy_id");



CREATE INDEX "idx_challenge_academy_state" ON "public"."challenge" USING "btree" ("academy_id", "state");



CREATE INDEX "idx_challenge_created_at" ON "public"."challenge" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_challenge_editor_id" ON "public"."challenge" USING "btree" ("editor_id") WHERE ("editor_id" IS NOT NULL);



CREATE INDEX "idx_challenge_open" ON "public"."challenge" USING "btree" ("open") WHERE ("open" = true);



CREATE INDEX "idx_challenge_question_id" ON "public"."challenge" USING "btree" ("question_id");



CREATE INDEX "idx_challenge_state" ON "public"."challenge" USING "btree" ("state");



CREATE INDEX "idx_challenge_topic_id" ON "public"."challenge" USING "btree" ("topic_id");



CREATE INDEX "idx_challenge_user_id" ON "public"."challenge" USING "btree" ("user_id");



CREATE INDEX "idx_cms_users_academy_id" ON "public"."cms_users" USING "btree" ("academy_id");



CREATE INDEX "idx_cms_users_email" ON "public"."cms_users" USING "btree" ("email");



CREATE INDEX "idx_cms_users_role_id" ON "public"."cms_users" USING "btree" ("role_id");



CREATE INDEX "idx_cms_users_user_uuid" ON "public"."cms_users" USING "btree" ("user_uuid");



CREATE INDEX "idx_cms_users_username" ON "public"."cms_users" USING "btree" ("username");



CREATE INDEX "idx_cms_users_uuid_academy" ON "public"."cms_users" USING "btree" ("user_uuid", "academy_id");



CREATE INDEX "idx_membership_levels_access_level" ON "public"."membership_levels" USING "btree" ("access_level");



CREATE INDEX "idx_membership_levels_is_active" ON "public"."membership_levels" USING "btree" ("is_active");



CREATE INDEX "idx_membership_levels_wordpress_rcp_id" ON "public"."membership_levels" USING "btree" ("wordpress_rcp_id") WHERE ("wordpress_rcp_id" IS NOT NULL);



CREATE INDEX "idx_question_options_correct" ON "public"."question_options" USING "btree" ("question_id", "is_correct") WHERE ("is_correct" = true);



CREATE INDEX "idx_question_options_order" ON "public"."question_options" USING "btree" ("question_id", "option_order");



CREATE INDEX "idx_question_options_question_id" ON "public"."question_options" USING "btree" ("question_id");



CREATE INDEX "idx_questions_academy_id" ON "public"."questions" USING "btree" ("academy_id");



CREATE INDEX "idx_questions_academy_published" ON "public"."questions" USING "btree" ("academy_id", "published") WHERE ("published" = true);



CREATE INDEX "idx_questions_academy_topic" ON "public"."questions" USING "btree" ("academy_id", "topic");



CREATE INDEX "idx_questions_challenge_by_tutor" ON "public"."questions" USING "btree" ("challenge_by_tutor") WHERE ("challenge_by_tutor" = true);



CREATE INDEX "idx_questions_created_by" ON "public"."questions" USING "btree" ("created_at") WHERE ("created_by" IS NOT NULL);



CREATE INDEX "idx_questions_flashcard_topic" ON "public"."questions" USING "btree" ("topic", "published") WHERE ("published" = true);



CREATE INDEX "idx_questions_topic" ON "public"."questions" USING "btree" ("topic");



CREATE INDEX "idx_questions_topic_difficulty" ON "public"."questions" USING "btree" ("topic", "difficult_rate") WHERE ("published" = true);



CREATE INDEX "idx_questions_topic_order" ON "public"."questions" USING "btree" ("topic", "question_order") WHERE ("published" = true);



CREATE INDEX "idx_questions_topic_published" ON "public"."questions" USING "btree" ("topic", "published");



CREATE INDEX "idx_role_name_lower" ON "public"."role" USING "btree" ("lower"("role_name"));



CREATE INDEX "idx_topic_academy_enabled" ON "public"."topic" USING "btree" ("academy_id", "enabled") WHERE ("enabled" = true);



CREATE INDEX "idx_topic_academy_id" ON "public"."topic" USING "btree" ("academy_id");



CREATE INDEX "idx_topic_academy_type" ON "public"."topic" USING "btree" ("academy_id", "topic_type_id");



CREATE INDEX "idx_topic_enabled_type" ON "public"."topic" USING "btree" ("enabled", "topic_type_id") WHERE ("enabled" = true);



CREATE INDEX "idx_topic_name_lower" ON "public"."topic" USING "btree" ("lower"("topic_name"));



CREATE INDEX "idx_topic_premium_published" ON "public"."topic" USING "btree" ("is_premium", "published_at") WHERE (("enabled" = true) AND ("published_at" IS NOT NULL));



CREATE INDEX "idx_topic_published_at" ON "public"."topic" USING "btree" ("published_at" DESC) WHERE (("enabled" = true) AND ("published_at" IS NOT NULL));



CREATE INDEX "idx_topic_stats_participants" ON "public"."topic" USING "btree" ("total_participants" DESC) WHERE ("enabled" = true);



CREATE INDEX "idx_topic_type_id" ON "public"."topic" USING "btree" ("topic_type_id");



CREATE INDEX "idx_topic_type_name_lower" ON "public"."topic_type" USING "btree" ("lower"("topic_type_name"));



CREATE INDEX "idx_user_memberships_active" ON "public"."user_memberships" USING "btree" ("user_id", "status") WHERE (("status")::"text" = 'active'::"text");



CREATE INDEX "idx_user_memberships_expires_at" ON "public"."user_memberships" USING "btree" ("expires_at");



CREATE INDEX "idx_user_memberships_membership_level_id" ON "public"."user_memberships" USING "btree" ("membership_level_id");



CREATE INDEX "idx_user_memberships_status" ON "public"."user_memberships" USING "btree" ("status");



CREATE INDEX "idx_user_memberships_sync_source" ON "public"."user_memberships" USING "btree" ("sync_source");



CREATE INDEX "idx_user_memberships_user_id" ON "public"."user_memberships" USING "btree" ("user_id");



CREATE INDEX "idx_user_test_answers_correct" ON "public"."user_test_answers" USING "btree" ("correct") WHERE ("correct" IS NOT NULL);



CREATE INDEX "idx_user_test_answers_difficulty" ON "public"."user_test_answers" USING "btree" ("difficulty_rating") WHERE ("difficulty_rating" IS NOT NULL);



CREATE INDEX "idx_user_test_answers_flashcard_review" ON "public"."user_test_answers" USING "btree" ("next_review_date", "question_id") WHERE ("next_review_date" IS NOT NULL);



CREATE INDEX "idx_user_test_answers_next_review" ON "public"."user_test_answers" USING "btree" ("user_test_id", "next_review_date") WHERE ("next_review_date" IS NOT NULL);



CREATE INDEX "idx_user_test_answers_order" ON "public"."user_test_answers" USING "btree" ("user_test_id", "question_order");



CREATE INDEX "idx_user_test_answers_question_id" ON "public"."user_test_answers" USING "btree" ("question_id");



CREATE INDEX "idx_user_test_answers_user_test_id" ON "public"."user_test_answers" USING "btree" ("user_test_id");



CREATE INDEX "idx_user_tests_finalized" ON "public"."user_tests" USING "btree" ("finalized");



CREATE INDEX "idx_user_tests_flashcard_mode" ON "public"."user_tests" USING "btree" ("is_flashcard_mode", "user_id") WHERE ("is_flashcard_mode" = true);



CREATE INDEX "idx_user_tests_survival" ON "public"."user_tests" USING "btree" ("survival") WHERE ("survival" = true);



CREATE INDEX "idx_user_tests_topic_ids_gin" ON "public"."user_tests" USING "gin" ("topic_ids");



CREATE INDEX "idx_user_tests_updated_at" ON "public"."user_tests" USING "btree" ("updated_at" DESC);



CREATE INDEX "idx_user_tests_user_finalized_visible" ON "public"."user_tests" USING "btree" ("user_id", "finalized", "visible") WHERE (("finalized" = true) AND ("visible" = true));



CREATE INDEX "idx_user_tests_user_id" ON "public"."user_tests" USING "btree" ("user_id");



CREATE INDEX "idx_user_tests_visible" ON "public"."user_tests" USING "btree" ("visible");



CREATE INDEX "idx_users_academy_email" ON "public"."users" USING "btree" ("academy_id", "email");



CREATE INDEX "idx_users_academy_id" ON "public"."users" USING "btree" ("academy_id");



CREATE INDEX "idx_users_email" ON "public"."users" USING "btree" ("email");



CREATE INDEX "idx_users_email_lower" ON "public"."users" USING "btree" ("lower"("email"));



CREATE INDEX "idx_users_enabled" ON "public"."users" USING "btree" ("enabled") WHERE ("enabled" = true);



CREATE INDEX "idx_users_unlocked_at" ON "public"."users" USING "btree" ("unlocked_at") WHERE ("unlocked_at" IS NOT NULL);



CREATE INDEX "idx_users_username" ON "public"."users" USING "btree" ("username");



CREATE UNIQUE INDEX "idx_users_wordpress_user_id" ON "public"."users" USING "btree" ("wordpress_user_id") WHERE ("wordpress_user_id" IS NOT NULL);



CREATE OR REPLACE TRIGGER "trg_calculate_answer_correctness" BEFORE INSERT OR UPDATE ON "public"."user_test_answers" FOR EACH ROW EXECUTE FUNCTION "public"."calculate_answer_correctness"();



CREATE OR REPLACE TRIGGER "trg_challenge_by_tutor_update" AFTER UPDATE OF "challenge_by_tutor" ON "public"."questions" FOR EACH ROW EXECUTE FUNCTION "public"."fn_challenge_by_tutor_update"();



CREATE OR REPLACE TRIGGER "trg_create_blank_options" AFTER INSERT ON "public"."questions" FOR EACH ROW EXECUTE FUNCTION "public"."create_blank_question_options"();



COMMENT ON TRIGGER "trg_create_blank_options" ON "public"."questions" IS 'Trigger que ejecuta create_blank_question_options() después de insertar una nueva pregunta.';



CREATE OR REPLACE TRIGGER "trg_set_topic_options" BEFORE INSERT ON "public"."topic" FOR EACH ROW EXECUTE FUNCTION "public"."set_topic_options_from_type"();



CREATE OR REPLACE TRIGGER "trg_set_user_test_defaults" BEFORE INSERT ON "public"."user_tests" FOR EACH ROW EXECUTE FUNCTION "public"."set_user_test_defaults_from_topic"();



CREATE OR REPLACE TRIGGER "trg_update_academy_daily_answers" AFTER INSERT ON "public"."user_test_answers" FOR EACH ROW EXECUTE FUNCTION "public"."update_academy_daily_answers"();



CREATE OR REPLACE TRIGGER "trg_update_academy_daily_kpis_users" AFTER INSERT ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."update_academy_daily_kpis_users"();



CREATE OR REPLACE TRIGGER "trg_update_academy_premium_users" AFTER INSERT OR DELETE OR UPDATE OF "membership_level_id", "status" ON "public"."user_memberships" FOR EACH ROW EXECUTE FUNCTION "public"."update_academy_premium_users"();



CREATE OR REPLACE TRIGGER "trg_update_academy_total_questions" AFTER INSERT OR DELETE OR UPDATE OF "academy_id" ON "public"."questions" FOR EACH ROW EXECUTE FUNCTION "public"."update_academy_total_questions"();



CREATE OR REPLACE TRIGGER "trg_update_academy_total_tests" AFTER INSERT OR DELETE OR UPDATE OF "finalized" ON "public"."user_tests" FOR EACH ROW EXECUTE FUNCTION "public"."update_academy_total_tests"();



CREATE OR REPLACE TRIGGER "trg_update_academy_total_users" AFTER INSERT OR DELETE OR UPDATE OF "academy_id" ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."update_academy_total_users"();



CREATE OR REPLACE TRIGGER "trg_update_challenge_timestamp" BEFORE UPDATE ON "public"."challenge" FOR EACH ROW EXECUTE FUNCTION "public"."update_challenge_timestamp"();



CREATE OR REPLACE TRIGGER "trg_update_flashcard_schedule" BEFORE INSERT OR UPDATE ON "public"."user_test_answers" FOR EACH ROW EXECUTE FUNCTION "public"."update_flashcard_review_schedule"();



CREATE OR REPLACE TRIGGER "trg_update_topic_duration_delete" AFTER DELETE ON "public"."questions" FOR EACH ROW EXECUTE FUNCTION "public"."update_topic_duration_from_count"();



CREATE OR REPLACE TRIGGER "trg_update_topic_duration_insert" AFTER INSERT ON "public"."questions" FOR EACH ROW EXECUTE FUNCTION "public"."update_topic_duration_from_count"();



CREATE OR REPLACE TRIGGER "trg_update_topic_duration_update_topic" AFTER UPDATE OF "topic" ON "public"."questions" FOR EACH ROW EXECUTE FUNCTION "public"."update_topic_duration_from_count"();



CREATE OR REPLACE TRIGGER "trg_update_topic_question_count_delete" AFTER DELETE ON "public"."questions" FOR EACH ROW EXECUTE FUNCTION "public"."update_topic_question_count_optimized"();



CREATE OR REPLACE TRIGGER "trg_update_topic_question_count_insert" AFTER INSERT ON "public"."questions" FOR EACH ROW EXECUTE FUNCTION "public"."update_topic_question_count_optimized"();



CREATE OR REPLACE TRIGGER "trg_update_topic_question_count_update" AFTER UPDATE ON "public"."questions" FOR EACH ROW EXECUTE FUNCTION "public"."update_topic_question_count_optimized"();



CREATE OR REPLACE TRIGGER "trg_update_topic_stats_delete" AFTER DELETE ON "public"."user_tests" FOR EACH ROW WHEN ((("old"."special_topic" IS NOT NULL) AND ("old"."finalized" = true))) EXECUTE FUNCTION "public"."update_topic_stats_from_user_tests"();



CREATE OR REPLACE TRIGGER "trg_update_topic_stats_insert" AFTER INSERT ON "public"."user_tests" FOR EACH ROW WHEN ((("new"."special_topic" IS NOT NULL) AND ("new"."finalized" = true))) EXECUTE FUNCTION "public"."update_topic_stats_from_user_tests"();



CREATE OR REPLACE TRIGGER "trg_update_topic_stats_update" AFTER UPDATE ON "public"."user_tests" FOR EACH ROW WHEN (((("new"."special_topic" IS NOT NULL) OR ("old"."special_topic" IS NOT NULL)) AND (("old"."finalized" IS DISTINCT FROM "new"."finalized") OR ("old"."score" IS DISTINCT FROM "new"."score") OR ("old"."special_topic" IS DISTINCT FROM "new"."special_topic")))) EXECUTE FUNCTION "public"."update_topic_stats_from_user_tests"();



CREATE OR REPLACE TRIGGER "trg_update_user_stats_delete" AFTER DELETE ON "public"."user_tests" FOR EACH ROW WHEN (("old"."finalized" = true)) EXECUTE FUNCTION "public"."update_user_total_stats_optimized"();



CREATE OR REPLACE TRIGGER "trg_update_user_stats_insert" AFTER INSERT ON "public"."user_tests" FOR EACH ROW WHEN (("new"."finalized" = true)) EXECUTE FUNCTION "public"."update_user_total_stats_optimized"();



CREATE OR REPLACE TRIGGER "trg_update_user_stats_update" AFTER UPDATE ON "public"."user_tests" FOR EACH ROW WHEN ((("old"."finalized" IS DISTINCT FROM "new"."finalized") OR ("old"."question_count" IS DISTINCT FROM "new"."question_count") OR ("old"."right_questions" IS DISTINCT FROM "new"."right_questions") OR ("old"."wrong_questions" IS DISTINCT FROM "new"."wrong_questions") OR ("old"."user_id" IS DISTINCT FROM "new"."user_id"))) EXECUTE FUNCTION "public"."update_user_total_stats_optimized"();



CREATE OR REPLACE TRIGGER "trg_update_user_test_stats" AFTER INSERT OR DELETE OR UPDATE ON "public"."user_test_answers" FOR EACH ROW EXECUTE FUNCTION "public"."update_user_test_stats"();



CREATE OR REPLACE TRIGGER "trg_validate_flashcard_options" BEFORE INSERT OR UPDATE ON "public"."question_options" FOR EACH ROW EXECUTE FUNCTION "public"."validate_flashcard_options"();



CREATE OR REPLACE TRIGGER "trg_validate_flashcard_topic_type" BEFORE INSERT OR UPDATE ON "public"."topic_type" FOR EACH ROW EXECUTE FUNCTION "public"."validate_flashcard_topic_type"();



CREATE OR REPLACE TRIGGER "trigger_create_academy_kpis" AFTER INSERT ON "public"."academies" FOR EACH ROW EXECUTE FUNCTION "public"."create_academy_kpis"();



CREATE OR REPLACE TRIGGER "trigger_update_academies_updated_at" BEFORE UPDATE ON "public"."academies" FOR EACH ROW EXECUTE FUNCTION "public"."update_academies_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_update_academy_kpis_updated_at" BEFORE UPDATE ON "public"."academy_kpis" FOR EACH ROW EXECUTE FUNCTION "public"."update_academy_kpis_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_update_membership_levels_updated_at" BEFORE UPDATE ON "public"."membership_levels" FOR EACH ROW EXECUTE FUNCTION "public"."update_membership_levels_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_update_user_memberships_updated_at" BEFORE UPDATE ON "public"."user_memberships" FOR EACH ROW EXECUTE FUNCTION "public"."update_user_memberships_updated_at"();



ALTER TABLE ONLY "public"."academy_kpis"
    ADD CONSTRAINT "academy_kpis_academy_id_fkey" FOREIGN KEY ("academy_id") REFERENCES "public"."academies"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."challenge"
    ADD CONSTRAINT "challenge_academy_id_fkey" FOREIGN KEY ("academy_id") REFERENCES "public"."academies"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."challenge"
    ADD CONSTRAINT "challenge_editor_id_fkey" FOREIGN KEY ("editor_id") REFERENCES "public"."cms_users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."challenge"
    ADD CONSTRAINT "challenge_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "public"."questions"("id") ON DELETE RESTRICT;



COMMENT ON CONSTRAINT "challenge_question_id_fkey" ON "public"."challenge" IS 'RESTRICT: No se puede eliminar una pregunta si tiene challenges asociados';



ALTER TABLE ONLY "public"."challenge"
    ADD CONSTRAINT "challenge_topic_id_fkey" FOREIGN KEY ("topic_id") REFERENCES "public"."topic"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."challenge"
    ADD CONSTRAINT "challenge_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."cms_users"
    ADD CONSTRAINT "cms_users_academy_id_fkey" FOREIGN KEY ("academy_id") REFERENCES "public"."academies"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."cms_users"
    ADD CONSTRAINT "cms_users_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."role"("id") ON DELETE SET DEFAULT;



ALTER TABLE ONLY "public"."question_options"
    ADD CONSTRAINT "question_options_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "public"."questions"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."questions"
    ADD CONSTRAINT "questions_academy_id_fkey" FOREIGN KEY ("academy_id") REFERENCES "public"."academies"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."questions"
    ADD CONSTRAINT "questions_topic_fkey" FOREIGN KEY ("topic") REFERENCES "public"."topic"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."topic"
    ADD CONSTRAINT "topic_academy_id_fkey" FOREIGN KEY ("academy_id") REFERENCES "public"."academies"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."topic"
    ADD CONSTRAINT "topic_topic_type_id_fkey" FOREIGN KEY ("topic_type_id") REFERENCES "public"."topic_type"("id") ON DELETE RESTRICT;



COMMENT ON CONSTRAINT "topic_topic_type_id_fkey" ON "public"."topic" IS 'RESTRICT: No se puede eliminar un topic_type si tiene topics asociados';



ALTER TABLE ONLY "public"."user_memberships"
    ADD CONSTRAINT "user_memberships_membership_level_id_fkey" FOREIGN KEY ("membership_level_id") REFERENCES "public"."membership_levels"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."user_memberships"
    ADD CONSTRAINT "user_memberships_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."user_test_answers"
    ADD CONSTRAINT "user_test_answers_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "public"."questions"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."user_test_answers"
    ADD CONSTRAINT "user_test_answers_selected_option_id_fkey" FOREIGN KEY ("selected_option_id") REFERENCES "public"."question_options"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_test_answers"
    ADD CONSTRAINT "user_test_answers_user_test_id_fkey" FOREIGN KEY ("user_test_id") REFERENCES "public"."user_tests"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_tests"
    ADD CONSTRAINT "user_tests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_academy_id_fkey" FOREIGN KEY ("academy_id") REFERENCES "public"."academies"("id") ON DELETE RESTRICT;



ALTER TABLE "public"."removed_questions_history" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."academy_kpis";






GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";































































































































































GRANT ALL ON FUNCTION "public"."calculate_answer_correctness"() TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_answer_correctness"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_answer_correctness"() TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_next_review_flashcard"("p_difficulty_rating" character varying, "p_current_ease_factor" numeric, "p_current_interval_days" integer, "p_current_repetitions" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_next_review_flashcard"("p_difficulty_rating" character varying, "p_current_ease_factor" numeric, "p_current_interval_days" integer, "p_current_repetitions" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_next_review_flashcard"("p_difficulty_rating" character varying, "p_current_ease_factor" numeric, "p_current_interval_days" integer, "p_current_repetitions" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_test_score"("test_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_test_score"("test_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_test_score"("test_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."check_user_has_active_membership"("p_user_id" "uuid", "p_wordpress_user_id" integer, "p_email" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."check_user_has_active_membership"("p_user_id" "uuid", "p_wordpress_user_id" integer, "p_email" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_user_has_active_membership"("p_user_id" "uuid", "p_wordpress_user_id" integer, "p_email" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."create_academy_kpis"() TO "anon";
GRANT ALL ON FUNCTION "public"."create_academy_kpis"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_academy_kpis"() TO "service_role";



GRANT ALL ON FUNCTION "public"."create_blank_question_options"() TO "anon";
GRANT ALL ON FUNCTION "public"."create_blank_question_options"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_blank_question_options"() TO "service_role";



GRANT ALL ON FUNCTION "public"."fn_adjust_question_count"() TO "anon";
GRANT ALL ON FUNCTION "public"."fn_adjust_question_count"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fn_adjust_question_count"() TO "service_role";



GRANT ALL ON FUNCTION "public"."fn_challenge_by_tutor_update"() TO "anon";
GRANT ALL ON FUNCTION "public"."fn_challenge_by_tutor_update"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fn_challenge_by_tutor_update"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_membership_level"("p_user_id" "uuid", "p_wordpress_user_id" integer, "p_email" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_membership_level"("p_user_id" "uuid", "p_wordpress_user_id" integer, "p_email" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_membership_level"("p_user_id" "uuid", "p_wordpress_user_id" integer, "p_email" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."recalculate_academy_kpis"("p_academy_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."recalculate_academy_kpis"("p_academy_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."recalculate_academy_kpis"("p_academy_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."recalculate_questions_difficulty"() TO "anon";
GRANT ALL ON FUNCTION "public"."recalculate_questions_difficulty"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."recalculate_questions_difficulty"() TO "service_role";



GRANT ALL ON FUNCTION "public"."reset_academy_daily_kpis"() TO "anon";
GRANT ALL ON FUNCTION "public"."reset_academy_daily_kpis"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."reset_academy_daily_kpis"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_topic_options_from_type"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_topic_options_from_type"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_topic_options_from_type"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_user_test_defaults_from_topic"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_user_test_defaults_from_topic"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_user_test_defaults_from_topic"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_auth_users_to_cms"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_auth_users_to_cms"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_auth_users_to_cms"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_academies_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_academies_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_academies_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_academy_daily_answers"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_academy_daily_answers"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_academy_daily_answers"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_academy_daily_kpis_users"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_academy_daily_kpis_users"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_academy_daily_kpis_users"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_academy_kpi"("p_academy_id" bigint, "p_kpi_name" "text", "p_increment" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."update_academy_kpi"("p_academy_id" bigint, "p_kpi_name" "text", "p_increment" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_academy_kpi"("p_academy_id" bigint, "p_kpi_name" "text", "p_increment" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_academy_kpis_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_academy_kpis_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_academy_kpis_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_academy_premium_users"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_academy_premium_users"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_academy_premium_users"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_academy_total_questions"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_academy_total_questions"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_academy_total_questions"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_academy_total_tests"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_academy_total_tests"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_academy_total_tests"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_academy_total_users"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_academy_total_users"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_academy_total_users"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_challenge_timestamp"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_challenge_timestamp"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_challenge_timestamp"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_flashcard_review_schedule"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_flashcard_review_schedule"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_flashcard_review_schedule"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_membership_levels_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_membership_levels_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_membership_levels_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_single_topic_stats"("topic_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."update_single_topic_stats"("topic_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_single_topic_stats"("topic_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_topic_duration_from_count"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_topic_duration_from_count"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_topic_duration_from_count"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_topic_question_count_optimized"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_topic_question_count_optimized"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_topic_question_count_optimized"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_topic_questions_count"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_topic_questions_count"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_topic_questions_count"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_topic_stats_from_user_tests"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_topic_stats_from_user_tests"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_topic_stats_from_user_tests"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_user_memberships_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_user_memberships_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user_memberships_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_user_test_stats"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_user_test_stats"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user_test_stats"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_user_tests_question_count"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_user_tests_question_count"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user_tests_question_count"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_user_total_stats_optimized"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_user_total_stats_optimized"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user_total_stats_optimized"() TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_flashcard_options"() TO "anon";
GRANT ALL ON FUNCTION "public"."validate_flashcard_options"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_flashcard_options"() TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_flashcard_topic_type"() TO "anon";
GRANT ALL ON FUNCTION "public"."validate_flashcard_topic_type"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_flashcard_topic_type"() TO "service_role";


















GRANT ALL ON TABLE "public"."academies" TO "anon";
GRANT ALL ON TABLE "public"."academies" TO "authenticated";
GRANT ALL ON TABLE "public"."academies" TO "service_role";



GRANT ALL ON SEQUENCE "public"."academies_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."academies_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."academies_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."academy_kpis" TO "anon";
GRANT ALL ON TABLE "public"."academy_kpis" TO "authenticated";
GRANT ALL ON TABLE "public"."academy_kpis" TO "service_role";



GRANT ALL ON SEQUENCE "public"."academy_kpis_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."academy_kpis_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."academy_kpis_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."challenge" TO "anon";
GRANT ALL ON TABLE "public"."challenge" TO "authenticated";
GRANT ALL ON TABLE "public"."challenge" TO "service_role";



GRANT ALL ON SEQUENCE "public"."challenge_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."challenge_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."challenge_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."cms_users" TO "anon";
GRANT ALL ON TABLE "public"."cms_users" TO "authenticated";
GRANT ALL ON TABLE "public"."cms_users" TO "service_role";



GRANT ALL ON SEQUENCE "public"."cms_users_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."cms_users_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."cms_users_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."membership_levels" TO "anon";
GRANT ALL ON TABLE "public"."membership_levels" TO "authenticated";
GRANT ALL ON TABLE "public"."membership_levels" TO "service_role";



GRANT ALL ON SEQUENCE "public"."membership_levels_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."membership_levels_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."membership_levels_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."question_options" TO "anon";
GRANT ALL ON TABLE "public"."question_options" TO "authenticated";
GRANT ALL ON TABLE "public"."question_options" TO "service_role";



GRANT ALL ON SEQUENCE "public"."question_options_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."question_options_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."question_options_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."questions" TO "anon";
GRANT ALL ON TABLE "public"."questions" TO "authenticated";
GRANT ALL ON TABLE "public"."questions" TO "service_role";



GRANT ALL ON SEQUENCE "public"."questions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."questions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."questions_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."removed_questions_history" TO "anon";
GRANT ALL ON TABLE "public"."removed_questions_history" TO "authenticated";
GRANT ALL ON TABLE "public"."removed_questions_history" TO "service_role";



GRANT ALL ON TABLE "public"."role" TO "anon";
GRANT ALL ON TABLE "public"."role" TO "authenticated";
GRANT ALL ON TABLE "public"."role" TO "service_role";



GRANT ALL ON SEQUENCE "public"."role_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."role_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."role_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."topic" TO "anon";
GRANT ALL ON TABLE "public"."topic" TO "authenticated";
GRANT ALL ON TABLE "public"."topic" TO "service_role";



GRANT ALL ON SEQUENCE "public"."topic_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."topic_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."topic_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."topic_type" TO "anon";
GRANT ALL ON TABLE "public"."topic_type" TO "authenticated";
GRANT ALL ON TABLE "public"."topic_type" TO "service_role";



GRANT ALL ON SEQUENCE "public"."topic_type_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."topic_type_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."topic_type_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."user_memberships" TO "anon";
GRANT ALL ON TABLE "public"."user_memberships" TO "authenticated";
GRANT ALL ON TABLE "public"."user_memberships" TO "service_role";



-- GRANT ALL ON TABLE "public"."user_memberships_backup" TO "anon";
-- GRANT ALL ON TABLE "public"."user_memberships_backup" TO "authenticated";
-- GRANT ALL ON TABLE "public"."user_memberships_backup" TO "service_role";



GRANT ALL ON SEQUENCE "public"."user_memberships_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."user_memberships_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."user_memberships_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."user_test_answers" TO "anon";
GRANT ALL ON TABLE "public"."user_test_answers" TO "authenticated";
GRANT ALL ON TABLE "public"."user_test_answers" TO "service_role";



GRANT ALL ON SEQUENCE "public"."user_test_answers_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."user_test_answers_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."user_test_answers_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."user_tests" TO "anon";
GRANT ALL ON TABLE "public"."user_tests" TO "authenticated";
GRANT ALL ON TABLE "public"."user_tests" TO "service_role";



GRANT ALL ON SEQUENCE "public"."user_tests_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."user_tests_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."user_tests_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



GRANT ALL ON SEQUENCE "public"."users_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."users_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."users_id_seq" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































RESET ALL;
-- =====================================================

-- =====================================================
-- Migración: Sistema de Especialidades
-- Fecha: 2025-10-27
-- Descripción: Añade un nivel adicional de jerarquía
--              entre academias y contenido (topics/users)
-- =====================================================

-- =====================================================
-- 1. CREAR TABLA SPECIALTIES
-- =====================================================

CREATE TABLE IF NOT EXISTS public.specialties (
    id BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    academy_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url TEXT,
    color_hex VARCHAR(7),
    display_order INTEGER DEFAULT 0 NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    is_default BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Foreign Keys
    CONSTRAINT fk_specialties_academy
        FOREIGN KEY (academy_id)
        REFERENCES public.academies(id)
        ON DELETE RESTRICT,

    -- Validaciones
    CONSTRAINT specialty_name_length
        CHECK (LENGTH(TRIM(name)) > 0),

    CONSTRAINT specialty_slug_format
        CHECK (slug ~ '^[a-z0-9_-]+$'),

    -- Constraints de unicidad
    CONSTRAINT unique_specialty_slug_per_academy
        UNIQUE (academy_id, slug),

    CONSTRAINT unique_specialty_name_per_academy
        UNIQUE (academy_id, name)
);

-- Índice único parcial: solo una especialidad por defecto por academia
CREATE UNIQUE INDEX idx_specialties_one_default_per_academy
ON public.specialties(academy_id)
WHERE is_default = true;

-- Comentarios
COMMENT ON TABLE public.specialties IS 'Especialidades o categorías dentro de cada academia (ej: Escala Básica, Escala Ejecutiva)';
COMMENT ON COLUMN public.specialties.academy_id IS 'Academia propietaria de la especialidad';
COMMENT ON COLUMN public.specialties.is_default IS 'Si es la especialidad por defecto para nuevos usuarios';
COMMENT ON COLUMN public.specialties.color_hex IS 'Color temático en formato hexadecimal (#FF5733)';

-- Índices básicos
CREATE INDEX idx_specialties_academy_id ON public.specialties(academy_id);
CREATE INDEX idx_specialties_active ON public.specialties(academy_id, is_active) WHERE is_active = true;
CREATE INDEX idx_specialties_order ON public.specialties(academy_id, display_order);
CREATE INDEX idx_specialties_slug ON public.specialties(academy_id, slug);


-- =====================================================
-- 2. MODIFICAR TABLA USERS
-- =====================================================

-- Agregar columna specialty_id
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS specialty_id BIGINT;

-- Agregar foreign key
ALTER TABLE public.users
ADD CONSTRAINT fk_users_specialty
    FOREIGN KEY (specialty_id)
    REFERENCES public.specialties(id)
    ON DELETE RESTRICT;

-- Comentario
COMMENT ON COLUMN public.users.specialty_id IS 'Especialidad a la que pertenece el usuario. NULL = acceso general';

-- Índices
CREATE INDEX idx_users_specialty_id ON public.users(specialty_id);
CREATE INDEX idx_users_academy_specialty ON public.users(academy_id, specialty_id);


-- =====================================================
-- 3. MODIFICAR TABLA TOPIC
-- =====================================================

-- Agregar columna specialty_id
ALTER TABLE public.topic
ADD COLUMN IF NOT EXISTS specialty_id BIGINT;

-- Agregar foreign key
ALTER TABLE public.topic
ADD CONSTRAINT fk_topic_specialty
    FOREIGN KEY (specialty_id)
    REFERENCES public.specialties(id)
    ON DELETE RESTRICT;

-- Comentario
COMMENT ON COLUMN public.topic.specialty_id IS 'Especialidad a la que pertenece el topic. NULL = contenido compartido';

-- Índices
CREATE INDEX idx_topic_specialty_id ON public.topic(specialty_id);
CREATE INDEX idx_topic_academy_specialty ON public.topic(academy_id, specialty_id);
CREATE INDEX idx_topic_specialty_enabled ON public.topic(specialty_id, enabled) WHERE enabled = true;
CREATE INDEX idx_topic_specialty_premium ON public.topic(specialty_id, is_premium) WHERE is_premium = true;


-- =====================================================
-- 4. MODIFICAR TABLA MEMBERSHIP_LEVELS
-- =====================================================

-- Agregar columna specialty_id
ALTER TABLE public.membership_levels
ADD COLUMN IF NOT EXISTS specialty_id BIGINT;

-- Agregar foreign key
ALTER TABLE public.membership_levels
ADD CONSTRAINT fk_membership_specialty
    FOREIGN KEY (specialty_id)
    REFERENCES public.specialties(id)
    ON DELETE RESTRICT;

-- Comentario
COMMENT ON COLUMN public.membership_levels.specialty_id IS 'Especialidad específica de la membresía. NULL = membresía general';

-- Índices
CREATE INDEX idx_membership_specialty ON public.membership_levels(specialty_id);
CREATE INDEX idx_membership_academy_specialty ON public.membership_levels(specialty_id, is_active) WHERE is_active = true;


-- =====================================================
-- 5. MODIFICAR TABLA CHALLENGE
-- =====================================================

-- Agregar columna specialty_id
ALTER TABLE public.challenge
ADD COLUMN IF NOT EXISTS specialty_id BIGINT;

-- Agregar foreign key
ALTER TABLE public.challenge
ADD CONSTRAINT fk_challenge_specialty
    FOREIGN KEY (specialty_id)
    REFERENCES public.specialties(id)
    ON DELETE RESTRICT;

-- Comentario
COMMENT ON COLUMN public.challenge.specialty_id IS 'Especialidad de la que proviene el challenge';

-- Índice
CREATE INDEX idx_challenge_specialty ON public.challenge(specialty_id);


-- =====================================================
-- 6. FUNCIÓN: ASIGNAR ESPECIALIDAD POR DEFECTO
-- =====================================================

CREATE OR REPLACE FUNCTION public.assign_default_specialty()
RETURNS TRIGGER AS $$
DECLARE
    default_specialty_id BIGINT;
BEGIN
    -- Si no tiene specialty_id asignado pero sí academy_id
    IF NEW.specialty_id IS NULL AND NEW.academy_id IS NOT NULL THEN
        -- Buscar especialidad por defecto de la academia
        SELECT id INTO default_specialty_id
        FROM public.specialties
        WHERE academy_id = NEW.academy_id
          AND is_default = true
          AND is_active = true
        LIMIT 1;

        -- Si existe, asignar
        IF default_specialty_id IS NOT NULL THEN
            NEW.specialty_id := default_specialty_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.assign_default_specialty() IS 'Asigna automáticamente la especialidad por defecto de la academia si no se especifica una';

-- Aplicar trigger a users
DROP TRIGGER IF EXISTS trg_users_assign_specialty ON public.users;
CREATE TRIGGER trg_users_assign_specialty
BEFORE INSERT ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.assign_default_specialty();

-- Aplicar trigger a topics
DROP TRIGGER IF EXISTS trg_topic_assign_specialty ON public.topic;
CREATE TRIGGER trg_topic_assign_specialty
BEFORE INSERT ON public.topic
FOR EACH ROW
EXECUTE FUNCTION public.assign_default_specialty();


-- =====================================================
-- 7. FUNCIÓN: VALIDAR ESPECIALIDAD PERTENECE A ACADEMIA
-- =====================================================

CREATE OR REPLACE FUNCTION public.validate_specialty_belongs_to_academy()
RETURNS TRIGGER AS $$
DECLARE
    specialty_academy_id BIGINT;
BEGIN
    -- Si tiene specialty_id, validar que pertenezca a su academy_id
    IF NEW.specialty_id IS NOT NULL AND NEW.academy_id IS NOT NULL THEN
        SELECT academy_id INTO specialty_academy_id
        FROM public.specialties
        WHERE id = NEW.specialty_id;

        -- Validar coincidencia
        IF specialty_academy_id IS NULL THEN
            RAISE EXCEPTION 'La especialidad % no existe', NEW.specialty_id;
        END IF;

        IF specialty_academy_id != NEW.academy_id THEN
            RAISE EXCEPTION 'La especialidad % no pertenece a la academia %',
                NEW.specialty_id, NEW.academy_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.validate_specialty_belongs_to_academy() IS 'Valida que la especialidad asignada pertenezca a la academia del registro';

-- Aplicar a users
DROP TRIGGER IF EXISTS trg_users_validate_specialty ON public.users;
CREATE TRIGGER trg_users_validate_specialty
BEFORE INSERT OR UPDATE ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.validate_specialty_belongs_to_academy();

-- Aplicar a topics
DROP TRIGGER IF EXISTS trg_topic_validate_specialty ON public.topic;
CREATE TRIGGER trg_topic_validate_specialty
BEFORE INSERT OR UPDATE ON public.topic
FOR EACH ROW
EXECUTE FUNCTION public.validate_specialty_belongs_to_academy();

-- Aplicar a membership_levels
-- NOTA: Este trigger NO se aplica a membership_levels porque esa tabla
-- no tiene academy_id (son niveles globales de la app, no específicos de academia)
-- DROP TRIGGER IF EXISTS trg_membership_validate_specialty ON public.membership_levels;

-- Aplicar a challenge
DROP TRIGGER IF EXISTS trg_challenge_validate_specialty ON public.challenge;
CREATE TRIGGER trg_challenge_validate_specialty
BEFORE INSERT OR UPDATE ON public.challenge
FOR EACH ROW
EXECUTE FUNCTION public.validate_specialty_belongs_to_academy();


-- =====================================================
-- 8. FUNCIÓN: ACTUALIZAR UPDATED_AT DE SPECIALTIES
-- =====================================================

CREATE OR REPLACE FUNCTION public.update_specialties_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_specialties_updated_at ON public.specialties;
CREATE TRIGGER trg_specialties_updated_at
BEFORE UPDATE ON public.specialties
FOR EACH ROW
EXECUTE FUNCTION public.update_specialties_updated_at();


-- =====================================================
-- 9. DATOS INICIALES: ESPECIALIDADES POR DEFECTO
-- =====================================================

-- Crear especialidad "General" por defecto para cada academia existente
INSERT INTO public.specialties (academy_id, name, slug, description, is_default, is_active, display_order)
SELECT
    a.id,
    'General',
    'general',
    'Especialidad general de ' || a.name,
    true,
    true,
    0
FROM public.academies a
WHERE a.is_active = true
ON CONFLICT DO NOTHING;


-- =====================================================
-- 10. MIGRACIÓN: ASIGNAR DATOS EXISTENTES
-- =====================================================

-- Asignar todos los topics existentes a la especialidad general de su academia
UPDATE public.topic t
SET specialty_id = s.id
FROM public.specialties s
WHERE t.academy_id = s.academy_id
  AND s.is_default = true
  AND t.specialty_id IS NULL;

-- Asignar todos los usuarios existentes a la especialidad general de su academia
UPDATE public.users u
SET specialty_id = s.id
FROM public.specialties s
WHERE u.academy_id = s.academy_id
  AND s.is_default = true
  AND u.specialty_id IS NULL;

-- Asignar challenges existentes a especialidad según su topic
UPDATE public.challenge ch
SET specialty_id = t.specialty_id
FROM public.topic t
WHERE ch.topic_id = t.id
  AND ch.specialty_id IS NULL;


-- =====================================================
-- 11. PERMISOS
-- =====================================================

-- Tabla specialties
GRANT ALL ON TABLE public.specialties TO postgres;
GRANT ALL ON TABLE public.specialties TO anon;
GRANT ALL ON TABLE public.specialties TO authenticated;
GRANT ALL ON TABLE public.specialties TO service_role;

-- Secuencia
GRANT ALL ON SEQUENCE public.specialties_id_seq TO postgres;
GRANT ALL ON SEQUENCE public.specialties_id_seq TO anon;
GRANT ALL ON SEQUENCE public.specialties_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.specialties_id_seq TO service_role;

-- Funciones
GRANT ALL ON FUNCTION public.assign_default_specialty() TO anon;
GRANT ALL ON FUNCTION public.assign_default_specialty() TO authenticated;
GRANT ALL ON FUNCTION public.assign_default_specialty() TO service_role;

GRANT ALL ON FUNCTION public.validate_specialty_belongs_to_academy() TO anon;
GRANT ALL ON FUNCTION public.validate_specialty_belongs_to_academy() TO authenticated;
GRANT ALL ON FUNCTION public.validate_specialty_belongs_to_academy() TO service_role;

GRANT ALL ON FUNCTION public.update_specialties_updated_at() TO anon;
GRANT ALL ON FUNCTION public.update_specialties_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.update_specialties_updated_at() TO service_role;


-- =====================================================
-- MIGRACIÓN COMPLETADA
-- =====================================================

-- Verificar creación
DO $$
DECLARE
    specialty_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO specialty_count FROM public.specialties;
    RAISE NOTICE 'Migración completada. Total de especialidades creadas: %', specialty_count;
END $$;-- =====================================================

-- Migration: Add auth trigger to sync users from auth.users to cms_users
--
-- This trigger automatically syncs users from auth.users to cms_users
-- Note: The auth schema is not included in Supabase backups by default,
-- so this trigger must be recreated via this migration.
--
-- The function public.sync_auth_users_to_cms() must exist previously.

-- Drop trigger if it already exists (for idempotence)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create the trigger on auth.users
-- This trigger executes after each INSERT, UPDATE or DELETE on auth.users
-- It automatically syncs users to cms_users with academy_id = 1 (OPN) as default
CREATE TRIGGER on_auth_user_created
  AFTER INSERT OR UPDATE OR DELETE ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.sync_auth_users_to_cms();-- =====================================================

-- Migration: Fix permissions for sync_auth_users_to_cms function
--
-- This migration fixes permission issues when creating users from the Supabase dashboard.
-- The sync_auth_users_to_cms function needs explicit permissions to:
-- 1. Access the auth schema
-- 2. Read from auth.users table
-- 3. Insert/update into cms_users table

-- In Supabase, the auth schema is special and managed by supabase_auth_admin
-- The key is to ensure the function runs with the correct security context

-- Ensure the function has proper ownership
-- Using postgres as owner gives it superuser privileges to bypass RLS
ALTER FUNCTION public.sync_auth_users_to_cms() OWNER TO postgres;

-- Grant EXECUTE permission to all roles that might trigger user creation
GRANT EXECUTE ON FUNCTION public.sync_auth_users_to_cms() TO postgres;
GRANT EXECUTE ON FUNCTION public.sync_auth_users_to_cms() TO supabase_auth_admin;
GRANT EXECUTE ON FUNCTION public.sync_auth_users_to_cms() TO service_role;
GRANT EXECUTE ON FUNCTION public.sync_auth_users_to_cms() TO authenticated;
GRANT EXECUTE ON FUNCTION public.sync_auth_users_to_cms() TO anon;

-- Ensure postgres has full permissions on cms_users table and sequence
-- This is critical for the SECURITY DEFINER function to insert/update
GRANT ALL ON TABLE public.cms_users TO postgres;
GRANT ALL ON SEQUENCE public.cms_users_id_seq TO postgres;

-- Also ensure supabase_auth_admin can execute (it's the owner of auth.users)
GRANT ALL ON TABLE public.cms_users TO supabase_auth_admin;
GRANT ALL ON SEQUENCE public.cms_users_id_seq TO supabase_auth_admin;

-- Add a comment explaining the security context
COMMENT ON FUNCTION public.sync_auth_users_to_cms() IS
'Trigger function to sync users from auth.users to cms_users.
Runs with SECURITY DEFINER as postgres to bypass RLS and permission checks.
The function is executed by triggers on auth.users (owned by supabase_auth_admin).
Multiple roles have EXECUTE permission to ensure compatibility with dashboard user creation.';
-- =====================================================

-- Migration: Insert default academies
--
-- This migration creates the default academies required by the system.
-- The OPN (Oposición Nacional de Policía) academy is set as id=1 as it's
-- referenced as the default in sync_auth_users_to_cms function.

-- Insert default academies
-- Using ON CONFLICT to make this migration idempotent
INSERT INTO public.academies (
    id,
    name,
    slug,
    description,
    is_active,
    created_at,
    updated_at
) VALUES
    (
        1,
        'OPN - Oposición Policía Nacional',
        'opn',
        'Academia para la preparación de oposiciones a Policía Nacional',
        true,
        NOW(),
        NOW()
    )
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    updated_at = NOW();

-- Ensure the sequence is updated to avoid conflicts with future inserts
SELECT setval('public.academies_id_seq', (SELECT MAX(id) FROM public.academies));

-- Add a comment
COMMENT ON TABLE public.academies IS
'Academias o centros de formación. La academia OPN (id=1) es la academia por defecto para nuevos usuarios.';
-- =====================================================

-- Migration: Insert default roles
--
-- This migration creates the default roles required by the system.
-- Role id=4 (User/Alumno) is referenced as the default in sync_auth_users_to_cms function.

-- Insert default roles
-- Using ON CONFLICT to make this migration idempotent
INSERT INTO public.role (
    id,
    role_name,
    created_at,
    updated_at
) VALUES
    (1, 'Admin', NOW(), NOW()),
    (2, 'Editor', NOW(), NOW()),
    (3, 'Tutor', NOW(), NOW()),
    (4, 'User', NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET
    role_name = EXCLUDED.role_name,
    updated_at = NOW();

-- Ensure the sequence is updated to avoid conflicts with future inserts
SELECT setval('public.role_id_seq', (SELECT MAX(id) FROM public.role));

-- Add comments
COMMENT ON TABLE public.role IS
'Roles de usuario en el sistema. El rol User (id=4) es el rol por defecto para nuevos usuarios registrados.';
-- =====================================================

-- Remove the validate_specialty_belongs_to_academy trigger from membership_levels
-- because membership_levels table does not have academy_id column

DROP TRIGGER IF EXISTS trg_membership_validate_specialty ON public.membership_levels;

COMMENT ON TABLE public.membership_levels IS 'Niveles de desbloqueo globales de la app (Freemium, Premium, Premium+). No están asociados a academias específicas.';
-- =====================================================

-- Create categories table
create table public.categories (
  id bigint generated by default as identity not null,
  created_at timestamp with time zone not null default now(),
  name text null,
  topic_type bigint null,
  constraint categories_pkey primary key (id),
  constraint categories_topic_type_fkey foreign key (topic_type) references topic_type (id) on update cascade on delete cascade
) tablespace pg_default;

-- Enable RLS
alter table public.categories enable row level security;

-- Create policy for authenticated users to read categories
create policy "Allow authenticated users to read categories"
  on public.categories
  for select
  to authenticated
  using (true);

-- Create policy for authenticated users to insert categories
create policy "Allow authenticated users to create categories"
  on public.categories
  for insert
  to authenticated
  with check (true);

-- Create policy for authenticated users to update categories
create policy "Allow authenticated users to update categories"
  on public.categories
  for update
  to authenticated
  using (true);

-- Create policy for authenticated users to delete categories
create policy "Allow authenticated users to delete categories"
  on public.categories
  for delete
  to authenticated
  using (true);

-- Create index on topic_type for faster queries
create index categories_topic_type_idx on public.categories (topic_type);
-- =====================================================

-- Disable RLS on categories table to match other system tables
alter table public.categories disable row level security;

-- Drop existing policies (they won't be needed)
drop policy if exists "Allow authenticated users to read categories" on public.categories;
drop policy if exists "Allow authenticated users to create categories" on public.categories;
drop policy if exists "Allow authenticated users to update categories" on public.categories;
drop policy if exists "Allow authenticated users to delete categories" on public.categories;
-- =====================================================

-- Eliminar la restricción que limita access_level a 1-3
-- Ahora access_level será dinámico y coincidirá con el access_level de WordPress RCP

ALTER TABLE public.membership_levels 
DROP CONSTRAINT IF EXISTS membership_levels_access_level_check;

-- Actualizar el comentario de la columna
COMMENT ON COLUMN public.membership_levels.access_level IS 'Nivel de acceso desde WordPress RCP. Puede ser cualquier número positivo según la configuración de RCP.';

-- Verificar que access_level sea positivo
ALTER TABLE public.membership_levels 
ADD CONSTRAINT membership_levels_access_level_positive 
CHECK (access_level > 0);
-- =====================================================

-- Agregar columnas 'order' y 'category_id' a la tabla topics

-- Agregar columna 'order' para ordenar los topics
ALTER TABLE public.topic
ADD COLUMN IF NOT EXISTS "order" INTEGER DEFAULT 0 NOT NULL;

-- Agregar columna 'category_id' como foreign key a categories
ALTER TABLE public.topic
ADD COLUMN IF NOT EXISTS category_id BIGINT;

-- Agregar foreign key constraint
ALTER TABLE public.topic
ADD CONSTRAINT fk_topic_category
    FOREIGN KEY (category_id)
    REFERENCES public.categories(id)
    ON DELETE SET NULL;

-- Agregar índices para mejor performance
CREATE INDEX IF NOT EXISTS idx_topic_order ON public.topic("order");
CREATE INDEX IF NOT EXISTS idx_topic_category ON public.topic(category_id);
CREATE INDEX IF NOT EXISTS idx_topic_category_order ON public.topic(category_id, "order") WHERE category_id IS NOT NULL;

-- Comentarios
COMMENT ON COLUMN public.topic."order" IS 'Orden de visualización del topic dentro de su categoría. Menor número = mayor prioridad.';
COMMENT ON COLUMN public.topic.category_id IS 'ID de la categoría a la que pertenece este topic. NULL = topic sin categoría.';

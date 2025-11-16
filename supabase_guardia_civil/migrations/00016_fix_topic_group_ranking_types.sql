-- =====================================================
-- MIGRATION 16: FIX TOPIC GROUP RANKING FUNCTION TYPES
-- =====================================================
-- Descripción: Corrige los tipos de datos de las funciones de ranking
--              para que coincidan con los tipos reales de la tabla users
-- Fecha: 2025-11-12
-- =====================================================

-- =====================================================
-- FUNCIÓN: get_topic_group_ranking (CORREGIDA)
-- =====================================================
DROP FUNCTION IF EXISTS "public"."get_topic_group_ranking"(BIGINT, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION "public"."get_topic_group_ranking"(
  p_topic_group_id BIGINT,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  user_id BIGINT,
  username VARCHAR,
  display_name TEXT,
  profile_image TEXT,
  first_name TEXT,
  last_name TEXT,
  average_first_score NUMERIC,
  total_attempts INTEGER,
  topics_completed INTEGER,
  total_topics_in_group INTEGER,
  rank_position INTEGER,
  first_attempt_date TIMESTAMP WITH TIME ZONE,
  last_attempt_date TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  v_total_topics INTEGER;
BEGIN
  -- Obtener el número total de topics en el grupo
  SELECT COUNT(*)
  INTO v_total_topics
  FROM "public"."topic"
  WHERE topic_group_id = p_topic_group_id
    AND enabled = true;

  -- Si no hay topics en el grupo, retornar vacío
  IF v_total_topics = 0 THEN
    RETURN;
  END IF;

  -- Calcular el ranking
  RETURN QUERY
  WITH user_group_stats AS (
    -- Agrupar por usuario y calcular estadísticas
    SELECT
      tmr.user_id,
      AVG(tmr.first_score) AS avg_first_score,
      SUM(tmr.attempts) AS total_attempts,
      COUNT(DISTINCT tmr.topic_id) AS topics_completed,
      MIN(tmr.first_attempt_date) AS first_attempt,
      MAX(tmr.last_attempt_date) AS last_attempt
    FROM "public"."topic_mock_rankings" tmr
    INNER JOIN "public"."topic" t ON t.id = tmr.topic_id
    WHERE tmr.topic_group_id = p_topic_group_id
      AND t.enabled = true
    GROUP BY tmr.user_id
    -- IMPORTANTE: Solo incluir usuarios que completaron TODOS los topics del grupo
    HAVING COUNT(DISTINCT tmr.topic_id) = v_total_topics
  ),
  ranked_users AS (
    -- Asignar posiciones de ranking
    SELECT
      ugs.user_id,
      ugs.avg_first_score,
      ugs.total_attempts,
      ugs.topics_completed,
      ugs.first_attempt,
      ugs.last_attempt,
      ROW_NUMBER() OVER (
        ORDER BY ugs.avg_first_score DESC, ugs.first_attempt ASC
      ) AS position
    FROM user_group_stats ugs
  )
  SELECT
    ru.user_id,
    u.username,
    u.display_name,
    u.profile_image,
    u.first_name,
    u.last_name,
    ru.avg_first_score,
    ru.total_attempts::INTEGER,
    ru.topics_completed::INTEGER,
    v_total_topics,
    ru.position::INTEGER,
    ru.first_attempt,
    ru.last_attempt
  FROM ranked_users ru
  INNER JOIN "public"."users" u ON u.id = ru.user_id
  ORDER BY ru.position ASC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

ALTER FUNCTION "public"."get_topic_group_ranking"(BIGINT, INTEGER, INTEGER) OWNER TO "postgres";

COMMENT ON FUNCTION "public"."get_topic_group_ranking"(BIGINT, INTEGER, INTEGER) IS
'Calcula el ranking consolidado de un topic_group promediando los first_score de todos los topics del grupo. Solo incluye usuarios que han completado TODOS los topics del grupo.';

-- =====================================================
-- FUNCIÓN: get_user_topic_group_ranking_entry (CORREGIDA)
-- =====================================================
DROP FUNCTION IF EXISTS "public"."get_user_topic_group_ranking_entry"(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION "public"."get_user_topic_group_ranking_entry"(
  p_topic_group_id BIGINT,
  p_user_id BIGINT
)
RETURNS TABLE (
  user_id BIGINT,
  username VARCHAR,
  display_name TEXT,
  profile_image TEXT,
  first_name TEXT,
  last_name TEXT,
  average_first_score NUMERIC,
  total_attempts INTEGER,
  topics_completed INTEGER,
  total_topics_in_group INTEGER,
  rank_position INTEGER,
  first_attempt_date TIMESTAMP WITH TIME ZONE,
  last_attempt_date TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  v_total_topics INTEGER;
BEGIN
  -- Obtener el número total de topics en el grupo
  SELECT COUNT(*)
  INTO v_total_topics
  FROM "public"."topic"
  WHERE topic_group_id = p_topic_group_id
    AND enabled = true;

  -- Si no hay topics en el grupo, retornar vacío
  IF v_total_topics = 0 THEN
    RETURN;
  END IF;

  -- Calcular el ranking y buscar al usuario
  RETURN QUERY
  WITH user_group_stats AS (
    SELECT
      tmr.user_id,
      AVG(tmr.first_score) AS avg_first_score,
      SUM(tmr.attempts) AS total_attempts,
      COUNT(DISTINCT tmr.topic_id) AS topics_completed,
      MIN(tmr.first_attempt_date) AS first_attempt,
      MAX(tmr.last_attempt_date) AS last_attempt
    FROM "public"."topic_mock_rankings" tmr
    INNER JOIN "public"."topic" t ON t.id = tmr.topic_id
    WHERE tmr.topic_group_id = p_topic_group_id
      AND t.enabled = true
    GROUP BY tmr.user_id
  ),
  ranked_users AS (
    SELECT
      ugs.user_id,
      ugs.avg_first_score,
      ugs.total_attempts,
      ugs.topics_completed,
      ugs.first_attempt,
      ugs.last_attempt,
      ROW_NUMBER() OVER (
        ORDER BY ugs.avg_first_score DESC, ugs.first_attempt ASC
      ) AS position
    FROM user_group_stats ugs
    -- IMPORTANTE: Solo incluir usuarios que completaron TODOS los topics del grupo
    WHERE ugs.topics_completed = v_total_topics
  )
  SELECT
    ru.user_id,
    u.username,
    u.display_name,
    u.profile_image,
    u.first_name,
    u.last_name,
    ru.avg_first_score,
    ru.total_attempts::INTEGER,
    ru.topics_completed::INTEGER,
    v_total_topics,
    ru.position::INTEGER,
    ru.first_attempt,
    ru.last_attempt
  FROM ranked_users ru
  INNER JOIN "public"."users" u ON u.id = ru.user_id
  WHERE ru.user_id = p_user_id
  LIMIT 1;
END;
$$;

ALTER FUNCTION "public"."get_user_topic_group_ranking_entry"(BIGINT, BIGINT) OWNER TO "postgres";

COMMENT ON FUNCTION "public"."get_user_topic_group_ranking_entry"(BIGINT, BIGINT) IS
'Obtiene la entrada del ranking de un usuario específico en un topic_group. Retorna NULL si el usuario no ha completado todos los topics del grupo.';
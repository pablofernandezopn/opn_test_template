-- =====================================================
-- Migration: User Special Topics Functions
-- Description: Funciones optimizadas para obtener topics especiales completados por el usuario
-- Date: 2025-11-03
-- =====================================================

-- =====================================================
-- 1. Función para obtener topics especiales del usuario (con paginación)
-- =====================================================

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

-- =====================================================
-- 2. Función para obtener IDs de topics completados por el usuario
-- =====================================================

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

-- =====================================================
-- 3. Índices adicionales para optimización
-- =====================================================

-- Índice para búsquedas de special_topic por usuario
CREATE INDEX IF NOT EXISTS "idx_user_tests_user_special_topic"
ON "public"."user_tests"("user_id", "special_topic", "created_at" DESC)
WHERE "special_topic" IS NOT NULL AND "finalized" = true AND "visible" = true;

COMMENT ON INDEX "idx_user_tests_user_special_topic" IS
'Optimiza consultas de topics especiales por usuario ordenados por fecha';

-- Índice para unnest de topic_ids (mejora el rendimiento de get_user_completed_topic_ids)
CREATE INDEX IF NOT EXISTS "idx_user_tests_topic_ids_gin"
ON "public"."user_tests" USING GIN ("topic_ids")
WHERE "finalized" = true AND array_length("topic_ids", 1) > 0;

COMMENT ON INDEX "idx_user_tests_topic_ids_gin" IS
'Índice GIN para búsquedas rápidas en el array topic_ids';

-- =====================================================
-- 4. Permisos
-- =====================================================

GRANT EXECUTE ON FUNCTION "public"."get_user_special_topics"(BIGINT, INTEGER, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION "public"."get_user_special_topics"(BIGINT, INTEGER, INTEGER) TO service_role;

GRANT EXECUTE ON FUNCTION "public"."get_user_completed_topic_ids"(BIGINT) TO authenticated;
GRANT EXECUTE ON FUNCTION "public"."get_user_completed_topic_ids"(BIGINT) TO service_role;

-- =====================================================
-- 5. Testing (comentar en producción)
-- =====================================================

-- Ejemplo de uso:
-- SELECT * FROM get_user_special_topics(1, 20, 0);
-- SELECT * FROM get_user_completed_topic_ids(1);
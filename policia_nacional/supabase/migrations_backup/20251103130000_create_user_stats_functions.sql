-- =====================================================
-- FUNCIÓN: Obtener estadísticas globales del usuario en Mock tests
-- =====================================================

CREATE OR REPLACE FUNCTION get_user_mock_stats(p_user_id INT)
RETURNS JSON
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT json_build_object(
        'total_mock_tests', COUNT(DISTINCT tmr.topic_id),
        'average_score', COALESCE(AVG(tmr.first_score), 0),
        'best_score', COALESCE(MAX(tmr.best_score), 0),
        'total_attempts', COALESCE(SUM(tmr.attempts), 0),
        'average_rank_position', AVG(tmr.rank_position),
        'best_rank_position', MIN(tmr.rank_position),
        'top_3_count', COUNT(*) FILTER (WHERE tmr.rank_position <= 3),
        'top_10_count', COUNT(*) FILTER (WHERE tmr.rank_position <= 10),
        'last_attempt_date', MAX(tmr.last_attempt_date)
    ) INTO v_result
    FROM topic_mock_rankings tmr
    INNER JOIN topics t ON t.id = tmr.topic_id
    INNER JOIN topic_types tt ON tt.id = t.topic_type_id
    WHERE tmr.user_id = p_user_id
      AND tt.level = 'Mock'
      AND t.is_enabled = true
      AND t.is_published = true;

    RETURN v_result;
END;
$$;

-- =====================================================
-- FUNCIÓN: Obtener estadísticas detalladas por topic Mock
-- =====================================================

CREATE OR REPLACE FUNCTION get_user_topic_mock_stats(p_user_id INT)
RETURNS TABLE (
    topic_id INT,
    topic_name TEXT,
    first_score NUMERIC,
    best_score NUMERIC,
    attempts INT,
    rank_position INT,
    total_participants BIGINT,
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
        -- Contar participantes en este topic
        (SELECT COUNT(*)
         FROM topic_mock_rankings
         WHERE topic_id = tmr.topic_id) AS total_participants,
        tmr.first_attempt_date,
        tmr.last_attempt_date
    FROM topic_mock_rankings tmr
    INNER JOIN topics t ON t.id = tmr.topic_id
    INNER JOIN topic_types tt ON tt.id = t.topic_type_id
    WHERE tmr.user_id = p_user_id
      AND tt.level = 'Mock'
      AND t.is_enabled = true
      AND t.is_published = true
    ORDER BY tmr.last_attempt_date DESC;
END;
$$;

-- =====================================================
-- FUNCIÓN: Obtener datos para gráficos de evolución
-- =====================================================

CREATE OR REPLACE FUNCTION get_user_mock_evolution(p_user_id INT, p_days INT DEFAULT 30)
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
    INNER JOIN topics t ON t.id = tmr.topic_id
    INNER JOIN topic_types tt ON tt.id = t.topic_type_id
    WHERE tmr.user_id = p_user_id
      AND tt.level = 'Mock'
      AND t.is_enabled = true
      AND t.is_published = true
      AND tmr.last_attempt_date >= NOW() - (p_days || ' days')::INTERVAL
    ORDER BY tmr.last_attempt_date ASC;
END;
$$;

-- =====================================================
-- FUNCIÓN: Obtener comparación del usuario con el promedio
-- =====================================================

CREATE OR REPLACE FUNCTION get_user_mock_comparison(p_user_id INT, p_topic_id INT)
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

-- =====================================================
-- FUNCIÓN: Obtener progreso/mejora del usuario
-- =====================================================

CREATE OR REPLACE FUNCTION get_user_mock_progress(p_user_id INT)
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
    INNER JOIN topics t ON t.id = tmr.topic_id
    INNER JOIN topic_types tt ON tt.id = t.topic_type_id
    WHERE tmr.user_id = p_user_id
      AND tt.level = 'Mock'
      AND t.is_enabled = true
      AND t.is_published = true
      AND tmr.attempts > 1  -- Solo mostrar donde hay mejora
    ORDER BY improvement_percentage DESC;
END;
$$;

-- =====================================================
-- COMENTARIOS
-- =====================================================

COMMENT ON FUNCTION get_user_mock_stats IS
'Obtiene estadísticas globales del usuario en todos los topics de tipo Mock';

COMMENT ON FUNCTION get_user_topic_mock_stats IS
'Obtiene estadísticas detalladas por cada topic Mock completado por el usuario';

COMMENT ON FUNCTION get_user_mock_evolution IS
'Obtiene datos para gráficos de evolución temporal del usuario en los últimos N días';

COMMENT ON FUNCTION get_user_mock_comparison IS
'Compara el rendimiento del usuario con el promedio en un topic específico';

COMMENT ON FUNCTION get_user_mock_progress IS
'Obtiene el progreso/mejora del usuario en topics con múltiples intentos';
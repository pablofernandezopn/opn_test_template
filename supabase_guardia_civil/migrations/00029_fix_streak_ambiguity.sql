-- =====================================================
-- Fix: Corregir ambigüedad en get_week_activity
-- =====================================================

-- Recrear la función con aliases explícitos para evitar ambigüedad
CREATE OR REPLACE FUNCTION "public"."get_week_activity"(p_user_id bigint)
RETURNS TABLE(
    day_of_week integer,
    day_name text,
    activity_date date,
    has_activity boolean,
    is_today boolean,
    tests_completed integer,
    questions_answered integer
) AS $$
BEGIN
    RETURN QUERY
    WITH week_dates AS (
        -- Generar los últimos 7 días (incluyendo hoy)
        SELECT
            generate_series(
                CURRENT_DATE - INTERVAL '6 days',
                CURRENT_DATE,
                INTERVAL '1 day'
            )::date as date
    ),
    user_activity AS (
        SELECT
            uda.activity_date as activity_date,
            uda.tests_completed as tests_completed,
            uda.questions_answered as questions_answered
        FROM public.user_daily_activity uda
        WHERE uda.user_id = p_user_id
          AND uda.activity_date >= CURRENT_DATE - INTERVAL '6 days'
    )
    SELECT
        EXTRACT(DOW FROM wd.date)::integer as day_of_week,
        CASE EXTRACT(DOW FROM wd.date)::integer
            WHEN 0 THEN 'D'  -- Domingo
            WHEN 1 THEN 'L'  -- Lunes
            WHEN 2 THEN 'M'  -- Martes
            WHEN 3 THEN 'M'  -- Miércoles
            WHEN 4 THEN 'J'  -- Jueves
            WHEN 5 THEN 'V'  -- Viernes
            WHEN 6 THEN 'S'  -- Sábado
        END as day_name,
        wd.date::date as activity_date,
        (ua.activity_date IS NOT NULL) as has_activity,
        (wd.date = CURRENT_DATE) as is_today,
        COALESCE(ua.tests_completed, 0) as tests_completed,
        COALESCE(ua.questions_answered, 0) as questions_answered
    FROM week_dates wd
    LEFT JOIN user_activity ua ON ua.activity_date::date = wd.date::date
    ORDER BY wd.date;
END;
$$ LANGUAGE plpgsql STABLE;

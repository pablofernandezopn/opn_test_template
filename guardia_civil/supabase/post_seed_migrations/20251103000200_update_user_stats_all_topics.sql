-- =====================================================
-- Migration: Update user stats for ALL topics
-- Description: Modificar trigger para contar todos los tipos de topics (Study, Mock, etc.)
--              en las estadísticas del usuario (totalQuestions, rightQuestions, wrongQuestions)
-- Date: 2025-11-03
-- =====================================================

-- =====================================================
-- Reemplazar función para contar TODOS los topics
-- =====================================================

CREATE OR REPLACE FUNCTION "public"."update_user_total_stats_optimized"()
RETURNS TRIGGER
LANGUAGE plpgsql
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
    -- CAMBIO: Ya NO se ignoran tests de special_topic
    -- Ahora se cuentan TODOS los tests finalizados, independientemente del tipo de topic

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

COMMENT ON FUNCTION "public"."update_user_total_stats_optimized"() IS
'Actualiza las estadísticas totales del usuario (totalQuestions, rightQuestions, wrongQuestions)
considerando TODOS los tipos de topics (Study, Mock, Flashcard, etc.) cuando se finaliza un test.';

-- =====================================================
-- Recalcular estadísticas de usuarios desde cero
-- =====================================================

-- Esta operación recalcula las estadísticas de todos los usuarios
-- basándose en TODOS sus tests finalizados (incluyendo Mock, Study, etc.)

DO $$
DECLARE
    user_record RECORD;
    total_users INTEGER := 0;
BEGIN
    RAISE NOTICE 'Iniciando recálculo de estadísticas para todos los usuarios...';

    -- Para cada usuario, recalcular desde cero
    FOR user_record IN
        SELECT id FROM users
    LOOP
        UPDATE users u
        SET
            "totalQuestions" = COALESCE(
                (SELECT SUM(question_count)
                 FROM user_tests
                 WHERE user_id = user_record.id
                   AND finalized = true),
                0
            ),
            "rightQuestions" = COALESCE(
                (SELECT SUM(right_questions)
                 FROM user_tests
                 WHERE user_id = user_record.id
                   AND finalized = true),
                0
            ),
            "wrongQuestions" = COALESCE(
                (SELECT SUM(wrong_questions)
                 FROM user_tests
                 WHERE user_id = user_record.id
                   AND finalized = true),
                0
            ),
            "updatedAt" = now()
        WHERE u.id = user_record.id;

        total_users := total_users + 1;
    END LOOP;

    RAISE NOTICE 'Recálculo completado para % usuarios', total_users;
END $$;

-- =====================================================
-- Mostrar resumen de cambios
-- =====================================================

DO $$
DECLARE
    total_users INTEGER;
    total_questions BIGINT;
    total_right BIGINT;
    total_wrong BIGINT;
    users_with_stats INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_users FROM users;

    SELECT
        SUM("totalQuestions"),
        SUM("rightQuestions"),
        SUM("wrongQuestions"),
        COUNT(*) FILTER (WHERE "totalQuestions" > 0)
    INTO total_questions, total_right, total_wrong, users_with_stats
    FROM users;

    RAISE NOTICE '=== RESUMEN DE ESTADÍSTICAS ===';
    RAISE NOTICE 'Total usuarios: %', total_users;
    RAISE NOTICE 'Usuarios con estadísticas: %', users_with_stats;
    RAISE NOTICE 'Total preguntas: %', total_questions;
    RAISE NOTICE 'Total correctas: %', total_right;
    RAISE NOTICE 'Total incorrectas: %', total_wrong;
    RAISE NOTICE 'Tasa de acierto global: %%%',
        CASE
            WHEN total_questions > 0
            THEN ROUND((total_right::numeric / total_questions::numeric) * 100, 2)
            ELSE 0
        END;
END $$;
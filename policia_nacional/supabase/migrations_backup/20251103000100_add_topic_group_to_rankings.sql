-- =====================================================
-- Migration: Add topic_group_id to Rankings
-- Description: Añadir topic_group_id a la tabla de rankings
-- Date: 2025-11-03
-- =====================================================

-- =====================================================
-- 1. Añadir columna topic_group_id
-- =====================================================

ALTER TABLE "public"."topic_mock_rankings"
ADD COLUMN IF NOT EXISTS "topic_group_id" BIGINT REFERENCES "public"."topic_groups"("id") ON DELETE SET NULL;

COMMENT ON COLUMN "public"."topic_mock_rankings"."topic_group_id" IS
'ID del grupo al que pertenece este topic (NULL si el topic va solo). Permite filtrar rankings por grupo de examen.';

-- =====================================================
-- 2. Crear índice para búsquedas por grupo
-- =====================================================

CREATE INDEX IF NOT EXISTS "idx_rankings_topic_group"
ON "public"."topic_mock_rankings"("topic_group_id", "topic_id")
WHERE "topic_group_id" IS NOT NULL;

COMMENT ON INDEX "public"."idx_rankings_topic_group" IS
'Índice para recuperar rankings de todos los topics de un grupo';

-- =====================================================
-- 3. Actualizar función del trigger para incluir topic_group_id
-- =====================================================

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
  -- Solo procesar si es un test Mock finalizado con score
  IF NEW.mock IS NOT TRUE OR NEW.finalized IS NOT TRUE OR NEW.score IS NULL THEN
    RETURN NEW;
  END IF;

  -- Verificar que el topic_ids tenga al menos un elemento
  IF array_length(NEW.topic_ids, 1) IS NULL OR array_length(NEW.topic_ids, 1) = 0 THEN
    RETURN NEW;
  END IF;

  -- Tomar el primer topic_id (asumiendo que un test Mock tiene un solo topic)
  v_topic_id := NEW.topic_ids[1];

  -- Obtener level y topic_group_id del topic
  SELECT tt.level, t.topic_group_id
  INTO v_topic_type_level, v_topic_group_id
  FROM "public"."topic" t
  JOIN "public"."topic_type" tt ON t.topic_type_id = tt.id
  WHERE t.id = v_topic_id;

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
      v_topic_group_id,  -- Puede ser NULL si el topic no pertenece a ningún grupo
      NEW.score,  -- first_score (inmutable desde ahora)
      NEW.score,  -- best_score (puede mejorar después)
      1,
      NEW.created_at,  -- first_attempt_date (inmutable)
      NEW.created_at   -- last_attempt_date
    );
    -- Recalcular porque hay un nuevo participante
    v_should_recalculate := true;

  ELSE
    -- Actualizar entrada existente (intentos posteriores)
    -- first_score y first_attempt_date NO se tocan (son inmutables)

    IF NEW.score > v_current_best_score THEN
      -- Actualizar best_score si mejora
      UPDATE "public"."topic_mock_rankings"
      SET
        best_score = NEW.score,
        attempts = v_current_attempts + 1,
        last_attempt_date = NEW.created_at,
        updated_at = now()
      WHERE topic_id = v_topic_id AND user_id = NEW.user_id;
      -- NO recalcular porque first_score no cambió (el ranking no se ve afectado)

    ELSE
      -- Solo actualizar attempts y fecha, sin cambios en scores
      UPDATE "public"."topic_mock_rankings"
      SET
        attempts = v_current_attempts + 1,
        last_attempt_date = NEW.created_at,
        updated_at = now()
      WHERE topic_id = v_topic_id AND user_id = NEW.user_id;
      -- NO recalcular porque nada cambió en el ranking
    END IF;
  END IF;

  -- Recalcular rankings SOLO si hay un nuevo usuario (porque first_score es inmutable)
  IF v_should_recalculate THEN
    PERFORM "public"."recalculate_topic_rankings"(v_topic_id);
  END IF;

  RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."update_ranking_on_mock_complete"() OWNER TO "postgres";

COMMENT ON FUNCTION "public"."update_ranking_on_mock_complete"() IS
'Actualiza el ranking cuando un usuario completa un test Mock. Incluye topic_group_id para filtrar por grupos.';

-- =====================================================
-- 4. Actualizar datos históricos con topic_group_id
-- =====================================================

UPDATE "public"."topic_mock_rankings" tmr
SET topic_group_id = t.topic_group_id
FROM "public"."topic" t
WHERE tmr.topic_id = t.id
  AND tmr.topic_group_id IS NULL;

-- =====================================================
-- 5. Mostrar resumen
-- =====================================================

DO $$
DECLARE
  v_updated INTEGER;
  v_with_group INTEGER;
  v_without_group INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_with_group
  FROM "public"."topic_mock_rankings"
  WHERE topic_group_id IS NOT NULL;

  SELECT COUNT(*) INTO v_without_group
  FROM "public"."topic_mock_rankings"
  WHERE topic_group_id IS NULL;

  RAISE NOTICE 'Rankings con grupo: %', v_with_group;
  RAISE NOTICE 'Rankings sin grupo: %', v_without_group;
END $$;
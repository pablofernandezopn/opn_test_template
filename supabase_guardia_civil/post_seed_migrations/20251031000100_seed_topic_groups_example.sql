-- =====================================================
-- Seed: Ejemplo de Topic Groups
-- Description: Datos de ejemplo para probar el sistema de topic_groups
-- Date: 2025-10-31
-- =====================================================

-- NOTA: Esta migración es SOLO PARA TESTING/DESARROLLO
-- En producción, los topic_groups se crearán desde el CMS

-- =====================================================
-- 1. Crear grupo de examen ejemplo
-- =====================================================

INSERT INTO "public"."topic_groups" (
  "name",
  "description",
  "academy_id",
  "enabled",
  "is_premium",
  "published_at",
  "image_url"
) VALUES (
  'Examen Oficial 2024',
  'Simulacro completo del examen oficial - Conocimientos, Psicotécnicos y Ortografía',
  1, -- academy_id (asumiendo que existe academy con id=1)
  true,
  false,
  now(),
  NULL
)
ON CONFLICT DO NOTHING; -- Evitar error si ya existe

-- =====================================================
-- 2. Obtener el ID del grupo recién creado
-- =====================================================

DO $$
DECLARE
  v_group_id BIGINT;
  v_topic_conocimientos BIGINT;
  v_topic_psicos BIGINT;
  v_topic_ortografia BIGINT;
BEGIN
  -- Obtener el ID del grupo
  SELECT id INTO v_group_id
  FROM "public"."topic_groups"
  WHERE "name" = 'Examen Oficial 2024'
  LIMIT 1;

  -- Solo continuar si se encontró el grupo
  IF v_group_id IS NOT NULL THEN

    -- Buscar topics existentes que podamos usar para el ejemplo
    -- (Ajusta estos nombres según los topics que existan en tu BD)

    -- Buscar topic de Conocimientos
    SELECT id INTO v_topic_conocimientos
    FROM "public"."topic"
    WHERE "topic_name" ILIKE '%conocimiento%'
      AND "academy_id" = 1
    LIMIT 1;

    -- Buscar topic de Psicotécnicos
    SELECT id INTO v_topic_psicos
    FROM "public"."topic"
    WHERE "topic_name" ILIKE '%psico%'
      AND "academy_id" = 1
    LIMIT 1;

    -- Buscar topic de Ortografía
    SELECT id INTO v_topic_ortografia
    FROM "public"."topic"
    WHERE "topic_name" ILIKE '%ortograf%'
      AND "academy_id" = 1
    LIMIT 1;

    -- Asignar los topics al grupo (si existen)
    IF v_topic_conocimientos IS NOT NULL THEN
      UPDATE "public"."topic"
      SET
        "topic_group_id" = v_group_id,
        "group_order" = 1
      WHERE "id" = v_topic_conocimientos;

      RAISE NOTICE 'Topic de Conocimientos (id: %) asignado al grupo con orden 1', v_topic_conocimientos;
    ELSE
      RAISE NOTICE 'No se encontró topic de Conocimientos';
    END IF;

    IF v_topic_psicos IS NOT NULL THEN
      UPDATE "public"."topic"
      SET
        "topic_group_id" = v_group_id,
        "group_order" = 2
      WHERE "id" = v_topic_psicos;

      RAISE NOTICE 'Topic de Psicotécnicos (id: %) asignado al grupo con orden 2', v_topic_psicos;
    ELSE
      RAISE NOTICE 'No se encontró topic de Psicotécnicos';
    END IF;

    IF v_topic_ortografia IS NOT NULL THEN
      UPDATE "public"."topic"
      SET
        "topic_group_id" = v_group_id,
        "group_order" = 3
      WHERE "id" = v_topic_ortografia;

      RAISE NOTICE 'Topic de Ortografía (id: %) asignado al grupo con orden 3', v_topic_ortografia;
    ELSE
      RAISE NOTICE 'No se encontró topic de Ortografía';
    END IF;

    -- El trigger sync_topic_group_to_topics automáticamente sincronizará
    -- enabled, is_premium y published_at a estos topics

    RAISE NOTICE 'Grupo de examen creado con ID: %', v_group_id;
  ELSE
    RAISE NOTICE 'No se pudo crear el grupo de examen';
  END IF;
END $$;

-- =====================================================
-- 3. Verificar el resultado
-- =====================================================

-- Ver el grupo creado
-- SELECT * FROM topic_groups WHERE name = 'Examen Oficial 2024';

-- Ver los topics del grupo ordenados
-- SELECT
--   t.id,
--   t.topic_name,
--   t.topic_group_id,
--   t.group_order,
--   t.enabled,
--   t.is_premium,
--   t.published_at
-- FROM topic t
-- WHERE t.topic_group_id IS NOT NULL
-- ORDER BY t.topic_group_id, t.group_order;

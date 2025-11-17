-- =====================================================
-- Migration: Validar que todos los topics de un grupo tengan el mismo topic_type
-- Description: Trigger para asegurar consistencia en topic_groups
-- Date: 2025-10-31
-- =====================================================

-- =====================================================
-- Función para validar que todos los topics del grupo tengan el mismo topic_type
-- =====================================================

CREATE OR REPLACE FUNCTION "public"."validate_topic_group_same_type"()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_existing_topic_type_id BIGINT;
  v_new_topic_type_id BIGINT;
  v_group_name TEXT;
BEGIN
  -- Solo validar si el topic tiene un topic_group_id
  IF NEW.topic_group_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- Obtener el topic_type_id del topic que se está insertando/actualizando
  v_new_topic_type_id := NEW.topic_type_id;

  -- Obtener el nombre del grupo para mensajes de error más claros
  SELECT name INTO v_group_name
  FROM topic_groups
  WHERE id = NEW.topic_group_id;

  -- Buscar si ya hay otros topics en este grupo
  SELECT topic_type_id INTO v_existing_topic_type_id
  FROM topic
  WHERE topic_group_id = NEW.topic_group_id
    AND id != COALESCE(NEW.id, -1)  -- Excluir el topic actual si es UPDATE
  LIMIT 1;

  -- Si ya existen topics en el grupo, validar que el tipo sea el mismo
  IF v_existing_topic_type_id IS NOT NULL THEN
    IF v_existing_topic_type_id != v_new_topic_type_id THEN
      RAISE EXCEPTION 'No se puede añadir el topic al grupo "%". Todos los topics de un grupo deben tener el mismo topic_type_id. El grupo ya contiene topics con topic_type_id=%, pero este topic tiene topic_type_id=%',
        v_group_name,
        v_existing_topic_type_id,
        v_new_topic_type_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."validate_topic_group_same_type"() OWNER TO "postgres";

COMMENT ON FUNCTION "public"."validate_topic_group_same_type"() IS
'Valida que todos los topics de un topic_group tengan el mismo topic_type_id';

-- =====================================================
-- Crear trigger en la tabla topic
-- =====================================================

CREATE TRIGGER "trg_validate_topic_group_same_type"
BEFORE INSERT OR UPDATE OF "topic_group_id", "topic_type_id"
ON "public"."topic"
FOR EACH ROW
EXECUTE FUNCTION "public"."validate_topic_group_same_type"();

COMMENT ON TRIGGER "trg_validate_topic_group_same_type" ON "public"."topic" IS
'Trigger que valida que todos los topics de un grupo tengan el mismo topic_type_id';

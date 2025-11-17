-- =====================================================
-- MIGRATION 17: ALLOW NULL SPECIALTY IN MEMBERSHIP LEVELS
-- =====================================================
-- Descripción: Permitir specialty_id NULL en membership_levels
--              para soportar membresías genéricas (Freemium)
-- Fecha: 2025-11-12
-- =====================================================

-- Eliminar la foreign key constraint existente
ALTER TABLE "public"."membership_levels"
  DROP CONSTRAINT IF EXISTS "membership_levels_specialty_id_fkey";

-- Cambiar la columna para permitir NULL
ALTER TABLE "public"."membership_levels"
  ALTER COLUMN "specialty_id" DROP NOT NULL;

-- Volver a crear la foreign key constraint
ALTER TABLE "public"."membership_levels"
  ADD CONSTRAINT "membership_levels_specialty_id_fkey"
  FOREIGN KEY ("specialty_id")
  REFERENCES "public"."specialties"("id")
  ON DELETE CASCADE;

-- Actualizar el comentario
COMMENT ON COLUMN "public"."membership_levels"."specialty_id" IS
  'Especialidad a la que pertenece este nivel de membresía. NULL para membresías genéricas (ej: Freemium).';

-- =====================================================
-- END OF MIGRATION
-- =====================================================

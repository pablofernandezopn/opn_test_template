-- =====================================================
-- MIGRATION 2: INITIAL DATA
-- =====================================================
-- Descripción: Datos iniciales necesarios para el sistema
--              (Academies, Roles, Specialties)
-- Fecha: 2025-11-05
-- =====================================================

-- =====================================================
-- 1. ACADEMIES (Academia OPN por defecto)
-- =====================================================

-- Insert default academy OPN
-- Using ON CONFLICT to make this migration idempotent
INSERT INTO "public"."academies" (
    "id",
    "name",
    "slug",
    "description",
    "is_active",
    "created_at",
    "updated_at"
) VALUES (
    1,
    'Academia OPN',
    'opn',
    'Academia para la preparación de oposiciones',
    true,
    NOW(),
    NOW()
)
ON CONFLICT ("id") DO UPDATE SET
    "name" = EXCLUDED."name",
    "slug" = EXCLUDED."slug",
    "description" = EXCLUDED."description",
    "updated_at" = NOW();

-- Ensure the sequence is updated to avoid conflicts with future inserts
SELECT setval('public.academies_id_seq', (SELECT MAX("id") FROM "public"."academies"));

COMMENT ON TABLE "public"."academies" IS
'Academias o centros de formación. La academia OPN (id=1) es la academia por defecto para nuevos usuarios.';

-- =====================================================
-- 2. ROLES (Roles del sistema)
-- =====================================================

-- Insert default roles
-- Using ON CONFLICT to make this migration idempotent
INSERT INTO "public"."role" (
    "id",
    "name",
    "description",
    "created_at"
) VALUES
    (1, 'Super Admin', 'Super Administrador del sistema', NOW()),
    (2, 'Admin', 'Administrador de una academia', NOW()),
    (3, 'Tutor', 'Tutor/Profesor', NOW()),
    (4, 'User', 'Usuario/Alumno (rol por defecto)', NOW())
ON CONFLICT ("id") DO UPDATE SET
    "name" = EXCLUDED."name",
    "description" = EXCLUDED."description";

-- Ensure the sequence is updated to avoid conflicts with future inserts
SELECT setval('public.role_id_seq', (SELECT MAX("id") FROM "public"."role"));

COMMENT ON TABLE "public"."role" IS
'Roles de usuario en el sistema. El rol User (id=4) es el rol por defecto para nuevos usuarios registrados.';

-- =====================================================
-- 3. SPECIALTIES (Especialidad General por defecto)
-- =====================================================

-- Crear especialidad "General" por defecto para cada academia existente
INSERT INTO "public"."specialties" (
    "academy_id",
    "name",
    "slug",
    "description",
    "is_default",
    "is_active",
    "display_order"
)
SELECT
    a."id",
    'General',
    'general',
    'Especialidad general de ' || a."name",
    true,
    true,
    0
FROM "public"."academies" a
WHERE a."is_active" = true
ON CONFLICT DO NOTHING;

-- =====================================================
-- 4. ACADEMY KPIs (Inicializar KPIs para cada academia)
-- =====================================================

INSERT INTO "public"."academy_kpis" (
    "academy_id",
    "total_users",
    "total_questions",
    "total_tests",
    "total_premium_users",
    "premium_plus_users",
    "total_users_today",
    "new_users_today",
    "total_answers_today",
    "total_flashcard_answers_today",
    "updated_at"
)
SELECT
    a."id",
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    NOW()
FROM "public"."academies" a
ON CONFLICT ("academy_id") DO NOTHING;

-- =====================================================
-- 5. ASIGNAR DATOS EXISTENTES A ESPECIALIDAD GENERAL
-- =====================================================

-- Asignar todos los topics existentes a la especialidad general de su academia
UPDATE "public"."topic" t
SET "specialty_id" = s."id"
FROM "public"."specialties" s
WHERE t."academy_id" = s."academy_id"
  AND s."is_default" = true
  AND t."specialty_id" IS NULL;

-- Asignar todos los usuarios existentes a la especialidad general de su academia
UPDATE "public"."users" u
SET "specialty_id" = s."id"
FROM "public"."specialties" s
WHERE u."academy_id" = s."academy_id"
  AND s."is_default" = true
  AND u."specialty_id" IS NULL;

-- COMMENTED OUT: questions table doesn't have specialty_id column
-- Asignar preguntas existentes a especialidad según su topic
-- UPDATE "public"."questions" q
-- SET "specialty_id" = t."specialty_id"
-- FROM "public"."topic" t
-- WHERE q."topic" = t."id"
--   AND q."specialty_id" IS NULL;

-- COMMENTED OUT: depends on questions.specialty_id which doesn't exist
-- Asignar challenges existentes a especialidad según su pregunta
-- UPDATE "public"."challenge" ch
-- SET "specialty_id" = q."specialty_id"
-- FROM "public"."questions" q
-- WHERE ch."question_id" = q."id"
--   AND ch."specialty_id" IS NULL;

-- =====================================================
-- END OF MIGRATION
-- =====================================================
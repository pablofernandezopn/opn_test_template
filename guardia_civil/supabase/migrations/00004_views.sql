-- =====================================================
-- MIGRATION 4: VIEWS
-- =====================================================
-- Descripción: Vistas para queries complejas y reporting
-- Fecha: 2025-11-05
-- =====================================================

-- =====================================================
-- VIEW 1: CMS Users with Specialty
-- =====================================================
-- Vista que muestra usuarios CMS con información de su especialidad

DROP VIEW IF EXISTS "public"."cms_users_with_specialty";

CREATE OR REPLACE VIEW "public"."cms_users_with_specialty" AS
SELECT
    u.*,
    s."name" AS "specialty_name",
    s."slug" AS "specialty_slug"
FROM
    "public"."cms_users" u
LEFT JOIN
    "public"."specialties" s ON u."specialty_id" = s."id";

COMMENT ON VIEW "public"."cms_users_with_specialty" IS
'Vista de cms_users con información de la especialidad';

-- =====================================================
-- VIEW 2: User OPN Index Current
-- =====================================================
-- Vista que muestra el OPN Index más reciente de cada usuario

CREATE OR REPLACE VIEW "public"."user_opn_index_current" AS
SELECT DISTINCT ON ("user_id")
  "user_id",
  "opn_index",
  "quality_trend_score",
  "recent_activity_score",
  "competitive_score",
  "momentum_score",
  "global_rank",
  "calculated_at"
FROM "public"."user_opn_index_history"
ORDER BY "user_id", "calculated_at" DESC;

COMMENT ON VIEW "public"."user_opn_index_current" IS
'View showing the most recent OPN Index for each user (used for global ranking)';

-- =====================================================
-- END OF MIGRATION
-- =====================================================
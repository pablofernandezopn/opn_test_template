-- =====================================================
-- Migration: Refactor user_tests table
-- Description:
--   1. Remove obsolete columns
--   2. Rename minutes to duration_seconds
-- Date: 2025-11-04
-- =====================================================

-- =====================================================
-- 1. Drop index that uses mock column
-- =====================================================

DROP INDEX IF EXISTS "public"."idx_user_tests_mock_finalized";

-- =====================================================
-- 2. Rename minutes to duration_seconds
-- =====================================================

-- First check if minutes column exists and duration_seconds doesn't
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user_tests'
      AND column_name = 'minutes'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user_tests'
      AND column_name = 'duration_seconds'
  ) THEN
    -- Rename minutes to duration_seconds
    ALTER TABLE "public"."user_tests"
    RENAME COLUMN "minutes" TO "duration_seconds";

    -- Update comment
    COMMENT ON COLUMN "public"."user_tests"."duration_seconds" IS
    'Duration in seconds that the user took to complete the test';
  END IF;
END $$;

-- =====================================================
-- 3. Drop obsolete columns
-- =====================================================

-- Drop columns one by one, checking if they exist first
DO $$
BEGIN
  -- Drop study_mode
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user_tests'
      AND column_name = 'study_mode'
  ) THEN
    ALTER TABLE "public"."user_tests" DROP COLUMN "study_mode";
    RAISE NOTICE 'Dropped column study_mode';
  END IF;

  -- Drop study_white
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user_tests'
      AND column_name = 'study_white'
  ) THEN
    ALTER TABLE "public"."user_tests" DROP COLUMN "study_white";
    RAISE NOTICE 'Dropped column study_white';
  END IF;

  -- Drop study_failed
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user_tests'
      AND column_name = 'study_failed'
  ) THEN
    ALTER TABLE "public"."user_tests" DROP COLUMN "study_failed";
    RAISE NOTICE 'Dropped column study_failed';
  END IF;

  -- Drop mock
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user_tests'
      AND column_name = 'mock'
  ) THEN
    ALTER TABLE "public"."user_tests" DROP COLUMN "mock";
    RAISE NOTICE 'Dropped column mock';
  END IF;

  -- Drop survival
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user_tests'
      AND column_name = 'survival'
  ) THEN
    ALTER TABLE "public"."user_tests" DROP COLUMN "survival";
    RAISE NOTICE 'Dropped column survival';
  END IF;

  -- Drop mark_collection
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user_tests'
      AND column_name = 'mark_collection'
  ) THEN
    ALTER TABLE "public"."user_tests" DROP COLUMN "mark_collection";
    RAISE NOTICE 'Dropped column mark_collection';
  END IF;

  -- Drop difficulty_end
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user_tests'
      AND column_name = 'difficulty_end'
  ) THEN
    ALTER TABLE "public"."user_tests" DROP COLUMN "difficulty_end";
    RAISE NOTICE 'Dropped column difficulty_end';
  END IF;

  -- Drop number_of_lives
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user_tests'
      AND column_name = 'number_of_lives'
  ) THEN
    ALTER TABLE "public"."user_tests" DROP COLUMN "number_of_lives";
    RAISE NOTICE 'Dropped column number_of_lives';
  END IF;
END $$;

-- =====================================================
-- 4. Summary
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'User Tests Refactor Migration completed successfully!';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Changes applied:';
  RAISE NOTICE '  ✓ Renamed minutes → duration_seconds';
  RAISE NOTICE '  ✓ Dropped obsolete columns:';
  RAISE NOTICE '    - study_mode';
  RAISE NOTICE '    - study_white';
  RAISE NOTICE '    - study_failed';
  RAISE NOTICE '    - mock';
  RAISE NOTICE '    - survival';
  RAISE NOTICE '    - mark_collection';
  RAISE NOTICE '    - difficulty_end';
  RAISE NOTICE '    - number_of_lives';
  RAISE NOTICE '========================================';
END $$;
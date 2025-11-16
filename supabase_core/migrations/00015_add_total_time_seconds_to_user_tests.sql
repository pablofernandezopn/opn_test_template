-- ============================================================================
-- Migration: Add total_time_seconds to user_tests
-- Description: Adds a column to track the total time spent on a test in seconds
--              This is needed for the "Continue Later" feature to resume tests
--              with accurate timer information.
-- ============================================================================

-- Add total_time_seconds column to user_tests table
ALTER TABLE "public"."user_tests"
ADD COLUMN IF NOT EXISTS "total_time_seconds" INTEGER DEFAULT 0;

-- Add comment to explain the purpose of this column
COMMENT ON COLUMN "public"."user_tests"."total_time_seconds" IS
'Total time spent on the test in seconds. Used to calculate remaining time when resuming a paused test.';

-- Update existing records to calculate total_time_seconds from time_spent_millis
-- This ensures existing tests have accurate time tracking
UPDATE "public"."user_tests"
SET "total_time_seconds" = COALESCE(FLOOR("time_spent_millis" / 1000.0), 0)
WHERE "total_time_seconds" IS NULL OR "total_time_seconds" = 0;
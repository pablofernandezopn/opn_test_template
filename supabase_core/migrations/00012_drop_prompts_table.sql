-- =====================================================
-- Migration: Drop redundant prompts table
-- =====================================================
-- Description:
-- Eliminates the redundant 'prompts' table since we're using 'system_prompts' instead
-- =====================================================

-- Drop indexes first
DROP INDEX IF EXISTS public.idx_prompts_prompt_for;
DROP INDEX IF EXISTS public.idx_prompts_destination;
DROP INDEX IF EXISTS public.idx_prompts_version;

-- Drop the prompts table
DROP TABLE IF EXISTS public.prompts;

-- =====================================================
-- Migration Complete
-- =====================================================

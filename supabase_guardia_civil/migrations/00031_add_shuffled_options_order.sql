-- =====================================================
-- Migration: Add shuffled_option_ids to user_test_answers
-- Purpose: Store the order in which options were presented to the user
--          to preserve shuffle order when reviewing test history
-- =====================================================

-- Add new column to store the shuffled option IDs order
ALTER TABLE public.user_test_answers
ADD COLUMN shuffled_option_ids JSONB;

-- Add comment explaining the column purpose
COMMENT ON COLUMN public.user_test_answers.shuffled_option_ids IS
'Array de IDs de opciones en el orden en que fueron presentadas al usuario. Permite preservar el orden aleatorio (shuffle) al revisar el test desde el historial. Ejemplo: [3, 1, 4, 2] significa que las opciones se mostraron en ese orden específico.';

-- No need for indexes as this is only for storage/retrieval, not filtering
-- The column is nullable to maintain backward compatibility with existing records
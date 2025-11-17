-- =====================================================
-- Migration: Fix get_user_chat_preferences function
-- =====================================================
-- This fixes the function to return defaults even if:
-- 1. The user doesn't exist in the users table
-- 2. The user has no preferences configured
-- =====================================================

CREATE OR REPLACE FUNCTION public.get_user_chat_preferences(p_user_id BIGINT)
RETURNS TABLE (
  user_id BIGINT,
  model_key TEXT,
  model_display_name TEXT,
  response_length public.response_length,
  max_tokens INTEGER,
  custom_system_prompt TEXT,
  tone public.conversation_tone,
  enable_emojis BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    p_user_id,
    COALESCE(m.model_key, 'gpt-5-mini-2025-08-07') AS model_key,
    COALESCE(m.display_name, 'GPT-5 Mini') AS model_display_name,
    COALESCE(p.response_length, 'normal'::public.response_length) AS response_length,
    COALESCE(p.max_tokens, m.max_tokens, 1500) AS max_tokens,
    p.custom_system_prompt,
    COALESCE(p.tone, 'friendly'::public.conversation_tone) AS tone,
    COALESCE(p.enable_emojis, true) AS enable_emojis
  FROM (SELECT p_user_id AS id) u
  LEFT JOIN public.chat_user_preferences p ON u.id = p.user_id
  LEFT JOIN public.ai_models m ON p.ai_model_id = m.id
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.get_user_chat_preferences(BIGINT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_chat_preferences(BIGINT) TO anon;
GRANT EXECUTE ON FUNCTION public.get_user_chat_preferences(BIGINT) TO service_role;

COMMENT ON FUNCTION public.get_user_chat_preferences(BIGINT) IS
'Returns user chat preferences with defaults. Always returns a row even if user or preferences do not exist.';
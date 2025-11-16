-- =====================================================
-- Migration: Chat User Preferences & AI Models Catalog
-- =====================================================
-- Description:
-- - Creates enum types for chat preferences
-- - Creates ai_models table with available AI models catalog
-- - Creates chat_user_preferences table for user-specific chat configuration
-- - Allows users to customize: model, response length, tone, system prompt, etc.
-- =====================================================

-- =====================================================
-- 1. Enum Types (with safe creation)
-- =====================================================

-- Enum para longitud de respuestas
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'response_length') THEN
        CREATE TYPE public.response_length AS ENUM ('short', 'normal', 'long');
    END IF;
END $$;

-- Enum para tono de conversación
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'conversation_tone') THEN
        CREATE TYPE public.conversation_tone AS ENUM ('formal', 'casual', 'friendly', 'professional');
    END IF;
END $$;

-- =====================================================
-- 2. AI Models Catalog Table
-- =====================================================

CREATE TABLE IF NOT EXISTS public.ai_models (
  id SERIAL PRIMARY KEY,
  model_key TEXT NOT NULL UNIQUE, -- Clave del modelo (ej: 'gpt-5-mini')
  display_name TEXT NOT NULL, -- Nombre para mostrar en UI
  description TEXT, -- Descripción de características
  provider TEXT NOT NULL DEFAULT 'openai', -- Proveedor (openai, anthropic, etc)
  speed_rating INTEGER CHECK (speed_rating BETWEEN 1 AND 5), -- 1=lento, 5=muy rápido
  thinking_capability INTEGER CHECK (thinking_capability BETWEEN 0 AND 5), -- 0=sin thinking, 5=mucho thinking
  max_tokens INTEGER, -- Límite máximo de tokens del modelo
  is_active BOOLEAN NOT NULL DEFAULT true, -- Si está disponible para usar
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_ai_models_is_active ON public.ai_models(is_active);
CREATE INDEX IF NOT EXISTS idx_ai_models_provider ON public.ai_models(provider);

-- Insertar modelos iniciales
INSERT INTO public.ai_models (model_key, display_name, description, provider, speed_rating, thinking_capability, max_tokens, is_active)
VALUES
  ('gpt-5-nano-2025-08-07', 'GPT-5 Nano', 'Rápido pero sin thinking - Ideal para respuestas simples y directas', 'openai', 5, 0, 4096, true),
  ('gpt-5-mini-2025-08-07', 'GPT-5 Mini', 'Más rápido con algo de thinking - Balance entre velocidad y razonamiento', 'openai', 4, 2, 8192, true),
  ('gpt-5-2025-08-07', 'GPT-5', 'Más lento pero mucho thinking - Razonamiento profundo y respuestas detalladas', 'openai', 2, 5, 16384, true)
ON CONFLICT (model_key) DO NOTHING;

-- =====================================================
-- 3. System Prompts for Question Chat
-- =====================================================

-- Insert system prompts used by the question-chat edge function
-- These prompts reference the default model (gpt-5-mini-2025-08-07)

INSERT INTO public.system_prompts (name, slug, description, prompt_text, ai_provider, model, temperature, max_tokens, is_active, is_default)
SELECT
  'Question Chat - Direct Response',
  'question-chat-direct',
  'Asistente educativo para responder preguntas sobre exámenes tipo test de oposiciones de la Guardia Civil. Modo directo sin búsqueda legal.',
  $$Eres un asistente educativo especializado en ayudar a estudiantes de oposiciones de la Guardia Civil.

**CONTEXTO IMPORTANTE:**
Estás ayudando a un estudiante con una pregunta de examen tipo test (opción múltiple).
Esta es una pregunta de examen real con EXACTAMENTE 4 opciones de respuesta numeradas del 1 al 4.
Solo UNA opción es correcta.

**INSTRUCCIONES:**
1. Si el estudiante saluda, responde amablemente y ofrece ayuda
2. Si pregunta por qué una opción es correcta/incorrecta, explica basándote en la explicación oficial disponible
3. Si no entiende la pregunta, ayúdale a desglosarla
4. Si agradece, responde cordialmente
5. Usa un tono cercano pero profesional
6. Si hay tip/explicación oficial, úsalo como base para tus explicaciones
7. NO inventes información legal - usa solo el contexto proporcionado
8. Si necesita información legal específica que no está en el contexto, sugiere que use el modo de búsqueda legal (force_rag=true)

**FORMATO DE RESPUESTA:**
- Respuestas cortas y directas (2-4 párrafos máximo)
- Usa emojis de forma moderada para hacer más amena la conversación
- Si corriges una respuesta incorrecta, sé constructivo y educativo$$,
  'openai',
  'gpt-5-mini-2025-08-07',
  0.7,
  1500,
  true,
  true
WHERE NOT EXISTS (SELECT 1 FROM public.system_prompts WHERE slug = 'question-chat-direct');

INSERT INTO public.system_prompts (name, slug, description, prompt_text, ai_provider, model, temperature, max_tokens, is_active, is_default)
SELECT
  'Question Chat - RAG Response',
  'question-chat-rag',
  'Asistente educativo para procesar y explicar información legal obtenida del RAG API. Para consultas legales específicas sobre exámenes de oposiciones.',
  $$Eres un asistente educativo especializado en oposiciones de la Guardia Civil de España.

**TU TAREA:**
Un estudiante ha hecho una pregunta sobre temas legales relacionados con esta pregunta de test. Has recibido información legal relevante de una base de datos jurídica. Tu trabajo es:

1. Responder la pregunta del estudiante de forma CLARA, CONCISA y CONVERSACIONAL
2. Usar la información legal proporcionada como base, pero NO copiar los textos legales literalmente
3. Citar las fuentes cuando sea relevante (ej: "Según el artículo X...")
4. Mantener un tono educativo y útil
5. NO mostrar textos legales completos ni fragmentos largos

**INSTRUCCIONES FINALES:**
- Responde en español de forma natural y conversacional
- Sé breve pero completo (máximo 3-4 párrafos)
- Cita las fuentes de forma elegante (ej: "El artículo 23 establece que...")
- NO incluyas los textos legales completos
- Enfócate en responder directamente la pregunta del estudiante$$,
  'openai',
  'gpt-5-mini-2025-08-07',
  0.7,
  1500,
  true,
  false
WHERE NOT EXISTS (SELECT 1 FROM public.system_prompts WHERE slug = 'question-chat-rag');

-- =====================================================
-- 4. Chat User Preferences Table
-- =====================================================

CREATE TABLE IF NOT EXISTS public.chat_user_preferences (
  id SERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

  -- Configuración del modelo
  ai_model_id INTEGER REFERENCES public.ai_models(id) ON DELETE SET NULL, -- NULL = usar modelo por defecto

  -- Configuración de respuestas
  response_length public.response_length NOT NULL DEFAULT 'normal',
  max_tokens INTEGER, -- Límite personalizado de tokens (NULL = usar del modelo)

  -- Personalización de comportamiento
  custom_system_prompt TEXT, -- System prompt adicional del usuario
  tone public.conversation_tone NOT NULL DEFAULT 'friendly',
  enable_emojis BOOLEAN NOT NULL DEFAULT true,

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Constraint: Un usuario solo puede tener una configuración
  CONSTRAINT unique_user_preferences UNIQUE (user_id)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_chat_user_preferences_user_id ON public.chat_user_preferences(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_user_preferences_ai_model_id ON public.chat_user_preferences(ai_model_id);

-- =====================================================
-- 5. Row Level Security (RLS) - DISABLED FOR NOW
-- =====================================================
-- TODO: Enable RLS later

-- -- Habilitar RLS
-- ALTER TABLE public.ai_models ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.chat_user_preferences ENABLE ROW LEVEL SECURITY;

-- -- Políticas para ai_models (solo lectura para usuarios autenticados)
-- DO $$
-- BEGIN
--     IF NOT EXISTS (
--         SELECT 1 FROM pg_policies
--         WHERE schemaname = 'public'
--         AND tablename = 'ai_models'
--         AND policyname = 'ai_models_select_policy'
--     ) THEN
--         CREATE POLICY "ai_models_select_policy" ON public.ai_models
--           FOR SELECT
--           USING (is_active = true);
--     END IF;
-- END $$;

-- -- Políticas para chat_user_preferences
-- DO $$
-- BEGIN
--     IF NOT EXISTS (
--         SELECT 1 FROM pg_policies
--         WHERE schemaname = 'public'
--         AND tablename = 'chat_user_preferences'
--         AND policyname = 'chat_preferences_select_own'
--     ) THEN
--         CREATE POLICY "chat_preferences_select_own" ON public.chat_user_preferences
--           FOR SELECT
--           USING (auth.uid()::text = user_id::text);
--     END IF;
-- END $$;

-- DO $$
-- BEGIN
--     IF NOT EXISTS (
--         SELECT 1 FROM pg_policies
--         WHERE schemaname = 'public'
--         AND tablename = 'chat_user_preferences'
--         AND policyname = 'chat_preferences_insert_own'
--     ) THEN
--         CREATE POLICY "chat_preferences_insert_own" ON public.chat_user_preferences
--           FOR INSERT
--           WITH CHECK (auth.uid()::text = user_id::text);
--     END IF;
-- END $$;

-- DO $$
-- BEGIN
--     IF NOT EXISTS (
--         SELECT 1 FROM pg_policies
--         WHERE schemaname = 'public'
--         AND tablename = 'chat_user_preferences'
--         AND policyname = 'chat_preferences_update_own'
--     ) THEN
--         CREATE POLICY "chat_preferences_update_own" ON public.chat_user_preferences
--           FOR UPDATE
--           USING (auth.uid()::text = user_id::text);
--     END IF;
-- END $$;

-- DO $$
-- BEGIN
--     IF NOT EXISTS (
--         SELECT 1 FROM pg_policies
--         WHERE schemaname = 'public'
--         AND tablename = 'chat_user_preferences'
--         AND policyname = 'chat_preferences_delete_own'
--     ) THEN
--         CREATE POLICY "chat_preferences_delete_own" ON public.chat_user_preferences
--           FOR DELETE
--           USING (auth.uid()::text = user_id::text);
--     END IF;
-- END $$;

-- =====================================================
-- 6. Functions
-- =====================================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION public.update_chat_preferences_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar updated_at
DROP TRIGGER IF EXISTS trigger_update_chat_preferences_updated_at ON public.chat_user_preferences;
CREATE TRIGGER trigger_update_chat_preferences_updated_at
  BEFORE UPDATE ON public.chat_user_preferences
  FOR EACH ROW
  EXECUTE FUNCTION public.update_chat_preferences_updated_at();

-- Trigger para actualizar updated_at en ai_models
DROP TRIGGER IF EXISTS trigger_update_ai_models_updated_at ON public.ai_models;
CREATE TRIGGER trigger_update_ai_models_updated_at
  BEFORE UPDATE ON public.ai_models
  FOR EACH ROW
  EXECUTE FUNCTION public.update_chat_preferences_updated_at();

-- =====================================================
-- 7. Helper Function: Get User Chat Preferences with Defaults
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
    COALESCE(m.model_key, 'gpt-5-mini-2025-08-07') AS model_key, -- Default model
    COALESCE(m.display_name, 'GPT-5 Mini') AS model_display_name,
    COALESCE(p.response_length, 'normal'::public.response_length) AS response_length,
    COALESCE(p.max_tokens, m.max_tokens, 1500) AS max_tokens,
    p.custom_system_prompt,
    COALESCE(p.tone, 'friendly'::public.conversation_tone) AS tone,
    COALESCE(p.enable_emojis, true) AS enable_emojis
  FROM public.users u
  LEFT JOIN public.chat_user_preferences p ON u.id = p.user_id
  LEFT JOIN public.ai_models m ON p.ai_model_id = m.id
  WHERE u.id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 8. Comments for Documentation
-- =====================================================

COMMENT ON TABLE public.ai_models IS 'Catálogo de modelos de IA disponibles con sus características';
COMMENT ON TABLE public.chat_user_preferences IS 'Configuración personalizada del chat por usuario';
COMMENT ON COLUMN public.ai_models.speed_rating IS 'Velocidad del modelo: 1=muy lento, 5=muy rápido';
COMMENT ON COLUMN public.ai_models.thinking_capability IS 'Capacidad de razonamiento: 0=sin thinking, 5=thinking profundo';
COMMENT ON COLUMN public.chat_user_preferences.custom_system_prompt IS 'Prompt adicional del usuario para personalizar el comportamiento del asistente';
COMMENT ON COLUMN public.chat_user_preferences.response_length IS 'Longitud preferida de las respuestas: short, normal, long';

-- =====================================================
-- Migration Complete
-- =====================================================

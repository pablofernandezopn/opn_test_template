-- =====================================================
-- MIGRATION 21: FIX SURVIVAL SESSIONS USER FOREIGN KEY
-- =====================================================
-- Descripción: Corrige la foreign key de user_id en survival_sessions
--              para apuntar a public.users en lugar de public.cms_users
-- Fecha: 2025-11-13
-- =====================================================

-- Primero, eliminar el constraint incorrecto
ALTER TABLE public.survival_sessions
DROP CONSTRAINT IF EXISTS fk_survival_sessions_user;

-- Crear el constraint correcto apuntando a public.users
ALTER TABLE public.survival_sessions
ADD CONSTRAINT fk_survival_sessions_user
    FOREIGN KEY (user_id)
    REFERENCES public.users(id)
    ON DELETE CASCADE;

-- Comentario
COMMENT ON CONSTRAINT fk_survival_sessions_user ON public.survival_sessions
IS 'Foreign key corregida para apuntar a public.users en lugar de public.cms_users';
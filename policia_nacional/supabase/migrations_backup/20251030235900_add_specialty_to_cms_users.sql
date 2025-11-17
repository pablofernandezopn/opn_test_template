-- =====================================================
-- AÑADIR COLUMNA SPECIALTY_ID A CMS_USERS
-- =====================================================

-- Agregar columna specialty_id a cms_users
ALTER TABLE public.cms_users
ADD COLUMN IF NOT EXISTS specialty_id BIGINT;

-- Agregar foreign key constraint
ALTER TABLE public.cms_users
ADD CONSTRAINT fk_cms_users_specialty
FOREIGN KEY (specialty_id)
REFERENCES public.specialties(id)
ON DELETE SET NULL;

-- Crear índice para mejorar performance
CREATE INDEX IF NOT EXISTS idx_cms_users_specialty_id ON public.cms_users(specialty_id);
CREATE INDEX IF NOT EXISTS idx_cms_users_academy_specialty ON public.cms_users(academy_id, specialty_id);

-- Comentario de la columna
COMMENT ON COLUMN public.cms_users.specialty_id IS 'Especialidad del usuario CMS. NULL = sin especialidad asignada';

-- =====================================================
-- INSERTAR ESPECIALIDAD POR DEFECTO
-- =====================================================

-- Insertar una especialidad "Básica" por defecto para cada academia existente
-- Esto evita errores cuando no hay especialidades disponibles
INSERT INTO public.specialties (academy_id, name, slug, description, display_order, is_active, is_default)
SELECT
    id as academy_id,
    'Básica' as name,
    'basica' as slug,
    'Especialidad básica para acceso general al contenido' as description,
    0 as display_order,
    true as is_active,
    true as is_default
FROM public.academies
WHERE NOT EXISTS (
    SELECT 1 FROM public.specialties
    WHERE specialties.academy_id = academies.id
    AND specialties.is_default = true
)
ON CONFLICT DO NOTHING;

-- Log de especialidades insertadas
DO $$
DECLARE
    inserted_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO inserted_count
    FROM public.specialties
    WHERE name = 'Básica';

    RAISE NOTICE 'Especialidades "Básica" disponibles: %', inserted_count;
END $$;

-- =====================================================
-- CREAR VISTA CON EL NOMBRE DE LA ESPECIALIDAD
-- =====================================================

-- Eliminar vista si existe (para recrearla)
DROP VIEW IF EXISTS public.cms_users_with_specialty;

-- Crear vista que incluye el nombre de la especialidad
CREATE OR REPLACE VIEW public.cms_users_with_specialty AS
SELECT
    u.*,
    s.name AS specialty_name,
    s.slug AS specialty_slug,
    s.color_hex AS specialty_color
FROM
    public.cms_users u
LEFT JOIN
    public.specialties s ON u.specialty_id = s.id;

-- Comentario de la vista
COMMENT ON VIEW public.cms_users_with_specialty IS 'Vista de cms_users con información de la especialidad';

-- =====================================================
-- FUNCIÓN PARA ASIGNAR ESPECIALIDAD POR DEFECTO
-- =====================================================

-- Función que asigna automáticamente la especialidad por defecto de la academia
CREATE OR REPLACE FUNCTION public.assign_default_specialty_to_cms_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    default_specialty_id BIGINT;
BEGIN
    -- Si no tiene specialty_id asignado pero sí academy_id
    IF NEW.specialty_id IS NULL AND NEW.academy_id IS NOT NULL THEN
        -- Buscar la especialidad por defecto de la academia
        SELECT id INTO default_specialty_id
        FROM public.specialties
        WHERE academy_id = NEW.academy_id
          AND is_default = true
          AND is_active = true
        LIMIT 1;

        -- Asignar la especialidad por defecto si existe
        IF default_specialty_id IS NOT NULL THEN
            NEW.specialty_id := default_specialty_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

-- Trigger para asignar especialidad por defecto en INSERT
DROP TRIGGER IF EXISTS trigger_assign_default_specialty_cms_user ON public.cms_users;
CREATE TRIGGER trigger_assign_default_specialty_cms_user
    BEFORE INSERT ON public.cms_users
    FOR EACH ROW
    EXECUTE FUNCTION public.assign_default_specialty_to_cms_user();

-- =====================================================
-- MIGRAR DATOS EXISTENTES (OPCIONAL)
-- =====================================================

-- Asignar especialidad por defecto a usuarios que no tienen specialty_id
-- (solo si tienen academy_id)
UPDATE public.cms_users u
SET specialty_id = s.id
FROM public.specialties s
WHERE u.specialty_id IS NULL
  AND u.academy_id IS NOT NULL
  AND s.academy_id = u.academy_id
  AND s.is_default = true
  AND s.is_active = true;

-- Log de la migración
DO $$
DECLARE
    updated_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO updated_count
    FROM public.cms_users
    WHERE specialty_id IS NOT NULL;

    RAISE NOTICE 'Migración completada. % usuarios con especialidad asignada', updated_count;
END $$;
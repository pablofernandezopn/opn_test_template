-- Desactivar RLS temporalmente en survival_sessions
-- El usuario configurará las políticas correctas más tarde

-- Verificar si la tabla existe antes de modificar RLS
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_tables
    WHERE schemaname = 'public'
    AND tablename = 'survival_sessions'
  ) THEN
    ALTER TABLE public.survival_sessions DISABLE ROW LEVEL SECURITY;

    COMMENT ON TABLE public.survival_sessions IS
    'Tabla de sesiones de modo supervivencia. RLS desactivado temporalmente para desarrollo.';
  END IF;
END $$;
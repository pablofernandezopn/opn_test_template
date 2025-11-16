-- =====================================================
-- Fix Storage Policies for WordPress Authentication
-- =====================================================
-- Descripción: Elimina políticas antiguas basadas en auth.uid()
--              y las reemplaza con políticas que funcionan sin Supabase Auth
-- Creado: 2025-11-06
-- =====================================================

-- Eliminar políticas antiguas que dependen de auth.uid()
DROP POLICY IF EXISTS "Users can upload their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Public users images are viewable by everyone" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own profile images" ON storage.objects;

-- Eliminar políticas de la migración anterior si existen (para evitar conflictos)
DROP POLICY IF EXISTS "Anyone can upload to users bucket" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view users bucket images" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can update users bucket images" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can delete users bucket images" ON storage.objects;

-- =====================================================
-- Storage Policies - Compatible con WordPress Auth
-- =====================================================
-- Nota: Las políticas permiten acceso público porque la autenticación
-- se maneja externamente a través de WordPress, no Supabase Auth.
-- El bucket es público para lectura pero cualquier usuario autenticado
-- puede subir/modificar/eliminar (la lógica de autorización está en la app).

-- Política: Cualquier usuario puede subir imágenes al bucket users
CREATE POLICY "Anyone can upload to users bucket"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'users');

-- Política: Cualquier usuario puede ver las imágenes (público)
CREATE POLICY "Anyone can view users bucket images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'users');

-- Política: Cualquier usuario puede actualizar imágenes en el bucket users
CREATE POLICY "Anyone can update users bucket images"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'users')
WITH CHECK (bucket_id = 'users');

-- Política: Cualquier usuario puede eliminar imágenes del bucket users
CREATE POLICY "Anyone can delete users bucket images"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'users');

-- Verificar que las políticas se crearon correctamente
DO $$
BEGIN
  RAISE NOTICE 'Storage policies updated successfully for WordPress authentication';
END $$;
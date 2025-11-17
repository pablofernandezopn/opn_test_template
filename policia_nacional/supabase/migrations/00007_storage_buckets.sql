-- =====================================================
-- Storage Buckets Setup
-- =====================================================
-- Descripción: Crea los buckets necesarios para almacenar archivos
-- Creado: 2025-11-06
-- =====================================================

-- Crear bucket para imágenes de perfil de usuarios
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'users',
  'users',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];

-- =====================================================
-- Storage Policies
-- =====================================================
-- Nota: Las políticas permiten acceso público porque la autenticación
-- se maneja externamente a través de WordPress, no Supabase Auth.

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
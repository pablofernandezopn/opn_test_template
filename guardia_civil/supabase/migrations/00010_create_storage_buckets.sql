-- =====================================================
-- STORAGE BUCKETS
-- =====================================================
-- Descripción: Creación de buckets de almacenamiento públicos
-- =====================================================

-- Bucket para avatares y archivos de usuarios
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'users',
    'users',
    true,
    5242880, -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO NOTHING;

-- Bucket para imágenes de topics
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'topics',
    'topics',
    true,
    10485760, -- 10MB limit
    ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/webp', 'image/svg+xml', 'audio/mpeg', 'audio/wav', 'audio/mp3']
)
ON CONFLICT (id) DO NOTHING;

-- Bucket para imágenes de especialidades
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'specialties',
    'specialties',
    true,
    5242880, -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/webp', 'image/svg+xml']
)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- POLÍTICAS DE STORAGE (PUBLIC ACCESS)
-- =====================================================

-- Políticas para bucket 'users'
CREATE POLICY "Public read access for users bucket"
ON storage.objects FOR SELECT
USING (bucket_id = 'users');

CREATE POLICY "Public insert access for users bucket"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'users');

CREATE POLICY "Public update access for users bucket"
ON storage.objects FOR UPDATE
USING (bucket_id = 'users');

CREATE POLICY "Public delete access for users bucket"
ON storage.objects FOR DELETE
USING (bucket_id = 'users');

-- Políticas para bucket 'topics'
CREATE POLICY "Public read access for topics bucket"
ON storage.objects FOR SELECT
USING (bucket_id = 'topics');

CREATE POLICY "Public insert access for topics bucket"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'topics');

CREATE POLICY "Public update access for topics bucket"
ON storage.objects FOR UPDATE
USING (bucket_id = 'topics');

CREATE POLICY "Public delete access for topics bucket"
ON storage.objects FOR DELETE
USING (bucket_id = 'topics');

-- Políticas para bucket 'specialties'
CREATE POLICY "Public read access for specialties bucket"
ON storage.objects FOR SELECT
USING (bucket_id = 'specialties');

CREATE POLICY "Public insert access for specialties bucket"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'specialties');

CREATE POLICY "Public update access for specialties bucket"
ON storage.objects FOR UPDATE
USING (bucket_id = 'specialties');

CREATE POLICY "Public delete access for specialties bucket"
ON storage.objects FOR DELETE
USING (bucket_id = 'specialties');

-- =====================================================
-- END OF STORAGE BUCKETS SETUP
-- =====================================================
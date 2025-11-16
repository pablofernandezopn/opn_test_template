# Image Picker & Upload Component

Componente reutilizable para seleccionar, comprimir y subir imágenes a Supabase Storage.

## Características

- Selección de imagen desde galería o cámara
- Compresión automática de imágenes según el tipo
- Subida automática a Supabase Storage
- Dos tipos de imágenes: **perfil** y **test**
- UI con popup/dialog para mejor experiencia de usuario
- Manejo de errores y estados de carga
- Logging completo para debugging

## Configuración Requerida en Supabase

### 1. Crear los buckets de Storage

En Supabase Dashboard > Storage, crea dos buckets públicos:

```sql
-- Bucket para imágenes de perfil (avatares)
INSERT INTO storage.buckets (id, name, public)
VALUES ('cms_profile_avatar', 'cms_profile_avatar', true);

-- Bucket para imágenes de tests
INSERT INTO storage.buckets (id, name, public)
VALUES ('test_images', 'test_images', true);
```

### 2. Configurar políticas de acceso (RLS)

```sql
-- Política para SUBIR imágenes de perfil (solo usuarios autenticados)
CREATE POLICY "Users can upload their profile images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'cms_profile_avatar');

-- Política para LEER imágenes de perfil (público)
CREATE POLICY "Anyone can view profile images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'cms_profile_avatar');

-- Política para ACTUALIZAR imágenes de perfil (solo usuarios autenticados)
CREATE POLICY "Users can update their profile images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'cms_profile_avatar');

-- Política para ELIMINAR imágenes de perfil (solo usuarios autenticados)
CREATE POLICY "Users can delete their profile images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'cms_profile_avatar');

-- Repetir las mismas políticas para test_images
CREATE POLICY "Users can upload test images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'test_images');

CREATE POLICY "Anyone can view test images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'test_images');

CREATE POLICY "Users can update test images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'test_images');

CREATE POLICY "Users can delete test images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'test_images');
```

## Uso

### Ejemplo Básico - Usando el Dialog (Recomendado)

```dart
import 'package:opn_test_guardia_civil_cms/app/config/widgets/pickImage/pick_image.dart';

// En tu widget:
Future<void> _uploadProfileImage() async {
  // Generar nombre único para el archivo
  final userId = 'user_123'; // ID del usuario actual
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final fileName = '${userId}_$timestamp';

  // Mostrar el dialog y esperar el resultado
  final String? imageUrl = await showImagePickerDialog(
    context: context,
    type: ImageUploadType.profile,
    fileName: fileName,
    title: 'Subir foto de perfil',
    subtitle: 'Selecciona una imagen desde tu galería o toma una foto',
  );

  if (imageUrl != null) {
    // La imagen se subió exitosamente
    print('Imagen subida: $imageUrl');
    // Guardar la URL en tu base de datos
    // await updateUserProfileImage(imageUrl);
  } else {
    // El usuario canceló
    print('Usuario canceló la subida');
  }
}

// Llamar la función desde un botón
ElevatedButton(
  onPressed: _uploadProfileImage,
  child: Text('Cambiar foto de perfil'),
)
```

### Ejemplo - Subir Imagen de Test

```dart
Future<void> _uploadTestImage(int questionId) async {
  final fileName = 'test_${questionId}_${DateTime.now().millisecondsSinceEpoch}';

  final String? imageUrl = await showImagePickerDialog(
    context: context,
    type: ImageUploadType.test,
    fileName: fileName,
    title: 'Subir imagen de pregunta',
  );

  if (imageUrl != null) {
    print('Imagen de test subida: $imageUrl');
    // Guardar la URL en la tabla de questions
    // await updateQuestionImage(questionId, imageUrl);
  }
}
```

### Ejemplo Avanzado - Usando el Repository Directamente

Si necesitas más control, puedes usar el repository directamente:

```dart
import 'package:get_it/get_it.dart';
import 'package:opn_test_guardia_civil_cms/app/config/widgets/pickImage/pick_image.dart';

class MyWidget extends StatelessWidget {
  final ImageUploadRepository _repository = GetIt.instance<ImageUploadRepository>();

  Future<void> _customUpload() async {
    try {
      // 1. Seleccionar imagen
      final imageFile = await _repository.pickImageFromGallery();
      if (imageFile == null) return; // Usuario canceló

      // 2. Comprimir imagen
      final compressedBytes = await _repository.compressImage(
        imageFile,
        ImageUploadType.profile,
      );

      // 3. Subir a Supabase
      final imageUrl = await _repository.uploadImage(
        compressedBytes,
        ImageUploadType.profile,
        'custom_file_name',
      );

      print('Imagen subida: $imageUrl');
    } catch (e) {
      print('Error: $e');
    }
  }
}
```

### Ejemplo - Función Todo en Uno (sin Dialog)

```dart
final repository = GetIt.instance<ImageUploadRepository>();

// Desde galería
final imageUrl = await repository.pickCompressAndUploadFromGallery(
  ImageUploadType.profile,
  'user_123_${DateTime.now().millisecondsSinceEpoch}',
);

// Desde cámara
final imageUrl2 = await repository.pickCompressAndUploadFromCamera(
  ImageUploadType.test,
  'test_456_${DateTime.now().millisecondsSinceEpoch}',
);
```

### Ejemplo - Eliminar Imagen

```dart
final repository = GetIt.instance<ImageUploadRepository>();

try {
  await repository.deleteImage(
    'https://xxx.supabase.co/storage/v1/object/public/cms_profile_avatar/user_123.jpg',
    ImageUploadType.profile,
  );
  print('Imagen eliminada');
} catch (e) {
  print('Error al eliminar: $e');
}
```

## Tipos de Imagen

### `ImageUploadType.profile`
- **Bucket:** `cms_profile_avatar`
- **Dimensiones:** 400x400px
- **Calidad:** 85%
- **Uso:** Fotos de perfil de usuario

### `ImageUploadType.test`
- **Bucket:** `test_images`
- **Dimensiones:** 1200x800px
- **Calidad:** 90%
- **Uso:** Imágenes de preguntas y tests

## Permisos Necesarios

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a tu cámara para tomar fotos de perfil</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a tu galería para seleccionar fotos</string>
```

## Manejo de Errores

El componente maneja automáticamente los siguientes errores:

- Usuario cancela la selección → retorna `null`
- Error al acceder a galería/cámara → muestra mensaje de permisos
- Error al comprimir imagen → muestra mensaje de imagen corrupta
- Error al subir a Supabase → muestra mensaje de conexión

Todos los errores se registran en el logger para debugging.

## Estructura de Archivos

```
lib/app/config/widgets/pickImage/
├── image_upload_type.dart          # Enum con tipos de imagen
├── image_upload_repository.dart    # Lógica de negocio
├── image_picker_dialog.dart        # Widget del popup
├── pick_image.dart                 # Exportaciones
└── README.md                       # Esta documentación
```

## Buckets Utilizados

- **cms_profile_avatar**: Para imágenes de perfil de usuarios del CMS
- **test_images**: Para imágenes de preguntas y tests

## Dependencias Utilizadas

- `image_picker` - Selección de imágenes
- `image` - Compresión y procesamiento de imágenes (multiplataforma)
- `supabase_flutter` - Subida a Supabase Storage
- `get_it` - Inyección de dependencias

## Notas Importantes

1. **Nombres de archivo únicos**: Siempre usa timestamps o IDs únicos en los nombres de archivo para evitar colisiones.

2. **Manejo de URLs antiguas**: Si un usuario sube una nueva imagen, considera eliminar la anterior:

```dart
// Eliminar imagen antigua antes de subir nueva
if (oldImageUrl != null) {
  await repository.deleteImage(oldImageUrl, ImageUploadType.profile);
}

// Subir nueva imagen
final newImageUrl = await showImagePickerDialog(...);
```

3. **Testing en iOS Simulator**: La cámara no funciona en el simulador, solo en dispositivos físicos.

4. **Tamaño máximo**: Supabase tiene un límite de 50MB por archivo por defecto. La compresión ayuda a mantenerse muy por debajo de este límite.

## Troubleshooting

### "Error al acceder a la galería"
- Verifica que los permisos estén configurados en AndroidManifest.xml / Info.plist
- En Android 13+, usa `READ_MEDIA_IMAGES` en vez de `READ_EXTERNAL_STORAGE`

### "Error al subir imagen a Supabase"
- Verifica que los buckets existan en Supabase Storage
- Verifica que las políticas RLS permitan la subida
- Verifica la conexión a internet

### "La imagen se ve pixelada"
- Ajusta las dimensiones en `ImageUploadType` si necesitas mayor resolución
- Aumenta el `quality` (0-100) en el enum

## Futuras Mejoras

- [ ] Soporte para múltiples imágenes
- [ ] Crop/recorte de imagen antes de subir
- [ ] Progress bar durante la subida
- [ ] Caché local de imágenes
- [ ] Soporte para videos

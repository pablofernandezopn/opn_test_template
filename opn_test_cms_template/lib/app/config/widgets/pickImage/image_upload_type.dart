/// Tipo de imagen a subir que determina el bucket y las dimensiones de compresión
enum ImageUploadType {
  /// Imagen de perfil de usuario (avatar)
  /// Bucket: 'users'
  /// Dimensiones: 400x400px
  /// Ejemplo de uso: folderPath: 'user_{id}', fileName: 'avatar'
  /// Resultado: users/user_{id}/avatar.jpg
  profile('users', 400, 400),

  /// Imagen para test/pregunta
  /// Bucket: 'topics'
  /// Dimensiones: 1200x800px
  /// Ejemplo de uso: folderPath: 'topic_{id}/question_{id}', fileName: 'question_image'
  /// Resultado: topics/topic_{id}/question_{id}/question_image.jpg
  test('topics', 1200, 800),

  /// Imagen de especialidad
  /// Bucket: 'specialties'
  /// Dimensiones: 400x400px
  /// Ejemplo de uso: folderPath: 'specialty_{id}', fileName: 'icon'
  /// Resultado: specialties/specialty_{id}/icon.jpg
  specialty('specialties', 400, 400);

  const ImageUploadType(this.bucketName, this.maxWidth, this.maxHeight);

  /// Nombre del bucket en Supabase Storage
  final String bucketName;

  /// Ancho máximo de la imagen comprimida
  final int maxWidth;

  /// Alto máximo de la imagen comprimida
  final int maxHeight;

  /// Calidad de compresión JPEG (0-100)
  int get quality => this == ImageUploadType.profile ? 85 : 90;
}

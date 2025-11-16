import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../bootstrap.dart';
import 'image_upload_type.dart';

/// Repositorio para manejar la subida de imágenes a Supabase Storage.
///
/// Funcionalidades:
/// - Selección de imagen desde galería o cámara
/// - Compresión automática según el tipo de imagen
/// - Subida a Supabase Storage en el bucket correspondiente
/// - Generación de URL pública de la imagen
class ImageUploadRepository {
  ImageUploadRepository();

  final ImagePicker _picker = ImagePicker();

  /// Obtiene el cliente de Supabase
  supa.SupabaseClient get _client => supa.Supabase.instance.client;

  // ============================================
  // SELECCIÓN DE IMAGEN
  // ============================================

  /// Selecciona una imagen desde la galería.
  ///
  /// Retorna el archivo de imagen seleccionado o null si el usuario cancela.
  Future<XFile?> pickImageFromGallery() async {
    try {
      logger.info('Opening gallery picker');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 4000,
        maxHeight: 4000,
      );

      if (image != null) {
        logger.info('Image selected from gallery: ${image.path}');
      } else {
        logger.info('User cancelled image selection');
      }

      return image;
    } catch (e, st) {
      logger.error('Error picking image from gallery: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al seleccionar imagen de la galería');
    }
  }

  /// Selecciona una imagen desde la cámara.
  ///
  /// Retorna el archivo de imagen capturado o null si el usuario cancela.
  Future<XFile?> pickImageFromCamera() async {
    try {
      logger.info('Opening camera');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 4000,
        maxHeight: 4000,
      );

      if (image != null) {
        logger.info('Image captured from camera: ${image.path}');
      } else {
        logger.info('User cancelled camera');
      }

      return image;
    } catch (e, st) {
      logger.error('Error capturing image from camera: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al capturar imagen desde la cámara');
    }
  }

  // ============================================
  // COMPRESIÓN
  // ============================================

  /// Comprime una imagen según el tipo especificado.
  ///
  /// [imageFile] - Archivo de imagen original
  /// [type] - Tipo de imagen (perfil o test) que determina las dimensiones
  ///
  /// Retorna los bytes de la imagen comprimida en formato JPEG.
  Future<Uint8List> compressImage(
    XFile imageFile,
    ImageUploadType type,
  ) async {
    try {
      logger.info('Compressing image: ${imageFile.path}');
      logger.info(
          'Target dimensions: ${type.maxWidth}x${type.maxHeight}, quality: ${type.quality}');

      // Leer el archivo de imagen
      final bytes = await File(imageFile.path).readAsBytes();
      final originalSize = bytes.length;

      // Decodificar la imagen
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Calcular las nuevas dimensiones manteniendo el aspect ratio
      int targetWidth = type.maxWidth;
      int targetHeight = type.maxHeight;

      // Si la imagen es más grande que el target, redimensionar
      if (image.width > targetWidth || image.height > targetHeight) {
        // Calcular el ratio para mantener proporciones
        final widthRatio = targetWidth / image.width;
        final heightRatio = targetHeight / image.height;
        final ratio = widthRatio < heightRatio ? widthRatio : heightRatio;

        targetWidth = (image.width * ratio).round();
        targetHeight = (image.height * ratio).round();

        // Redimensionar la imagen con interpolación de alta calidad
        image = img.copyResize(
          image,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.linear,
        );
      }

      // Codificar a JPEG con la calidad especificada
      final compressedBytes = Uint8List.fromList(
        img.encodeJpg(image, quality: type.quality),
      );

      final compressedSize = compressedBytes.length;
      final compressionRatio =
          ((1 - compressedSize / originalSize) * 100).toStringAsFixed(1);

      logger.info('Image compressed successfully');
      logger.info(
          'Original size: ${(originalSize / 1024).toStringAsFixed(2)} KB');
      logger.info(
          'Compressed size: ${(compressedSize / 1024).toStringAsFixed(2)} KB');
      logger.info('Compression ratio: $compressionRatio%');
      logger.info('Final dimensions: ${image.width}x${image.height}');

      return compressedBytes;
    } catch (e, st) {
      logger.error('Error compressing image: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al comprimir la imagen');
    }
  }

  // ============================================
  // SUBIDA A SUPABASE STORAGE
  // ============================================

  /// Sube una imagen comprimida a Supabase Storage.
  ///
  /// [imageBytes] - Bytes de la imagen comprimida
  /// [type] - Tipo de imagen (determina el bucket)
  /// [fileName] - Nombre del archivo (sin extensión, se agrega .jpg automáticamente)
  /// [folderPath] - Ruta de carpetas opcional DENTRO del bucket (ej: 'topic_1/question_5')
  ///                IMPORTANTE: NO incluir el nombre del bucket en folderPath.
  ///                Si no se proporciona, se sube directamente en la raíz del bucket.
  ///                Las carpetas se crean automáticamente si no existen.
  ///
  /// Retorna la URL pública de la imagen subida.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// // Sin carpetas (raíz del bucket)
  /// final url = await repository.uploadImage(
  ///   compressedBytes,
  ///   ImageUploadType.profile,
  ///   'user_avatar',
  /// );
  /// // Resultado: users/user_avatar.jpg
  ///
  /// // Con estructura de carpetas (bucket: 'topics')
  /// final url = await repository.uploadImage(
  ///   compressedBytes,
  ///   ImageUploadType.test,
  ///   'question_image',
  ///   folderPath: 'topic_1/question_5',  // SIN 'topics/' al inicio
  /// );
  /// // Resultado: topics/topic_1/question_5/question_image.jpg
  /// ```
  Future<String> uploadImage(
    Uint8List imageBytes,
    ImageUploadType type,
    String fileName, {
    String? folderPath,
  }) async {
    try {
      logger.info('Uploading image to bucket: ${type.bucketName}');

      // Construir la ruta completa del archivo
      final String filePath = folderPath != null && folderPath.isNotEmpty
          ? '$folderPath/$fileName.jpg'
          : '$fileName.jpg';

      logger.info('File path: $filePath');

      // Subir a Supabase Storage
      await _client.storage.from(type.bucketName).uploadBinary(
            filePath,
            imageBytes,
            fileOptions: const supa.FileOptions(
              contentType: 'image/jpeg',
              upsert: true, // Reemplazar si ya existe
            ),
          );

      // Obtener URL pública con cache-buster para forzar recarga en Flutter
      final String basePublicUrl =
          _client.storage.from(type.bucketName).getPublicUrl(filePath);

      // Agregar timestamp como query parameter para evitar problemas de cache
      final String publicUrl =
          '$basePublicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      logger.info('Image uploaded successfully');
      // logger.info('Public URL: $publicUrl');

      return publicUrl;
    } on supa.StorageException catch (e) {
      logger.error('Supabase Storage error: ${e.message}');
      throw Exception('Error al subir imagen a Supabase: ${e.message}');
    } catch (e, st) {
      logger.error('Unexpected error uploading image: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al subir imagen');
    }
  }

  /// Elimina una imagen de Supabase Storage.
  ///
  /// [imageUrl] - URL completa de la imagen a eliminar
  /// [type] - Tipo de imagen (determina el bucket)
  ///
  /// Ejemplo:
  /// ```dart
  /// // Eliminar imagen en la raíz del bucket
  /// await repository.deleteImage(
  ///   'https://xxx.supabase.co/storage/v1/object/public/users/user_avatar.jpg',
  ///   ImageUploadType.profile,
  /// );
  ///
  /// // Eliminar imagen en carpetas anidadas
  /// await repository.deleteImage(
  ///   'https://xxx.supabase.co/storage/v1/object/public/topics/topic_1/question_5/image.jpg',
  ///   ImageUploadType.test,
  /// );
  /// ```
  Future<void> deleteImage(String imageUrl, ImageUploadType type) async {
    try {
      // Extraer la ruta del archivo de la URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // La estructura es: /storage/v1/object/public/{bucket}/{path}/{fileName}
      // Necesitamos encontrar el índice donde empieza el bucket
      if (pathSegments.length < 5) {
        throw Exception('URL de imagen inválida');
      }

      // Encontrar el índice del bucket en los segmentos
      final bucketIndex = pathSegments.indexOf(type.bucketName);
      if (bucketIndex == -1) {
        throw Exception('Bucket no encontrado en la URL');
      }

      // Obtener todos los segmentos después del bucket (incluye carpetas y archivo)
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      logger.info('Deleting image from bucket: ${type.bucketName}');
      logger.info('File path: $filePath');

      await _client.storage.from(type.bucketName).remove([filePath]);

      logger.info('Image deleted successfully');
    } on supa.StorageException catch (e) {
      logger.error('Supabase Storage error deleting image: ${e.message}');
      throw Exception('Error al eliminar imagen: ${e.message}');
    } catch (e, st) {
      logger.error('Unexpected error deleting image: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al eliminar imagen');
    }
  }

  // ============================================
  // FUNCIONES DE CONVENIENCIA (TODO EN UNO)
  // ============================================

  /// Proceso completo: selecciona, comprime y sube una imagen desde la galería.
  ///
  /// [type] - Tipo de imagen (perfil o test)
  /// [fileName] - Nombre del archivo sin extensión
  /// [folderPath] - Ruta de carpetas opcional DENTRO del bucket (ej: 'topic_1/question_5')
  ///                IMPORTANTE: NO incluir el nombre del bucket en folderPath.
  ///
  /// Retorna la URL pública de la imagen subida o null si el usuario cancela.
  Future<String?> pickCompressAndUploadFromGallery(
    ImageUploadType type,
    String fileName, {
    String? folderPath,
  }) async {
    try {
      // 1. Seleccionar imagen
      final XFile? imageFile = await pickImageFromGallery();
      if (imageFile == null) return null;

      // 2. Comprimir imagen
      final Uint8List compressedBytes = await compressImage(imageFile, type);

      // 3. Subir a Supabase
      final String publicUrl = await uploadImage(
        compressedBytes,
        type,
        fileName,
        folderPath: folderPath,
      );

      return publicUrl;
    } catch (e) {
      logger.error('Error in complete upload process: $e');
      rethrow;
    }
  }

  /// Proceso completo: captura, comprime y sube una imagen desde la cámara.
  ///
  /// [type] - Tipo de imagen (perfil o test)
  /// [fileName] - Nombre del archivo sin extensión
  /// [folderPath] - Ruta de carpetas opcional DENTRO del bucket (ej: 'topic_1/question_5')
  ///                IMPORTANTE: NO incluir el nombre del bucket en folderPath.
  ///
  /// Retorna la URL pública de la imagen subida o null si el usuario cancela.
  Future<String?> pickCompressAndUploadFromCamera(
    ImageUploadType type,
    String fileName, {
    String? folderPath,
  }) async {
    try {
      // 1. Capturar imagen
      final XFile? imageFile = await pickImageFromCamera();
      if (imageFile == null) return null;

      // 2. Comprimir imagen
      final Uint8List compressedBytes = await compressImage(imageFile, type);

      // 3. Subir a Supabase
      final String publicUrl = await uploadImage(
        compressedBytes,
        type,
        fileName,
        folderPath: folderPath,
      );

      return publicUrl;
    } catch (e) {
      logger.error('Error in complete upload process from camera: $e');
      rethrow;
    }
  }
}

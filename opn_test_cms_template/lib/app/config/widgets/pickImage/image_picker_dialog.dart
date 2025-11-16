import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../bootstrap.dart';
import 'image_upload_repository.dart';
import 'image_upload_type.dart';

/// Dialog para seleccionar y subir imágenes.
///
/// Muestra un popup con opciones para:
/// - Seleccionar imagen de la galería
/// - Capturar imagen con la cámara
/// - Cancelar
///
/// Maneja automáticamente la compresión y subida a Supabase.
///
/// Ejemplo de uso:
/// ```dart
/// // Sin estructura de carpetas (sube a raíz del bucket)
/// showImagePickerDialog(
///   context: context,
///   type: ImageUploadType.profile,
///   fileName: 'user_avatar',
///   title: 'Subir foto de perfil',
///   onImageUploaded: (imageUrl) {
///     print('Imagen subida: $imageUrl');
///     // Usa imageUrl aquí
///   },
///   onError: (errorMessage) {
///     // Opcional: Maneja el error si lo necesitas
///     print('Error: $errorMessage');
///   },
/// );
/// // Resultado: users/user_avatar.jpg
///
/// // Con estructura de carpetas (bucket: 'topics')
/// showImagePickerDialog(
///   context: context,
///   type: ImageUploadType.test,
///   fileName: 'question_image',
///   folderPath: 'topic_1/question_5',  // SIN 'topics/' al inicio
///   title: 'Subir imagen de pregunta',
///   onImageUploaded: (imageUrl) {
///     print('Imagen subida: $imageUrl');
///   },
/// );
/// // Resultado: topics/topic_1/question_5/question_image.jpg
/// ```
void showImagePickerDialog({
  required BuildContext context,
  required ImageUploadType type,
  required String fileName,
  required Function(String imageUrl) onImageUploaded,
  String? folderPath,
  String? title,
  String? subtitle,
  Function(String errorMessage)? onError,
}) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return ImagePickerDialog(
        type: type,
        fileName: fileName,
        folderPath: folderPath,
        title: title,
        subtitle: subtitle,
        onImageUploaded: onImageUploaded,
        onError: onError,
      );
    },
  );
}

/// Widget interno del dialog de selección de imagen.
class ImagePickerDialog extends StatefulWidget {
  const ImagePickerDialog({
    required this.type,
    required this.fileName,
    required this.onImageUploaded,
    this.folderPath,
    this.title,
    this.subtitle,
    this.onError,
    super.key,
  });

  final ImageUploadType type;
  final String fileName;
  final Function(String imageUrl) onImageUploaded;
  final Function(String errorMessage)? onError;
  final String? folderPath;
  final String? title;
  final String? subtitle;

  @override
  State<ImagePickerDialog> createState() => _ImagePickerDialogState();
}

class _ImagePickerDialogState extends State<ImagePickerDialog> {
  final ImageUploadRepository _repository =
      GetIt.instance<ImageUploadRepository>();
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  XFile? _selectedImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        widget.title ?? _getDefaultTitle(),
        style: theme.textTheme.headlineSmall,
      ),
      content: _isUploading
          ? _buildUploadingView()
          : _selectedImage != null
              ? _buildPreviewView()
              : _buildOptionsView(),
      actions: _isUploading
          ? null
          : _selectedImage != null
              ? _buildPreviewActions(context)
              : _buildActions(context),
    );
  }

  String _getDefaultTitle() {
    return widget.type == ImageUploadType.profile
        ? 'Subir foto de perfil'
        : 'Subir imagen del test';
  }

  String _getDefaultSubtitle() {
    return widget.type == ImageUploadType.profile
        ? 'Selecciona una imagen para tu perfil'
        : 'Selecciona una imagen para la pregunta';
  }

  Widget _buildOptionsView() {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.subtitle != null || _errorMessage == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              widget.subtitle ?? _getDefaultSubtitle(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        _buildOptionButton(
          context: context,
          icon: Icons.photo_library,
          label: 'Galería',
          onTap: _pickFromGallery,
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewView() {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Vista previa',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          constraints: const BoxConstraints(
            maxHeight: 300,
            maxWidth: 300,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(_selectedImage!.path),
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '¿Te gusta esta imagen?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadingView() {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Subiendo imagen...',
          style: theme.textTheme.bodyMedium,
        ),
        if (_uploadProgress > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${(_uploadProgress * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context, rootNavigator: false).pop(),
        child: const Text('Cancelar'),
      ),
    ];
  }

  List<Widget> _buildPreviewActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () {
          setState(() {
            _selectedImage = null;
            _errorMessage = null;
          });
        },
        child: const Text('Cambiar imagen'),
      ),
      const SizedBox(width: 8),
      FilledButton.icon(
        onPressed: _confirmUpload,
        icon: const Icon(Icons.check),
        label: const Text('Confirmar'),
      ),
    ];
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? imageFile = await _repository.pickImageFromGallery();

      if (imageFile != null && mounted) {
        setState(() {
          _selectedImage = imageFile;
          _errorMessage = null;
        });
      }
    } catch (e) {
      logger.error('Error picking image from gallery: $e');

      if (mounted) {
        setState(() {
          _errorMessage =
              'No se pudo acceder a la galería. Verifica los permisos.';
        });
      }
    }
  }

  // Future<void> _pickFromCamera() async {
  //   try {
  //     final XFile? imageFile = await _repository.pickImageFromCamera();

  //     if (imageFile != null && mounted) {
  //       setState(() {
  //         _selectedImage = imageFile;
  //         _errorMessage = null;
  //       });
  //     }
  //   } catch (e) {
  //     logger.error('Error capturing image from camera: $e');

  //     if (mounted) {
  //       setState(() {
  //         _errorMessage =
  //             'No se pudo acceder a la cámara. Verifica los permisos.';
  //       });
  //     }
  //   }
  // }

  Future<void> _confirmUpload() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _errorMessage = null;
    });

    try {
      // Comprimir imagen
      final compressedBytes = await _repository.compressImage(
        _selectedImage!,
        widget.type,
      );

      // Subir a Supabase
      final String imageUrl = await _repository.uploadImage(
        compressedBytes,
        widget.type,
        widget.fileName,
        folderPath: widget.folderPath,
      );

      if (!mounted) return;

      // ✅ Cerrar este diálogo PRIMERO
      Navigator.of(context).pop();

      // ✅ Esperar un frame antes de llamar al callback
      await Future.delayed(const Duration(milliseconds: 100));

      // ✅ Llamar al callback (que mostrará otro diálogo)
      widget.onImageUploaded(imageUrl);
    } catch (e) {
      logger.error('Error uploading image: $e');

      if (!mounted) return;

      final errorMessage = _getErrorMessage(e);

      // Cerrar el diálogo
      Navigator.of(context).pop();

      // Esperar antes de mostrar el error
      await Future.delayed(const Duration(milliseconds: 100));

      // Llamar al callback de error
      widget.onError?.call(errorMessage);
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('galería')) {
      return 'No se pudo acceder a la galería. Verifica los permisos.';
    } else if (errorString.contains('cámara')) {
      return 'No se pudo acceder a la cámara. Verifica los permisos.';
    } else if (errorString.contains('comprimir')) {
      return 'Error al procesar la imagen. Intenta con otra imagen.';
    } else if (errorString.contains('Supabase') ||
        errorString.contains('subir')) {
      return 'Error al subir la imagen. Verifica tu conexión.';
    }

    return 'Error desconocido. Intenta nuevamente.';
  }
}

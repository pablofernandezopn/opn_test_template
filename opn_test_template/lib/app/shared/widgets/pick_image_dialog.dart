import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img; // Librería para compresión real
import 'package:opn_test_template/bootstrap.dart';
import 'package:opn_test_template/app/shared/widgets/network_image_widget.dart';

// Lista global de cámaras disponibles
List<CameraDescription>? _cameras;

// Inicializar cámaras (llamar al inicio de la app)
Future<void> initializeCameras() async {
  try {
    _cameras = await availableCameras();
  } catch (e) {
    logger.error('Error inicializando cámaras: $e');
    _cameras = [];
  }
}

Future<void> openImagePicker({
  required BuildContext context,
  required Function(XFile) onSave,
  // Parámetros de optimización aplicados directamente
  int maxWidth = 800,
  int maxHeight = 800,
  int quality = 70,
  List<String> allowedFormats = const ['jpg', 'jpeg', 'png', 'webp'],
  bool forceOptimization = true,
  bool showPreview = true,
  bool showCropInterface = true,
  // PARÁMETROS DE CÁMARA
  bool showSourceSelection = true,
  bool allowCamera = true,
  bool allowGallery = true,
  String? customTitle,
  // Nuevos parámetros para camera plugin
  bool useCameraPlugin = true,
  CameraLensDirection preferredCamera = CameraLensDirection.front,
}) async {
  if (!context.mounted) return;

  // Verificar si hay cámaras disponibles
  if (allowCamera && useCameraPlugin && !kIsWeb) {
    if (_cameras == null) {
      await initializeCameras();
    }

    if (_cameras?.isEmpty ?? true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontraron cámaras en el dispositivo'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      allowCamera = false;
    }
  }

  ImageSource? selectedSource;

  if (!showSourceSelection) {
    selectedSource = allowGallery ? ImageSource.gallery : null;
  } else {
    selectedSource = await _showSourceSelectionDialog(
      context: context,
      allowCamera: allowCamera,
      allowGallery: allowGallery,
      customTitle: customTitle,
      useCameraPlugin: useCameraPlugin && !kIsWeb,
    );
  }

  if (selectedSource == null) return;

  XFile? pickedFile;

  if (selectedSource == ImageSource.camera && useCameraPlugin && !kIsWeb) {
    pickedFile = await _openCameraWithPlugin(
      context: context,
      preferredCamera: preferredCamera,
    );
  } else {
    pickedFile = await _pickWithImagePicker(
      context: context,
      source: selectedSource,
      quality: quality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  if (pickedFile == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se seleccionó imagen'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    return;
  }

  // Validación de formatos
  if (!_isValidImageFormat(pickedFile, allowedFormats)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Formato no soportado. Usa: ${allowedFormats.join(', ').toUpperCase()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  if (!context.mounted) return;

  // Mostrar interfaz de recorte si está habilitada
  if (showCropInterface && context.mounted) {
    final croppedFile = await _showCropInterface(
      context: context,
      imageFile: pickedFile,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: quality, // Pasar quality al recorte
    );

    if (croppedFile != null) {
      pickedFile = croppedFile;
    }
  }

  // Procesar imagen con optimización automática
  XFile? optimizedFile;
  String? originalSize;
  String? optimizedSize;

  // Validar que la imagen tenga contenido
  Uint8List? originalBytes;
  try {
    originalBytes = await pickedFile.readAsBytes();
    if (originalBytes.isEmpty) {
      throw Exception('Bytes de imagen vacíos');
    }
  } catch (e) {
    logger.error('Error obteniendo bytes de imagen: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: La imagen seleccionada está vacía o corrupta'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  originalSize = _getFileSizeString(originalBytes.length);

  // Optimizar si está habilitado
  if (forceOptimization) {
    optimizedFile = await _optimizeImageWithQuality(
      pickedFile,
      maxWidth,
      maxHeight,
      quality,
    );
    if (optimizedFile != null) {
      final optimizedBytes = await optimizedFile.readAsBytes();
      optimizedSize = _getFileSizeString(optimizedBytes.length);
    }
  }

  final finalImage = optimizedFile ?? pickedFile;

  // Mostrar preview si está habilitado
  if (showPreview && context.mounted) {
    await _showPreviewDialog(
      context: context,
      originalImage: pickedFile,
      optimizedImage: optimizedFile,
      originalSize: originalSize,
      optimizedSize: optimizedSize,
      onSave: onSave,
    );
  } else {
    onSave(finalImage);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(optimizedFile != null
              ? 'Imagen procesada y guardada correctamente'
              : 'Imagen guardada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// NUEVA: Función de optimización con calidad real usando la librería image
Future<XFile?> _optimizeImageWithQuality(XFile image, int maxWidth, int maxHeight, int quality) async {
  try {
    // Leer bytes de la imagen
    final imageBytes = await image.readAsBytes();
    if (imageBytes.isEmpty) {
      logger.error('Los bytes de la imagen están vacíos');
      return null;
    }

    // Decodificar la imagen usando la librería image
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      logger.error('No se pudo decodificar la imagen');
      return null;
    }

    final originalWidth = originalImage.width;
    final originalHeight = originalImage.height;

    // Determinar formato de salida
    final originalExtension = image.name.toLowerCase().split('.').last;
    final useJpeg = ['jpg', 'jpeg'].contains(originalExtension);
    final outputExtension = useJpeg ? 'jpg' : 'png';
    final mimeType = useJpeg ? 'image/jpeg' : 'image/png';

    img.Image processedImage = originalImage;

    // Si la imagen es mayor que los límites, redimensionar manteniendo aspecto
    if (originalWidth > maxWidth || originalHeight > maxHeight) {
      // Calcular nuevas dimensiones manteniendo aspecto
      final aspectRatio = originalWidth / originalHeight;
      int newWidth, newHeight;

      if (aspectRatio > 1) {
        // Imagen horizontal
        newWidth = math.min(maxWidth, originalWidth);
        newHeight = (newWidth / aspectRatio).round();
        if (newHeight > maxHeight) {
          newHeight = maxHeight;
          newWidth = (newHeight * aspectRatio).round();
        }
      } else {
        // Imagen vertical o cuadrada
        newHeight = math.min(maxHeight, originalHeight);
        newWidth = (newHeight * aspectRatio).round();
        if (newWidth > maxWidth) {
          newWidth = maxWidth;
          newHeight = (newWidth / aspectRatio).round();
        }
      }

      // Redimensionar con alta calidad
      processedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.cubic,
      );
    }

    // Aplicar compresión con calidad específica
    Uint8List compressedBytes;

    if (useJpeg) {
      // Para JPEG, aplicar calidad específica (0-100)
      compressedBytes = Uint8List.fromList(
          img.encodeJpg(processedImage, quality: quality)
      );
    } else {
      // Para PNG (sin pérdida), solo optimizar
      compressedBytes = Uint8List.fromList(
          img.encodePng(processedImage)
      );
    }

    // Crear archivo optimizado
    return XFile.fromData(
      compressedBytes,
      name: '${image.name.split('.').first}_optimized.$outputExtension',
      mimeType: mimeType,
    );

  } catch (e) {
    logger.error('Error optimizando imagen: $e');
    return null;
  }
}

// Función _buildImagePreview actualizada
Widget _buildImagePreview(XFile imageFile) {
  if (kIsWeb) {
    if (imageFile.path.isEmpty) {
      return FutureBuilder<Uint8List>(
        future: imageFile.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Error cargando imagen', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Container(
              color: Colors.grey.shade100,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Error cargando imagen', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          }
        },
      );
    }

    try {
      return NetworkImageWidget(imageUrl: imageFile.path);
    } catch (e) {
      return Image.network(
        imageFile.path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade100,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Error cargando imagen', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      );
    }
  } else {
    if (imageFile.path.isEmpty) {
      return FutureBuilder<Uint8List>(
        future: imageFile.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Error cargando imagen', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Container(
              color: Colors.grey.shade100,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No se pudo cargar la imagen', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          }
        },
      );
    }

    try {
      final file = File(imageFile.path);
      return FutureBuilder<bool>(
        future: file.exists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data == true) {
            return Image.file(
              file,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                logger.error('Error cargando imagen desde archivo: $error');
                return Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Error cargando imagen', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return FutureBuilder<Uint8List>(
              future: imageFile.readAsBytes(),
              builder: (context, bytesSnapshot) {
                if (bytesSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (bytesSnapshot.hasData) {
                  return Image.memory(
                    bytesSnapshot.data!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Error cargando imagen', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No se pudo cargar la imagen', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      );
    } catch (e) {
      logger.error('Error general cargando imagen: $e');
      return Container(
        color: Colors.grey.shade100,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 48, color: Colors.red),
              SizedBox(height: 8),
              Text('Error cargando imagen', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      );
    }
  }
}

// Interfaz de recorte de imagen
Future<XFile?> _showCropInterface({
  required BuildContext context,
  required XFile imageFile,
  required int maxWidth,
  required int maxHeight,
  required int quality,
}) async {
  return await Navigator.of(context).push<XFile>(
    MaterialPageRoute(
      builder: (context) => ImageCropScreen(
        imageFile: imageFile,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
      ),
      fullscreenDialog: true,
    ),
  );
}

// Pantalla de recorte de imagen
class ImageCropScreen extends StatefulWidget {
  final XFile imageFile;
  final int maxWidth;
  final int maxHeight;
  final int quality;

  const ImageCropScreen({
    Key? key,
    required this.imageFile,
    required this.maxWidth,
    required this.maxHeight,
    required this.quality,
  }) : super(key: key);

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  ui.Image? _image;
  Rect _cropRect = Rect.zero;
  Size _imageSize = Size.zero;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();

      setState(() {
        _image = frame.image;
        _imageSize = Size(frame.image.width.toDouble(), frame.image.height.toDouble());
        _initializeCropRect();
        _isLoading = false;
      });
    } catch (e) {
      logger.error('Error cargando imagen: $e');
      Navigator.of(context).pop();
    }
  }

  void _initializeCropRect() {
    if (_image == null) return;

    final imageWidth = _image!.width.toDouble();
    final imageHeight = _image!.height.toDouble();
    final targetAspectRatio = widget.maxWidth / widget.maxHeight;
    final imageAspectRatio = imageWidth / imageHeight;

    double cropWidth, cropHeight;

    if (imageAspectRatio > targetAspectRatio) {
      cropHeight = imageHeight;
      cropWidth = cropHeight * targetAspectRatio;
    } else {
      cropWidth = imageWidth;
      cropHeight = cropWidth / targetAspectRatio;
    }

    final left = (imageWidth - cropWidth) / 2;
    final top = (imageHeight - cropHeight) / 2;

    setState(() {
      _cropRect = Rect.fromLTWH(left, top, cropWidth, cropHeight);
    });
  }

  Future<void> _cropAndSave() async {
    if (_image == null) return;

    try {
      // Validar que el cropRect sea válido
      if (_cropRect.width <= 0 || _cropRect.height <= 0) {
        throw Exception('Área de recorte inválida');
      }

      // Asegurar que el cropRect esté dentro de los límites de la imagen
      final clampedRect = Rect.fromLTWH(
        math.max(0, _cropRect.left),
        math.max(0, _cropRect.top),
        math.min(_cropRect.width, _image!.width.toDouble() - math.max(0, _cropRect.left)),
        math.min(_cropRect.height, _image!.height.toDouble() - math.max(0, _cropRect.top)),
      );

      if (clampedRect.width <= 0 || clampedRect.height <= 0) {
        throw Exception('Área de recorte fuera de los límites de la imagen');
      }

      // Usar la librería image para recortar con calidad
      final originalBytes = await widget.imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(originalBytes);

      if (originalImage == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Recortar la imagen
      img.Image croppedImage = img.copyCrop(
        originalImage,
        x: clampedRect.left.round(),
        y: clampedRect.top.round(),
        width: clampedRect.width.round(),
        height: clampedRect.height.round(),
      );

      // Determinar formato de salida
      final originalExtension = widget.imageFile.name.toLowerCase().split('.').last;
      final useJpeg = ['jpg', 'jpeg'].contains(originalExtension);
      final outputExtension = useJpeg ? 'jpg' : 'png';
      final mimeType = useJpeg ? 'image/jpeg' : 'image/png';

      // Codificar con calidad específica
      Uint8List imageBytes;
      if (useJpeg) {
        imageBytes = Uint8List.fromList(
            img.encodeJpg(croppedImage, quality: widget.quality)
        );
      } else {
        imageBytes = Uint8List.fromList(
            img.encodePng(croppedImage)
        );
      }

      // Crear archivo
      String originalName = widget.imageFile.name;
      if (originalName.isEmpty) {
        originalName = 'cropped_image';
      }

      final nameWithoutExtension = originalName.contains('.')
          ? originalName.split('.').first
          : originalName;

      final croppedFile = XFile.fromData(
        imageBytes,
        name: '${nameWithoutExtension}_cropped.$outputExtension',
        mimeType: mimeType,
      );

      if (mounted) {
        Navigator.of(context).pop(croppedFile);
      }

    } catch (e) {
      logger.error('Error recortando imagen: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al recortar la imagen: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Recortar imagen', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _cropAndSave,
            child: const Text('Listo', style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: _imageSize.aspectRatio,
                child: CustomPaint(
                  painter: CropPainter(
                    image: _image!,
                    cropRect: _cropRect,
                    imageSize: _imageSize,
                  ),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      _updateCropRect(details.localPosition);
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Arrastra para ajustar el área de recorte',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Tamaño objetivo: ${widget.maxWidth}x${widget.maxHeight} | Calidad: ${widget.quality}%',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateCropRect(Offset position) {
    if (_image == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final scaleX = _imageSize.width / size.width;
    final scaleY = _imageSize.height / size.height;

    final imagePosition = Offset(
      position.dx * scaleX,
      position.dy * scaleY,
    );

    final newLeft = math.max(0.0, math.min(imagePosition.dx - _cropRect.width / 2, _imageSize.width - _cropRect.width));
    final newTop = math.max(0.0, math.min(imagePosition.dy - _cropRect.height / 2, _imageSize.height - _cropRect.height));

    setState(() {
      _cropRect = Rect.fromLTWH(newLeft, newTop, _cropRect.width, _cropRect.height);
    });
  }
}

// Painter personalizado para mostrar el área de recorte
class CropPainter extends CustomPainter {
  final ui.Image image;
  final Rect cropRect;
  final Size imageSize;

  CropPainter({
    required this.image,
    required this.cropRect,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;
    final scale = math.min(scaleX, scaleY);

    final scaledWidth = imageSize.width * scale;
    final scaledHeight = imageSize.height * scale;

    final offsetX = (size.width - scaledWidth) / 2;
    final offsetY = (size.height - scaledHeight) / 2;

    // Dibujar la imagen
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, imageSize.width, imageSize.height),
      Rect.fromLTWH(offsetX, offsetY, scaledWidth, scaledHeight),
      Paint(),
    );

    // Dibujar overlay oscuro
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5);

    // Área de recorte escalada
    final scaledCropRect = Rect.fromLTWH(
      offsetX + cropRect.left * scale,
      offsetY + cropRect.top * scale,
      cropRect.width * scale,
      cropRect.height * scale,
    );

    // Dibujar overlay en las áreas no recortadas
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRect(scaledCropRect),
      ),
      overlayPaint,
    );

    // Dibujar borde del área de recorte
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(scaledCropRect, borderPaint);

    // Dibujar líneas de guía (regla de tercios)
    final guidePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Líneas verticales
    for (int i = 1; i < 3; i++) {
      final x = scaledCropRect.left + (scaledCropRect.width * i / 3);
      canvas.drawLine(
        Offset(x, scaledCropRect.top),
        Offset(x, scaledCropRect.bottom),
        guidePaint,
      );
    }

    // Líneas horizontales
    for (int i = 1; i < 3; i++) {
      final y = scaledCropRect.top + (scaledCropRect.height * i / 3);
      canvas.drawLine(
        Offset(scaledCropRect.left, y),
        Offset(scaledCropRect.right, y),
        guidePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Función para usar camera plugin
Future<XFile?> _openCameraWithPlugin({
  required BuildContext context,
  required CameraLensDirection preferredCamera,
}) async {
  if (_cameras == null || _cameras!.isEmpty) {
    return null;
  }

  CameraDescription? selectedCamera;
  try {
    selectedCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
    );
  } catch (e) {
    try {
      selectedCamera = _cameras!.firstWhere(
            (camera) => camera.lensDirection == preferredCamera,
      );
    } catch (e) {
      selectedCamera = _cameras!.first;
    }
  }

  final result = await Navigator.of(context).push<XFile>(
    MaterialPageRoute(
      builder: (context) => CameraScreen(camera: selectedCamera!),
      fullscreenDialog: true,
    ),
  );

  return result;
}

// Pantalla de cámara con camera plugin
class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isFlashOn = false;
  bool _isBackCamera = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller!.initialize();
    _isBackCamera = widget.camera.lensDirection == CameraLensDirection.back;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      if (mounted) {
        Navigator.of(context).pop(image);
      }
    } catch (e) {
      logger.error('Error tomando foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar la foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFlash() async {
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        setState(() {
          _isFlashOn = !_isFlashOn;
        });

        await _controller!.setFlashMode(
          _isFlashOn ? FlashMode.torch : FlashMode.off,
        );
      }
    } catch (e) {
      logger.error('Error con flash: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    try {
      final newCameraDirection = _isBackCamera
          ? CameraLensDirection.front
          : CameraLensDirection.back;

      final newCamera = _cameras!.firstWhere(
            (camera) => camera.lensDirection == newCameraDirection,
      );

      await _controller?.dispose();

      setState(() {
        _isBackCamera = !_isBackCamera;
      });

      _controller = CameraController(newCamera, ResolutionPreset.high);
      _initializeControllerFuture = _controller!.initialize();

      setState(() {});
    } catch (e) {
      logger.error('Error cambiando cámara: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleFlash,
          ),
          if (_cameras != null && _cameras!.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
              onPressed: _switchCamera,
            ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned(
                  child: AspectRatio(
                      aspectRatio: 9/16,
                      child: CameraPreview(_controller!)),
                ),
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.photo_library,
                              color: Colors.white, size: 28),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null && mounted) {
                              Navigator.of(context).pop(image);
                            }
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 60, height: 60),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
        },
      ),
    );
  }
}

// Función para image_picker tradicional
Future<XFile?> _pickWithImagePicker({
  required BuildContext context,
  required ImageSource source,
  required int quality,
  required int maxWidth,
  required int maxHeight,
}) async {
  try {
    final picker = ImagePicker();

    if (kIsWeb && source == ImageSource.camera) {
      return await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
    } else {
      return await picker.pickImage(
        source: source,
        imageQuality: source == ImageSource.camera ? 85 : quality,
        maxWidth: source == ImageSource.gallery ? maxWidth.toDouble() : null,
        maxHeight: source == ImageSource.gallery ? maxHeight.toDouble() : null,
      );
    }
  } catch (e) {
    logger.error('Error con image_picker: $e');

    if (context.mounted) {
      String errorMessage = 'Error al acceder a la ${source == ImageSource.camera ? 'cámara' : 'galería'}';

      if (e.toString().contains('camera_access_denied') ||
          e.toString().contains('NotAllowedError')) {
        errorMessage = 'Permisos denegados. Permite el acceso en configuración.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
    return null;
  }
}

// Diálogo de selección de fuente
Future<ImageSource?> _showSourceSelectionDialog({
  required BuildContext context,
  required bool allowCamera,
  required bool allowGallery,
  String? customTitle,
  bool useCameraPlugin = false,
}) async {
  if (allowCamera && !allowGallery) {
    return ImageSource.camera;
  }
  if (!allowCamera && allowGallery) {
    return ImageSource.gallery;
  }
  if (!allowCamera && !allowGallery) {
    return null;
  }

  return await showDialog<ImageSource>(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.add_photo_alternate,
                      color: Colors.blue.shade600, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      customTitle ?? 'Seleccionar imagen',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '¿Cómo quieres añadir la imagen?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  if (allowCamera) ...[
                    _buildSourceOption(
                      context: dialogContext,
                      icon: Icons.camera_alt,
                      title: useCameraPlugin && !kIsWeb
                          ? 'Tomar foto'
                          : kIsWeb ? 'Usar cámara web' : 'Tomar foto',
                      subtitle: useCameraPlugin && !kIsWeb
                          ? 'Interfaz de cámara completa con controles'
                          : kIsWeb
                          ? 'Necesita permisos de cámara en tu navegador'
                          : 'Usa la cámara de tu dispositivo',
                      color: Colors.green,
                      onTap: () => Navigator.of(dialogContext).pop(ImageSource.camera),
                    ),
                    if (allowGallery) const SizedBox(height: 16),
                  ],
                  if (allowGallery) ...[
                    _buildSourceOption(
                      context: dialogContext,
                      icon: kIsWeb ? Icons.upload_file : Icons.photo_library,
                      title: kIsWeb ? 'Subir desde ordenador' : 'Seleccionar de galería',
                      subtitle: kIsWeb
                          ? 'Busca archivos en tu ordenador'
                          : 'Elige una foto de tu galería',
                      color: Colors.blue,
                      onTap: () => Navigator.of(dialogContext).pop(ImageSource.gallery),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}

// Widget auxiliar para las opciones de fuente
Widget _buildSourceOption({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade400,
            size: 16,
          ),
        ],
      ),
    ),
  );
}

// Vista previa de imagen
Future<void> _showPreviewDialog({
  required BuildContext context,
  required XFile originalImage,
  XFile? optimizedImage,
  String? originalSize,
  String? optimizedSize,
  required Function(XFile) onSave,
}) async {
  await showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(

            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.preview, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Vista previa de imagen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),

                  child: _buildImagePreview(originalImage),
                ),
              ),
              const SizedBox(height: 16),
              // if (originalSize != null) ...[
              //   Container(
              //     padding: const EdgeInsets.all(16),
              //     decoration: BoxDecoration(
              //       color: Colors.blue.shade50,
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(color: Colors.blue.shade200),
              //     ),
              //     child: Row(
              //       children: [
              //         Icon(Icons.info, color: Colors.blue.shade600, size: 20),
              //         const SizedBox(width: 8),
              //         Expanded(
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text(
              //                 optimizedImage != null
              //                     ? 'Imagen optimizada con calidad aplicada'
              //                     : 'Imagen lista para guardar',
              //                 style: TextStyle(
              //                   fontSize: 14,
              //                   fontWeight: FontWeight.w600,
              //                   color: Colors.blue.shade700,
              //                 ),
              //               ),
              //               const SizedBox(height: 4),
              //               Text(
              //                 optimizedImage != null
              //                     ? 'Original: $originalSize → Optimizada: $optimizedSize'
              //                     : 'Tamaño: $originalSize',
              //                 style: TextStyle(
              //                   fontSize: 12,
              //                   color: Colors.grey.shade600,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              //   const SizedBox(height: 20),
              // ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final imageToSave = optimizedImage ?? originalImage;
                        onSave(imageToSave);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Imagen guardada correctamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                        Navigator.of(dialogContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Guardar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Validación de formatos de imagen
bool _isValidImageFormat(XFile file, List<String> allowedFormats) {
  final extension = file.name.toLowerCase().split('.').last;

  if (allowedFormats.contains(extension)) {
    return true;
  }

  if (kIsWeb && file.mimeType != null) {
    final validMimeTypes = [
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/webp'
    ];
    return validMimeTypes.contains(file.mimeType!.toLowerCase());
  }

  return false;
}

// Obtener string del tamaño de archivo
String _getFileSizeString(int bytes) {
  if (bytes < 1024) {
    return '${bytes} B';
  } else if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  } else {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
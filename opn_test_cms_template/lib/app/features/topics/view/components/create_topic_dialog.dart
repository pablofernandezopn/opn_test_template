// lib/app/features/topics/widgets/create_topic_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_model.dart';
import 'package:opn_test_guardia_civil_cms/app/config/go_route/app_routes.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_type_model.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_level.dart';
import 'package:opn_test_guardia_civil_cms/app/config/widgets/pickImage/pick_image.dart';
import 'package:opn_test_guardia_civil_cms/app/features/categories/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/categories/cubit/state.dart';

class CreateTopicDialog extends StatefulWidget {
  final int topicTypeId;
  final Topic? topicToEdit;

  const CreateTopicDialog({
    super.key,
    required this.topicTypeId,
    this.topicToEdit,
  });

  bool get isEditMode => topicToEdit != null;

  @override
  State<CreateTopicDialog> createState() => _CreateTopicDialogState();
}

class _CreateTopicDialogState extends State<CreateTopicDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _enabled = true;
  bool _isPremium = false;
  bool _isHiddenButPremium = false;
  late int _options; // Changed: Will be initialized in initState
  String? _uploadedImageUrl; // URL de la imagen subida a Supabase
  int? _selectedCategoryId; // Category selection for Study level topics

  @override
  void initState() {
    super.initState();

    if (widget.isEditMode && widget.topicToEdit != null) {
      // Modo edición: cargar datos del topic existente
      _nameController.text = widget.topicToEdit!.topicName;
      _descriptionController.text = widget.topicToEdit!.description ?? '';

      // Si tiene imagen, determinar si es de Supabase o URL externa
      final existingImageUrl = widget.topicToEdit!.imageUrl;
      if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
        // Si la URL contiene "supabase" o "storage", es de nuestro bucket
        if (existingImageUrl.contains('supabase') ||
            existingImageUrl.contains('/storage/')) {
          _uploadedImageUrl = existingImageUrl;
        } else {
          // Si no, es una URL externa manual
          _imageUrlController.text = existingImageUrl;
        }
      }

      _enabled = widget.topicToEdit!.enabled;
      _isPremium = widget.topicToEdit!.isPremium;
      _isHiddenButPremium = widget.topicToEdit!.isHiddenButPremium;
      _options = widget.topicToEdit!.options;
      _selectedCategoryId = widget.topicToEdit!.categoryId;
    } else {
      // Modo creación: usar valores por defecto del TopicType
      _options = _currentTopicType?.defaultNumberOptions ?? 4;
    }

    // Si el TopicType es de nivel Study, cargar las categorías
    if (_currentTopicType?.level == TopicLevel.Study) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<CategoryCubit>()
            .fetchCategoriesByTopicType(widget.topicTypeId);
      });
    }
  }

  /// Obtiene el TopicType actual del state
  TopicType? get _currentTopicType {
    try {
      final topicState = context.read<TopicCubit>().state;
      return topicState.topicTypes.firstWhere(
        (type) => type.id == widget.topicTypeId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _pickImage() {
    // Generar un nombre único para la imagen del topic
    final fileName = widget.isEditMode && widget.topicToEdit?.id != null
        ? 'topic_${widget.topicToEdit!.id}' // Reutilizar nombre si es edición
        : 'topic_${DateTime.now().millisecondsSinceEpoch}'; // Nombre único si es creación

    // Mostrar el dialog de selección de imagen con preview y subida
    showImagePickerDialog(
      context: context,
      type: ImageUploadType.test,
      fileName: fileName,
      title: 'Imagen del test',
      subtitle: 'Selecciona una imagen para el test',
      onImageUploaded: (imageUrl) {
        if (mounted) {
          setState(() {
            _uploadedImageUrl = imageUrl;
            // Si se sube una imagen, limpiamos el campo URL manual
            _imageUrlController.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Imagen subida correctamente'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  String? get _currentImageUrl {
    // Prioridad: 1. Imagen subida a Supabase, 2. URL manual
    if (_uploadedImageUrl != null) {
      return _uploadedImageUrl;
    }
    if (_imageUrlController.text.trim().isNotEmpty) {
      return _imageUrlController.text.trim();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditMode ? 'Editar Test' : 'Crear Nuevo Test'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del test (requerido)
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del test *',
                    hintText: 'Ej: Test de Constitución Española',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    if (value.trim().length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                ),
                const SizedBox(height: 16),

                // Descripción (opcional)
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: 'Descripción detallada del test',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  maxLength: 500,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),

                // Imagen - URL
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'URL de la imagen (opcional)',
                    hintText: 'https://ejemplo.com/imagen.jpg',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.link),
                    suffixIcon: _imageUrlController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _imageUrlController.clear();
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _uploadedImageUrl = null;
                      });
                    }
                  },
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final uri = Uri.tryParse(value.trim());
                      if (uri == null || !uri.hasScheme) {
                        return 'URL no válida';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Botón para seleccionar y subir imagen
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.cloud_upload),
                    label: Text(_uploadedImageUrl != null
                        ? 'Cambiar imagen'
                        : 'Subir imagen'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Previsualización de la imagen
                if (_currentImageUrl != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _currentImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 48, color: Colors.red),
                                SizedBox(height: 8),
                                Text('Error al cargar la imagen'),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (_currentImageUrl != null) const SizedBox(height: 16),

                // Número de opciones
                DropdownButtonFormField<int>(
                  // initialValue: _options,
                  decoration: const InputDecoration(
                    labelText: 'Número de opciones',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.format_list_numbered),
                  ),
                  items: [2, 3, 4, 5, 6, 7, 8].map((optionCount) {
                    return DropdownMenuItem(
                      value: optionCount,
                      child: Text('$optionCount opciones'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _options = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Selector de categoría (solo para topic_types de nivel Study)
                if (_currentTopicType?.level == TopicLevel.Study)
                  _buildCategorySelector(),
                if (_currentTopicType?.level == TopicLevel.Study)
                  const SizedBox(height: 16),

                // Switches
                SwitchListTile(
                  title: const Text('Test activo'),
                  subtitle:
                      const Text('El test estará disponible para los usuarios'),
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value),
                  secondary: Icon(
                    _enabled ? Icons.check_circle : Icons.cancel,
                    color: _enabled ? Colors.green : Colors.grey,
                  ),
                ),

                SwitchListTile(
                  title: const Text('Test premium'),
                  subtitle: const Text('Solo usuarios premium pueden acceder'),
                  value: _isPremium,
                  onChanged: (value) => setState(() => _isPremium = value),
                  secondary: Icon(
                    Icons.star,
                    color: _isPremium ? Colors.amber : Colors.grey,
                  ),
                ),

                if (_isPremium)
                  SwitchListTile(
                    title: const Text('Oculto pero premium'),
                    subtitle: const Text(
                        'No se muestra en listados pero es accesible'),
                    value: _isHiddenButPremium,
                    onChanged: (value) =>
                        setState(() => _isHiddenButPremium = value),
                    secondary: Icon(
                      Icons.visibility_off,
                      color: _isHiddenButPremium ? Colors.orange : Colors.grey,
                    ),
                  ),

                const SizedBox(height: 16),
                Text(
                  '* Campos obligatorios',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => _handleSubmit(context),
          child: Text(widget.isEditMode ? 'Guardar Cambios' : 'Crear Test'),
        ),
      ],
    );
  }

  /// Construye el selector de categorías
  Widget _buildCategorySelector() {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, categoryState) {
        // Si está cargando, mostrar indicador
        if (categoryState.fetchStatus.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Cargando categorías...'),
                ],
              ),
            ),
          );
        }

        // Si hay error
        if (categoryState.fetchStatus.isError) {
          return Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Error al cargar categorías: ${categoryState.error ?? "Error desconocido"}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Obtener categorías del topic_type actual
        final categories = categoryState.categories;

        // Crear items del dropdown
        final List<DropdownMenuItem<int?>> dropdownItems = [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('Sin categoría'),
          ),
          ...categories.map((category) {
            return DropdownMenuItem<int?>(
              value: category.id,
              child: Text(category.name ?? 'Sin nombre'),
            );
          }),
        ];

        return DropdownButtonFormField<int?>(
          // initialValue: _selectedCategoryId,
          decoration: InputDecoration(
            labelText: 'Categoría (opcional)',
            hintText: 'Selecciona una categoría',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.label_outline),
            helperText: categories.isEmpty
                ? 'No hay categorías disponibles. Crea una en la sección de Categorías.'
                : 'Clasifica este test en una categoría',
          ),
          items: dropdownItems,
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
        );
      },
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Determinar la URL de imagen final
    // Prioridad: 1. Imagen subida a Supabase, 2. URL manual
    final String? finalImageUrl = _uploadedImageUrl ??
        (_imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim());

    final now = DateTime.now();

    if (widget.isEditMode) {
      // Modo edición: actualizar topic existente
      // Lógica para publishedAt:
      // - Si ya tenía fecha: mantenerla (no cambiarla nunca)
      // - Si no tenía fecha y se activa: asignar fecha actual
      // - Si no tenía fecha y NO se activa: mantener null
      final newPublishedAt =
          widget.topicToEdit!.publishedAt ?? (_enabled ? now : null);

      final updatedTopic = widget.topicToEdit!.copyWith(
        topicName: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imageUrl: finalImageUrl,
        enabled: _enabled,
        isPremium: _isPremium,
        isHiddenButPremium: _isHiddenButPremium,
        options: _options,
        category: _selectedCategoryId,
        updatedAt: now,
        publishedAt: newPublishedAt,
      );

      await context
          .read<TopicCubit>()
          .updateTopic(widget.topicToEdit!.id!, updatedTopic);

      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      // Modo creación: crear nuevo topic
      final newTopic = Topic(
        topicTypeId: widget.topicTypeId,
        topicName: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imageUrl: finalImageUrl,
        enabled: _enabled,
        isPremium: _isPremium,
        isHiddenButPremium: _isHiddenButPremium,
        options: _options,
        categoryId: _selectedCategoryId,
        createdAt: now,
        updatedAt: now,
        publishedAt: _enabled ? now : null,
        // Valores por defecto para campos calculados
        totalParticipants: 0,
        totalQuestions: 0,
        totalScore: 0,
        averageScore: null,
        maxScore: null,
        minScore: null,
      );

      // Crear el topic y esperar a que se complete
      await context.read<TopicCubit>().createTopic(newTopic);

      // Obtener el topic recién creado del state
      final createdTopic = context.read<TopicCubit>().state.topics.lastOrNull;

      if (!mounted) return;
      Navigator.of(context).pop();

      // Mostrar confirmación con opción de navegar
      if (createdTopic != null && createdTopic.id != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child:
                      Text('Test "${newTopic.topicName}" creado correctamente'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            action: SnackBarAction(
              label: 'Ver Preguntas',
              textColor: Colors.white,
              onPressed: () {
                context.push(
                  AppRoutes.questions,
                  extra: createdTopic.id!,
                );
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child:
                      Text('Test "${newTopic.topicName}" creado correctamente'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    }
  }
}

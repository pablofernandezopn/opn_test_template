import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:opn_test_guardia_civil_cms/app/config/widgets/pickImage/image_picker_dialog.dart';
import 'package:opn_test_guardia_civil_cms/app/config/widgets/pickImage/image_upload_type.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/model/specialty.dart';

class SpecialtyFormDialog extends StatefulWidget {
  final Specialty? specialty;

  const SpecialtyFormDialog({super.key, this.specialty});

  @override
  State<SpecialtyFormDialog> createState() => _SpecialtyFormDialogState();
}

class _SpecialtyFormDialogState extends State<SpecialtyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _slugController;
  late TextEditingController _descriptionController;
  late TextEditingController _iconUrlController;
  late TextEditingController _colorHexController;
  late TextEditingController _displayOrderController;
  late bool _isActive;
  late bool _isDefault;
  bool _isSubmitting = false;

  bool get isEditing => widget.specialty != null;

  Color get _selectedColor {
    if (_colorHexController.text.isNotEmpty) {
      return _hexToColor(_colorHexController.text);
    }
    return Colors.blue;
  }

  @override
  void initState() {
    super.initState();
    final specialty = widget.specialty;

    _nameController = TextEditingController(text: specialty?.name ?? '');
    _slugController = TextEditingController(text: specialty?.slug ?? '');
    _descriptionController =
        TextEditingController(text: specialty?.description ?? '');
    _iconUrlController = TextEditingController(text: specialty?.iconUrl ?? '');
    _colorHexController =
        TextEditingController(text: specialty?.colorHex ?? '');
    _displayOrderController = TextEditingController(
      text: specialty?.displayOrder.toString() ?? '0',
    );
    _isActive = specialty?.isActive ?? true;
    _isDefault = specialty?.isDefault ?? false;

    _nameController.addListener(_generateSlug);
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _generateSlug() {
    if (!isEditing && _nameController.text.isNotEmpty) {
      final slug = _nameController.text
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
      _slugController.text = slug;
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color tempColor = _selectedColor;

        return AlertDialog(
          title: const Text('Selecciona un color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                tempColor = color;
              },
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hueWheel,
              labelTypes: const [],
              pickerAreaBorderRadius:
                  const BorderRadius.all(Radius.circular(10)),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              child: const Text('Seleccionar'),
              onPressed: () {
                setState(() {
                  _colorHexController.text = _colorToHex(tempColor);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _iconUrlController.dispose();
    _colorHexController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit : Icons.add,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing
                                  ? 'Editar Especialidad'
                                  : 'Nueva Especialidad',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              isEditing
                                  ? 'Modifica los datos de la especialidad'
                                  : 'Completa los datos de la nueva especialidad',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Formulario
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.title),
                      filled: true,
                      fillColor:
                          colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _slugController,
                    decoration: InputDecoration(
                      labelText: 'Slug *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.link),
                      helperText: 'URL amigable (ej: matematicas)',
                      filled: true,
                      fillColor:
                          colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El slug es obligatorio';
                      }
                      if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value)) {
                        return 'Solo minúsculas, números y guiones';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.description),
                      filled: true,
                      fillColor:
                          colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _iconUrlController,
                          decoration: InputDecoration(
                            labelText: 'URL del icono',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.image),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.image_search),
                        tooltip: isEditing
                            ? 'Seleccionar imagen'
                            : 'Primero crea la especialidad para subir imagen',
                        onPressed: isEditing
                            ? () {
                                _changeSpecialtyImage(context,
                                    widget.specialty!, _iconUrlController);
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Selector de color mejorado
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _colorHexController,
                          decoration: InputDecoration(
                            labelText: 'Color (hex)',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.palette),
                            hintText: '#FF5733',
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                          ),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _showColorPicker,
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: _selectedColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _displayOrderController,
                    decoration: InputDecoration(
                      labelText: 'Orden de visualización',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.sort),
                      filled: true,
                      fillColor:
                          colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (int.tryParse(value) == null) {
                          return 'Debe ser un número';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Switches con diseño mejorado
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Activa'),
                          subtitle:
                              const Text('La especialidad está disponible'),
                          value: _isActive,
                          onChanged: (value) =>
                              setState(() => _isActive = value),
                        ),
                        Divider(
                            height: 1,
                            color: colorScheme.outline.withOpacity(0.2)),
                        SwitchListTile(
                          title: const Text('Por defecto'),
                          subtitle: const Text('Especialidad predeterminada'),
                          value: _isDefault,
                          onChanged: (value) =>
                              setState(() => _isDefault = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            _isSubmitting ? null : () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(isEditing ? Icons.save : Icons.add),
                        label: Text(isEditing ? 'Guardar' : 'Crear'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _changeSpecialtyImage(BuildContext context, Specialty specialty,
      TextEditingController iconUrlController) {
    final specialtyCubit = context.read<SpecialtyCubit>();

    final fileName = 'icon';

    showImagePickerDialog(
      context: context,
      type: ImageUploadType.specialty,
      fileName: fileName,
      folderPath: 'specialty_${specialty.id}/icons',
      title: 'Cambiar foto de especialidad',
      subtitle: 'Selecciona una imagen para la especialidad',
      onImageUploaded: (imageUrl) async {
        if (!context.mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Actualizando foto de la especialidad...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        try {
          // Actualizar el objeto specialty con la nueva URL de la imagen
          final updatedSpecialty = specialty.copyWith(iconUrl: imageUrl);

          final success =
              await specialtyCubit.updateSpecialty(specialty.id!, updatedSpecialty);

          if (context.mounted) {
            Navigator.of(context).pop();

            if (success) {
              // Actualizar el campo de texto con la nueva URL
              iconUrlController.text = imageUrl;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Foto de la especialidad actualizada correctamente'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Error al actualizar la foto de perfil'),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error: ${e.toString().replaceAll('Exception: ', '')}',
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final specialty = Specialty(
        id: widget.specialty?.id ?? 0,
        academyId: widget.specialty?.academyId ?? 1,
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        iconUrl: _iconUrlController.text.trim().isEmpty
            ? null
            : _iconUrlController.text.trim(),
        colorHex: _colorHexController.text.trim().isEmpty
            ? null
            : _colorHexController.text.trim(),
        displayOrder: int.tryParse(_displayOrderController.text) ?? 0,
        isActive: _isActive,
        isDefault: _isDefault,
      );

      final cubit = context.read<SpecialtyCubit>();
      final bool success;

      if (isEditing) {
        success = await cubit.updateSpecialty(widget.specialty!.id!, specialty);
      } else {
        success = await cubit.createSpecialty(specialty);
      }

      if (mounted) {
        setState(() => _isSubmitting = false);

        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? 'Especialidad actualizada correctamente'
                    : 'Especialidad creada correctamente',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

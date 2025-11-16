import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/cubit/auth_cubit.dart';
import 'dart:io';
import '../../cubit/cubit.dart';
import '../../cubit/state.dart';
import '../../model/academy_model.dart';

/// Diálogo para crear o editar una academia.
class AcademyFormDialog extends StatefulWidget {
  final Academy? academy;

  const AcademyFormDialog({super.key, this.academy});

  @override
  State<AcademyFormDialog> createState() => _AcademyFormDialogState();
}

class _AcademyFormDialogState extends State<AcademyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _slugController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _logoUrlController;
  late final TextEditingController _websiteController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late bool _isActive;
  late bool _isAdmin;
  final ImagePicker _imagePicker = ImagePicker();

  bool get _isEditing => widget.academy != null;

  @override
  void initState() {
    super.initState();
    final academy = widget.academy;
    _nameController = TextEditingController(text: academy?.name ?? '');
    _slugController = TextEditingController(text: academy?.slug ?? '');
    _descriptionController =
        TextEditingController(text: academy?.description ?? '');
    _logoUrlController = TextEditingController(text: academy?.logoUrl ?? '');
    _websiteController = TextEditingController(text: academy?.website ?? '');
    _emailController = TextEditingController(text: academy?.contactEmail ?? '');
    _phoneController = TextEditingController(text: academy?.contactPhone ?? '');
    _addressController = TextEditingController(text: academy?.address ?? '');
    _isActive = academy?.isActive ?? true;
    _isAdmin = context.read<AuthCubit>().state.user.isAdmin;

    // Auto-generar slug desde el nombre
    if (!_isEditing) {
      _nameController.addListener(_updateSlug);
    }
  }

  void _updateSlug() {
    if (!_isEditing && _slugController.text.isEmpty) {
      final name = _nameController.text;
      final slug = name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
      _slugController.text = slug;
    }
  }

  Future<void> _pickImage() async {
    try {
      // Mostrar opciones para elegir de dónde obtener la imagen
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Aquí se establece la ruta local del archivo
        // En una implementación real, deberías subir la imagen a un servidor
        // y obtener la URL. Por ahora, solo mostramos la ruta local.
        setState(() {
          _logoUrlController.text = image.path;
        });

        // Mostrar mensaje informativo
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Imagen seleccionada. Nota: Debes subir la imagen a un servidor y usar la URL',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePreview() {
    final imageUrl = _logoUrlController.text.trim();
    if (imageUrl.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Vista previa del logo'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildImageWidget(imageUrl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    // Si es una ruta local (empieza con / o contiene :\ para Windows)
    if (imageUrl.startsWith('/') || imageUrl.contains(r':\')) {
      return Image.file(
        File(imageUrl),
        height: 300,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Column(
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 8),
              Text('Error al cargar la imagen local'),
            ],
          );
        },
      );
    } else {
      // Es una URL
      return Image.network(
        imageUrl,
        height: 300,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Column(
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 8),
              Text('Error al cargar la imagen desde la URL'),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _logoUrlController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AcademyCubit, AcademyState>(
      listener: (context, state) {
        if (state.createStatus.isDone || state.updateStatus.isDone) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing
                  ? 'Academia actualizada exitosamente'
                  : 'Academia creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          context.read<AcademyCubit>().resetCreateStatus();
          context.read<AcademyCubit>().resetUpdateStatus();
        } else if (state.createStatus.isError || state.updateStatus.isError) {
          final message = _isEditing
              ? state.updateStatus.message
              : state.createStatus.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AlertDialog(
        title: Text(_isEditing ? 'Editar Academia' : 'Nueva Academia'),
        content: SizedBox(
          width: 600,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nombre (requerido)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      hintText: 'Ej: Academia Madrid',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Slug (requerido)
                  TextFormField(
                    controller: _slugController,
                    decoration: const InputDecoration(
                      labelText: 'Slug *',
                      hintText: 'Ej: academia-madrid',
                      helperText:
                          'Solo minúsculas, números, guiones y guiones bajos',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El slug es requerido';
                      }
                      if (!RegExp(r'^[a-z0-9_-]+$').hasMatch(value)) {
                        return 'Slug inválido: solo minúsculas, números, - y _';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Describe la academia',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email de contacto',
                      hintText: 'contacto@academia.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          !RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
                              .hasMatch(value)) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Teléfono
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      hintText: '+34 600 000 000',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Website
                  TextFormField(
                    controller: _websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Sitio web',
                      hintText: 'https://academia.com',
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),

                  // Logo URL
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _logoUrlController,
                          decoration: const InputDecoration(
                            labelText: 'URL del logo',
                            hintText: 'https://...',
                          ),
                          keyboardType: TextInputType.url,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botón para seleccionar imagen del dispositivo
                      IconButton.filled(
                        icon: const Icon(Icons.image),
                        tooltip: 'Seleccionar imagen del dispositivo',
                        onPressed: _pickImage,
                      ),
                      const SizedBox(width: 4),
                      // Botón de preview
                      IconButton.outlined(
                        icon: const Icon(Icons.preview),
                        tooltip: 'Vista previa',
                        onPressed: _logoUrlController.text.isEmpty
                            ? null
                            : _showImagePreview,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dirección
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      hintText: 'Calle, Ciudad, CP',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Estado activo/inactivo
                  if (_isAdmin)
                    SwitchListTile(
                      title: const Text('Academia activa'),
                      subtitle: Text(_isActive
                          ? 'La academia está operativa'
                          : 'La academia está desactivada'),
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
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
          BlocBuilder<AcademyCubit, AcademyState>(
            builder: (context, state) {
              final isLoading =
                  state.createStatus.isLoading || state.updateStatus.isLoading;

              return FilledButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Actualizar' : 'Crear'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final academy = Academy(
      id: widget.academy?.id,
      name: _nameController.text.trim(),
      slug: _slugController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      logoUrl: _logoUrlController.text.trim().isEmpty
          ? null
          : _logoUrlController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      contactEmail: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      contactPhone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      isActive: _isActive,
    );

    if (_isEditing) {
      context.read<AcademyCubit>().updateAcademy(academy);
    } else {
      context.read<AcademyCubit>().createAcademy(academy);
    }
  }
}

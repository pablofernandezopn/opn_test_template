import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/cubit/auth_cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/cubit/auth_state.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/model/user.dart';
import 'package:opn_test_guardia_civil_cms/app/config/widgets/pickImage/pick_image.dart';
import 'package:opn_test_guardia_civil_cms/bootstrap.dart';

/// 👤 Página de Perfil de Usuario
///
/// Permite ver y editar la información del perfil del usuario autenticado.
/// Incluye:
/// - Visualización de datos personales
/// - Edición de nombre, apellido, email, teléfono, dirección
/// - Visualización del rol del usuario
/// - Avatar del usuario
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// Ruta de navegación para esta página
  static const String route = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        automaticallyImplyLeading: MediaQuery.of(context).size.width < 600,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state.user;

          if (user == null) {
            return const SizedBox.expand(
              child: Center(
                child: Text('No hay usuario autenticado'),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final scrollableContent = SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ==========================================
                        // SECCIÓN: AVATAR Y NOMBRE
                        // ==========================================
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                // Avatar clickeable
                                Stack(
                                  children: [
                                    InkWell(
                                      onTap: () => _changeAvatar(context, user),
                                      borderRadius: BorderRadius.circular(60),
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        backgroundImage:
                                            user.avatarUrl != null &&
                                                    user.avatarUrl!.isNotEmpty
                                                ? NetworkImage(
                                                    _getImageUrlWithCacheBuster(
                                                        user.avatarUrl!))
                                                : null,
                                        child: user.avatarUrl == null ||
                                                user.avatarUrl!.isEmpty
                                            ? Icon(
                                                Icons.person,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                size: 36,
                                              )
                                            : null,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            width: 3,
                                          ),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.camera_alt,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              _changeAvatar(context, user),
                                          tooltip: 'Cambiar foto de perfil',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Nombre completo
                                Text(
                                  user.fullName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),

                                // Rol
                                Chip(
                                  label: Text(user.roleName),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  labelStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ==========================================
                        // SECCIÓN: FORMULARIO DE EDICIÓN
                        // ==========================================
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: _ProfileForm(user: user),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              if (constraints.hasBoundedHeight) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: scrollableContent,
                );
              } else {
                return scrollableContent;
              }
            },
          );
        },
      ),
    );
  }
}

/// 📝 Formulario de edición de perfil
class _ProfileForm extends StatefulWidget {
  final CmsUser user;

  const _ProfileForm({required this.user});

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Escuchar cambios en los campos
    _usernameController.addListener(_onFieldChanged);
    _nombreController.addListener(_onFieldChanged);
    _apellidoController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
  }

  void _initializeControllers() {
    _usernameController.text = widget.user.username;
    _nombreController.text = widget.user.name;
    _apellidoController.text = widget.user.lastName;
    _emailController.text = widget.user.email ?? '';
    _phoneController.text = widget.user.phone ?? '';
    _addressController.text = widget.user.address ?? '';
  }

  void _onFieldChanged() {
    final hasChanges = _usernameController.text != widget.user.username ||
        _nombreController.text != widget.user.name ||
        _apellidoController.text != widget.user.lastName ||
        _emailController.text != (widget.user.email ?? '') ||
        _phoneController.text != (widget.user.phone ?? '') ||
        _addressController.text != (widget.user.address ?? '');

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authCubit = context.read<AuthCubit>();

      final success = await authCubit.updateUser(
        username: _usernameController.text.trim(),
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          _hasChanges = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al actualizar el perfil'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    _initializeControllers();
    setState(() {
      _hasChanges = false;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título de la sección
          Text(
            'Información Personal',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Actualiza tu información personal',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // Campo: Username
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de usuario',
              hintText: 'Ingresa tu nombre de usuario',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre de usuario es obligatorio';
              }
              if (value.trim().length < 3) {
                return 'Mínimo 3 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Campo: Nombre
          TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'Ingresa tu nombre',
              prefixIcon: Icon(Icons.badge_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Campo: Apellido
          TextFormField(
            controller: _apellidoController,
            decoration: const InputDecoration(
              labelText: 'Apellido',
              hintText: 'Ingresa tu apellido',
              prefixIcon: Icon(Icons.badge_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El apellido es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Campo: Email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'tu@email.com',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Email no válido';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Campo: Teléfono
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              hintText: '+34 600 000 000',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Campo: Dirección
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              hintText: 'Calle, número, ciudad',
              prefixIcon: Icon(Icons.home_outlined),
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 32),

          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Botón: Cancelar/Resetear
              if (_hasChanges)
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : _resetForm,
                    child: const Text('Cancelar'),
                  ),
                ),

              if (_hasChanges) const SizedBox(width: 12),

              // Botón: Guardar
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading || !_hasChanges ? null : _saveProfile,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Guardando...' : 'Guardar cambios'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🔧 FUNCIONES HELPER
// ==========================================

/// Limpia query parameters antiguos y agrega un cache-buster para forzar recarga
String _getImageUrlWithCacheBuster(String url) {
  try {
    final uri = Uri.parse(url);
    // Construir URL sin query parameters
    final cleanUrl = uri.replace(query: '').toString();
    // Agregar nuevo cache-buster
    return '$cleanUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  } catch (e) {
    // Si hay error al parsear, retornar URL original
    return url;
  }
}

// ==========================================
// 📸 FUNCIÓN PARA CAMBIAR AVATAR
// ==========================================

/// Muestra el dialog para cambiar la foto de perfil del usuario
Future<void> _changeAvatar(BuildContext context, CmsUser user) async {
  final authCubit = context.read<AuthCubit>();

  try {
    // Usar un nombre fijo para el avatar para sobrescribirlo siempre
    final fileName = 'avatar';

    // Construir la ruta de carpetas para este usuario
    // Nota: No incluir el nombre del bucket en la ruta, solo la estructura de carpetas
    final folderPath = 'cms_users/user_${user.id}';

    // Mostrar dialog para seleccionar y subir imagen
    showImagePickerDialog(
      context: context,
      type: ImageUploadType.profile,
      fileName: fileName,
      folderPath: folderPath,
      title: 'Cambiar foto de perfil',
      subtitle: 'Selecciona una imagen para tu perfil',
      onError: (errorMessage) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Error al subir imagen: $errorMessage'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      onImageUploaded: (imageUrl) async {
        if (!context.mounted) return;

        try {
          final authCubit = context.read<AuthCubit>();

          // Actualizar avatar en la base de datos
          final success = await authCubit.updateUser(
            username: user.username,
            nombre: user.name,
            apellido: user.lastName,
            email: user.email,
            phone: user.phone,
            address: user.address,
            avatarUrl: imageUrl,
          );

          if (!context.mounted) return;

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Foto de perfil actualizada correctamente'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 3),
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
        } catch (e) {
          logger.error('Error updating avatar: $e');

          if (!context.mounted) return;

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
      },
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Error al seleccionar imagen: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

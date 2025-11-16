import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/cubit/auth_cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/cubit/auth_state.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/model/user.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/model/specialty.dart';
import 'package:opn_test_guardia_civil_cms/app/config/go_route/app_routes.dart';
import 'package:opn_test_guardia_civil_cms/app/config/layout/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/config/layout/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/academy/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/academy/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/config/widgets/pickImage/pick_image.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/repository/repository.dart';
import 'package:opn_test_guardia_civil_cms/bootstrap.dart';

class TopMenuWidget extends StatelessWidget {
  const TopMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final schemeColor = Theme.of(context).colorScheme;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState.user;

        return Container(
          height: 56,
          margin: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: schemeColor.primaryContainer,
            boxShadow: [
              BoxShadow(
                color: schemeColor.shadow.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: BlocBuilder<AppLayoutCubit, AppLayoutState>(
            builder: (context, layoutState) {
              return ClipRect(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ==========================================
                      // 🔹 SECCIÓN IZQUIERDA: Botón menú
                      // ==========================================
                      Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                context
                                    .read<AppLayoutCubit>()
                                    .toggleNavigation();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  layoutState.isNavigationExpanded
                                      ? Icons.menu
                                      : Icons.menu,
                                  color: schemeColor.onPrimary,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Logo o título de la academia del usuario
                          BlocBuilder<AcademyCubit, AcademyState>(
                            builder: (context, academyState) {
                              final academy = academyState.myAcademy;
                              if (academy != null && !academy.isEmpty) {
                                return InkWell(
                                  onTap: () {
                                    context.go(AppRoutes.academies);
                                  },
                                  child: _AcademyInfo(
                                    academyName: academy.name,
                                    logoUrl: academy.logoUrl,
                                    schemeColor: schemeColor,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          BlocSelector<AuthCubit, AuthState, CmsUser>(
                            selector: (state) => state.user,
                            builder: (context, user) {
                              if (user.specialty != null &&
                                  user.specialty!.name.isNotEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: schemeColor.onPrimary
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: schemeColor.outline
                                            .withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.school_rounded,
                                          color: schemeColor.onPrimary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            user.specialty!.name,
                                            style: TextStyle(
                                              color: schemeColor.onPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),

                      // ==========================================
                      // 🔹 SECCIÓN DERECHA: Usuario y acciones
                      // ==========================================
                      Row(
                        children: [
                          // Botón de tema
                          IconButton(
                            icon: Icon(
                              layoutState.isDarkMode
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                              color: schemeColor.onPrimary,
                            ),
                            tooltip: layoutState.isDarkMode
                                ? 'Modo claro'
                                : 'Modo oscuro',
                            onPressed: () {
                              context.read<AppLayoutCubit>().toggleDarkMode();
                            },
                          ),

                          const SizedBox(width: 16),

                          // Menú de usuario
                          _UserMenu(user: user),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ==========================================
// 👤 MENÚ DE USUARIO CON DESPLEGABLE
// ==========================================

class _UserMenu extends StatelessWidget {
  final CmsUser user;

  const _UserMenu({required this.user});

  @override
  Widget build(BuildContext context) {
    final schemeColor = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    // Extraer información del usuario
    final userName = user.name ?? '';
    final fullName = user.fullName;
    final userEmail = user.email ?? '';
    final userRole = user.roleName;
    final userImageUrl = user.avatarUrl;

    logger.info(user.specialty?.name);

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tooltip: 'Menú de usuario',
      onSelected: (value) {
        switch (value) {
          case 'profile':
            // Navegar al perfil usando GoRouter
            context.go(AppRoutes.profile);
            break;
          case 'especialidad':
            // Mostrar diálogo para cambiar especialidad
            _showChangeSpecialtyDialog(context, user);
            break;
          case 'settings':
            // Navegar a ajustes
            context.go(AppRoutes.settings);
            break;
          case 'logout':
            context.read<AuthCubit>().logout();
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        // Header con información del usuario
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildUserAvatar(userImageUrl, schemeColor),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: schemeColor.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // Mostrar rol del usuario
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user, schemeColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            userRole,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: schemeColor.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (userEmail.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            userEmail,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: schemeColor.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(
                height: 1,
                thickness: 1,
                color: schemeColor.outlineVariant,
              ),
            ],
          ),
        ),

        // Opción: Mi perfil
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 20,
                color: schemeColor.onSurface,
              ),
              const SizedBox(width: 12),
              Text(
                'Mi perfil',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        // Opción: Especialidad
        PopupMenuItem<String>(
          value: 'especialidad',
          child: Row(
            children: [
              Icon(
                Icons.school_outlined,
                size: 20,
                color: schemeColor.onSurface,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Especialidad',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (user.specialty != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.specialty!.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: schemeColor.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: schemeColor.onSurfaceVariant,
              ),
            ],
          ),
        ),

        // Opción: Configuración
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(
                Icons.settings_outlined,
                size: 20,
                color: schemeColor.onSurface,
              ),
              const SizedBox(width: 12),
              Text(
                'Configuración',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        // Divider
        const PopupMenuDivider(),

        // Opción: Cerrar sesión
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(
                Icons.logout,
                size: 20,
                color: schemeColor.error,
              ),
              const SizedBox(width: 12),
              Text(
                'Cerrar sesión',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: schemeColor.error,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: null, // El PopupMenuButton maneja el tap
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUserAvatar(userImageUrl, schemeColor, size: 32),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hola $userName',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: schemeColor.onPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userRole,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: schemeColor.onPrimary.withAlpha(100),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down_outlined,
                  color: schemeColor.onPrimary.withAlpha(125),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Obtiene el color del rol del usuario
  Color _getRoleColor(CmsUser user, ColorScheme colorScheme) {
    if (user.isAdmin) {
      return colorScheme.errorContainer; // Rojo/Rosa para Admin
    } else if (user.isAdmin) {
      return colorScheme.tertiaryContainer; // Morado para Editor
    } else if (user.isTutor) {
      return colorScheme.primaryContainer; // Azul para Tutor
    } else {
      return colorScheme.secondaryContainer; // Verde para User
    }
  }

  /// Construye el avatar del usuario
  Widget _buildUserAvatar(
    String? imageUrl,
    ColorScheme colorScheme, {
    double size = 40,
  }) {
    // Agregar cache-buster para forzar recarga de imagen
    final String? imageUrlWithCache = imageUrl != null && imageUrl.isNotEmpty
        ? _getImageUrlWithCacheBuster(imageUrl)
        : null;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: colorScheme.onSurface.withAlpha(50),
      backgroundImage:
          imageUrlWithCache != null ? NetworkImage(imageUrlWithCache) : null,
      child: imageUrlWithCache == null
          ? Icon(
              Icons.person,
              color: colorScheme.onPrimary,
              size: size * 0.6,
            )
          : SizedBox.shrink(),
    );
  }

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
}

// ==========================================
// 🏫 INFORMACIÓN DE LA ACADEMIA
// ==========================================

class _AcademyInfo extends StatelessWidget {
  final String academyName;
  final String? logoUrl;
  final ColorScheme schemeColor;

  const _AcademyInfo({
    required this.academyName,
    required this.logoUrl,
    required this.schemeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: schemeColor.onPrimary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: schemeColor.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo de la academia
          if (logoUrl != null && logoUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                logoUrl!,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultLogo();
                },
              ),
            )
          else
            _buildDefaultLogo(),

          const SizedBox(width: 8),

          // Nombre de la academia
          Flexible(
            child: Text(
              academyName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: schemeColor.onPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: schemeColor.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.business,
        color: schemeColor.onPrimary,
        size: 16,
      ),
    );
  }
}

// ==========================================
// 📚 DIÁLOGO PARA CAMBIAR ESPECIALIDAD
// ==========================================

void _showChangeSpecialtyDialog(BuildContext context, CmsUser user) {
  final specialtyRepository = SpecialtyRepository();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return FutureBuilder<List<Specialty>>(
        future: specialtyRepository.fetchSpecialties(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingDialog(context);
          }

          if (snapshot.hasError) {
            return _buildErrorDialog(context, snapshot.error.toString());
          }

          final specialties = snapshot.data ?? [];

          if (specialties.isEmpty) {
            return _buildErrorDialog(
              context,
              'No hay especialidades disponibles para tu academia.',
            );
          }

          return _buildSpecialtySelectionDialog(
            context,
            user,
            specialties,
            specialtyRepository,
          );
        },
      );
    },
  );
}

Widget _buildLoadingDialog(BuildContext context) {
  final theme = Theme.of(context);
  final schemeColor = theme.colorScheme;

  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: schemeColor.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando especialidades...',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );
}

Widget _buildErrorDialog(BuildContext context, String message) {
  final theme = Theme.of(context);
  final schemeColor = theme.colorScheme;

  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    title: Row(
      children: [
        Icon(Icons.error_outline, color: schemeColor.error),
        const SizedBox(width: 8),
        const Text('Error'),
      ],
    ),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cerrar'),
      ),
    ],
  );
}

Widget _buildSpecialtySelectionDialog(
  BuildContext context,
  CmsUser user,
  List<Specialty> specialties,
  SpecialtyRepository repository,
) {
  final theme = Theme.of(context);
  final schemeColor = theme.colorScheme;

  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    title: Row(
      children: [
        Icon(Icons.school_outlined, color: schemeColor.primary),
        const SizedBox(width: 8),
        const Text('Cambiar Especialidad'),
      ],
    ),
    content: SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona tu especialidad:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: schemeColor.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...specialties.map((specialty) {
            final isSelected = user.specialtyId == specialty.id;

            return InkWell(
              onTap: () => _handleSpecialtyChange(
                context,
                user,
                specialty,
                repository,
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? schemeColor.primary
                        : schemeColor.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected
                      ? schemeColor.primaryContainer.withOpacity(0.3)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    if (specialty.iconUrl != null &&
                        specialty.iconUrl!.isNotEmpty)
                      Image.network(
                        specialty.iconUrl!,
                        width: 32,
                        height: 32,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.school, color: schemeColor.primary),
                      )
                    else
                      Icon(Icons.school, color: schemeColor.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            specialty.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? schemeColor.primary
                                  : schemeColor.onSurface,
                            ),
                          ),
                          if (specialty.description != null &&
                              specialty.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              specialty.description!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: schemeColor.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: schemeColor.primary,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancelar'),
      ),
    ],
  );
}

void _handleSpecialtyChange(
  BuildContext context,
  CmsUser user,
  Specialty specialty,
  SpecialtyRepository repository,
) async {
  // No hacer nada si ya está seleccionada
  if (user.specialtyId == specialty.id) {
    Navigator.of(context).pop();
    return;
  }

  // Mostrar loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _buildLoadingDialog(context),
  );

  try {
    // Actualizar especialidad en la base de datos
    await repository.updateUserSpecialty(
      userId: user.id,
      specialtyId: specialty.id!,
    );

    // Actualizar el usuario en el AuthCubit
    final updatedUser = user.copyWith(
      specialtyId: specialty.id,
      specialty: specialty,
    );

    if (context.mounted) {
      context.read<AuthCubit>().updateUserState(updatedUser);

      // Cerrar el diálogo de loading
      Navigator.of(context).pop();
      // Cerrar el diálogo de selección
      Navigator.of(context).pop();

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Especialidad cambiada a "${specialty.name}"'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      // Cerrar el diálogo de loading
      Navigator.of(context).pop();

      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar especialidad: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

// ==========================================
// 📸 FUNCIÓN PARA CAMBIAR AVATAR
// ==========================================

/// Muestra el dialog para cambiar la foto de perfil del usuario
// Future<void> _changeUserAvatar(BuildContext context, CmsUser user) async {
//   final authCubit = context.read<AuthCubit>();

//   try {
//     // Generar nombre único para la imagen
//     final fileName = 'cms_users/user_${user.id}';

//     // Mostrar dialog para seleccionar y subir imagen
//     final String? imageUrl = await showImagePickerDialog(
//       context: context,
//       type: ImageUploadType.profile,
//       fileName: fileName,
//       title: 'Cambiar foto de perfil',
//       subtitle: 'Selecciona una imagen para tu perfil',
//     );

//     if (imageUrl != null && context.mounted) {
//       // Mostrar loading mientras se actualiza
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => Center(
//           child: Card(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const CircularProgressIndicator(),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Actualizando foto de perfil...',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );

//       try {
//         // Actualizar avatar en la base de datos
//         final success = await authCubit.updateUser(
//           username: user.username,
//           nombre: user.name,
//           apellido: user.lastName,
//           email: user.email,
//           phone: user.phone,
//           address: user.address,
//           avatarUrl: imageUrl,
//           specialtyId: user.specialtyId,
//         );

//         if (context.mounted) {
//           // Cerrar dialog de loading
//           Navigator.of(context).pop();

//           if (success) {
//             // Mostrar mensaje de éxito
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: const Row(
//                   children: [
//                     Icon(Icons.check_circle, color: Colors.white),
//                     SizedBox(width: 8),
//                     Text('Foto de perfil actualizada correctamente'),
//                   ],
//                 ),
//                 backgroundColor: Colors.green,
//                 behavior: SnackBarBehavior.floating,
//                 duration: const Duration(seconds: 3),
//               ),
//             );
//           } else {
//             // Mostrar error
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Row(
//                   children: [
//                     Icon(Icons.error_outline, color: Colors.white),
//                     SizedBox(width: 8),
//                     Text('Error al actualizar la foto de perfil'),
//                   ],
//                 ),
//                 backgroundColor: Colors.red,
//                 behavior: SnackBarBehavior.floating,
//                 duration: Duration(seconds: 3),
//               ),
//             );
//           }
//         }
//       } catch (e) {
//         if (context.mounted) {
//           // Cerrar dialog de loading
//           Navigator.of(context).pop();

//           // Mostrar error
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Row(
//                 children: [
//                   const Icon(Icons.error_outline, color: Colors.white),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Error: ${e.toString().replaceAll('Exception: ', '')}',
//                     ),
//                   ),
//                 ],
//               ),
//               backgroundColor: Colors.red,
//               behavior: SnackBarBehavior.floating,
//               duration: const Duration(seconds: 4),
//             ),
//           );
//         }
//       }
//     }
//   } catch (e) {
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               const Icon(Icons.error_outline, color: Colors.white),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text('Error al seleccionar imagen: ${e.toString()}'),
//               ),
//             ],
//           ),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }
// }

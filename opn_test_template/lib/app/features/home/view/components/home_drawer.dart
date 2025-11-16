import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opn_test_template/app/authentification/auth/cubit/auth_cubit.dart';
import 'package:opn_test_template/app/authentification/auth/model/user.dart';
import 'package:opn_test_template/app/config/go_route/app_routes.dart';
import 'package:opn_test_template/app/authentification/auth/model/academy.dart';
import 'package:opn_test_template/app/shared/services/purchase_service.dart';
import 'package:opn_test_template/app/shared/widgets/pick_image_dialog.dart';
import 'package:opn_test_template/app/features/specialty/view/pages/change_specialty_page.dart';
import 'package:url_launcher/url_launcher.dart'; // Added for launching URLs and emails

import '../../../profile/view/profile_page.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
    required this.user,
    this.academy,
  });

  final User user;
  final Academy? academy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Drawer(
      width: 320,
      backgroundColor: colors.surface,
      elevation: 12,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerHeader(user: user),
                const SizedBox(height: 8),
                _DrawerSection(
                  title: 'PERFIL',
                  children: [
                    _DrawerMenuItem(
                      icon: Icons.badge_outlined,
                      label: 'Mi perfil',
                      subtitle: 'Gestiona tus datos personales',
                      colorScheme: colors,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(ProfilePage.route());
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.school_outlined,
                      label: 'Especialidad',
                      subtitle: 'Cambia tu especialidad',
                      colorScheme: colors,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ChangeSpecialtyPage(),
                          ),
                        );
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.insights_outlined,
                      label: 'Estadísticas',
                      subtitle: 'Tu evolución y resultados',
                      colorScheme: colors,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.stats);
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.workspace_premium,
                      label: 'Suscripción',
                      subtitle: 'Mejora tu cuenta a Premium',
                      colorScheme: colors,
                      onTap: () async {
                        Navigator.of(context).pop();
                        await PurchaseService.instance.showPaywall(
                          context: context,
                        );
                      },
                    ),
                  ],
                ),
                _DrawerSection(
                  title: 'ESTUDIO',
                  children: [

                    _DrawerMenuItem(
                      icon: Icons.timer_outlined,
                      label: 'Pomodoro',
                      subtitle: 'Temporiza tus sesiones de estudio',
                      colorScheme: colors,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.pomodoro);
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.history,
                      label: 'Historial',
                      subtitle: 'Revisa tus últimos tests',
                      colorScheme: colors,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.history);
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.star,
                      label: 'Favoritas',
                      subtitle: 'Preguntas guardadas',
                      colorScheme: colors,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.favorites);
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.gavel_rounded,
                      label: 'Impugnaciones',
                      subtitle: 'Reportar errores en preguntas',
                      colorScheme: colors,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.challenges);
                      },
                    ),
                  ],
                ),

                _DrawerSection(
                  title: 'CONFIGURACIÓN',
                  children: [
                    _DrawerMenuItem(
                      icon: Icons.settings_outlined,
                      label: 'Preferencias',
                      subtitle: 'Personaliza la aplicación',
                      colorScheme: colors,
                      onTap: () => _showSnack(context, 'Configuración'),
                    ),
                    _DrawerMenuItem(
                      icon: Icons.chat_outlined,
                      label: 'Configuración Chat IA',
                      subtitle: 'Personaliza tu asistente inteligente',
                      colorScheme: colors,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.chatSettings);
                      },
                    ),
                    _DrawerMenuItem(
                      icon: Icons.logout,
                      label: 'Cerrar sesión',
                      subtitle: 'Salir de tu cuenta',
                      colorScheme: colors,
                      onTap: () async {
                        Navigator.of(context).pop();
                        await context.read<AuthCubit>().logout();
                        if (context.mounted) {
                          context.go(AppRoutes.signin);
                        }
                      },
                    ),
                  ],
                ),
                _BottomStatus(user: user, academy: academy),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text('Acción: $label')),
      );
    Navigator.of(context).maybePop();
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fullName = _resolveName();
    final initials = _initialsFor(fullName);
    final email = user.email ?? 'Sin correo';
    final isTester = user.tester ?? false;

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
            colorScheme.tertiary.withOpacity(0.85),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Editar avatar próximamente')),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.secondaryContainer.withOpacity(0.55),
                            colorScheme.secondary.withOpacity(0.35),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.onSecondaryContainer
                                .withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => _changeProfileImage(context),
                      borderRadius: BorderRadius.circular(30),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: colorScheme.surface,
                            foregroundColor: colorScheme.onSurface,
                            backgroundImage: _avatarProvider(),
                            child: user.profileImage == null ||
                                    user.profileImage!.isEmpty
                                ? Text(
                                    initials,
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.primary,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 12,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hola, $fullName',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isTester)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.secondary,
                            colorScheme.secondaryContainer,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.secondary.withOpacity(0.32),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'TESTER',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.surfaceTint.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mail_outline,
                      size: 16,
                      color: colorScheme.onPrimary.withOpacity(0.85),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        email,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider<Object>? _avatarProvider() {
    final url = user.profileImage;
    if (url != null && url.isNotEmpty) {
      return NetworkImage(url);
    }
    return null;
  }

  String _resolveName() {
    final first = user.firstName;
    final last = user.lastName;
    if (first != null && first.isNotEmpty) {
      final lastPart = last != null && last.isNotEmpty ? ' $last' : '';
      return '$first$lastPart';
    }
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    if (user.username.isNotEmpty) {
      return user.username;
    }
    return 'Invitado';
  }

  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> _changeProfileImage(BuildContext context) async {
    try {
      await openImagePicker(
        context: context,
        onSave: (XFile image) async {
          try {
            // Leer bytes de la imagen
            final imageBytes = await image.readAsBytes();

            // Determinar extensión y mimeType
            final extension = image.name.split('.').last.toLowerCase();
            final mimeType = image.mimeType ?? 'image/jpeg';

            // Actualizar en el cubit
            if (context.mounted) {
              await context.read<AuthCubit>().updateProfileImage(
                    imageBytes: imageBytes,
                    extension: extension,
                    mimeType: mimeType,
                  );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Foto de perfil actualizada correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al actualizar la foto: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        maxWidth: 512,
        maxHeight: 512,
        quality: 85,
        showCropInterface: true,
        useCameraPlugin: true,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 6),
            child: Text(
              title,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colorScheme,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle!,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
                if (trailing == null)
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomStatus extends StatelessWidget {
  const _BottomStatus({
    required this.user,
    this.academy,
  });

  final User user;
  final Academy? academy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final total = user.totalQuestions;
    final right = user.rightQuestions;
    final wrong = user.wrongQuestions;
    final blank = (total - right - wrong).clamp(0, total);

    double successRatio = 0;
    if (total > 0) {
      successRatio = right / total;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withOpacity(0.35),
            colors.secondary.withOpacity(0.45),
          ],
        ),
        border: Border(
          top: BorderSide(color: colors.outlineVariant.withOpacity(0.4)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (academy != null) ...[
            Text(
              'Tu academia',
              style: textTheme.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((academy?.logoUrl ?? '').isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      academy!.logoUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _PlaceholderLogo(colors: colors),
                    ),
                  )
                else
                  _PlaceholderLogo(colors: colors),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        academy!.name,
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if ((academy!.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          academy!.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if ((academy!.contactEmail ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoLine(
                icon: Icons.mail_outline,
                label: academy!.contactEmail!,
                color: colors,
                textTheme: textTheme,
                onTap: () => _launchEmail(context, academy!.contactEmail!),
              ),
            ],
            if ((academy!.website ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoLine(
                icon: Icons.public,
                label: academy!.website!,
                color: colors,
                textTheme: textTheme,
                onTap: () => _launchUrl(context, academy!.website!),
              ),
            ],
            const SizedBox(height: 12),
            Divider(
              height: 20,
              color: colors.outlineVariant.withOpacity(0.4),
            ),
            const SizedBox(height: 8),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'No pudimos obtener la información de tu academia.',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              height: 20,
              color: colors.outlineVariant.withOpacity(0.4),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  // Function to launch URLs
  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir $url')),
      );
    }
  }

  // Function to launch email client
  Future<void> _launchEmail(BuildContext context, String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el cliente de correo')),
      );
    }
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.color,
    required this.textTheme,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final ColorScheme color;
  final TextTheme textTheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: onTap != null ? color.primary : color.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: onTap != null ? color.primary : color.onSurfaceVariant,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderLogo extends StatelessWidget {
  const _PlaceholderLogo({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.4)),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.school_outlined,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.onSurfaceVariant,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

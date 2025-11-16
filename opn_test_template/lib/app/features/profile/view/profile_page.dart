import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../authentification/auth/cubit/auth_state.dart';
import '../../../authentification/auth/model/user.dart';
import '../../../authentification/auth/model/user_membership.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const ProfilePage());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary,
              colors.primaryContainer,
              colors.secondary.withOpacity(0.9),
            ],
          ),

          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(

          child: BlocSelector<AuthCubit, AuthState, User>(
            selector: (state) => state.user,
            builder: (context, user) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _ProfileHeader(user: user)),
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [

                          _InfoCard(user: user),
                          const SizedBox(height: 20),
                          _MembershipCard(user: user),
                          const SizedBox(height: 20),
                          _ActivityCard(user: user),
                          const SizedBox(height: 20),
                          const _DeleteAccountCard(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final name = _resolveName();
    final initials = _initialsFor(name);
    final subtitle = user.username.isNotEmpty ? '@${user.username}' : null;

    return Container(

      padding: const EdgeInsets.fromLTRB(8, 32, 8, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios_new, color: colors.onPrimary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Avatar(
                initials: initials,
                imageUrl: user.profileImage,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _ProfileChip(
                          icon: Icons.mail_outline,
                          label: user.email ?? 'Sin correo',
                        ),
                        if (user.tester ?? false)
                          _ProfileChip(
                            icon: Icons.workspace_premium,
                            label: 'Tester',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  String _resolveName() {
    final first = user.firstName;
    final last = user.lastName;
    if (first != null && first.isNotEmpty) {
      final lastPart = last != null && last.isNotEmpty ? ' $last' : '';
      return '$first$lastPart';
    }
    if ((user.displayName ?? '').isNotEmpty) {
      return user.displayName!;
    }
    if (user.username.isNotEmpty) return user.username;
    return 'Usuario';
  }

  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, required this.imageUrl});

  final String initials;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            colors.onPrimary.withOpacity(0.24),
            colors.primaryContainer.withOpacity(0.2),
          ],
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: CircleAvatar(
        radius: 42,
        backgroundColor: colors.surface,
        foregroundColor: colors.primary,
        backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
            ? NetworkImage(imageUrl!)
            : null,
        child: imageUrl == null || imageUrl!.isEmpty
            ? Text(
                initials,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              )
            : null,
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.surfaceTint.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.onPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}



class _StatBadge extends StatelessWidget {
  const _StatBadge({
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Información personal',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _InfoTile(
              icon: Icons.badge_outlined,
              label: 'Nombre completo',
              value: _fullName(),
            ),
            const SizedBox(height: 16),
            _InfoTile(
              icon: Icons.alternate_email,
              label: 'Usuario',
              value: user.username.isNotEmpty ? user.username : '--',
            ),
            const SizedBox(height: 16),
            _InfoTile(
              icon: Icons.mail_outline,
              label: 'Email',
              value: user.email ?? '--',
            ),
            const SizedBox(height: 16),
            _InfoTile(
              icon: Icons.phone_outlined,
              label: 'Teléfono',
              value: user.phone ?? 'No disponible',
              isEditable: true,
              onTap: () => _onEditPhone(context),
            ),
          ],
        ),
      ),
    );
  }

  String _fullName() {
    final first = user.firstName ?? '';
    final last = user.lastName ?? '';
    final combined = '$first $last'.trim();
    if (combined.isEmpty) return 'No disponible';
    return combined;
  }

  Future<void> _onEditPhone(BuildContext context) async {
    final newPhone = await _showPhoneDialog(context);
    if (newPhone == null) return;

    final normalizedNew = newPhone.trim();
    final current = (user.phone ?? '').trim();
    if (normalizedNew == current) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('El teléfono no ha cambiado.'),
          ),
        );
      return;
    }

    try {
      await context.read<AuthCubit>().updatePhone(normalizedNew);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Teléfono actualizado correctamente.'),
          ),
        );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('No se pudo actualizar el teléfono.'),
          ),
        );
    }
  }

  Future<String?> _showPhoneDialog(BuildContext context) async {
    final controller = TextEditingController(text: user.phone ?? '');
    String? error;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Actualizar teléfono'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Introduce tu número',
                      errorText: error,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final value = controller.text.trim();
                    if (value.isNotEmpty) {
                      final digits = value.replaceAll(RegExp(r'\D'), '');
                      if (digits.length < 6) {
                        setState(() {
                          error = 'Introduce un teléfono válido.';
                        });
                        return;
                      }
                    }
                    Navigator.of(dialogContext).pop(value);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.isEditable = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isEditable;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final borderRadius = BorderRadius.circular(16);

    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEditable)
                Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}


class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final activeMembership = _activeMembership();
    final membershipLevel = activeMembership?.membershipLevel;
    final planName = membershipLevel?.name ?? 'Plan gratuito';
    final expiresAt = activeMembership?.expiresAt;
    final accessLevel = membershipLevel?.accessLevel ?? 0;
    final levelLabel = accessLevel <= 1 ? 'Free' : 'Nivel $accessLevel';

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium_outlined, color: colors.secondary),
                const SizedBox(width: 8),
                Text(
                  'Tu plan',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.secondary.withOpacity(0.2),
                        colors.secondaryContainer.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    levelLabel,
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              planName.isEmpty ? 'Plan personalizado' : planName,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.secondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              membershipLevel?.description ??
                  'Disfruta de todo el contenido disponible en la plataforma.',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _PlanFeature(
                  icon: Icons.check_circle_outlined,
                  label: activeMembership != null
                      ? 'Suscripción activa'
                      : 'Plan gratuito',
                ),
                const SizedBox(width: 16),
                _PlanFeature(
                  icon: Icons.autorenew,
                  label: activeMembership?.autoRenews == true
                      ? 'Renovación automática'
                      : 'Renovación manual',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (expiresAt != null)
              Text(
                'Renueva el ${_formatDate(expiresAt)}',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              )
            else
              Text(
                'Sin fecha de caducidad asignada.',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _onManageSubscription(context),
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Administrar suscripción'),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.secondary,
                  foregroundColor: colors.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  UserMembership? _activeMembership() {
    final memberships = List<UserMembership>.from(user.userMemberships);
    if (memberships.isEmpty) return null;

    final validMemberships =
        memberships.where((m) => m.isValidAndActive).toList();
    final source = validMemberships.isEmpty ? memberships : validMemberships;

    source.sort((a, b) {
      final accessA = a.membershipLevel?.accessLevel ?? 0;
      final accessB = b.membershipLevel?.accessLevel ?? 0;
      return accessB.compareTo(accessA);
    });
    return source.first;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _onManageSubscription(BuildContext context) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final managementUrl = customerInfo.managementURL;

      if (managementUrl != null) {
        final uri = Uri.parse(managementUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              const SnackBar(
                content: Text('No se pudo abrir la URL de administración'),
              ),
            );
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('No hay URL de administración disponible'),
            ),
          );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('Error al obtener información de suscripción: $e'),
          ),
        );
    }
  }
}

class _PlanFeature extends StatelessWidget {
  const _PlanFeature({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: colors.secondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final lastUsed = user.lastUsed != null
        ? _formatDateTime(user.lastUsed!)
        : 'Aún sin actividad';
    final createdAt = user.createdAt != null
        ? _formatDateTime(user.createdAt!)
        : 'Desconocido';
    final updatedAt = user.updatedAt != null
        ? _formatDateTime(user.updatedAt!)
        : 'Sin cambios';

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_toggle_off, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Actividad reciente',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ActivityTile(
              label: 'Último acceso',
              value: lastUsed,
              icon: Icons.login,
            ),
            const SizedBox(height: 12),
            _ActivityTile(
              label: 'Cuenta creada',
              value: createdAt,
              icon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 12),
            _ActivityTile(
              label: 'Última actualización',
              value: updatedAt,
              icon: Icons.update,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year · $hour:$minute';
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountCard extends StatelessWidget {
  const _DeleteAccountCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colors.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_outlined, color: colors.error),
                const SizedBox(width: 8),
                Text(
                  'Zona de peligro',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Esta acción es irreversible. Una vez eliminada tu cuenta, no podrás recuperar tus datos.',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onErrorContainer,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _onDeleteAccount(context),
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Eliminar mi cuenta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                  side: BorderSide(color: colors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onDeleteAccount(BuildContext context) async {
    final confirmed = await _showPasswordConfirmationBottomSheet(context);

    if (confirmed != true) return;

    // Guardar el navigator antes de hacer el async
    if (!context.mounted) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Eliminando cuenta...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Llamar al método de eliminación del AuthCubit
      await context.read<AuthCubit>().deleteAccount();

      // Cerrar el diálogo de loading antes de que se haga el logout
      navigator.pop();

      // La navegación al login se manejará automáticamente por el cambio de estado de AuthCubit
    } catch (e) {
      // Cerrar el diálogo de loading
      navigator.pop();

      // Mostrar error
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la cuenta: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
    }
  }

  Future<bool?> _showPasswordConfirmationBottomSheet(BuildContext context) async {
    final confirmationController = TextEditingController();
    String? errorMessage;

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.warning_outlined,
                            color: Theme.of(context).colorScheme.error,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Confirmar eliminación',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Esta acción no se puede deshacer',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          const TextSpan(text: 'Para confirmar, escribe '),
                          TextSpan(
                            text: 'eliminar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const TextSpan(text: ' en el campo de abajo:'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmationController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Confirmación',
                        hintText: 'Escribe "eliminar"',
                        prefixIcon: const Icon(Icons.edit_outlined),
                        errorText: errorMessage,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (_) {
                        if (errorMessage != null) {
                          setState(() {
                            errorMessage = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(bottomSheetContext).pop(false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              final enteredText = confirmationController.text.trim();

                              if (enteredText.isEmpty) {
                                setState(() {
                                  errorMessage = 'Debes escribir algo para continuar';
                                });
                                return;
                              }

                              if (enteredText.toLowerCase() != 'eliminar') {
                                setState(() {
                                  errorMessage = 'Debes escribir exactamente "eliminar"';
                                });
                                return;
                              }

                              // Confirmación correcta
                              Navigator.of(bottomSheetContext).pop(true);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.error,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Eliminar cuenta'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

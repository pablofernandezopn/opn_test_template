import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/model/user.dart';
import 'package:opn_test_guardia_civil_cms/app/config/widgets/buttons/modern_icon_button.dart';
import 'package:opn_test_guardia_civil_cms/app/config/widgets/roleLocker/role_based_widget.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/model/specialty.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/view/components/dialogForm.dart';

class SpecialtiesPage extends StatelessWidget {
  const SpecialtiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpecialtyCubit, SpecialtyState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state.createStatus.isDone &&
            state.createStatus.message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.createStatus.message)),
          );
        }
        if (state.updateStatus.isDone &&
            state.updateStatus.message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.updateStatus.message)),
          );
        }

        if (state.deleteStatus.isDone &&
            state.deleteStatus.message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.deleteStatus.message)),
          );
        }
      },
      child: BlocBuilder<SpecialtyCubit, SpecialtyState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Especialidades'),
              actions: [
                RoleBasedWidget(
                  allowedRoles: const [UserRole.superAdmin],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ModernIconButton(
                      icon: Icons.add,
                      tooltip: 'Crear nueva especialidad',
                      onPressed: () => _showSpecialtyDialog(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ModernIconButton(
                    icon: Icons.refresh,
                    tooltip: 'Actualizar',
                    onPressed: () =>
                        context.read<SpecialtyCubit>().loadSpecialties(),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.only(
                  top: 16, right: 16, left: 16, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, state),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildContent(context, state),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SpecialtyState state) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestión de Especialidades',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Administra las especialidades disponibles en el sistema',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        _buildStatsCards(context, state),
      ],
    );
  }

  Widget _buildStatsCards(BuildContext context, SpecialtyState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final active = state.specialties.where((s) => s.isActive).length;
    final total = state.specialties.length;

    return Row(
      children: [
        _StatCard(
          label: 'Especialidades Activas',
          value: '$active/$total',
          icon: Icons.check_circle_outline,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Total Especialidades',
          value: '$total',
          icon: Icons.school_outlined,
          color: colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, SpecialtyState state) {
    if (state.fetchStatus.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.fetchStatus.isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar especialidades',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => context.read<SpecialtyCubit>().loadSpecialties(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.specialties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No hay especialidades',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Crea tu primera especialidad'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: state.sortedSpecialties.length,
      itemBuilder: (context, index) {
        final specialty = state.sortedSpecialties[index];
        return _SpecialtyCard(specialty: specialty);
      },
    );
  }

  void _showSpecialtyDialog(BuildContext context, [Specialty? specialty]) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SpecialtyCubit>(),
        child: SpecialtyFormDialog(specialty: specialty),
      ),
    );
  }
}

class _SpecialtyCard extends StatelessWidget {
  final Specialty specialty;

  const _SpecialtyCard({required this.specialty});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = specialty.colorHex != null
        ? Color(int.parse('0xFF${specialty.colorHex!.replaceAll('#', '')}'))
        : colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withAlpha((0.2 * 255).round()),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Acción al hacer clic en la tarjeta si es necesario
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono/Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: specialty.iconUrl != null
                      ? Image.network(
                          specialty.iconUrl!,
                          width: 28,
                          height: 28,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.school,
                            color: color,
                            size: 28,
                          ),
                        )
                      : Icon(
                          Icons.school,
                          color: color,
                          size: 28,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specialty.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialty.slug,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (specialty.description != null &&
                        specialty.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        specialty.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Estado
              Chip(
                label: Text(
                  specialty.isActive ? 'Activo' : 'Inactivo',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor:
                    specialty.isActive ? Colors.green[100] : Colors.grey[300],
                side: BorderSide.none,
              ),
              const SizedBox(width: 8),
              // Acciones
              RoleBasedWidget(
                allowedRoles: const [UserRole.superAdmin],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditDialog(context),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(context),
                      tooltip: 'Eliminar',
                    ),
                    Switch(
                      value: specialty.isActive,
                      onChanged: (value) {
                        context
                            .read<SpecialtyCubit>()
                            .toggleActive(specialty.id!, value);
                      },
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

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SpecialtyCubit>(),
        child: SpecialtyFormDialog(specialty: specialty),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Especialidad'),
        content: Text('¿Estás seguro de eliminar "${specialty.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await context
                  .read<SpecialtyCubit>()
                  .deleteSpecialty(specialty.id!);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Especialidad eliminada')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withAlpha((0.3 * 255).round()),
        ),
      ),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color ?? colorScheme.primary, size: 22),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

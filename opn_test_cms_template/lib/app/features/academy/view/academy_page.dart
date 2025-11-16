import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_guardia_civil_cms/app/config/widgets/table/reorderable_table.dart';
import '../../../config/go_route/app_routes.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';
import '../model/academy_model.dart';
import 'academy_detail_page.dart';
import 'components/academy_form_dialog.dart';
import 'components/delete_academy_dialog.dart';

/// Página de gestión de academias.
///
/// Muestra una tabla con todas las academias y permite crear, editar y eliminar
/// (solo para Super Admin).
class AcademyPage extends StatelessWidget {
  const AcademyPage({super.key});

  static const String route = '/academies';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AcademyCubit, AcademyState>(
        builder: (context, state) {
          if (state.fetchStatus.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.fetchStatus.isError) {
            return _buildErrorView(context, state.fetchStatus.message);
          }

          return _buildContent(context, state);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AcademyState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cubit = context.read<AcademyCubit>();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
                    colorScheme.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.business,
                color: colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestión de Academias',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: ${state.totalAcademies} | Activas: ${state.totalActiveAcademies} | Inactivas: ${state.totalInactiveAcademies}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Botón de refrescar
            IconButton.outlined(
              onPressed: () => cubit.refreshAcademies(),
              icon: const Icon(Icons.refresh),
              tooltip: 'Refrescar',
            ),
            const SizedBox(width: 8),
            // Botón de crear (solo Super Admin)
            if (cubit.isAdmin)
              FilledButton.icon(
                onPressed: () => _showAcademyDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Nueva Academia'),
              ),
          ],
        ),

        const SizedBox(height: 24),

        // Tabla
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: state.academies.isEmpty
              ? _buildEmptyState(context)
              : _buildDataTable(context, state),
        ),
      ],
    );
  }

  Widget _buildDataTable(BuildContext context, AcademyState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final cubit = context.read<AcademyCubit>();

    return ReorderableTable<Academy>(
      items: state.academies,
      showDragHandle: false,
      onReorder: (oldIndex, newIndex) {
        // Implementar lógica de reordenamiento si es necesario
      },
      columns: [
        ReorderableTableColumnConfig<Academy>(
          id: 'id',
          label: 'ID',
          width: 60,
          valueGetter: (academy) => academy.id?.toString() ?? '-',
          alignment: Alignment.center,
        ),
        ReorderableTableColumnConfig<Academy>(
          id: 'name',
          label: 'Nombre',
          flex: 3,
          valueGetter: (academy) => academy.name,
          cellBuilder: (academy) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                academy.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              if (academy.description != null) ...[
                const SizedBox(height: 2),
                Text(
                  academy.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        ReorderableTableColumnConfig<Academy>(
          id: 'slug',
          label: 'Slug',
          flex: 2,
          valueGetter: (academy) => academy.slug,
        ),
        ReorderableTableColumnConfig<Academy>(
          id: 'status',
          label: 'Estado',
          flex: 1,
          alignment: Alignment.center,
          valueGetter: (academy) => academy.isActive ? 'Activa' : 'Inactiva',
          cellBuilder: (academy) => Chip(
            label: Text(academy.isActive ? 'Activa' : 'Inactiva'),
            backgroundColor: academy.isActive
                ? colorScheme.primaryContainer
                : colorScheme.errorContainer,
            labelStyle: TextStyle(
              color: academy.isActive
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onErrorContainer,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        // ReorderableTableColumnConfig<Academy>(
        //   id: 'cms_users',
        //   label: 'Usuarios CMS',
        //   width: 120,
        //   alignment: Alignment.center,
        //   valueGetter: (academy) {
        //     final stats =
        //         state.allAcademiesStats[academy.id] ?? <String, int>{};
        //     return stats['total_cms_users']?.toString() ?? '-';
        //   },
        //   cellBuilder: (academy) {
        //     final stats =
        //         state.allAcademiesStats[academy.id] ?? <String, int>{};
        //     final count = stats['total_cms_users'] ?? 0;
        //     return Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Icon(
        //           Icons.admin_panel_settings,
        //           size: 16,
        //           color: colorScheme.primary,
        //         ),
        //         const SizedBox(width: 4),
        //         Text(
        //           count.toString(),
        //           style: const TextStyle(fontWeight: FontWeight.w600),
        //         ),
        //       ],
        //     );
        //   },
        // ),
        ReorderableTableColumnConfig<Academy>(
          id: 'app_users',
          label: 'Usuarios App',
          width: 120,
          alignment: Alignment.center,
          valueGetter: (academy) {
            final stats =
                state.allAcademiesStats[academy.id] ?? <String, int>{};
            return stats['total_users']?.toString() ?? '-';
          },
          cellBuilder: (academy) {
            final stats =
                state.allAcademiesStats[academy.id] ?? <String, int>{};
            final count = stats['total_users'] ?? 0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  count.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            );
          },
        ),
        ReorderableTableColumnConfig<Academy>(
          id: 'topics',
          label: 'Topics',
          width: 90,
          alignment: Alignment.center,
          valueGetter: (academy) {
            final stats =
                state.allAcademiesStats[academy.id] ?? <String, int>{};
            return stats['total_tests']?.toString() ?? '-';
          },
          cellBuilder: (academy) {
            final stats =
                state.allAcademiesStats[academy.id] ?? <String, int>{};
            final count = stats['total_tests'] ?? 0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.topic,
                  size: 16,
                  color: colorScheme.tertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  count.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            );
          },
        ),
        ReorderableTableColumnConfig<Academy>(
          id: 'questions',
          label: 'Preguntas',
          width: 100,
          alignment: Alignment.center,
          valueGetter: (academy) {
            final stats =
                state.allAcademiesStats[academy.id] ?? <String, int>{};
            return stats['total_questions']?.toString() ?? '-';
          },
          cellBuilder: (academy) {
            final stats =
                state.allAcademiesStats[academy.id] ?? <String, int>{};
            final count = stats['total_questions'] ?? 0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz,
                  size: 16,
                  color: colorScheme.tertiary.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  count.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            );
          },
        ),
      ],
      onItemTap: (academy) =>
          context.go('${AppRoutes.academies}/${academy.id}'),
      rowActions: (academy) {
        final actions = <Widget>[];

        // Botón de editar (solo Super Admin)
        if (cubit.isAdmin) {
          actions.add(
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showAcademyDialog(context, academy),
              tooltip: 'Editar',
              iconSize: 20,
              color: colorScheme.primary,
            ),
          );
        }

        // Botón de cambiar estado (solo Super Admin && no es la academia OPN)
        // if (cubit.isAdmin && academy.id != 1) {
        //   actions.add(
        //     IconButton(
        //       icon: Icon(
        //         academy.isActive ? Icons.toggle_on : Icons.toggle_off,
        //       ),
        //       onPressed: () => cubit.toggleAcademyStatus(
        //         academy.id!,
        //         !academy.isActive,
        //       ),
        //       tooltip: academy.isActive ? 'Desactivar' : 'Activar',
        //       iconSize: 20,
        //       color: academy.isActive
        //           ? colorScheme.primary
        //           : colorScheme.onSurfaceVariant,
        //     ),
        //   );
        // }

        // Botón de eliminar (solo Super Admin, no se puede eliminar OPN)
        if (cubit.isAdmin && academy.id != 1) {
          actions.add(
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context, academy),
              tooltip: 'Eliminar',
              iconSize: 20,
              color: colorScheme.error,
            ),
          );
        }

        return actions;
      },
      emptyMessage: 'No hay academias disponibles',
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay academias',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera academia para comenzar',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.read<AcademyCubit>().refreshAcademies(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showAcademyDialog(BuildContext context, [Academy? academy]) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AcademyCubit>(),
        child: AcademyFormDialog(academy: academy),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Academy academy) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AcademyCubit>(),
        child: DeleteAcademyDialog(academy: academy),
      ),
    );
  }
}

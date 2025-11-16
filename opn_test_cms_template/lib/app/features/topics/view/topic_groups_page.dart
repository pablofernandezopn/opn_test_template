import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_group_model.dart';

import '../../../config/go_route/app_routes.dart';
import '../../../config/widgets/buttons/modern_icon_button.dart';
import '../../../config/widgets/table/reorderable_table.dart';
import 'components/create_topic_group_dialog.dart';

class TopicGroupsPage extends StatefulWidget {
  const TopicGroupsPage({super.key});

  static const String route = '/topic-groups';

  @override
  State<TopicGroupsPage> createState() => _TopicGroupsPageState();
}

class _TopicGroupsPageState extends State<TopicGroupsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TopicCubit>().fetchTopicGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TopicCubit, TopicState>(
      listenWhen: (previous, current) =>
          previous.createTopicGroupStatus != current.createTopicGroupStatus ||
          previous.updateTopicGroupStatus != current.updateTopicGroupStatus ||
          previous.deleteTopicGroupStatus != current.deleteTopicGroupStatus,
      listener: (context, state) {
        if (state.createTopicGroupStatus.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.createTopicGroupStatus.message),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state.updateTopicGroupStatus.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.updateTopicGroupStatus.message),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state.deleteTopicGroupStatus.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.deleteTopicGroupStatus.message),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state.createTopicGroupStatus.isDone) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Grupo creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (state.updateTopicGroupStatus.isDone) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Grupo actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (state.deleteTopicGroupStatus.isDone) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Grupo eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: BlocBuilder<TopicCubit, TopicState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Grupos de Tópicos'),
              centerTitle: true,
              automaticallyImplyLeading:
                  MediaQuery.of(context).size.width < 600,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ModernIconButton(
                    icon: Icons.add,
                    tooltip: 'Crear nuevo grupo',
                    onPressed: () => _showCreateTopicGroupDialog(context),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ModernIconButton(
                    icon: Icons.refresh,
                    tooltip: 'Actualizar',
                    onPressed: () =>
                        context.read<TopicCubit>().fetchTopicGroups(),
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
                  _buildHeader(context, state.topicGroups),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 16, left: 16, right: 16, bottom: 0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SizedBox(
                              height: constraints.maxHeight,
                              width: constraints.maxWidth,
                              child: ReorderableTable<TopicGroup>(
                                items: state.topicGroups,
                                columns: _buildColumns(context),
                                onReorder: (oldIndex, newIndex) {
                                  // Implementación del reordenamiento si es necesario
                                  // Por ahora lo dejamos vacío ya que no parece necesario para categorías
                                }, // No hay reordenamiento para grupos
                                onItemTap: (group) {
                                  if (group.id != null) {
                                    context.push(
                                        AppRoutes.topicGroupDetail(group.id!));
                                  }
                                },
                                rowActions: (group) => [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _showEditTopicGroupDialog(
                                        context, group),
                                    tooltip: 'Editar',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 20, color: Colors.red),
                                    onPressed: () =>
                                        _showDeleteDialog(context, group),
                                    tooltip: 'Eliminar',
                                  ),
                                ],
                                showDragHandle: false,
                                isLoading:
                                    state.fetchTopicGroupsStatus.isLoading,
                                emptyMessage:
                                    'No hay grupos de tópicos disponibles',
                              ),
                            );
                          },
                        ),
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

  Widget _buildHeader(BuildContext context, List<TopicGroup> groups) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestión de Grupos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Organiza tus tópicos en grupos para una mejor gestión',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        _buildStatsCards(context, groups),
      ],
    );
  }

  Widget _buildStatsCards(BuildContext context, List<TopicGroup> groups) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = groups.where((g) => g.enabled).length;
    final premium = groups.where((g) => g.isPremium).length;

    return Row(
      children: [
        _StatCard(
          label: 'Grupos Activos',
          value: '$enabled/${groups.length}',
          icon: Icons.check_circle_outline,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Premium',
          value: '$premium',
          icon: Icons.stars_outlined,
          color: colorScheme.secondary,
        ),
      ],
    );
  }

  List<ReorderableTableColumnConfig<TopicGroup>> _buildColumns(
      BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return [
      ReorderableTableColumnConfig<TopicGroup>(
        id: 'id',
        label: 'ID',
        flex: 1,
        valueGetter: (group) => group.id?.toString() ?? '-',
      ),
      ReorderableTableColumnConfig<TopicGroup>(
        id: 'name',
        label: 'Nombre',
        flex: 3,
        valueGetter: (group) => group.name,
      ),
      ReorderableTableColumnConfig<TopicGroup>(
        id: 'description',
        label: 'Descripción',
        flex: 3,
        valueGetter: (group) => group.description ?? '-',
        cellBuilder: (group) => Text(
          group.description ?? '-',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: group.description == null
                ? Colors.grey
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      ReorderableTableColumnConfig<TopicGroup>(
        id: 'status',
        label: 'Estado',
        flex: 1,
        valueGetter: (group) => group.enabled ? 'Activo' : 'Inactivo',
        cellBuilder: (group) => Chip(
          label: Text(
            group.enabled ? 'Activo' : 'Inactivo',
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: group.enabled ? Colors.green[100] : Colors.grey[300],
          side: BorderSide.none,
        ),
      ),
      ReorderableTableColumnConfig<TopicGroup>(
        id: 'premium',
        label: 'Premium',
        flex: 1,
        valueGetter: (group) => group.isPremium ? 'Sí' : 'No',
        cellBuilder: (group) => group.isPremium
            ? const Icon(Icons.stars, color: Colors.amber, size: 20)
            : const Icon(Icons.star_border, color: Colors.grey, size: 20),
      ),
      ReorderableTableColumnConfig<TopicGroup>(
        id: 'publishedAt',
        label: 'Publicado',
        flex: 2,
        valueGetter: (group) => group.publishedAt != null
            ? dateFormat.format(group.publishedAt!)
            : 'No publicado',
        cellBuilder: (group) {
          final isPublished = group.publishedAt != null;
          final color = isPublished ? Colors.green : Colors.grey;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withAlpha((0.5 * 255).round()),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPublished ? Icons.check_circle : Icons.schedule,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    isPublished
                        ? dateFormat.format(group.publishedAt!)
                        : 'No publicado',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      ReorderableTableColumnConfig<TopicGroup>(
        id: 'createdAt',
        label: 'Creado',
        flex: 2,
        valueGetter: (group) =>
            group.createdAt != null ? dateFormat.format(group.createdAt!) : '-',
      ),
    ];
  }

  void _showCreateTopicGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TopicCubit>(),
        child: const CreateTopicGroupDialog(),
      ),
    );
  }

  void _showEditTopicGroupDialog(BuildContext context, TopicGroup group) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TopicCubit>(),
        child: CreateTopicGroupDialog(groupToEdit: group),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TopicGroup group) {
    if (group.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar: ID del grupo inválido.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (sbContext, setState) {
          final typed = controller.text;
          final matches = typed.trim() == group.name.trim();

          return AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Para confirmar la eliminación escribe EXACTAMENTE el nombre del grupo abajo:',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Advertencia: Al eliminar este grupo, puede afectar a los tópicos asociados. Esta acción no se puede deshacer.',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nombre del grupo: "${group.name}"',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Escribe el nombre exacto del grupo',
                  ),
                ),
                const SizedBox(height: 8),
                if (controller.text.isNotEmpty && !matches)
                  const Text(
                    'El texto no coincide con el nombre del grupo.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(sbContext).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: matches
                    ? () {
                        context.read<TopicCubit>().deleteTopicGroup(group.id!);
                        Navigator.of(sbContext).pop();
                      }
                    : null,
                child: const Text('Eliminar'),
              ),
            ],
          );
        },
      ),
    ).then((_) {
      try {
        controller.dispose();
      } catch (_) {}
    });
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
            color: colorScheme.outline.withAlpha((0.3 * 255).round())),
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

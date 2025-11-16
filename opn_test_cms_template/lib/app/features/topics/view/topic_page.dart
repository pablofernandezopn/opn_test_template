import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_model.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_type_model.dart';

import '../../../config/go_route/app_routes.dart';
import '../../../config/widgets/buttons/modern_icon_button.dart';
import '../../../config/widgets/table/reorderable_table.dart';
import 'components/add_to_group_with_management_dialog.dart';
import 'components/create_topic_dialog.dart';
import 'components/edit_topic_type_dialog.dart';
import 'components/schedule_publication_dialog.dart';

class TopicsManagementScreen extends StatefulWidget {
  final int topicTypeId;

  const TopicsManagementScreen({
    super.key,
    required this.topicTypeId,
  });

  @override
  State<TopicsManagementScreen> createState() => _TopicsManagementScreenState();
}

class _TopicsManagementScreenState extends State<TopicsManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar los topics de este tipo cuando se monta la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TopicCubit>().fetchTopicsByType(widget.topicTypeId);
      context.read<TopicCubit>().fetchTopicGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TopicCubit, TopicState>(
      listenWhen: (previous, current) =>
          previous.createTopicStatus != current.createTopicStatus ||
          previous.updateTopicStatus != current.updateTopicStatus ||
          previous.deleteTopicStatus != current.deleteTopicStatus ||
          previous.updateTopicTypeStatus != current.updateTopicTypeStatus,
      listener: (context, state) {
        // Manejar error en creación
        if (state.createTopicStatus.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.createTopicStatus.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }

        // Manejar error en actualización de Topic
        if (state.updateTopicStatus.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.updateTopicStatus.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }

        // Manejar error en actualización de TopicType
        if (state.updateTopicTypeStatus.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.updateTopicTypeStatus.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }

        // Manejar error en eliminación
        if (state.deleteTopicStatus.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.deleteTopicStatus.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: BlocBuilder<TopicCubit, TopicState>(
        builder: (context, state) {
          final topicType = state.topicTypes
              .where((type) => type.id == widget.topicTypeId)
              .firstOrNull;

          if (topicType == null) {
            return _buildErrorScreen(context);
          }

          final topicsForType = state.topics
              .where((topic) => topic.topicTypeId == widget.topicTypeId)
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'Tests de ${topicType.topicTypeName}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ModernIconButton(
                    icon: Icons.edit,
                    tooltip: 'Editar nombre y descripción',
                    onPressed: () =>
                        _showEditTopicTypeDialog(context, topicType),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ModernIconButton(
                    icon: Icons.add,
                    tooltip: 'Crear nuevo test',
                    onPressed: () =>
                        _showCreateTopicDialog(context, widget.topicTypeId),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ModernIconButton(
                    icon: Icons.refresh,
                    tooltip: 'Actualizar',
                    onPressed: () => context
                        .read<TopicCubit>()
                        .fetchTopicsByType(widget.topicTypeId),
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
                  _buildHeader(context, topicType, topicsForType),
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
                              child: ReorderableTable<Topic>(
                                items: topicsForType,
                                columns: _buildColumns(context, state),
                                onReorder: (oldIndex, newIndex) {
                                  // El ajuste del índice ya se hace en ReorderableTable
                                  context.read<TopicCubit>().reorderTopics(
                                        topicTypeId: widget.topicTypeId,
                                        oldIndex: oldIndex,
                                        newIndex: newIndex,
                                      );
                                },
                                onItemTap: (topic) {
                                  // Usar path param en lugar de extra para soporte web
                                  context.push(
                                      AppRoutes.questionsByTopic(topic.id!));
                                },
                                // rowActions: (topic) => [

                                // ],
                                showDragHandle: true,
                                isLoading:
                                    state.fetchTopicsByTypeStatus.isLoading,
                                emptyMessage:
                                    'No hay tests disponibles para este tipo',
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

  Widget _buildHeader(
      BuildContext context, TopicType topicType, List<Topic> topics) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topicType.topicTypeName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              if (topicType.description != null &&
                  topicType.description!.isNotEmpty)
                Text(
                  topicType.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        _buildStatsCards(context, topics),
      ],
    );
  }

  Widget _buildStatsCards(BuildContext context, List<Topic> topics) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = topics.where((t) => t.enabled).length;
    final totalQuestions = topics.fold(0, (sum, t) => sum + t.totalQuestions);

    return Row(
      children: [
        _StatCard(
          label: 'Tests Activos',
          value: '$enabled/${topics.length}',
          icon: Icons.check_circle_outline,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Total Preguntas',
          value: '$totalQuestions',
          icon: Icons.quiz_outlined,
          color: colorScheme.secondary,
        ),
      ],
    );
  }

  List<ReorderableTableColumnConfig<Topic>> _buildColumns(
      BuildContext context, TopicState state) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return [
      ReorderableTableColumnConfig<Topic>(
        id: 'id',
        label: 'ID',
        flex: 1,
        valueGetter: (topic) => topic.id?.toString() ?? '-',
      ),
      ReorderableTableColumnConfig<Topic>(
        id: 'name',
        label: 'Nombre',
        flex: 2,
        valueGetter: (topic) => topic.topicName,
      ),
      ReorderableTableColumnConfig<Topic>(
        id: 'topic_group_id',
        label: 'Grupo',
        flex: 2,
        valueGetter: (topic) {
          if (topic.topicGroupId != null) {
            final group = state.topicGroups
                .where((g) => g.id == topic.topicGroupId)
                .firstOrNull;
            return group?.name ?? 'Grupo ${topic.topicGroupId}';
          }
          return 'Sin grupo';
        },
        cellBuilder: (topic) {
          final hasGroup = topic.topicGroupId != null;
          final group = hasGroup
              ? state.topicGroups
                  .where((g) => g.id == topic.topicGroupId)
                  .firstOrNull
              : null;

          final colorScheme = Theme.of(context).colorScheme;
          final groupColor = hasGroup
              ? colorScheme.primary
              : colorScheme.onSurface.withAlpha((0.6 * 255).round());
          final removeColor = colorScheme.error.withAlpha((0.7 * 255).round());
          final addColor = colorScheme.tertiary.withAlpha((0.7 * 255).round());

          return InkWell(
            onTap: () {
              if (hasGroup) {
                _showRemoveFromGroupDialog(context, topic);
              } else {
                _showAddToGroupDialog(context, topic);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: hasGroup
                    ? colorScheme.primary.withAlpha((0.15 * 255).round())
                    : colorScheme.onSurface.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hasGroup
                      ? colorScheme.primary.withAlpha((0.5 * 255).round())
                      : colorScheme.onSurface.withAlpha((0.3 * 255).round()),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasGroup ? Icons.folder : Icons.folder_open,
                    size: 16,
                    color: groupColor,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      group?.name ??
                          (hasGroup
                              ? 'Grupo ${topic.topicGroupId}'
                              : 'Sin grupo'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: groupColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    hasGroup
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline,
                    size: 14,
                    color: hasGroup ? removeColor : addColor,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      ReorderableTableColumnConfig<Topic>(
        id: 'status',
        label: 'Estado',
        alignment: Alignment.center,
        flex: 1,
        valueGetter: (topic) => topic.enabled ? 'Activo' : 'Inactivo',
        cellBuilder: (topic) => Chip(
          label: Text(
            topic.enabled ? 'Activo' : 'Inactivo',
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: topic.enabled
              ? Theme.of(context).colorScheme.surfaceContainerHigh
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          side: BorderSide.none,
        ),
      ),
      ReorderableTableColumnConfig<Topic>(
        id: 'questions',
        label: 'Preguntas',
        flex: 1,
        alignment: Alignment.center,
        valueGetter: (topic) => topic.totalQuestions.toString(),
      ),
      ReorderableTableColumnConfig<Topic>(
        id: 'publishedAt',
        label: 'Publicado',
        alignment: Alignment.center,
        flex: 1,
        valueGetter: (topic) {
          final status = PublicationStatus.fromTopic(topic);
          if (topic.publishedAt != null) {
            final label = status == PublicationStatus.scheduled
                ? 'Programado'
                : status.label;
            return '$label - ${dateFormat.format(topic.publishedAt!)}';
          }
          return status.label;
        },
        cellBuilder: (topic) {
          final status = PublicationStatus.fromTopic(topic);
          final showDate = topic.publishedAt != null;
          final dateStr = showDate ? dateFormat.format(topic.publishedAt!) : '';

          return InkWell(
            onTap: () => _showSchedulePublicationDialog(context, topic),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: status.color.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: status.color.withAlpha((0.5 * 255).round()),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    status.icon,
                    size: 16,
                    color: status.color,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          status == PublicationStatus.scheduled
                              ? 'Programado'
                              : status.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: status.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit,
                    size: 14,
                    color: status.color.withAlpha((0.7 * 255).round()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      ReorderableTableColumnConfig<Topic>(
          id: 'durationSeconds',
          label: 'Acciones',
          flex: 1,
          alignment: Alignment.center,
          valueGetter: (topic) => '',
          cellBuilder: (topic) {
            return Row(children: [
              IconButton(
                icon: const Icon(Icons.dashboard, size: 20),
                onPressed: () {
                  if (topic.id != null) {
                    context.push(AppRoutes.topicDashboard(topic.id!));
                  }
                },
                tooltip: 'Dashboard',
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _showEditTopicDialog(context, topic),
                tooltip: 'Editar',
              ),
              IconButton(
                icon: Icon(Icons.delete,
                    size: 20, color: Theme.of(context).colorScheme.error),
                onPressed: () => _showDeleteDialog(context, topic),
                tooltip: 'Eliminar',
              ),
            ]);
          })
    ];
  }

  void _showCreateTopicDialog(BuildContext context, int topicTypeId) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TopicCubit>(),
        child: CreateTopicDialog(topicTypeId: topicTypeId),
      ),
    );
  }

  void _showEditTopicTypeDialog(BuildContext context, TopicType topicType) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<TopicCubit>(),
        child: EditTopicTypeDialog(topicType: topicType),
      ),
    );
  }

  void _showEditTopicDialog(BuildContext context, Topic topic) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TopicCubit>(),
        child: CreateTopicDialog(
          topicTypeId: topic.topicTypeId,
          topicToEdit: topic,
        ),
      ),
    );
  }

  void _showSchedulePublicationDialog(BuildContext context, Topic topic) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TopicCubit>(),
        child: SchedulePublicationDialog(topic: topic),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Topic topic) {
    // Si no hay id, mostrar mensaje y salir
    if (topic.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se puede eliminar: ID del test inválida.'),
          backgroundColor: Theme.of(context).colorScheme.error,
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
          final matches = typed.trim() == topic.topicName.trim();

          return AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Para confirmar la eliminación escribe EXACTAMENTE el nombre del test abajo:',
                ),
                const SizedBox(height: 8),
                Text(
                  'Advertencia: Al eliminar este test, también se borrarán todas las preguntas asociadas y esta acción no se puede deshacer.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nombre del test: "${topic.topicName}"',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Escribe el nombre exacto del test',
                  ),
                ),
                const SizedBox(height: 8),
                if (controller.text.isNotEmpty && !matches)
                  Text(
                    'El texto no coincide con el nombre del test.',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12),
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
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: matches
                    ? () {
                        context.read<TopicCubit>().deleteTopic(topic.id!);
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
      // Dispose controller when the dialog is closed
      try {
        controller.dispose();
      } catch (_) {}
    });
  }

  void _showAddToGroupDialog(BuildContext context, Topic topic) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddToGroupWithManagementDialog(topic: topic),
    );
  }

  void _showRemoveFromGroupDialog(BuildContext context, Topic topic) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quitar del grupo'),
        content: Text(
          '¿Estás seguro de que deseas quitar "${topic.topicName}" del grupo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              final updatedTopic = topic.copyWith(
                topicGroupId: null,
                groupOrder: null,
              );
              context.read<TopicCubit>().updateTopic(topic.id!, updatedTopic);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Quitar'),
          )
        ],
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text(
            'No se pudo cargar el tipo de test. Vuelve atrás e inténtalo de nuevo.'),
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

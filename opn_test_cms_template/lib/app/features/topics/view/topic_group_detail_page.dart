import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:intl/intl.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/cubit/auth_cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_group_model.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_model.dart';
import 'package:opn_test_guardia_civil_cms/bootstrap.dart';

import '../../../config/widgets/buttons/modern_icon_button.dart';
import 'components/create_topic_group_dialog.dart';
import 'components/topic_group_header.dart';

/// Página de gestión individual de un Topic Group.
///
/// Muestra información detallada del grupo, estadísticas y permite editar.
/// Además permite asignar/desasignar topics al grupo.
class TopicGroupDetailPage extends StatefulWidget {
  final int topicGroupId;

  const TopicGroupDetailPage({
    super.key,
    required this.topicGroupId,
  });

  static const String route = '/topic-group-detail';

  @override
  State<TopicGroupDetailPage> createState() => _TopicGroupDetailPageState();
}

class _TopicGroupDetailPageState extends State<TopicGroupDetailPage> {
  final ResizableController _resizableController = ResizableController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TopicCubit>().fetchTopicGroups();
      // También cargar todos los topics para poder filtrarlos
      context.read<TopicCubit>().fetchTopics();
    });
  }

  @override
  void dispose() {
    _resizableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<TopicCubit, TopicState>(
      listenWhen: (previous, current) =>
          previous.updateTopicGroupStatus != current.updateTopicGroupStatus ||
          previous.updateTopicStatus != current.updateTopicStatus,
      listener: (context, state) {
        // if (state.updateTopicGroupStatus.isError) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(state.updateTopicGroupStatus.message),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        // }

        // if (state.updateTopicGroupStatus.isDone) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text('Grupo actualizado exitosamente'),
        //       backgroundColor: Colors.green,
        //     ),
        //   );
        // }

        // if (state.updateTopicStatus.isDone) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text('Topic actualizado exitosamente'),
        //       backgroundColor: Colors.green,
        //     ),
        //   );
        // }
      },
      child: BlocBuilder<TopicCubit, TopicState>(
        builder: (context, state) {
          // Buscar el grupo por ID
          final topicGroup = state.topicGroups.firstWhere(
            (g) => g.id == widget.topicGroupId,
            orElse: () => TopicGroup.empty,
          );

          // Si el grupo no se encontró, mostrar loading o error
          if (topicGroup.id == null) {
            if (state.fetchTopicGroupsStatus.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Grupo no encontrado'),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No se pudo encontrar el grupo',
                        style: textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Volver'),
                      ),
                    ],
                  ),
                ),
              );
            }
          }

          // Filtrar topics asignados y no asignados
          final assignedTopics = state.topics
              .where((topic) => topic.topicGroupId == widget.topicGroupId)
              .toList();

          final userSpecialtyId =
              context.read<AuthCubit>().state.user.specialtyId;

          final unassignedTopics = state.topics
              .where((topic) =>
                  topic.topicGroupId == null &&
                  topic.specialtyId == userSpecialtyId &&
                  topic.topicTypeId == 3)
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Icon(
                    topicGroup.isPremium ? Icons.stars : Icons.folder_outlined,
                    color: topicGroup.isPremium ? Colors.amber : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      topicGroup.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              centerTitle: false,
              // automaticallyImplyLeading:
              //     MediaQuery.of(context).size.width < 600,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ModernIconButton(
                    icon: Icons.edit,
                    tooltip: 'Editar grupo',
                    onPressed: () =>
                        _showEditTopicGroupDialog(context, topicGroup),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ModernIconButton(
                    icon: Icons.refresh,
                    tooltip: 'Actualizar',
                    onPressed: () {
                      context.read<TopicCubit>().fetchTopicGroups();
                      context.read<TopicCubit>().fetchTopics();
                    },
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información básica del grupo
                // Padding(
                //   padding: const EdgeInsets.all(24),
                //   child: _buildInfoCard(
                //       context, topicGroup, assignedTopics.length),
                // ),

                // Header de gestión del grupo
                Padding(
                  padding: const EdgeInsets.only(
                      top: 24, left: 24, right: 24, bottom: 24),
                  child: TopicGroupHeader(topicGroup: topicGroup),
                ),

                // Sección principal dividida con ResizableContainer
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                    child: ResizableContainer(
                      controller: _resizableController,
                      direction: Axis.horizontal,
                      children: [
                        // Lado izquierdo: Topics asignados
                        ResizableChild(
                          child: _buildAssignedTopicsSection(
                            context,
                            assignedTopics,
                            state.fetchTopicsStatus.isLoading,
                          ),
                          divider: const ResizableDivider(
                            color: Colors.grey,
                            thickness: 0.5,
                            padding: 2,
                          ),
                        ),
                        // Lado derecho: Topics sin asignar
                        ResizableChild(
                          child: _buildUnassignedTopicsSection(
                            context,
                            unassignedTopics,
                            state.fetchTopicsStatus.isLoading,
                          ),
                          divider: const ResizableDivider(
                            color: Colors.grey,
                            thickness: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, TopicGroup topicGroup, int assignedCount) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Información General',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    topicGroup.name,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (topicGroup.description != null &&
                      topicGroup.description!.isNotEmpty)
                    Text(
                      topicGroup.description!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: Icon(
                          topicGroup.enabled
                              ? Icons.check_circle
                              : Icons.cancel,
                          size: 18,
                          color:
                              topicGroup.enabled ? Colors.green : Colors.grey,
                        ),
                        label: Text(
                          topicGroup.enabled ? 'Activo' : 'Inactivo',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: topicGroup.enabled
                            ? Colors.green[100]
                            : Colors.grey[300],
                        side: BorderSide.none,
                      ),
                      Chip(
                        avatar: Icon(
                          topicGroup.isPremium ? Icons.stars : Icons.public,
                          size: 18,
                          color: topicGroup.isPremium
                              ? Colors.amber
                              : colorScheme.primary,
                        ),
                        label: Text(
                          topicGroup.isPremium ? 'Premium' : 'Gratuito',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: topicGroup.isPremium
                            ? Colors.amber[100]
                            : colorScheme.primaryContainer,
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Estadísticas
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatCard(
                  label: 'Topics Asignados',
                  value: '$assignedCount',
                  icon: Icons.topic,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 12),
                if (topicGroup.publishedAt != null)
                  _InfoChip(
                    icon: Icons.publish,
                    label: 'Publicado',
                    value: dateFormat.format(topicGroup.publishedAt!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedTopicsSection(
      BuildContext context, List<Topic> topics, bool isLoading) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Ordenar topics por group_order
    final sortedTopics = List<Topic>.from(topics)
      ..sort((a, b) {
        final orderA = a.groupOrder ?? 999999;
        final orderB = b.groupOrder ?? 999999;
        return orderA.compareTo(orderB);
      });

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  colorScheme.primaryContainer.withAlpha((0.3 * 255).round()),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Topics Asignados',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${topics.length}',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : topics.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: colorScheme.onSurfaceVariant
                                    .withAlpha((0.3 * 255).round()),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay topics asignados',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Agrega topics desde la lista de la derecha',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: sortedTopics.length,
                        onReorder: (oldIndex, newIndex) {
                          _onReorderTopics(
                              context, sortedTopics, oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final topic = sortedTopics[index];
                          return _buildTopicCard(
                            context,
                            topic,
                            isAssigned: true,
                            key: ValueKey(topic.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnassignedTopicsSection(
      BuildContext context, List<Topic> topics, bool isLoading) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  colorScheme.secondaryContainer.withAlpha((0.3 * 255).round()),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.playlist_add,
                  color: colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Topics Disponibles',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${topics.length}',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : topics.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: colorScheme.onSurfaceVariant
                                    .withAlpha((0.3 * 255).round()),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Todos los topics están asignados',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: topics.length,
                        itemBuilder: (context, index) {
                          final topic = topics[index];
                          return _buildTopicCard(
                            context,
                            topic,
                            isAssigned: false,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(
    BuildContext context,
    Topic topic, {
    required bool isAssigned,
    Key? key,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withAlpha((0.2 * 255).round()),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: topic.enabled
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.topic,
            color: topic.enabled
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        title: Text(
          topic.topicName,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${topic.totalQuestions} preguntas',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: topic.enabled
                      ? Colors.green.withAlpha((0.2 * 255).round())
                      : Colors.grey.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  topic.enabled ? 'Activo' : 'Inactivo',
                  style: textTheme.labelSmall?.copyWith(
                    color: topic.enabled ? Colors.green[700] : Colors.grey[700],
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            isAssigned ? Icons.remove_circle_outline : Icons.add_circle_outline,
            color: isAssigned ? Colors.red : colorScheme.primary,
          ),
          tooltip: isAssigned ? 'Desasignar del grupo' : 'Asignar al grupo',
          onPressed: () => _toggleTopicAssignment(context, topic, isAssigned),
        ),
      ),
    );
  }

  void _onReorderTopics(
    BuildContext context,
    List<Topic> sortedTopics,
    int oldIndex,
    int newIndex,
  ) {
    // Ajustar newIndex si es necesario (peculiaridad de ReorderableListView)
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Crear una nueva lista con el topic reordenado
    final reorderedTopics = List<Topic>.from(sortedTopics);
    final movedTopic = reorderedTopics.removeAt(oldIndex);
    reorderedTopics.insert(newIndex, movedTopic);

    // Actualizar el group_order de todos los topics (índice + 1)
    for (int i = 0; i < reorderedTopics.length; i++) {
      final topic = reorderedTopics[i];
      if (topic.id == null) continue;

      final newGroupOrder = i + 1;

      logger.info(newGroupOrder);
      // Solo actualizar si el order cambió
      if (topic.groupOrder != newGroupOrder) {
        final updatedTopic = topic.copyWith(groupOrder: newGroupOrder);
        context.read<TopicCubit>().updateTopic(topic.id!, updatedTopic);
      }
    }
  }

  void _toggleTopicAssignment(
      BuildContext context, Topic topic, bool currentlyAssigned) {
    if (topic.id == null) return;

    if (currentlyAssigned) {
      // Al desasignar, limpiar topicGroupId y groupOrder
      final updatedTopic = topic.copyWith(
        topicGroupId: null,
        groupOrder: null,
      );
      context.read<TopicCubit>().updateTopic(topic.id!, updatedTopic);
    } else {
      // Al asignar, establecer topicGroupId y calcular el próximo groupOrder
      final assignedTopics = context
          .read<TopicCubit>()
          .state
          .topics
          .where((t) => t.topicGroupId == widget.topicGroupId)
          .toList();

      // Encontrar el máximo groupOrder actual
      final maxGroupOrder = assignedTopics.isEmpty
          ? 0
          : assignedTopics
              .map((t) => t.groupOrder ?? -1)
              .reduce((a, b) => a > b ? a : b);

      final updatedTopic = topic.copyWith(
        topicGroupId: widget.topicGroupId,
        groupOrder: maxGroupOrder + 1,
      );
      context.read<TopicCubit>().updateTopic(topic.id!, updatedTopic);
    }
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

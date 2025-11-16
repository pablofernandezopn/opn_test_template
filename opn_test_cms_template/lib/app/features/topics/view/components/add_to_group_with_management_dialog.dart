import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_group_model.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_model.dart';

class AddToGroupWithManagementDialog extends StatefulWidget {
  final Topic topic;

  const AddToGroupWithManagementDialog({
    super.key,
    required this.topic,
  });

  @override
  State<AddToGroupWithManagementDialog> createState() =>
      _AddToGroupWithManagementDialogState();
}

class _AddToGroupWithManagementDialogState
    extends State<AddToGroupWithManagementDialog> {
  TopicGroup? _groupToEdit;
  bool _isCreatingOrEditing = false;
  final Set<int> _expandedGroups = {};

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _enabled = true;
  bool _isPremium = false;
  DateTime? _publishedAt;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _startCreating() {
    setState(() {
      _isCreatingOrEditing = true;
      _groupToEdit = null;
      _nameController.clear();
      _descriptionController.clear();
      _enabled = true;
      _isPremium = false;
      _publishedAt = null;
    });
  }

  void _startEditing(TopicGroup group) {
    setState(() {
      _isCreatingOrEditing = true;
      _groupToEdit = group;
      _nameController.text = group.name;
      _descriptionController.text = group.description ?? '';
      _enabled = group.enabled;
      _isPremium = group.isPremium;
      _publishedAt = group.publishedAt;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isCreatingOrEditing = false;
      _groupToEdit = null;
      _nameController.clear();
      _descriptionController.clear();
      _enabled = true;
      _isPremium = false;
      _publishedAt = null;
    });
  }

  Future<void> _handleSaveGroup(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final cubit = context.read<TopicCubit>();

    if (_groupToEdit != null) {
      final updatedGroup = _groupToEdit!.copyWith(
        name: name,
        description: description.isEmpty ? null : description,
        enabled: _enabled,
        isPremium: _isPremium,
        publishedAt: _publishedAt,
        updatedAt: DateTime.now(),
      );
      await cubit.updateTopicGroup(_groupToEdit!.id!, updatedGroup);
    } else {
      final newGroup = TopicGroup(
        name: name,
        description: description.isEmpty ? null : description,
        academyId: 1,
        enabled: _enabled,
        isPremium: _isPremium,
        publishedAt: _publishedAt,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await cubit.createTopicGroup(newGroup);
    }

    _cancelEditing();
  }

  void _handleDeleteGroup(BuildContext context, TopicGroup group) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar grupo'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el grupo "${group.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<TopicCubit>().deleteTopicGroup(group.id!);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _handleAssignToGroup(BuildContext context, TopicGroup group) {
    context.read<TopicCubit>().updateTopic(
          widget.topic.id!,
          widget.topic.copyWith(topicGroupId: group.id),
        );
    context.pop();
  }

  void _toggleGroupExpansion(int groupId) {
    setState(() {
      if (_expandedGroups.contains(groupId)) {
        _expandedGroups.remove(groupId);
      } else {
        _expandedGroups.add(groupId);
      }
    });
  }

  Future<void> _selectPublishedDate() async {
    final now = DateTime.now();
    final initialDate = _publishedAt ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (time == null || !mounted) return;

    setState(() {
      _publishedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TopicCubit, TopicState>(
      listenWhen: (previous, current) =>
          previous.createTopicGroupStatus != current.createTopicGroupStatus ||
          previous.updateTopicGroupStatus != current.updateTopicGroupStatus ||
          previous.deleteTopicGroupStatus != current.deleteTopicGroupStatus,
      listener: (context, state) {
        if (state.createTopicGroupStatus.isDone ||
            state.updateTopicGroupStatus.isDone) {
          _cancelEditing();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          height: 700,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header minimalista
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Añadir a grupo',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.topic.topicName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isCreatingOrEditing
                    ? _buildGroupForm(context)
                    : _buildGroupList(context),
              ),

              // Footer minimalista
              if (!_isCreatingOrEditing)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _startCreating,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Crear grupo'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
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

  Widget _buildGroupList(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, state) {
        final groups = state.topicGroups;

        if (state.fetchTopicGroupsStatus.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (groups.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 56,
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay grupos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primer grupo para organizar los tests',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: groups.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final group = groups[index];
            return _buildGroupCard(context, group);
          },
        );
      },
    );
  }

  Widget _buildGroupCard(BuildContext context, TopicGroup group) {
    final isExpanded = _expandedGroups.contains(group.id);
    final groupTopics = context
        .read<TopicCubit>()
        .state
        .topics
        .where((topic) => topic.topicGroupId == group.id)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _handleAssignToGroup(context, group),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                group.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (group.isPremium)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Premium',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            if (!group.enabled)
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Oculto',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (group.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            group.description!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          '${groupTopics.length} test${groupTopics.length != 1 ? 's' : ''}',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Actions minimalistas
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _startEditing(group),
                        tooltip: 'Editar',
                        style: IconButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () => _handleDeleteGroup(context, group),
                        tooltip: 'Eliminar',
                        style: IconButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      if (groupTopics.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 18,
                          ),
                          onPressed: () => _toggleGroupExpansion(group.id!),
                          tooltip: isExpanded ? 'Contraer' : 'Expandir',
                          style: IconButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Lista de topics expandible
          if (isExpanded && groupTopics.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: groupTopics.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final topic = groupTopics[index];
                      final isCurrentTopic = topic.id == widget.topic.id;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrentTopic
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withOpacity(0.3)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 16,
                              color: isCurrentTopic
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                topic.topicName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isCurrentTopic
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : null,
                                      fontWeight: isCurrentTopic
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupForm(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, state) {
        final isLoading = state.createTopicGroupStatus.isLoading ||
            state.updateTopicGroupStatus.isLoading;

        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _groupToEdit != null ? 'Editar grupo' : 'Nuevo grupo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      hintText: 'Ej: Temas Generales',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.3),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                    autofocus: true,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Descripción del grupo (opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.3),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Switches minimalistas
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Habilitado'),
                          subtitle: const Text('Visible en la aplicación'),
                          value: _enabled,
                          onChanged: isLoading
                              ? null
                              : (value) => setState(() => _enabled = value),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                        ),
                        Divider(
                            height: 1,
                            color: Theme.of(context)
                                .dividerColor
                                .withOpacity(0.1)),
                        SwitchListTile(
                          title: const Text('Premium'),
                          subtitle: const Text('Solo usuarios premium'),
                          value: _isPremium,
                          onChanged: isLoading
                              ? null
                              : (value) => setState(() => _isPremium = value),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Publication date
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha de publicación',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _publishedAt != null
                                    ? _formatDateTime(_publishedAt!)
                                    : 'Sin fecha',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: _publishedAt != null
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (_publishedAt != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: isLoading
                                ? null
                                : () => setState(() => _publishedAt = null),
                            tooltip: 'Quitar fecha',
                          ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today_outlined,
                              size: 18),
                          onPressed: isLoading ? null : _selectPublishedDate,
                          tooltip: 'Seleccionar fecha',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isLoading ? null : _cancelEditing,
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed:
                            isLoading ? null : () => _handleSaveGroup(context),
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                _groupToEdit != null ? 'Actualizar' : 'Crear'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

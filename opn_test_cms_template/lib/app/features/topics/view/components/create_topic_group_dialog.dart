import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_group_model.dart';

class CreateTopicGroupDialog extends StatefulWidget {
  final TopicGroup? groupToEdit;

  const CreateTopicGroupDialog({
    super.key,
    this.groupToEdit,
  });

  @override
  State<CreateTopicGroupDialog> createState() => _CreateTopicGroupDialogState();
}

class _CreateTopicGroupDialogState extends State<CreateTopicGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _enabled;
  late bool _isPremium;
  DateTime? _publishedAt;

  bool get isEditing => widget.groupToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.groupToEdit?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.groupToEdit?.description ?? '');
    _enabled = widget.groupToEdit?.enabled ?? true;
    _isPremium = widget.groupToEdit?.isPremium ?? false;
    _publishedAt = widget.groupToEdit?.publishedAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TopicCubit, TopicState>(
      listenWhen: (previous, current) =>
          previous.createTopicGroupStatus != current.createTopicGroupStatus ||
          previous.updateTopicGroupStatus != current.updateTopicGroupStatus,
      listener: (context, state) {
        if (state.createTopicGroupStatus.isDone ||
            state.updateTopicGroupStatus.isDone) {
          context.pop();
        }
      },
      child: AlertDialog(
        title: Text(isEditing ? 'Editar Grupo' : 'Crear Nuevo Grupo'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    hintText: 'Ej: Temas Generales',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Descripción del grupo',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Configuración',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Habilitado'),
                  subtitle:
                      const Text('El grupo estará visible en la aplicación'),
                  value: _enabled,
                  onChanged: (value) {
                    setState(() {
                      _enabled = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Premium'),
                  subtitle: const Text('Solo usuarios premium pueden acceder'),
                  value: _isPremium,
                  onChanged: (value) {
                    setState(() {
                      _isPremium = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fecha de publicación',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _publishedAt != null
                            ? 'Publicado: ${_formatDateTime(_publishedAt!)}'
                            : 'Sin fecha de publicación',
                        style: TextStyle(
                          color:
                              _publishedAt != null ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                    if (_publishedAt != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _publishedAt = null;
                          });
                        },
                        tooltip: 'Quitar fecha',
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today, size: 20),
                      onPressed: _selectPublishedDate,
                      tooltip: 'Seleccionar fecha',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancelar'),
          ),
          BlocBuilder<TopicCubit, TopicState>(
            builder: (context, state) {
              final isLoading = state.createTopicGroupStatus.isLoading ||
                  state.updateTopicGroupStatus.isLoading;

              return ElevatedButton(
                onPressed: isLoading ? null : _handleSubmit,
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Actualizar' : 'Crear'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    final cubit = context.read<TopicCubit>();
    // final authCubit = cubit._authCubit;
    final academyId = 1;

    if (isEditing) {
      final updatedGroup = widget.groupToEdit!.copyWith(
        name: name,
        description: description.isEmpty ? null : description,
        enabled: _enabled,
        isPremium: _isPremium,
        publishedAt: _publishedAt,
        updatedAt: DateTime.now(),
      );
      cubit.updateTopicGroup(widget.groupToEdit!.id!, updatedGroup);
    } else {
      final newGroup = TopicGroup(
        name: name,
        description: description.isEmpty ? null : description,
        academyId: academyId,
        enabled: _enabled,
        isPremium: _isPremium,
        publishedAt: _publishedAt,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      cubit.createTopicGroup(newGroup);
    }
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
}

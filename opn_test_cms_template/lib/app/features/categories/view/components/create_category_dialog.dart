import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../topics/cubit/cubit.dart';
import '../../../topics/cubit/state.dart';
import '../../../topics/model/topic_level.dart';
import '../../cubit/cubit.dart';
import '../../cubit/state.dart' as category_state;

class CreateCategoryDialog extends StatefulWidget {
  final int? preselectedTopicTypeId;

  const CreateCategoryDialog({
    super.key,
    this.preselectedTopicTypeId,
  });

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int? _selectedTopicTypeId;

  @override
  void initState() {
    super.initState();
    _selectedTopicTypeId = widget.preselectedTopicTypeId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Categoría'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la categoría *',
                  hintText: 'Ej: Matemáticas, Historia, etc.',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  if (value.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              BlocBuilder<TopicCubit, TopicState>(
                builder: (context, state) {
                  // Filtrar solo topic_types de tipo Study
                  final studyTopicTypes = state.topicTypes
                      .where((topicType) => topicType.level == TopicLevel.Study)
                      .toList();

                  return DropdownButtonFormField<int>(
                    // initialValue: _selectedTopicTypeId,
                    decoration: const InputDecoration(
                      labelText: 'Bloque de Estudio *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.library_books),
                    ),
                    items: studyTopicTypes.map((topicType) {
                      return DropdownMenuItem<int>(
                        value: topicType.id,
                        child: Text(topicType.topicTypeName),
                      );
                    }).toList(),
                    onChanged: widget.preselectedTopicTypeId != null
                        ? null
                        : (value) {
                            setState(() {
                              _selectedTopicTypeId = value;
                            });
                          },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecciona un bloque de estudio';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                '* Campos obligatorios',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        BlocConsumer<CategoryCubit, category_state.CategoryState>(
          listener: (context, state) {
            if (state.createStatus.isDone) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Categoría creada exitosamente'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state.createStatus.isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.createStatus.message)),
                    ],
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return ElevatedButton(
              onPressed: state.createStatus.isLoading
                  ? null
                  : () => _handleSubmit(context),
              child: state.createStatus.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear'),
            );
          },
        ),
      ],
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await context.read<CategoryCubit>().createCategory(
          name: _nameController.text.trim(),
          topicTypeId: _selectedTopicTypeId!,
        );
  }
}

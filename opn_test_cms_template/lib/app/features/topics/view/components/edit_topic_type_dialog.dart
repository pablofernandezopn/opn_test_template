import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_guardia_civil_cms/app/config/go_route/app_routes.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_type_model.dart';

class EditTopicTypeDialog extends StatefulWidget {
  final TopicType topicType;

  const EditTopicTypeDialog({super.key, required this.topicType});

  @override
  State<EditTopicTypeDialog> createState() => _EditTopicTypeDialogState();
}

class _EditTopicTypeDialogState extends State<EditTopicTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _penaltyController;
  late final TextEditingController _optionsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.topicType.topicTypeName);
    _descriptionController = TextEditingController(text: widget.topicType.description);
    _penaltyController = TextEditingController(text: widget.topicType.penalty.toString());
    _optionsController = TextEditingController(text: widget.topicType.defaultNumberOptions.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _penaltyController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final updatedTopicType = widget.topicType.copyWith(
        topicTypeName: _nameController.text,
        description: _descriptionController.text,
        penalty: double.tryParse(_penaltyController.text) ?? widget.topicType.penalty,
        defaultNumberOptions: int.tryParse(_optionsController.text) ?? widget.topicType.defaultNumberOptions,
      );

      context.read<TopicCubit>().updateTopicType(widget.topicType.id!, updatedTopicType);

      Navigator.of(context).pop();
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar "${widget.topicType.topicTypeName}"? Esta acción no se puede deshacer y borrará todos los tests asociados.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                context.read<TopicCubit>().deleteTopicType(widget.topicType.id!);
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
                context.go(AppRoutes.tests_overview);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Tipo de Test'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del tipo'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _penaltyController,
                decoration: const InputDecoration(labelText: 'Penalización (ej. 0.5)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Introduce un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _optionsController,
                decoration: const InputDecoration(labelText: 'Nº de opciones por defecto'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Introduce un número válido';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _showDeleteConfirmationDialog,
          child: Text(
            'Eliminar',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

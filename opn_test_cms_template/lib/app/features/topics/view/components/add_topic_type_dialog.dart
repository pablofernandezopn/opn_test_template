import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_level.dart';

class AddTopicTypeDialog extends StatefulWidget {
  final TopicLevel level;

  const AddTopicTypeDialog({super.key, required this.level});

  @override
  State<AddTopicTypeDialog> createState() => _AddTopicTypeDialogState();
}

class _AddTopicTypeDialogState extends State<AddTopicTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _penaltyController = TextEditingController(text: '0.5');
  final _optionsController = TextEditingController(text: '4');

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
      final name = _nameController.text;
      final description = _descriptionController.text;
      final penalty = double.tryParse(_penaltyController.text) ?? 0.5;
      final options = int.tryParse(_optionsController.text) ?? 4;

      context.read<TopicCubit>().createTopicType(
            name: name,
            description: description,
            penalty: penalty,
            defaultNumberOptions: options,
            level: widget.level,
          );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.level == TopicLevel.Mock
        ? 'Nuevo Tipo de Test'
        : 'Nuevo Bloque';

    return AlertDialog(
      title: Text(title),
      content: Form(
        key: _formKey,
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
      actions: [
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

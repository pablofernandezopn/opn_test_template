import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/cubit.dart';
import '../../cubit/state.dart';

class GenerateAIQuestionsDialog extends StatefulWidget {
  final int topicId;
  final String topicName;

  const GenerateAIQuestionsDialog({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  State<GenerateAIQuestionsDialog> createState() =>
      _GenerateAIQuestionsDialogState();
}

class _GenerateAIQuestionsDialogState extends State<GenerateAIQuestionsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numQuestionsController = TextEditingController(text: '5');
  final _contextController = TextEditingController();

  int _difficulty = 0;
  int _numOptions = 4;

  @override
  void dispose() {
    _numQuestionsController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuestionCubit, QuestionState>(
      listener: (context, state) {
        if (state.generateQuestionsWithAIStatus.isDone) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.generateQuestionsWithAIStatus.message.isNotEmpty
                    ? state.generateQuestionsWithAIStatus.message
                    : 'Preguntas generadas con éxito',
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          Navigator.of(context).pop();
        } else if (state.generateQuestionsWithAIStatus.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${state.generateQuestionsWithAIStatus.message}',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.generateQuestionsWithAIStatus.isLoading;

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('Generar Preguntas con IA'),
            ],
          ),
          content: SizedBox(
            width: 700,
            height: 600,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.topic,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tema: ${widget.topicName}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('Número de preguntas a generar',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 16),

                    // Number of questions
                    TextFormField(
                      controller: _numQuestionsController,
                      decoration: const InputDecoration(
                        labelText: 'Número de preguntas',
                        hintText: 'Ej: 5',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.format_list_numbered),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un número';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num < 1 || num > 50) {
                          return 'Ingresa un número entre 1 y 50';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Context
                    Text(
                      'Contexto',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Proporciona texto del cual extraer las preguntas',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contextController,
                      decoration: const InputDecoration(
                        hintText:
                            'Pega aquí el texto, artículo o contenido del cual quieres generar preguntas...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 15,
                      maxLength: 10000,
                    ),

                    if (isLoading) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text('Generando preguntas con IA...'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: isLoading ? null : _generateQuestions,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generar'),
            ),
          ],
        );
      },
    );
  }

  void _generateQuestions() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final numQuestions = int.parse(_numQuestionsController.text);
    final questionContext = _contextController.text.trim();

    context.read<QuestionCubit>().generateQuestionsWithAI(
          topicId: widget.topicId,
          topicName: widget.topicName,
          numQuestions: numQuestions,
          difficulty: _difficulty,
          numOptions: _numOptions,
          context: questionContext.isEmpty ? null : questionContext,
          saveToDatabase: true,
        );
  }
}

/// Helper method to show the dialog
Future<void> showGenerateAIQuestionsDialog(
  BuildContext context, {
  required int topicId,
  required String topicName,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => BlocProvider.value(
      value: context.read<QuestionCubit>(),
      child: GenerateAIQuestionsDialog(
        topicId: topicId,
        topicName: topicName,
      ),
    ),
  );
}

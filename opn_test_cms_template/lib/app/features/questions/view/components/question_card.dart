import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/widgets/pickImage/image_picker_dialog.dart';
import '../../../../config/widgets/pickImage/image_upload_type.dart';
import 'mp3_reproductor.dart';
import '../../../topics/model/topic_level.dart';
import '../../../topics/model/topic_type_model.dart';
import '../../cubit/cubit.dart';
import '../../cubit/state.dart';
import '../../model/question_model.dart';
import '../../model/question_option_model.dart';

class QuestionCard extends StatefulWidget {
  final VoidCallback? onClose;
  final TopicType topicType;

  const QuestionCard({
    super.key,
    this.onClose,
    required this.topicType,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late TextEditingController questionController;
  late TextEditingController tipController;
  late TextEditingController questionImageUrlController;
  late TextEditingController retroImageUrlController;
  bool published = false;
  bool shuffled = false;
  int correctOptionIndex = -1;
  int? _lastSelectedQuestionId;
  Timer? _debounceTimer; // Debounce timer para auto-guardado
  bool _hasLocalChanges = false; // Flag para cambios locales

  @override
  void initState() {
    super.initState();
    questionController = TextEditingController();
    tipController = TextEditingController();
    questionImageUrlController = TextEditingController();
    retroImageUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    questionController.dispose();
    tipController.dispose();
    questionImageUrlController.dispose();
    retroImageUrlController.dispose();
    super.dispose();
  }

  void _syncWithSelectedQuestion(Question q, List<QuestionOption> options) {
    // Only update if the selected question changed
    if (_lastSelectedQuestionId != q.id) {
      _lastSelectedQuestionId = q.id;
      _hasLocalChanges = false; // Reset local changes flag
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            questionController.text = q.question;
            tipController.text = q.tip ?? '';
            questionImageUrlController.text = q.questionImageUrl;
            retroImageUrlController.text = q.retroImageUrl;
            published = q.published;
            shuffled = q.shuffled ?? false;
            // Find correct option
            final correctOption = options.where((o) => o.isCorrect).firstOrNull;
            correctOptionIndex =
                correctOption != null ? options.indexOf(correctOption) : -1;
          });
        }
      });
    }
  }

  /// Debounced update - guarda después de 500ms de inactividad
  void _scheduleUpdate() {
    _hasLocalChanges = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_hasLocalChanges) {
        _updateQuestion();
      }
    });
  }

  void _updateQuestion() {
    final state = context.read<QuestionCubit>().state;
    final selectedQuestion = state.questions
        .where((q) => q.id == state.selectedQuestionId)
        .firstOrNull;
    if (selectedQuestion != null && selectedQuestion.id != null) {
      final updated = selectedQuestion.copyWith(
        question: questionController.text,
        tip: tipController.text,
        questionImageUrl: questionImageUrlController.text,
        retroImageUrl: retroImageUrlController.text,
        published: published,
        shuffled: shuffled,
      );
      context
          .read<QuestionCubit>()
          .updateQuestion(selectedQuestion.id!, updated);
      _hasLocalChanges = false; // Reset flag después de guardar
    }
  }

  void _updateQuestionImmediately() {
    _debounceTimer?.cancel(); // Cancelar cualquier guardado pendiente
    _updateQuestion();
  }

  /// Abre el dialog para seleccionar y subir imagen de la pregunta
  Future<void> _uploadQuestionImage() async {
    final state = context.read<QuestionCubit>().state;
    final selectedQuestion = state.questions
        .where((q) => q.id == state.selectedQuestionId)
        .firstOrNull;

    if (selectedQuestion == null || selectedQuestion.id == null) return;

    // Obtener el topicId desde el estado
    final topicId = state.selectedTopicId;

    // Nombre fijo para que se sobrescriba al subir una nueva imagen
    final fileName = 'question_image';

    // Construir la ruta de carpetas si hay topicId disponible
    // Nota: No incluir el nombre del bucket en la ruta, solo la estructura de carpetas
    final folderPath = topicId != null
        ? 'topic_$topicId/question_${selectedQuestion.id}'
        : null;

    showImagePickerDialog(
      context: context,
      type: ImageUploadType.test,
      fileName: fileName,
      folderPath: folderPath,
      title: 'Subir imagen de la pregunta',
      subtitle: 'Selecciona una imagen para esta pregunta',
      onImageUploaded: (imageUrl) {
        if (mounted) {
          setState(() {
            questionImageUrlController.text = imageUrl;
          });
          _updateQuestionImmediately();
        }
      },
    );
  }

  /// Abre el dialog para seleccionar y subir imagen de retroalimentación
  Future<void> _uploadRetroImage() async {
    final state = context.read<QuestionCubit>().state;
    final selectedQuestion = state.questions
        .where((q) => q.id == state.selectedQuestionId)
        .firstOrNull;

    if (selectedQuestion == null || selectedQuestion.id == null) return;

    // Obtener el topicId desde el estado
    final topicId = state.selectedTopicId;

    // Nombre fijo para que se sobrescriba al subir una nueva imagen
    final fileName = 'retro_image';

    // Construir la ruta de carpetas si hay topicId disponible
    // Nota: No incluir el nombre del bucket en la ruta, solo la estructura de carpetas
    final folderPath = topicId != null
        ? 'topic_$topicId/question_${selectedQuestion.id}'
        : null;

    showImagePickerDialog(
      context: context,
      type: ImageUploadType.test,
      fileName: fileName,
      folderPath: folderPath,
      title: 'Subir imagen de retroalimentación',
      subtitle: 'Selecciona una imagen para la retroalimentación',
      onImageUploaded: (imageUrl) {
        if (mounted) {
          setState(() {
            retroImageUrlController.text = imageUrl;
          });
          _updateQuestionImmediately();
        }
      },
    );
  }

  void _updateOptions() {
    final state = context.read<QuestionCubit>().state;
    final options = List<QuestionOption>.from(state.questionOptions
        .where((o) => o.questionId == state.selectedQuestionId));
    for (int i = 0; i < options.length; i++) {
      final updated = options[i].copyWith(isCorrect: i == correctOptionIndex);
      context
          .read<QuestionCubit>()
          .updateQuestionOption(options[i].id!, updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestionCubit, QuestionState>(
      builder: (context, state) {
        final selectedQuestion = state.questions
            .where((q) => q.id == state.selectedQuestionId)
            .firstOrNull;

        if (selectedQuestion == null) {
          _lastSelectedQuestionId = null; // Reset when no question selected
          return const Card(
            child: Center(child: Text('Selecciona una pregunta para editar')),
          );
        }

        // Filtrar solo las opciones de la pregunta seleccionada
        final options = state.questionOptions
            .where((opt) => opt.questionId == selectedQuestion.id)
            .toList()
          ..sort((a, b) => a.optionOrder.compareTo(b.optionOrder));

        // Detectar si es una flashcard
        final isFlashcard = widget.topicType.level == TopicLevel.Flashcard;

        // Sync controllers with selected question (only when question changes)
        _syncWithSelectedQuestion(selectedQuestion, options);

        return Card(
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            children: [
              // Header con título y botón cerrar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pregunta ${selectedQuestion.order}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        context.read<QuestionCubit>().deselectQuestion();
                        widget.onClose?.call();
                      },
                      tooltip: 'Cerrar',
                    ),
                  ],
                ),
              ),

              // Switches e indicador en la misma fila
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Indicador de guardado
                    BlocSelector<QuestionCubit, QuestionState, bool>(
                      selector: (state) =>
                          state.updateQuestionStatus.isLoading ||
                          state.updateQuestionOptionStatus.isLoading,
                      builder: (context, isLoading) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLoading)
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              else if (_hasLocalChanges)
                                Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: Colors.orange,
                                )
                              else
                                Icon(
                                  Icons.check_circle,
                                  size: 12,
                                  color: Colors.green,
                                ),
                              const SizedBox(width: 6),
                              Text(
                                isLoading
                                    ? 'Guardando...'
                                    : _hasLocalChanges
                                        ? 'Guardando...'
                                        : 'Guardado',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isLoading
                                      ? Theme.of(context).colorScheme.primary
                                      : _hasLocalChanges
                                          ? Colors.orange
                                          : Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    // Switches (solo visible para tipos Block/Study, no para Mock)
                    if (widget.topicType.level == TopicLevel.Study) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Publicado:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              height: 20,
                              width: 35,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Switch(
                                  value: published,
                                  onChanged: (value) {
                                    setState(() => published = value);
                                    _updateQuestionImmediately();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Aleatorizado:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              height: 20,
                              width: 35,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Switch(
                                  value: shuffled,
                                  onChanged: (value) {
                                    setState(() => shuffled = value);
                                    _updateQuestionImmediately();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Divider(height: 1),

              // Contenido scrolleable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campo "Pregunta" solo visible si NO es flashcard
                      if (!isFlashcard) ...[
                        Text(
                          'Pregunta',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: questionController,
                          decoration: const InputDecoration(
                            labelText: 'Escribe aqui la pregunta',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          onChanged: (_) => _scheduleUpdate(),
                        ),
                        const SizedBox(height: 16),
                        // Campo de imagen de pregunta
                        Text(
                          'Imagen de la Pregunta',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: questionImageUrlController,
                                decoration: const InputDecoration(
                                  labelText: 'URL de la imagen',
                                  border: OutlineInputBorder(),
                                  hintText: 'https://ejemplo.com/imagen.jpg',
                                ),
                                onChanged: (_) => _scheduleUpdate(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _uploadQuestionImage,
                              icon: const Icon(Icons.image_search),
                              tooltip: 'Buscar imagen',
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        if (questionImageUrlController.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: Image.network(
                              questionImageUrlController.text,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                padding: const EdgeInsets.all(16),
                                color: Colors.red.shade50,
                                child: const Text(
                                  'Error al cargar la imagen. Verifica la URL.',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isFlashcard
                                  ? 'Contenido de la Flashcard'
                                  : 'Opciones de Respuesta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isFlashcard)
                            Expanded(
                              child: ElevatedButton.icon(
                                // Deshabilitar si es flashcard (solo 2 opciones permitidas)
                                onPressed: isFlashcard
                                    ? null
                                    : () {
                                        final newOption = QuestionOption(
                                          questionId: selectedQuestion.id!,
                                          answer: 'Nueva opción',
                                          optionOrder: options.length + 1,
                                        );
                                        context
                                            .read<QuestionCubit>()
                                            .createQuestionOption(newOption);
                                      },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Agregar'),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Options list with constrained height
                      if (options.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                                'No hay opciones. Agrega una nueva opción.'),
                          ),
                        )
                      else ...[
                        for (int index = 0; index < options.length; index++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isFlashcard
                                      ? (index == 0
                                          ? 'Pregunta/Frente'
                                          : 'Respuesta/Reverso')
                                      : 'Opción ${String.fromCharCode('A'.codeUnitAt(0) + index)}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    // Radio button solo visible si NO es flashcard
                                    if (!isFlashcard)
                                      Radio<int>(
                                        value: index,
                                        groupValue: correctOptionIndex,
                                        onChanged: (value) {
                                          setState(() =>
                                              correctOptionIndex = value!);
                                          _updateOptions(); // Guardar inmediatamente cambio de opción correcta
                                        },
                                      ),
                                    Expanded(
                                      child: _OptionTextField(
                                        option: options[index],
                                        index: index,
                                        isFlashcard: isFlashcard,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      // Deshabilitar si es flashcard y solo hay 2 opciones
                                      onPressed:
                                          (isFlashcard && options.length <= 2)
                                              ? null
                                              : () => context
                                                  .read<QuestionCubit>()
                                                  .deleteQuestionOption(
                                                      options[index].id!),
                                      tooltip: (isFlashcard &&
                                              options.length <= 2)
                                          ? 'Las flashcards requieren exactamente 2 opciones'
                                          : 'Eliminar opción',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                      // Campo "Retroalimentación" solo visible si NO es flashcard
                      if (!isFlashcard) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Retroalimentación',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: tipController,
                          decoration: const InputDecoration(
                            labelText: 'Retroalimentación',
                            border: OutlineInputBorder(),
                            helperText:
                                'Explicación que se mostrará al usuario',
                          ),
                          maxLines: 3,
                          onChanged: (_) => _scheduleUpdate(),
                        ),
                        const SizedBox(height: 16),
                        // Widget de retroaudio usando el componente Reproductor
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Retroaudio',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withOpacity(0.2)),
                              const SizedBox(height: 8),
                              // Componente Reproductor
                              Reproductor(
                                key: Key(selectedQuestion.id.toString()),
                                question: selectedQuestion,
                                generateAudio: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Campo de imagen de retroalimentación
                        Text(
                          'Imagen de Retroalimentación',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: retroImageUrlController,
                                decoration: const InputDecoration(
                                  labelText:
                                      'URL de la imagen de retroalimentación',
                                  border: OutlineInputBorder(),
                                  hintText:
                                      'https://ejemplo.com/retro-imagen.jpg',
                                ),
                                onChanged: (_) => _scheduleUpdate(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _uploadRetroImage,
                              icon: const Icon(Icons.image_search),
                              tooltip: 'Buscar imagen',
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        if (retroImageUrlController.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: Image.network(
                              retroImageUrlController.text,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                padding: const EdgeInsets.all(16),
                                color: Colors.red.shade50,
                                child: const Text(
                                  'Error al cargar la imagen. Verifica la URL.',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget separado para cada TextField de opción con su propio controller
/// Esto evita crear controllers en cada build
class _OptionTextField extends StatefulWidget {
  final QuestionOption option;
  final int index;
  final bool isFlashcard;

  const _OptionTextField({
    required this.option,
    required this.index,
    this.isFlashcard = false,
  });

  @override
  State<_OptionTextField> createState() => _OptionTextFieldState();
}

class _OptionTextFieldState extends State<_OptionTextField> {
  late TextEditingController controller;
  // late TextEditingController imageUrlController;
  Timer? _debounceTimer;
  bool _isEditing = false; // Flag para saber si el usuario está escribiendo

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.option.answer);
    // imageUrlController = TextEditingController(text: widget.option.imageUrl);
  }

  @override
  void didUpdateWidget(_OptionTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo actualizar si cambió el ID de la opción o si no está editando
    if (oldWidget.option.id != widget.option.id) {
      // Cambió la opción completamente, actualizar siempre
      controller.text = widget.option.answer;
      _isEditing = false;
    } else if (!_isEditing) {
      if (oldWidget.option.answer != widget.option.answer) {
        controller.text = widget.option.answer;
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    controller.dispose();
    // imageUrlController.dispose();
    super.dispose();
  }

  void _scheduleUpdate(String value) {
    _isEditing = true; // Marcar que está editando
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final updated = widget.option.copyWith(answer: value);
      context
          .read<QuestionCubit>()
          .updateQuestionOption(widget.option.id!, updated);
      // Esperar un poco más antes de permitir actualizaciones desde fuera
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _isEditing = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Opción ${widget.index + 1}',
            border: const OutlineInputBorder(),
            // No mostrar icono de check en flashcards (no hay concepto de respuesta correcta)
            suffixIcon: (!widget.isFlashcard && widget.option.isCorrect)
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
          ),
          maxLines: 2, // Permite múltiples líneas
          keyboardType: TextInputType.multiline, // Teclado multilinea
          textInputAction: TextInputAction.newline, // Enter crea nueva línea
          onChanged: _scheduleUpdate,
        ),
      ],
    );
  }
}

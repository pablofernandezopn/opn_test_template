import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/features/questions/cubit/state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../bootstrap.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../model/question_model.dart';
import '../model/question_option_model.dart';
import '../repository/repository.dart';

class QuestionCubit extends Cubit<QuestionState> {
  final QuestionRepository _questionRepository;
  final AuthCubit _authCubit;

  QuestionCubit(this._questionRepository, this._authCubit)
      : super(QuestionState.initial());

  /// Obtiene el academy_id del usuario autenticado
  int? get _currentAcademyId => _authCubit.state.user.academyId;

  // Seleccionar topic
  void selectTopic(int topicId, {bool usePagination = false}) async {
    emit(state.copyWith(selectedTopicId: topicId));
    await fetchQuestions(topicId: topicId, usePagination: usePagination);
    // Cargar todas las opciones de todas las preguntas del topic
    await fetchAllQuestionOptionsByTopic(topicId);
  }

  // Establecer el topicId seleccionado sin cargar preguntas
  // Útil cuando ya tenemos la pregunta cargada pero necesitamos el contexto del topic
  // (por ejemplo, para que las imágenes se suban en la ubicación correcta)
  void setSelectedTopicId(int topicId) {
    emit(state.copyWith(selectedTopicId: topicId));
  }

  // Seleccionar question
  void selectQuestion(int questionId) {
    emit(state.copyWith(selectedQuestionId: questionId));
    // No necesitamos fetchQuestionOptions porque ya tenemos todas las opciones cargadas
  }

  // Deseleccionar question
  void deselectQuestion() {
    emit(state.copyWith(selectedQuestionId: null));
  }

  // Fetch questions, opcionalmente por topic
  Future<void> fetchQuestions(
      {int? topicId, bool usePagination = false}) async {
    try {
      emit(state.copyWith(
        fetchQuestionsStatus: Status.loading(),
        currentPage: 0,
        hasMore: true,
      ));

      // Si usamos paginación, cargar solo la primera página
      final questions = await _questionRepository.fetchQuestions(
        topicId: topicId,
        academyId: _currentAcademyId,
        limit: usePagination ? state.pageSize : null,
        offset: usePagination ? 0 : null,
      );

      // Si obtuvimos menos de pageSize, no hay más páginas
      final hasMore =
          usePagination ? questions.length == state.pageSize : false;

      emit(state.copyWith(
        questions: questions,
        fetchQuestionsStatus: Status.done(),
        error: null,
        currentPage: 0,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchQuestionsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching questions: $e');
    }
  }

  /// Carga más preguntas (scroll infinito)
  /// Solo se usa cuando el topic type tiene nivel 'Study'
  Future<void> loadMoreQuestions() async {
    // No cargar si ya estamos cargando o no hay más preguntas
    if (state.isLoadingMore || !state.hasMore) {
      return;
    }

    try {
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final offset = nextPage * state.pageSize;

      final newQuestions = await _questionRepository.fetchQuestions(
        topicId: state.selectedTopicId,
        academyId: _currentAcademyId,
        limit: state.pageSize,
        offset: offset,
      );

      // Si obtuvimos menos de pageSize, no hay más páginas
      final hasMore = newQuestions.length == state.pageSize;

      // Combinar con las preguntas existentes
      final allQuestions = [...state.questions, ...newQuestions];

      emit(state.copyWith(
        questions: allQuestions,
        currentPage: nextPage,
        hasMore: hasMore,
        isLoadingMore: false,
      ));

      logger.info(
          'Loaded ${newQuestions.length} more questions (page $nextPage)');
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        error: 'Error al cargar más preguntas: ${e.toString()}',
      ));
      logger.error('Error loading more questions: $e');
    }
  }

  // Create question
  Future<void> createQuestion(Question question,
      {bool autoSelect = true}) async {
    try {
      emit(state.copyWith(createQuestionStatus: Status.loading()));
      final newQuestion = await _questionRepository.createQuestion(question);
      final updatedQuestions = [...state.questions, newQuestion];
      emit(state.copyWith(
        questions: updatedQuestions,
        createQuestionStatus: Status.done(),
        error: null,
        // Auto-seleccionar la pregunta recién creada si autoSelect es true
        selectedQuestionId:
            autoSelect ? newQuestion.id : state.selectedQuestionId,
      ));

      // Si auto-selecciona, cargar las opciones de la pregunta (vacías al inicio)
      if (autoSelect && newQuestion.id != null) {
        await fetchQuestionOptions(newQuestion.id!);
      }
    } catch (e) {
      emit(state.copyWith(
        createQuestionStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error creating question: $e');
    }
  }

  // Update question
  Future<void> updateQuestion(int id, Question question) async {
    try {
      emit(state.copyWith(updateQuestionStatus: Status.loading()));
      final updatedQuestion =
          await _questionRepository.updateQuestion(id, question);
      final updatedQuestions =
          state.questions.map((q) => q.id == id ? updatedQuestion : q).toList();
      emit(state.copyWith(
        questions: updatedQuestions,
        updateQuestionStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        updateQuestionStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error updating question: $e');
    }
  }

  // Delete question
  Future<void> deleteQuestion(int id) async {
    try {
      emit(state.copyWith(deleteQuestionStatus: Status.loading()));
      await _questionRepository.deleteQuestion(id);

      // Eliminar la pregunta de la lista
      final updatedQuestions =
          state.questions.where((q) => q.id != id).toList();

      // Eliminar también todas las opciones de respuesta asociadas a esta pregunta
      final updatedOptions =
          state.questionOptions.where((opt) => opt.questionId != id).toList();

      emit(state.copyWith(
        questions: updatedQuestions,
        questionOptions: updatedOptions,
        deleteQuestionStatus: Status.done(),
        error: null,
        // Si la pregunta eliminada estaba seleccionada, deseleccionarla
        selectedQuestionId:
            state.selectedQuestionId == id ? null : state.selectedQuestionId,
      ));
    } catch (e) {
      emit(state.copyWith(
        deleteQuestionStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error deleting question: $e');
    }
  }

  // Fetch question options
  Future<void> fetchQuestionOptions(int questionId) async {
    try {
      emit(state.copyWith(fetchQuestionOptionsStatus: Status.loading()));
      final options =
          await _questionRepository.fetchQuestionOptions(questionId);

      // Agregar las opciones de esta pregunta manteniendo las de otras preguntas
      final existingOptions = state.questionOptions
          .where((opt) => opt.questionId != questionId)
          .toList();
      final updatedOptions = [...existingOptions, ...options];

      emit(state.copyWith(
        questionOptions: updatedOptions,
        fetchQuestionOptionsStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchQuestionOptionsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching question options: $e');
    }
  }

  // Fetch all question options by topic (para mostrar en la tabla)
  Future<void> fetchAllQuestionOptionsByTopic(int topicId) async {
    try {
      emit(state.copyWith(fetchQuestionOptionsStatus: Status.loading()));
      // Filtrar question options por academy_id del usuario autenticado
      final options = await _questionRepository.fetchAllQuestionOptionsByTopic(
        topicId,
        academyId: _currentAcademyId,
      );
      emit(state.copyWith(
        questionOptions: options,
        fetchQuestionOptionsStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchQuestionOptionsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching all question options by topic: $e');
    }
  }

  // Create question option
  Future<void> createQuestionOption(QuestionOption option) async {
    try {
      emit(state.copyWith(createQuestionOptionStatus: Status.loading()));
      final newOption = await _questionRepository.createQuestionOption(option);
      final updatedOptions = [...state.questionOptions, newOption];
      emit(state.copyWith(
        questionOptions: updatedOptions,
        createQuestionOptionStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        createQuestionOptionStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error creating question option: $e');
    }
  }

  // Update question option
  Future<void> updateQuestionOption(int id, QuestionOption option) async {
    try {
      emit(state.copyWith(updateQuestionOptionStatus: Status.loading()));
      final updatedOption =
          await _questionRepository.updateQuestionOption(id, option);
      final updatedOptions = state.questionOptions
          .map((o) => o.id == id ? updatedOption : o)
          .toList();
      emit(state.copyWith(
        questionOptions: updatedOptions,
        updateQuestionOptionStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        updateQuestionOptionStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error updating question option: $e');
    }
  }

  // Delete question option
  Future<void> deleteQuestionOption(int id) async {
    try {
      emit(state.copyWith(deleteQuestionOptionStatus: Status.loading()));
      await _questionRepository.deleteQuestionOption(id);
      final updatedOptions =
          state.questionOptions.where((o) => o.id != id).toList();
      emit(state.copyWith(
        questionOptions: updatedOptions,
        deleteQuestionOptionStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        deleteQuestionOptionStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error deleting question option: $e');
    }
  }

  // Reorder questions and persist to database
  Future<void> reorderQuestions(int fromIndex, int toIndex) async {
    try {
      final questions = List<Question>.from(state.questions);
      final question = questions.removeAt(fromIndex);
      questions.insert(toIndex, question);

      // Actualizar todas las preguntas con su nuevo orden (índice + 1, ya que empieza en 1)
      final updatedQuestions = questions.asMap().entries.map((entry) {
        return entry.value.copyWith(order: entry.key + 1);
      }).toList();

      // Actualizar el estado inmediatamente para UI responsiva
      emit(state.copyWith(questions: updatedQuestions));

      // Preparar las actualizaciones de orden para TODAS las preguntas
      // El orden empieza en 1, no en 0
      final updates = <Map<String, dynamic>>[];
      for (int i = 0; i < updatedQuestions.length; i++) {
        final q = updatedQuestions[i];
        if (q.id != null) {
          updates.add({
            'id': q.id,
            'order': i + 1, // Orden empieza en 1
          });
        }
      }

      // Persistir los cambios en la base de datos
      if (updates.isNotEmpty) {
        await _questionRepository.updateQuestionsOrder(updates);
        logger.info('Updated order for ${updates.length} questions');
      }
    } catch (e) {
      logger.error('Error reordering questions: $e');
      // En caso de error, recargar las preguntas desde la BD
      await fetchQuestions(topicId: state.selectedTopicId);
    }
  }

  // Generate retro audio using edge function (single question)
  Future<void> generateRetroAudio(Question question,
      {String? customText}) async {
    try {
      emit(state.copyWith(generateRetroAudioStatus: Status.loading()));

      if (question.id == null) {
        throw Exception('La pregunta debe tener un ID válido');
      }

      logger.info(
          'Generating audio for question ${question.id} in topic ${question.topic}');

      // Llamar al repositorio que se encarga de:
      // 1. Generar el audio con ElevenLabs
      // 2. Subir el audio al bucket 'topics'
      // 3. Actualizar la pregunta en la base de datos
      final data = await _questionRepository.generateRetroText(
        question,
        customText: customText,
      );

      logger.info('Audio generated and uploaded: ${data['audioPath']}');

      // Recargar las preguntas para obtener los datos actualizados
      await fetchQuestions(topicId: question.topic);

      emit(state.copyWith(
        generateRetroAudioStatus:
            Status.done('Retroaudio generado correctamente'),
      ));

      logger.info(
          'Generated and uploaded retro audio for question ${question.id}');
    } catch (e) {
      emit(state.copyWith(
        generateRetroAudioStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error generating retro audio: $e');
    }
  }

  // Generate retro audio for multiple questions
  Future<void> generateRetroAudioBatch(List<Question> questions) async {
    try {
      emit(state.copyWith(generateRetroAudioStatus: Status.loading()));

      if (questions.isEmpty) {
        throw Exception('No se proporcionaron preguntas para procesar');
      }

      // Verificar que tenemos el topicId
      final topicId = state.selectedTopicId ?? questions.first.topic;

      logger.info('Generating audio for ${questions.length} questions');

      // Llamar al repositorio para procesar múltiples preguntas
      final data = await _questionRepository.generateRetroTexts(questions);

      final totalProcessed = data['totalProcessed'] ?? 0;
      final totalErrors = data['totalErrors'] ?? 0;

      logger.info(
          'Batch processing complete: $totalProcessed successful, $totalErrors errors');

      // Recargar las preguntas para obtener los datos actualizados
      await fetchQuestions(topicId: topicId);

      emit(state.copyWith(
        generateRetroAudioStatus: Status.done(
            'Procesadas $totalProcessed de ${questions.length} preguntas'),
      ));

      logger.info('Generated and uploaded retro audio for multiple questions');
    } catch (e) {
      emit(state.copyWith(
        generateRetroAudioStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error generating retro audio batch: $e');
    }
  }

  /// Genera preguntas usando IA (OpenAI)
  ///
  /// Parámetros:
  /// - [topicId]: ID del topic al que pertenecerán las preguntas
  /// - [topicName]: Nombre del topic (usado por la IA para contexto)
  /// - [numQuestions]: Número de preguntas a generar (default: 5)
  /// - [difficulty]: Nivel de dificultad (0: básica, 1: media, 2: avanzada, default: 0)
  /// - [numOptions]: Número de opciones por pregunta (default: 4)
  /// - [context]: Texto opcional del cual extraer las preguntas
  /// - [saveToDatabase]: Si debe guardar las preguntas en la BD (default: true)
  Future<void> generateQuestionsWithAI({
    required int topicId,
    required String topicName,
    int numQuestions = 5,
    int difficulty = 0,
    int numOptions = 4,
    String? context,
    bool saveToDatabase = true,
  }) async {
    try {
      emit(state.copyWith(generateQuestionsWithAIStatus: Status.loading()));

      logger.info(
          'Generating $numQuestions questions with AI for topic $topicName');

      final data = await _questionRepository.generateQuestionsWithAI(
        topicId: topicId,
        topicName: topicName,
        numQuestions: numQuestions,
        difficulty: difficulty,
        numOptions: numOptions,
        context: context,
        academyId: _currentAcademyId ?? 1,
        saveToDatabase: saveToDatabase,
      );

      final message =
          data['message'] as String? ?? 'Preguntas generadas con éxito';

      // Si se guardaron en la BD, recargar las preguntas
      if (saveToDatabase) {
        await fetchQuestions(topicId: topicId);
        await fetchAllQuestionOptionsByTopic(topicId);
      }

      emit(state.copyWith(
        generateQuestionsWithAIStatus: Status.done(message),
      ));

      logger.info('Questions generated with AI successfully');
    } catch (e) {
      emit(state.copyWith(
        generateQuestionsWithAIStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error generating questions with AI: $e');
    }
  }

  /// Genera el texto del retro audio usando IA para una pregunta
  /// Retorna el texto generado y actualiza la pregunta en el estado
  Future<String> generateRetroAudioText(Question question) async {
    try {
      emit(state.copyWith(generateRetroAudioStatus: Status.loading()));

      logger.info(
          'Generating retro audio text for question ${question.id} in topic ${question.topic}');

      final text = await _questionRepository.generateRetroAudioText(question);

      logger.info('Generated retro audio text: ${text.substring(0, 50)}...');

      // Actualizar la pregunta en el estado con el nuevo texto
      final updatedQuestion = question.copyWith(retroAudioText: text);
      final updatedQuestions = state.questions
          .map((q) => q.id == question.id ? updatedQuestion : q)
          .toList();

      emit(state.copyWith(
        questions: updatedQuestions,
        generateRetroAudioStatus: Status.done('Texto generado con éxito'),
      ));

      return text;
    } catch (e) {
      emit(state.copyWith(
        generateRetroAudioStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error generating retro audio text: $e');
      rethrow;
    }
  }
}

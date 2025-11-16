import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_template/app/features/questions/cubit/state.dart';
import '../../../../bootstrap.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../model/question_model.dart';
import '../model/question_option_model.dart';
import '../repository/repository.dart';
import '../../test_config/model/answer_display_mode.dart';


class QuestionCubit extends Cubit<QuestionState> {
  final QuestionRepository _questionRepository;
  final AuthCubit _authCubit;
  final ScrollController questionIndexScrollController = ScrollController();

  QuestionCubit(this._questionRepository, this._authCubit) : super(QuestionState.initial());

  /// Obtiene el academy_id del usuario autenticado
  int? get _currentAcademyId => _authCubit.state.user.academyId;

  // Seleccionar topic
  void selectTopic(int topicId) async {
    emit(state.copyWith(selectedTopicId: topicId));
    await fetchQuestions(topicId: topicId);
    // Cargar todas las opciones de todas las preguntas del topic
    await fetchAllQuestionOptionsByTopic(topicId);
  }

  /// Pre-carga preguntas y opciones directamente (para tests generados)
  void loadQuestionsDirectly(
    int virtualTopicId,
    List<Question> questions,
    List<QuestionOption> options, {
    required AnswerDisplayMode answerDisplayMode,
  }) {
    emit(state.copyWith(
      selectedTopicId: virtualTopicId,
      questions: questions,
      questionOptions: options,
      answerDisplayMode: answerDisplayMode,
      fetchQuestionsStatus: Status.done(),
      fetchQuestionOptionsStatus: Status.done(),
      error: null,
    ));
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
  Future<void> fetchQuestions({int? topicId}) async {
    try {
      emit(state.copyWith(fetchQuestionsStatus: Status.loading()));
      // Filtrar questions por academy_id del usuario autenticado
      final questions = await _questionRepository.fetchQuestions(
        topicId: topicId,
        academyId: _currentAcademyId,
      );
      emit(state.copyWith(
        questions: questions,
        fetchQuestionsStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchQuestionsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching questions: $e');
    }
  }

  // Create question
  Future<void> createQuestion(Question question, {bool autoSelect = true}) async {
    try {
      emit(state.copyWith(createQuestionStatus: Status.loading()));
      final newQuestion = await _questionRepository.createQuestion(question);
      final updatedQuestions = [...state.questions, newQuestion];
      emit(state.copyWith(
        questions: updatedQuestions,
        createQuestionStatus: Status.done(),
        error: null,
        // Auto-seleccionar la pregunta recién creada si autoSelect es true
        selectedQuestionId: autoSelect ? newQuestion.id : state.selectedQuestionId,
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
      final updatedQuestion = await _questionRepository.updateQuestion(id, question);
      final updatedQuestions = state.questions.map((q) => q.id == id ? updatedQuestion : q).toList();
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
      final updatedQuestions = state.questions.where((q) => q.id != id).toList();

      // Eliminar también todas las opciones de respuesta asociadas a esta pregunta
      final updatedOptions = state.questionOptions.where((opt) => opt.questionId != id).toList();

      emit(state.copyWith(
        questions: updatedQuestions,
        questionOptions: updatedOptions,
        deleteQuestionStatus: Status.done(),
        error: null,
        // Si la pregunta eliminada estaba seleccionada, deseleccionarla
        selectedQuestionId: state.selectedQuestionId == id ? null : state.selectedQuestionId,
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
      final options = await _questionRepository.fetchQuestionOptions(questionId);

      // Agregar las opciones de esta pregunta manteniendo las de otras preguntas
      final existingOptions = state.questionOptions.where((opt) => opt.questionId != questionId).toList();
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
      final updatedOption = await _questionRepository.updateQuestionOption(id, option);
      final updatedOptions = state.questionOptions.map((o) => o.id == id ? updatedOption : o).toList();
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
      final updatedOptions = state.questionOptions.where((o) => o.id != id).toList();
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

  /// Calcula el número de respuestas en blanco a partir del total y las respondidas.
  int calculateBlankAnswers({
    required int totalQuestions,
    required int answered,
  }) {
    if (totalQuestions <= 0) return 0;
    final blank = totalQuestions - answered;
    return blank < 0 ? 0 : blank;
  }

  /// Devuelve el total neto de aciertos aplicando la penalización a las respuestas incorrectas.
  double calculateRawScore({
    required int correct,
    required int incorrect,
    required double penaltyPerWrong,
  }) {
    final adjustedPenalty = penaltyPerWrong.isNaN ? 0 : penaltyPerWrong;
    return (correct - (incorrect * adjustedPenalty)).toDouble();
  }

  /// Calcula la nota final (rango 0 - [maxScore]) con penalización y normalizada al total de preguntas.
  double calculateFinalScore({
    required int correct,
    required int incorrect,
    required int totalQuestions,
    required double penaltyPerWrong,
    double maxScore = 10,
  }) {
    if (totalQuestions <= 0 || maxScore <= 0) return 0;
    final rawScore = calculateRawScore(
      correct: correct,
      incorrect: incorrect,
      penaltyPerWrong: penaltyPerWrong,
    );
    final normalized = rawScore / totalQuestions;
    final scaled = normalized * maxScore;
    final clamped = scaled.clamp(0, maxScore);
    return _roundToDecimals(clamped.toDouble());
  }

  /// Calcula el porcentaje de aciertos sobre el total de preguntas.
  double calculateSuccessRate({
    required int correct,
    required int totalQuestions,
  }) {
    if (totalQuestions <= 0) return 0;
    final percentage = (correct / totalQuestions) * 100;
    return _roundToDecimals(percentage);
  }

  double _roundToDecimals(double value, {int decimals = 2}) {
    if (decimals <= 0) return value;
    final factor = math.pow(10, decimals).toDouble();
    return (value * factor).roundToDouble() / factor;
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

  @override
  Future<void> close() {
    questionIndexScrollController.dispose();
    return super.close();
  }
}

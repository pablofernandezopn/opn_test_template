import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../config/go_route/app_routes.dart';
import '../../../config/service_locator.dart';
import '../../../config/utils/topic_encryption.dart';
import '../../history/model/user_test_model.dart';
import '../../history/repository/history_repository.dart';
import '../../topics/model/topic_model.dart';
import '../../topics/model/topic_type_model.dart';
import '../../topics/repository/topic_repository.dart';
import '../../topics/cubit/topic_cubit.dart';
import '../../history/cubit/history_cubit.dart';
import '../../favorites/cubit/favorite_cubit.dart';
import '../../challenges/cubit/challenge_cubit.dart';
import '../../challenges/view/components/create_challenge_dialog.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';
import '../model/question_model.dart';
import '../model/question_option_model.dart';
import '../repository/repository.dart';
import '../model/user_test_answer_model.dart';
import '../../test_config/model/answer_display_mode.dart';
import 'components/question_index_page.dart';
import 'components/navigation_controls.dart';
import 'components/question_actions_bar.dart';
import 'components/result_summary_sheet.dart';
import 'components/finish_confirmation_sheet.dart';
import 'components/after_finish_retro.dart';
import 'components/flashcard_view.dart';
import '../../../../bootstrap.dart';
import '../../topics/model/topic_level.dart';
import '../../topics/model/grouped_test_session.dart';
import '../helpers/grouped_test_handler.dart';
import '../../../core/utils/question_utils.dart';

class TopicTestPage extends StatefulWidget {
  const TopicTestPage({
    super.key,
    this.topic,
    this.encryptedId,
    this.userTest,
    this.userTestAnswers,
    this.isHistoryReview = false,
    this.isResumingTest = false, // 🆕 Test pausado que se está retomando
    this.groupedSession, // 🆕 Test agrupado (opcional)
  }) : assert(
          topic != null || encryptedId != null || userTest != null,
          'Debe proporcionarse un topic, un token cifrado o un userTest',
        );

  final Topic? topic;
  final String? encryptedId;
  final UserTest? userTest;
  final List<UserTestAnswer>? userTestAnswers;
  final bool isHistoryReview;
  final bool isResumingTest; // 🆕 Flag para indicar que se está retomando un test pausado

  /// Sesión de test agrupado (null = test simple normal)
  final GroupedTestSession? groupedSession;

  @override
  State<TopicTestPage> createState() => _TopicTestPageState();
}

class _TopicTestPageState extends State<TopicTestPage> {
  Topic? _topic;
  TopicType? _topicType;
  bool _loading = true;
  String? _error;
  QuestionCubit? _questionCubit;
  StreamSubscription<QuestionState>? _questionSub;
  late final PageController _pageController;
  final Map<int, int?> _selectedOptions = {};
  final Map<int, String> _difficultyRatings = {};
  final Map<int, bool> _flashcardFlipped = {};
  late final FocusNode _navigationFocusNode;
  double _topicPenalty = 0;
  bool _isFlashcardMode = false;
  bool _resultsSaved = false;
  int? _savedCorrect;
  int? _savedIncorrect;
  int? _savedBlank;
  double? _savedScore;
  double? _savedNetScore;
  double? _savedSuccessRate;
  bool _savedHasTips = false;
  Map<String, int>? _savedFlashcardStats;
  double _averageScore = 0.0;
  Timer? _timer;
  Duration? _remaining;
  int _currentIndex = 0;
  DateTime? _questionStartTime;
  final Map<int, int> _questionDurationsSeconds = {};
  DateTime? _testStartTime;
  bool _finishing = false;
  bool _tipsUnlocked = false;
  bool _testFinished = false;
  late final HistoryRepository _historyRepository;
  int? _currentUserTestId; // ID del test actual cuando se está reanudando

  // Cache del orden de opciones para cada pregunta (para preservar shuffle)
  final Map<int, List<QuestionOption>> _optionsCache = {};

  // Orden preservado de opciones desde historial (question_id -> [option_ids])
  final Map<int, List<int>> _preservedOptionsOrder = {};

  // ============================================================
  // 🆕 GROUPED TEST HELPERS
  // ============================================================

  /// ¿Es un test agrupado?
  bool get _isGroupedTest => widget.groupedSession != null;

  /// Sesión del test agrupado (si aplica)
  GroupedTestSession? get _groupedSession => widget.groupedSession;

  @override
  void initState() {
    super.initState();
    print('🔍 [TopicTestPage] initState INICIO');
    print('🔍 [TopicTestPage] - widget.topic.id: ${widget.topic?.id}');
    print('🔍 [TopicTestPage] - widget.topic.topicName: ${widget.topic?.topicName}');
    print('🔍 [TopicTestPage] - widget.groupedSession: ${widget.groupedSession}');
    if (widget.groupedSession != null) {
      print('🔍 [TopicTestPage] - groupedSession.currentTopicIndex: ${widget.groupedSession!.currentTopicIndex}');
      print('🔍 [TopicTestPage] - groupedSession.totalParts: ${widget.groupedSession!.totalParts}');
      print('🔍 [TopicTestPage] - groupedSession.currentTopic.id: ${widget.groupedSession!.currentTopic.id}');
      print('🔍 [TopicTestPage] - groupedSession.isLastPart: ${widget.groupedSession!.isLastPart}');
    }

    _pageController = PageController();
    _navigationFocusNode = FocusNode(debugLabel: 'TopicTestNavigation');
    _historyRepository = getIt<HistoryRepository>();

    _prepare();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _navigationFocusNode.requestFocus();
      }
    });
  }

  bool _shouldCloseCubit = false;

  @override
  void dispose() {
    _timer?.cancel();
    _questionSub?.cancel();
    // Only close the cubit if we created it (not if it was provided externally)
    if (_shouldCloseCubit) {
      _questionCubit?.close();
    }
    _pageController.dispose();
    _navigationFocusNode.dispose();
    super.dispose();
  }

  Future<void> _prepare() async {
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.state.user;

    // Si es revisión de historial O test a retomar, cargar desde userTest
    if ((widget.isHistoryReview || widget.isResumingTest) && widget.userTest != null) {
      await _prepareHistoryReview(user);
      return;
    }

    Topic? topic = widget.topic;

    if (topic == null) {
      final token = widget.encryptedId;
      if (token == null) {
        _setError('No se proporcionó un identificador de test.');
        return;
      }
      final topicId = TopicEncryption.decode(token);
      if (topicId == null) {
        _setError('El identificador del test no es válido.');
        return;
      }
      topic = await getIt<TopicRepository>().fetchTopicById(topicId);
      if (!mounted) return;
      if (topic == null) {
        _setError('No se pudo cargar el test solicitado.');
        return;
      }
    }

    if (topic.id == null) {
      _setError('El test seleccionado no tiene un identificador válido.');
      return;
    }

    if (topic.isPremium && !user.isPremiumOrBasic) {
      _showNoAccess();
      return;
    }

    final resolvedTopic = topic;

    _testStartTime = DateTime.now();

    // 🆕 Timer: usa helper para detectar modo agrupado
    final duration = GroupedTestHandler.getInitialDuration(
      groupedSession: _groupedSession,
      topic: resolvedTopic,
    );
    _startTimerWithDuration(duration);

    double penalty = _defaultPenaltyForTopic(resolvedTopic);
    TopicType? topicType;
    bool isFlashcard = false;
    try {
      topicType = await getIt<TopicRepository>()
          .fetchTopicTypeById(resolvedTopic.topicTypeId);
      if (topicType != null) {
        penalty = topicType.penalty;
        isFlashcard = topicType.level == TopicLevel.Flashcard;
      }
    } catch (e) {
      logger.error(
          'No se pudo obtener la penalización del topic type ${resolvedTopic.topicTypeId}: $e');
    }

    // Check if a QuestionCubit is already provided (for generated tests)
    QuestionCubit? existingCubit;
    try {
      existingCubit = context.read<QuestionCubit>();
    } catch (e) {
      // No cubit provided, will create a new one
    }

    final questionCubit = existingCubit ?? QuestionCubit(
      getIt<QuestionRepository>(),
      authCubit,
    );

    // Track if we created the cubit so we can close it later
    _shouldCloseCubit = existingCubit == null;

    _questionSub = questionCubit.stream.listen(_handleQuestionState);

    setState(() {
      _topic = resolvedTopic;
      _topicType = topicType;
      _topicPenalty = penalty;
      _isFlashcardMode = isFlashcard;
      _questionCubit = questionCubit;
      _resultsSaved = false;
      _savedCorrect = null;
      _savedIncorrect = null;
      _savedBlank = null;
      _savedScore = null;
      _savedNetScore = null;
      _savedSuccessRate = null;
      _savedHasTips = false;
      _savedFlashcardStats = null;
      _averageScore = resolvedTopic.averageScore ?? 0.0;
    });

    // Only fetch from database if we created a new cubit
    // (for generated tests, questions are already pre-loaded)
    if (existingCubit == null) {
      questionCubit.selectTopic(resolvedTopic.id!);
    } else {
      // Para tests generados, las preguntas ya están cargadas
      // Llamar manualmente a _handleQuestionState con el estado actual
      _handleQuestionState(questionCubit.state);
    }
  }

  Future<void> _prepareHistoryReview(user) async {
    try {
      final userTest = widget.userTest!;
      final authCubit = context.read<AuthCubit>();

      // Cargar respuestas del usuario si no están proporcionadas
      List<UserTestAnswer> userTestAnswers = widget.userTestAnswers ?? [];
      if (userTestAnswers.isEmpty && userTest.id != null) {
        userTestAnswers = await _historyRepository.fetchAnswers(userTest.id!);
      }

      if (!mounted) return;

      // Obtener IDs de preguntas
      final questionIds = userTestAnswers.map((a) => a.questionId).toSet();
      if (questionIds.isEmpty) {
        _setError('No se encontraron preguntas en este test.');
        return;
      }

      // Cargar topic si es necesario
      Topic? topic;
      if (userTest.topicIds.isNotEmpty) {
        final topicId = userTest.topicIds.first;
        topic = await getIt<TopicRepository>().fetchTopicById(topicId);
      }

      // Si no hay topic, crear uno virtual
      topic ??= Topic(
        id: userTest.specialTopic,
        topicName: userTest.specialTopicTitle ?? 'Test del historial',
        topicTypeId: 1,
        isPremium: false,
        durationSeconds: userTest.durationSeconds,
        averageScore: userTest.score,
        createdAt: userTest.createdAt,
        updatedAt: userTest.updatedAt,
      );

      // Cargar directamente las preguntas por sus IDs (mucho más eficiente)
      final questionRepo = getIt<QuestionRepository>();
      final questions = await questionRepo.fetchQuestionsByIds(questionIds.toList());

      if (questions.isEmpty) {
        _setError('No se pudieron cargar las preguntas del test.');
        return;
      }

      if (!mounted) return;

      // Ordenar preguntas según el orden en userTestAnswers
      final answerMap = <int, UserTestAnswer>{};
      for (final answer in userTestAnswers) {
        answerMap[answer.questionId] = answer;
      }
      questions.sort((a, b) {
        final orderA = answerMap[a.id]?.questionOrder ?? 0;
        final orderB = answerMap[b.id]?.questionOrder ?? 0;
        return orderA.compareTo(orderB);
      });

      // Cargar opciones para las preguntas filtradas
      final allOptions = <QuestionOption>[];
      for (final question in questions) {
        if (question.id != null) {
          final options = await questionRepo.fetchQuestionOptions(question.id!);
          allOptions.addAll(options);
        }
      }

      if (!mounted) return;

      // Obtener topic type
      TopicType? topicType;
      try {
        topicType = await getIt<TopicRepository>()
            .fetchTopicTypeById(topic.topicTypeId);
      } catch (e) {
        logger.error('No se pudo obtener el topic type: $e');
      }

      // Crear QuestionCubit y cargar preguntas
      final questionCubit = QuestionCubit(questionRepo, authCubit);
      _shouldCloseCubit = true;

      // Determinar si estamos retomando el test o revisando uno finalizado
      // Si todas las preguntas están contestadas, tratarlo como test finalizado
      final allQuestionsAnswered = userTest.totalAnswered >= userTest.questionCount;
      final isResuming = widget.isResumingTest && !userTest.finalized && !allQuestionsAnswered;

      print('🔍 [PREPARE_HISTORY_REVIEW] Debug info:');
      print('🔍 - widget.isResumingTest: ${widget.isResumingTest}');
      print('🔍 - widget.isHistoryReview: ${widget.isHistoryReview}');
      print('🔍 - userTest.finalized: ${userTest.finalized}');
      print('🔍 - userTest.totalAnswered: ${userTest.totalAnswered}');
      print('🔍 - userTest.questionCount: ${userTest.questionCount}');
      print('🔍 - allQuestionsAnswered: $allQuestionsAnswered');
      print('🔍 - userTest.isPaused: ${userTest.isPaused}');
      print('🔍 - isResuming (calculated): $isResuming');

      // Pre-cargar preguntas y opciones en el cubit
      // Si es modo retomar (test incompleto), usar modo afterSubmit para que solo vea respuestas de preguntas ya contestadas
      // Si es modo revisión (test finalizado o completamente contestado), usar modo immediate para ver todas las respuestas
      questionCubit.loadQuestionsDirectly(
        topic.id ?? 0,
        questions,
        allOptions,
        answerDisplayMode: isResuming ? AnswerDisplayMode.atEnd : AnswerDisplayMode.immediate,
      );

      // Pre-cargar respuestas seleccionadas y orden de opciones preservado
      for (final answer in userTestAnswers) {
        final questionId = answer.questionId;
        if (answer.selectedOptionId != null) {
          _selectedOptions[questionId] = answer.selectedOptionId;
        }
        if (answer.difficultyRating != null && answer.difficultyRating!.isNotEmpty) {
          _difficultyRatings[questionId] = answer.difficultyRating!;
        }
        // Pre-cargar duraciones si existen
        if (answer.timeTakenSeconds != null) {
          _questionDurationsSeconds[questionId] = answer.timeTakenSeconds!;
        }
        // Pre-cargar orden preservado de opciones (para shuffle)
        if (answer.shuffledOptionIds != null && answer.shuffledOptionIds!.isNotEmpty) {
          _preservedOptionsOrder[questionId] = answer.shuffledOptionIds!;
        }
      }

      // Calcular estadísticas
      final cubit = questionCubit;
      final penalty = topicType?.penalty ?? _defaultPenaltyForTopic(topic);
      final blank = cubit.calculateBlankAnswers(
        totalQuestions: userTest.questionCount,
        answered: userTest.totalAnswered,
      );
      final netScore = cubit.calculateRawScore(
        correct: userTest.rightQuestions,
        incorrect: userTest.wrongQuestions,
        penaltyPerWrong: penalty,
      );
      final successRate = cubit.calculateSuccessRate(
        correct: userTest.rightQuestions,
        totalQuestions: userTest.questionCount,
      );

      final hasTips = questions.any((q) => (q.tip ?? '').trim().isNotEmpty);
      final flashcardStats = userTest.isFlashcardMode ? _buildFlashcardStats(questions) : null;

      if (!mounted) return;


      setState(() {
        _topic = topic;
        _topicType = topicType;
        _topicPenalty = penalty;
        _isFlashcardMode = userTest.isFlashcardMode;
        _questionCubit = questionCubit;

        if (isResuming) {
          // MODO RESUMIR: Test pausado, permitir continuar respondiendo
          _testFinished = false;
          _tipsUnlocked = false;
          _resultsSaved = false;
          _currentIndex = 0; // Empezar desde la primera pregunta (con respuestas ya guardadas pre-cargadas)
          _currentUserTestId = userTest.id; // Guardar el ID del test para actualizarlo más tarde

          // Ajustar _testStartTime para que refleje el tiempo ya transcurrido
          // Esto permite que el cálculo de timeSpentMillis sea correcto cuando se guarde
          _testStartTime = DateTime.now().subtract(Duration(seconds: userTest.totalTimeSeconds));

          // Si el test tiene duración, reiniciar el timer desde el tiempo restante
          if (userTest.durationSeconds != null && userTest.durationSeconds! > 0) {
            final remainingSeconds = userTest.durationSeconds! - userTest.totalTimeSeconds;
            if (remainingSeconds > 0) {
              _startTimerWithDuration(Duration(seconds: remainingSeconds));
            }
          }
        } else {
          // MODO REVISIÓN: Test finalizado, solo revisar
          _testFinished = true;
          _tipsUnlocked = true;
          _resultsSaved = true;
          _savedCorrect = userTest.rightQuestions;
          _savedIncorrect = userTest.wrongQuestions;
          _savedBlank = blank;
          _savedScore = userTest.score;
          _savedNetScore = netScore;
          _savedSuccessRate = successRate;
          _savedHasTips = hasTips;
          _savedFlashcardStats = flashcardStats;
        }

        _averageScore = topic!.averageScore ?? 0.0;
        _loading = false;
      });
    } catch (e) {
      logger.error('Error cargando test del historial: $e');
      _setError('No se pudo cargar el test del historial.');
    }
  }

  void _handleQuestionState(QuestionState state) {
    if (!mounted) return;

    if (state.fetchQuestionsStatus.isError) {
      _setError('No se pudieron cargar las preguntas.');
      return;
    }

    if (state.fetchQuestionOptionsStatus.isError) {
      _setError('No se pudieron cargar las opciones de las preguntas.');
      return;
    }

    final questionsReady = state.fetchQuestionsStatus.isDone;
    final optionsReady = state.fetchQuestionOptionsStatus.isDone;

    if (questionsReady && optionsReady) {
      setState(() {
        _loading = false;
        _currentIndex = 0;
        _questionDurationsSeconds.clear();
        _questionStartTime = DateTime.now();
      });
    }
  }

  // ============================================================
  // 🔧 TIMER METHODS (modificados para soportar tests agrupados)
  // ============================================================

  void _startTimer(int minutes) {
    _startTimerWithDuration(Duration(minutes: minutes));
  }

  void _startTimerWithDuration(Duration duration) {
    if (duration <= Duration.zero) return;

    _remaining = duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining == null) {
        timer.cancel();
        return;
      }
      final newDuration = _remaining! - const Duration(seconds: 1);
      if (newDuration <= Duration.zero) {
        setState(() {
          _remaining = Duration.zero;
        });
        timer.cancel();
        _handleTimeout(); // 🆕 Timeout
      } else {
        setState(() {
          _remaining = newDuration;
        });
        // 🆕 Actualizar tiempo en sesión grupal
        GroupedTestHandler.updateSessionTime(
          groupedSession: _groupedSession,
          remainingSeconds: newDuration.inSeconds,
        );
      }
    });
  }

  /// Pausa el timer
  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Reanuda el timer con el tiempo restante
  void _resumeTimer() {
    if (_remaining == null || _remaining! <= Duration.zero) return;
    _startTimerWithDuration(_remaining!);
  }

  /// 🆕 Maneja el timeout (para tests agrupados y simples)
  Future<void> _handleTimeout() async {
    if (_testFinished) return;

    final cubit = _questionCubit;
    if (cubit == null || !mounted) return;

    // Guardar progreso parcial
    setState(() => _finishing = true);
    _recordQuestionDurationForIndex(_currentIndex);

    try {
      final user = context.read<AuthCubit>().state.user;
      if (user.id == 0) return;

      final topic = _topic!;
      final questions = cubit.state.questions;
      final questionOptions = cubit.state.questionOptions;

      // Calcular respuestas
      int right = 0, wrong = 0, answered = 0;
      final pendingAnswers = <Map<String, dynamic>>[];

      for (var i = 0; i < questions.length; i++) {
        final question = questions[i];
        final questionId = question.id;
        final key = questionId ?? i;
        final selectedOptionId = _selectedOptions[key];

        bool? isCorrect;
        if (selectedOptionId != null) {
          answered++;
          final option = questionOptions.firstWhere(
            (opt) => opt.id == selectedOptionId,
            orElse: () => const QuestionOption(id: null, questionId: 0, answer: ''),
          );
          if (option.id != null) {
            isCorrect = option.isCorrect;
            if (isCorrect) right++; else wrong++;
          }
        }

        if (questionId != null) {
          // Obtener el orden de opciones visible al usuario
          final visibleOptions = _optionsFor(question, questionOptions);
          final shuffledIds = extractOptionIds(visibleOptions);

          pendingAnswers.add({
            'question_id': questionId,
            'selected_option_id': selectedOptionId,
            'correct': isCorrect,
            'time_taken_seconds': _questionDurationsSeconds[questionId] ?? 0,
            'question_order': i + 1,
            'challenge_by_tutor': question.challengeByTutor,
            'difficulty_rating': _isFlashcardMode ? _difficultyRatings[key] : null,
            'shuffled_option_ids': shuffledIds,
          });
        }
      }

      final totalQuestions = questions.length;
      final timeSpentMillis = _testStartTime != null
          ? DateTime.now().difference(_testStartTime!).inMilliseconds
          : null;
      final score = cubit.calculateFinalScore(
        correct: right,
        incorrect: wrong,
        totalQuestions: totalQuestions,
        penaltyPerWrong: _topicPenalty,
      );

      // 🆕 Test agrupado vs simple
      UserTest initialUserTest;
      UserTest insertedUserTest;
      int userTestId;

      // Determinar si estamos completando un test retomado
      final isCompletingResumedTest = _currentUserTestId != null;

      if (isCompletingResumedTest) {
        // CASO 1: Completando un test retomado - actualizar el existente
        userTestId = _currentUserTestId!;

        // Eliminar las respuestas antiguas (parciales)
        await _historyRepository.deleteAnswersForTest(userTestId);

        // Actualizar el UserTest existente
        if (_isGroupedTest && _groupedSession != null) {
          initialUserTest = GroupedTestHandler.createUserTestForGroup(
            userId: user.id,
            topic: topic,
            session: _groupedSession!,
            rightQuestions: right,
            wrongQuestions: wrong,
            questionCount: totalQuestions,
            totalAnswered: answered,
            score: score,
            timeSpentMillis: timeSpentMillis,
            isFlashcardMode: _isFlashcardMode,
          );
        } else {
          initialUserTest = UserTest(
            id: userTestId,
            userId: user.id,
            topicIds: [topic.id!],
            options: topic.options,
            rightQuestions: right,
            wrongQuestions: wrong,
            questionCount: totalQuestions,
            totalAnswered: answered,
            score: score,
            finalized: true,
            visible: true,
            durationSeconds: (timeSpentMillis != null ? (timeSpentMillis / 1000).round() : topic.durationSeconds ?? 0),
            timeSpentMillis: timeSpentMillis,
            specialTopic: topic.id,
            specialTopicTitle: topic.topicName,
            createdAt: null,
            updatedAt: null,
            isFlashcardMode: _isFlashcardMode,
          );
        }

        insertedUserTest = await _historyRepository.updateUserTest(userTestId, initialUserTest);
        userTestId = insertedUserTest.id!;
      } else {
        // CASO 2: Nuevo test - crear desde cero
        if (_isGroupedTest && _groupedSession != null) {
          // Test agrupado: crear con topic_group_id
          initialUserTest = GroupedTestHandler.createUserTestForGroup(
            userId: user.id,
            topic: topic,
            session: _groupedSession!,
            rightQuestions: right,
            wrongQuestions: wrong,
            questionCount: totalQuestions,
            totalAnswered: answered,
            score: score,
            timeSpentMillis: timeSpentMillis,
            isFlashcardMode: _isFlashcardMode,
          );
        } else {
          // Test simple
          initialUserTest = UserTest(
            userId: user.id,
            topicIds: [topic.id!],
            options: topic.options,
            rightQuestions: right,
            wrongQuestions: wrong,
            questionCount: totalQuestions,
            totalAnswered: answered,
            score: score,
            finalized: true,
            visible: true,
            durationSeconds: (timeSpentMillis != null ? (timeSpentMillis / 1000).round() : topic.durationSeconds ?? 0),
            timeSpentMillis: timeSpentMillis,
            specialTopic: topic.id,
            specialTopicTitle: topic.topicName,
            createdAt: null,
            updatedAt: null,
            isFlashcardMode: _isFlashcardMode,
          );
        }

        // Guardar en BD
        insertedUserTest = await _historyRepository.createUserTest(initialUserTest);
        userTestId = insertedUserTest.id!;
      }

      if (userTestId == null) return;

      // Guardar respuestas
      final answersModels = pendingAnswers
          .map((a) => UserTestAnswer(
                userTestId: userTestId,
                questionId: a['question_id'] as int,
                selectedOptionId: a['selected_option_id'] as int?,
                correct: a['correct'] as bool?,
                timeTakenSeconds: a['time_taken_seconds'] as int?,
                questionOrder: a['question_order'] as int,
                challengeByTutor: a['challenge_by_tutor'] as bool? ?? false,
                difficultyRating: a['difficulty_rating'] as String?,
                shuffledOptionIds: (a['shuffled_option_ids'] as List<int>?)?.isNotEmpty == true
                    ? a['shuffled_option_ids'] as List<int>
                    : null,
              ))
          .toList();
      await _historyRepository.insertUserTestAnswers(answersModels);

      if (!mounted) return;

      // 🆕 Navegar según tipo de test
      if (_isGroupedTest && _groupedSession != null) {
        // Test agrupado: guardar todos los pendientes e ir a FinalTestPage
        await GroupedTestHandler.handleGroupedTimeout(
          context: context,
          session: _groupedSession!,
          currentPartialTest: insertedUserTest,
          userId: user.id,
          saveUserTest: (userTest) => _historyRepository.createUserTest(userTest),
        );
      } else {
        // Test simple: mostrar diálogo con resultados
        final hasTips = questions.any((q) => (q.tip ?? '').trim().isNotEmpty);
        final flashcardStats = _isFlashcardMode ? _buildFlashcardStats(questions) : null;

        setState(() {
          _tipsUnlocked = true;
          _testFinished = true;
          _resultsSaved = true;
          _savedCorrect = right;
          _savedIncorrect = wrong;
          _savedBlank = totalQuestions - answered;
          _savedScore = score;
          _savedHasTips = hasTips;
          _savedFlashcardStats = flashcardStats;
        });

        await _presentSummary(questionsForTips: questions);
      }
    } catch (e) {
      logger.error('Error en timeout: $e');
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _loading = false;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showNoAccess() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('No tienes acceso a este contenido Premium.'),
        ),
      );
    // Limpiar el stack y volver al home
    while (context.canPop()) {
      context.pop();
    }
    context.go(AppRoutes.home);
  }

  double _defaultPenaltyForTopic(Topic topic) {
    if (topic.options <= 1) return 0;
    return 1 / (topic.options - 1);
  }

  bool _isQuestionFavorite(Question question) {
    final questionId = question.id;
    if (questionId == null) return false;

    try {
      final favoriteCubit = context.read<FavoriteCubit>();
      return favoriteCubit.isFavorite(questionId);
    } catch (e) {
      return false;
    }
  }

  Future<void> _toggleFavorite(Question question) async {
    final questionId = question.id;
    if (questionId == null) {
      _showMessage('No se puede marcar esta pregunta como favorita.');
      return;
    }

    final authCubit = context.read<AuthCubit>();
    final user = authCubit.state.user;

    if (user.id == 0) {
      _showMessage('Debes iniciar sesión para usar favoritos.');
      return;
    }

    try {
      final favoriteCubit = context.read<FavoriteCubit>();
      final success = await favoriteCubit.toggleFavorite(user.id, questionId);

      if (success) {
        final isFavorite = favoriteCubit.isFavorite(questionId);
        _showMessage(
          isFavorite
              ? 'Pregunta añadida a favoritos.'
              : 'Pregunta eliminada de favoritos.',
        );
        // Force rebuild to update the star icon
        setState(() {});
      } else {
        _showMessage('No se pudo actualizar el favorito.');
      }
    } catch (e) {
      _showMessage('Error al actualizar favorito.');
    }
  }

  Future<void> _handleImpugnation(Question question, int index) async {
    final questionNumber = index + 1;
    final questionId = question.id;

    if (questionId == null) {
      _showMessage('No se puede impugnar esta pregunta.');
      return;
    }

    final topicId = _topic?.id;
    if (topicId == null) {
      _showMessage('No se puede impugnar esta pregunta.');
      return;
    }

    // Pausar el timer mientras se muestra el diálogo
    _pauseTimer();

    // Mostrar el diálogo de impugnación
    final result = await showCreateChallengeDialog(
      context: context,
      questionNumber: questionNumber,
    );

    // Reanudar el timer después de cerrar el diálogo
    _resumeTimer();

    if (result == null || !mounted) return;

    // Obtener información del usuario
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.state.user;

    if (user.id == 0) {
      _showMessage('Debes iniciar sesión para impugnar una pregunta.');
      return;
    }

    try {
      // Obtener el cubit de challenges y crear la impugnación
      final challengeCubit = context.read<ChallengeCubit>();
      final success = await challengeCubit.createChallenge(
        questionId: questionId,
        topicId: topicId,
        reason: result.reason,
        academyId: user.academyId ?? 1,
        specialtyId: user.specialtyId,
      );

      if (success) {
        _showMessage('Impugnación enviada correctamente. Un tutor la revisará pronto.');
      } else {
        _showMessage('No se pudo enviar la impugnación. Inténtalo de nuevo.');
      }
    } catch (e) {
      logger.error('Error al crear impugnación: $e');
      _showMessage('Error al enviar la impugnación.');
    }
  }

  void _handleChatWithAi() {
    final cubit = _questionCubit;
    if (cubit == null || !mounted) return;

    final questions = cubit.state.questions;
    if (questions.isEmpty || _currentIndex >= questions.length) return;

    final currentQuestion = questions[_currentIndex];

    // Obtener la opción seleccionada para esta pregunta
    final questionKey = currentQuestion.id ?? _currentIndex;
    final selectedOptionId = _selectedOptions[questionKey];

    // No pasar questionText para evitar problemas con caracteres especiales
    // Se cargará desde la BD usando el questionId
    context.push(
      AppRoutes.aiChat,
      extra: {
        'questionId': currentQuestion.id,
        'selectedOptionId': selectedOptionId,
      },
    );
  }

  Future<void> _shareQuestion(Question question) async {
    final content = question.question.trim();
    if (content.isEmpty) {
      _showMessage('No hay contenido para compartir.');
      return;
    }

    try {
      // Obtener las opciones de la pregunta
      final cubit = _questionCubit;
      if (cubit == null) return;

      final options = _optionsFor(question, cubit.state.questionOptions);

      // Crear un screenshot controller
      final screenshotController = ScreenshotController();

      // Capturar el widget como imagen
      final imageBytes = await screenshotController.captureFromWidget(
        Material(
          color: Theme.of(context).colorScheme.surface,
          child: _QuestionShareWidget(
            question: question,
            options: options,
            colors: Theme.of(context).colorScheme,
            textTheme: Theme.of(context).textTheme,
          ),
        ),
        context: context,
      );

      // Guardar la imagen temporalmente
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/question_${question.id}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // Compartir la imagen
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Pregunta OPN',
      );

      _showMessage('Imagen compartida correctamente.');
    } catch (e) {
      _showMessage('Error al compartir la pregunta.');
    }
  }

  void _goToPreviousQuestion() {
    if (_questionCubit == null || !_pageController.hasClients) return;
    final total = _questionCubit!.state.questions.length;
    if (total <= 1) return;
    if (!_testFinished && (_finishing || _currentIndex <= 0)) return;
    if (_currentIndex <= 0) return;

    final previous = _currentIndex - 1;
    _pageController.animateToPage(
      previous,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextQuestion() {
    if (_questionCubit == null || !_pageController.hasClients) return;
    final total = _questionCubit!.state.questions.length;
    if (total <= 1) return;
    final isLastQuestion = _currentIndex >= total - 1;
    if (isLastQuestion) return;
    if (!_testFinished && _finishing) return;

    // En modo flashcard, no permitir avanzar si no se ha seleccionado dificultad
    if (_isFlashcardMode && !_testFinished) {
      final questions = _questionCubit!.state.questions;
      if (_currentIndex < questions.length) {
        final question = questions[_currentIndex];
        final key = question.id ?? _currentIndex;
        if (!_difficultyRatings.containsKey(key)) {
          _showMessage('Debes seleccionar una dificultad antes de continuar.');
          return;
        }
      }
    }

    final next = _currentIndex + 1;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // En modo flashcard sin finalizar, bloquear navegación con teclado
    if (_isFlashcardMode && !_testFinished) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        return KeyEventResult.ignored;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _goToNextQuestion();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _goToPreviousQuestion();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _presentSummary({List<Question>? questionsForTips}) async {
    if (!_resultsSaved || !mounted) return;

    final summaryAction = await showResultSummarySheet(
      context: context,
      correct: _savedCorrect ?? 0,
      incorrect: _savedIncorrect ?? 0,
      blank: _savedBlank ?? 0,
      score: _savedScore ?? 0,
      netScore: _savedNetScore ?? 0,
      successRate: _savedSuccessRate ?? 0,
      penalty: _topicPenalty,
      hasTips: _savedHasTips,
      averageScore: _averageScore,
      topicType: _topicType,
      flashcardStats: _isFlashcardMode ? _savedFlashcardStats : null,
    );

    final resolvedAction = summaryAction ?? ResultSummaryAction.continueReview;

    switch (resolvedAction) {
      case ResultSummaryAction.continueReview:
        if (mounted) {
          _navigationFocusNode.requestFocus();
        }
        break;
      case ResultSummaryAction.viewTips:
        final questions =
            questionsForTips ?? _questionCubit?.state.questions ?? [];
        if (questions.isNotEmpty) {
          await _showTipsDialog(questions);
        }
        if (mounted) {
          _navigationFocusNode.requestFocus();
        }
        break;
      case ResultSummaryAction.exit:
        if (mounted) {
          Navigator.of(context).pop();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    // Limpiar el stack de navegación hasta llegar al home
                    while (context.canPop()) {
                      context.pop();
                    }
                    // Asegurar que estamos en home
                    context.go(AppRoutes.home);
                  },
                  child: const Text('Volver al inicio'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_loading || _topic == null || _questionCubit == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider.value(
      value: _questionCubit!,
      child: Focus(
        focusNode: _navigationFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
          appBar: _TestHeader(
            title: _topic!.topicName,
            remaining: _remaining,
            currentIndex: _currentIndex,
            questionLength: _questionCubit!.state.questions.length,
            onViewIndex: _openQuestionIndex,
            topicType: _topicType,
            groupedSession: _groupedSession, // 🆕 Pasar sesión agrupada
          ),
          body: BlocBuilder<QuestionCubit, QuestionState>(
            builder: (context, state) {
              final questions = state.questions;
              if (state.fetchQuestionsStatus.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.fetchQuestionOptionsStatus.isLoading &&
                  state.questionOptions.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return PageView.builder(
                controller: _pageController,
                itemCount: questions.length,
                physics: _isFlashcardMode
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  final previousIndex = _currentIndex;
                  _recordQuestionDurationForIndex(previousIndex);
                  if (_currentIndex != index) {
                    setState(() {
                      _currentIndex = index;
                      _questionStartTime = DateTime.now();
                    });
                  } else {
                    _questionStartTime = DateTime.now();
                  }
                },
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final options = _optionsFor(question, state.questionOptions);

                  if (_isFlashcardMode) {
                    final questionKey = question.id ?? index;
                    return FlashcardView(
                      question: question,
                      options: options,
                      canFlip: !_testFinished,
                      initiallyFlipped: _testFinished
                          ? true
                          : (_flashcardFlipped[questionKey] ?? false),
                      selectedDifficulty: _difficultyRatings[questionKey],
                      onFlipChanged: (isFlipped) {
                        final currentValue =
                            _flashcardFlipped[questionKey] ?? false;
                        if (currentValue != isFlipped) {
                          setState(() {
                            _flashcardFlipped[questionKey] = isFlipped;
                          });
                        }
                      },
                      onDifficultySelected: (difficulty) {
                        if (!_testFinished) {
                          setState(() {
                            _difficultyRatings[questionKey] = difficulty;
                            _selectedOptions[questionKey] =
                                options.length > 1 ? options[1].id : null;
                            _flashcardFlipped[questionKey] = true;
                          });

                          // Auto-avanzar a la siguiente pregunta si no es la última
                          final isLastQuestion = index == questions.length - 1;
                          if (!isLastQuestion) {
                            Future.delayed(const Duration(milliseconds: 400),
                                () {
                              if (mounted && _pageController.hasClients) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            });
                          }
                        }
                      },
                    );
                  }

                  return _QuestionPage(
                    index: index,
                    total: questions.length,
                    question: question,
                    options: options,
                    selectedOptionId: _selectedOptions[question.id ?? index],
                    showTip: _tipsUnlocked,
                    testFinished: _testFinished,
                    onSelect: (optionId) {
                      if (!_testFinished) {
                        setState(() {
                          _selectedOptions[question.id ?? index] = optionId;
                        });

                        // Auto-avanzar a la siguiente pregunta si no es la última
                        final isLastQuestion = index == questions.length - 1;
                        if (!isLastQuestion) {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted && _pageController.hasClients) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          });
                        }
                      }
                    },
                  );
                },
              );
            },
          ),
          bottomNavigationBar: BlocBuilder<QuestionCubit, QuestionState>(
            builder: (context, state) {
              if (state.fetchQuestionsStatus.isLoading) {
                return const SizedBox.shrink();
              }
              final questions = state.questions;
              if (questions.isEmpty) {
                return const SizedBox.shrink();
              }

              final clampedIndex = _currentIndex.clamp(0, questions.length - 1);
              final currentQuestion = questions[clampedIndex];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NavigationControls(
                    controller: _pageController,
                    questions: questions,
                    currentIndex: clampedIndex,
                    isFinishing: _finishing,
                    testFinished: _testFinished,
                    topicType: _topicType,
                    onFinish: _finishTest,
                  ),
                  QuestionActionsBar(
                    isFavorite:
                        _isQuestionFavorite(currentQuestion),
                    onReport: () =>
                        _handleImpugnation(currentQuestion, clampedIndex),
                    onToggleFavorite: () =>
                        _toggleFavorite(currentQuestion),
                    onChatWithAi: _handleChatWithAi,
                    onShare: () {
                      unawaited(_shareQuestion(currentQuestion));
                    },
                    // Chat IA habilitado cuando el test ha finalizado O en revisión de historial
                    isChatWithAiDisabled: !_testFinished && !widget.isHistoryReview,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<QuestionOption> _optionsFor(
      Question question, List<QuestionOption> allOptions) {
    final questionId = question.id;
    if (questionId == null) return [];

    // Verificar cache primero
    if (_optionsCache.containsKey(questionId)) {
      return _optionsCache[questionId]!;
    }

    final options = allOptions
        .where((opt) => opt.questionId == questionId)
        .toList();

    // Aplicar shuffle o preservar orden según configuración
    final orderedOptions = sortOrShuffleOptions(
      options,
      shouldShuffle: question.shuffled,
      preservedOrder: _preservedOptionsOrder[questionId],
      isFlashcardMode: _isFlashcardMode,
    );

    // Guardar en cache
    _optionsCache[questionId] = orderedOptions;

    return orderedOptions;
  }

  Map<String, int> _buildFlashcardStats(List<Question> questions) {
    final stats = <String, int>{
      'again': 0,
      'hard': 0,
      'medium': 0,
      'easy': 0,
      'pending': 0,
    };

    for (var index = 0; index < questions.length; index++) {
      final question = questions[index];
      final key = question.id ?? index;
      final rating = _difficultyRatings[key];
      if (rating == null || rating.isEmpty) {
        stats['pending'] = (stats['pending'] ?? 0) + 1;
        continue;
      }

      if (stats.containsKey(rating)) {
        stats[rating] = (stats[rating] ?? 0) + 1;
      } else {
        stats['pending'] = (stats['pending'] ?? 0) + 1;
      }
    }

    return stats;
  }

  void _recordQuestionDurationForIndex(int index) {
    if (_questionStartTime == null) return;
    final questions = _questionCubit?.state.questions;
    if (questions == null || index < 0 || index >= questions.length) return;
    final question = questions[index];
    final questionId = question.id;
    if (questionId == null) return;
    final elapsedSeconds =
        DateTime.now().difference(_questionStartTime!).inSeconds;
    if (elapsedSeconds <= 0) return;
    _questionDurationsSeconds[questionId] =
        (_questionDurationsSeconds[questionId] ?? 0) + elapsedSeconds;
  }

  Future<void> _showTipsDialog(List<Question> questions) async {
    if (!mounted) return;

    final tipEntries = <Map<String, dynamic>>[];
    for (var i = 0; i < questions.length; i++) {
      final tipText = questions[i].tip?.trim();
      if (tipText == null || tipText.isEmpty) continue;
      tipEntries.add({
        'index': i,
        'question': questions[i],
        'tip': tipText,
      });
    }

    if (tipEntries.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Text(
                    'Tips del test',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: tipEntries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final entry = tipEntries[index];
                      final questionIndex = (entry['index'] as int) + 1;
                      final question = entry['question'] as Question;
                      final tipText = entry['tip'] as String;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$questionIndex',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          if (question.question.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              question.question,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tipText,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openQuestionIndex() async {
    final cubit = _questionCubit;
    if (cubit == null || !mounted) return;
    final questions = cubit.state.questions;
    final questionOptions = cubit.state.questionOptions;
    if (questions.isEmpty) return;

    final selectedIndex = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => QuestionIndexPage(
          questions: questions,
          selectedOptions: _selectedOptions,
          currentIndex: _currentIndex,
          questionOptions: questionOptions,
          scrollController: cubit.questionIndexScrollController,
          isFlashcardMode: _isFlashcardMode,
          difficultyRatings: _difficultyRatings,
        ),
      ),
    );

    if (selectedIndex == null ||
        selectedIndex < 0 ||
        selectedIndex >= questions.length) {
      return;
    }

    _recordQuestionDurationForIndex(_currentIndex);
    if (!mounted) return;
    setState(() {
      _currentIndex = selectedIndex;
      _questionStartTime = DateTime.now();
    });

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        selectedIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishTest() async {
    logger.info('🏁 [FINISH_TEST] Iniciando finishTest...');
    if (_finishing) {
      logger.warning('⚠️ [FINISH_TEST] Ya está finalizando, abortando');
      return;
    }

    // Establecer flag ANTES de mostrar el diálogo para prevenir doble-tap
    setState(() => _finishing = true);

    final cubit = _questionCubit;
    if (cubit == null) {
      logger.error('❌ [FINISH_TEST] QuestionCubit es null');
      setState(() => _finishing = false);
      return;
    }
    final state = cubit.state;

    if (_testFinished && _resultsSaved) {
      logger.info('✅ [FINISH_TEST] Test ya finalizado, mostrando resumen');
      setState(() => _finishing = false);
      await _presentSummary(questionsForTips: state.questions);
      return;
    }

    if (state.questions.isEmpty) {
      logger.warning('⚠️ [FINISH_TEST] No hay preguntas para finalizar');
      setState(() => _finishing = false);
      _showMessage('No hay preguntas para finalizar.');
      return;
    }

    logger.info('📝 [FINISH_TEST] Mostrando diálogo de confirmación...');
    // Detectar si es un test generado (topic con ID negativo)
    final isGeneratedTest = _topic?.id != null && _topic!.id! < 0;
    final confirmation = await showFinishConfirmationSheet(
      context: context,
      topicType: _topicType,
      isTestGroup: _isGroupedTest,
      isLastPart: _groupedSession?.isLastPart ?? true,
      isGeneratedTest: isGeneratedTest, // 🆕 Pasar flag al diálogo
    );

    logger.info('🎯 [FINISH_TEST] Acción seleccionada: $confirmation');

    // Manejar acción "Continuar más tarde"
    if (confirmation == FinishConfirmationAction.continueLater) {
      logger.info('⏸️ [FINISH_TEST] Usuario seleccionó "Continuar más tarde"');
      await _saveDraftTest();
      return;
    }

    if (confirmation != FinishConfirmationAction.finalize) {
      logger.info('❌ [FINISH_TEST] Usuario canceló la finalización');
      setState(() => _finishing = false);
      if (mounted) {
        _navigationFocusNode.requestFocus();
      }
      return;
    }

    final wasPreviouslySaved = _resultsSaved;

    logger.info('🚀 [FINISH_TEST] Procediendo a finalizar test...');
    setState(() => _finishing = true);
    _recordQuestionDurationForIndex(_currentIndex);

    try {
      logger.info('👤 [FINISH_TEST] Obteniendo usuario...');
      final user = context.read<AuthCubit>().state.user;
      logger.info('👤 [FINISH_TEST] Usuario ID: ${user.id}');
      if (user.id == 0) {
        logger.error('❌ [FINISH_TEST] Usuario no autenticado (ID = 0)');
        _showMessage('Usuario no autenticado.');
        return;
      }

      logger.info('📊 [FINISH_TEST] Topic: ${_topic?.topicName} (ID: ${_topic?.id})');
      final topic = _topic!;
      final questions = state.questions;
      final questionOptions = state.questionOptions;
      logger.info('📝 [FINISH_TEST] Total preguntas: ${questions.length}, Opciones: ${questionOptions.length}');

      int right = 0;
      int wrong = 0;
      int answered = 0;

      final pendingAnswers = <Map<String, dynamic>>[];
      logger.info('🔄 [FINISH_TEST] Procesando respuestas...');
      logger.info('✅ [FINISH_TEST] Respuestas contestadas: ${_selectedOptions.length}');

      for (var i = 0; i < questions.length; i++) {
        final question = questions[i];
        final questionId = question.id;
        final key = questionId ?? i;

        final selectedOptionId = _selectedOptions[key];
        bool? isCorrect;
        if (selectedOptionId != null) {
          answered++;
          final option = questionOptions.firstWhere(
            (opt) => opt.id == selectedOptionId,
            orElse: () => const QuestionOption(
              id: null,
              questionId: 0,
              answer: '',
            ),
          );
          if (option.id != null) {
            isCorrect = option.isCorrect;
            if (isCorrect) {
              right++;
            } else {
              wrong++;
            }
          }
        }

        if (questionId == null) continue;

        final durationSeconds = _questionDurationsSeconds[questionId] ?? 0;
        final difficultyRating =
            _isFlashcardMode ? _difficultyRatings[key] : null;

        // Obtener el orden de opciones visible al usuario
        final visibleOptions = _optionsFor(question, questionOptions);
        final shuffledIds = extractOptionIds(visibleOptions);

        pendingAnswers.add({
          'question_id': questionId,
          'selected_option_id': selectedOptionId,
          'correct': isCorrect,
          'time_taken_seconds': durationSeconds > 0 ? durationSeconds : null,
          'question_order': i + 1,
          'challenge_by_tutor': question.challengeByTutor,
          'difficulty_rating': difficultyRating,
          'shuffled_option_ids': shuffledIds,
        });
      }

      final totalQuestions = questions.length;
      final timeSpentMillis = _testStartTime != null
          ? DateTime.now().difference(_testStartTime!).inMilliseconds
          : null;
      final blank = cubit.calculateBlankAnswers(
        totalQuestions: totalQuestions,
        answered: answered,
      );
      final netScore = cubit.calculateRawScore(
        correct: right,
        incorrect: wrong,
        penaltyPerWrong: _topicPenalty,
      );
      final score = cubit.calculateFinalScore(
        correct: right,
        incorrect: wrong,
        totalQuestions: totalQuestions,
        penaltyPerWrong: _topicPenalty,
      );
      final successRate = cubit.calculateSuccessRate(
        correct: right,
        totalQuestions: totalQuestions,
      );

      // 🆕 Determinar si estamos completando un test retomado
      final isCompletingResumedTest = widget.isResumingTest &&
                                       widget.userTest?.id != null &&
                                       widget.userTest!.finalized == false;

      UserTest completedTest;
      int userTestId;

      if (isCompletingResumedTest) {
        // CASO 1: Completando un test retomado - actualizar el existente
        userTestId = widget.userTest!.id!;

        // Eliminar las respuestas antiguas (parciales)
        await _historyRepository.deleteAnswersForTest(userTestId);

        // Crear respuestas completas y nuevas
        final answersModels = pendingAnswers
            .map(
              (answer) => UserTestAnswer(
                userTestId: userTestId,
                questionId: answer['question_id'] as int,
                selectedOptionId: answer['selected_option_id'] as int?,
                correct: answer['correct'] as bool?,
                timeTakenSeconds: answer['time_taken_seconds'] as int?,
                questionOrder: answer['question_order'] as int,
                challengeByTutor: answer['challenge_by_tutor'] as bool? ?? false,
                difficultyRating: answer['difficulty_rating'] as String?,
                shuffledOptionIds: (answer['shuffled_option_ids'] as List<int>?)?.isNotEmpty == true
                    ? answer['shuffled_option_ids'] as List<int>
                    : null,
              ),
            )
            .toList();

        await _historyRepository.insertUserTestAnswers(answersModels);

        // Actualizar el UserTest existente con resultados finales
        completedTest = widget.userTest!.copyWith(
          rightQuestions: right,
          wrongQuestions: wrong,
          questionCount: totalQuestions,
          totalAnswered: answered,
          score: score,
          finalized: true,
          timeSpentMillis: timeSpentMillis,
          totalTimeSeconds: timeSpentMillis != null ? (timeSpentMillis / 1000).round() : null,
        );

        await _historyRepository.updateUserTest(userTestId, completedTest);
      } else {
        // CASO 2: Nuevo test - crear desde cero

        // 🆕 Test agrupado vs simple: crear UserTest apropiado
        final UserTest initialUserTest;
        if (_isGroupedTest && _groupedSession != null) {
          // Test agrupado: crear con topic_group_id
          initialUserTest = GroupedTestHandler.createUserTestForGroup(
            userId: user.id,
            topic: topic,
            session: _groupedSession!,
            rightQuestions: right,
            wrongQuestions: wrong,
            questionCount: totalQuestions,
            totalAnswered: answered,
            score: score,
            timeSpentMillis: timeSpentMillis,
            isFlashcardMode: _isFlashcardMode,
          );
        } else {
          // Test simple: crear sin topic_group_id
          initialUserTest = UserTest(
            userId: user.id,
            topicIds: [topic.id!],
            options: topic.options,
            rightQuestions: right,
            wrongQuestions: wrong,
            questionCount: totalQuestions,
            totalAnswered: answered,
            score: score,
            finalized: false,
            visible: true,
            durationSeconds: topic.durationSeconds ?? 0,
            timeSpentMillis: null,
            specialTopic: topic.id,
            specialTopicTitle: topic.topicName,
            createdAt: null,
            updatedAt: null,
            isFlashcardMode: _isFlashcardMode,
          );
        }

        final insertedUserTest =
            await _historyRepository.createUserTest(initialUserTest);
        userTestId = insertedUserTest.id!;
        if (userTestId == null) {
          _showMessage('No se pudo registrar el resultado del test.');
          return;
        }

        final answersModels = pendingAnswers
            .map(
              (answer) => UserTestAnswer(
                userTestId: userTestId,
                questionId: answer['question_id'] as int,
                selectedOptionId: answer['selected_option_id'] as int?,
                correct: answer['correct'] as bool?,
                timeTakenSeconds: answer['time_taken_seconds'] as int?,
                questionOrder: answer['question_order'] as int,
                challengeByTutor: answer['challenge_by_tutor'] as bool? ?? false,
                difficultyRating: answer['difficulty_rating'] as String?,
                shuffledOptionIds: (answer['shuffled_option_ids'] as List<int>?)?.isNotEmpty == true
                    ? answer['shuffled_option_ids'] as List<int>
                    : null,
              ),
            )
            .toList();

        await _historyRepository.insertUserTestAnswers(answersModels);

        completedTest = insertedUserTest.copyWith(
          rightQuestions: right,
          wrongQuestions: wrong,
          questionCount: totalQuestions,
          totalAnswered: answered,
          score: score,
          finalized: true,
          timeSpentMillis: timeSpentMillis,
        );

        await _historyRepository.updateUserTest(userTestId, completedTest);
      }

      // Actualizar el historial, topics completados y estadísticas del usuario
      if (mounted) {
        final historyCubit = context.read<HistoryCubit>();
        final topicCubit = context.read<TopicCubit>();
        final authCubit = context.read<AuthCubit>();
        await Future.wait([
          historyCubit.refresh(),
          topicCubit.fetchCompletedTopics(),
          authCubit.refreshQuestionStats(),
        ]);
      }

      if (!mounted) return;

      // 🆕 Test agrupado vs simple: navegar apropiadamente
      if (_isGroupedTest && _groupedSession != null) {
        print('🔍 [TopicTestPage] ANTES de handleGroupedFinish:');
        print('🔍 [TopicTestPage] - widget.topic.id: ${widget.topic!.id!}');
        print('🔍 [TopicTestPage] - widget.topic.topicName: ${widget.topic!.topicName}');
        print('🔍 [TopicTestPage] - _groupedSession.currentTopicIndex: ${_groupedSession!.currentTopicIndex}');
        print('🔍 [TopicTestPage] - _groupedSession.totalParts: ${_groupedSession!.totalParts}');
        print('🔍 [TopicTestPage] - _groupedSession.currentTopic.id: ${_groupedSession!.currentTopic.id}');
        print('🔍 [TopicTestPage] - userTestId guardado: $userTestId');

        // Test agrupado: resetear flag ANTES de navegar
        if (mounted) {
          setState(() => _finishing = false);
        }

        // Usar handler para navegar
        await GroupedTestHandler.handleGroupedFinish(
          context: context,
          session: _groupedSession!,
          completedTest: completedTest,
          savedUserTestId: userTestId,
        );

        print('🔍 [TopicTestPage] DESPUÉS de handleGroupedFinish');
        return; // No ejecutar el flujo normal de presentación
      }

      // Test simple: flujo normal con presentación de resultados
      final hasTips =
          questions.any((question) => (question.tip ?? '').trim().isNotEmpty);
      final flashcardStats =
          _isFlashcardMode ? _buildFlashcardStats(questions) : null;
      Map<int, bool>? finalizedFlips;
      if (_isFlashcardMode) {
        finalizedFlips = Map<int, bool>.from(_flashcardFlipped);
        for (var i = 0; i < questions.length; i++) {
          final question = questions[i];
          final key = question.id ?? i;
          finalizedFlips[key] = true;
        }
      }

      if (mounted) {
        setState(() {
          _tipsUnlocked = true;
          _testFinished = true;
          _resultsSaved = true;
          _savedCorrect = right;
          _savedIncorrect = wrong;
          _savedBlank = blank;
          _savedScore = score;
          _savedNetScore = netScore;
          _savedSuccessRate = successRate;
          _savedHasTips = hasTips;
          _savedFlashcardStats = flashcardStats;
          if (finalizedFlips != null) {
            _flashcardFlipped
              ..clear()
              ..addAll(finalizedFlips);
          }
        });
      }

      await _presentSummary(questionsForTips: questions);
    } catch (e) {
      logger.error('Error finalizando test (topic: ${_topic?.id}): $e');
      _showMessage('No se pudo guardar el resultado del test.');
    } finally {
      if (mounted) {
        setState(() => _finishing = false);
      }
    }
  }

  /// Guarda el test parcialmente para continuar más tarde
  Future<void> _saveDraftTest() async {
    setState(() => _finishing = true);
    _recordQuestionDurationForIndex(_currentIndex);

    try {
      final user = context.read<AuthCubit>().state.user;
      if (user.id == 0) {
        _showMessage('Usuario no autenticado.');
        return;
      }

      final cubit = _questionCubit;
      if (cubit == null) return;

      final topic = _topic!;
      final questions = cubit.state.questions;
      final questionOptions = cubit.state.questionOptions;

      // Calcular respuestas actuales (solo las que ha respondido)
      int right = 0;
      int wrong = 0;
      int answered = 0;

      final pendingAnswers = <Map<String, dynamic>>[];

      for (var i = 0; i < questions.length; i++) {
        final question = questions[i];
        final questionId = question.id;
        final key = questionId ?? i;

        final selectedOptionId = _selectedOptions[key];
        bool? isCorrect;
        if (selectedOptionId != null) {
          answered++;
          final option = questionOptions.firstWhere(
            (opt) => opt.id == selectedOptionId,
            orElse: () => const QuestionOption(
              id: null,
              questionId: 0,
              answer: '',
            ),
          );
          if (option.id != null) {
            isCorrect = option.isCorrect;
            if (isCorrect) {
              right++;
            } else {
              wrong++;
            }
          }
        }

        if (questionId == null) continue;

        final durationSeconds = _questionDurationsSeconds[questionId] ?? 0;
        final difficultyRating =
            _isFlashcardMode ? _difficultyRatings[key] : null;

        pendingAnswers.add({
          'question_id': questionId,
          'selected_option_id': selectedOptionId,
          'correct': isCorrect,
          'time_taken_seconds': durationSeconds > 0 ? durationSeconds : null,
          'question_order': i + 1,
          'challenge_by_tutor': question.challengeByTutor,
          'difficulty_rating': difficultyRating,
        });
      }

      final totalQuestions = questions.length;
      final timeSpentMillis = _testStartTime != null
          ? DateTime.now().difference(_testStartTime!).inMilliseconds
          : null;
      final totalTimeSeconds = timeSpentMillis != null
          ? (timeSpentMillis / 1000).round()
          : 0;

      // Crear UserTest con finalized: false (test pausado)
      final draftUserTest = UserTest(
        id: _currentUserTestId, // Usar el ID existente si estamos actualizando
        userId: user.id,
        topicIds: [topic.id!],
        options: topic.options,
        rightQuestions: right,
        wrongQuestions: wrong,
        questionCount: totalQuestions,
        totalAnswered: answered,
        score: null, // No hay puntuación final aún
        finalized: false, // ← Clave: test no finalizado
        visible: true,
        durationSeconds: topic.durationSeconds ?? 0,
        timeSpentMillis: timeSpentMillis,
        totalTimeSeconds: totalTimeSeconds,
        specialTopic: topic.id,
        specialTopicTitle: topic.topicName,
        createdAt: null,
        updatedAt: null,
        isFlashcardMode: _isFlashcardMode,
      );

      // Guardar o actualizar en BD
      UserTest insertedUserTest;
      if (_currentUserTestId != null) {
        // Actualizar test existente
        print('🔄 [SAVE_DRAFT] Actualizando test existente con ID: $_currentUserTestId');
        insertedUserTest = await _historyRepository.updateUserTest(_currentUserTestId!, draftUserTest);

        // Borrar las respuestas antiguas antes de insertar las nuevas
        await _historyRepository.deleteAnswersForTest(_currentUserTestId!);
      } else {
        // Crear nuevo test
        print('🆕 [SAVE_DRAFT] Creando nuevo test');
        insertedUserTest = await _historyRepository.createUserTest(draftUserTest);

        // Guardar el ID para futuras actualizaciones
        _currentUserTestId = insertedUserTest.id;
      }

      final userTestId = insertedUserTest.id;
      if (userTestId == null) {
        _showMessage('No se pudo guardar el progreso del test.');
        return;
      }

      // Guardar respuestas
      final answersModels = pendingAnswers
          .map(
            (answer) => UserTestAnswer(
              userTestId: userTestId,
              questionId: answer['question_id'] as int,
              selectedOptionId: answer['selected_option_id'] as int?,
              correct: answer['correct'] as bool?,
              timeTakenSeconds: answer['time_taken_seconds'] as int?,
              questionOrder: answer['question_order'] as int,
              challengeByTutor: answer['challenge_by_tutor'] as bool? ?? false,
              difficultyRating: answer['difficulty_rating'] as String?,
            ),
          )
          .toList();

      await _historyRepository.insertUserTestAnswers(answersModels);

      // Refrescar el historial para que aparezca el test guardado
      if (mounted) {
        final historyCubit = context.read<HistoryCubit>();
        await historyCubit.refresh();
      }

      if (!mounted) return;

      _showMessage('Progreso guardado. Puedes continuar desde el historial.');

      // Salir del test
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      logger.error('Error guardando draft test: $e');
      _showMessage('No se pudo guardar el progreso del test.');
    } finally {
      if (mounted) {
        setState(() => _finishing = false);
      }
    }
  }
}

class _TestHeader extends StatelessWidget implements PreferredSizeWidget {
  const _TestHeader({
    required this.title,
    required this.remaining,
    required this.onViewIndex,
    required this.currentIndex,
    required this.questionLength,
    required this.topicType,
    this.groupedSession, // 🆕 Sesión agrupada opcional
  });

  final String title;
  final int questionLength;
  final int currentIndex;
  final Duration? remaining;
  final VoidCallback onViewIndex;
  final TopicType? topicType;
  final GroupedTestSession? groupedSession;

  static const double _height = 72;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final showTimer = remaining != null && remaining! > Duration.zero;
    final timeText = showTimer
        ? '${remaining!.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(remaining!.inSeconds.remainder(60)).toString().padLeft(2, '0')}'
        : '';

    // 🆕 Determinar si es test agrupado
    final isGrouped = groupedSession != null;

    return Material(
      color: colors.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: _height,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del topic + contador de preguntas (igual en ambos modos)
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${currentIndex + 1}/$questionLength',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // 🆕 Si es test agrupado, mostrar indicador de parte
                    if (isGrouped) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Parte ${groupedSession!.currentPartNumber} de ${groupedSession!.totalParts}',
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    // Timer (se muestra en ambos modos)
                    if (showTimer) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 18, color: colors.primary),
                          const SizedBox(width: 6),
                          Text(
                            timeText,
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: onViewIndex,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  textStyle: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: Colors.transparent,
                  foregroundColor: colors.onSecondaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.spellcheck),
                label: Text(topicType?.isTest ?? true
                    ? 'Ver test'
                    : topicType?.isFlashcards ?? false
                        ? 'Ver flashcards'
                        : 'Ver indice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    required this.index,
    required this.total,
    required this.question,
    required this.options,
    required this.selectedOptionId,
    required this.onSelect,
    this.showTip = true,
    this.testFinished = false,
  });

  final int index;
  final int total;
  final Question question;
  final List<QuestionOption> options;
  final int? selectedOptionId;
  final ValueChanged<int> onSelect;
  final bool showTip;
  final bool testFinished;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question.trim().isEmpty
                ? 'Pregunta sin enunciado'
                : question.question,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          if (question.questionImageUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                question.questionImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: colors.surfaceContainerLow,
                  alignment: Alignment.center,
                  child: Icon(Icons.image_not_supported_outlined,
                      color: colors.onSurfaceVariant),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (options.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No hay opciones disponibles para esta pregunta.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < options.length; i++) ...[
                  _OptionTile(
                    index: i,
                    option: options[i],
                    selected: selectedOptionId == options[i].id,
                    testFinished: testFinished,
                    onTap: options[i].id == null || testFinished
                        ? null
                        : () => onSelect(options[i].id!),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          AfterFinishRetro(
            question: question,
            visible: showTip && testFinished,
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.index,
    required this.option,
    required this.selected,
    this.onTap,
    this.testFinished = false,
  });

  final int index;
  final QuestionOption option;
  final bool selected;
  final VoidCallback? onTap;
  final bool testFinished;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final letter = String.fromCharCode('A'.codeUnitAt(0) + index);

    // Determinar el estado de la opción cuando el test está finalizado
    Color borderColor;
    Color backgroundColor;
    Color letterBgColor;
    Color letterColor;
    IconData? resultIcon;
    Color? resultIconColor;

    final successColor = const Color(0xFF4CAF50);
    final errorColor = colors.error;

    if (testFinished) {
      // Modo corrección
      if (option.isCorrect) {
        // Opción correcta
        borderColor = successColor;
        backgroundColor = successColor.withValues(alpha: 0.1);
        letterBgColor = successColor;
        letterColor = colors.surface;
        resultIcon = Icons.check_circle;
        resultIconColor = successColor;
      } else if (selected) {
        // Opción incorrecta seleccionada
        borderColor = errorColor;
        backgroundColor = errorColor.withValues(alpha: 0.1);
        letterBgColor = errorColor;
        letterColor = colors.surface;
        resultIcon = Icons.cancel;
        resultIconColor = errorColor;
      } else {
        // Opción no seleccionada e incorrecta
        borderColor = colors.outlineVariant;
        backgroundColor = colors.surfaceContainerLowest;
        letterBgColor = Colors.transparent;
        letterColor = colors.onSurfaceVariant;
      }
    } else {
      // Modo normal (test en progreso)
      if (selected) {
        borderColor = colors.primary;
        backgroundColor = colors.primary.withValues(alpha: 0.08);
        letterBgColor = colors.primary;
        letterColor = colors.onPrimary;
      } else {
        borderColor = colors.outlineVariant;
        backgroundColor = colors.surfaceContainerLowest;
        letterBgColor = Colors.transparent;
        letterColor = colors.onSurface;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: selected || (testFinished && option.isCorrect) ? 2 : 1,
          ),
          color: backgroundColor,
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: testFinished && !option.isCorrect && !selected
                      ? colors.onSurfaceVariant
                      : (testFinished && option.isCorrect)
                          ? successColor
                          : (selected && testFinished)
                              ? errorColor
                              : selected
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                ),
                color: letterBgColor,
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: textTheme.bodyMedium?.copyWith(
                  color: letterColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.answer,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ),
            if (testFinished && resultIcon != null) ...[
              const SizedBox(width: 8),
              Icon(
                resultIcon,
                color: resultIconColor,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget para compartir pregunta como imagen
class _QuestionShareWidget extends StatelessWidget {
  const _QuestionShareWidget({
    required this.question,
    required this.options,
    required this.colors,
    required this.textTheme,
  });

  final Question question;
  final List<QuestionOption> options;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.primary, width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'OPN Test',
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pregunta
          Text(
            question.question,
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          // Opciones
          ...options.map((option) {
            final letter = String.fromCharCode(65 + option.optionOrder - 1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: textTheme.titleSmall?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option.answer,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Preparado con OPN Test App',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

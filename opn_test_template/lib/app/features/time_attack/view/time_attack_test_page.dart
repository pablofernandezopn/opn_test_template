import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../config/go_route/app_routes.dart';
import '../../../config/service_locator.dart';
import '../../../core/utils/question_utils.dart';
import '../../history/model/user_test_model.dart';
import '../../history/repository/history_repository.dart';
import '../../history/cubit/history_cubit.dart';
import '../../questions/model/question_model.dart';
import '../../questions/model/question_option_model.dart';
import '../../questions/view/components/question_display.dart';
import '../../questions/view/components/navigation_controls.dart';
import '../../questions/view/components/question_actions_bar.dart';
import '../../favorites/cubit/favorite_cubit.dart';
import '../../challenges/cubit/challenge_cubit.dart';
import '../../challenges/view/components/create_challenge_dialog.dart';
import '../../survival/widgets/level_up_overlay.dart';
import '../model/time_attack_session.dart';
import '../repository/time_attack_repository.dart';
import '../widgets/time_attack_stats_bar.dart';
import '../widgets/time_up_dialog.dart';
import '../widgets/finish_options_sheet.dart';
import '../../../../bootstrap.dart';

class TimeAttackTestPage extends StatefulWidget {
  final int timeLimitSeconds;
  final int? topicTypeId;
  final int? specialtyId;
  final int? resumeSessionId;
  final bool reviewMode;

  const TimeAttackTestPage({
    super.key,
    required this.timeLimitSeconds,
    this.topicTypeId,
    this.specialtyId,
    this.resumeSessionId,
    this.reviewMode = false,
  });

  @override
  State<TimeAttackTestPage> createState() => _TimeAttackTestPageState();
}

class _TimeAttackTestPageState extends State<TimeAttackTestPage> {
  final _repository = getIt<TimeAttackRepository>();
  final _historyRepository = getIt<HistoryRepository>();

  TimeAttackSession? _session;
  Timer? _countdownTimer;
  int _timeRemainingSeconds = 0;

  // PageView para navegación
  late PageController _pageController;

  // Buffer de preguntas
  List<Question> _questions = [];
  Map<int, List<QuestionOption>> _questionOptions = {};
  Map<int, int?> _selectedOptions = {};
  Map<int, DateTime> _questionStartTimes = {};

  // Cache del orden de opciones shuffleadas para preservar durante el test
  final Map<int, List<QuestionOption>> _optionsCache = {};

  int _currentPageIndex = 0;
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  int _previousLevel = 1;
  bool _testFinished = false;

  // Helper getters
  Question? get _currentQuestion =>
      _questions.isNotEmpty && _currentPageIndex < _questions.length
          ? _questions[_currentPageIndex]
          : null;

  List<QuestionOption>? get _currentOptions =>
      _currentQuestion != null ? _questionOptions[_currentQuestion!.id] : null;

  int? get _currentSelectedOption =>
      _currentQuestion != null ? _selectedOptions[_currentQuestion!.id] : null;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timeRemainingSeconds = widget.timeLimitSeconds;
    _initializeSession();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pageController.dispose();
    // Guardar progreso automáticamente si el test no ha finalizado
    if (_session != null && _session!.isActive && _session!.questionsAnswered > 0) {
      _saveProgressToHistory(finalized: false);
    }
    super.dispose();
  }

  // El tiempo SÍ cuenta hacia atrás automáticamente cada segundo
  // Y ADEMÁS se ajusta cuando respondes (+5s correcto, -2s fallo)
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Restar 1 segundo automáticamente
      if (_timeRemainingSeconds > 0 && !_testFinished) {
        setState(() {
          _timeRemainingSeconds--;
        });
      } else if (_timeRemainingSeconds <= 0 && !_testFinished) {
        timer.cancel();
        _onTimeUp();
      }
    });
  }

  Future<void> _initializeSession() async {
    if (widget.resumeSessionId != null) {
      if (widget.reviewMode) {
        await _reviewSession(widget.resumeSessionId!);
      } else {
        await _resumeSession(widget.resumeSessionId!);
      }
    } else {
      await _startNewSession();
    }
  }

  Future<void> _startNewSession() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final authCubit = context.read<AuthCubit>();
      final user = authCubit.state.user;

      if (user.id == 0) {
        _setError('Debes iniciar sesión para jugar');
        return;
      }

      final session = await _repository.startSession(
        userId: user.id,
        academyId: user.academyId ?? 1,
        timeLimitSeconds: widget.timeLimitSeconds,
        topicTypeId: widget.topicTypeId,
        specialtyId: widget.specialtyId,
      );

      if (!mounted) return;

      setState(() {
        _session = session;
        _timeRemainingSeconds = session.timeLimitSeconds;
        _previousLevel = session.currentLevel;
      });

      await _loadNextQuestions(count: 2);

      // Iniciar el countdown
      _startCountdown();
    } catch (e) {
      _setError('Error al iniciar sesión: $e');
    }
  }

  Future<void> _resumeSession(int sessionId) async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final session = await _repository.getSession(sessionId);

      if (session == null) {
        _setError('Sesión no encontrada');
        return;
      }

      if (!session.isActive) {
        _setError('Esta sesión ya ha finalizado');
        return;
      }

      // Cargar las preguntas respondidas anteriormente
      final answersMap = await _repository.getSessionAnswers(sessionId: sessionId);

      if (!mounted) return;

      for (final answerData in answersMap.values) {
        final question = Question(
          id: answerData.questionId,
          question: answerData.questionText,
          topic: -3, // -3 indica modo contra reloj
        );

        final options = answerData.options.map((opt) {
          return QuestionOption(
            id: opt.id,
            questionId: answerData.questionId,
            answer: opt.answer,
            optionOrder: opt.optionOrder,
            isCorrect: opt.isCorrect,
          );
        }).toList();

        _questions.add(question);
        _questionOptions[answerData.questionId] = options;
        _selectedOptions[answerData.questionId] = answerData.selectedOptionId;
      }

      setState(() {
        _session = session;
        _timeRemainingSeconds = session.timeRemainingSeconds;
        _previousLevel = session.currentLevel;
        _currentPageIndex = _questions.length - 1;
      });

      await _loadNextQuestions(count: 2);
      _startCountdown();
    } catch (e) {
      _setError('Error al reanudar sesión: $e');
    }
  }

  Future<void> _reviewSession(int sessionId) async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final session = await _repository.getSession(sessionId);

      if (session == null) {
        _setError('Sesión no encontrada');
        return;
      }

      final answersMap = await _repository.getSessionAnswers(sessionId: sessionId);

      if (!mounted) return;

      for (final answerData in answersMap.values) {
        final question = Question(
          id: answerData.questionId,
          question: answerData.questionText,
          topic: -3,
        );

        final options = answerData.options.map((opt) {
          return QuestionOption(
            id: opt.id,
            questionId: answerData.questionId,
            answer: opt.answer,
            optionOrder: opt.optionOrder,
            isCorrect: opt.isCorrect,
          );
        }).toList();

        _questions.add(question);
        _questionOptions[answerData.questionId] = options;
        _selectedOptions[answerData.questionId] = answerData.selectedOptionId;
      }

      setState(() {
        _session = session;
        _timeRemainingSeconds = session.timeRemainingSeconds;
        _testFinished = true;
        _loading = false;
      });
    } catch (e) {
      _setError('Error al cargar sesión para revisión: $e');
    }
  }

  Future<void> _loadNextQuestions({int count = 1}) async {
    if (_session == null) return;

    try {
      for (int i = 0; i < count; i++) {
        final response = await _repository.getNextQuestion(sessionId: _session!.id!);

        if (!mounted) return;

        if (!response.success || response.timeUp == true || response.question == null) {
          break;
        }

        final question = response.question!;
        final rawOptions = response.options ?? [];

        // Aplicar shuffle si la pregunta lo requiere
        final orderedOptions = sortOrShuffleOptions(
          rawOptions,
          shouldShuffle: question.shuffled,
          isFlashcardMode: false,
        );

        setState(() {
          _questions.add(question);
          _questionOptions[question.id!] = orderedOptions;
          _optionsCache[question.id!] = orderedOptions; // Cachear orden shuffleado
          _questionStartTimes[question.id!] = DateTime.now();
          if (response.session != null) {
            _session = response.session;
          }
          _loading = false;
        });
      }
    } catch (e) {
      _setError('Error al cargar preguntas: $e');
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });

    if (index >= _questions.length - 1 && !_testFinished) {
      _loadNextQuestions(count: 1);
    }
  }

  void _handleSelectOption(int? optionId) {
    if (_currentQuestion == null || _testFinished) return;

    setState(() {
      _selectedOptions[_currentQuestion!.id!] = optionId;
    });

    _submitAnswer();
  }

  Future<void> _submitAnswer() async {
    if (_session == null || _currentQuestion == null || _submitting || _testFinished) return;

    final questionId = _currentQuestion!.id;
    final selectedOptionId = _selectedOptions[questionId];

    if (selectedOptionId == null) return;

    try {
      setState(() => _submitting = true);

      final options = _currentOptions ?? [];
      final selectedOption = options.firstWhere((opt) => opt.id == selectedOptionId);
      final wasCorrect = selectedOption.isCorrect;

      final startTime = _questionStartTimes[questionId] ?? DateTime.now();
      final timeTaken = DateTime.now().difference(startTime).inSeconds;

      final response = await _repository.submitAnswer(
        sessionId: _session!.id!,
        questionId: questionId!,
        selectedOptionId: selectedOptionId,
        wasCorrect: wasCorrect,
        timeTakenSeconds: timeTaken,
      );

      if (!mounted) return;

      setState(() {
        _session = response.session;
        // Actualizar el tiempo restante desde el servidor
        _timeRemainingSeconds = response.session.timeRemainingSeconds;
        _submitting = false;
      });

      if (_session!.currentLevel > _previousLevel) {
        _showLevelUpAnimation();
        _previousLevel = _session!.currentLevel;
      }

      // Verificar si el tiempo se agotó después de la respuesta
      if (response.timeUp || _timeRemainingSeconds <= 0) {
        await Future.delayed(const Duration(milliseconds: 800));
        await _onTimeUp();
        return;
      }

      await Future.delayed(Duration(milliseconds: wasCorrect ? 800 : 1500));

      if (_currentPageIndex < _questions.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      } else {
        await _loadNextQuestions(count: 1);
        if (_currentPageIndex < _questions.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
      }
    } catch (e) {
      _setError('Error al enviar respuesta: $e');
      setState(() => _submitting = false);
    }
  }

  void _showLevelUpAnimation() {
    if (!mounted) return;
    showLevelUpOverlay(context, _session!.currentLevel);
  }

  Future<void> _onTimeUp() async {
    if (_session == null) return;

    _countdownTimer?.cancel();

    await _saveProgressToHistory(finalized: true);

    if (!mounted) return;

    setState(() {
      _testFinished = true;
    });

    final action = await showTimeUpDialog(
      context: context,
      session: _session!,
    );

    if (!mounted) return;

    if (action == null) {
      return;
    }

    switch (action) {
      case TimeUpAction.playAgain:
        setState(() {
          _questions.clear();
          _questionOptions.clear();
          _selectedOptions.clear();
          _questionStartTimes.clear();
          _currentPageIndex = 0;
          _testFinished = false;
        });
        await _startNewSession();
        break;

      case TimeUpAction.viewHistory:
        if (mounted) {
          context.read<HistoryCubit>().fetchHistory(refresh: true);
          context.read<HistoryCubit>().fetchRecentTests();
          context.go(AppRoutes.history);
        }
        break;

      case TimeUpAction.exit:
        if (mounted) {
          context.read<HistoryCubit>().fetchHistory(refresh: true);
          context.read<HistoryCubit>().fetchRecentTests();
          context.pop();
        }
        break;
    }
  }

  Future<void> _saveProgressToHistory({required bool finalized}) async {
    if (_session == null) return;

    try {
      final authCubit = context.read<AuthCubit>();
      final user = authCubit.state.user;

      if (user.id == 0) return;

      final specialTitle = finalized
          ? '⏱️ Contra reloj - Nivel ${_session!.currentLevel} • '
              '${_session!.questionsAnswered} preguntas • '
              'Racha: ${_session!.bestStreak} • '
              '${_session!.currentScore} pts'
          : '⏸️ Contra reloj EN PROGRESO - ${_timeRemainingSeconds}s restantes';

      final userTest = UserTest(
        userId: user.id,
        topicIds: [],
        options: 4,
        rightQuestions: _session!.questionsCorrect,
        wrongQuestions: _session!.questionsIncorrect,
        questionCount: _session!.questionsAnswered,
        totalAnswered: _session!.questionsAnswered,
        score: finalized ? (_session!.finalScore?.toDouble() ?? 0.0) : null,
        finalized: finalized,
        visible: true,
        durationSeconds: widget.timeLimitSeconds,
        timeSpentMillis: _session!.endedAt != null && _session!.startedAt != null
            ? _session!.endedAt!.difference(_session!.startedAt!).inMilliseconds
            : DateTime.now().difference(_session!.startedAt!).inMilliseconds,
        totalTimeSeconds: widget.timeLimitSeconds - _timeRemainingSeconds,
        specialTopic: -3, // -3 para modo contra reloj
        specialTopicTitle: specialTitle,
        timeAttackSessionId: _session!.id,
        createdAt: _session!.startedAt,
        updatedAt: finalized ? _session!.endedAt : DateTime.now(),
        isFlashcardMode: false,
      );

      final createdTest = await _historyRepository.createUserTest(userTest);
      final userTestId = createdTest.id!;

      // Crear mapa de shuffled option IDs
      final shuffledIds = <int, List<int>?>{};
      for (final entry in _optionsCache.entries) {
        shuffledIds[entry.key] = extractOptionIds(entry.value);
      }

      await _historyRepository.createUserTestAnswers(
        userTestId,
        _selectedOptions,
        _questionOptions,
        shuffledOptionIds: shuffledIds,
      );
    } catch (e) {
      logger.error('Error guardando en historial: $e');
    }
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _loading = false;
      _submitting = false;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
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
          isFavorite ? 'Pregunta añadida a favoritos.' : 'Pregunta eliminada de favoritos.',
        );
        setState(() {});
      } else {
        _showMessage('No se pudo actualizar el favorito.');
      }
    } catch (e) {
      _showMessage('Error al actualizar favorito.');
    }
  }

  Future<void> _handleImpugnation(Question question) async {
    final questionId = question.id;

    if (questionId == null) {
      _showMessage('No se puede impugnar esta pregunta.');
      return;
    }

    final result = await showCreateChallengeDialog(
      context: context,
      questionNumber: _session!.questionsAnswered + _currentPageIndex + 1,
    );

    if (result == null || !mounted) return;

    final authCubit = context.read<AuthCubit>();
    final user = authCubit.state.user;

    if (user.id == 0) {
      _showMessage('Debes iniciar sesión para impugnar una pregunta.');
      return;
    }

    try {
      final challengeCubit = context.read<ChallengeCubit>();
      final success = await challengeCubit.createChallenge(
        questionId: questionId,
        topicId: -3,
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
    if (_currentQuestion == null) return;

    context.push(
      AppRoutes.aiChat,
      extra: {
        'questionId': _currentQuestion!.id,
        'selectedOptionId': _currentSelectedOption,
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
      final options = _currentOptions ?? [];
      final screenshotController = ScreenshotController();

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

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/question_${question.id}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Pregunta OPN - Modo Contra Reloj',
      );

      _showMessage('Imagen compartida correctamente.');
    } catch (e) {
      _showMessage('Error al compartir la pregunta.');
    }
  }

  void _handlePrevious() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNext() {
    if (_currentPageIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handleFinish() async {
    if (_session == null) return;

    if (_testFinished) {
      final action = await showTimeUpDialog(
        context: context,
        session: _session!,
      );

      if (!mounted) return;

      if (action == null) {
        return;
      }

      switch (action) {
        case TimeUpAction.playAgain:
          setState(() {
            _questions.clear();
            _questionOptions.clear();
            _selectedOptions.clear();
            _questionStartTimes.clear();
            _currentPageIndex = 0;
            _testFinished = false;
          });
          await _startNewSession();
          break;

        case TimeUpAction.viewHistory:
          if (mounted) {
            context.read<HistoryCubit>().fetchHistory(refresh: true);
            context.read<HistoryCubit>().fetchRecentTests();
            context.go(AppRoutes.history);
          }
          break;

        case TimeUpAction.exit:
          if (mounted) {
            context.read<HistoryCubit>().fetchHistory(refresh: true);
            context.read<HistoryCubit>().fetchRecentTests();
            context.pop();
          }
          break;
      }
      return;
    }

    final action = await showFinishTimeAttackOptionsSheet(
      context: context,
      hasStarted: _session!.questionsAnswered > 0,
      questionsAnswered: _session!.questionsAnswered,
    );

    if (action == null || !mounted) return;

    switch (action) {
      case FinishTimeAttackAction.continueSession:
        break;

      case FinishTimeAttackAction.exit:
        if (mounted) {
          context.pop();
        }
        break;

      case FinishTimeAttackAction.finalize:
        _countdownTimer?.cancel();
        setState(() {
          _timeRemainingSeconds = 0;
        });
        await _onTimeUp();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modo Contra Reloj')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_loading || _session == null || _questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modo Contra Reloj')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          TimeAttackStatsBar(
            session: _session!,
            timeRemainingSeconds: _timeRemainingSeconds,
            onBack: _handleFinish,
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _questions.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final question = _questions[index];
                final options = _questionOptions[question.id] ?? [];
                final selectedOption = _selectedOptions[question.id];

                return QuestionDisplay(
                  question: question,
                  options: options,
                  selectedOptionId: selectedOption,
                  onSelect: _testFinished
                      ? (_) {}
                      : _submitting
                          ? (_) {}
                          : (optionId) => _handleSelectOption(optionId),
                  showTip: _testFinished,
                  testFinished: _testFinished,
                  showRetro: _testFinished,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavigationControls(
            controller: _pageController,
            questions: _questions,
            currentIndex: _currentPageIndex,
            onFinish: _handleFinish,
            isFinishing: _submitting,
            testFinished: _testFinished,
            topicType: null,
          ),
          QuestionActionsBar(
            isFavorite: _currentQuestion != null ? _isQuestionFavorite(_currentQuestion!) : false,
            onReport: () {
              if (_currentQuestion != null) {
                _handleImpugnation(_currentQuestion!);
              }
            },
            onToggleFavorite: () {
              if (_currentQuestion != null) {
                _toggleFavorite(_currentQuestion!);
              }
            },
            onChatWithAi: _handleChatWithAi,
            onShare: () {
              if (_currentQuestion != null) {
                _shareQuestion(_currentQuestion!);
              }
            },
            isChatWithAiDisabled: true,
          ),
        ],
      ),
    );
  }
}

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
      width: 400,
      padding: const EdgeInsets.all(24),
      color: colors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OPN - Modo Contra Reloj',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${String.fromCharCode(65 + option.optionOrder)}. ',
                    style: textTheme.bodyMedium,
                  ),
                  Expanded(
                    child: Text(
                      option.answer,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
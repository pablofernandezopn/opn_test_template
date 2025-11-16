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
import '../model/survival_session.dart';
import '../repository/survival_repository.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/level_up_overlay.dart';
import '../widgets/survival_stats_bar.dart';
import '../widgets/finish_options_sheet.dart';
import '../../../../bootstrap.dart';


class SurvivalTestPage extends StatefulWidget {
  final int? topicTypeId;
  final int? specialtyId;
  final int? resumeSessionId;
  final bool reviewMode;

  const SurvivalTestPage({
    super.key,
    this.topicTypeId,
    this.specialtyId,
    this.resumeSessionId,
    this.reviewMode = false,
  });

  @override
  State<SurvivalTestPage> createState() => _SurvivalTestPageState();
}

class _SurvivalTestPageState extends State<SurvivalTestPage> {
  final _repository = getIt<SurvivalRepository>();
  final _historyRepository = getIt<HistoryRepository>();

  SurvivalSession? _session;

  // PageView para navegación
  late PageController _pageController;

  // Buffer de preguntas (siempre mantenemos 2 preguntas cargadas)
  List<Question> _questions = [];
  Map<int, List<QuestionOption>> _questionOptions = {};
  Map<int, int?> _selectedOptions = {}; // questionId -> selectedOptionId
  Map<int, DateTime> _questionStartTimes = {}; // questionId -> startTime

  // Cache del orden de opciones shuffleadas para preservar durante el test
  final Map<int, List<QuestionOption>> _optionsCache = {};

  int _currentPageIndex = 0;
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  int _previousLevel = 1;
  bool _testFinished = false;

  // Estadísticas adicionales para el historial
  int _currentStreak = 0;
  int _longestStreak = 0;

  // Helper getters
  Question? get _currentQuestion =>
      _questions.isNotEmpty && _currentPageIndex < _questions.length
          ? _questions[_currentPageIndex]
          : null;

  List<QuestionOption>? get _currentOptions =>
      _currentQuestion != null
          ? _questionOptions[_currentQuestion!.id]
          : null;

  int? get _currentSelectedOption =>
      _currentQuestion != null
          ? _selectedOptions[_currentQuestion!.id]
          : null;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeSession();
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Guardar progreso automáticamente al salir (si no ha terminado)
    if (_session != null && _session!.isActive && _session!.questionsAnswered > 0) {
      _saveProgressToHistory(finalized: false);
    }
    super.dispose();
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

      // Convertir los datos a preguntas y opciones
      for (final answerData in answersMap.values) {
        final question = Question(
          id: answerData.questionId,
          question: answerData.questionText,
          topic: -2, // -2 indica modo supervivencia
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
        _previousLevel = session.currentLevel;
        _currentStreak = 0;
        _longestStreak = 0;
        _currentPageIndex = _questions.length - 1; // Ir a la última pregunta respondida
      });

      // Cargar 2 nuevas preguntas para continuar
      await _loadNextQuestions(count: 2);
    } catch (e) {
      _setError('Error al reanudar sesión: $e');
    }
  }

  /// Carga una sesión finalizada para revisión
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

      // Cargar TODAS las preguntas respondidas de la sesión
      final answersMap = await _repository.getSessionAnswers(sessionId: sessionId);

      if (!mounted) return;

      // Convertir los datos a preguntas y opciones
      for (final answerData in answersMap.values) {
        final question = Question(
          id: answerData.questionId,
          question: answerData.questionText,
          topic: -2, // -2 indica modo supervivencia
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

      // Activar modo revisión inmediatamente
      setState(() {
        _session = session;
        _previousLevel = session.currentLevel;
        _currentStreak = 0;
        _longestStreak = 0;
        _testFinished = true; // ← Modo revisión activado desde el inicio
        _currentPageIndex = 0; // Empezar desde la primera pregunta
        _loading = false;
      });
    } catch (e) {
      _setError('Error al cargar revisión: $e');
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
        _setError('Debes iniciar sesión para jugar modo supervivencia');
        return;
      }

      final session = await _repository.startSession(
        userId: user.id,
        academyId: user.academyId ?? 1,
        topicTypeId: widget.topicTypeId,
        specialtyId: widget.specialtyId,
      );

      if (!mounted) return;

      setState(() {
        _session = session;
        _previousLevel = session.currentLevel;
        _currentStreak = 0;
        _longestStreak = 0;
      });

      // Cargar primeras 2 preguntas
      await _loadNextQuestions(count: 2);
    } catch (e) {
      _setError('Error al iniciar sesión: $e');
    }
  }

  /// Carga preguntas al buffer
  Future<void> _loadNextQuestions({int count = 1}) async {
    if (_session == null) return;

    try {
      for (int i = 0; i < count; i++) {
        final response = await _repository.getNextQuestion(
          sessionId: _session!.id!,
        );

        if (!mounted) return;

        _session = response.session;

        // Verificar game over
        if (response.gameOver || !response.hasQuestion) {
          if (_questions.isEmpty) {
            await _handleGameOver();
            return;
          } else {
            // Ya no hay más preguntas, pero tenemos algunas en el buffer
            break;
          }
        }

        // Verificar si subió de nivel
        if (_session!.currentLevel > _previousLevel) {
          _showLevelUpAnimation();
          _previousLevel = _session!.currentLevel;
        }

        // Agregar pregunta al buffer con shuffle
        final question = response.question!;
        final rawOptions = response.options!;

        // Aplicar shuffle si la pregunta lo requiere
        final orderedOptions = sortOrShuffleOptions(
          rawOptions,
          shouldShuffle: question.shuffled,
          isFlashcardMode: false,
        );

        _questions.add(question);
        _questionOptions[question.id!] = orderedOptions;
        _optionsCache[question.id!] = orderedOptions; // Cachear orden shuffleado
        _questionStartTimes[question.id!] = DateTime.now();
      }

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      _setError('Error al cargar preguntas: $e');
    }
  }

  void _onPageChanged(int newIndex) {
    setState(() => _currentPageIndex = newIndex);

    // Solo cargar más preguntas si NO estamos en modo revisión
    if (!_testFinished && newIndex == _questions.length - 1) {
      _loadNextQuestions(count: 1);
    }
  }

  Future<void> _handleSelectOption(int optionId) async {
    if (_currentQuestion == null || _submitting || _testFinished) return;

    final questionId = _currentQuestion!.id!;

    // Guardar selección
    setState(() {
      _selectedOptions[questionId] = optionId;
    });

    // Auto-submit
    await _submitAnswer();
  }

  Future<void> _submitAnswer() async {
    if (_session == null ||
        _currentQuestion == null ||
        _currentSelectedOption == null ||
        _submitting) {
      return;
    }

    try {
      setState(() => _submitting = true);

      final questionId = _currentQuestion!.id!;
      final selectedOptionId = _currentSelectedOption!;

      // Calcular tiempo tomado
      final startTime = _questionStartTimes[questionId];
      final timeTaken = startTime != null
          ? DateTime.now().difference(startTime).inSeconds
          : null;

      // Verificar si la respuesta es correcta
      final selectedOption = _currentOptions!.firstWhere(
        (opt) => opt.id == selectedOptionId,
      );
      final wasCorrect = selectedOption.isCorrect;

      // Actualizar racha (streak)
      if (wasCorrect) {
        _currentStreak++;
        if (_currentStreak > _longestStreak) {
          _longestStreak = _currentStreak;
        }
      } else {
        _currentStreak = 0;
      }

      // Enviar respuesta
      final response = await _repository.submitAnswer(
        sessionId: _session!.id!,
        questionId: questionId,
        selectedOptionId: selectedOptionId,
        wasCorrect: wasCorrect,
        timeTakenSeconds: timeTaken,
      );

      if (!mounted) return;

      // Actualizar sesión
      setState(() {
        _session = response.session;
        _submitting = false;
      });

      // Verificar game over ANTES del feedback
      if (response.gameOver || (_session!.livesRemaining <= 0)) {
        // Mostrar feedback visual antes de game over
        await Future.delayed(
          Duration(milliseconds: wasCorrect ? 800 : 1500),
        );
        await _handleGameOver();
        return;
      }

      // Mostrar feedback visual
      await Future.delayed(
        Duration(milliseconds: wasCorrect ? 800 : 1500),
      );

      // Avanzar a la siguiente pregunta automáticamente
      if (_currentPageIndex < _questions.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      } else {
        // No hay más preguntas en el buffer, cargar más
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

  Future<void> _handleGameOver() async {
    if (_session == null) return;

    await _saveProgressToHistory(finalized: true);

    if (!mounted) return;

    // Activar modo revisión INMEDIATAMENTE
    setState(() {
      _testFinished = true;
    });

    // Mostrar game over dialog (informativo)
    final action = await showGameOverDialog(
      context: context,
      session: _session!,
      longestStreak: _longestStreak,
    );

    if (!mounted) return;

    // Si cierra el dialog (null), no hacer nada (ya está en revisión)
    if (action == null) {
      return;
    }

    switch (action) {
      case GameOverAction.playAgain:
        // Resetear todo y empezar de nuevo
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

      case GameOverAction.viewHistory:
        if (mounted) {
          // Refrescar el historial antes de navegar
          context.read<HistoryCubit>().fetchHistory(refresh: true);
          context.read<HistoryCubit>().fetchRecentTests();
          context.go(AppRoutes.history);
        }
        break;

      case GameOverAction.exit:
        if (mounted) {
          // Refrescar el historial antes de salir
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
          ? '🔥 Supervivencia - Nivel ${_session!.currentLevel} • '
              '${_session!.questionsAnswered} preguntas • '
              'Racha: $_longestStreak • '
              '${_session!.accuracy.toStringAsFixed(0)}% precisión'
          : '⏸️ Supervivencia EN PROGRESO - Nivel ${_session!.currentLevel} • '
              '${_session!.questionsAnswered} preguntas';

      final userTest = UserTest(
        userId: user.id,
        topicIds: [],
        options: 4,
        rightQuestions: _session!.questionsCorrect,
        wrongQuestions: _session!.questionsIncorrect,
        questionCount: _session!.questionsAnswered,
        totalAnswered: _session!.questionsAnswered,
        score: finalized ? (_session!.finalScore ?? 0) : null,
        finalized: finalized,
        visible: true,
        durationSeconds: 0,
        timeSpentMillis: _session!.endedAt != null && _session!.startedAt != null
            ? _session!.endedAt!.difference(_session!.startedAt!).inMilliseconds
            : DateTime.now().difference(_session!.startedAt!).inMilliseconds,
        totalTimeSeconds: 0,
        specialTopic: -2,
        specialTopicTitle: specialTitle,
        survivalSessionId: _session!.id,
        createdAt: _session!.startedAt,
        updatedAt: finalized ? _session!.endedAt : DateTime.now(),
        isFlashcardMode: false,
      );

      // Crear el user_test y obtener su ID
      final createdTest = await _historyRepository.createUserTest(userTest);
      final userTestId = createdTest.id!;

      // Crear mapa de shuffled option IDs
      final shuffledIds = <int, List<int>?>{};
      for (final entry in _optionsCache.entries) {
        shuffledIds[entry.key] = extractOptionIds(entry.value);
      }

      // Guardar todas las respuestas en user_test_answers
      await _historyRepository.createUserTestAnswers(
        userTestId,
        _selectedOptions,
        _questionOptions,
        shuffledOptionIds: shuffledIds,
      );
    } catch (e) {
      print('❌ Error guardando en historial: $e');
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

  // ============================================================
  // 🎯 MÉTODOS COMPARTIDOS
  // ============================================================

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
        topicId: -2, // -2 indica modo supervivencia (sin topic específico)
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
        text: 'Pregunta OPN - Modo Supervivencia',
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

    // Si estamos en modo revisión (después de game over), mostrar el dialog de nuevo
    if (_testFinished) {
      final action = await showGameOverDialog(
        context: context,
        session: _session!,
        longestStreak: _longestStreak,
      );

      if (!mounted) return;

      // Si cierra el dialog (null), no hacer nada (sigue revisando)
      if (action == null) {
        return;
      }

      switch (action) {
        case GameOverAction.playAgain:
          // Resetear todo y empezar de nuevo
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

        case GameOverAction.viewHistory:
          if (mounted) {
            context.go(AppRoutes.history);
          }
          break;

        case GameOverAction.exit:
          if (mounted) {
            context.pop();
          }
          break;
      }
      return;
    }

    // Si no estamos en modo revisión, mostrar las opciones normales
    final action = await showFinishSurvivalSheet(
      context: context,
      session: _session!,
    );

    if (!mounted || action == null) return;

    switch (action) {
      case FinishSurvivalAction.continuePlay:
        // No hacer nada, simplemente cerrar el diálogo
        // El usuario sigue jugando
        break;

      case FinishSurvivalAction.continueLater:
        // Guardar progreso con finalized=false
        await _saveProgressToHistory(finalized: false);
        if (mounted) {
          // Refrescar el historial antes de salir
          context.read<HistoryCubit>().fetchHistory(refresh: true);
          context.read<HistoryCubit>().fetchRecentTests();
          _showMessage('Progreso guardado. Puedes continuar desde el historial.');
          context.pop();
        }
        break;

      case FinishSurvivalAction.finalize:
        // Actualizar la sesión para marcar como finalizada (0 vidas)
        if (_session != null) {
          setState(() {
            _session = _session!.copyWith(
              livesRemaining: 0,
              endedAt: DateTime.now(),
              isActive: false,
            );
          });
        }

        // Finalizar la partida y mostrar game over
        await _handleGameOver();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modo Supervivencia')),
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
        appBar: AppBar(title: const Text('Modo Supervivencia')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          SurvivalStatsBar(
            session: _session!,
            onBack: _handleFinish,
          ),

          // PageView con preguntas
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _questions.length,
              physics: const NeverScrollableScrollPhysics(), // Desactivar swipe
              itemBuilder: (context, index) {
                final question = _questions[index];
                final options = _questionOptions[question.id] ?? [];
                final selectedOption = _selectedOptions[question.id];

                return QuestionDisplay(
                  question: question,
                  options: options,
                  selectedOptionId: selectedOption,
                  onSelect: _testFinished
                      ? (_) {} // No permitir seleccionar en modo revisión
                      : _submitting
                          ? (_) {}
                          : (optionId) => _handleSelectOption(optionId),
                  showTip: _testFinished, // Mostrar consejos en modo revisión
                  testFinished: _testFinished, // Activar colores de corrección
                  showRetro: _testFinished, // Mostrar retroalimentación
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // NavigationControls (como TopicTestPage)
          NavigationControls(
            controller: _pageController,
            questions: _questions,
            currentIndex: _currentPageIndex,
            onFinish: _handleFinish,
            isFinishing: _submitting,
            testFinished: _testFinished, // Pasar estado de revisión
            topicType: null, // No hay topicType en modo supervivencia
          ),

          // QuestionActionsBar
          QuestionActionsBar(
            isFavorite: _currentQuestion != null
                ? _isQuestionFavorite(_currentQuestion!)
                : false,
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
            // Deshabilitar IA solo durante el juego activo, permitirla cuando el juego termina
            isChatWithAiDisabled: !_testFinished,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'OPN Test - Supervivencia',
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            question.question,
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ...options.map((option) {
            final letter = String.fromCharCode(65 + option.optionOrder - 1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outlineVariant, width: 1),
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
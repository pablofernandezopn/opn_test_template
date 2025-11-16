import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_template/app/features/test_config/model/test_mode.dart';
import '../../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../../config/go_route/app_routes.dart';
import '../../../../config/service_locator.dart';
import '../../../questions/cubit/cubit.dart';
import '../../../questions/model/question_model.dart';
import '../../../questions/repository/repository.dart';
import '../../../questions/view/topic_test_page.dart';
import '../../../topics/model/topic_model.dart';
import '../../../topics/model/topic_type_model.dart';
import '../../../topics/cubit/topic_cubit.dart';
import '../../cubit/test_config_cubit.dart';
import '../../cubit/test_config_state.dart';
import '../../model/answer_display_mode.dart';
import '../../model/test_config.dart';
import '../../model/test_difficulty.dart';
import '../../repository/test_repository.dart';
import 'select_box.dart';
import 'topic_selector.dart';
import 'test_mode_selector.dart';

/// Modo principal del test
enum TestMainMode { games, study }

/// Modo de juego
enum GameMode { survival, timeAttack }

/// Formulario principal de configuración del test (simplificado y minimalista)
class TestConfigForm extends StatefulWidget {
  const TestConfigForm({
    super.key,
    required this.studyTopicTypes,
    required this.selectedTopicType,
    required this.onTopicTypeChanged,
  });

  final List<TopicType> studyTopicTypes;
  final TopicType? selectedTopicType;
  final ValueChanged<TopicType> onTopicTypeChanged;

  @override
  State<TestConfigForm> createState() => _TestConfigFormState();
}

class _TestConfigFormState extends State<TestConfigForm> {
  TestMainMode _mainMode = TestMainMode.study;
  GameMode? _selectedGameMode;

  @override
  void initState() {
    super.initState();
    // Sincronizar el estado local con el estado del cubit al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cubit = context.read<TestConfigCubit>();
        final isGameMode = cubit.state.isGameMode;
        if (isGameMode && _mainMode != TestMainMode.games) {
          setState(() {
            _mainMode = TestMainMode.games;
          });
          print('✅ [TEST_CONFIG_FORM] Sincronizado al modo juego desde el estado del cubit');
        } else if (!isGameMode && _mainMode != TestMainMode.study) {
          setState(() {
            _mainMode = TestMainMode.study;
          });
          print('✅ [TEST_CONFIG_FORM] Sincronizado al modo estudio desde el estado del cubit');
        }
      }
    });
  }

  /// Inicia un test generado con la edge function
  Future<void> _startGeneratedTest(BuildContext context, TestConfig config, bool isFreemium) async {
    try {
      final authCubit = context.read<AuthCubit>();
      final userId = authCubit.state.user.id;
      final academyId = authCubit.state.user.academyId;
      final testRepository = getIt<TestRepository>();
      final questionRepository = getIt<QuestionRepository>();

      // Decidir qué edge function usar según los modos
      final List<Question> questions;
      if (config.testModes.length > 1 || config.hasReviewMode) {
        // Obtener todos los topic IDs del topic_type seleccionado
        // para filtrar las preguntas falladas/en blanco
        final testConfigCubit = context.read<TestConfigCubit>();
        final availableTopicIds = testConfigCubit.state.availableTopics
            .where((topic) => topic.id != null)
            .map((topic) => topic.id!)
            .toList();

        // Usar edge function de modo mixto
        questions = await testRepository.generateMixedModeTest(
          config,
          userId: userId.toString(),
          academyId: academyId,
          availableTopicIds: availableTopicIds,
        );
      } else {
        // Usar edge function tradicional (solo topics)
        questions = await testRepository.generateTestWithEdgeFunction(
          config,
          academyId: academyId,
        );
      }

      if (!context.mounted) return;

      // Validar que haya preguntas disponibles
      if (questions.isEmpty) {
        _showNoQuestionsDialog(context, config);
        return;
      }

      // Obtener opciones
      final questionIds = questions.where((q) => q.id != null).map((q) => q.id!).toList().cast<int>();
      final options = await questionRepository.fetchOptionsForQuestions(questionIds);

      if (!context.mounted) return;

      // Crear Topic virtual para el test generado
      final virtualTopic = Topic(
        id: -1, // ID especial para test generado
        topicTypeId: -1,
        topicName: 'Test de Estudio',
        description: 'Test generado con ${config.selectedTopicIds.length} tema(s)',
        enabled: true,
        isPremium: false,
        totalQuestions: questions.length,
        durationSeconds: ((questions.length / 2) * 60).toInt(), // mitad del número de preguntas en segundos
        options: 4,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        academyId: academyId ?? 1,
      );

      // Crear QuestionCubit y pre-cargar preguntas con el modo de respuesta
      final questionCubit = QuestionCubit(questionRepository, authCubit);
      questionCubit.loadQuestionsDirectly(
        -1,
        questions,
        options,
        answerDisplayMode: config.answerDisplayMode,
      );

      // Navegar a TopicTestPage
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: questionCubit,
            child: TopicTestPage(topic: virtualTopic),
          ),
        ),
      );
    } catch (e) {
      print('❌ Error generating test: $e');
      if (context.mounted) {
        _handleTestGenerationError(context, e, config);
      }
    }
  }

  /// Inicia el modo supervivencia (muestra preview primero)
  void _startSurvivalMode(BuildContext context) {
    final cubit = context.read<TestConfigCubit>();
    final config = cubit.state.config;

    print('🎮 [TEST_CONFIG_FORM] Iniciando modo supervivencia (preview)');
    print('   - TopicTypeId: ${config.topicTypeId}');

    // Navegar al preview del modo supervivencia
    context.pushNamed(
      AppRoutes.survivalPreview,
      extra: <String, dynamic>{
        'topicTypeId': config.topicTypeId,
        // Specialty se puede agregar en el futuro si es necesario
      },
    );
  }

  void _startTimeAttackMode(BuildContext context) {
    final cubit = context.read<TestConfigCubit>();
    final config = cubit.state.config;

    print('⏱️ [TEST_CONFIG_FORM] Iniciando modo contra reloj');
    print('   - TopicTypeId: ${config.topicTypeId}');

    // Navegar al modo contra reloj
    context.pushNamed(
      AppRoutes.timeAttackPreview,
      extra: <String, dynamic>{
        'topicTypeId': config.topicTypeId,
        // Specialty se puede agregar en el futuro si es necesario
      },
    );
  }

  void _showNoQuestionsDialog(BuildContext context, TestConfig config) {
    final colors = Theme.of(context).colorScheme;

    // Construir mensaje detallado
    String message = 'No hay preguntas disponibles con los criterios seleccionados:\n\n';

    // Dificultades
    if (config.difficulties.isEmpty) {
      message += '• Dificultad: Todas\n';
    } else {
      final diffNames = config.difficulties.map((d) => d.displayName).join(', ');
      message += '• Dificultad: $diffNames\n';
    }

    // Número de preguntas
    message += '• Preguntas solicitadas: ${config.numQuestions}\n';
    message += '• Temas seleccionados: ${config.selectedTopicIds.length}\n\n';
    message += 'Intenta cambiar los filtros o seleccionar más temas.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.info_outline,
          size: 48,
          color: colors.primary,
        ),
        title: const Text('Sin preguntas disponibles'),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showPremiumModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Función Premium'),
        content: const Text(
          'Esta opción está disponible solo para usuarios Premium. '
          'Actualiza tu suscripción para acceder a todas las funciones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navegar a página de suscripciones
            },
            child: const Text('Ver Planes'),
          ),
        ],
      ),
    );
  }

  /// Maneja los errores de generación de test con mensajes amigables
  void _handleTestGenerationError(BuildContext context, dynamic error, TestConfig config) {
    final errorString = error.toString();
    final colors = Theme.of(context).colorScheme;

    // Detectar si el error es por falta de preguntas de modos específicos
    if (errorString.contains('Failed to fetch questions') ||
        errorString.contains('No questions available') ||
        errorString.contains('does not exist')) {

      // Construir mensaje detallado basado en los modos seleccionados
      String title = 'No hay preguntas disponibles';
      String message = _buildNoQuestionsMessage(config);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(
            Icons.info_outline,
            size: 48,
            color: colors.primary,
          ),
          title: Text(title),
          content: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } else {
      // Para otros errores, mostrar un snackbar genérico
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al generar el test. Por favor, intenta de nuevo.'),
          backgroundColor: colors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Construye un mensaje personalizado basado en los modos seleccionados
  String _buildNoQuestionsMessage(TestConfig config) {
    final buffer = StringBuffer();
    buffer.writeln('No se encontraron suficientes preguntas con los criterios seleccionados:\n');

    // Modos seleccionados
    if (config.testModes.isNotEmpty) {
      buffer.writeln('• Modos de test:');
      for (final mode in config.testModes) {
        String modeName = mode.displayName;
        if (mode.value == 'failed') {
          modeName = 'Preguntas falladas';
        } else if (mode.value == 'skipped') {
          modeName = 'Preguntas en blanco';
        }
        buffer.writeln('  - $modeName');
      }
      buffer.writeln();
    }

    // Dificultades
    if (config.difficulties.isNotEmpty) {
      final diffNames = config.difficulties.map((d) => d.displayName).join(', ');
      buffer.writeln('• Dificultad: $diffNames');
    }

    // Número de preguntas
    buffer.writeln('• Preguntas solicitadas: ${config.numQuestions}');

    // Temas seleccionados
    if (config.selectedTopicIds.isNotEmpty) {
      buffer.writeln('• Temas seleccionados: ${config.selectedTopicIds.length}');
    }

    buffer.writeln();

    // Sugerencias específicas según los modos
    if (config.hasReviewMode) {
      buffer.writeln('💡 Sugerencias:');
      if (config.testModes.any((m) => m.value == 'failed')) {
        buffer.writeln('• Aún no has fallado suficientes preguntas en estos temas');
      }
      if (config.testModes.any((m) => m.value == 'skipped')) {
        buffer.writeln('• Aún no has dejado en blanco suficientes preguntas en estos temas');
      }
      buffer.writeln('• Prueba reducir el número de preguntas');
      buffer.writeln('• O selecciona más temas para ampliar el banco de preguntas');
    } else {
      buffer.writeln('💡 Intenta cambiar los filtros o seleccionar más temas.');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TestConfigCubit, TestConfigState>(
      builder: (context, state) {
        final cubit = context.read<TestConfigCubit>();
        final user = context.watch<AuthCubit>().state.user;
        final isFreemium = user.isFreemium;

        // Sincronizar el estado local con el del cubit (bidireccional)
        final expectedMode = state.isGameMode ? TestMainMode.games : TestMainMode.study;
        if (_mainMode != expectedMode) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _mainMode = expectedMode;
              });
              print('✅ [TEST_CONFIG_FORM] Sincronizado al modo ${state.isGameMode ? "juego" : "estudio"} desde el estado del cubit');
            }
          });
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // FUENTE DE PREGUNTAS (SIEMPRE PRIMERO)
                  _buildSectionHeader(
                    context,
                    'Fuente de preguntas',
                    subtitle: 'Selecciona de dónde sacaremos las preguntas',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.studyTopicTypes.map((topicType) {
                      final isSelected = widget.selectedTopicType?.id == topicType.id;
                      final colorScheme = Theme.of(context).colorScheme;

                      return InkWell(
                        onTap: () => widget.onTopicTypeChanged(topicType),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            topicType.topicTypeName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (widget.selectedTopicType != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.selectedTopicType!.description ??
                                  'Las preguntas de tu test se tomarán de esta fuente de contenido.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),

                  // MODO PRINCIPAL: JUEGOS O ESTUDIO
                  _buildSectionHeader(
                    context,
                    'Modo de Test',
                    subtitle: 'Elige si quieres jugar o estudiar',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SelectBox(
                          title: 'Juegos',
                          subtitle: 'Modos de juego',
                          selected: _mainMode == TestMainMode.games,
                          onSelect: () {
                            setState(() {
                              _mainMode = TestMainMode.games;
                            });
                            // Notificar al cubit que estamos en modo juego
                            cubit.setGameMode(true);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SelectBox(
                          title: 'Estudio',
                          subtitle: 'Modo de estudio',
                          selected: _mainMode == TestMainMode.study,
                          onSelect: () {
                            setState(() {
                              _mainMode = TestMainMode.study;
                            });
                            // Notificar al cubit que estamos en modo estudio
                            cubit.setGameMode(false);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // OPCIONES SEGÚN MODO SELECCIONADO
                  if (_mainMode == TestMainMode.games) ...[
                    // MODO JUEGOS
                    _buildSectionHeader(
                      context,
                      'Selecciona un modo de juego',
                      subtitle: 'Solo puedes elegir uno',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: BlocBuilder<TestConfigCubit, TestConfigState>(
                            builder: (context, state) {
                              return SelectBox(
                                title: 'Supervivencia',
                                subtitle: 'Hasta que falles',
                                selected: _selectedGameMode == GameMode.survival,
                                onSelect: () {
                                  setState(() {
                                    _selectedGameMode = GameMode.survival;
                                  });
                                  // Activar modo survival en el cubit
                                  context.read<TestConfigCubit>().setTestMode(TestMode.survival);
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BlocBuilder<TestConfigCubit, TestConfigState>(
                            builder: (context, state) {
                              return SelectBox(
                                title: 'A contrarreloj',
                                subtitle: 'Contra el tiempo',
                                selected: _selectedGameMode == GameMode.timeAttack,
                                onSelect: () {
                                  setState(() {
                                    _selectedGameMode = GameMode.timeAttack;
                                  });
                                  // Activar modo time attack en el cubit
                                  context.read<TestConfigCubit>().setTestMode(TestMode.timeAttack);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],

                  if (_mainMode == TestMainMode.study) ...[
                    // MODO ESTUDIO

                    // NÚMERO DE PREGUNTAS
                    _buildSectionHeader(context, 'Nº de preguntas'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SelectBox(
                            title: '10 preguntas',
                            subtitle: '~10 min',
                            selected: state.config.numQuestions == 10,
                            onSelect: () => cubit.updateNumQuestions(10),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SelectBox(
                            title: '20 preguntas',
                            subtitle: '~20 min',
                            selected: state.config.numQuestions == 20,
                            lock: isFreemium,
                            onSelect: () => cubit.updateNumQuestions(20),
                            onLock: () => _showPremiumModal(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SelectBox(
                            title: '50 preguntas',
                            subtitle: '~50 min',
                            selected: state.config.numQuestions == 50,
                            lock: isFreemium,
                            onSelect: () => cubit.updateNumQuestions(50),
                            onLock: () => _showPremiumModal(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SelectBox(
                            title: '100 preguntas',
                            subtitle: '~100 min',
                            selected: state.config.numQuestions == 100,
                            lock: isFreemium,
                            onSelect: () => cubit.updateNumQuestions(100),
                            onLock: () => _showPremiumModal(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // DIFICULTAD (selección múltiple)
                    _buildSectionHeader(
                      context,
                      'Dificultad',
                      subtitle: state.config.difficulties.isEmpty
                          ? 'Todas seleccionadas'
                          : '${state.config.difficulties.length} seleccionada(s)',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SelectBox(
                            title: 'Fácil',
                            selected: state.config.difficulties.contains(TestDifficulty.easy),
                            lock: isFreemium,
                            onSelect: () => cubit.toggleDifficulty(TestDifficulty.easy),
                            onLock: () => _showPremiumModal(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SelectBox(
                            title: 'Normal',
                            selected: state.config.difficulties.contains(TestDifficulty.normal),
                            onSelect: () => cubit.toggleDifficulty(TestDifficulty.normal),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SelectBox(
                            title: 'Difícil',
                            selected: state.config.difficulties.contains(TestDifficulty.hard),
                            lock: isFreemium,
                            onSelect: () => cubit.toggleDifficulty(TestDifficulty.hard),
                            onLock: () => _showPremiumModal(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // MODO DE RESPUESTA
                    _buildSectionHeader(context, 'Mostrar respuestas'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SelectBox(
                            title: 'Al finalizar',
                            subtitle: 'Ver todas al final',
                            selected: state.config.answerDisplayMode == AnswerDisplayMode.atEnd,
                            onSelect: () => cubit.updateAnswerDisplayMode(AnswerDisplayMode.atEnd),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SelectBox(
                            title: 'Inmediato',
                            subtitle: 'Una por una',
                            selected: state.config.answerDisplayMode == AnswerDisplayMode.immediate,
                            lock: isFreemium,
                            onSelect: () => cubit.updateAnswerDisplayMode(AnswerDisplayMode.immediate),
                            onLock: () => _showPremiumModal(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // SELECTOR DE MODOS DE TEST (solo para usuarios premium)
                    if (!isFreemium) ...[
                      TestModeSelector(
                        selectedModes: state.config.testModes,
                        onModeToggled: (mode) => cubit.toggleTestMode(mode),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // SELECTOR DE TEMAS (siempre visible para usuarios premium)
                    if (!isFreemium) ...[
                      _buildSectionHeader(
                        context,
                        'Temas',
                        subtitle: state.config.hasTopicsMode
                            ? '${state.config.selectedTopicIds.length} tema(s) seleccionado(s)'
                            : '${state.config.selectedTopicIds.length} tema(s) seleccionado(s) (opcional para filtrar)',
                      ),
                      const SizedBox(height: 12),
                      Builder(
                        builder: (context) {
                          final topicCubit = context.watch<TopicCubit>();
                          final filteredCategories = topicCubit.getCategoriesBySelectedTopicType();

                          return TopicSelector(
                            availableTopics: state.availableTopics,
                            selectedTopicIds: state.config.selectedTopicIds,
                            onTopicToggled: (topicId) {
                              cubit.toggleTopicSelection(topicId);
                            },
                            onSelectMultipleTopics: (topicIds) {
                              cubit.selectTopics(topicIds);
                            },
                            categories: filteredCategories,
                          );
                        },
                      ),
                    ],

                    // Mensaje para usuarios freemium
                    if (isFreemium)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Los usuarios freemium incluyen todos los temas disponibles',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
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

            // BOTÓN INICIAR TEST
            _buildStartTestButton(context, state, isFreemium),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildStartTestButton(
    BuildContext context,
    TestConfigState state,
    bool isFreemium,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // Para freemium, validar que haya al menos un tema disponible
    final bool isValid = isFreemium
        ? state.availableTopics.isNotEmpty
        : state.isConfigValid;

    final String? errorMessage = isFreemium
        ? (state.availableTopics.isEmpty ? 'No hay temas disponibles' : null)
        : state.config.validationError;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isValid && errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: colorScheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isValid
                  ? () {
                      final cubit = context.read<TestConfigCubit>();

                      // Si está en modo juego, verificar qué modo de juego está seleccionado
                      if (state.isGameMode) {
                        if (_selectedGameMode == GameMode.survival) {
                          _startSurvivalMode(context);
                        } else if (_selectedGameMode == GameMode.timeAttack) {
                          _startTimeAttackMode(context);
                        } else {
                          // Otros modos de juego en el futuro
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Este modo de juego aún no está disponible'),
                            ),
                          );
                        }
                      } else {
                        // Modo estudio normal
                        final config = isFreemium
                            ? cubit.getFreemiumConfig()
                            : cubit.getConfig();
                        _startGeneratedTest(context, config, isFreemium);
                      }
                    }
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: Text(
                state.isGameMode ? 'Jugar Ahora' : 'Iniciar Test',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Función auxiliar para obtener iconos según el tipo
  IconData _getIconForTopicType(String typeName) {
    final lowerName = typeName.toLowerCase();
    if (lowerName.contains('constituc')) return Icons.gavel;
    if (lowerName.contains('código')) return Icons.menu_book;
    if (lowerName.contains('ley')) return Icons.description;
    if (lowerName.contains('civil')) return Icons.account_balance;
    if (lowerName.contains('penal')) return Icons.policy;
    return Icons.book;
  }
}
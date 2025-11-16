import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/go_route/app_routes.dart';
import '../../topics/cubit/topic_cubit.dart';
import '../../topics/cubit/topic_state.dart';
import '../../topics/model/topic_level.dart';
import '../../topics/model/topic_type_model.dart';
import '../../../config/service_locator.dart';
import '../cubit/test_config_cubit.dart';
import '../cubit/test_config_state.dart';
import '../model/saved_test_config.dart';
import 'components/test_config_form.dart';
import 'components/save_config_dialog.dart';
import 'components/saved_configs_sheet.dart';

/// Página de configuración del test con selección por Study Topic Type
class TestConfigPage extends StatelessWidget {
  const TestConfigPage({super.key, this.savedConfig});

  static const String routeName = '/test-config';

  /// Configuración guardada para cargar (opcional)
  final SavedTestConfig? savedConfig;

  @override
  Widget build(BuildContext context) {
    return _TestConfigView(savedConfig: savedConfig);
  }
}

class _TestConfigView extends StatefulWidget {
  const _TestConfigView({this.savedConfig});

  final SavedTestConfig? savedConfig;

  @override
  State<_TestConfigView> createState() => _TestConfigViewState();
}

class _TestConfigViewState extends State<_TestConfigView> {
  TopicType? _selectedTopicType;
  bool _configLoaded = false;

  @override
  void initState() {
    super.initState();

    // Si hay una configuración guardada, cargarla después del primer frame
    if (widget.savedConfig != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_configLoaded) {
          print('🔄 [TEST_CONFIG_PAGE] Cargando configuración guardada: ${widget.savedConfig!.configName}');
          context.read<TestConfigCubit>().loadSavedConfig(widget.savedConfig!);
          _configLoaded = true;

          // Forzar reconstrucción de la UI
          setState(() {});
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, state) {
        // Filtrar solo Study Topic Types que tengan contenido disponible
        final studyTopicTypes = state.topicTypes
            .where((type) =>
                type.level == TopicLevel.Study &&
                type.id != null &&
                state.topics.any((t) => t.topicTypeId == type.id))
            .toList()
          ..sort((a, b) => (a.orderOfAppearance ?? 0).compareTo(b.orderOfAppearance ?? 0));

        // Seleccionar el tipo de tema:
        // 1. Si ya hay un topicTypeId en la configuración cargada, usar ese
        // 2. Si no, seleccionar el primer tipo disponible
        if (_selectedTopicType == null && studyTopicTypes.isNotEmpty) {
          final cubit = context.read<TestConfigCubit>();
          final loadedTopicTypeId = cubit.state.config.topicTypeId;
          if (loadedTopicTypeId != null) {
            // Buscar el topicType que coincide con el ID cargado
            _selectedTopicType = studyTopicTypes.firstWhere(
              (type) => type.id == loadedTopicTypeId,
              orElse: () => studyTopicTypes.first,
            );
            print('✅ [TEST_CONFIG_PAGE] TopicType seleccionado de configuración: ${_selectedTopicType?.topicTypeName} (ID: $loadedTopicTypeId)');
          } else {
            _selectedTopicType = studyTopicTypes.first;
            print('📌 [TEST_CONFIG_PAGE] Seleccionando primer topicType disponible: ${_selectedTopicType?.topicTypeName}');
          }
        }

        if (studyTopicTypes.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.home);
                  }
                },
                tooltip: 'Volver',
              ),
              title: const Text('Configurar Test'),
              centerTitle: false,
              elevation: 0,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No hay tipos de test disponibles',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contacta con el administrador para configurar los temas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Obtener los topics del tipo seleccionado
        final topicsOfSelectedType = _selectedTopicType != null
            ? (state.topics
            .where((topic) => topic.topicTypeId == _selectedTopicType!.id)
            .toList()
          ..sort((a, b) {
            // Ordenar por 'order', poniendo null al final
            if (a.order == null && b.order == null) return 0;
            if (a.order == null) return 1;
            if (b.order == null) return -1;
            return a.order!.compareTo(b.order!);
          }))
            : <dynamic>[];

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
              tooltip: 'Volver',
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Configurar Test',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_selectedTopicType != null)
                  Text(
                    _selectedTopicType!.topicTypeName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
            centerTitle: false,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            actions: [
              // Botón para ver configuraciones guardadas
              BlocBuilder<TestConfigCubit, TestConfigState>(
                builder: (context, state) {
                  final isGameMode = state.isGameMode;
                  final hasConfigs = state.savedConfigs.isNotEmpty;
                  final canShowConfigs = !isGameMode && hasConfigs;

                  String tooltip = 'Configuraciones guardadas';
                  if (isGameMode) {
                    tooltip = 'No disponible en modo juego';
                  } else if (!hasConfigs) {
                    tooltip = 'No hay configuraciones guardadas';
                  }

                  return IconButton(
                    icon: const Icon(Icons.bookmark_outline),
                    onPressed: canShowConfigs ? () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (dialogContext) => const SavedConfigsSheet(),
                      );
                    } : null,
                    tooltip: tooltip,
                  );
                },
              ),
              // Botón para guardar configuración actual
              BlocBuilder<TestConfigCubit, TestConfigState>(
                builder: (context, state) {
                  final isGameMode = state.isGameMode;
                  final isConfigValid = state.config.isValid;
                  final canSave = !isGameMode && isConfigValid;

                  String tooltip = 'Guardar configuración';
                  if (isGameMode) {
                    tooltip = 'No disponible en modo juego';
                  } else if (!isConfigValid) {
                    tooltip = state.config.validationError ?? 'Configuración inválida';
                  }

                  return IconButton(
                    icon: const Icon(Icons.save_outlined),
                    onPressed: canSave ? () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => const SaveConfigDialog(),
                      );
                    } : null,
                    tooltip: tooltip,
                  );
                },
              ),
              // Botón de ayuda
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Configuración de Test'),
                      content: const Text(
                        'Selecciona el tipo de test, los temas que quieres incluir, '
                            'y configura las opciones del examen.\n\n'
                            'Puedes guardar tus configuraciones favoritas con el botón de guardar '
                            'y acceder a ellas rápidamente con el botón de marcadores.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Entendido'),
                        ),
                      ],
                    ),
                  );
                },
                tooltip: 'Ayuda',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _selectedTopicType != null
              ? _TopicTypeConfigTab(
            topicTypeId: _selectedTopicType!.id!,
            topicTypeName: _selectedTopicType!.topicTypeName,
            availableTopics: topicsOfSelectedType,
            studyTopicTypes: studyTopicTypes,
            selectedTopicType: _selectedTopicType,
            onTopicTypeChanged: (topicType) {
              setState(() {
                _selectedTopicType = topicType;
              });
              // Actualizar el topicTypeId en el cubit para que se envíe a las edge functions
              context.read<TestConfigCubit>().setTopicTypeId(topicType.id);
            },
          )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Tab con configurador para un TopicType específico
class _TopicTypeConfigTab extends StatefulWidget {
  final int topicTypeId;
  final String topicTypeName;
  final List availableTopics;
  final List<TopicType> studyTopicTypes;
  final TopicType? selectedTopicType;
  final ValueChanged<TopicType> onTopicTypeChanged;

  const _TopicTypeConfigTab({
    required this.topicTypeId,
    required this.topicTypeName,
    required this.availableTopics,
    required this.studyTopicTypes,
    required this.selectedTopicType,
    required this.onTopicTypeChanged,
  });

  @override
  State<_TopicTypeConfigTab> createState() => _TopicTypeConfigTabState();
}

class _TopicTypeConfigTabState extends State<_TopicTypeConfigTab> {
  @override
  void initState() {
    super.initState();

    // Esperar un frame para que la configuración se haya cargado completamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('🔄 [TEST_CONFIG_TAB] Inicializando tab para ${widget.topicTypeName}');

        final cubit = context.read<TestConfigCubit>();

        // Solo cargar los topics disponibles sin seleccionarlos todos
        // El método setAvailableTopics respetará los topics ya seleccionados
        cubit.setAvailableTopics(widget.availableTopics);

        // Establecer el topicTypeId inicial
        cubit.setTopicTypeId(widget.selectedTopicType?.id);

        print('📋 [TEST_CONFIG_TAB] Topics seleccionados: ${cubit.state.config.selectedTopicIds.length}');
      }
    });
  }

  @override
  void didUpdateWidget(_TopicTypeConfigTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambiaron los topics disponibles (por cambio de topicType), actualizar el cubit
    if (widget.topicTypeId != oldWidget.topicTypeId) {
      print('🔄 [TEST_CONFIG_TAB] TopicType cambió a ${widget.topicTypeName}');

      final cubit = context.read<TestConfigCubit>();

      // Limpiar los topics seleccionados primero
      // Esto permite que setAvailableTopics seleccione todos automáticamente
      cubit.clearSelectedTopics();

      // setAvailableTopics selecciona todos automáticamente si la lista está vacía
      cubit.setAvailableTopics(widget.availableTopics);

      // Actualizar el topicTypeId
      cubit.setTopicTypeId(widget.selectedTopicType?.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.availableTopics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.quiz_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No hay temas disponibles',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Aún no se han publicado temas de ${widget.topicTypeName}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return TestConfigForm(
      studyTopicTypes: widget.studyTopicTypes,
      selectedTopicType: widget.selectedTopicType,
      onTopicTypeChanged: widget.onTopicTypeChanged,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_template/app/features/history/cubit/history_cubit.dart';
import 'package:opn_test_template/app/features/history/cubit/history_state.dart';
import 'package:opn_test_template/app/features/topics/cubit/topic_cubit.dart';
import 'package:opn_test_template/app/features/topics/cubit/topic_state.dart';
import 'package:opn_test_template/app/config/go_route/app_routes.dart';
import '../components/history_item.dart';
import '../components/grouped_history_item.dart';
import '../components/topic_type_filter.dart';
import '../../model/history_item_model.dart';

class HistoryPage extends StatefulWidget {
  static const String route = '/history';

  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Cargar el historial al inicio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryCubit>().fetchHistory(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<HistoryCubit>().loadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Historial',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, historyState) {
          return BlocBuilder<TopicCubit, TopicState>(
            builder: (context, topicState) {
              // En el historial mostramos todos los topic_types disponibles
              // (el usuario puede tener tests históricos de cualquier tipo)
              return Column(
                children: [
                  // Filtro de tipos de test
                  if (topicState.topicTypes.isNotEmpty)
                    TopicTypeFilter(
                      topicTypes: topicState.topicTypes,
                      selectedTopicTypeId: historyState.selectedTopicTypeFilter,
                      onFilterChanged: (topicTypeId) {
                        context.read<HistoryCubit>().applyTopicTypeFilter(topicTypeId);
                      },
                    ),

                  // Contenido principal
                  Expanded(
                    child: _buildContent(historyState),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(HistoryState state) {
    // Estado de carga inicial
    if (state.fetchHistoryStatus.isLoading && state.tests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Estado de error
    if (state.fetchHistoryStatus.isError && state.tests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error al cargar el historial',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error ?? 'Error desconocido',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<HistoryCubit>().fetchHistory(refresh: true);
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // Lista vacía
    if (state.tests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay tests en el historial',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Completa un test para verlo aquí',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    // Transformar tests en items del historial (agrupados + individuales)
    final historyItems = HistoryItemTransformer.transform(
      state.tests,
      topicGroupNames: {}, // TODO: Cargar nombres de grupos si es necesario
    );

    // Lista con tests agrupados e individuales
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<HistoryCubit>().fetchHistory(refresh: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: historyItems.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Indicador de carga al final
          if (index >= historyItems.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final item = historyItems[index];
          final isFirstOfDay = _isFirstItemOfDay(historyItems, index);
          final showTodayMarker = item.isToday && isFirstOfDay;

          // Renderizar según el tipo de item
          if (item is SingleHistoryItem) {
            return HistoryItem(
              test: item.test,
              isFirstOfDay: isFirstOfDay,
              showTodayMarker: showTodayMarker,
              onTap: () async {
                // Detectar si es modo supervivencia (finalized o no)
                if (item.test.specialTopic == -2 && item.test.survivalSessionId != null) {
                  final isFinalized = item.test.finalized;

                  // Navegar al modo supervivencia con el flag correcto
                  context.push(
                    AppRoutes.survivalTest,
                    extra: {
                      'resumeSessionId': item.test.survivalSessionId,
                      'reviewMode': isFinalized,  // true = revisar, false = continuar
                    },
                  );
                  return;
                }

                // Verificar si el test puede continuarse (no está finalizado)
                final canResume = !item.test.finalized;
                print('🔍 [HISTORY_PAGE] onTap - Test ID: ${item.test.id}');
                print('🔍 [HISTORY_PAGE] - finalized: ${item.test.finalized}');
                print('🔍 [HISTORY_PAGE] - totalAnswered: ${item.test.totalAnswered}');
                print('🔍 [HISTORY_PAGE] - isPaused: ${item.test.isPaused}');
                print('🔍 [HISTORY_PAGE] - canResume: $canResume');

                // Mostrar indicador de carga mientras se obtienen las preguntas
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  // Cargar las respuestas del test
                  final historyCubit = context.read<HistoryCubit>();
                  final answers = await historyCubit.fetchTestAnswers(item.test.id!);

                  // Cerrar el diálogo de carga usando rootNavigator
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop();
                    // Esperar un frame antes de navegar para evitar conflictos con el Navigator
                    await Future.delayed(const Duration(milliseconds: 100));
                  }

                  if (context.mounted) {
                    if (canResume) {
                      // Test no finalizado: Navegar a TopicTestPage para retomarlo/continuarlo
                      context.push(
                        AppRoutes.historyTestReview,
                        extra: {
                          'userTest': item.test,
                          'userTestAnswers': answers,
                          'isResumingTest': true, // ← Flag para indicar que se está retomando
                        },
                      );
                    } else {
                      // Test finalizado: Navegar a revisión normal
                      context.push(
                        AppRoutes.historyTestReview,
                        extra: {
                          'userTest': item.test,
                          'userTestAnswers': answers,
                        },
                      );
                    }
                  }
                } catch (e) {
                  // Cerrar el diálogo de carga usando rootNavigator
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }

                  // Mostrar error
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al cargar el test: $e'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              },
            );
          } else if (item is GroupedHistoryItemModel) {
            return GroupedHistoryItem(
              groupedTest: item.groupedTest,
              isFirstOfDay: isFirstOfDay,
              showTodayMarker: showTodayMarker,
              onTap: () {
                // Navegar usando GoRouter con extra
                context.push(
                  AppRoutes.historyFinalTestReview,
                  extra: {
                    'topicGroupId': item.groupedTest.topicGroupId,
                    'userTestIds': item.groupedTest.tests
                        .map((t) => t.id!)
                        .toList(),
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  bool _isFirstItemOfDay(List<HistoryItemModel> items, int index) {
    if (index == 0) return true;
    final currentItem = items[index];
    final previousItem = items[index - 1];
    return !_isSameDay(currentItem.createdAt, previousItem.createdAt);
  }

  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
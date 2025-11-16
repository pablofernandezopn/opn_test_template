import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_template/app/features/history/cubit/history_cubit.dart';
import 'package:opn_test_template/app/features/history/cubit/history_state.dart';
import 'package:opn_test_template/app/features/history/view/pages/history_page.dart';
import 'package:opn_test_template/app/features/questions/view/topic_test_page.dart';
import 'package:opn_test_template/app/features/questions/view/final_test_page.dart';
import 'package:opn_test_template/app/config/go_route/app_routes.dart';
import 'history_item.dart';
import 'grouped_history_item.dart';
import '../../model/history_item_model.dart';

/// Widget que muestra los 3 tests más recientes en la página home
class RecentTestsWidget extends StatelessWidget {
  const RecentTestsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        // No mostrar nada si está cargando por primera vez
        if (state.fetchRecentTestsStatus.isLoading && state.recentTests.isEmpty) {
          return const SizedBox.shrink();
        }

        // No mostrar nada si está vacío
        if (state.recentTests.isEmpty) {
          return const SizedBox.shrink();
        }

        return ColoredBox(
          color: colorScheme.surfaceContainerLowest,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con título y botón "Ver todo"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Últimos tests',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          context.push(HistoryPage.route);
                        },
                       borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Ver historial',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.list,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Transformar y mostrar tests recientes (agrupados + individuales)
                Builder(
                  builder: (context) {
                    // Transformar tests recientes en items del historial
                    final historyItems = HistoryItemTransformer.transform(
                      state.recentTests,
                      topicGroupNames: {},
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: historyItems.asMap().entries.map(
                          (entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final isFirstOfDay = index == 0;

                            // Renderizar según el tipo de item
                            if (item is SingleHistoryItem) {
                              return HistoryItem(
                                test: item.test,
                                isFirstOfDay: isFirstOfDay,
                                showTodayMarker: false,
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
                                  print('🔍 [RECENT_TESTS] onTap - Test ID: ${item.test.id}');
                                  print('🔍 [RECENT_TESTS] - finalized: ${item.test.finalized}');
                                  print('🔍 [RECENT_TESTS] - totalAnswered: ${item.test.totalAnswered}');
                                  print('🔍 [RECENT_TESTS] - isPaused: ${item.test.isPaused}');
                                  print('🔍 [RECENT_TESTS] - canResume: $canResume');

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
                                showTodayMarker: false,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => FinalTestPage(
                                        topicGroupId: item.groupedTest.topicGroupId,
                                        userTestIds: item.groupedTest.tests
                                            .map((t) => t.id!)
                                            .toList(),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
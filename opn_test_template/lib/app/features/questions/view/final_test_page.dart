import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/service_locator.dart';
import '../../../config/go_route/app_routes.dart';
import '../../history/model/user_test_model.dart';
import '../../history/repository/history_repository.dart';
import '../../history/view/components/history_item.dart';
import '../../history/cubit/history_cubit.dart';
import '../../topics/model/topic_group_model.dart';
import '../../topics/repository/topic_repository.dart';
import '../../topics/cubit/topic_cubit.dart';
import '../../../../bootstrap.dart';
import 'components/final_test_header.dart';
import 'components/final_test_stats.dart';
import 'topic_test_page.dart';

/// Página de resultados finales para tests agrupados
///
/// Muestra:
/// - Header con nombre del grupo y estado (completado/timeout)
/// - Estadísticas globales (suma y promedio de puntuaciones)
/// - Lista de partes con resultados individuales
/// - Botón para volver a inicio
class FinalTestPage extends StatefulWidget {
  const FinalTestPage({
    super.key,
    required this.topicGroupId,
    required this.userTestIds,
    this.timedOut = false,
  });

  /// ID del grupo de topics
  final int topicGroupId;

  /// IDs de los user_tests completados
  final List<int> userTestIds;

  /// ¿El examen finalizó por timeout?
  final bool timedOut;

  @override
  State<FinalTestPage> createState() => _FinalTestPageState();
}

class _FinalTestPageState extends State<FinalTestPage> {
  bool _loading = true;
  String? _error;
  TopicGroup? _topicGroup;
  List<UserTest> _userTests = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Cargar topic group
      final topicRepo = getIt<TopicRepository>();
      final topicGroup = await topicRepo.fetchTopicGroupById(widget.topicGroupId);

      if (topicGroup == null) {
        _setError('No se pudo cargar el grupo de examen.');
        return;
      }

      // Cargar user tests
      final historyRepo = getIt<HistoryRepository>();
      final userTests = <UserTest>[];
      for (final id in widget.userTestIds) {
        final test = await historyRepo.fetchUserTestById(id);
        if (test != null) {
          userTests.add(test);
        }
      }

      if (userTests.isEmpty) {
        _setError('No se encontraron resultados del examen.');
        return;
      }

      if (!mounted) return;

      setState(() {
        _topicGroup = topicGroup;
        _userTests = userTests;
        _loading = false;
      });
    } catch (e) {
      logger.error('Error cargando resultados finales: $e');
      _setError('Error al cargar los resultados.');
    }
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resultados')),
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
                    // Navegar al home y limpiar el stack
                    if (context.canPop()) {
                      context.pop();
                    }

                  },
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLow,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header con nombre del grupo y estado
            SliverToBoxAdapter(
              child: FinalTestHeader(
                groupName: _topicGroup?.name ?? 'Examen',
                timedOut: widget.timedOut,
                totalParts: _userTests.length,
              ),
            ),

            // Estadísticas globales
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: FinalTestStats(
                  userTests: _userTests,
                ),
              ),
            ),

            // Título de la sección de partes
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Partes del examen',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),

            // Lista de partes usando HistoryItem
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final test = _userTests[index];
                    final isFirstOfDay = index == 0;

                    return HistoryItem(
                      test: test,
                      isFirstOfDay: isFirstOfDay,
                      showTodayMarker: false,
                      showTimeline: false,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TopicTestPage(
                              userTest: test,
                              isHistoryReview: true,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: _userTests.length,
                ),
              ),
            ),

            // Botón para volver
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: FilledButton(
                  onPressed: () async {
                    // Actualizar topics completados e historial
                    try {
                      final topicCubit = context.read<TopicCubit>();
                      final historyCubit = context.read<HistoryCubit>();
                      await Future.wait([
                        topicCubit.fetchCompletedTopics(),
                        historyCubit.refresh(),
                      ]);
                    } catch (e) {
                      logger.error('Error refrescando datos: $e');
                    }

                    if (!context.mounted) return;

                    // Limpiar el stack de navegación hasta llegar al home
                    while (context.canPop()) {
                      context.pop();
                    }
                    // Asegurar que estamos en home
                    context.go(AppRoutes.home);
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Volver al inicio'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
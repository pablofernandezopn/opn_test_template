import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_template/app/config/service_locator.dart';
import 'package:opn_test_template/app/authentification/auth/cubit/auth_cubit.dart';
import '../../../authentification/auth/cubit/auth_state.dart';
import '../cubit/stats_cubit.dart';
import '../cubit/stats_state.dart';
import '../repository/stats_repository.dart';
import 'components/topic_scores_bar_chart.dart';
import 'components/evolution_line_chart.dart';
import 'components/progress_radar_chart.dart';
import 'components/ranking_distribution_pie_chart.dart';
import 'components/topic_type_evolution_chart.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  static const String route = '/stats';

  /// Factory method para crear la página con su provider
  static Widget create() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState.status != AuthStatus.authenticated) {
          return const Scaffold(
            body: Center(
              child: Text('Debes iniciar sesión para ver las estadísticas'),
            ),
          );
        }

        return BlocProvider(
          create: (context) => StatsCubit(
            getIt<StatsRepository>(),
            userId: authState.user.id,
          )..loadStats(),
          child: const StatsPage(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Estadísticas'),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<StatsCubit, StatsState>(
            builder: (context, state) {
              if (state.status == StatsStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state.status == StatsStatus.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage ?? 'Error al cargar estadísticas',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.read<StatsCubit>().refresh(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              final globalStats = state.globalStats;
              final topicStats = state.topicStats;
              final user = authState.user;

              if (globalStats.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart_outlined,
                        size: 80,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay estadísticas disponibles',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completa algunos tests para ver tus estadísticas',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // Cargar datos de evolución si aún no están cargados
              if (state.evolutionData.isEmpty) {
                final cubit = context.read<StatsCubit>();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  cubit.loadEvolution(days: 30);
                });
              }

              // Cargar datos de evolución por topic_type si aún no están cargados
              if (state.evolutionByTopicType.isEmpty) {
                final cubit = context.read<StatsCubit>();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  cubit.loadEvolutionByTopicType();
                });
              }

              return RefreshIndicator(
                onRefresh: () async {
                  final cubit = context.read<StatsCubit>();
                  await cubit.refresh();
                  await Future.wait([
                    cubit.loadEvolution(days: 30),
                    cubit.loadEvolutionByTopicType(),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con información del usuario
                      _UserHeader(user: user),
                      const SizedBox(height: 24),

                      // Dashboard compacto de estadísticas
                      _CompactDashboard(
                        user: user,
                        globalStats: globalStats,
                      ),
                      const SizedBox(height: 32),
                      // Gráfica de evolución temporal
                      if (state.evolutionData.isNotEmpty) ...[
                        EvolutionLineChart(
                          evolutionData: state.evolutionData,
                          days: 30,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Gráfica radar de progreso
                      if (topicStats.length >= 3) ...[
                        ProgressRadarChart(topicStats: topicStats),
                        const SizedBox(height: 24),
                      ],

                      // Gráficas de evolución por topic_type
                      if (state.evolutionByTopicType.isNotEmpty) ...[
                        Text(
                          'Evolución por Área',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        ...state.evolutionByTopicType.map((topicTypeData) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TopicTypeEvolutionChart(data: topicTypeData),
                          );
                        }),
                        const SizedBox(height: 8),
                      ],

                      // Estadísticas por topic (lista detallada)
                      if (topicStats.isNotEmpty) ...[
                        Text(
                          'Detalle por tema',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: topicStats.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _TopicStatsCard(stats: topicStats[index]);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TopicStatsCard extends StatelessWidget {
  const _TopicStatsCard({required this.stats});

  final dynamic stats;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    stats.topicName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (stats.isTop3)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'TOP 3',
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SmallStatItem(
                    label: 'Primera',
                    value: '${stats.firstScore.toStringAsFixed(1)}%',
                    color: colors.primary,
                  ),
                ),
                Expanded(
                  child: _SmallStatItem(
                    label: 'Mejor',
                    value: '${stats.bestScore.toStringAsFixed(1)}%',
                    color: colors.secondary,
                  ),
                ),
                Expanded(
                  child: _SmallStatItem(
                    label: 'Intentos',
                    value: '${stats.attempts}',
                    color: colors.tertiary,
                  ),
                ),
              ],
            ),
            if (stats.rankPosition != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Posición en ranking',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '#${stats.rankPosition} de ${stats.totalParticipants}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SmallStatItem extends StatelessWidget {
  const _SmallStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

/// Widget que muestra la información del usuario
class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final displayName = user.displayName ??
        user.username ??
        '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();

    return Row(
      children: [
        // Avatar del usuario
        CircleAvatar(
          radius: 32,
          backgroundColor: colorScheme.primaryContainer,
          backgroundImage:
              user.profileImage != null ? NetworkImage(user.profileImage!) : null,
          child: user.profileImage == null
              ? Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),
        // Información del usuario
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName.isNotEmpty ? displayName : 'Usuario',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '@${user.username}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dashboard compacto con las estadísticas más relevantes
class _CompactDashboard extends StatelessWidget {
  const _CompactDashboard({
    required this.user,
    required this.globalStats,
  });

  final dynamic user;
  final dynamic globalStats;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Calcular tasa de acierto y error
    final totalQuestions = user.totalQuestions ?? 0;
    final rightQuestions = user.rightQuestions ?? 0;
    final wrongQuestions = user.wrongQuestions ?? 0;

    final successRate = totalQuestions > 0
        ? (rightQuestions / totalQuestions * 100).toStringAsFixed(1)
        : '0.0';
    final errorRate = totalQuestions > 0
        ? (wrongQuestions / totalQuestions * 100).toStringAsFixed(1)
        : '0.0';

    // Acceder al índice OPN desde opnIndexData
    final opnIndex = user.opnIndexData?.opnIndex;
    final globalRank = user.opnIndexData?.globalRank;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen de rendimiento',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Grid de estadísticas principales
        Row(

              children: [
                Expanded(
                  child: _DashboardMetric(
                    icon: Icons.trending_up,
                    label: 'Índice OPN',
                    value: opnIndex?.toString() ?? 'N/A',
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                // Ranking Global
                Expanded(
                  child: _DashboardMetric(
                    icon: Icons.leaderboard,
                    label: 'Ranking Global',
                    value: globalRank != null ? '#$globalRank' : 'N/A',
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
       const SizedBox(height: 8),
        Row(
              children: [
                // Tasa de acierto
                Expanded(
                  child: _DashboardMetric(
                    icon: Icons.check_circle,
                    label: 'Tasa de Acierto',
                    value: '$successRate%',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                // Tasa de error
                Expanded(
                  child: _DashboardMetric(
                    icon: Icons.cancel,
                    label: 'Tasa de Error',
                    value: '$errorRate%',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            // Índice OPN
        const SizedBox(height: 8),
        // Estadísticas adicionales en fila
        Row(
          children: [
            Expanded(
              child: _DashboardMetric(
                icon: Icons.quiz,
                label: 'Preguntas Totales',
                value: totalQuestions.toString(),
                color: colorScheme.tertiary,
                isCompact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DashboardMetric(
                icon: Icons.emoji_events,
                label: 'Tests Completados',
                value: globalStats.totalMockTests.toString(),
                color: Colors.amber,
                isCompact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Widget individual para cada métrica del dashboard
class _DashboardMetric extends StatelessWidget {
  const _DashboardMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isCompact = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: (textTheme.titleSmall)
                ?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isCompact ? 2 : 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
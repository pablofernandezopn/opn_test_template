import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_template/app/features/topics/cubit/topic_cubit.dart';
import 'package:opn_test_template/app/features/topics/cubit/topic_state.dart';
import 'package:opn_test_template/app/features/topics/model/topic_level.dart';
import 'package:opn_test_template/app/features/topics/model/topic_model.dart';
import 'package:opn_test_template/app/features/topics/model/topic_or_group.dart';
import 'package:opn_test_template/app/features/topics/model/user_completed_topic_model.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../authentification/auth/model/user.dart';
import '../../../config/app_bloc_listeners.dart';
import '../../../config/go_route/app_routes.dart';
import '../../topics/model/topic_group_model.dart';
import 'components/home_drawer.dart';
import 'components/question_box_statistics.dart';
import 'components/question_progress.dart';
import 'components/ranking_position.dart';
import 'components/test_item.dart';
import 'components/change_goal_dialog.dart';
import 'components/saved_config_card.dart';
import 'view_all_topics_page.dart';
import '../../history/view/components/recent_tests_widget.dart';
import '../../topics/view/preview_topic_page.dart';
import '../../test_config/cubit/test_config_cubit.dart';
import '../../test_config/cubit/test_config_state.dart';
import '../../test_config/model/saved_test_config.dart';
import '../../test_config/view/components/saved_configs_sheet.dart';
import '../../../../bootstrap.dart';
import '../../streak/cubit/streak_cubit.dart';
import '../../streak/cubit/streak_state.dart';
import '../../streak/repository/streak_repository.dart';
import '../../streak/view/components/streak_widget.dart';
import '../../streak/view/components/streak_loading_widget.dart';
import '../../streak/view/components/streak_error_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const HomeView();

  static Future<void> showChangeGoalDialog(BuildContext context, int currentGoal) async {
    final newGoal = await showDialog<int>(
      context: context,
      builder: (dialogContext) => ChangeGoalDialog(currentGoal: currentGoal),
    );

    if (newGoal != null && newGoal != currentGoal && context.mounted) {
      // Capturar el BuildContext del diálogo de loading
      BuildContext? loadingContext;

      try {
        // Mostrar loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            loadingContext = dialogContext;
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        // Actualizar el objetivo
        await context.read<AuthCubit>().updateQuestionGoal(newGoal);

        // Cerrar loading usando el contexto capturado
        if (loadingContext != null && loadingContext!.mounted) {
          Navigator.of(loadingContext!).pop();
        }

        if (context.mounted) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Objetivo actualizado a $newGoal preguntas'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Cerrar loading usando el contexto capturado si existe
        if (loadingContext != null && loadingContext!.mounted) {
          Navigator.of(loadingContext!).pop();
        }

        if (context.mounted) {
          // Mostrar error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar el objetivo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Valores anteriores del usuario para animar el cambio
  int? _previousTotalQuestions;
  int? _previousRightQuestions;
  int? _previousWrongQuestions;
  bool _shouldAnimate = false;

  @override
  void initState() {
    super.initState();
    // Esperar a que el widget esté completamente construido
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Guardar los valores actuales antes de refrescar
      final authCubit = context.read<AuthCubit>();
      final currentUser = authCubit.state.user;
      _previousTotalQuestions = currentUser.totalQuestions;
      _previousRightQuestions = currentUser.rightQuestions;
      _previousWrongQuestions = currentUser.wrongQuestions;

      // Refrescar stats usando el cubit (lógica de negocio en repository)
      try {
        await authCubit.refreshQuestionStats();

        if (!mounted) return;

        final newUser = authCubit.state.user;

        // Verificar si hubo cambios
        final hasChanges = newUser.totalQuestions != _previousTotalQuestions ||
            newUser.rightQuestions != _previousRightQuestions ||
            newUser.wrongQuestions != _previousWrongQuestions;

        setState(() {
          _shouldAnimate = hasChanges;
        });
      } catch (e) {
        logger.error('Error refreshing user stats: $e');
      }

      // Mostrar popup de teléfono si es necesario
      await AppBlocListeners.ensurePhoneCaptured(context);

      if (!mounted) return;

      // Mostrar popup de especialidad si es necesario (después del teléfono)
      await AppBlocListeners.ensureSpecialtySelected(context);

      if (!mounted) return;

      // Cargar configuraciones guardadas del usuario
      final userId = context.read<AuthCubit>().state.user.id;
      context.read<TestConfigCubit>().loadSavedConfigs(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = context.watch<AuthCubit>().state.user;
    final academy = context.watch<AuthCubit>().state.academy;
    final userName = user.firstName ?? user.username;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      endDrawerEnableOpenDragGesture: false,
      endDrawer: HomeDrawer(user: user, academy: academy),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Space(20),
              _Header(userName: userName),
              const Space(12),
              _RankingData(),
              const Space(12),
              _WeeklyProgress(
                user: user,
                previousTotal: _shouldAnimate ? _previousTotalQuestions : null,
                previousRight: _shouldAnimate ? _previousRightQuestions : null,
                previousWrong: _shouldAnimate ? _previousWrongQuestions : null,
              ),
              const Space(24),
              _StreakSection(userId: user.id),
              const Space(28),
              _DoTestButton(colorScheme: colorScheme),

              const Space(20),
              const _SavedConfigsSection(),

              //const Space(20),
              //_GamesSection(colorScheme: colorScheme),

              const Space(20),
              BlocBuilder<TopicCubit, TopicState>(
                builder: (context, topicState) {
                  final isLoading =
                      topicState.fetchTopicTypesStatus.isLoading ||
                      topicState.fetchTopicsStatus.isLoading;

                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final hasError =
                      topicState.fetchTopicTypesStatus.isError ||
                      topicState.fetchTopicsStatus.isError;

                  if (hasError) {
                    final error = topicState.error ?? 'No se pudieron cargar los test.';
                    return Center(child: Text('Error: $error'));
                  }

                  final topics = topicState.topics;

                  final topicTypesWithContent = topicState.topicTypes
                      .where((type) =>
                          type.id != null &&
                          type.level != TopicLevel.Study &&
                          topics.any((t) => t.topicTypeId == type.id))
                      .toList()
                    ..sort((a, b) =>
                        (a.orderOfAppearance ?? 0).compareTo(b.orderOfAppearance ?? 0));

                  if (topicTypesWithContent.isEmpty || topics.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'Aún no hay test disponibles.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }


                  return Column(
                    children: [
                      for (int i = 0; i < topicTypesWithContent.length; i++)
                        Builder(
                          builder: (context) {
                            final type = topicTypesWithContent[i];
                            final typeId = type.id;
                            if (typeId == null) return const SizedBox.shrink();

                            // Filtrar topics por tipo
                            final filteredTopics = topics
                                .where((t) => t.topicTypeId == typeId && t.topicGroupId == null)
                                .toList();

                            // Filtrar topic_groups por tipo usando el mapa
                            final filteredGroups = topicState.topicGroups
                                .where((g) => g.id != null && topicState.topicGroupTypeMap[g.id] == typeId)
                                .toList();

                            // Mezclar topics y groups en TopicOrGroup
                            final items = <TopicOrGroup>[
                              ...filteredTopics.map((t) => TopicOrGroup.topic(t)),
                              ...filteredGroups.map((g) => TopicOrGroup.group(
                                g,
                                topicState.topicGroupCountMap[g.id] ?? 0,
                              )),
                            ];

                            // Ordenar por published_at (más recientes primero)
                            items.sort((a, b) {
                              final aDate = a.publishedAt;
                              final bDate = b.publishedAt;
                              if (aDate == null && bDate == null) return 0;
                              if (aDate == null) return 1;
                              if (bDate == null) return -1;
                              return bDate.compareTo(aDate); // Descendente
                            });

                            if (items.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return _TopicTypeList(
                              title: type.topicTypeName,
                              items: items,
                              isEven: i.isEven,
                              topicTypeId: typeId,
                              completedTopicIds: topicState.completedTopicIds,
                              completedTopics: topicState.completedTopics,
                              allTopics: topics,
                            );
                          },
                        ),
                    ],
                  );
                },
              ),

              const Space(20),
              const RecentTestsWidget(),
              const Space(40),
            ],
          ),
        ),
      ),
    );
  }
}



// ======================================================
// DATOS DE RANKING
// ======================================================
class _RankingData extends StatelessWidget {
  const _RankingData({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = context.watch<AuthCubit>().state.user;

    // Calcular porcentaje del índice OPN (máximo 1000)
    final opnIndex = user.opnIndexData?.opnIndex ?? 0;
    final opnPercentage = opnIndex;

    // Obtener la posición en el ranking
    final globalRank = user.opnIndexData?.globalRank ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          RankingPosition(
              opnIndex: user.opnIndexData?.opnIndex,
              globalRank: user.opnIndexData?.globalRank,
            ),

          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _rankingButton(context),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatisticData(
                        label: 'Índice OPN',
                        value: opnPercentage,
                        color: colors.primary,
                        borderColor: colors.onPrimaryContainer.withAlpha(55),
                        backgroundColor: colors.primaryContainer.withAlpha(55),
                        precision: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatisticData(
                        label: 'Posición',
                        value: globalRank.toDouble(),
                        color: colors.secondary,
                        borderColor: colors.onPrimaryContainer.withAlpha(55),
                        backgroundColor: colors.secondaryContainer.withAlpha(55),
                        precision: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankingButton(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        context.pushNamed(AppRoutes.opnRanking);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.primary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ver ranking',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.sports_score,
              size: 16,
              color: colors.primary,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// HEADER
// ======================================================

class _Header extends StatelessWidget {
  const _Header({required this.userName});
  final String userName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hola $userName',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: const Icon(Icons.menu),
            iconSize: 24,
          ),
        ],
      ),
    );
  }
}

// ======================================================
// SEMANA Y ESTADÍSTICAS
// ======================================================

class _WeeklyProgress extends StatelessWidget {
  const _WeeklyProgress({
    required this.user,
    this.previousTotal,
    this.previousRight,
    this.previousWrong,
  });

  final User user;
  final int? previousTotal;
  final int? previousRight;
  final int? previousWrong;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rightQuestions = user.rightQuestions;
    final wrongQuestions = user.wrongQuestions;
    final totalQuestions = user.totalQuestions;
    final blankQuestions =
        math.max(totalQuestions - rightQuestions - wrongQuestions, 0);

    // Calcular valores anteriores de blankQuestions si hay cambios
    final previousBlank = (previousTotal != null && previousRight != null && previousWrong != null)
        ? math.max(previousTotal! - previousRight! - previousWrong!, 0)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsetsGeometry.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // ESTADÍSTICAS
            Row(
              children: [
                Expanded(
                  child: QuestionResult(
                    label: 'Acertadas',
                    value: rightQuestions,
                    icon: Icons.check,
                    color: cs.primaryContainer.withValues(alpha: 0.6),
                    textColor: cs.onSurface,
                    iconColor: cs.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: QuestionResult(
                    label: 'Falladas',
                    value: wrongQuestions,
                    icon: Icons.close,
                    color: cs.errorContainer.withValues(alpha: 0.6),
                    textColor: cs.onSurface,
                    iconColor: cs.error,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: QuestionResult(
                    label: 'En blanco',
                    value: blankQuestions,
                    icon: Icons.circle_outlined,
                    color: cs.secondaryContainer.withValues(alpha: 0.6),
                    textColor: cs.onSurface,
                    iconColor: cs.onSecondaryContainer,
                  ),
                ),
              ],
            ),

            const Space(16),
            // HEADER
            Row(
              children: [
                Row(
                  children: [

                    Text(
                      'Tu semana',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // VER ESTADÍSTICAS COMPLETAS
                InkWell(
                  onTap: () {
                    context.pushNamed(AppRoutes.stats);
                  },
                  child: Row(
                    children: [
                      Text('Ver estadísticas',
                      style: TextStyle(
                        color: cs.onSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12
                      ),

                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.bar_chart
                          , size: 16, color: cs.onSecondary)
                    ],
                  ))

              ],
            ),
            const Space(12),

            // PROGRESO
            QuestionProgress(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              goal: totalQuestions,
              goalWeek: user.questionGoal,
              onChangeGoal: () => HomePage.showChangeGoalDialog(context, user.questionGoal),
            ),


          ],
        ),
      ),
    );
  }
}


// ======================================================
// BOTÓN HACER TEST
// ======================================================

class _DoTestButton extends StatelessWidget {
  const _DoTestButton({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          context.pushNamed(AppRoutes.testConfig);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hacer test', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Icon(Icons.play_arrow, size: 28),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// BLOQUES DE TEMARIOS
// ======================================================

class _TopicTypeList extends StatelessWidget {
  const _TopicTypeList({
    required this.title,
    required this.items,
    required this.isEven,
    required this.topicTypeId,
    required this.completedTopicIds,
    required this.completedTopics,
    required this.allTopics,
  });

  final String title;
  final List<TopicOrGroup> items;
  final bool isEven;
  final int topicTypeId;
  final Set<int> completedTopicIds;
  final List<UserCompletedTopic> completedTopics;
  final List<Topic> allTopics;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: isEven
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                H2Old(title),
                const Spacer(),
                if (items.isNotEmpty)
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ViewAllTopicsPage(
                            topicTypeId: topicTypeId,
                            title: title,
                          ),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Highlight('Ver todos'),
                        SizedBox(width: 4),
                        Icon(Icons.grid_view_rounded, size: 20),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('No hay temas disponibles'),
            )
          else
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final topicState = context.read<TopicCubit>().state;

                  if (item.isGroup) {
                    // Buscar el ranking del grupo
                    final groupRanking = topicState.completedTopicGroups
                        .where((g) => g.topicGroupId == item.topicGroup!.id)
                        .firstOrNull;

                    // Mostrar TopicGroup con badge
                    return _TopicGroupItem(
                      singleTitle: title,
                      topicGroup: item.topicGroup!,
                      topicCount: item.topicCount ?? 0,
                      completedTopicIds: completedTopicIds,
                      allTopics: allTopics,
                      rankPosition: groupRanking?.rankPosition,
                    );
                  } else {
                    // Mostrar Topic normal
                    final topic = item.topic!;
                    final isCompleted = topic.id != null &&
                                       completedTopicIds.contains(topic.id!);

                    // Buscar información del ranking para este topic
                    final completedTopic = completedTopics.firstWhere(
                      (ct) => ct.topicId == topic.id,
                      orElse: () => UserCompletedTopic(
                        topicId: topic.id!,
                        attempts: 0,
                        lastAttemptDate: DateTime.now(),
                      ),
                    );

                    final hasRanking = completedTopic.rankPosition != null;
                    final rankPosition = completedTopic.rankPosition;
                    final bestScore = completedTopic.bestScore;

                    return SpecialTestItem(
                      singleTitle: title,
                      topic: topic,
                      rank: rankPosition,
                      showRanking: hasRanking,
                      percentile: bestScore?.toInt(),
                      showTick: isCompleted,
                      isCompleted: isCompleted,
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ======================================================
// TOPIC GROUP ITEM - Widget para mostrar grupos con badge
// ======================================================

class _TopicGroupItem extends StatelessWidget {
  const _TopicGroupItem({
    required this.singleTitle,
    required this.topicGroup,
    required this.topicCount,
    required this.completedTopicIds,
    required this.allTopics,
    this.rankPosition,
  });

  final String singleTitle;
  final TopicGroup topicGroup;
  final int topicCount;
  final Set<int> completedTopicIds;
  final List<Topic> allTopics;
  final int? rankPosition;

  /// Verifica si todos los topics del grupo están completados
  bool get isCompleted {
    final groupId = topicGroup.id;
    if (groupId == null) return false;

    // Obtener todos los topics que pertenecen a este grupo
    final groupTopics = allTopics.where((t) => t.topicGroupId == groupId).toList();

    // Si no hay topics en el grupo, no está completado
    if (groupTopics.isEmpty) return false;

    // Verificar que todos los topics del grupo estén completados
    return groupTopics.every((t) => t.id != null && completedTopicIds.contains(t.id!));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = topicGroup.imageUrl != null && topicGroup.imageUrl!.isNotEmpty;
    final titleColor = hasImage ? colorScheme.onPrimary : colorScheme.onPrimaryContainer;
    final subtitleColor = hasImage
        ? colorScheme.onPrimary.withValues(alpha: 0.92)
        : colorScheme.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PreviewTopicPage(topicGroup: topicGroup),
              ),
            );
          },
          child: SpecialTestBox(
            title: Text(
              topicGroup.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: _buildSubtitle(context, subtitleColor),
            imageUrl: topicGroup.imageUrl,
            publishedAt: topicGroup.publishedAt,
            isCompleted: isCompleted,
            rankPosition: rankPosition,
          ),
        ),
        const SizedBox(height: 6),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context, Color textColor) {
    final textStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: textColor);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.layers_rounded,
          size: 16,
          color: textColor,
        ),
        const SizedBox(width: 4),
        Text(
          '$topicCount partes',
          style: textStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: colors.onSurfaceVariant);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer_outlined, size: 14, color: colors.primary),
        const SizedBox(width: 4),
        Text('${topicGroup.durationMinutes} min', style: style),
      ],
    );
  }
}

// ======================================================
// SECCIÓN DE CONFIGURACIONES GUARDADAS
// ======================================================

class _SavedConfigsSection extends StatelessWidget {
  const _SavedConfigsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TestConfigCubit, TestConfigState>(
      builder: (context, state) {
        // No mostrar la sección si no hay configuraciones o si está cargando
        if (state.savedConfigsStatus.isLoading || state.savedConfigs.isEmpty) {
          return const SizedBox.shrink();
        }

        final configs = state.savedConfigs;
        // Mostrar máximo 3 configuraciones
        final displayConfigs = configs.take(3).toList();
        final hasMore = configs.length > 3;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const H2Old('Configuraciones Guardadas'),
                  const Spacer(),
                  if (configs.isNotEmpty)
                    InkWell(
                      onTap: () => _showAllConfigs(context),
                      child: const Row(
                        children: [
                          Highlight('Ver todas'),
                          SizedBox(width: 4),
                          Icon(Icons.bookmark_outline, size: 20),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Lista horizontal de configuraciones
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayConfigs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {

                    final config = displayConfigs[index];
                    return SavedConfigCard(
                      config: config,
                      onTap: () => _loadConfig(context, config),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _loadConfig(BuildContext context, SavedTestConfig config) {
    // Navegar a la página de configuración pasando la config como extra
    context.pushNamed(
      AppRoutes.testConfig,
      extra: config, // Pasar la configuración como parámetro
    );
  }

  void _showAllConfigs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SavedConfigsSheet(),
    );
  }
}

// ======================================================
// SECCIÓN DE JUEGOS
// ======================================================

class _GamesSection extends StatelessWidget {
  const _GamesSection({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la sección
          Row(
            children: [
              H2Old('Juegos'),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          // Tarjeta de Modo Supervivencia
          _SurvivalGameCard(colorScheme: colorScheme),
        ],
      ),
    );
  }
}

class _SurvivalGameCard extends StatelessWidget {
  const _SurvivalGameCard({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(AppRoutes.survivalPreview);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepOrange.shade400,
              Colors.red.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modo Supervivencia',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3 vidas • Dificultad creciente • ¿Hasta dónde llegarás?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Flecha
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// SECCIÓN DE RACHA
// ======================================================

class _StreakSection extends StatelessWidget {
  const _StreakSection({required this.userId});
  final int userId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocProvider(
        create: (context) => StreakCubit(
          repository: StreakRepository(),
          userId: userId,
        )..loadStreakData(),
        child: BlocBuilder<StreakCubit, StreakState>(
          builder: (context, state) {
            return state.when(
              initial: () => const StreakLoadingWidget(),
              loading: () => const StreakLoadingWidget(),
              loaded: (streakData) => StreakWidget(
                streakData: streakData,
                onTap: () => _showStreakDetails(context, streakData),
              ),
              error: (message) => StreakErrorWidget(
                errorMessage: message,
                onRetry: () {
                  context.read<StreakCubit>().loadStreakData();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showStreakDetails(BuildContext context, streakData) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🔥', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            const Text('Tu Racha'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow(
              context,
              icon: Icons.local_fire_department,
              label: 'Racha actual',
              value: '${streakData.currentStreak} días',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              icon: Icons.emoji_events,
              label: 'Récord personal',
              value: '${streakData.longestStreak} días',
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              icon: Icons.calendar_today,
              label: 'Esta semana',
              value: '${streakData.weekCompletedDays}/7 días',
              color: Colors.blue,
            ),
            if (streakData.currentStreak > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        streakData.completedToday
                          ? '¡Ya completaste tu práctica hoy! Sigue así.'
                          : 'Completa un test hoy para mantener tu racha.',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ======================================================
// UTILS
// ======================================================

class Space extends StatelessWidget {
  const Space(this.size, {super.key});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}

class Highlight extends StatelessWidget {
  const Highlight(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      ),
    );
  }
}

class H2Old extends StatelessWidget {
  const H2Old(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );
  }
}

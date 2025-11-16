import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../bootstrap.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../config/go_route/app_routes.dart';
import '../../../config/service_locator.dart';
import '../../../config/utils/topic_encryption.dart';
import '../../../config/widgets/app_bar/app_bar_menu.dart';
import '../../../config/widgets/premium/premium_content.dart';
import '../../questions/repository/repository.dart';
import '../../questions/model/question_model.dart';
import '../../ranking/repository/ranking_repository.dart';
import '../../ranking/model/ranking_entry_model.dart';
import '../model/topic_model.dart';
import '../model/topic_type_model.dart';
import '../model/topic_level.dart';
import '../model/topic_group_model.dart';
import '../model/grouped_test_session.dart';
import '../repository/topic_repository.dart';

class PreviewTopicPage extends StatefulWidget {
  const PreviewTopicPage({
    super.key,
    this.topic,
    this.topicGroup,
  }) : assert(topic != null || topicGroup != null, 'Either topic or topicGroup must be provided');

  final Topic? topic;
  final TopicGroup? topicGroup;

  bool get isGroup => topicGroup != null;

  @override
  State<PreviewTopicPage> createState() => _PreviewTopicPageState();
}

class _PreviewTopicPageState extends State<PreviewTopicPage> {
  bool _starting = false;
  List<Question>? _cachedQuestions;
  double? _averageDifficulty;
  TopicType? _topicType;
  bool _isFlashcard = false;
  List<Topic>? _groupTopics;
  int _totalQuestions = 0;
  Map<int, RankingEntry> _topicRankings = {}; // 🆕 Rankings por topicId

  Topic get topic => widget.topic!;
  TopicGroup? get topicGroup => widget.topicGroup;
  bool get isGroup => widget.isGroup;

  @override
  Widget build(BuildContext context) {
    if (isGroup) {
      return _buildGroupPreview();
    }
    return _buildTopicPreview();
  }

  Widget _buildGroupPreview() {
    final description = topicGroup!.description ?? '';
    final user = context.watch<AuthCubit>().state.user;
    final shouldLock = topicGroup!.isPremium && user.isFreemium;


    return Scaffold(
      appBar: AppBarMenu(title: topicGroup!.name),
      body: PremiumContent(
        requiresPremium: shouldLock,
        onPressed: shouldLock ? _showPremiumMessage : null,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GroupHeader(topicGroup: topicGroup!, topicCount: _groupTopics?.length ?? 0, totalQuestions: _totalQuestions),
              const SizedBox(height: 24),
              _GroupMetrics(topicGroup: topicGroup!, topics: _groupTopics ?? []),
              if (_groupTopics != null && _groupTopics!.isNotEmpty) ...[
                const SizedBox(height: 24),
                _GroupTopicsList(
                  topics: _groupTopics!,
                  rankings: _topicRankings,
                ),
              ],
              if (description.isNotEmpty) ...[
                const SizedBox(height: 24),
                _Description(description: description),
              ],
              const SizedBox(height: 32),
              _StartButton(
                isLocked: shouldLock,
                loading: _starting,
                onPressed: shouldLock ? null : _handleGroupStart,
                isFlashcard: false,
              ),
              // Botón de Ver Ranking (siempre visible para grupos)
              const SizedBox(height: 12),
              _GroupRankingButton(
                topicGroup: topicGroup!,
                isLocked: shouldLock,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicPreview() {
    final description = topic!.description ?? '';
    final user = context.watch<AuthCubit>().state.user;
    final shouldLock = topic!.isPremium && user.isFreemium;


    return Scaffold(
      appBar: AppBarMenu(title: topic!.topicName),
      body: PremiumContent(
        requiresPremium: shouldLock,
        onPressed: shouldLock ? _showPremiumMessage : null,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(topic: topic!, isFlashcard: _isFlashcard),
              const SizedBox(height: 24),
              _Metrics(
                topic: topic!,
                averageDifficulty: _averageDifficulty,
                isFlashcard: _isFlashcard,
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 24),
                _Description(description: description),
              ],
              const SizedBox(height: 32),
              _StartButton(
                isLocked: shouldLock,
                loading: _starting,
                onPressed: shouldLock ? null : _handleStart,
                isFlashcard: _isFlashcard,
              ),
              // Botón de Ver Ranking (solo para topics tipo Mock)
              if (_topicType?.level == TopicLevel.Mock) ...[
                const SizedBox(height: 12),
                _RankingButton(
                  topic: topic!,
                  isLocked: shouldLock,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showPremiumMessage() {

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(content: Text('Contenido Premium. Desbloquea tu acceso para continuar.')),
      );
  }

  Future<void> _handleStart() async {
    if (_starting) return;
    if (!mounted) return;
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.state.user;


    setState(() => _starting = true);

    try {
      if (topic.id == null) {
        _showMessage('No se ha encontrado el identificador del test.');
        return;
      }

      var questions = _cachedQuestions;
      if (questions == null) {
        questions = await getIt<QuestionRepository>().fetchQuestions(
          topicId: topic.id,
          academyId: user.academyId,
        );
        _cachedQuestions = questions;
      }

      if (!mounted) return;

      if (questions.isEmpty) {
        _showMessage('Este test aún no tiene preguntas disponibles.');
        return;
      }

      final token = TopicEncryption.encode(topic.id!);
      context.push('${AppRoutes.topicTest}/$token', extra: topic);
    } catch (e) {
      logger.error('Error al iniciar test para topic ${topic.id}: $e');
      _showMessage('No se pudo iniciar el test. Intenta nuevamente.');
    } finally {
      if (mounted) {
        setState(() => _starting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleGroupStart() async {
    if (_starting) return;
    if (!mounted) return;


    setState(() => _starting = true);

    try {
      if (topicGroup!.id == null) {
        _showMessage('No se ha encontrado el identificador del grupo.');
        return;
      }

      // 🆕 Cargar topics del grupo
      var topics = _groupTopics;
      if (topics == null || topics.isEmpty) {
        topics = await getIt<TopicRepository>().fetchTopicsInGroup(topicGroup!.id!);
        if (!mounted) return;
      }

      if (topics.isEmpty) {
        _showMessage('Este examen no tiene partes configuradas.');
        return;
      }

      // 🆕 Crear sesión de test agrupado
      final session = GroupedTestSession(
        topicGroup: topicGroup!,
        orderedTopics: topics,
        totalDurationSeconds: (topicGroup!.durationSeconds ?? 0).toInt(),
      );

      // 🆕 Navegar al primer topic con la sesión
      final firstTopic = topics.first;
      if (!mounted) return;

      // Usar push para navegar con extra
      context.push(
        '${AppRoutes.topicTest}/${TopicEncryption.encode(firstTopic.id!)}',
        extra: {
          'topic': firstTopic,
          'groupedSession': session,
        },
      );
    } catch (e) {
      logger.error('Error al iniciar grupo ${topicGroup!.id}: $e');
      _showMessage('No se pudo iniciar el examen. Intenta nuevamente.');
    } finally {
      if (mounted) {
        setState(() => _starting = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (isGroup) {
      _loadGroupMetrics();
    } else {
      _loadMetrics();
    }
  }

  Future<void> _loadGroupMetrics() async {
    if (topicGroup?.id == null) return;
    final user = context.read<AuthCubit>().state.user;

    try {
      final topics = await getIt<TopicRepository>().fetchTopicsInGroup(topicGroup!.id!);
      if (!mounted) return;

      int totalQuestions = 0;
      for (final topic in topics) {
        totalQuestions += topic.totalQuestions;
      }

      // 🆕 Cargar rankings del usuario para cada topic del grupo
      final rankingRepo = getIt<RankingRepository>();
      final Map<int, RankingEntry> rankings = {};

      logger.info('🏆 [BADGE] Cargando rankings para ${topics.length} topics del grupo ${topicGroup!.id}');

      for (final topic in topics) {
        if (topic.id != null) {
          try {
            final rankingEntry = await rankingRepo.fetchUserRankingEntry(
              topicId: topic.id!,
              userId: user.id,
            );
            if (rankingEntry != null) {
              rankings[topic.id!] = rankingEntry;
              logger.info('🏆 [BADGE] Topic ${topic.id} (${topic.topicName}): rankPosition=${rankingEntry.rankPosition}, hasCompleted=true');
            } else {
              logger.info('🏆 [BADGE] Topic ${topic.id} (${topic.topicName}): NO completado');
            }
          } catch (e) {
            // Ignorar errores individuales, continuar con el siguiente topic
            logger.debug('No hay ranking para topic ${topic.id}: $e');
          }
        }
      }

      logger.info('🏆 [BADGE] Total rankings cargados: ${rankings.length}');
      logger.info('🏆 [BADGE] Rankings map: ${rankings.map((k, v) => MapEntry(k, 'pos=${v.rankPosition}'))}');

      if (!mounted) return;

      setState(() {
        _groupTopics = topics;
        _totalQuestions = totalQuestions;
        _topicRankings = rankings;
      });
    } catch (e) {
      logger.error('Error cargando métricas del grupo ${topicGroup!.id}: $e');
    }
  }

  Future<void> _loadMetrics() async {
    if (topic?.id == null) return;
    final user = context.read<AuthCubit>().state.user;
    try {
      // Cargar TopicType para saber si es Flashcard
      final topicType = await getIt<TopicRepository>().fetchTopicTypeById(topic!.topicTypeId);
      final isFlashcard = topicType?.level == TopicLevel.Flashcard;

      final questions = await getIt<QuestionRepository>().fetchQuestions(
        topicId: topic!.id,
        academyId: user.academyId,
      );
      if (!mounted) return;
      _cachedQuestions = questions;
      _topicType = topicType;
      _isFlashcard = isFlashcard;

      final difficulties = questions
          .where((q) => q.difficultRate != null)
          .map((q) => q.difficultRate!)
          .toList();
      if (difficulties.isNotEmpty) {
        final average = difficulties.reduce((a, b) => a + b) / difficulties.length;
        setState(() {
          _averageDifficulty = average;
        });
      } else {
        setState(() {});
      }
    } catch (e) {
      logger.error('Error cargando métricas del topic ${topic!.id}: $e');
    }
  }
}

// ======================================================
// GROUP HEADER
// ======================================================

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.topicGroup,
    required this.topicCount,
    required this.totalQuestions,
  });

  final TopicGroup topicGroup;
  final int topicCount;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topicGroup.imageUrl != null && topicGroup.imageUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                topicGroup.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: colors.surfaceContainerLow,
                  alignment: Alignment.center,
                  child: Icon(Icons.image_not_supported_outlined, color: colors.onSurfaceVariant),
                ),
              ),
            ),
          ),
        if (topicGroup.imageUrl != null && topicGroup.imageUrl!.isNotEmpty)
          const SizedBox(height: 16),
        Text(
          topicGroup.name,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _HeaderChip(
              icon: Icons.layers_rounded,
              label: '$topicCount partes',
            ),
            _HeaderChip(
              icon: Icons.help_outline,
              label: '$totalQuestions preguntas',
            ),
          ],
        ),
      ],
    );
  }
}

// ======================================================
// GROUP METRICS
// ======================================================

class _GroupMetrics extends StatelessWidget {
  const _GroupMetrics({
    required this.topicGroup,
    required this.topics,
  });

  final TopicGroup topicGroup;
  final List<Topic> topics;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final metrics = <Widget>[];

    if (topicGroup.durationMinutes > 0) {
      metrics.add(_MetricTile(
        icon: Icons.timer_outlined,
        label: 'Duración total estimada',
        value: '${topicGroup.durationMinutes} minutos',
        color: colors.primary,
      ));
    }

    if (topics.isNotEmpty) {
      metrics.add(_MetricTile(
        icon: Icons.format_list_numbered,
        label: 'Estructura del examen',
        value: '${topics.length} partes secuenciales',
        color: colors.tertiary,
      ));
    }

    if (metrics.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información del examen',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            for (int i = 0; i < metrics.length; i++) ...[
              metrics[i],
              if (i != metrics.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ],
    );
  }
}

// ======================================================
// GROUP TOPICS LIST
// ======================================================

class _GroupTopicsList extends StatelessWidget {
  const _GroupTopicsList({
    required this.topics,
    this.rankings = const {},
  });

  final List<Topic> topics;
  final Map<int, RankingEntry> rankings;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Partes del examen',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
        ),
        const SizedBox(height: 12),
        ...topics.asMap().entries.map((entry) {
          final index = entry.key;
          final topic = entry.value;
          final rankingEntry = topic.id != null ? rankings[topic.id!] : null;
          final hasCompleted = rankingEntry != null;
          final isTopRanking = rankingEntry?.rankPosition != null && rankingEntry!.rankPosition! <= 3;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
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
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic.topicName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.help_outline, size: 14, color: colors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  '${topic.totalQuestions} preguntas',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.timer_outlined, size: 14, color: colors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  '${topic.durationMinutes} min',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 🏆 Badge de ranking/completado
                if (hasCompleted)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildBadge(
                      context: context,
                      isTopRanking: isTopRanking,
                      rankPosition: rankingEntry?.rankPosition,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBadge({
    required BuildContext context,
    required bool isTopRanking,
    required int? rankPosition,
  }) {
    final colors = Theme.of(context).colorScheme;

    Color badgeColor;
    IconData badgeIcon;

    if (isTopRanking && rankPosition != null) {
      // Top 3: Copa con color según posición
      switch (rankPosition) {
        case 1:
          badgeColor = const Color(0xFFFFD700); // Oro
          break;
        case 2:
          badgeColor = const Color(0xFFC0C0C0); // Plata
          break;
        case 3:
          badgeColor = const Color(0xFFCD7F32); // Bronce
          break;
        default:
          badgeColor = Colors.green;
      }
      badgeIcon = Icons.emoji_events_rounded;
    } else {
      // Completado sin ranking top 3: Check verde
      badgeColor = Colors.green;
      badgeIcon = Icons.check_rounded;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.surface.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        badgeIcon,
        color: colors.surface,
        size: 20,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.topic, this.isFlashcard = false});

  final Topic topic;
  final bool isFlashcard;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topic.imageUrl != null && topic.imageUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                topic.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: colors.surfaceContainerLow,
                  alignment: Alignment.center,
                  child: Icon(Icons.image_not_supported_outlined, color: colors.onSurfaceVariant),
                ),
              ),
            ),
          ),
        if (topic.imageUrl != null && topic.imageUrl!.isNotEmpty)
          const SizedBox(height: 16),
        Text(
          topic.topicName,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            if (isFlashcard)
              _HeaderChip(
                icon: Icons.style,
                label: 'Flashcards',
              )
            else
              _HeaderChip(
                icon: Icons.layers,
                label: 'Opciones: ${topic.options}',
              ),
            _HeaderChip(
              icon: isFlashcard ? Icons.collections_bookmark : Icons.help_outline,
              label: '${topic.totalQuestions} ${isFlashcard ? 'tarjetas' : 'preguntas'}',
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.topic, this.averageDifficulty, this.isFlashcard = false});

  final Topic topic;
  final double? averageDifficulty;
  final bool isFlashcard;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final metrics = <Widget>[];

    if (topic.durationMinutes > 0) {
      metrics.add(_MetricTile(
        icon: Icons.timer_outlined,
        label: 'Duración estimada',
        value: '${topic.durationMinutes} minutos',
        color: colors.primary,
      ));
    }
    if (averageDifficulty != null) {
      final difficulty = (averageDifficulty! * 100).clamp(0, 100).toStringAsFixed(1);
      metrics.add(_MetricTile(
        icon: Icons.speed_rounded,
        label: 'Dificultad promedio',
        value: '$difficulty %',
        color: colors.tertiary,
      ));
    }
    if (topic.averageScore != null) {
      metrics.add(_MetricTile(
        icon: Icons.trending_up_rounded,
        label: 'Nota promedio',
        value: topic.averageScore!.toStringAsFixed(1),
        color: colors.secondary,
      ));
    }
    if (topic.totalParticipants > 0) {
      metrics.add(_MetricTile(
        icon: Icons.groups_outlined,
        label: 'Participantes',
        value: '${topic.totalParticipants} personas',
        color: colors.primary,
      ));
    }

    if (metrics.isEmpty) {
      return Container();
    }

    if (isFlashcard) {
      metrics.add(_MetricTile(
        icon: Icons.loop,
        label: 'Sistema de repetición espaciada',
        value: 'Algoritmo SM-2',
        color: colors.tertiary,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isFlashcard ? 'Cómo funciona' : 'Antes de empezar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            for (int i = 0; i < metrics.length; i++) ...[
              metrics[i],
              if (i != metrics.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_outlined, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Descripción',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.isLocked,
    required this.loading,
    required this.onPressed,
    this.isFlashcard = false,
  });

  final bool isLocked;
  final bool loading;
  final VoidCallback? onPressed;
  final bool isFlashcard;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLocked || loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: isLocked ? colors.surfaceContainerHighest : colors.primary,
          foregroundColor: isLocked ? colors.onSurfaceVariant : colors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(colors.onPrimary),
                ),
              )
            : Icon(isLocked ? Icons.lock_rounded : (isFlashcard ? Icons.school : Icons.play_arrow_rounded)),
        label: Text(isLocked
            ? 'Contenido Premium'
            : loading
                ? (isFlashcard ? 'Preparando estudio...' : 'Preparando test...')
                : (isFlashcard ? 'Comenzar estudio' : 'Empezar test')),
      ),
    );
  }
}

class _RankingButton extends StatelessWidget {
  const _RankingButton({
    required this.topic,
    required this.isLocked,
  });

  final Topic topic;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLocked ? null : () => _navigateToRanking(context),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: colors.primary,
          side: BorderSide(
            color: isLocked
                ? colors.outlineVariant
                : colors.primary.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(
          isLocked ? Icons.lock_rounded : Icons.emoji_events_outlined,
          color: isLocked ? colors.onSurfaceVariant : colors.primary,
        ),
        label: Text(
          isLocked ? 'Contenido Premium' : 'Ver Ranking',
          style: TextStyle(
            color: isLocked ? colors.onSurfaceVariant : colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _navigateToRanking(BuildContext context) {
    if (topic.id == null) return;

    // Encode el nombre del topic para URL
    final encodedTopicName = Uri.encodeComponent(topic.topicName);

    // Navegar usando path parameters
    context.push('${AppRoutes.ranking}/${topic.id}/$encodedTopicName');
  }
}

class _GroupRankingButton extends StatelessWidget {
  const _GroupRankingButton({
    required this.topicGroup,
    required this.isLocked,
  });

  final TopicGroup topicGroup;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLocked ? null : () => _navigateToGroupRanking(context),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: colors.primary,
          side: BorderSide(
            color: isLocked
                ? colors.outlineVariant
                : colors.primary.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(
          isLocked ? Icons.lock_rounded : Icons.emoji_events_outlined,
          color: isLocked ? colors.onSurfaceVariant : colors.primary,
        ),
        label: Text(
          isLocked ? 'Contenido Premium' : 'Ver Ranking',
          style: TextStyle(
            color: isLocked ? colors.onSurfaceVariant : colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _navigateToGroupRanking(BuildContext context) {
    if (topicGroup.id == null) return;

    // Navegar solo con el ID, sin pasar el nombre en la URL
    // para evitar problemas con caracteres especiales
    context.push('${AppRoutes.groupRanking}/${topicGroup.id}');
  }
}

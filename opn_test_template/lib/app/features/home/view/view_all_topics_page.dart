import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_template/app/authentification/auth/cubit/auth_cubit.dart';
import 'package:opn_test_template/app/config/widgets/app_bar/app_bar_menu.dart';
import 'package:opn_test_template/app/config/widgets/premium/premium_content.dart';
import 'package:opn_test_template/app/features/topics/model/topic_model.dart';
import 'package:opn_test_template/app/features/topics/model/topic_group_model.dart';
import 'package:opn_test_template/app/features/topics/model/topic_or_group.dart';
import 'package:opn_test_template/app/features/topics/view/preview_topic_page.dart';

import '../../../config/service_locator.dart';
import '../../topics/repository/topic_repository.dart';

class ViewAllTopicsPage extends StatefulWidget {
  const ViewAllTopicsPage({
    super.key,
    this.topicTypeId,
    this.title,
  });

  final int? topicTypeId;
  final String? title;

  @override
  State<ViewAllTopicsPage> createState() => _ViewAllTopicsPageState();
}

class _ViewAllTopicsPageState extends State<ViewAllTopicsPage> {
  final _searchController = TextEditingController();
  final _repo = getIt<TopicRepository>();

  List<TopicOrGroup> _items = const [];
  bool _loading = true;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTopics({String query = ''}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = context.read<AuthCubit>().state.user;
      final academyId = user.academyId;
      final specialtyId = user.specialtyId;

      // Cargar topics y grupos filtrados por especialidad
      final topics = await _repo.searchTopics(
        query,
        academyId: academyId,
        specialtyId: specialtyId,
        topicTypeId: widget.topicTypeId,
      );

      // Separar topics con grupo y sin grupo
      final topicsWithoutGroup = topics.where((t) => t.topicGroupId == null).toList();
      final topicsWithGroup = topics.where((t) => t.topicGroupId != null).toList();

      // Agrupar topics por topic_group_id
      final groupMap = <int, List<Topic>>{};
      for (final topic in topicsWithGroup) {
        final groupId = topic.topicGroupId!;
        groupMap.putIfAbsent(groupId, () => []).add(topic);
      }

      // Crear items (mezclar topics sin grupo y grupos)
      final items = <TopicOrGroup>[
        ...topicsWithoutGroup.map((t) => TopicOrGroup.topic(t)),
      ];

      // Cargar información de los grupos y agregarlos
      for (final groupId in groupMap.keys) {
        try {
          // Obtener el topic group desde Supabase
          final topicGroup = await _repo.fetchTopicGroupById(groupId);
          if (topicGroup != null) {
            final groupTopics = groupMap[groupId]!;
            items.add(TopicOrGroup.group(topicGroup, groupTopics.length));
          } else {
            // Si no se encuentra el grupo, mostrar topics individuales
            items.addAll(groupMap[groupId]!.map((t) => TopicOrGroup.topic(t)));
          }
        } catch (e) {
          // Si falla cargar el grupo, mostrar topics individuales
          items.addAll(groupMap[groupId]!.map((t) => TopicOrGroup.topic(t)));
        }
      }

      // Ordenar por published_at (más recientes primero)
      items.sort((a, b) {
        final aDate = a.publishedAt;
        final bDate = b.publishedAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _items = const [];
        _loading = false;
        _error = 'No se pudieron cargar los temarios. Intenta de nuevo.';
      });
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _loadTopics(query: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = widget.title ?? 'Todos los test';

    return Scaffold(
      appBar: AppBarMenu(title: title),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Buscar test por nombre',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildBody(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: colors.error, size: 40),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _loadTopics(query: _searchController.text),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron test.',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _items[index];

        if (item.isGroup) {
          return _TopicGroupTile(
            topicGroup: item.topicGroup!,
            topicCount: item.topicCount ?? 0,
          );
        } else {
          return _TopicTile(topic: item.topic!);
        }
      },
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PremiumContent(
      requiresPremium: topic.isPremium,
      onPressed: () {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('Contenido Premium. Desbloquea tu acceso para continuar.'),
            ),
          );
      },
      child: Material(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PreviewTopicPage(topic: topic),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        topic.topicName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: colors.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _InfoChip(
                      icon: Icons.timer_outlined,
                      label: '${topic.durationMinutes} min',
                    ),
                    _InfoChip(
                      icon: Icons.help_outline,
                      label: '${topic.totalQuestions} preguntas',
                    ),
                    if (topic.totalParticipants > 0)
                      _InfoChip(
                        icon: Icons.groups_outlined,
                        label: '${topic.totalParticipants} participantes',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicGroupTile extends StatelessWidget {
  const _TopicGroupTile({required this.topicGroup, required this.topicCount});

  final TopicGroup topicGroup;
  final int topicCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colors.tertiary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PreviewTopicPage(topicGroup: topicGroup),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.tertiary.withValues(alpha: 0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.layers_rounded,
                      size: 20,
                      color: colors.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        topicGroup.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: colors.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _InfoChip(
                      icon: Icons.topic,
                      label: '$topicCount partes',
                      color: colors.tertiary,
                    ),
                    _InfoChip(
                      icon: Icons.timer_outlined,
                      label: '${topicGroup.durationMinutes} min',
                      color: colors.tertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final chipColor = color ?? colors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: chipColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

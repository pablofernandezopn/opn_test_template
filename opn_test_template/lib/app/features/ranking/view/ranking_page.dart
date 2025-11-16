import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/service_locator.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../cubit/ranking_cubit.dart';
import '../cubit/ranking_state.dart';
import '../model/ranking_entry_model.dart';

class RankingPage extends StatelessWidget {
  final int topicId;
  final String topicName;

  const RankingPage({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user.id;

    return BlocProvider(
      create: (_) => RankingCubit(
        getIt(),
        userId: userId,
      )..loadTopicRanking(topicId: topicId),
      child: _RankingPageContent(topicName: topicName),
    );
  }
}

class _RankingPageContent extends StatefulWidget {
  final String topicName;

  const _RankingPageContent({required this.topicName});

  @override
  State<_RankingPageContent> createState() => _RankingPageContentState();
}

class _RankingPageContentState extends State<_RankingPageContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<RankingCubit>().loadMoreEntries();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ranking',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.topicName,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<RankingCubit, RankingState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Error al cargar el ranking',
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.read<RankingCubit>().refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (!state.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay participantes en este ranking',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<RankingCubit>().refresh(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // User entry (si existe y no está en el top)
                if (state.userEntry != null &&
                    (state.userEntry!.rankPosition ?? 0) > 10)
                  SliverToBoxAdapter(
                    child: _UserRankingCard(entry: state.userEntry!),
                  ),

                // Header con información
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Posición',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${state.totalParticipants} participantes',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Lista del ranking
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= state.entries.length) {
                          return null;
                        }

                        final entry = state.entries[index];
                        final isCurrentUser =
                            entry.userId == state.userEntry?.userId;

                        return _RankingListItem(
                          entry: entry,
                          isCurrentUser: isCurrentUser,
                        );
                      },
                      childCount: state.entries.length,
                    ),
                  ),
                ),

                // Loading indicator para más entradas
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),

                // Espaciado final
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Card que muestra la posición del usuario actual
class _UserRankingCard extends StatelessWidget {
  final RankingEntry entry;

  const _UserRankingCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer,
            colors.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: colors.primary,
            backgroundImage: entry.profileImage != null
                ? NetworkImage(entry.profileImage!)
                : null,
            child: entry.profileImage == null
                ? Text(
                    entry.displayNameOrUsername[0].toUpperCase(),
                    style: textTheme.headlineSmall?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu posición',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.displayNameOrUsername,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.firstScore.toStringAsFixed(1)} pts',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Posición
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '#${entry.rankPosition ?? '-'}',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
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

/// Item de la lista del ranking
class _RankingListItem extends StatelessWidget {
  final RankingEntry entry;
  final bool isCurrentUser;

  const _RankingListItem({
    required this.entry,
    required this.isCurrentUser,
  });

  Color _getRankColor(BuildContext context, int? rank) {
    final colors = Theme.of(context).colorScheme;
    if (rank == null) return colors.onSurfaceVariant;

    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return colors.onSurfaceVariant;
    }
  }

  IconData _getRankIcon(int? rank) {
    if (rank == null) return Icons.emoji_events_outlined;

    switch (rank) {
      case 1:
      case 2:
      case 3:
        return Icons.emoji_events;
      default:
        return Icons.emoji_events_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final rankColor = _getRankColor(context, entry.rankPosition);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? colors.primaryContainer.withValues(alpha: 0.3)
            : colors.surface,
        border: Border.all(
          color: isCurrentUser
              ? colors.primary.withValues(alpha: 0.5)
              : colors.outlineVariant,
          width: isCurrentUser ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Posición
          SizedBox(
            width: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getRankIcon(entry.rankPosition),
                  color: rankColor,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.rankPosition ?? '-'}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: rankColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.primaryContainer,
            backgroundImage: entry.profileImage != null
                ? NetworkImage(entry.profileImage!)
                : null,
            child: entry.profileImage == null
                ? Text(
                    entry.displayNameOrUsername[0].toUpperCase(),
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayNameOrUsername,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.attempts} ${entry.attempts == 1 ? 'intento' : 'intentos'}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Puntuación
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.firstScore.toStringAsFixed(1),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              if (entry.bestScore > entry.firstScore)
                Text(
                  'Mejor: ${entry.bestScore.toStringAsFixed(1)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
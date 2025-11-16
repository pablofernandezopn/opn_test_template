import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../config/go_route/app_routes.dart';
import '../../../config/widgets/table/groupable_table.dart';
import '../../../config/widgets/buttons/modern_icon_button.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';
import '../model/challenge_model.dart';

/// Página de gestión de impugnaciones con agrupación por pregunta.
///
/// Muestra una tabla agrupada con todas las impugnaciones y permite:
/// - Ver impugnaciones agrupadas por pregunta
/// - Scroll infinito para cargar más datos
/// - Filtrar por estado
/// - Expandir/colapsar grupos
/// - Ver detalles de cada impugnación
class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  static const String route = '/challenges';

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      context.read<ChallengeCubit>().updateSearchQuery(_searchController.text);
    });
  }

  void _onScroll() {
    final state = context.read<ChallengeCubit>().state;

    // Solo cargar si no está ya cargando y hay más datos disponibles
    if (_isBottom && !state.isLoadingMore && state.hasMore) {
      context.read<ChallengeCubit>().loadMoreChallenges();
    }
  }

  Future<void> _loadData() async {
    context.read<ChallengeCubit>().initialFetch();
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Cargar cuando esté a 200 pixels del final para mejor UX
    return currentScroll >= (maxScroll - 200);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impugnaciones'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ModernIconButton(
              icon: Icons.refresh,
              tooltip: 'Actualizar',
              onPressed: () =>
                  context.read<ChallengeCubit>().refreshChallenges(),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<ChallengeCubit, ChallengeState>(
        builder: (context, state) {
          if (state.fetchStatus.isLoading && state.challenges.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.fetchStatus.isError && state.challenges.isEmpty) {
            return _buildErrorView(context, state.fetchStatus.message);
          }

          return _buildContent(context, state);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ChallengeState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con información
          _buildHeader(context, state),

          const SizedBox(height: 24),

          // Barra de búsqueda
          _buildSearchBar(context),

          const SizedBox(height: 16),

          // Filtros
          _buildFilters(context, state),

          const SizedBox(height: 24),

          // Estadísticas rápidas
          _buildStatsCards(context, state),

          const SizedBox(height: 24),

          // Tabla agrupada por tema y pregunta con scroll infinito
          Expanded(
            child: Card(
              child: _buildTableOrEmpty(context, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChallengeState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.error.withOpacity(0.1),
                colorScheme.error.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.error.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.flag,
            color: colorScheme.error,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestión de Impugnaciones',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _buildDynamicSummary(state),
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

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar por usuario, razón, respuesta, pregunta...',
        prefixIcon: Icon(Icons.search, color: colorScheme.primary),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, ChallengeState state) {
    final cubit = context.read<ChallengeCubit>();

    final segments = <ButtonSegment<ChallengeStatus?>>[
      const ButtonSegment(
        value: null,
        label: Text('Pendientes'),
        icon: Icon(Icons.pending_actions, size: 16),
      ),
      ...ChallengeStatus.values
          .where((status) => !status.isPending)
          .map((status) => ButtonSegment(
                value: status,
                label: Text(status.label),
                icon: Icon(status.icon, size: 16),
              )),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SegmentedButton<ChallengeStatus?>(
          segments: segments,
          selected: {state.statusFilter},
          onSelectionChanged: (Set<ChallengeStatus?> selected) {
            final status = selected.first;
            if (status == null) {
              cubit.loadPendingChallenges();
            } else {
              cubit.filterByStatus(status);
            }
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
          ),
        ),
        if (state.statusFilter != null)
          OutlinedButton.icon(
            onPressed: () => cubit.clearFilters(),
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Limpiar filtros'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
      ],
    );
  }

  Widget _buildStatsCards(BuildContext context, ChallengeState state) {
    final statCards = ChallengeStatus.values.map((status) {
      return Expanded(
        child: _buildStatCard(
          context,
          title: status.label,
          value: state.stats[status.statsKey]?.toString() ?? '0',
          icon: status.icon,
          color: status.color,
        ),
      );
    }).toList();

    final cardsWithSeparators = <Widget>[];
    for (var i = 0; i < statCards.length; i++) {
      cardsWithSeparators.add(statCards[i]);
      if (i < statCards.length - 1) {
        cardsWithSeparators.add(const SizedBox(width: 12));
      }
    }

    return Row(children: cardsWithSeparators);
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableOrEmpty(BuildContext context, ChallengeState state) {
    // Filtrar impugnaciones según el término de búsqueda
    final filteredChallenges = state.searchQuery.isEmpty
        ? state.challenges
        : state.challenges.where((challenge) {
            final query = state.searchQuery.toLowerCase();
            return (challenge.userName?.toLowerCase().contains(query) ?? false) ||
                (challenge.userEmail?.toLowerCase().contains(query) ?? false) ||
                (challenge.reason?.toLowerCase().contains(query) ?? false) ||
                (challenge.reply.toLowerCase().contains(query)) ||
                (challenge.questionText?.toLowerCase().contains(query) ?? false) ||
                (challenge.academyName?.toLowerCase().contains(query) ?? false) ||
                (challenge.editorName?.toLowerCase().contains(query) ?? false);
          }).toList();

    if (filteredChallenges.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildNestedGroupedView(context, state, filteredChallenges);
  }

  /// Construye la vista con agrupación por pregunta y scroll infinito
  Widget _buildNestedGroupedView(
    BuildContext context,
    ChallengeState state,
    List<Challenge> filteredChallenges,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Expanded(
          child: GroupableTable<Challenge>(
            items: filteredChallenges,
            columns: _buildColumns(context),
            groupByGetter: (challenge) =>
                challenge.questionId?.toString() ?? 'sin-pregunta',
            scrollController: _scrollController,
            groupHeaderBuilder: (groupId, items) {
              final firstChallenge = items.first;
              final questionText =
                  firstChallenge.questionText ?? 'Pregunta #$groupId';
              final questionId = firstChallenge.questionId;

              return InkWell(
                onTap: () {
                  if (questionId != null) {
                    context.push(AppRoutes.challengesAggregated(questionId));
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        questionText,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.open_in_new,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              );
            },
            onItemTap: (challenge) {
              if (challenge.id != null) {
                context.push(AppRoutes.challengeDetail(challenge.id!));
              }
            },
            // rowActions: (challenge) => [
            //   IconButton(
            //     onPressed: () {
            //       if (challenge.id != null) {
            //         context.push(AppRoutes.challengeDetail(challenge.id!));
            //       }
            //     },
            //     icon: const Icon(Icons.open_in_new),
            //     tooltip: 'Abrir detalle',
            //     iconSize: 20,
            //   ),
            // ],
            isLoading: false,
            emptyMessage: 'No hay impugnaciones disponibles',
            initiallyExpanded: true,
            showItemCount: true,
          ),
        ),
        if (state.isLoadingMore) _buildLoadingIndicator(state),
      ],
    );
  }

  Widget _buildLoadingIndicator(ChallengeState state) {
    if (!state.isLoadingMore) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Cargando más impugnaciones...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = context.read<ChallengeCubit>().state;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              state.searchQuery.isEmpty
                  ? Icons.inbox_outlined
                  : Icons.search_off,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              state.searchQuery.isEmpty
                  ? 'No hay impugnaciones'
                  : 'No se encontraron resultados',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.searchQuery.isEmpty
                  ? 'No se encontraron impugnaciones con los filtros seleccionados'
                  : 'No hay impugnaciones que coincidan con "${state.searchQuery}"',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar impugnaciones',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  context.read<ChallengeCubit>().refreshChallenges(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  String _buildDynamicSummary(ChallengeState state) {
    final summaryParts = <String>['Total: ${state.totalChallenges}'];

    for (final status in ChallengeStatus.values) {
      final count = state.getCountForStatus(status);
      summaryParts.add('${status.label}: $count');
    }

    return summaryParts.join(' | ');
  }

  List<GroupableTableColumnConfig<Challenge>> _buildColumns(
      BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return [
      GroupableTableColumnConfig<Challenge>(
        id: 'estado',
        label: 'Estado',
        flex: 1,
        valueGetter: (challenge) => challenge.state.label,
        cellBuilder: (challenge) => _buildStatusChip(context, challenge.state),
      ),
      GroupableTableColumnConfig<Challenge>(
        id: 'usuario',
        label: 'Usuario',
        flex: 2,
        valueGetter: (challenge) =>
            challenge.userName ?? challenge.userEmail ?? '-',
        cellBuilder: (challenge) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge.userName ?? challenge.userEmail ?? '-',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (challenge.academyName != null)
              Text(
                challenge.academyName!,
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
      GroupableTableColumnConfig<Challenge>(
        id: 'razon',
        label: 'Razón',
        flex: 3,
        valueGetter: (challenge) => challenge.reason ?? '',
        cellBuilder: (challenge) => Text(
          challenge.reason ?? '',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      GroupableTableColumnConfig<Challenge>(
        id: 'respuesta',
        label: 'Respuesta',
        flex: 3,
        valueGetter: (challenge) => challenge.reply,
        cellBuilder: (challenge) => Text(
          challenge.reply.isEmpty ? '-' : challenge.reply,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: challenge.reply.isEmpty
                ? colorScheme.onSurfaceVariant.withOpacity(0.5)
                : colorScheme.onSurface,
          ),
        ),
      ),
      GroupableTableColumnConfig<Challenge>(
        id: 'fecha',
        label: 'Fecha',
        flex: 1,
        valueGetter: (challenge) => challenge.createdAt != null
            ? dateFormat.format(challenge.createdAt!)
            : '-',
        cellBuilder: (challenge) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge.createdAt != null
                  ? dateFormat.format(challenge.createdAt!)
                  : '-',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              '${challenge.daysOld} días',
              style: TextStyle(
                fontSize: 10,
                color: challenge.daysOld > 7
                    ? colorScheme.error
                    : colorScheme.onSurfaceVariant,
                fontWeight:
                    challenge.daysOld > 7 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      GroupableTableColumnConfig<Challenge>(
        id: 'editor',
        label: 'Editor',
        flex: 2,
        valueGetter: (challenge) => challenge.editorName ?? '-',
        cellBuilder: (challenge) => Text(
          challenge.editorName ?? '-',
          style: TextStyle(
            fontSize: 12,
            color: challenge.editorName == null
                ? colorScheme.onSurfaceVariant.withOpacity(0.5)
                : colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];
  }

  Widget _buildStatusChip(BuildContext context, ChallengeStatus state) {
    return Chip(
      label: Text(state.label),
      backgroundColor: state.color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: state.color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

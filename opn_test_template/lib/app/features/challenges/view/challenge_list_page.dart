import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/challenge_cubit.dart';
import '../cubit/challenge_state.dart';
import 'components/challenge_list_item.dart';

class ChallengeListPage extends StatefulWidget {
  const ChallengeListPage({super.key});

  @override
  State<ChallengeListPage> createState() => _ChallengeListPageState();
}

class _ChallengeListPageState extends State<ChallengeListPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Cargar impugnaciones cuando se navega a la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeCubit>().fetchChallenges();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ChallengeCubit>().loadMoreChallenges();
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Impugnaciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<ChallengeCubit, ChallengeState>(
        builder: (context, state) {
          // Estado de carga inicial
          if (state.fetchChallengesStatus.isLoading && state.challenges.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Estado de error
          if (state.fetchChallengesStatus.isError && state.challenges.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar las impugnaciones',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error ?? 'Error desconocido',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.read<ChallengeCubit>().refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Lista vacía
          if (state.challenges.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.gavel_rounded,
                      size: 64,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes impugnaciones',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cuando encuentres un error en una pregunta, podrás impugnarla desde el test.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Lista con datos
          return RefreshIndicator(
            onRefresh: () => context.read<ChallengeCubit>().refresh(),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: state.challenges.length + (state.hasMoreData ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                // Mostrar indicador de carga al final
                if (index >= state.challenges.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: state.loadMoreStatus.isLoading
                          ? const CircularProgressIndicator()
                          : const SizedBox.shrink(),
                    ),
                  );
                }

                final challenge = state.challenges[index];
                return ChallengeListItem(challenge: challenge);
              },
            ),
          );
        },
      ),
    );
  }
}
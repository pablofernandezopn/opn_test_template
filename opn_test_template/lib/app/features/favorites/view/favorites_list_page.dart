import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../config/go_route/app_routes.dart';
import '../../../config/service_locator.dart';
import '../../questions/model/question_model.dart';
import '../../questions/repository/repository.dart';
import '../cubit/favorite_cubit.dart';
import '../cubit/favorite_state.dart';

class FavoritesListPage extends StatefulWidget {
  const FavoritesListPage({super.key});

  static const String route = '/favorites';

  @override
  State<FavoritesListPage> createState() => _FavoritesListPageState();
}

class _FavoritesListPageState extends State<FavoritesListPage> {
  final _questionRepository = getIt<QuestionRepository>();
  List<Question> _questions = [];
  bool _loadingQuestions = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.state.user;

    if (user.id == 0) {
      setState(() {
        _loadingQuestions = false;
      });
      return;
    }

    final favoriteCubit = context.read<FavoriteCubit>();
    await favoriteCubit.loadFavorites(user.id);

    if (!mounted) return;

    final favoriteIds = favoriteCubit.state.favoriteQuestionIds.toList();

    if (favoriteIds.isEmpty) {
      setState(() {
        _loadingQuestions = false;
      });
      return;
    }

    // Cargar las preguntas completas usando los IDs
    try {
      final allQuestions = await _questionRepository.fetchQuestions();
      final favoriteQuestions = allQuestions
          .where((q) => favoriteIds.contains(q.id))
          .toList();

      if (!mounted) return;

      setState(() {
        _questions = favoriteQuestions;
        _loadingQuestions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingQuestions = false;
      });
    }
  }

  Future<void> _removeFavorite(int questionId) async {
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.state.user;

    final favoriteCubit = context.read<FavoriteCubit>();
    final success = await favoriteCubit.removeFavorite(user.id, questionId);

    if (!mounted) return;

    if (success) {
      setState(() {
        _questions.removeWhere((q) => q.id == questionId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pregunta eliminada de favoritos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preguntas Favoritas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
          ),
        ],
      ),
      body: BlocBuilder<FavoriteCubit, FavoriteState>(
        builder: (context, state) {
          if (state.status == FavoriteStatus.loading || _loadingQuestions) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == FavoriteStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loadFavorites,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_questions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_border,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No tienes preguntas favoritas',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Marca preguntas como favoritas desde los tests para acceder a ellas rápidamente',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _questions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final question = _questions[index];
              return _QuestionCard(
                question: question,
                index: index,
                onTap: () {
                  context.push(
                    '${AppRoutes.favoriteQuestion}?id=${question.id}',
                  );
                },
                onRemove: () => _removeFavorite(question.id!),
              );
            },
          );
        },
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.index,
    required this.onTap,
    required this.onRemove,
  });

  final Question question;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.question.trim().isEmpty
                          ? 'Pregunta sin enunciado'
                          : question.question,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (question.tip != null && question.tip!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 14,
                            color: colors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tiene tip',
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.star, color: colors.primary),
                onPressed: onRemove,
                tooltip: 'Eliminar de favoritos',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
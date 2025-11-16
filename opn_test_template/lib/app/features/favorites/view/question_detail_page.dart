import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../config/service_locator.dart';
import '../../../core/utils/question_utils.dart';
import '../../questions/model/question_model.dart';
import '../../questions/model/question_option_model.dart';
import '../../questions/repository/repository.dart';
import '../cubit/favorite_cubit.dart';
import '../cubit/favorite_state.dart';

class QuestionDetailPage extends StatefulWidget {
  const QuestionDetailPage({
    super.key,
    required this.questionId,
  });

  final int questionId;

  static const String route = '/favorite-question';

  @override
  State<QuestionDetailPage> createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends State<QuestionDetailPage> {
  final _questionRepository = getIt<QuestionRepository>();
  Question? _question;
  List<QuestionOption> _options = [];
  bool _loading = true;
  String? _error;
  bool _showAnswer = false;
  int? _selectedOptionId;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final questions = await _questionRepository.fetchQuestions();
      final question = questions.firstWhere(
        (q) => q.id == widget.questionId,
        orElse: () => throw Exception('Pregunta no encontrada'),
      );

      final options = await _questionRepository.fetchQuestionOptions(widget.questionId);

      // Aplicar shuffle si la pregunta lo requiere, o mantener orden original
      final orderedOptions = sortOrShuffleOptions(
        options,
        shouldShuffle: question.shuffled,
        isFlashcardMode: false,
      );

      if (!mounted) return;

      setState(() {
        _question = question;
        _options = orderedOptions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar la pregunta';
        _loading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_question == null) return;

    final authCubit = context.read<AuthCubit>();
    final user = authCubit.state.user;
    final favoriteCubit = context.read<FavoriteCubit>();

    final success = await favoriteCubit.toggleFavorite(user.id, widget.questionId);

    if (!mounted) return;

    if (success) {
      final isFavorite = favoriteCubit.isFavorite(widget.questionId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? 'Pregunta añadida a favoritos'
                : 'Pregunta eliminada de favoritos',
          ),
        ),
      );

      // Si se eliminó de favoritos, volver atrás
      if (!isFavorite && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Pregunta'),
        actions: [
          if (_question != null)
            BlocBuilder<FavoriteCubit, FavoriteState>(
              builder: (context, state) {
                final isFavorite = state.favoriteQuestionIds.contains(widget.questionId);
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? colors.primary : null,
                  ),
                  onPressed: _toggleFavorite,
                  tooltip: isFavorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
                );
              },
            ),
        ],
      ),
      body: _buildBody(colors, textTheme),
    );
  }

  Widget _buildBody(ColorScheme colors, TextTheme textTheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _question == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: colors.error),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Error desconocido',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadQuestion,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enunciado de la pregunta
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.help_outline, color: colors.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Pregunta',
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _question!.question.trim().isEmpty
                      ? 'Pregunta sin enunciado'
                      : _question!.question,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Imagen de la pregunta
          if (_question!.questionImageUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _question!.questionImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: colors.surfaceContainerLow,
                  alignment: Alignment.center,
                  child: Icon(Icons.image_not_supported_outlined,
                      color: colors.onSurfaceVariant),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Opciones
          Text(
            'Opciones',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          if (_options.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No hay opciones disponibles para esta pregunta.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < _options.length; i++) ...[
                  _OptionTile(
                    index: i,
                    option: _options[i],
                    selected: _selectedOptionId == _options[i].id,
                    showAnswer: _showAnswer,
                    onTap: _options[i].id == null
                        ? null
                        : () {
                            setState(() {
                              _selectedOptionId = _options[i].id;
                            });
                          },
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),

          const SizedBox(height: 24),

          // Botón para mostrar respuesta
          Center(
            child: FilledButton.icon(
              onPressed: () {
                setState(() {
                  _showAnswer = !_showAnswer;
                });
              },
              icon: Icon(_showAnswer ? Icons.visibility_off : Icons.visibility),
              label: Text(_showAnswer ? 'Ocultar respuesta' : 'Ver respuesta'),
            ),
          ),

          // Tip
          if (_question!.tip != null && _question!.tip!.isNotEmpty && _showAnswer) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.secondaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.secondary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: colors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tip',
                        style: textTheme.titleSmall?.copyWith(
                          color: colors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _question!.tip!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.index,
    required this.option,
    required this.selected,
    required this.showAnswer,
    this.onTap,
  });

  final int index;
  final QuestionOption option;
  final bool selected;
  final bool showAnswer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final letter = String.fromCharCode('A'.codeUnitAt(0) + index);

    Color borderColor;
    Color backgroundColor;
    Color letterBgColor;
    Color letterColor;
    IconData? resultIcon;
    Color? resultIconColor;

    final successColor = const Color(0xFF4CAF50);
    final errorColor = colors.error;

    if (showAnswer) {
      if (option.isCorrect) {
        borderColor = successColor;
        backgroundColor = successColor.withOpacity(0.1);
        letterBgColor = successColor;
        letterColor = colors.surface;
        resultIcon = Icons.check_circle;
        resultIconColor = successColor;
      } else if (selected) {
        borderColor = errorColor;
        backgroundColor = errorColor.withOpacity(0.1);
        letterBgColor = errorColor;
        letterColor = colors.surface;
        resultIcon = Icons.cancel;
        resultIconColor = errorColor;
      } else {
        borderColor = colors.outlineVariant;
        backgroundColor = colors.surfaceContainerLowest;
        letterBgColor = Colors.transparent;
        letterColor = colors.onSurfaceVariant;
      }
    } else {
      if (selected) {
        borderColor = colors.primary;
        backgroundColor = colors.primary.withOpacity(0.08);
        letterBgColor = colors.primary;
        letterColor = colors.onPrimary;
      } else {
        borderColor = colors.outlineVariant;
        backgroundColor = colors.surfaceContainerLowest;
        letterBgColor = Colors.transparent;
        letterColor = colors.onSurface;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: selected || (showAnswer && option.isCorrect) ? 2 : 1,
          ),
          color: backgroundColor,
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: showAnswer && !option.isCorrect && !selected
                      ? colors.onSurfaceVariant
                      : (showAnswer && option.isCorrect)
                          ? successColor
                          : (selected && showAnswer)
                              ? errorColor
                              : selected
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                ),
                color: letterBgColor,
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: textTheme.bodyMedium?.copyWith(
                  color: letterColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.answer,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ),
            if (showAnswer && resultIcon != null) ...[
              const SizedBox(width: 8),
              Icon(
                resultIcon,
                color: resultIconColor,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
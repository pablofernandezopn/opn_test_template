import 'package:flutter/material.dart';
import '../../questions/model/question_model.dart';
import '../../questions/model/question_option_model.dart';

// ============================================
// PANEL EXPANDIBLE DE PREGUNTA (desde arriba)
// ============================================

class ExpandableQuestionPanel extends StatefulWidget {
  const ExpandableQuestionPanel({
    super.key,
    required this.question,
    required this.options,
    this.selectedOptionId,
  });

  final Question question;
  final List<QuestionOption> options;
  final int? selectedOptionId;

  @override
  State<ExpandableQuestionPanel> createState() => _ExpandableQuestionPanelState();
}

class _ExpandableQuestionPanelState extends State<ExpandableQuestionPanel>
    with SingleTickerProviderStateMixin {
  late double _panelHeight;
  final double _visibleTabHeight = 50; // Altura del tab cuando está cerrado
  bool _isOpen = false;
  late double _topPosition;
  double _initialY = 0;
  double _initialTop = 0;
  late AnimationController _animationController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    // Calcular altura del panel según tamaño de pantalla
    if (screenHeight < 600) {
      _panelHeight = screenHeight * 0.8;
    } else if (screenHeight < 800) {
      _panelHeight = screenHeight * 0.7;
    } else {
      _panelHeight = screenHeight - 200;
    }

    // Posición inicial: panel cerrado (solo tab visible en la parte superior)
    // El AppBar ocupa 64px, el tab debe estar justo debajo
    _topPosition = 64 + _visibleTabHeight - _panelHeight;
  }

  void _togglePanel() {
    setState(() {
      _isOpen = !_isOpen;
      FocusScope.of(context).unfocus();
    });
    // Abierto: panel justo debajo del AppBar (64px)
    // Cerrado: solo el tab visible
    final openPosition = 64.0;
    final closedPosition = 64.0 + _visibleTabHeight - _panelHeight;
    _animateToPosition(_isOpen ? openPosition : closedPosition);
  }

  void _animateToPosition(double targetPosition) {
    _animationController.reset();

    final tween = Tween<double>(
      begin: _topPosition,
      end: targetPosition,
    );

    final animation = tween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    animation.addListener(() {
      setState(() {
        _topPosition = animation.value;
      });
    });

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      top: _topPosition,
      left: 16,
      right: 16,
      height: _panelHeight,
      child: GestureDetector(
        onTap: _togglePanel,
        onVerticalDragStart: (details) {
          _animationController.stop();
          _initialY = details.globalPosition.dy;
          _initialTop = _topPosition;
        },
        onVerticalDragUpdate: (details) {
          FocusScope.of(context).unfocus();
          final delta = details.globalPosition.dy - _initialY;
          double newTop = _initialTop + delta;

          final openPosition = 64.0;
          final closedPosition = 64.0 + _visibleTabHeight - _panelHeight;
          newTop = newTop.clamp(closedPosition, openPosition);

          setState(() {
            _topPosition = newTop;
          });
        },
        onVerticalDragEnd: (details) {
          final openPosition = 64.0;
          final closedPosition = 64.0 + _visibleTabHeight - _panelHeight;

          // Calcular el punto medio entre abierto y cerrado
          final midPoint = (openPosition + closedPosition) / 2;

          // Si está por encima del punto medio (más cerca de abierto), abrir
          // Si está por debajo del punto medio (más cerca de cerrado), cerrar
          if (_topPosition < midPoint) {
            // Más cerca de abierto -> abrir
            setState(() {
              _isOpen = true;
            });
            _animateToPosition(openPosition);
          } else {
            // Más cerca de cerrado -> cerrar
            setState(() {
              _isOpen = false;
            });
            _animateToPosition(closedPosition);
          }
        },
        child: Container(
          padding: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.primary, width: 2),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Contenido scrollable de la pregunta
              Expanded(
                child: _QuestionContent(
                  question: widget.question,
                  options: widget.options,
                  scrollController: _scrollController,
                  selectedOptionId: widget.selectedOptionId,
                ),
              ),
              // Tab/Ticket en la parte inferior
              _buildTicket(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicket(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: SizedBox(
        height: 30,
        width: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: colors.primary,
            ),
            const SizedBox(width: 16),
            Text(
              _isOpen ? 'Ocultar pregunta' : 'Ver pregunta',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// CONTENIDO DE LA PREGUNTA
// ============================================

class _QuestionContent extends StatelessWidget {
  const _QuestionContent({
    required this.question,
    required this.options,
    required this.scrollController,
    this.selectedOptionId,
  });

  final Question question;
  final List<QuestionOption> options;
  final ScrollController scrollController;
  final int? selectedOptionId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final successColor = const Color(0xFF4CAF50);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Enunciado de la pregunta
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            question.question.trim().isEmpty
                ? 'Pregunta sin enunciado'
                : question.question,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
              height: 1.5,
            ),
          ),
        ),

        // Imagen de la pregunta (si existe)
        if (question.questionImageUrl.isNotEmpty) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              question.questionImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 160,
                color: colors.surfaceContainerLow,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: colors.onSurfaceVariant,
                  size: 48,
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Opciones
        Text(
          'Opciones:',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        if (options.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No hay opciones disponibles',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          )
        else
          ...List.generate(options.length, (index) {
            final option = options[index];
            final letter = String.fromCharCode('A'.codeUnitAt(0) + index);
            final isCorrect = option.isCorrect;
            final isSelected = selectedOptionId != null && option.id == selectedOptionId;
            final errorColor = colors.error;

            // Determinar colores y estado según si fue seleccionada
            Color borderColor;
            Color backgroundColor;
            Color letterBgColor;
            Color letterColor;
            IconData? resultIcon;
            Color? resultIconColor;

            if (isCorrect) {
              // Opción correcta (siempre verde)
              borderColor = successColor;
              backgroundColor = successColor.withValues(alpha: 0.1);
              letterBgColor = successColor;
              letterColor = Colors.white;
              resultIcon = Icons.check_circle;
              resultIconColor = successColor;
            } else if (isSelected) {
              // Opción incorrecta seleccionada por el usuario (rojo)
              borderColor = errorColor;
              backgroundColor = errorColor.withValues(alpha: 0.1);
              letterBgColor = errorColor;
              letterColor = Colors.white;
              resultIcon = Icons.cancel;
              resultIconColor = errorColor;
            } else {
              // Opción no seleccionada e incorrecta (gris)
              borderColor = colors.outlineVariant;
              backgroundColor = colors.surfaceContainerLowest;
              letterBgColor = colors.surfaceContainerHigh;
              letterColor = colors.onSurface;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor,
                    width: (isCorrect || isSelected) ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Letra de la opción
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: letterBgColor,
                        border: Border.all(
                          color: isCorrect
                              ? successColor
                              : isSelected
                                  ? errorColor
                                  : colors.onSurfaceVariant,
                        ),
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
                    // Texto de la opción
                    Expanded(
                      child: Text(
                        option.answer,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: (isCorrect || isSelected) ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    // Icono de resultado
                    if (resultIcon != null) ...[
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
          }),

        // Retroalimentación/Tip
        if (question.tip != null && question.tip!.trim().isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.tertiary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: colors.tertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Retroalimentación',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  question.tip!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }
}
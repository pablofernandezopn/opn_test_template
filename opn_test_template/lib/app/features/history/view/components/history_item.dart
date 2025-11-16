import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opn_test_template/app/features/history/model/user_test_model.dart';

class HistoryItem extends StatelessWidget {
  const HistoryItem({
    super.key,
    required this.test,
    required this.isFirstOfDay,
    this.showTodayMarker = false,
    this.showTimeline = true,
    this.onTap,
  });

  final UserTest test;
  final bool isFirstOfDay;
  final bool showTodayMarker;
  final bool showTimeline;
  final VoidCallback? onTap;

  String _getWeekday(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Lu';
      case 2:
        return 'Ma';
      case 3:
        return 'Mi';
      case 4:
        return 'Ju';
      case 5:
        return 'Vi';
      case 6:
        return 'Sá';
      case 7:
        return 'Do';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isToday = test.isToday;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Si no se muestra timeline, solo mostrar la card
    if (!showTimeline) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _TestCard(test: test, onTap: onTap, isSmallScreen: isSmallScreen),
      );
    }

    // Tamaños adaptativos
    final badgeSize = isSmallScreen ? 48.0 : 60.0;
    final horizontalSpacing = isSmallScreen ? 12.0 : 16.0;
    final badgeFontSizeSmall = isSmallScreen ? 10.0 : 12.0;
    final badgeFontSizeLarge = isSmallScreen ? 12.0 : 14.0;

    // Mostrar con timeline
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline a la izquierda con badge circular
          Column(
            children: [
              if (isFirstOfDay) ...[
                // Badge circular con día de la semana y número
                Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    color: isToday ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isToday ? colorScheme.primary : colorScheme.surfaceContainerHighest)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getWeekday(test.createdAt ?? DateTime.now()),
                          style: TextStyle(
                            fontSize: badgeFontSizeSmall,
                            color: isToday ? colorScheme.onPrimary : colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${test.createdAt?.day ?? DateTime.now().day}',
                          style: TextStyle(
                            fontSize: badgeFontSizeLarge,
                            color: isToday ? colorScheme.onPrimary : colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Hora
              if (!isFirstOfDay) ...[
                SizedBox(width: badgeSize),
              ],

              // Línea vertical que se extiende
              Container(
                width: 3,
                height: isFirstOfDay ? 100 : 160,
                color: isToday
                    ? colorScheme.primary.withValues(alpha: 0.5)
                    : colorScheme.outlineVariant,
              ),
            ],
          ),

          SizedBox(width: horizontalSpacing),

          // Card del test
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar hora fuera de la card
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _formatTime(test.createdAt ?? DateTime.now()),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _TestCard(test: test, onTap: onTap, isSmallScreen: isSmallScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}

class _TestCard extends StatelessWidget {
  const _TestCard({required this.test, this.onTap, this.isSmallScreen = false});

  final UserTest test;
  final VoidCallback? onTap;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Determinar el color del borde según el tipo de test
    final borderColor = _getBorderColor(test, colorScheme);

    // Tamaños adaptativos
    final horizontalPadding = isSmallScreen ? 10.0 : 12.0;
    final verticalPadding = isSmallScreen ? 8.0 : 10.0;
    final titleFontSize = isSmallScreen ? 14.0 : 16.0;
    final labelFontSize = isSmallScreen ? 11.0 : 12.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primera fila: Tipo de test y puntuación
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tipo de test
              Flexible(
                child: Text(
                  test.specialTopicTitle??'Test de estudio',
                  style: TextStyle(
                    color: borderColor,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              // Badge de "Sin finalizar" si el test no está finalizado
              if (!test.finalized)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : 8,
                    vertical: isSmallScreen ? 3 : 4
                  ),
                  decoration: BoxDecoration(
                    color: test.isSurvivalSessionResumable
                        ? Colors.deepOrange.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    test.isSurvivalSessionResumable ? '🔥 Continuar partida' : 'Continuar',
                    style: TextStyle(
                      color: test.isSurvivalSessionResumable
                          ? Colors.deepOrange.shade900
                          : Colors.orange.shade900,
                      fontSize: isSmallScreen ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              // Icono de flashcard si aplica
              if (test.isFlashcardMode)
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.style,
                    size: isSmallScreen ? 16 : 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
            ],
          ),

          SizedBox(height: isSmallScreen ? 3 : 4),

          // Segunda fila: Estadísticas compactas
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Nota final (siempre visible, con "--" si no está finalizado)
              Row(
                children: [
                  Text(
                    'Nota final:',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    test.finalized && test.score != null
                        ? test.score!.toStringAsFixed(2)
                        : '--',
                    style: TextStyle(
                      color: test.finalized
                          ? _getScoreColor(test.successRate, colorScheme)
                          : colorScheme.onSurfaceVariant,
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 3 : 4),

              // Tasa de error (siempre visible, con "--" si no está finalizado)
              Row(
                children: [
                  Text(
                    'Tasa de error:',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    test.finalized
                        ? '${test.errorRate.toStringAsFixed(0)}%'
                        : '--',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 3 : 4),

              // Stats compactas (siempre visible)
              _buildCompactStats(context),
            ],
          ),

          SizedBox(height: isSmallScreen ? 6 : 8),

          // Barra de progreso coloreada (verde/rojo/gris)
          _buildColoredProgressBar(context),
        ],
      ),
    ),
    );
  }

  Widget _buildCompactStats(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Si el test no está finalizado, mostrar "--" en todos los contadores
    final rightCount = test.finalized ? test.rightQuestions : 0;
    final wrongCount = test.finalized ? test.wrongQuestions : 0;
    final blankCount = test.finalized ? (test.questionCount - test.rightQuestions - test.wrongQuestions) : 0;

    // Formato de fecha adaptativo: corto para pantallas pequeñas
    final dateFormat = isSmallScreen ? 'd/M/y' : "d 'de' MMMM 'de' y";
    final dateFontSize = isSmallScreen ? 10.0 : 12.0;

    return Row(
      children: [
        Flexible(
          child: Text(
            DateFormat(dateFormat, 'es_ES').format(test.createdAt ?? DateTime.now()),
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: dateFontSize,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child:Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatBlock(
                    test.finalized ? rightCount : null,
                    Icons.check,
                    const Color(0xFF4CAF50),
                    context
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 8),
                  _buildStatBlock(
                    test.finalized ? wrongCount : null,
                    Icons.close,
                    colorScheme.error,
                    context
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 8),
                  _buildStatBlock(
                    test.finalized ? blankCount : null,
                    Icons.circle_outlined,
                    colorScheme.onSurfaceVariant,
                    context
                  ),
                ],
              ),

        ),
      ],
    );
  }

  Widget _buildStatBlock(int? value, IconData icon, Color color, BuildContext context) {
    final statFontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 14.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            value != null ? '$value' : '--',
            style: TextStyle(
              color: value != null ? color : Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: statFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: isSmallScreen ? 2 : 4),
          Icon(
            icon,
            size: iconSize,
            color: value != null ? color : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildColoredProgressBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Si el test no está finalizado, mostrar barra vacía
    if (!test.finalized) {
      return Container(
        height: 8,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    // Para tests finalizados, mostrar las estadísticas
    final rightCount = test.rightQuestions;
    final wrongCount = test.wrongQuestions;
    final blankCount = test.questionCount - test.rightQuestions - test.wrongQuestions;
    final totalQuestions = test.questionCount;
    final successColor = const Color(0xFF4CAF50);

    if (totalQuestions == 0) {
      return Container(
        height: 8,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    // Si todas están respondidas, no mostrar fondo gris
    final showBackground = blankCount > 0;

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: showBackground ? colorScheme.surfaceContainerHighest : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children: [
            if (rightCount > 0)
              Expanded(
                flex: rightCount,
                child: Container(color: successColor),
              ),
            if (wrongCount > 0)
              Expanded(
                flex: wrongCount,
                child: Container(color: colorScheme.error),
              ),
            if (blankCount > 0)
              Expanded(
                flex: blankCount,
                child: Container(color: Colors.transparent),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBorderColor(UserTest test, ColorScheme colorScheme) {
    // Modo supervivencia tiene color deepOrange
    if (test.specialTopic == -2) {
      return Colors.deepOrange.withValues(alpha: 0.8);
    }
    // Modo contra reloj tiene color blue
    if (test.specialTopic == -3) {
      return Colors.blue.withValues(alpha: 0.8);
    }
    return colorScheme.primary.withValues(alpha: 0.7);
  }

  Color _getTestTypeColor(UserTest test, ColorScheme colorScheme) {
    return colorScheme.primary;
  }

  Color _getScoreColor(double successRate, ColorScheme colorScheme) {
    if (successRate >= 80) return colorScheme.primary;
    if (successRate >= 60) return colorScheme.tertiary;
    return colorScheme.error;
  }

  String _formatDuration(int millis) {
    final duration = Duration(milliseconds: millis);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
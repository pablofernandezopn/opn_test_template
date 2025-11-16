import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opn_test_template/app/features/history/model/grouped_user_test_model.dart';

/// Widget para mostrar un grupo de tests en el historial
///
/// Muestra información agregada de todos los tests del grupo:
/// - Número de partes
/// - Nota promedio
/// - Tasa de error promedio
/// - Estadísticas totales (correctas, incorrectas, en blanco)
class GroupedHistoryItem extends StatelessWidget {
  const GroupedHistoryItem({
    super.key,
    required this.groupedTest,
    required this.isFirstOfDay,
    this.showTodayMarker = false,
    this.onTap,
  });

  final GroupedUserTest groupedTest;
  final bool isFirstOfDay;
  final bool showTodayMarker;
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
    final isToday = groupedTest.isToday;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Tamaños adaptativos
    final badgeSize = isSmallScreen ? 48.0 : 60.0;
    final horizontalSpacing = isSmallScreen ? 12.0 : 16.0;
    final badgeFontSizeSmall = isSmallScreen ? 10.0 : 12.0;
    final badgeFontSizeLarge = isSmallScreen ? 12.0 : 14.0;

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
                          _getWeekday(groupedTest.createdAt ?? DateTime.now()),
                          style: TextStyle(
                            fontSize: badgeFontSizeSmall,
                            color: isToday ? colorScheme.onPrimary : colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${groupedTest.createdAt?.day ?? DateTime.now().day}',
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

          // Card del test agrupado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar hora fuera de la card
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _formatTime(groupedTest.createdAt ?? DateTime.now()),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _GroupedTestCard(groupedTest: groupedTest, onTap: onTap, isSmallScreen: isSmallScreen),
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

class _GroupedTestCard extends StatelessWidget {
  const _GroupedTestCard({required this.groupedTest, this.onTap, this.isSmallScreen = false});

  final GroupedUserTest groupedTest;
  final VoidCallback? onTap;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Usar el mismo color que tests individuales
    final borderColor = colorScheme.primary.withValues(alpha: 0.7);

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
            // Primera fila: Título del test
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Título del grupo
                Flexible(
                  child: Text(
                    groupedTest.displayTitle,
                    style: TextStyle(
                      color: borderColor,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 3 : 4),

            // Segunda fila: Estadísticas compactas
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Nota final
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
                      groupedTest.averageScore.toStringAsFixed(2),
                      style: TextStyle(
                        color: _getScoreColor(groupedTest.successRate, colorScheme),
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 3 : 4),

                // Tasa de error
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
                      '${groupedTest.averageErrorRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 3 : 4),
                // Stats compactas
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
    final rightCount = groupedTest.totalRightQuestions;
    final wrongCount = groupedTest.totalWrongQuestions;
    final blankCount = groupedTest.totalBlankQuestions;

    // Formato de fecha adaptativo: corto para pantallas pequeñas
    final dateFormat = isSmallScreen ? 'd/M/y' : "d 'de' MMMM 'de' y";
    final dateFontSize = isSmallScreen ? 10.0 : 12.0;

    return Row(
      children: [
        Flexible(
          child: Text(
            DateFormat(dateFormat, 'es_ES').format(groupedTest.createdAt ?? DateTime.now()),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatBlock(rightCount, Icons.check, const Color(0xFF4CAF50), context),
              SizedBox(width: isSmallScreen ? 4 : 8),
              _buildStatBlock(wrongCount, Icons.close, colorScheme.error, context),
              SizedBox(width: isSmallScreen ? 4 : 8),
              _buildStatBlock(blankCount, Icons.circle_outlined, colorScheme.onSurfaceVariant, context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatBlock(int value, IconData icon, Color color, BuildContext context) {
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
            '$value',
            style: TextStyle(
              color: color,
              fontSize: statFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: isSmallScreen ? 2 : 4),
          Icon(icon, size: iconSize, color: color),
        ],
      ),
    );
  }

  Widget _buildColoredProgressBar(BuildContext context) {
    final rightCount = groupedTest.totalRightQuestions;
    final wrongCount = groupedTest.totalWrongQuestions;
    final blankCount = groupedTest.totalBlankQuestions;
    final totalQuestions = groupedTest.totalQuestions;

    final colorScheme = Theme.of(context).colorScheme;
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

  Color _getScoreColor(double successRate, ColorScheme colorScheme) {
    if (successRate >= 80) return colorScheme.primary;
    if (successRate >= 60) return colorScheme.tertiary;
    return colorScheme.error;
  }
}
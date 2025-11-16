import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_guardia_civil_cms/app/config/go_route/app_routes.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_level.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/view/components/edit_topic_type_dialog.dart';

import '../model/topic_type_model.dart';
import 'components/add_topic_type_dialog.dart';

class TestsOverviewScreen extends StatelessWidget {
  const TestsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, state) {
        if (state.fetchStatus.status == Status.loading) {
          return _buildLoadingScreen();
        }

        if (state.fetchStatus.status == Status.error) {
          return _buildErrorScreen(context, state.fetchStatus.message);
        }

        final mockTypes = state.topicTypes
            .where((t) => t.level == TopicLevel.Mock)
            .toList()
          ..sort((a, b) => (a.orderOfAppearance ?? 0).compareTo(b.orderOfAppearance ?? 0));

        final studyTypes = state.topicTypes
            .where((t) => t.level == TopicLevel.Study)
            .toList()
          ..sort((a, b) => (a.orderOfAppearance ?? 0).compareTo(b.orderOfAppearance ?? 0));

        final flashcardTypes = state.topicTypes
            .where((t) => t.level == TopicLevel.Flashcard)
            .toList()
          ..sort((a, b) => (a.orderOfAppearance ?? 0).compareTo(b.orderOfAppearance ?? 0));

        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildSection(
                context: context,
                title: 'Mocks (Exámenes de Simulación)',
                subtitle: 'Exámenes que se mostrarán en la página principal de la app.',
                topicTypes: mockTypes,
                level: TopicLevel.Mock,
              ),
              const SizedBox(height: 32),
              _buildSection(
                context: context,
                title: 'Bloques de Estudio',
                subtitle: 'Baterías de preguntas clasificadas por tema.',
                topicTypes: studyTypes,
                level: TopicLevel.Study,
              ),
              const SizedBox(height: 32),
              _buildSection(
                context: context,
                title: 'Flashcards (Tarjetas de Estudio)',
                subtitle: 'Sistema de repetición espaciada para memorización efectiva.',
                topicTypes: flashcardTypes,
                level: TopicLevel.Flashcard,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<TopicType> topicTypes,
    required TopicLevel level,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.1),
                      colorScheme.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  level == TopicLevel.Mock
                      ? Icons.school
                      : level == TopicLevel.Study
                          ? Icons.menu_book
                          : Icons.style,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (topicTypes.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
          ],
          if (topicTypes.isEmpty)
            const SizedBox(height: 24),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topicTypes.length,
            itemBuilder: (context, index) {
              final topicType = topicTypes[index];
              return Padding(
                key: ValueKey(topicType.id),
                padding: const EdgeInsets.only(bottom: 12),
                child: _TestTypeCard(
                  topicType: topicType,
                  onEdit: () => _showEditTopicTypeDialog(context, topicType),
                  onDelete: () => _showDeleteConfirmationDialog(context, topicType),
                ),
              );
            },

            onReorder: (oldIndex, newIndex) {
              context.read<TopicCubit>().updateTopicTypeOrder(
                    topicTypes: topicTypes,
                    level: level,
                    oldIndex: oldIndex,
                    newIndex: newIndex,
                  );
            },
          ),
          if (topicTypes.isNotEmpty)
            const SizedBox(height: 12),
          _AddTestTypeCard(
            onTap: () => _showAddTopicTypeDialog(context, level),
          ),
        ],
      ),
    );
  }

  void _showAddTopicTypeDialog(BuildContext context, TopicLevel level) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<TopicCubit>(),
        child: AddTopicTypeDialog(level: level),
      ),
    );
  }

  void _showEditTopicTypeDialog(BuildContext context, TopicType topicType) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<TopicCubit>(),
        child: EditTopicTypeDialog(topicType: topicType),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, TopicType topicType) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
              '¿Estás seguro de que quieres eliminar "${topicType.topicTypeName}"? Esta acción es irreversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                context.read<TopicCubit>().deleteTopicType(topicType.id!);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              'Cargando tipos de test...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Scaffold _buildErrorScreen(BuildContext context, String? message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.error.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Error al cargar tipos de test',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    message ?? 'Error desconocido',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.read<TopicCubit>().initialFetch(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddTestTypeCard extends StatefulWidget {
  final VoidCallback onTap;

  const _AddTestTypeCard({required this.onTap});

  @override
  State<_AddTestTypeCard> createState() => _AddTestTypeCardState();
}

class _AddTestTypeCardState extends State<_AddTestTypeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isHovered
                    ? colorScheme.primary.withOpacity(0.5)
                    : colorScheme.outlineVariant,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                color: _isHovered
                  ? colorScheme.primaryContainer.withOpacity(0.1)
                  : Colors.transparent,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 24,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Añadir nuevo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TestTypeCard extends StatefulWidget {
  final TopicType topicType;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TestTypeCard({
    super.key,
    required this.topicType,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_TestTypeCard> createState() => _TestTypeCardState();
}

class _TestTypeCardState extends State<_TestTypeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_isHovered ? 1.01 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _isHovered
                  ? colorScheme.primary.withOpacity(0.3)
                  : colorScheme.outlineVariant.withOpacity(0.5),
              width: _isHovered ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              context.go('${AppRoutes.tests_overview}/${widget.topicType.id}');
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [

                  // Icono del tipo de test
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withValues(alpha: _isHovered ? 0.15 : 0.1),
                          colorScheme.primary.withValues(alpha: _isHovered ? 0.1 : 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: _isHovered ? 0.3 : 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _getIconForTopicType(widget.topicType.topicTypeName),
                      size: 28,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Contenido del centro
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.topicType.topicTypeName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.format_list_numbered,
                                    size: 14,
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.topicType.defaultNumberOptions} opc.',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.remove_circle_outline,
                                    size: 14,
                                    color: colorScheme.onErrorContainer,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Pen: ${(widget.topicType.penalty * 100).toStringAsFixed(0)}%',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onErrorContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Menú de acciones (derecha)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        widget.onEdit();
                      } else if (value == 'delete') {
                        widget.onDelete();
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: colorScheme.onSurface,
                            ),
                            const SizedBox(width: 12),
                            const Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForTopicType(String typeName) {
    final nameLower = typeName.toLowerCase();
    if (nameLower.contains('bloque') || nameLower.contains('conocimiento')) return Icons.menu_book;
    if (nameLower.contains('psicotécnico')) return Icons.psychology;
    if (nameLower.contains('gramática') || nameLower.contains('ortografía')) return Icons.spellcheck;
    if (nameLower.contains('simulacro')) return Icons.school;
    if (nameLower.contains('oficial')) return Icons.verified;
    if (nameLower.contains('inglés')) return Icons.language;
    if (nameLower.contains('especial')) return Icons.star;
    return Icons.quiz;
  }
}

class DottedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final BorderType borderType;
  final Radius radius;
  final List<double> dashPattern;

  const DottedBorder({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.borderType = BorderType.Rect,
    this.radius = const Radius.circular(0),
    this.dashPattern = const <double>[3, 1],
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedPainter(
        color: color,
        strokeWidth: strokeWidth,
        radius: radius,
        dashPattern: dashPattern,
      ),
      child: child,
    );
  }
}

class _DottedPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final Radius radius;
  final List<double> dashPattern;

  _DottedPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), radius));

    final dashPath = _getDashedPath(path, dashPattern);
    canvas.drawPath(dashPath, paint);
  }

  Path _getDashedPath(Path source, List<double> dashArray) {
    final Path dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final len = dashArray[draw ? 0 : 1];
        dest.addPath(
          metric.extractPath(distance, distance + len),
          Offset.zero,
        );
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

enum BorderType {
  Rect,
  RRect,
  Oval,
  Circle,
}

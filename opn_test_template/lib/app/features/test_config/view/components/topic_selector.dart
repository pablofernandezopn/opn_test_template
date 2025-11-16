import 'package:flutter/material.dart';
import '../../../topics/model/topic_model.dart';
import '../../../topics/model/category_model.dart';

/// Widget para seleccionar los topics del test con una UI moderna y animada
class TopicSelector extends StatefulWidget {
  final List<Topic> availableTopics;
  final List<int> selectedTopicIds;
  final ValueChanged<int> onTopicToggled;
  final ValueChanged<List<int>>? onSelectMultipleTopics;
  final List<Category> categories;

  const TopicSelector({
    super.key,
    required this.availableTopics,
    required this.selectedTopicIds,
    required this.onTopicToggled,
    this.onSelectMultipleTopics,
    required this.categories,
  });

  @override
  State<TopicSelector> createState() => _TopicSelectorState();
}

class _TopicSelectorState extends State<TopicSelector> {
  /// Agrupa los topics por categoría y los ordena por el campo 'order'
  Map<int?, List<Topic>> _groupTopicsByCategory() {
    final Map<int?, List<Topic>> grouped = {};

    for (final topic in widget.availableTopics) {
      final categoryId = topic.categoryId;
      if (!grouped.containsKey(categoryId)) {
        grouped[categoryId] = [];
      }
      grouped[categoryId]!.add(topic);
    }

    // Ordenar topics dentro de cada categoría por el campo 'order'
    grouped.forEach((categoryId, topics) {
      topics.sort((a, b) {
        // Si ambos tienen order, comparar
        if (a.order != null && b.order != null) {
          return a.order!.compareTo(b.order!);
        }
        // Los que no tienen order van al final
        if (a.order == null && b.order == null) return 0;
        if (a.order == null) return 1;
        return -1;
      });
    });

    return grouped;
  }

  /// Obtiene el nombre de la categoría por su ID
  String _getCategoryName(int? categoryId) {
    if (categoryId == null) return 'Sin categoría';

    final category = widget.categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => Category.empty,
    );

    return category.name ?? 'Categoría $categoryId';
  }

  /// Verifica si todos los topics de una categoría están seleccionados
  bool _areAllTopicsSelectedInCategory(List<Topic> categoryTopics) {
    return categoryTopics.every((topic) =>
      topic.id != null && widget.selectedTopicIds.contains(topic.id)
    );
  }

  /// Verifica si algún topic de una categoría está seleccionado
  bool _areSomeTopicsSelectedInCategory(List<Topic> categoryTopics) {
    return categoryTopics.any((topic) =>
      topic.id != null && widget.selectedTopicIds.contains(topic.id)
    );
  }

  /// Selecciona o deselecciona todos los topics de una categoría
  void _toggleCategorySelection(List<Topic> categoryTopics) {
    final categoryTopicIds = categoryTopics
        .where((topic) => topic.id != null)
        .map((topic) => topic.id!)
        .toList();

    final allSelected = _areAllTopicsSelectedInCategory(categoryTopics);

    if (allSelected) {
      // Deseleccionar todos los topics de esta categoría
      final newSelectedIds = List<int>.from(widget.selectedTopicIds)
        ..removeWhere((id) => categoryTopicIds.contains(id));
      widget.onSelectMultipleTopics?.call(newSelectedIds);
    } else {
      // Seleccionar todos los topics de esta categoría
      final newSelectedIds = List<int>.from(widget.selectedTopicIds);
      for (final id in categoryTopicIds) {
        if (!newSelectedIds.contains(id)) {
          newSelectedIds.add(id);
        }
      }
      widget.onSelectMultipleTopics?.call(newSelectedIds);
    }
  }

  /// Verifica si todos los topics están seleccionados
  bool _areAllTopicsSelected() {
    final allTopicIds = widget.availableTopics
        .where((topic) => topic.id != null)
        .map((topic) => topic.id!)
        .toList();

    return allTopicIds.isNotEmpty &&
           allTopicIds.every((id) => widget.selectedTopicIds.contains(id));
  }

  /// Selecciona o deselecciona todos los topics
  void _toggleAllTopics() {
    final allTopicIds = widget.availableTopics
        .where((topic) => topic.id != null)
        .map((topic) => topic.id!)
        .toList();

    if (_areAllTopicsSelected()) {
      // Deseleccionar todos
      widget.onSelectMultipleTopics?.call([]);
    } else {
      // Seleccionar todos
      widget.onSelectMultipleTopics?.call(allTopicIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.availableTopics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.topic_outlined,
                size: 48,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay temas disponibles',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Intenta más tarde o contacta al administrador',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Agrupar topics por categoría
    final groupedTopics = _groupTopicsByCategory();
    final categoryIds = groupedTopics.keys.toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Checkbox global para seleccionar todos los topics
        if (widget.onSelectMultipleTopics != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: CheckboxListTile(
              dense: true,
              title: Text(
                'Seleccionar todos los temas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              subtitle: Text(
                '${widget.selectedTopicIds.length} de ${widget.availableTopics.length} seleccionados',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: _areAllTopicsSelected(),
              tristate: true,
              onChanged: (_) => _toggleAllTopics(),
              controlAffinity: ListTileControlAffinity.leading,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

        const SizedBox(height: 8),

        // Lista de categorías con ExpansionTile
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: categoryIds.length,
          itemBuilder: (context, categoryIndex) {
            final categoryId = categoryIds[categoryIndex];
            final categoryTopics = groupedTopics[categoryId]!;
            final categoryName = _getCategoryName(categoryId);
            final allSelected = _areAllTopicsSelectedInCategory(categoryTopics);
            final someSelected = _areSomeTopicsSelectedInCategory(categoryTopics);

            return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: someSelected
                        ? colorScheme.primary.withValues(alpha: 0.3)
                        : colorScheme.outline.withValues(alpha: 0.2),
                    width: someSelected ? 1.5 : 1,
                  ),
                ),
                child: categoryId == null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: categoryTopics.map((topic) {
                          final isSelected = widget.selectedTopicIds.contains(topic.id);
                          final bool hasDescription = topic.description?.isNotEmpty ?? false;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                                  : colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? colorScheme.primary.withValues(alpha: 0.5)
                                    : colorScheme.outline.withValues(alpha: 0.2),
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                                  : null,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                if (topic.id != null) {
                                  widget.onTopicToggled(topic.id!);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                child: Row(
                                  children: [
                                    // Checkbox con animación personalizada
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: AnimatedScale(
                                        scale: isSelected ? 1.1 : 1.0,
                                        duration: const Duration(milliseconds: 200),
                                        child: Checkbox(
                                          value: isSelected,
                                          onChanged: null, // Desactivamos el onChanged del checkbox
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          side: BorderSide(
                                            color: isSelected
                                                ? colorScheme.primary
                                                : colorScheme.outline,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Contenido del tema
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            topic.topicName,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight:
                                              isSelected ? FontWeight.bold : FontWeight.w600,
                                              color: isSelected
                                                  ? colorScheme.primary
                                                  : colorScheme.onSurface,
                                            ),
                                          ),
                                          if (hasDescription) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              topic.description!,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: colorScheme.onSurfaceVariant,
                                                height: 1.4,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // Icono indicativo opcional
                                    if (isSelected)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 12),
                                        child: Icon(
                                          Icons.check_circle,
                                          color: colorScheme.primary,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : ExpansionTile(
                  initiallyExpanded: false,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: widget.onSelectMultipleTopics != null
                      ? Checkbox(
                          value: allSelected,
                          tristate: true,
                          onChanged: (_) => _toggleCategorySelection(categoryTopics),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        )
                      : null,
                  title: Text(
                    categoryName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: someSelected ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '${categoryTopics.where((t) => t.id != null && widget.selectedTopicIds.contains(t.id)).length} de ${categoryTopics.length} seleccionados',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  children: categoryTopics.map((topic) {
                    final isSelected = widget.selectedTopicIds.contains(topic.id);
                    final bool hasDescription = topic.description?.isNotEmpty ?? false;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: 0.5)
                              : colorScheme.outline.withValues(alpha: 0.2),
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                            : null,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          if (topic.id != null) {
                            widget.onTopicToggled(topic.id!);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Row(
                            children: [
                              // Checkbox con animación personalizada
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: AnimatedScale(
                                  scale: isSelected ? 1.1 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Checkbox(
                                    value: isSelected,
                                    onChanged: null, // Desactivamos el onChanged del checkbox
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    side: BorderSide(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.outline,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Contenido del tema
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      topic.topicName,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight:
                                        isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                    if (hasDescription) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        topic.description!,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Icono indicativo opcional
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            );
          },
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:opn_test_template/app/features/topics/model/topic_type_model.dart';

class TopicTypeFilter extends StatelessWidget {
  const TopicTypeFilter({
    super.key,
    required this.topicTypes,
    required this.selectedTopicTypeId,
    required this.onFilterChanged,
  });

  final List<TopicType> topicTypes;
  final int? selectedTopicTypeId;
  final Function(int?) onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // Chip "Todos"
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              label: 'Todos',
              isSelected: selectedTopicTypeId == null,
              onTap: () => onFilterChanged(null),
              colorScheme: colorScheme,
            ),
          ),
          // Chips de tipos de test
          for (final topicType in topicTypes)
            if (topicType.id != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: topicType.topicTypeName,
                  isSelected: selectedTopicTypeId == topicType.id,
                  onTap: () => onFilterChanged(topicType.id),
                  colorScheme: colorScheme,
                ),
              ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
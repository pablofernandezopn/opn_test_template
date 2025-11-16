import 'package:flutter/material.dart';

/// Configuración de columna para GroupableTable
class GroupableTableColumnConfig<T> {
  final String id;
  final String label;
  final double? width;
  final bool sortable;
  final String Function(T item) valueGetter;
  final Widget Function(T item)? cellBuilder;
  final Alignment alignment;
  final int flex;

  const GroupableTableColumnConfig({
    required this.id,
    required this.label,
    this.width,
    this.sortable = true,
    required this.valueGetter,
    this.cellBuilder,
    this.alignment = Alignment.centerLeft,
    this.flex = 1,
  });
}

/// Tabla con capacidad de agrupación por ID
class GroupableTable<T> extends StatefulWidget {
  final List<T> items;
  final List<GroupableTableColumnConfig<T>> columns;
  final String Function(T item) groupByGetter;
  final T? selectedItem;
  final void Function(T item)? onItemTap;
  final List<Widget> Function(T item)? rowActions;
  final bool isLoading;
  final String emptyMessage;
  final Widget? emptyWidget;
  final bool showCheckboxes;
  final Set<T>? selectedItems;
  final void Function(Set<T>)? onSelectionChanged;
  final Widget Function(String groupId, List<T> items)? groupHeaderBuilder;
  final bool initiallyExpanded;
  final bool showItemCount;
  final ScrollController? scrollController;

  const GroupableTable({
    super.key,
    required this.items,
    required this.columns,
    required this.groupByGetter,
    this.selectedItem,
    this.onItemTap,
    this.rowActions,
    this.isLoading = false,
    this.emptyMessage = 'No hay datos disponibles',
    this.emptyWidget,
    this.showCheckboxes = false,
    this.selectedItems,
    this.onSelectionChanged,
    this.groupHeaderBuilder,
    this.initiallyExpanded = true,
    this.showItemCount = true,
    this.scrollController,
  });

  @override
  State<GroupableTable<T>> createState() => _GroupableTableState<T>();
}

class _GroupableTableState<T> extends State<GroupableTable<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<T> _sortedItems;
  final Map<String, bool> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    _sortedItems = List.from(widget.items);
    _initializeExpandedState();
  }

  @override
  void didUpdateWidget(GroupableTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _sortedItems = List.from(widget.items);
      _initializeExpandedState();
      if (_sortColumnIndex != null) {
        _sort(_sortColumnIndex!, _sortAscending);
      }
    }
  }

  void _initializeExpandedState() {
    final groupedData = _groupItems(_sortedItems);
    for (final groupId in groupedData.keys) {
      _expandedGroups.putIfAbsent(groupId, () => widget.initiallyExpanded);
    }
  }

  Map<String, List<T>> _groupItems(List<T> items) {
    final Map<String, List<T>> grouped = {};
    for (final item in items) {
      final groupId = widget.groupByGetter(item);
      grouped.putIfAbsent(groupId, () => []).add(item);
    }
    return grouped;
  }

  void _sort(int columnIndex, bool ascending) {
    final column = widget.columns[columnIndex];
    _sortedItems.sort((a, b) {
      final aValue = column.valueGetter(a);
      final bValue = column.valueGetter(b);
      return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _toggleGroup(String groupId) {
    setState(() {
      _expandedGroups[groupId] = !(_expandedGroups[groupId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sortedItems.isEmpty) {
      return widget.emptyWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.emptyMessage,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
    }

    final groupedData = _groupItems(_sortedItems);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool hasCheckbox = widget.showCheckboxes;
        final double checkboxW = hasCheckbox ? 48.0 : 0.0;
        final bool hasActions = widget.rowActions != null;
        final double actionsW = hasActions ? 120.0 : 0.0;
        final double sideWidth = checkboxW + actionsW;

        final Map<String, double> columnWidths = {};
        final List<GroupableTableColumnConfig<T>> flexColumns = [];
        double flexTotal = 0.0;

        for (final col in widget.columns) {
          if (col.width != null) {
            columnWidths[col.id] = col.width!;
          } else {
            flexColumns.add(col);
            flexTotal += col.flex;
            columnWidths[col.id] = col.flex * 100.0;
          }
        }

        final double sumFixedColumns = widget.columns
            .where((c) => c.width != null)
            .fold(0.0, (sum, c) => sum + columnWidths[c.id]!);
        double sumFlexWidths =
            flexColumns.fold(0.0, (sum, col) => sum + columnWidths[col.id]!);
        final double availableForColumns = constraints.maxWidth - sideWidth;
        double extraSpace =
            availableForColumns - (sumFixedColumns + sumFlexWidths);

        if (extraSpace > 0 && flexTotal > 0) {
          final double extraPerFlexUnit = extraSpace / flexTotal;
          for (final col in flexColumns) {
            columnWidths[col.id] =
                columnWidths[col.id]! + (col.flex * extraPerFlexUnit);
          }
        } else if (extraSpace < 0 && flexTotal > 0) {
          final double reductionPerFlexUnit = -extraSpace / flexTotal;
          for (final col in flexColumns) {
            columnWidths[col.id] =
                (columnWidths[col.id]! - (col.flex * reductionPerFlexUnit))
                    .clamp(50.0, double.infinity);
          }
          sumFlexWidths =
              flexColumns.fold(0.0, (sum, col) => sum + columnWidths[col.id]!);
        }

        final double totalWidth = sideWidth + sumFixedColumns + sumFlexWidths;

        return SingleChildScrollView(
          controller: widget.scrollController,
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth.clamp(constraints.maxWidth, double.infinity),
              child: _buildGroupedDataTable(
                context,
                groupedData,
                columnWidths,
                checkboxW,
                actionsW,
                hasCheckbox,
                hasActions,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupedDataTable(
    BuildContext context,
    Map<String, List<T>> groupedData,
    Map<String, double> columnWidths,
    double checkboxW,
    double actionsW,
    bool hasCheckbox,
    bool hasActions,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header row
        _buildHeaderRow(
          context,
          colorScheme,
          columnWidths,
          checkboxW,
          actionsW,
          hasCheckbox,
          hasActions,
        ),
        // Grouped data rows
        ...groupedData.entries.map((entry) {
          final groupId = entry.key;
          final items = entry.value;
          final isExpanded = _expandedGroups[groupId] ?? false;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Group header
              _buildGroupHeader(
                context,
                colorScheme,
                groupId,
                items,
                isExpanded,
                columnWidths,
                checkboxW,
                actionsW,
                hasCheckbox,
                hasActions,
              ),
              // Group items (if expanded)
              if (isExpanded)
                ...items.asMap().entries.map((itemEntry) {
                  final index = itemEntry.key;
                  final item = itemEntry.value;
                  return _buildDataRow(
                    context,
                    colorScheme,
                    item,
                    index,
                    columnWidths,
                    checkboxW,
                    actionsW,
                    hasCheckbox,
                    hasActions,
                  );
                }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildHeaderRow(
    BuildContext context,
    ColorScheme colorScheme,
    Map<String, double> columnWidths,
    double checkboxW,
    double actionsW,
    bool hasCheckbox,
    bool hasActions,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (hasCheckbox) SizedBox(width: checkboxW),
          ...widget.columns.asMap().entries.map((entry) {
            final index = entry.key;
            final column = entry.value;
            return SizedBox(
              width: columnWidths[column.id]!,
              child: GestureDetector(
                onTap: column.sortable
                    ? () {
                        final newAscending =
                            (_sortColumnIndex == index && _sortAscending)
                                ? !_sortAscending
                                : true;
                        _sort(index, newAscending);
                      }
                    : null,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: column.alignment,
                          child: Text(
                            column.label,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (_sortColumnIndex == index)
                        Icon(
                          _sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (hasActions)
            SizedBox(
              width: actionsW,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Acciones',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(
    BuildContext context,
    ColorScheme colorScheme,
    String groupId,
    List<T> items,
    bool isExpanded,
    Map<String, double> columnWidths,
    double checkboxW,
    double actionsW,
    bool hasCheckbox,
    bool hasActions,
  ) {
    final totalWidth = (hasCheckbox ? checkboxW : 0) +
        columnWidths.values.fold(0.0, (sum, w) => sum + w) +
        (hasActions ? actionsW : 0);

    return InkWell(
      onTap: () => _toggleGroup(groupId),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withOpacity(0.2),
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: widget.groupHeaderBuilder?.call(groupId, items) ??
              Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ID: $groupId',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (widget.showItemCount)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${items.length}',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildDataRow(
    BuildContext context,
    ColorScheme colorScheme,
    T item,
    int index,
    Map<String, double> columnWidths,
    double checkboxW,
    double actionsW,
    bool hasCheckbox,
    bool hasActions,
  ) {
    final isSelectedForEdit = widget.selectedItem == item;
    final isSelectedForCheckbox = widget.selectedItems?.contains(item) ?? false;

    Color? backgroundColor;
    Color textColor = colorScheme.onSurface;

    if (isSelectedForCheckbox && isSelectedForEdit) {
      backgroundColor = colorScheme.primary.withAlpha(180);
      textColor = colorScheme.onPrimary;
    } else if (isSelectedForCheckbox) {
      backgroundColor = colorScheme.primaryContainer.withAlpha(120);
      textColor = colorScheme.onPrimaryContainer;
    } else if (isSelectedForEdit) {
      backgroundColor = colorScheme.secondaryContainer.withAlpha(120);
      textColor = colorScheme.onSecondaryContainer;
    } else if (index.isEven) {
      backgroundColor = colorScheme.surfaceContainerHighest.withAlpha(50);
    }

    final cellStyle = TextStyle(color: textColor);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: InkWell(
        onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
        child: Row(
          children: [
            if (hasCheckbox)
              SizedBox(
                width: checkboxW,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Checkbox(
                    value: isSelectedForCheckbox,
                    onChanged: (selected) {
                      final newSelection =
                          Set<T>.from(widget.selectedItems ?? {});
                      if (selected == true) {
                        newSelection.add(item);
                      } else {
                        newSelection.remove(item);
                      }
                      widget.onSelectionChanged?.call(newSelection);
                    },
                  ),
                ),
              ),
            ...widget.columns.map((column) {
              final cellContent = column.cellBuilder?.call(item) ??
                  Text(
                    column.valueGetter(item),
                    style: cellStyle,
                    overflow: TextOverflow.ellipsis,
                  );
              return SizedBox(
                width: columnWidths[column.id]!,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Align(
                    alignment: column.alignment,
                    child: cellContent,
                  ),
                ),
              );
            }),
            if (hasActions)
              SizedBox(
                width: actionsW,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.rowActions!(item),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Configuración de columna para ReorderableTable
class ReorderableTableColumnConfig<T> {
  final String id;
  final String label;
  final double? width;
  final bool sortable;
  final String Function(T item) valueGetter;
  final Widget Function(T item)? cellBuilder;
  final Alignment alignment;
  final int flex;

  const ReorderableTableColumnConfig({
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

/// Tabla con capacidad de reordenamiento mediante drag & drop
class ReorderableTable<T> extends StatefulWidget {
  final List<T> items;
  final List<ReorderableTableColumnConfig<T>> columns;
  final T? selectedItem;
  final void Function(T item)? onItemTap;
  final List<Widget> Function(T item)? rowActions;
  final bool isLoading;
  final String emptyMessage;
  final Widget? emptyWidget;
  final bool showCheckboxes;
  final Set<T>? selectedItems;
  final void Function(Set<T>)? onSelectionChanged;
  final void Function(int oldIndex, int newIndex) onReorder;
  final bool showDragHandle;
  final ScrollController? scrollController; // NUEVO: ScrollController opcional

  const ReorderableTable({
    super.key,
    required this.items,
    required this.columns,
    required this.onReorder,
    this.selectedItem,
    this.onItemTap,
    this.rowActions,
    this.isLoading = false,
    this.emptyMessage = 'No hay datos disponibles',
    this.emptyWidget,
    this.showCheckboxes = false,
    this.selectedItems,
    this.onSelectionChanged,
    this.showDragHandle = true,
    this.scrollController, // NUEVO
  });

  @override
  State<ReorderableTable<T>> createState() => _ReorderableTableState<T>();
}

class _ReorderableTableState<T> extends State<ReorderableTable<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<T> _sortedItems;
  late ScrollController
      _internalScrollController; // NUEVO: ScrollController interno
  ScrollController?
      _horizontalScrollController; // NUEVO: Para scroll horizontal

  @override
  void initState() {
    super.initState();
    _sortedItems = List.from(widget.items);
    // Usar el controller proporcionado o crear uno interno
    _internalScrollController = widget.scrollController ?? ScrollController();
    _horizontalScrollController = ScrollController();
  }

  @override
  void didUpdateWidget(ReorderableTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _sortedItems = List.from(widget.items);
      if (_sortColumnIndex != null) {
        _sort(_sortColumnIndex!, _sortAscending);
      }
    }
    // Actualizar el controller si cambió
    if (oldWidget.scrollController != widget.scrollController) {
      if (widget.scrollController == null &&
          oldWidget.scrollController != null) {
        _internalScrollController = ScrollController();
      } else if (widget.scrollController != null) {
        _internalScrollController = widget.scrollController!;
      }
    }
  }

  @override
  void dispose() {
    // Solo dispose del controller horizontal y del interno si no fue proporcionado
    _horizontalScrollController?.dispose();
    if (widget.scrollController == null) {
      _internalScrollController.dispose();
    }
    super.dispose();
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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular anchos de columnas
        final bool hasDrag = widget.showDragHandle;
        final double dragW = hasDrag ? 48.0 : 0.0;
        final bool hasCheckbox = widget.showCheckboxes;
        final double checkboxW = hasCheckbox ? 48.0 : 0.0;
        final bool hasActions = widget.rowActions != null;
        final double actionsW = hasActions ? 120.0 : 0.0;
        final double sideWidth = dragW + checkboxW + actionsW;

        final Map<String, double> columnWidths = {};
        final List<ReorderableTableColumnConfig<T>> flexColumns = [];
        double flexTotal = 0.0;

        // Primera pasada: asignar anchos fijos y recolectar columnas flex
        for (final col in widget.columns) {
          if (col.width != null) {
            columnWidths[col.id] = col.width!;
          } else {
            flexColumns.add(col);
            flexTotal += col.flex;
            columnWidths[col.id] = col.flex * 100.0;
          }
        }

        // Segunda pasada: distribuir espacio extra a columnas flex si hay disponible
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

        // Total ancho calculado
        final double totalWidth = sideWidth + sumFixedColumns + sumFlexWidths;

        return SingleChildScrollView(
          controller:
              _internalScrollController, // MODIFICADO: Usar el controller
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth.clamp(constraints.maxWidth, double.infinity),
              child: _buildReorderableDataTable(
                context,
                columnWidths,
                dragW,
                checkboxW,
                actionsW,
                hasDrag,
                hasCheckbox,
                hasActions,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReorderableDataTable(
    BuildContext context,
    Map<String, double> columnWidths,
    double dragW,
    double checkboxW,
    double actionsW,
    bool hasDrag,
    bool hasCheckbox,
    bool hasActions,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header row (fixed, non-reorderable)
        _buildHeaderRow(
          context,
          colorScheme,
          columnWidths,
          dragW,
          checkboxW,
          actionsW,
          hasDrag,
          hasCheckbox,
          hasActions,
        ),
        // Data rows (reorderable)
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: _sortedItems.length,
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            widget.onReorder(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final item = _sortedItems[index];
            return _buildDataRow(
              context,
              colorScheme,
              item,
              index,
              columnWidths,
              dragW,
              checkboxW,
              actionsW,
              hasDrag,
              hasCheckbox,
              hasActions,
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderRow(
    BuildContext context,
    ColorScheme colorScheme,
    Map<String, double> columnWidths,
    double dragW,
    double checkboxW,
    double actionsW,
    bool hasDrag,
    bool hasCheckbox,
    bool hasActions,
  ) {
    return Container(
      key: const ValueKey('header'),
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
          // Drag handle column
          if (hasDrag)
            SizedBox(
              width: dragW,
            ),
          // Checkbox column
          if (hasCheckbox)
            SizedBox(
              width: checkboxW,
            ),
          // Data columns
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
          // Actions column
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

  Widget _buildDataRow(
    BuildContext context,
    ColorScheme colorScheme,
    T item,
    int index,
    Map<String, double> columnWidths,
    double dragW,
    double checkboxW,
    double actionsW,
    bool hasDrag,
    bool hasCheckbox,
    bool hasActions,
  ) {
    final isSelectedForEdit = widget.selectedItem == item;
    final isSelectedForCheckbox = widget.selectedItems?.contains(item) ?? false;

    // Determinar el color de fondo según el tipo de selección
    Color? backgroundColor;
    Color textColor = colorScheme.onSurface;

    if (isSelectedForCheckbox && isSelectedForEdit) {
      // Seleccionado por ambos: usar color primario más intenso
      backgroundColor = colorScheme.primary.withAlpha(180);
      textColor = colorScheme.onPrimary;
    } else if (isSelectedForCheckbox) {
      // Seleccionado solo por checkbox: usar color primario suave
      backgroundColor = colorScheme.primaryContainer.withAlpha(120);
      textColor = colorScheme.onPrimaryContainer;
    } else if (isSelectedForEdit) {
      // Seleccionado solo para edición: usar color secundario/terciario
      backgroundColor = colorScheme.secondaryContainer.withAlpha(120);
      textColor = colorScheme.onSecondaryContainer;
    } else if (index.isEven) {
      // Fila par sin selección: color alterno
      backgroundColor = colorScheme.surfaceContainerHighest.withAlpha(50);
    }

    // Generate unique key - try to use item's identity or index as fallback
    final key = ValueKey('${item.hashCode}_$index');

    final cellStyle = TextStyle(color: textColor);

    return Container(
      key: key,
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
            // Drag handle
            if (hasDrag)
              ReorderableDragStartListener(
                index: index,
                child: SizedBox(
                  width: dragW,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.drag_indicator,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                ),
              ),
            // Checkbox
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
            // Data columns
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
            // Actions
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

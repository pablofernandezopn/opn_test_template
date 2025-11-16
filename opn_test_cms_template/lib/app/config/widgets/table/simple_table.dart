import 'package:flutter/material.dart';

class TableColumnConfig<T> {
  final String id;
  final String label;
  final double? width;
  final bool sortable;
  final String Function(T item) valueGetter;
  final Widget Function(T item)? cellBuilder;
  final Alignment alignment;
  final int flex;

  const TableColumnConfig({
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



class SimpleTable<T> extends StatefulWidget {
  final List<T> items;
  final List<TableColumnConfig<T>> columns;
  final T? selectedItem;
  final void Function(T item)? onItemTap;
  final void Function(T item)? onItemDoubleTap;
  final List<Widget> Function(T item)? rowActions;
  final bool isLoading;
  final String emptyMessage;
  final Widget? emptyWidget;
  final bool showCheckboxes;
  final Set<T>? selectedItems;
  final void Function(Set<T>)? onSelectionChanged;

  const SimpleTable({
    super.key,
    required this.items,
    required this.columns,
    this.selectedItem,
    this.onItemTap,
    this.onItemDoubleTap,
    this.rowActions,
    this.isLoading = false,
    this.emptyMessage = 'No hay datos disponibles',
    this.emptyWidget,
    this.showCheckboxes = false,
    this.selectedItems,
    this.onSelectionChanged,
  });

  @override
  State<SimpleTable<T>> createState() => _SimpleTableState<T>();
}

class _SimpleTableState<T> extends State<SimpleTable<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<T> _sortedItems;

  @override
  void initState() {
    super.initState();
    _sortedItems = List.from(widget.items);
  }

  @override
  void didUpdateWidget(SimpleTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _sortedItems = List.from(widget.items);
      if (_sortColumnIndex != null) {
        _sort(_sortColumnIndex!, _sortAscending);
      }
    }
  }

  void _sort(int columnIndex, bool ascending) {
    final column = widget.columns[columnIndex];
    _sortedItems.sort((a, b) {
      final aValue = column.valueGetter(a);
      final bValue = column.valueGetter(b);
      return ascending
          ? aValue.compareTo(bValue)
          : bValue.compareTo(aValue);
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

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 48,
          ),
          child: DataTable(
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            showCheckboxColumn: widget.showCheckboxes,
            columns: [
              ...widget.columns.map((column) {
                return DataColumn(
                  label: column.width != null
                      ? SizedBox(
                          width: column.width,
                          child: Align(
                            alignment: column.alignment,
                            child: Text(
                              column.label,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : Expanded(
                          flex: column.flex,
                          child: Align(
                            alignment: column.alignment,
                            child: Text(
                              column.label,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                  onSort: column.sortable
                      ? (columnIndex, ascending) => _sort(columnIndex, ascending)
                      : null,
                );
              }),
              // Add actions column header if rowActions are provided
              if (widget.rowActions != null)
                DataColumn(
                  label: SizedBox(
                    width: 120,
                    child: Text(
                      'Acciones',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
            rows: _sortedItems.map((item) {
              final isSelectedForEdit = widget.selectedItem == item;
              final isSelectedForCheckbox = widget.selectedItems?.contains(item) ?? false;
              final isSelected = widget.showCheckboxes ? isSelectedForCheckbox : isSelectedForEdit;

              return DataRow(
                selected: isSelected,
                onSelectChanged: widget.showCheckboxes
                    ? (selected) {
                  final newSelection = Set<T>.from(widget.selectedItems ?? {});
                  if (selected == true) {
                    newSelection.add(item);
                  } else {
                    newSelection.remove(item);
                  }
                  widget.onSelectionChanged?.call(newSelection);
                }
                    : (selected) => widget.onItemTap?.call(item),
                cells: [
                  ...widget.columns.map((column) {
                    final cellContent = column.cellBuilder != null
                        ? column.cellBuilder!(item)
                        : Text(column.valueGetter(item));

                    return DataCell(
                      column.width != null
                          ? SizedBox(
                              width: column.width,
                              child: Align(
                                alignment: column.alignment,
                                child: cellContent,
                              ),
                            )
                          : Align(
                              alignment: column.alignment,
                              child: cellContent,
                            ),
                    );
                  }),
                  // Add row actions as a final cell if provided
                  if (widget.rowActions != null)
                    DataCell(
                      SizedBox(
                        width: 120,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.rowActions!(item),
                        ),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/features/categories/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/categories/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_level.dart';

import '../../../config/widgets/buttons/modern_icon_button.dart';
import '../../../config/widgets/table/reorderable_table.dart';
import '../model/category_model.dart';
import 'components/create_category_dialog.dart';

class CategoriesPage extends StatefulWidget {
  static const String route = '/categories';

  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  int? _selectedTopicTypeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryCubit>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Categorías'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ModernIconButton(
              icon: Icons.add,
              tooltip: 'Crear nueva categoría',
              onPressed: () => _showCreateCategoryDialog(context),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ModernIconButton(
              icon: Icons.refresh,
              tooltip: 'Actualizar',
              onPressed: () => _loadCategories(),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopicTypeFilter(context),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BlocBuilder<CategoryCubit, CategoryState>(
                    builder: (context, state) {
                      if (state.fetchStatus.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.fetchStatus.isError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Error al cargar las categorías',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(state.error ?? ''),
                            ],
                          ),
                        );
                      }

                      final filteredCategories = _selectedTopicTypeId == null
                          ? state.categories
                          : state.categories
                              .where((c) => c.topicType == _selectedTopicTypeId)
                              .toList();

                      if (filteredCategories.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.category_outlined,
                                  size: 64,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              const SizedBox(height: 16),
                              Text(
                                'No hay categorías disponibles',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Crea tu primera categoría usando el botón +',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }

                      return _buildCategoriesTable(context, filteredCategories);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicTypeFilter(BuildContext context) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, state) {
        // Filtrar solo topic_types de tipo Study
        final studyTopicTypes = state.topicTypes
            .where((topicType) => topicType.level == TopicLevel.Study)
            .toList();

        return Row(
          children: [
            Text(
              'Filtrar por bloque:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 16),
            DropdownButton<int?>(
              value: _selectedTopicTypeId,
              hint: const Text('Todos los bloques'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Todos los bloques de estudio'),
                ),
                ...studyTopicTypes.map((topicType) {
                  return DropdownMenuItem<int?>(
                    value: topicType.id,
                    child: Text(topicType.topicTypeName),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTopicTypeId = value;
                });
                _loadCategories();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoriesTable(
      BuildContext context, List<Category> categories) {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, topicState) {
        final columns = [
          ReorderableTableColumnConfig<Category>(
            id: 'id',
            label: 'ID',
            valueGetter: (category) => category.id?.toString() ?? '-',
            width: 80,
          ),
          ReorderableTableColumnConfig<Category>(
            id: 'name',
            label: 'Nombre',
            valueGetter: (category) => category.name ?? '-',
            flex: 2,
          ),
          ReorderableTableColumnConfig<Category>(
            id: 'topicType',
            label: 'Bloque de Estudio',
            valueGetter: (category) {
              final topicType = topicState.topicTypes
                  .where((t) => t.id == category.topicType)
                  .firstOrNull;
              return topicType?.topicTypeName ?? '-';
            },
            flex: 2,
          ),
          ReorderableTableColumnConfig<Category>(
            id: 'createdAt',
            label: 'Fecha de Creación',
            valueGetter: (category) => category.createdAt != null
                ? _formatDate(category.createdAt!)
                : '-',
            width: 180,
          ),
        ];

        return ReorderableTable<Category>(
          items: categories,
          columns: columns,
          showDragHandle: false,
          onReorder: (oldIndex, newIndex) {
            // Implementación del reordenamiento si es necesario
            // Por ahora lo dejamos vacío ya que no parece necesario para categorías
          },
          rowActions: (category) => [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditCategoryDialog(context, category),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, category),
              tooltip: 'Eliminar',
            ),
          ],
          emptyMessage: 'No hay categorías disponibles',
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showCreateCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<CategoryCubit>()),
          BlocProvider.value(value: context.read<TopicCubit>()),
        ],
        child: CreateCategoryDialog(
          preselectedTopicTypeId: _selectedTopicTypeId,
        ),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    final nameController = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar Categoría',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final updatedCategory = category.copyWith(
                        name: nameController.text.trim(),
                      );
                      context
                          .read<CategoryCubit>()
                          .updateCategory(category.id!, updatedCategory);
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la categoría "${category.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              context.read<CategoryCubit>().deleteCategory(category.id!);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _loadCategories() {
    if (_selectedTopicTypeId != null) {
      context
          .read<CategoryCubit>()
          .fetchCategoriesByTopicType(_selectedTopicTypeId!);
    } else {
      context.read<CategoryCubit>().fetchCategories();
    }
  }
}

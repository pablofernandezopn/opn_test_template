import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/cubit/state.dart';

class UserFilters extends StatefulWidget {
  const UserFilters({super.key});

  @override
  State<UserFilters> createState() => _UserFiltersState();
}

class _UserFiltersState extends State<UserFilters> {
  bool? _filterEnabled;
  bool? _filterTester;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.filter_list,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Filtros:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),

            // Filtro por estado
            DropdownButton<bool?>(
              value: _filterEnabled,
              hint: const Text('Todos los estados'),
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text('Todos los estados'),
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text('Activos'),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text('Inactivos'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _filterEnabled = value;
                });
                // context.read<UserCubit>().fetchUsers(
                //       enabled: value,
                //       tester: _filterTester,
                //     );
              },
            ),
            const SizedBox(width: 16),

            // Filtro por tester
            DropdownButton<bool?>(
              value: _filterTester,
              hint: const Text('Todos'),
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text('Todos'),
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text('Solo Testers'),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text('No Testers'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _filterTester = value;
                });
                // context.read<UserCubit>().fetchUsers(
                //       enabled: _filterEnabled,
                //       tester: value,
                //     );
              },
            ),
            const SizedBox(width: 16),

            // Botón para limpiar filtros
            if (_filterEnabled != null || _filterTester != null)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _filterEnabled = null;
                    _filterTester = null;
                  });
                  context.read<UserCubit>().fetchUsers();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar filtros'),
              ),

            const Spacer(),

            // Contador de usuarios
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  return Text(
                    '${state.users.length} usuarios',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

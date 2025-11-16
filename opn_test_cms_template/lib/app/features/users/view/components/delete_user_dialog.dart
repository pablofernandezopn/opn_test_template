import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/model/user.dart';

class DeleteUserDialog extends StatelessWidget {
  final User user;

  const DeleteUserDialog({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state.deleteUserStatus.isDone) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.deleteUserStatus.isError) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Error al eliminar usuario'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: colorScheme.error,
          size: 48,
        ),
        title: const Text('Eliminar Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Estás seguro de que deseas eliminar a ${user.fullName}?',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta acción no se puede deshacer.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              return FilledButton(
                onPressed: state.deleteUserStatus.isLoading
                    ? null
                    : () {
                        context.read<UserCubit>().deleteUser(user.id);
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: state.deleteUserStatus.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Eliminar'),
              );
            },
          ),
        ],
      ),
    );
  }
}

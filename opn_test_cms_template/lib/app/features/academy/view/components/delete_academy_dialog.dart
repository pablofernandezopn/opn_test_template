import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/cubit.dart';
import '../../cubit/state.dart';
import '../../model/academy_model.dart';

/// Diálogo de confirmación para eliminar una academia.
class DeleteAcademyDialog extends StatelessWidget {
  final Academy academy;

  const DeleteAcademyDialog({super.key, required this.academy});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<AcademyCubit, AcademyState>(
      listener: (context, state) {
        if (state.deleteStatus.isDone) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Academia eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          context.read<AcademyCubit>().resetDeleteStatus();
        } else if (state.deleteStatus.isError) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.deleteStatus.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
          context.read<AcademyCubit>().resetDeleteStatus();
        }
      },
      child: AlertDialog(
        icon: Icon(
          Icons.warning_rounded,
          color: colorScheme.error,
          size: 48,
        ),
        title: const Text('¿Eliminar Academia?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estás a punto de eliminar la academia:',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    academy.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Slug: ${academy.slug}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta acción NO se puede deshacer. '
                      'La eliminación fallará si la academia tiene usuarios, topics, preguntas o challenges asociados.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '¿Estás seguro de que deseas continuar?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          BlocBuilder<AcademyCubit, AcademyState>(
            builder: (context, state) {
              final isLoading = state.deleteStatus.isLoading;

              return FilledButton.tonal(
                onPressed: isLoading ? null : () => _confirmDelete(context),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Eliminar'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    if (academy.id != null) {
      context.read<AcademyCubit>().deleteAcademy(academy.id!);
    }
  }
}

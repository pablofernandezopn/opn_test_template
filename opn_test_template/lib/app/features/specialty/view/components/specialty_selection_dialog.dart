import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_template/app/features/specialty/cubit/specialty_cubit.dart';
import 'package:opn_test_template/app/features/specialty/cubit/specialty_state.dart';
import 'package:opn_test_template/app/features/specialty/model/specialty_model.dart';
import 'package:opn_test_template/app/authentification/auth/cubit/auth_cubit.dart';
import 'package:opn_test_template/app/features/topics/cubit/topic_cubit.dart';

class SpecialtySelectionDialog extends StatefulWidget {
  const SpecialtySelectionDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SpecialtySelectionDialog(),
    );
  }

  @override
  State<SpecialtySelectionDialog> createState() =>
      _SpecialtySelectionDialogState();
}

class _SpecialtySelectionDialogState extends State<SpecialtySelectionDialog> {
  Specialty? _selectedSpecialty;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<SpecialtyCubit, SpecialtyState>(
      builder: (context, state) {
        final specialties = state.specialties;

        return AlertDialog(
          icon: Icon(
            Icons.school_outlined,
            size: 48,
            color: colorScheme.primary,
          ),
          title: const Text('Selecciona tu especialidad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Para personalizar tu experiencia, elige la especialidad que estás preparando:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (specialties.isEmpty)
                Text(
                  'No hay especialidades disponibles',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: Column(
                      children: specialties.map((specialty) {
                        final isSelected = _selectedSpecialty?.id == specialty.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  _selectedSpecialty = specialty;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.outlineVariant,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            specialty.name,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              color: isSelected
                                                  ? colorScheme.onPrimaryContainer
                                                  : colorScheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (specialty.description != null &&
                                              specialty.description!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text(
                                                specialty.description!,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: isSelected
                                                      ? colorScheme
                                                          .onPrimaryContainer
                                                      : colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: _selectedSpecialty == null || _isLoading
                  ? null
                  : () => _onConfirm(context),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onConfirm(BuildContext context) async {
    if (_selectedSpecialty == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final specialtyCubit = context.read<SpecialtyCubit>();
      final authCubit = context.read<AuthCubit>();
      final topicCubit = context.read<TopicCubit>();
      final userId = authCubit.state.user.id;

      print('🔄 [DIALOG] Cambiando especialidad a: ${_selectedSpecialty!.name}');

      // Actualizar la especialidad del usuario
      final success =
          await specialtyCubit.updateSpecialty(userId, _selectedSpecialty!);

      if (success && context.mounted) {
        print('✅ [DIALOG] Especialidad actualizada en BD');

        // 1. Preparar TopicCubit para refresh manual
        print('🛡️ [DIALOG] Preparando refresh manual de topics...');
        topicCubit.prepareManualRefresh();

        if (!context.mounted) return;

        // 2. Actualizar el usuario en AuthCubit (el listener será ignorado)
        print('👤 [DIALOG] Refrescando usuario...');
        await authCubit.refreshUser();

        if (!context.mounted) return;

        // 3. Recargar los topics con la nueva especialidad
        print('🔄 [DIALOG] Recargando topics con nueva especialidad...');
        await topicCubit.refresh();

        print('✅ [DIALOG] Cambio de especialidad completado');

        Navigator.of(context).pop(true);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la especialidad'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
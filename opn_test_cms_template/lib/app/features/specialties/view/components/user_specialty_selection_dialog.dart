import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/model/specialty.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/cubit/auth_cubit.dart';

/// Diálogo para que el usuario seleccione su especialidad
/// Se muestra cuando el usuario no tiene especialidad asignada
class UserSpecialtySelectionDialog extends StatefulWidget {
  const UserSpecialtySelectionDialog({super.key});

  /// Muestra el diálogo de selección de especialidad
  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar sin seleccionar
      builder: (context) => const UserSpecialtySelectionDialog(),
    );
  }

  @override
  State<UserSpecialtySelectionDialog> createState() =>
      _UserSpecialtySelectionDialogState();
}

class _UserSpecialtySelectionDialogState
    extends State<UserSpecialtySelectionDialog> {
  int? _selectedSpecialtyId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(32),
        child: BlocBuilder<SpecialtyCubit, SpecialtyState>(
          builder: (context, state) {
            // Loading state
            if (state.fetchStatus.isLoading) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando especialidades...'),
                  ],
                ),
              );
            }

            // Error state
            if (state.fetchStatus.isError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar especialidades',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error ?? 'Error desconocido',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        context.read<SpecialtyCubit>().loadSpecialties();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            // Success state
            final activeSpecialties = state.activeSpecialties;

            if (activeSpecialties.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay especialidades disponibles',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Por favor, contacta con el administrador',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Bienvenido!',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Selecciona tu especialidad',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Descripción
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outlined,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Por favor, selecciona la especialidad a la que perteneces. '
                          'Esto te permitirá acceder al contenido específico de tu área.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Lista de especialidades
                Text(
                  'Especialidades disponibles:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: activeSpecialties.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final specialty = activeSpecialties[index];
                      final isSelected =
                          _selectedSpecialtyId == specialty.id;

                      return _SpecialtyCard(
                        specialty: specialty,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedSpecialtyId = specialty.id;
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Botón de confirmación
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _selectedSpecialtyId == null || _isLoading
                        ? null
                        : () => _confirmSelection(context),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      _isLoading ? 'Guardando...' : 'Confirmar Selección',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmSelection(BuildContext context) async {
    if (_selectedSpecialtyId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authCubit = context.read<AuthCubit>();
      final currentUser = authCubit.state.user;

      // Actualizar el usuario con la especialidad seleccionada
      final success = await authCubit.updateUser(
        username: currentUser.username,
        nombre: currentUser.name,
        apellido: currentUser.lastName,
        email: currentUser.email,
        phone: currentUser.phone,
        address: currentUser.address,
        avatarUrl: currentUser.avatarUrl,
        specialtyId: _selectedSpecialtyId,
      );

      if (success && context.mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Especialidad asignada correctamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Cerrar el diálogo
        Navigator.of(context).pop();
      } else if (context.mounted) {
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al asignar la especialidad'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
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

class _SpecialtyCard extends StatelessWidget {
  final Specialty specialty;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpecialtyCard({
    required this.specialty,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Parse color from hex
    Color? specialtyColor;
    if (specialty.colorHex != null) {
      try {
        specialtyColor = Color(
          int.parse(specialty.colorHex!.replaceFirst('#', '0xFF')),
        );
      } catch (e) {
        specialtyColor = null;
      }
    }

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color indicator
              if (specialtyColor != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: specialtyColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: specialtyColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // Specialty name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specialty.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (specialty.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        specialty.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Selection indicator
              const SizedBox(width: 12),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 20,
                    color: colorScheme.onPrimary,
                  ),
                )
              else
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

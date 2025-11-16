import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/cubit/auth_cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/config/go_route/app_routes.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/model/specialty.dart';

/// Página para que el usuario seleccione su especialidad
/// Se muestra cuando el usuario no tiene especialidad asignada
class SpecialtySelectionPage extends StatefulWidget {
  static const String route = '/specialty-selection';

  const SpecialtySelectionPage({super.key});

  @override
  State<SpecialtySelectionPage> createState() => _SpecialtySelectionPageState();
}

class _SpecialtySelectionPageState extends State<SpecialtySelectionPage> {
  int? _selectedSpecialtyId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Cargar especialidades al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final specialtyCubit = context.read<SpecialtyCubit>();
      if (specialtyCubit.state.activeSpecialties.isEmpty) {
        specialtyCubit.loadSpecialties();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<SpecialtyCubit, SpecialtyState>(
          builder: (context, state) {
            // Loading state
            if (state.fetchStatus.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Cargando especialidades...',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Error state
            if (state.fetchStatus.isError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Error al cargar especialidades',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.error ?? 'Error desconocido',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: () {
                          context.read<SpecialtyCubit>().loadSpecialties();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Success state
            final activeSpecialties = state.activeSpecialties;

            if (activeSpecialties.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 80,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No hay especialidades disponibles',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Por favor, contacta con el administrador',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Contenido principal
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Icon(
                        Icons.school_outlined,
                        size: 80,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '¡Bienvenido!',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Selecciona tu especialidad para continuar',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Descripción
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outlined,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Por favor, selecciona la especialidad a la que perteneces. '
                                'Esto te permitirá acceder al contenido específico de tu área.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Lista de especialidades
                      Text(
                        'Especialidades disponibles:',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cards de especialidades
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activeSpecialties.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final specialty = activeSpecialties[index];
                          final isSelected = _selectedSpecialtyId == specialty.id;

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
                      const SizedBox(height: 32),

                      // Botón de confirmación
                      SizedBox(
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: _selectedSpecialtyId == null || _isLoading
                              ? null
                              : () => _confirmSelection(context),
                          style: FilledButton.styleFrom(
                            textStyle: theme.textTheme.titleMedium,
                          ),
                          icon: _isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(
                            _isLoading ? 'Guardando...' : 'Confirmar y Continuar',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                const Text('Especialidad asignada correctamente'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navegar a la página principal
        await Future.delayed(const Duration(milliseconds: 500));
        if (context.mounted) {
          context.go(AppRoutes.home);
        }
      } else if (context.mounted) {
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                const Text('Error al asignar la especialidad'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Error: ${e.toString()}'),
                ),
              ],
            ),
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
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 3 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Color indicator
              if (specialtyColor != null) ...[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: specialtyColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: specialtyColor.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
              ],

              // Specialty info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specialty.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (specialty.description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        specialty.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
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
              const SizedBox(width: 16),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 20,
                        color: colorScheme.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

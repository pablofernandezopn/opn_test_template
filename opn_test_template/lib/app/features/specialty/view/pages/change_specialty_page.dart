import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_template/app/authentification/auth/cubit/auth_cubit.dart';
import 'package:opn_test_template/app/features/specialty/cubit/specialty_cubit.dart';
import 'package:opn_test_template/app/features/specialty/cubit/specialty_state.dart';
import 'package:opn_test_template/app/features/specialty/model/specialty_model.dart';
import 'package:opn_test_template/app/config/go_route/app_routes.dart';
import 'package:opn_test_template/app/features/topics/cubit/topic_cubit.dart';
import 'package:opn_test_template/app/features/loading/cubit/loading_cubit.dart';

class ChangeSpecialtyPage extends StatefulWidget {
  const ChangeSpecialtyPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ChangeSpecialtyPage(),
    );
  }

  @override
  State<ChangeSpecialtyPage> createState() => _ChangeSpecialtyPageState();
}

class _ChangeSpecialtyPageState extends State<ChangeSpecialtyPage> {
  Specialty? _selectedSpecialty;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final specialtyCubit = context.read<SpecialtyCubit>();
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.state.user;

    // Cargar especialidades si no están cargadas
    if (specialtyCubit.state.specialties.isEmpty) {
      await specialtyCubit.loadSpecialties(user.academyId);
    }

    // Establecer la especialidad actual
    if (mounted && user.specialtyId != null) {
      final currentSpecialty = specialtyCubit.state.specialties
          .where((s) => s.id == user.specialtyId)
          .firstOrNull;

      if (currentSpecialty != null) {
        setState(() {
          _selectedSpecialty = currentSpecialty;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Cambiar especialidad'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: BlocBuilder<SpecialtyCubit, SpecialtyState>(
        builder: (context, state) {
          if (state.isLoading && state.specialties.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Error al cargar especialidades',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final specialties = state.specialties;

          if (specialties.isEmpty) {
            return Center(
              child: Text(
                'No hay especialidades disponibles',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Selecciona tu especialidad para personalizar el contenido y los test disponibles.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Especialidades disponibles',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...specialties.map((specialty) {
                        final isSelected = _selectedSpecialty?.id == specialty.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
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
                                                  ? colorScheme
                                                      .onPrimaryContainer
                                                  : colorScheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (specialty.description != null &&
                                              specialty.description!.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
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
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _selectedSpecialty == null || _isLoading
                          ? null
                          : _onConfirm,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar cambios'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onConfirm() async {
    if (_selectedSpecialty == null) return;

    final authCubit = context.read<AuthCubit>();
    final currentSpecialtyId = authCubit.state.user.specialtyId;

    // Si no cambió nada, solo volver
    if (currentSpecialtyId == _selectedSpecialty!.id) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final specialtyCubit = context.read<SpecialtyCubit>();
      final userId = authCubit.state.user.id;

      print('🔄 [CHANGE_PAGE] ========================================');
      print('🔄 [CHANGE_PAGE] Iniciando cambio de especialidad');
      print('🔄 [CHANGE_PAGE] De: ${authCubit.state.user.specialtyId}');
      print('🔄 [CHANGE_PAGE] A: ${_selectedSpecialty!.id} (${_selectedSpecialty!.name})');

      // Actualizar la especialidad del usuario
      print('📝 [CHANGE_PAGE] Actualizando especialidad en BD...');
      final success =
          await specialtyCubit.updateSpecialty(userId, _selectedSpecialty!);

      if (!mounted) return;

      if (success) {
        print('✅ [CHANGE_PAGE] Especialidad actualizada en BD');

        // 1. Preparar TopicCubit para refresh manual (activar bandera ANTES de refreshUser)
        print('🛡️ [CHANGE_PAGE] Preparando refresh manual de TopicCubit...');
        final topicCubit = context.read<TopicCubit>();
        topicCubit.prepareManualRefresh();

        if (!mounted) return;

        // 2. Actualizar el usuario en AuthCubit (el listener será ignorado)
        print('👤 [CHANGE_PAGE] Refrescando usuario en AuthCubit...');
        await authCubit.refreshUser();
        print('✅ [CHANGE_PAGE] Usuario refrescado. specialty_id: ${authCubit.state.user.specialtyId}');

        if (!mounted) return;

        // 3. Resetear el LoadingCubit para que la navegación funcione correctamente
        print('🔄 [CHANGE_PAGE] Reseteando LoadingCubit...');
        final loadingCubit = context.read<LoadingCubit>();
        loadingCubit.reset();

        if (!mounted) return;

        // 4. Navegar a loading page
        print('🧭 [CHANGE_PAGE] Navegando a /loading...');
        context.go(AppRoutes.loading);

        if (!mounted) return;

        // 5. Recargar los topics (esto incluye limpieza del estado)
        print('🔄 [CHANGE_PAGE] Llamando a topicCubit.refresh()...');
        await topicCubit.refresh();
        print('✅ [CHANGE_PAGE] topicCubit.refresh() completado');

        if (!mounted) return;

        // 6. El listener de LoadingCubit navegará automáticamente a home
        // cuando dataReady y videoReady estén en true

        print('✅ [CHANGE_PAGE] Cambio de especialidad completado exitosamente');
        print('🔄 [CHANGE_PAGE] ========================================');

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Especialidad cambiada a: ${_selectedSpecialty!.name}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cambiar la especialidad'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
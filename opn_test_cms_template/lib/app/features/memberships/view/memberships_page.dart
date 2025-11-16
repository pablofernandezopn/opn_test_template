import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/features/memberships/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/memberships/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/memberships/model/membership_level_model.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/model/specialty.dart';

class MembershipsPage extends StatefulWidget {
  static const String route = '/memberships';

  const MembershipsPage({super.key});

  @override
  State<MembershipsPage> createState() => _MembershipsPageState();
}

class _MembershipsPageState extends State<MembershipsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar niveles de membresía y especialidades al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MembershipCubit>().fetchMembershipLevels(withStats: true);
      context.read<SpecialtyCubit>().loadSpecialties();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      context.read<MembershipCubit>().clearSearch();
    } else {
      context.read<MembershipCubit>().searchMembershipLevels(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.card_membership,
                  size: 32,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Niveles de Membresía',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gestiona los niveles de membresía y planes de la academia',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search bar
            TextField(
              controller: _searchController,
              onChanged: _handleSearch,
              decoration: InputDecoration(
                hintText: 'Buscar niveles de membresía...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child: BlocBuilder<MembershipCubit, MembershipState>(
                builder: (context, state) {
                  // Loading state
                  if (state.fetchMembershipLevelsStatus.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Error state
                  if (state.fetchMembershipLevelsStatus.isError) {
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
                            'Error al cargar niveles de membresía',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.error ?? 'Error desconocido',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () {
                              context
                                  .read<MembershipCubit>()
                                  .fetchMembershipLevels(withStats: true);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Empty state
                  if (state.membershipLevels.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_membership_outlined,
                            size: 64,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.searchQuery != null &&
                                    state.searchQuery!.isNotEmpty
                                ? 'No se encontraron niveles de membresía'
                                : 'No hay niveles de membresía',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.searchQuery != null &&
                                    state.searchQuery!.isNotEmpty
                                ? 'Intenta con otra búsqueda'
                                : 'Crea el primer nivel de membresía',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Success state - Lista de niveles
                  return ListView.separated(
                    itemCount: state.membershipLevels.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final level = state.membershipLevels[index];
                      final userCount =
                          context.read<MembershipCubit>().getUserCountForLevel(
                                level.id ?? 0,
                              );

                      final specialties =
                          context.read<SpecialtyCubit>().state.specialties;

                      return _MembershipLevelCard(
                        level: level,
                        userCount: userCount,
                        specialties: specialties,
                        // onTap: () {
                        //   context
                        //       .read<MembershipCubit>()
                        //       .selectMembershipLevel(level);
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(
                        //       content: Text('Seleccionado: ${level.name}'),
                        //     ),
                        //   );
                        // },
                        onToggleActive: (isActive) {
                          if (level.id != null) {
                            context
                                .read<MembershipCubit>()
                                .toggleMembershipLevelStatus(
                                    level.id!, isActive);
                          }
                        },
                        onSpecialtyChanged: (specialtyId) async {
                          final updatedLevel =
                              level.copyWith(specialtyId: specialtyId);
                          await context
                              .read<MembershipCubit>()
                              .updateMembershipLevel(updatedLevel);

                          if (context
                                  .read<MembershipCubit>()
                                  .state
                                  .updateMembershipLevelStatus
                                  .isDone &&
                              context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Especialidad actualizada exitosamente para "${level.name}"'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (context
                                  .read<MembershipCubit>()
                                  .state
                                  .updateMembershipLevelStatus
                                  .isError &&
                              context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error al actualizar: ${context.read<MembershipCubit>().state.error}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      );
                    },
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

class _MembershipLevelCard extends StatelessWidget {
  final MembershipLevel level;
  final int userCount;
  final List<Specialty> specialties;
  // final VoidCallback onTap;

  final Function(bool) onToggleActive;
  final Function(int) onSpecialtyChanged;

  const _MembershipLevelCard({
    required this.level,
    required this.userCount,
    required this.specialties,
    // required this.onTap,
    required this.onToggleActive,
    required this.onSpecialtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con nombre y estado
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              level.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: level.isActive
                                    ? colorScheme.primaryContainer
                                    : colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                level.isActive ? 'Activo' : 'Inactivo',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: level.isActive
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (level.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            level.description!,
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
                  // Switch(
                  //   value: level.isActive,
                  //   onChanged: onToggleActive,
                  // ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<int>(
                      value: level.specialtyId,
                      underline: const SizedBox.shrink(),
                      isDense: true,
                      items: specialties.map((specialty) {
                        return DropdownMenuItem<int>(
                          value: specialty.id!,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (specialty.colorHex != null) ...[
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Color(
                                      int.parse(specialty.colorHex!
                                          .replaceFirst('#', '0xFF')),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(specialty.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newSpecialtyId) {
                        if (newSpecialtyId != null) {
                          onSpecialtyChanged(newSpecialtyId);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Información del nivel
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  _InfoChip(
                    icon: Icons.euro,
                    label: 'Precio',
                    value: level.formattedPrice,
                  ),
                  _InfoChip(
                    icon: Icons.calendar_today,
                    label: 'Duración',
                    value: level.durationDescription,
                  ),
                  _InfoChip(
                    icon: Icons.people,
                    label: 'Usuarios',
                    value: userCount.toString(),
                  ),
                  _InfoChip(
                    icon: Icons.security,
                    label: 'Nivel de acceso',
                    value: level.accessLevel.toString(),
                  ),
                  if (level.isRecurring)
                    _InfoChip(
                      icon: Icons.repeat,
                      label: 'Tipo',
                      value: 'Recurrente',
                    ),
                  if (level.hasTrial)
                    _InfoChip(
                      icon: Icons.card_giftcard,
                      label: 'Trial',
                      value: '${level.trialDays} días',
                    ),
                ],
              ),

              // IDs de integración
              if (level.wordpressRcpId != null ||
                  level.revenuecatProductIds.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (level.wordpressRcpId != null) ...[
                      Icon(
                        Icons.wordpress,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'WP RCP: ${level.wordpressRcpId}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (level.revenuecatProductIds.isNotEmpty) ...[
                      Icon(
                        Icons.shopping_cart,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'RevenueCat: ${level.revenuecatProductIds.length} producto(s)',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

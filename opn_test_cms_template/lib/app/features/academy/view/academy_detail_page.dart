import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/cubit/auth_cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/model/user.dart';
import 'package:opn_test_guardia_civil_cms/app/config/widgets/table/reorderable_table.dart';
import 'package:opn_test_guardia_civil_cms/app/features/academy/view/components/tutor_modal.dart';
import 'package:opn_test_guardia_civil_cms/bootstrap.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';
import '../model/academy_model.dart';
import 'components/academy_form_dialog.dart';

/// Página de perfil/dashboard de una academia individual.
///
/// Muestra información detallada, estadísticas y permite editar
/// (solo para Super Admin).
class AcademyDetailPage extends StatefulWidget {
  final int academyId;

  const AcademyDetailPage({
    super.key,
    required this.academyId,
  });

  static const String route = '/academy';

  @override
  State<AcademyDetailPage> createState() => _AcademyDetailPageState();
}

class _AcademyDetailPageState extends State<AcademyDetailPage> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _loadAcademyData() async {
    final cubit = context.read<AcademyCubit>();
    // Buscar la academia en la lista actual
    final academy = cubit.state.academies.firstWhere(
      (a) => a.id == widget.academyId,
      orElse: () => Academy.empty,
    );

    if (academy.id != null) {
      await cubit.selectAcademy(academy);
    }
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadAcademyData(),
      _loadTutors(),
    ]);
  }

  Future<void> _loadTutors() async {
    await context.read<AcademyCubit>().fetchTutorsByAcademy(widget.academyId);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AcademyCubit>();
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<AcademyCubit, AcademyState>(
      builder: (context, state) {
        // Buscar la academia en la lista, ya sea selectedAcademy o por ID
        Academy? academy = state.selectedAcademy?.id == widget.academyId
            ? state.selectedAcademy
            : state.academies.firstWhere(
                (a) => a.id == widget.academyId,
                orElse: () => Academy.empty,
              );

        // Si la academia no se encontró, mostrar loading
        if (academy == null || academy.id == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                // Logo o inicial de la academia
                if (academy.logoUrl != null)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipOval(
                      child: Image.network(
                        academy.logoUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => CircleAvatar(
                          backgroundColor: colorScheme.onPrimary,
                          foregroundColor: colorScheme.primary,
                          child: Text(
                            academy.name.isNotEmpty
                                ? academy.name[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: BoxBorder.all(color: colorScheme.onSecondary)),
                    child: CircleAvatar(
                      backgroundColor: colorScheme.onPrimary,
                      foregroundColor: colorScheme.primary,
                      child: Text(
                        academy.name.isNotEmpty
                            ? academy.name[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    academy.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            foregroundColor: colorScheme.onPrimary,
            actions: [
              // Botón de editar (solo Admin)
              if (cubit.isAdmin)
                IconButton(
                  onPressed: () => _showEditDialog(context, academy),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar Academia',
                ),
              // Botón de activar/desactivar (solo Admin, no OPN)
              // if (cubit.isAdmin && academy.id != 1)
              //   IconButton(
              //     onPressed: () => cubit.toggleAcademyStatus(
              //       academy.id!,
              //       !academy.isActive,
              //     ),
              //     icon: Icon(
              //       academy.isActive ? Icons.toggle_on : Icons.toggle_off,
              //     ),
              //     tooltip: academy.isActive ? 'Desactivar' : 'Activar',
              //   ),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildContent(context, state, academy),
        );
      },
    );
  }

  Widget _buildContent(
      BuildContext context, AcademyState state, Academy academy) {
    final stats = state.selectedAcademyStats;
    final tutors = context.read<AcademyCubit>().state.tutors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estadísticas
          _buildStatsSection(context, stats, state.statsStatus),
          const SizedBox(height: 24),

          // Información General y Contacto
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información General
              Expanded(
                child: _buildInfoCard(context, academy),
              ),
              const SizedBox(width: 16),
              // Información de Contacto
              Expanded(
                child: _buildContactCard(context, academy),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tabla de tutores con título
          _buildTutorsSection(context, tutors),
        ],
      ),
    );
  }

  Widget _buildTutorsSection(BuildContext context, List<CmsUser> tutors) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cubit = context.read<AcademyCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de la tabla
        Row(
          children: [
            Icon(
              Icons.school,
              size: 32,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tutores de la Academia',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Gestiona los tutores asignados a esta academia',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (cubit.isAdmin)
              FilledButton.icon(
                onPressed: () => _showAddTutorDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Añadir Tutor'),
              ),
          ],
        ),
        const SizedBox(height: 24),

        // Tabla de tutores
        _buildTutorsTable(context, tutors),
      ],
    );
  }

  void _showAddTutorDialog() {
    showDialog(
      context: context,
      builder: (context) => TutorFormDialog(
        academyId: widget.academyId,
        onSave: (data) async {
          final roleId = data['role'] as UserRole;

          logger.info(data);

          final success = await context.read<AcademyCubit>().createTutor(
                academyId: widget.academyId,
                username: data['username'],
                email: data['email'],
                password: data['password'],
                name: data['name'],
                lastName: data['surname'],
                roleId: roleId.id,
              );
          logger.debug('esqureliste');
          if (success && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tutor creado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTutorsTable(BuildContext context, List<CmsUser> tutors) {
    final colorScheme = Theme.of(context).colorScheme;

    Color getRoleColor(UserRole role) {
      switch (role) {
        case UserRole.admin:
          return Colors.blue;
        case UserRole.superAdmin:
          return Colors.purple;
        case UserRole.tutor:
          return Colors.orange;
        case UserRole.user:
          return colorScheme.primary;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ReorderableTable<CmsUser>(
          items: tutors,
          showDragHandle:
              false, // Desactivar drag handle si no necesitas reordenamiento
          onReorder: (oldIndex, newIndex) {
            // Implementar lógica de reordenamiento si es necesario
            // Por ahora, no hacemos nada
          },
          columns: [
            ReorderableTableColumnConfig<CmsUser>(
              id: 'user',
              label: 'Usuario',
              flex: 4,
              valueGetter: (tutor) => tutor.fullName,
              cellBuilder: (tutor) => _CustomTutorName(
                tutor: tutor,
                getRoleColor: getRoleColor,
              ),
            ),
            ReorderableTableColumnConfig<CmsUser>(
              id: 'specialty',
              label: 'Especialidad',
              flex: 2,
              valueGetter: (tutor) => tutor.specialty?.name ?? '',
              cellBuilder: (tutor) => tutor.specialty != null
                  ? Row(
                      children: [
                        Icon(
                          Icons.school,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tutor.specialty!.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : const Text('-'),
            ),
            ReorderableTableColumnConfig<CmsUser>(
              id: 'role',
              label: 'Rol',
              flex: 1,
              alignment: Alignment.center,
              valueGetter: (tutor) => tutor.roleName,
              cellBuilder: (tutor) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: getRoleColor(tutor.role).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: getRoleColor(tutor.role).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  tutor.roleName,
                  style: TextStyle(
                    color: getRoleColor(tutor.role),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
          rowActions: (tutor) => [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditTutorDialog(tutor),
              tooltip: 'Editar',
              color: colorScheme.primary,
              iconSize: 20,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(tutor),
              tooltip: 'Eliminar',
              color: colorScheme.error,
              iconSize: 20,
            ),
          ],
          emptyMessage: 'No hay tutores en esta academia',
        ),
      ),
    );
  }

  void _showEditTutorDialog(CmsUser tutor) {
    showDialog(
      context: context,
      builder: (context) => TutorFormDialog(
        academyId: widget.academyId,
        tutor: tutor,
        onSave: (data) async {
          final roleId = data['role'] as UserRole;

          final success = await context.read<AcademyCubit>().updateTutor(
              tutorId: tutor.id,
              username: data['username'],
              email: data['email'],
              name: data['nombre'],
              lastName: data['apellido'],
              roleId: roleId.id
              // specialtyId: data['specialtyId'] as int?,
              );

          if (success && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tutor actualizado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(CmsUser tutor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tutor'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${tutor.fullName}?\n\n'
          'Esta acción marcará al tutor como inactivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final success = await context.read<AcademyCubit>().deleteTutor(
                    tutorId: tutor.id,
                  );

              if (success && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tutor eliminado exitosamente'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    Map<String, int> stats,
    Status statsStatus,
  ) {
    if (statsStatus.isLoading) {
      return const Center(
        child: SizedBox(
          height: 40,
          child: CircularProgressIndicator(),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fila principal de estadísticas
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.person,
                label: 'Usuarios',
                value: stats['total_users']?.toString() ?? '0',
              ),
              _buildStatDivider(colorScheme),
              _buildStatItem(
                context,
                icon: Icons.quiz,
                label: 'Preguntas',
                value: stats['total_questions']?.toString() ?? '0',
              ),
              _buildStatDivider(colorScheme),
              _buildStatItem(
                context,
                icon: Icons.assignment,
                label: 'Tests',
                value: stats['total_tests']?.toString() ?? '0',
              ),
              _buildStatDivider(colorScheme),
              _buildStatItem(
                context,
                icon: Icons.workspace_premium,
                label: 'Premium',
                value: stats['total_premium_users']?.toString() ?? '0',
              ),
              _buildStatDivider(colorScheme),
              _buildStatItem(
                context,
                icon: Icons.star,
                label: 'Premium Plus',
                value: stats['premium_plus_users']?.toString() ?? '0',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Fila de actividad diaria
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.today,
                label: 'Activos Hoy',
                value: stats['total_users_today']?.toString() ?? '0',
              ),
              _buildStatDivider(colorScheme),
              _buildStatItem(
                context,
                icon: Icons.person_add,
                label: 'Nuevos Hoy',
                value: stats['new_users_today']?.toString() ?? '0',
              ),
              _buildStatDivider(colorScheme),
              _buildStatItem(
                context,
                icon: Icons.check_circle,
                label: 'Respuestas Hoy',
                value: stats['total_answers_today']?.toString() ?? '0',
              ),
              _buildStatDivider(colorScheme),
              _buildStatItem(
                context,
                icon: Icons.style,
                label: 'Flashcards Hoy',
                value:
                    stats['total_flashcard_answers_today']?.toString() ?? '0',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(ColorScheme colorScheme) {
    return Container(
      width: 1,
      height: 40,
      color: colorScheme.outlineVariant.withOpacity(0.3),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Academy academy) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Información General',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('ID', academy.id?.toString() ?? '-'),
          _buildInfoRow('Nombre', academy.name),
          _buildInfoRow('Slug', academy.slug),
          if (academy.description != null)
            _buildInfoRow('Descripción', academy.description!),
          if (academy.website != null)
            _buildInfoRow('Sitio Web', academy.website!),
          if (academy.address != null)
            _buildInfoRow('Dirección', academy.address!),
          const Divider(height: 32),
          if (academy.createdAt != null)
            _buildInfoRow(
              'Creada',
              dateFormat.format(academy.createdAt!),
            ),
          if (academy.updatedAt != null)
            _buildInfoRow(
              'Actualizada',
              dateFormat.format(academy.updatedAt!),
            ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, Academy academy) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUser = context.read<AuthCubit>().state.user;
    final canEdit = currentUser.isAdmin || currentUser.isSuperAdmin;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_mail, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Información de Contacto',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (canEdit)
                IconButton(
                  onPressed: () => _showEditContactDialog(context, academy),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar Información de Contacto',
                  iconSize: 20,
                  color: colorScheme.primary,
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (academy.contactEmail != null) ...[
            _buildContactRow(
              icon: Icons.email,
              label: 'Email',
              value: academy.contactEmail!,
            ),
            const SizedBox(height: 16),
          ],
          if (academy.contactPhone != null) ...[
            _buildContactRow(
              icon: Icons.phone,
              label: 'Teléfono',
              value: academy.contactPhone!,
            ),
            const SizedBox(height: 16),
          ],
          if (academy.contactEmail == null && academy.contactPhone == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.contact_mail_outlined,
                      size: 48,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sin información de contacto',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, Academy academy) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AcademyCubit>(),
        child: AcademyFormDialog(academy: academy),
      ),
    );
  }

  void _showEditContactDialog(BuildContext context, Academy academy) {
    final emailController = TextEditingController(text: academy.contactEmail);
    final phoneController = TextEditingController(text: academy.contactPhone);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar Información de Contacto'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email de Contacto',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono de Contacto',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(), // ✅ Usa Navigator.of()
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final updatedAcademy = academy.copyWith(
                contactEmail: emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim(),
                contactPhone: phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim(),
              );

              // ✅ Cierra el diálogo ANTES de la operación async
              Navigator.of(dialogContext).pop();

              try {
                await context
                    .read<AcademyCubit>()
                    .updateAcademy(updatedAcademy);

                // ✅ Usa context (no dialogContext) para el SnackBar
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Información de contacto actualizada'),
                      backgroundColor: Colors.green,
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
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Widget personalizado para la columna Usuario
// ============================================

class _CustomTutorName extends StatelessWidget {
  const _CustomTutorName({
    required this.tutor,
    required this.getRoleColor,
  });

  final CmsUser tutor;
  final Color Function(UserRole role) getRoleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String name = tutor.username;
    String profileImage = tutor.avatarUrl ?? '';

    if (tutor.name.isNotEmpty) {
      name = '${tutor.name} ${tutor.lastName}'.trim();
    }

    final roleColor = getRoleColor(tutor.role);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Avatar con color según rol
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: roleColor.withOpacity(0.1),
            border: Border.all(color: roleColor.withOpacity(0.5), width: 2),
          ),
          child: profileImage.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    profileImage,
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        tutor.initials,
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                )
              : Text(
                  tutor.initials,
                  style: TextStyle(
                    color: roleColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        // Información del tutor
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nombre completo y username
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(@${tutor.username})',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Email con botón para copiar
              InkWell(
                onTap: (tutor.email?.isEmpty ?? true)
                    ? null
                    : () => _copyToClipboard(
                          context,
                          tutor.email!,
                          'Email copiado',
                        ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 12,
                      color: (tutor.email?.isEmpty ?? true)
                          ? colorScheme.onSurface.withOpacity(0.4)
                          : colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        (tutor.email?.isEmpty ?? true)
                            ? 'Sin email'
                            : (tutor.email!.length > 30
                                ? '${tutor.email!.substring(0, 30)}...'
                                : tutor.email!),
                        style: TextStyle(
                          fontSize: 13,
                          color: (tutor.email?.isEmpty ?? true)
                              ? colorScheme.onSurface.withOpacity(0.4)
                              : colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (tutor.email?.isNotEmpty ?? false) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.copy,
                        size: 12,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Copia texto al portapapeles y muestra un snackbar
  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

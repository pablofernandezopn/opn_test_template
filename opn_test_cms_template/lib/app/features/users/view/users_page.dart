import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_guardia_civil_cms/app/config/widgets/table/reorderable_table.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/view/components/user_filters.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/model/user.dart';
import 'package:opn_test_guardia_civil_cms/app/config/theme/color.dart';

class UsersPage extends StatefulWidget {
  static const String route = '/students';

  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Cargar usuarios al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserCubit>().fetchUsers();
    });

    // Agregar listener para scroll infinito
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final cubit = context.read<UserCubit>();
      final state = cubit.state;

      // Si hay una búsqueda activa, cargar más resultados de búsqueda
      if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
        cubit.loadMoreSearchResults();
      } else {
        // Si no hay búsqueda, cargar más usuarios normales
        cubit.loadMoreUsers();
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Activar cuando estemos a 200 píxeles del final
    return currentScroll >= (maxScroll - 200);
  }

  void _handleReorder(int oldIndex, int newIndex) {
    // Manejar el reordenamiento de usuarios si es necesario
    setState(() {
      // La lógica de reordenamiento la maneja el widget internamente
    });
  }

  void _navigateToUserStats(User user) {
    context.push('/students/${user.id}/stats');
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
                  Icons.people,
                  size: 32,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestión de Alumnos',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Administra los usuarios registrados en la plataforma',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => context.push('/students/add'),
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir Alumno'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Barra de búsqueda
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Buscar por nombre, apellido, email o usuario...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<UserCubit>().clearSearch();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length >= 3 || value.isEmpty) {
                        context.read<UserCubit>().searchUsers(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton.filled(
                  onPressed: () {
                    context.read<UserCubit>().fetchUsers();
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Recargar',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filtros
            const UserFilters(),
            const SizedBox(height: 24),

            // Lista de usuarios
            Expanded(
              child: BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  // Estado de carga inicial
                  if (state.fetchUsersStatus.isLoading ||
                      state.searchUsersStatus.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Estado de error
                  if (state.fetchUsersStatus.isError) {
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
                            'Error al cargar usuarios',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.error ?? 'Error desconocido',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () {
                              context.read<UserCubit>().fetchUsers();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Lista vacía
                  if (state.users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.searchQuery != null
                                ? 'No se encontraron usuarios'
                                : 'No hay usuarios registrados',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.searchQuery != null
                                ? 'Intenta con otro término de búsqueda'
                                : 'Comienza añadiendo un nuevo usuario',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (state.searchQuery == null)
                            FilledButton.icon(
                              onPressed: () => context.push('/students/add'),
                              icon: const Icon(Icons.add),
                              label: const Text('Añadir Primer Usuario'),
                            ),
                        ],
                      ),
                    );
                  }

                  // Lista de usuarios con scroll infinito
                  return Column(
                    children: [
                      Expanded(
                        child: ReorderableTable<User>(
                          scrollController: _scrollController,
                          items: state.users,
                          columns: [
                            ReorderableTableColumnConfig<User>(
                              id: 'username',
                              label: 'Usuario',
                              flex: 4,
                              valueGetter: (user) => user.username,
                              cellBuilder: (user) =>
                                  _CustomUserName(user: user),
                            ),
                            ReorderableTableColumnConfig<User>(
                              id: 'phone',
                              label: 'Teléfono',
                              flex: 2,
                              valueGetter: (user) =>
                                  user.phone ?? 'Sin teléfono',
                            ),
                            // ReorderableTableColumnConfig<User>(
                            //   id: 'membership',
                            //   label: 'Membresía',
                            //   flex: 2,
                            //   valueGetter: (user) => user.membershipLevelName,
                            //   cellBuilder: (user) => Container(
                            //     padding: const EdgeInsets.symmetric(
                            //       horizontal: 12,
                            //       vertical: 4,
                            //     ),
                            //     decoration: BoxDecoration(
                            //       color: _getMembershipColor(
                            //           user.maxAccessLevel, colorScheme),
                            //       borderRadius: BorderRadius.circular(12),
                            //     ),
                            //     child: Text(
                            //       user.membershipLevelName,
                            //       style: TextStyle(
                            //         color: colorScheme.onPrimary,
                            //         fontSize: 12,
                            //         fontWeight: FontWeight.w500,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            ReorderableTableColumnConfig<User>(
                              id: 'specialty',
                              label: 'Especialidad',
                              flex: 2,
                              valueGetter: (user) =>
                                  user.specialty?.name ?? 'Sin especialidad',
                            ),
                          ],
                          onReorder: _handleReorder,
                          onItemTap: _navigateToUserStats,
                          isLoading: false,
                          emptyMessage: 'No hay usuarios registrados',
                          showDragHandle: true,
                          rowActions: (user) => [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () {
                                context.read<UserCubit>().selectUser(user);
                              },
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              onPressed: () {
                                _showDeleteConfirmation(context, user);
                              },
                              tooltip: 'Eliminar',
                            ),
                          ],
                        ),
                      ),
                      // Indicador de carga al final
                      if (state.isLoadingMore)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Cargando más usuarios...',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Mensaje cuando no hay más usuarios
                      if (!state.hasMorePages && state.users.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No hay más usuarios para mostrar',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, User user) {
    final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar al usuario $fullName?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<UserCubit>().deleteUser(user.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Widget personalizado para la columna Usuario
// ============================================

class _CustomUserName extends StatelessWidget {
  const _CustomUserName({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String name = user.username;
    String profileImage = user.profileImage ?? '';

    if ((user.firstName ?? '').isNotEmpty) {
      name = '${user.firstName} ${user.lastName}'.trim();
    }

    final (bgColor, borderColor) = _getUserColors();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Avatar con badge de membresía
        Stack(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                border: Border.all(color: borderColor, width: 2),
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
                            name.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                    )
                  : Text(
                      name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
            // Badge de membresía
            if (user.isPremiumPlus || user.isPremium)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        user.isPremiumPlus ? AppColors.gold : AppColors.silver,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Text(
                    user.isPremiumPlus ? 'PLUS' : 'PRE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Información del usuario
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
                    '(${user.username})',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Email con botón para copiar
              InkWell(
                onTap: (user.email?.isEmpty ?? true)
                    ? null
                    : () =>
                        _copyToClipboard(context, user.email!, 'Email copiado'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 12,
                      color: (user.email?.isEmpty ?? true)
                          ? AppColors.greyMedium
                          : AppColors.grey,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        (user.email?.isEmpty ?? true)
                            ? 'Sin email'
                            : (user.email!.length > 30
                                ? '${user.email!.substring(0, 30)}...'
                                : user.email!),
                        style: TextStyle(
                          fontSize: 13,
                          color: (user.email?.isEmpty ?? true)
                              ? AppColors.greyMedium
                              : AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.email?.isNotEmpty ?? false) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.copy,
                        size: 12,
                        color: AppColors.grey,
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

  /// Determina los colores del avatar según el tipo de usuario
  (Color, Color) _getUserColors() {
    // Priority: Premium Plus > Premium > External Academy > Normal
    if (user.isPremiumPlus) {
      return (AppColors.greyLight, AppColors.gold);
    } else if (user.isPremium) {
      return (AppColors.greyLight, AppColors.silver);
    } else if (user.academyId != 1) {
      // Academia externa (asumiendo que academyId 1 es la principal)
      return (const Color(0xFFF3E8FF), const Color(0xFF9333EA)); // Purple tones
    } else {
      return (AppColors.greyLight, AppColors.greyMedium);
    }
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

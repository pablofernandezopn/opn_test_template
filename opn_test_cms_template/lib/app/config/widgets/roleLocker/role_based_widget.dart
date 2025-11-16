import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/cubit/auth_cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/cubit/auth_state.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/model/user.dart';
import 'package:opn_test_guardia_civil_cms/app/config/layout/lateral_menu.dart';

/// Widget que muestra u oculta su contenido basándose en el rol del usuario autenticado.
///
/// Este widget utiliza [BlocSelector] para escuchar cambios en el estado de autenticación
/// y mostrar/ocultar el widget hijo según los roles permitidos.
///
/// **Ejemplo básico - Ocultar elemento para usuarios básicos:**
/// ```dart
/// RoleBasedWidget(
///   allowedRoles: [UserRole.admin, UserRole.editor],
///   child: ElevatedButton(
///     onPressed: () => deleteItem(),
///     child: Text('Eliminar'),
///   ),
/// )
/// ```
///
/// **Ejemplo con widget alternativo:**
/// ```dart
/// RoleBasedWidget(
///   allowedRoles: [UserRole.admin],
///   fallback: Text('No tienes permisos para ver este contenido'),
///   child: AdminPanel(),
/// )
/// ```
///
/// **Ejemplo con rol mínimo (inclusivo hacia arriba):**
/// ```dart
/// RoleBasedWidget(
///   minimumRole: UserRole.editor,  // Muestra para Editor, Admin y SuperAdmin
///   child: EditButton(),
/// )
/// ```
///
/// **Ejemplo con modo de ocultación:**
/// ```dart
/// RoleBasedWidget(
///   allowedRoles: [UserRole.admin],
///   hideMode: RoleHideMode.invisible,  // Mantiene el espacio pero invisible
///   child: SuperAdminSettings(),
/// )
/// ```
class RoleBasedWidget extends StatelessWidget {
  /// El widget hijo que se mostrará si el usuario tiene los permisos necesarios
  final Widget child;

  /// Lista de roles permitidos. Si el usuario tiene alguno de estos roles, se mostrará el widget.
  /// No usar junto con [minimumRole].
  final List<UserRole>? allowedRoles;

  /// Rol mínimo requerido. Si se especifica, se mostrarán para este rol y todos los superiores.
  /// Por ejemplo, si es [UserRole.editor], se mostrará para Editor, Admin y SuperAdmin.
  /// No usar junto con [allowedRoles].
  final UserRole? minimumRole;

  /// Widget que se mostrará cuando el usuario NO tenga los permisos necesarios.
  /// Si no se especifica, no se mostrará nada (según [hideMode]).
  final Widget? fallback;

  /// Modo de ocultación cuando el usuario no tiene permisos.
  /// - [RoleHideMode.remove]: Elimina completamente el widget del árbol (por defecto)
  /// - [RoleHideMode.invisible]: Mantiene el espacio pero hace el widget invisible
  final RoleHideMode hideMode;

  /// Si es true, invierte la lógica: muestra el widget solo cuando el usuario NO tiene los roles especificados.
  /// Útil para mostrar mensajes como "Actualiza tu suscripción" solo a usuarios básicos.
  final bool invertLogic;

  const RoleBasedWidget({
    super.key,
    required this.child,
    this.allowedRoles,
    this.minimumRole,
    this.fallback,
    this.hideMode = RoleHideMode.remove,
    this.invertLogic = false,
  })  : assert(
          allowedRoles != null || minimumRole != null,
          'Debe especificar allowedRoles o minimumRole',
        ),
        assert(
          !(allowedRoles != null && minimumRole != null),
          'No puede especificar allowedRoles y minimumRole al mismo tiempo',
        );

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthCubit, AuthState, CmsUser>(
      selector: (state) => state.user,
      builder: (context, user) {
        final hasPermission = _checkPermission(user);
        final shouldShow = invertLogic ? !hasPermission : hasPermission;

        if (shouldShow) {
          return child;
        }

        // Usuario no tiene permisos
        if (fallback != null) {
          return fallback!;
        }

        return _buildHiddenWidget();
      },
    );
  }

  /// Verifica si el usuario tiene los permisos necesarios
  bool _checkPermission(CmsUser user) {
    // Si se especificó una lista de roles permitidos
    if (allowedRoles != null) {
      return allowedRoles!.any((role) => _userHasRole(user, role));
    }

    // Si se especificó un rol mínimo
    if (minimumRole != null) {
      return _userHasMinimumRole(user, minimumRole!);
    }

    return false;
  }

  /// Verifica si el usuario tiene un rol específico
  bool _userHasRole(CmsUser user, UserRole role) {
    return user.role == role;
  }

  /// Verifica si el usuario tiene el rol mínimo o superior
  bool _userHasMinimumRole(CmsUser user, UserRole minimum) {
    switch (minimum) {
      case UserRole.admin:
        return user.isAdmin; // Incluye Admin y SuperAdmin
      case UserRole.superAdmin:
        return user.isSuperAdmin; // Incluye Editor, Admin y SuperAdmin
      case UserRole.tutor:
        return user.isTutor;
      case UserRole.user:
        return true; // Todos los usuarios
    }
  }

  /// Construye el widget oculto según el modo de ocultación
  Widget _buildHiddenWidget() {
    switch (hideMode) {
      case RoleHideMode.remove:
        return const SizedBox.shrink();
      case RoleHideMode.invisible:
        return Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: child,
        );
    }
  }
}

/// Modo de ocultación del widget cuando el usuario no tiene permisos
enum RoleHideMode {
  /// Elimina completamente el widget del árbol (no ocupa espacio)
  remove,

  /// Mantiene el espacio del widget pero lo hace invisible
  invisible,
}

// ============================================================================
// WIDGETS DE CONVENIENCIA
// ============================================================================

/// Widget de conveniencia para mostrar contenido solo a administradores (Admin y SuperAdmin)
class AdminOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleBasedWidget(
      minimumRole: UserRole.admin,
      fallback: fallback,
      child: child,
    );
  }
}

/// Widget de conveniencia para mostrar contenido solo a Tutores y superiores
class TutorOrAbove extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const TutorOrAbove({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleBasedWidget(
      minimumRole: UserRole.tutor,
      fallback: fallback,
      child: child,
    );
  }
}

/// Widget de conveniencia para mostrar contenido a editores y superiores (Editor, Admin)
class EditorOrAbove extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const EditorOrAbove({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleBasedWidget(
      minimumRole: UserRole.admin,
      fallback: fallback,
      child: child,
    );
  }
}

/// Widget de conveniencia para mostrar contenido solo a usuarios básicos
class BasicUserOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const BasicUserOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleBasedWidget(
      allowedRoles: [UserRole.user],
      fallback: fallback,
      child: child,
    );
  }
}

// ============================================================================
// HELPER FUNCTION PARA USO FUERA DE WIDGETS
// ============================================================================

/// Extensión de BuildContext para verificar roles de manera conveniente
extension RoleCheckExtension on BuildContext {
  /// Verifica si el usuario autenticado actual tiene alguno de los roles especificados
  bool hasAnyRole(List<UserRole> roles) {
    final user = read<AuthCubit>().state.user;
    return roles.any((role) => user.role == role);
  }

  /// Verifica si el usuario autenticado actual tiene el rol mínimo especificado o superior
  bool hasMinimumRole(UserRole minimumRole) {
    final user = read<AuthCubit>().state.user;
    switch (minimumRole) {
      case UserRole.admin:
        return user.isAdmin;
      case UserRole.superAdmin:
        return user.isSuperAdmin;
      case UserRole.tutor:
        return user.isTutor;
      case UserRole.user:
        return true;
    }
  }

  /// Obtiene el usuario autenticado actual
  CmsUser get currentUser => read<AuthCubit>().state.user;
}

// ============================================================================
// SISTEMA DE FILTRADO PARA NAVIGATIONITEMDATA
// ============================================================================

/// Clase que extiende la funcionalidad de NavigationItemData con restricciones de roles.
///
/// Esta clase es necesaria porque NavigationItemData está definido en lateral_menu.dart
/// y no podemos modificarlo directamente. En su lugar, creamos esta clase que permite
/// asociar restricciones de roles a items de navegación.
///
/// **Uso:**
/// ```dart
/// final restrictedItem = RoleRestrictedNavigationItem(
///   navigationItem: NavigationItemData(
///     id: 'admin',
///     label: 'Panel Admin',
///     route: '/admin',
///   ),
///   minimumRole: UserRole.admin,
/// );
/// ```
class RoleRestrictedNavigationItem {
  /// El item de navegación original
  final dynamic navigationItem; // Tipo dynamic para evitar import circular

  /// Lista de roles permitidos. Si se especifica, solo los usuarios con alguno de estos roles verán el item.
  final List<UserRole>? allowedRoles;

  /// Rol mínimo requerido. Si se especifica, se mostrará para este rol y todos los superiores.
  final UserRole? minimumRole;

  const RoleRestrictedNavigationItem({
    required this.navigationItem,
    this.allowedRoles,
    this.minimumRole,
  })  : assert(
          allowedRoles != null || minimumRole != null,
          'Debe especificar allowedRoles o minimumRole',
        ),
        assert(
          !(allowedRoles != null && minimumRole != null),
          'No se puede especificar allowedRoles y minimumRole al mismo tiempo',
        );

  /// Verifica si el item es visible para el usuario dado
  bool isVisibleForUser(CmsUser user) {
    if (allowedRoles != null) {
      return allowedRoles!.any((role) => user.role == role);
    }

    if (minimumRole != null) {
      return _userHasMinimumRole(user, minimumRole!);
    }

    return true;
  }

  bool _userHasMinimumRole(CmsUser user, UserRole minimum) {
    switch (minimum) {
      case UserRole.superAdmin:
        return user.isSuperAdmin;
      case UserRole.admin:
        return user.isAdmin;
      case UserRole.tutor:
        return user.isTutor;
      case UserRole.user:
        return true;
    }
  }
}

// ============================================================================
// FUNCIONES HELPER PARA FILTRAR NAVIGATIONITEMDATA
// ============================================================================

/// Filtra una lista de NavigationItemData según las restricciones de roles especificadas.
///
/// **Parámetros:**
/// - `items`: Lista de NavigationItemData a filtrar
/// - `restrictions`: Mapa que asocia el ID del item con sus restricciones de rol
/// - `user`: Usuario actual para verificar permisos
///
/// **Ejemplo:**
/// ```dart
/// final restrictions = {
///   'admin': RoleRestriction(minimumRole: UserRole.admin),
///   'editor': RoleRestriction(minimumRole: UserRole.editor),
///   'super-admin': RoleRestriction(allowedRoles: [UserRole.admin]),
/// };
///
/// final filteredItems = filterNavigationItemsByRole(
///   navigationItems,
///   restrictions,
///   currentUser,
/// );
/// ```
List<T> filterNavigationItemsByRole<T>({
  required List<T> items,
  required Map<String, RoleRestriction> restrictions,
  required CmsUser user,
  required String Function(T) getId,
  required bool Function(T) hasChildren,
  required List<T> Function(T) getChildren,
  required T Function(T item, List<T> children) copyWithChildren,
}) {
  final filteredItems = <T>[];

  for (final item in items) {
    final itemId = getId(item);
    final restriction = restrictions[itemId];

    // Verificar si el item tiene restricciones de rol
    if (restriction != null && !restriction.isVisibleForUser(user)) {
      continue; // Saltar este item
    }

    // Si el item tiene hijos, filtrarlos recursivamente
    if (hasChildren(item)) {
      final children = getChildren(item);
      final filteredChildren = filterNavigationItemsByRole(
        items: children,
        restrictions: restrictions,
        user: user,
        getId: getId,
        hasChildren: hasChildren,
        getChildren: getChildren,
        copyWithChildren: copyWithChildren,
      );

      // Solo incluir el item si tiene hijos visibles o si el item en sí es visible
      if (filteredChildren.isNotEmpty) {
        filteredItems.add(copyWithChildren(item, filteredChildren));
      }
    } else {
      // Item sin hijos, añadirlo directamente
      filteredItems.add(item);
    }
  }

  return filteredItems;
}

/// Clase auxiliar para definir restricciones de rol
class RoleRestriction {
  final List<UserRole>? allowedRoles;
  final UserRole? minimumRole;

  const RoleRestriction({
    this.allowedRoles,
    this.minimumRole,
  })  : assert(
          allowedRoles != null || minimumRole != null,
          'Debe especificar allowedRoles o minimumRole',
        ),
        assert(
          !(allowedRoles != null && minimumRole != null),
          'No se puede especificar allowedRoles y minimumRole al mismo tiempo',
        );

  /// Constructor de conveniencia para rol mínimo
  const RoleRestriction.minimumRole(UserRole role)
      : minimumRole = role,
        allowedRoles = null;

  /// Constructor de conveniencia para roles específicos
  const RoleRestriction.allowedRoles(List<UserRole> roles)
      : allowedRoles = roles,
        minimumRole = null;

  /// Constructor de conveniencia: solo admins
  static const adminOnly = RoleRestriction(minimumRole: UserRole.admin);

  /// Constructor de conveniencia: solo super admins
  static const superAdminOnly =
      RoleRestriction(allowedRoles: [UserRole.superAdmin]);

  /// Constructor de conveniencia: editores y superiores
  static const editorOrAbove = RoleRestriction(minimumRole: UserRole.admin);

  bool isVisibleForUser(CmsUser user) {
    if (allowedRoles != null) {
      return allowedRoles!.any((role) => user.role == role);
    }

    if (minimumRole != null) {
      return _userHasMinimumRole(user, minimumRole!);
    }

    return true;
  }

  bool _userHasMinimumRole(CmsUser user, UserRole minimum) {
    switch (minimum) {
      case UserRole.superAdmin:
        return user.isSuperAdmin;
      case UserRole.admin:
        return user.isAdmin;
      case UserRole.tutor:
        return user.isTutor;
      case UserRole.user:
        return true;
    }
  }
}

// ============================================================================
// FUNCIONES HELPER SIMPLIFICADAS PARA NAVIGATIONITEMDATA
// ============================================================================

/// Filtra una lista de NavigationItemData según las restricciones de roles.
///
/// Esta es una versión simplificada que trabaja directamente con NavigationItemData
/// sin necesidad de parámetros genéricos complejos.
///
/// **Ejemplo básico:**
/// ```dart
/// // En lateral_menu.dart, dentro de build()
/// final currentUser = context.watch<AuthCubit>().state.user;
/// final restrictions = {
///   'specialties': RoleRestriction.adminOnly,
///   'academies': RoleRestriction.superAdminOnly,
///   'tests': RoleRestriction.editorOrAbove,
/// };
///
/// final filteredItems = filterNavigationItems(
///   allItems,
///   restrictions,
///   currentUser,
/// );
/// ```
///
/// **Parámetros:**
/// - `items`: Lista de NavigationItemData a filtrar
/// - `restrictions`: Mapa con ID del item como key y RoleRestriction como value
/// - `user`: Usuario actual
///
/// **Returns:** Lista filtrada de NavigationItemData según las restricciones
List<NavigationItemData> filterNavigationItems(
  List<NavigationItemData> items,
  Map<String, RoleRestriction> restrictions,
  CmsUser user,
) {
  final filteredItems = <NavigationItemData>[];

  for (final item in items) {
    final restriction = restrictions[item.id];

    // Verificar si el item tiene restricciones y si el usuario tiene permisos
    if (restriction != null && !restriction.isVisibleForUser(user)) {
      continue; // Saltar este item
    }

    // Si el item tiene children, filtrarlos recursivamente
    if (item.hasChildren) {
      final filteredChildren = filterNavigationItems(
        item.children!,
        restrictions,
        user,
      );

      // Solo incluir el item si tiene children visibles
      // O si el item padre en sí no tiene restricción (es decir, es visible)
      if (filteredChildren.isNotEmpty || restriction == null) {
        filteredItems.add(
          NavigationItemData(
            id: item.id,
            label: item.label,
            icon: item.icon,
            selectedIcon: item.selectedIcon,
            route: item.route,
            children: filteredChildren.isEmpty ? null : filteredChildren,
            onTap: item.onTap,
            badge: item.badge,
            badgeColor: item.badgeColor,
            isExpandedByDefault: item.isExpandedByDefault,
            iconSize: item.iconSize,
          ),
        );
      }
    } else {
      // Item sin children, añadirlo directamente si no hay restricción o si cumple la restricción
      if (restriction == null || restriction.isVisibleForUser(user)) {
        filteredItems.add(item);
      }
    }
  }

  return filteredItems;
}

/// Extensión para NavigationItemData que agrega métodos relacionados con roles
extension NavigationItemDataRoleExtension on NavigationItemData {
  /// Verifica si este item debe ser visible para el usuario dado según la restricción especificada
  bool isVisibleForUser(CmsUser user, RoleRestriction? restriction) {
    if (restriction == null) return true;
    return restriction.isVisibleForUser(user);
  }

  /// Crea una copia del item con children filtrados según restricciones
  NavigationItemData withFilteredChildren(
    Map<String, RoleRestriction> restrictions,
    CmsUser user,
  ) {
    if (!hasChildren) return this;

    final filteredChildren = filterNavigationItems(
      children!,
      restrictions,
      user,
    );

    return NavigationItemData(
      id: id,
      label: label,
      icon: icon,
      selectedIcon: selectedIcon,
      route: route,
      children: filteredChildren.isEmpty ? null : filteredChildren,
      onTap: onTap,
      badge: badge,
      badgeColor: badgeColor,
      isExpandedByDefault: isExpandedByDefault,
      iconSize: iconSize,
    );
  }
}

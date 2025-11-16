# Ejemplos de Uso - RoleBasedWidget

Este documento contiene ejemplos prácticos de cómo usar `RoleBasedWidget` y sus widgets de conveniencia para controlar la visibilidad de elementos según el rol del usuario.

## Índice
- [Uso Básico](#uso-básico)
- [Widgets de Conveniencia](#widgets-de-conveniencia)
- [Casos de Uso Comunes](#casos-de-uso-comunes)
- [Extensiones de BuildContext](#extensiones-de-buildcontext)
- [Ejemplos Avanzados](#ejemplos-avanzados)

---

## Uso Básico

### 1. Ocultar botón de eliminación para usuarios básicos

```dart
import 'package:opn_test_guardia_civil_cms/app/config/widgets/index.dart';

RoleBasedWidget(
  allowedRoles: [UserRole.admin, UserRole.superAdmin],
  child: ElevatedButton(
    onPressed: () => _deleteChallenge(),
    child: const Text('Eliminar'),
  ),
)
```

### 2. Mostrar panel de administración solo a administradores

```dart
RoleBasedWidget(
  minimumRole: UserRole.admin,  // Incluye Admin y SuperAdmin
  child: const AdminPanel(),
)
```

### 3. Widget alternativo cuando no tiene permisos

```dart
RoleBasedWidget(
  allowedRoles: [UserRole.editor, UserRole.admin, UserRole.superAdmin],
  fallback: Container(
    padding: const EdgeInsets.all(16),
    color: Colors.grey[200],
    child: const Text(
      'No tienes permisos para editar',
      style: TextStyle(color: Colors.grey),
    ),
  ),
  child: const EditForm(),
)
```

---

## Widgets de Conveniencia

### AdminOnly
Muestra contenido solo a administradores (Admin y SuperAdmin):

```dart
AdminOnly(
  child: ElevatedButton(
    onPressed: () => _manageUsers(),
    child: const Text('Gestionar Usuarios'),
  ),
)
```

### SuperAdminOnly
Muestra contenido solo a SuperAdmins:

```dart
SuperAdminOnly(
  fallback: const Text('Solo SuperAdmins pueden ver esto'),
  child: const SystemSettingsPanel(),
)
```

### EditorOrAbove
Muestra contenido a editores y superiores (Editor, Admin, SuperAdmin):

```dart
EditorOrAbove(
  child: FloatingActionButton(
    onPressed: () => _createNewPost(),
    child: const Icon(Icons.add),
  ),
)
```

### BasicUserOnly
Muestra contenido solo a usuarios básicos:

```dart
BasicUserOnly(
  child: Card(
    child: ListTile(
      leading: const Icon(Icons.star),
      title: const Text('¡Actualiza a Premium!'),
      subtitle: const Text('Accede a contenido exclusivo'),
      onTap: () => _showUpgradeDialog(),
    ),
  ),
)
```

---

## Casos de Uso Comunes

### 1. Menú con opciones según rol

```dart
class ProfileMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Todos los usuarios ven su perfil
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Mi Perfil'),
          onTap: () => context.push('/profile'),
        ),

        // Solo editores y superiores pueden crear contenido
        EditorOrAbove(
          child: ListTile(
            leading: const Icon(Icons.create),
            title: const Text('Crear Contenido'),
            onTap: () => context.push('/create'),
          ),
        ),

        // Solo administradores ven configuración
        AdminOnly(
          child: ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () => context.push('/settings'),
          ),
        ),

        // Solo SuperAdmin ve herramientas de sistema
        SuperAdminOnly(
          child: ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Herramientas de Sistema'),
            onTap: () => context.push('/system-tools'),
          ),
        ),
      ],
    );
  }
}
```

### 2. Tabla con acciones según permisos

```dart
class ChallengesTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: [
        const DataColumn(label: Text('Título')),
        const DataColumn(label: Text('Categoría')),

        // Columna de acciones solo visible para editores
        EditorOrAbove(
          child: const DataColumn(label: Text('Acciones')),
        ),
      ],
      rows: challenges.map((challenge) {
        return DataRow(
          cells: [
            DataCell(Text(challenge.title)),
            DataCell(Text(challenge.category)),

            // Botones de acción solo para editores
            DataCell(
              EditorOrAbove(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editChallenge(challenge),
                    ),

                    // Botón eliminar solo para admins
                    AdminOnly(
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteChallenge(challenge),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
```

### 3. Formulario con campos según permisos

```dart
class ChallengeForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          // Campos básicos (todos pueden verlos si pueden acceder al formulario)
          TextFormField(
            decoration: const InputDecoration(labelText: 'Título'),
          ),

          TextFormField(
            decoration: const InputDecoration(labelText: 'Descripción'),
            maxLines: 5,
          ),

          // Campo de estado solo para admins
          AdminOnly(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Estado'),
              items: ['borrador', 'publicado', 'archivado']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {},
            ),
          ),

          // Campo de prioridad solo para SuperAdmin
          SuperAdminOnly(
            child: SwitchListTile(
              title: const Text('Alta Prioridad'),
              value: false,
              onChanged: (value) {},
            ),
          ),
        ],
      ),
    );
  }
}
```

### 4. Banner de información solo para usuarios básicos

```dart
class ContentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contenido')),
      body: Column(
        children: [
          // Banner promocional solo para usuarios básicos
          BasicUserOnly(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                children: [
                  const Icon(Icons.star),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '¡Hazte Premium y accede a todo el contenido!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showUpgradeDialog(context),
                    child: const Text('Actualizar'),
                  ),
                ],
              ),
            ),
          ),

          // Contenido principal
          Expanded(
            child: const ContentList(),
          ),
        ],
      ),
    );
  }
}
```

---

## Extensiones de BuildContext

El widget también incluye extensiones útiles para verificar roles fuera de widgets:

### Verificar roles en funciones

```dart
void _handleAction(BuildContext context) {
  if (context.hasMinimumRole(UserRole.admin)) {
    // Ejecutar acción de administrador
    _performAdminAction();
  } else {
    // Mostrar mensaje de error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No tienes permisos')),
    );
  }
}
```

### Verificar múltiples roles

```dart
void _showContentOptions(BuildContext context) {
  if (context.hasAnyRole([UserRole.editor, UserRole.admin])) {
    _showEditorOptions(context);
  } else {
    _showViewOnlyOptions(context);
  }
}
```

### Obtener usuario actual

```dart
void _buildHeader(BuildContext context) {
  final user = context.currentUser;

  return AppBar(
    title: Text('Hola, ${user.fullName}'),
    subtitle: Text(user.roleName),
  );
}
```

---

## Ejemplos Avanzados

### 1. Lógica invertida (mostrar solo cuando NO tiene rol)

```dart
// Mostrar mensaje de actualización solo a usuarios que NO son premium
RoleBasedWidget(
  allowedRoles: [UserRole.admin, UserRole.editor],
  invertLogic: true,  // Invierte la lógica
  child: const UpgradePromoBanner(),
)
```

### 2. Modo invisible (mantiene el espacio)

```dart
// Útil para mantener el layout consistente
RoleBasedWidget(
  minimumRole: UserRole.admin,
  hideMode: RoleHideMode.invisible,  // Mantiene el espacio pero invisible
  child: const AdminButton(),
)
```

### 3. Múltiples niveles de permisos anidados

```dart
Column(
  children: [
    // Nivel 1: Solo editores y superiores ven la sección
    EditorOrAbove(
      child: Card(
        child: Column(
          children: [
            const Text('Panel de Edición'),

            // Nivel 2: Dentro de la sección, solo admins ven botón peligroso
            AdminOnly(
              child: ElevatedButton(
                onPressed: () => _dangerousAction(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Acción Peligrosa'),
              ),
            ),
          ],
        ),
      ),
    ),
  ],
)
```

### 4. Diseño responsivo según rol

```dart
class DashboardLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sidebar solo visible para editores y superiores
        EditorOrAbove(
          hideMode: RoleHideMode.remove,
          child: Container(
            width: 250,
            child: const EditorSidebar(),
          ),
        ),

        // Contenido principal (todos lo ven)
        Expanded(
          child: const MainContent(),
        ),

        // Panel de herramientas solo para admins
        AdminOnly(
          child: Container(
            width: 300,
            child: const AdminToolsPanel(),
          ),
        ),
      ],
    );
  }
}
```

### 5. Validación de permisos en Cubit usando extensión

```dart
class ChallengeCubit extends Cubit<ChallengeState> {
  final AuthCubit _authCubit;

  ChallengeCubit(this._authCubit) : super(const ChallengeState.initial());

  Future<void> deleteChallenge(int id, BuildContext context) async {
    // Usar la extensión para verificar permisos
    if (!context.hasMinimumRole(UserRole.admin)) {
      emit(ChallengeState.error('No tienes permisos para eliminar'));
      return;
    }

    try {
      emit(const ChallengeState.loading());
      await _repository.delete(id);
      emit(const ChallengeState.deleteSuccess());
    } catch (e) {
      emit(ChallengeState.error(e.toString()));
    }
  }
}
```

---

## Mejores Prácticas

### ✅ Hacer

```dart
// 1. Usar widgets de conveniencia cuando sea posible
AdminOnly(child: AdminPanel())

// 2. Proporcionar fallback informativo
RoleBasedWidget(
  minimumRole: UserRole.editor,
  fallback: Text('Necesitas ser editor'),
  child: EditButton(),
)

// 3. Usar minimumRole para jerarquías
RoleBasedWidget(
  minimumRole: UserRole.editor,  // Incluye Editor, Admin, SuperAdmin
  child: EditPanel(),
)
```

### ❌ Evitar

```dart
// 1. No usar ambos parámetros a la vez
RoleBasedWidget(
  allowedRoles: [UserRole.admin],
  minimumRole: UserRole.editor,  // ❌ Error: no usar ambos
  child: Widget(),
)

// 2. No verificar permisos en múltiples lugares
// ❌ Malo: verificar en widget y en cubit
if (user.isAdmin) {  // Verificación en widget
  AdminButton()
}
// ... y también en el cubit

// ✅ Bueno: verificar solo en el widget visual
AdminOnly(
  child: AdminButton(),  // El cubit asume que si se llama, tiene permisos
)
```

---

## Importación

```dart
// Importar el widget
import 'package:opn_test_guardia_civil_cms/app/config/widgets/index.dart';

// O importar directamente
import 'package:opn_test_guardia_civil_cms/app/config/widgets/role_based_widget.dart';
```

---

## Filtrado de NavigationItemData

El sistema también incluye funciones helper para filtrar items del menú lateral basándose en roles.

### Uso en lateral_menu.dart

```dart
import 'package:opn_test_guardia_civil_cms/app/config/widgets/index.dart';

class ScaffoldWithNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLayoutCubit, AppLayoutState>(
      builder: (context, layoutState) {
        // 1. Obtener todos los items de navegación (sin filtrar)
        final allNavigationItems = _getNavigationItems(context);

        // 2. Definir restricciones de roles por ID de item
        final restrictions = {
          'specialties': RoleRestriction.adminOnly,
          'academies': RoleRestriction.superAdminOnly,
          'tests': RoleRestriction.editorOrAbove,
          'challenges': RoleRestriction.editorOrAbove,
        };

        // 3. Obtener usuario actual
        final currentUser = context.watch<AuthCubit>().state.user;

        // 4. Filtrar items según roles
        final filteredItems = filterNavigationItems(
          allNavigationItems,
          restrictions,
          currentUser,
        );

        // 5. Usar los items filtrados
        return _buildWithNavigationRail(context, layoutState, filteredItems);
      },
    );
  }
}
```

### Definir Restricciones de Roles

```dart
// Usando constantes predefinidas
final restrictions = {
  'item-id': RoleRestriction.adminOnly,           // Solo Admin y SuperAdmin
  'item-id-2': RoleRestriction.superAdminOnly,     // Solo SuperAdmin
  'item-id-3': RoleRestriction.editorOrAbove,      // Editor, Admin, SuperAdmin
};

// Usando constructores con nombre
final restrictions = {
  'item-id': RoleRestriction.minimumRole(UserRole.admin),
  'item-id-2': RoleRestriction.allowedRoles([UserRole.superAdmin, UserRole.admin]),
};

// Usando constructor directo
final restrictions = {
  'item-id': RoleRestriction(minimumRole: UserRole.editor),
  'item-id-2': RoleRestriction(allowedRoles: [UserRole.admin]),
};
```

### Ejemplo Completo en lateral_menu.dart

```dart
List<NavigationItemData> _getNavigationItems(BuildContext context) {
  return [
    NavigationItemData(
      id: 'home',
      label: 'Inicio',
      icon: Icons.home_outlined,
      route: '/home',
    ),
    // Este item solo será visible para editores y superiores
    NavigationItemData(
      id: 'tests',
      label: 'Gestión de Tests',
      icon: Icons.quiz_outlined,
      route: '/tests',
    ),
    // Este item solo será visible para admins
    NavigationItemData(
      id: 'specialties',
      label: 'Especialidades',
      icon: Icons.school_outlined,
      route: '/specialties',
    ),
    // Este item solo será visible para super admins
    NavigationItemData(
      id: 'academies',
      label: 'Academias',
      icon: Icons.business_outlined,
      route: '/academias',
    ),
  ];
}

@override
Widget build(BuildContext context) {
  return BlocBuilder<AppLayoutCubit, AppLayoutState>(
    builder: (context, layoutState) {
      final allItems = _getNavigationItems(context);

      // Definir qué items son visibles para qué roles
      final restrictions = {
        'tests': RoleRestriction.editorOrAbove,
        'specialties': RoleRestriction.adminOnly,
        'academies': RoleRestriction.superAdminOnly,
      };

      // Filtrar según el usuario actual
      final currentUser = context.watch<AuthCubit>().state.user;
      final visibleItems = filterNavigationItems(
        allItems,
        restrictions,
        currentUser,
      );

      return _buildWithNavigationRail(context, layoutState, visibleItems);
    },
  );
}
```

### Restricciones en Items con Children

El filtrado funciona recursivamente con items que tienen children:

```dart
final allItems = [
  NavigationItemData(
    id: 'admin',
    label: 'Administración',
    icon: Icons.admin_panel_settings,
    children: [
      NavigationItemData(
        id: 'users',
        label: 'Usuarios',
        route: '/admin/users',
      ),
      NavigationItemData(
        id: 'system',
        label: 'Sistema',
        route: '/admin/system',
      ),
    ],
  ),
];

// Restricciones
final restrictions = {
  'admin': RoleRestriction.adminOnly,       // El padre requiere admin
  'system': RoleRestriction.superAdminOnly, // El child requiere superadmin
};

// Resultado para Admin:
// - Verá "Administración" con solo "Usuarios" (Sistema estará oculto)

// Resultado para SuperAdmin:
// - Verá "Administración" con "Usuarios" y "Sistema"

// Resultado para Editor:
// - No verá nada (ni siquiera el padre)
```

### Ejemplo Real: Ocultar Items según Rol

```dart
// Caso 1: Usuario básico
// Solo ve: Inicio, Tests Overview
final basicUserRestrictions = {
  'tests': RoleRestriction.editorOrAbove,
  'categories': RoleRestriction.editorOrAbove,
  'specialties': RoleRestriction.adminOnly,
  'academies': RoleRestriction.superAdminOnly,
};

// Caso 2: Editor
// Ve: Inicio, Tests Overview, Tests, Categorías
// (Especialidades y Academias ocultas)

// Caso 3: Admin
// Ve: Inicio, Tests Overview, Tests, Categorías, Especialidades
// (Academias oculta)

// Caso 4: SuperAdmin
// Ve: TODO
```

### Ventajas de este Enfoque

1. **No Modifica lateral_menu.dart**: La clase `NavigationItemData` permanece sin cambios
2. **Centralizado**: Todas las restricciones en un solo mapa
3. **Recursivo**: Funciona automáticamente con items anidados
4. **Flexible**: Diferentes tipos de restricciones (minimumRole, allowedRoles)
5. **Type-Safe**: Usa enums de Dart para los roles
6. **Performante**: Solo filtra cuando el usuario cambia (gracias a BlocBuilder)

---

## Referencias

- **Modelo de Usuario**: `lib/app/authentification/auth/model/user.dart`
- **AuthCubit**: `lib/app/authentification/auth/cubit/cubit.dart`
- **Enum de Roles**: `UserRole` en `user.dart` (superAdmin, admin, editor, user)
- **NavigationItemData**: `lib/app/config/layout/lateral_menu.dart`
- **Funciones de Filtrado**: `filterNavigationItems()` en `role_based_widget.dart`

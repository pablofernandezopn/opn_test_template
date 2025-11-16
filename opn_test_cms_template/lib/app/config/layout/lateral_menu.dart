import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/cubit/auth_cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/model/user.dart';
import 'package:opn_test_guardia_civil_cms/app/config/layout/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/config/layout/top_menu.dart';
import 'package:opn_test_guardia_civil_cms/app/config/widgets/roleLocker/role_based_widget.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_level.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/view/components/add_topic_type_dialog.dart';

import 'cubit/cubit.dart';

// ==========================================
// 📦 MODELOS DE DATOS PARA NAVEGACIÓN
// ==========================================

/// Item de navegación con soporte para subitems
class NavigationItemData {
  final String id;
  final String label;
  final IconData? icon;
  final IconData? selectedIcon;
  final String? route;
  final List<NavigationItemData>? children;
  final VoidCallback? onTap;
  final String? badge;
  final Color? badgeColor;
  final bool isExpandedByDefault;
  final double iconSize;

  const NavigationItemData({
    required this.id,
    required this.label,
    this.icon,
    this.selectedIcon,
    this.route,
    this.children,
    this.onTap,
    this.badge,
    this.badgeColor,
    this.isExpandedByDefault = false,
    this.iconSize = 24,
  });

  /// Verifica si este item tiene hijos
  bool get hasChildren => children != null && children!.isNotEmpty;

  /// Verifica si es un item de acción (no navega)
  bool get isAction => route == null && !hasChildren;

  /// Obtiene el icono a mostrar (o un punto por defecto)
  IconData get displayIcon => icon ?? Icons.fiber_manual_record;

  /// Obtiene el icono seleccionado
  IconData get displaySelectedIcon => selectedIcon ?? displayIcon;
}

// ==========================================
// 🎯 SCAFFOLD PRINCIPAL CON NAVEGACIÓN
// ==========================================

class ScaffoldWithNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavigation({
    super.key,
    required this.navigationShell,
  });

  /// Define la estructura de navegación de la aplicación
  /// Modifica esta lista para cambiar el menú
  List<NavigationItemData> _getNavigationItems(
      BuildContext context, CmsUser currentUser) {
    final topicState = context.watch<TopicCubit>().state;

    // Filtrar topicTypes por nivel
    final mockTestChildren = topicState.topicTypes
        .where((topic) => topic.level == TopicLevel.Mock)
        .map((topicType) {
      return NavigationItemData(
        id: topicType.id.toString(),
        label: topicType.topicTypeName,
        icon: _getIconForTopicType(topicType.topicTypeName),
        route: '/tests/${topicType.id}',
      );
    }).toList();

    final studyBlockChildren = topicState.topicTypes
        .where((topic) => topic.level == TopicLevel.Study)
        .map((topicType) {
      return NavigationItemData(
        id: topicType.id.toString(),
        label: topicType.topicTypeName,
        icon: _getIconForTopicType(topicType.topicTypeName),
        route: '/tests/${topicType.id}',
      );
    }).toList();

    final flashcardChildren = topicState.topicTypes
        .where((topic) => topic.level == TopicLevel.Flashcard)
        .map((topicType) {
      return NavigationItemData(
        id: topicType.id.toString(),
        label: topicType.topicTypeName,
        icon: _getIconForTopicType(topicType.topicTypeName),
        route: '/tests/${topicType.id}',
      );
    }).toList();

    return [
      NavigationItemData(
        id: 'tests_overview',
        label: 'Apartados de Tests',
        icon: Icons.category_outlined,
        selectedIcon: Icons.category,
        route: '/tests',
      ),
      NavigationItemData(
        id: 'categories',
        label: 'Categorías',
        icon: Icons.label_outlined,
        selectedIcon: Icons.label,
        route: '/categories',
      ),

      NavigationItemData(
        id: 'memberships',
        label: 'Membresías',
        icon: Icons.label_outlined,
        selectedIcon: Icons.label,
        route: '/memberships',
      ),
      // NavigationItemData(
      //   id: 'topic_groups',
      //   label: 'Grupos de Tópicos',
      //   icon: Icons.folder_outlined,
      //   selectedIcon: Icons.folder,
      //   route: '/topic-groups',
      // ),
      NavigationItemData(
        id: 'tests',
        label: 'Gestión de Tests',
        icon: Icons.quiz_outlined,
        iconSize: 20,
        selectedIcon: Icons.quiz,
        isExpandedByDefault: false,
        children: _buildTestChildren(topicState, mockTestChildren, () {
          _showAddTopicTypeDialog(context, TopicLevel.Mock);
        }),
      ),
      NavigationItemData(
        id: 'blocks',
        label: 'Gestión de Bloques',
        icon: Icons.library_books_outlined,
        iconSize: 20,
        selectedIcon: Icons.library_books,
        isExpandedByDefault: false,
        children: _buildTestChildren(topicState, studyBlockChildren, () {
          _showAddTopicTypeDialog(context, TopicLevel.Study);
        }),
      ),
      NavigationItemData(
        id: 'flashcards',
        label: 'Gestión de Flashcards',
        icon: Icons.style_outlined,
        iconSize: 20,
        selectedIcon: Icons.style,
        isExpandedByDefault: false,
        children: _buildTestChildren(topicState, flashcardChildren, () {
          _showAddTopicTypeDialog(context, TopicLevel.Flashcard);
        }),
      ),
      NavigationItemData(
        id: 'challenges',
        label: 'Impugnaciones',
        icon: Icons.flag_outlined,
        selectedIcon: Icons.flag,
        route: '/challenges',
      ),
      NavigationItemData(
        id: 'specialties',
        label: 'Especialidades',
        icon: Icons.school_outlined,
        selectedIcon: Icons.school,
        route: '/specialties',
      ),

      NavigationItemData(
        id: 'academies',
        label: 'Academias',
        icon: Icons.business_outlined,
        selectedIcon: Icons.business,
        route: '/academias',
      ),
      NavigationItemData(
        id: 'student_management',
        label: 'Gestión de alumnos',
        icon: Icons.people_outlined,
        selectedIcon: Icons.people,
        isExpandedByDefault: false,
        children: [
          NavigationItemData(
            id: 'all_students',
            label: 'Todos los alumnos',
            icon: Icons.list_outlined,
            route: '/students',
          ),
          NavigationItemData(
            id: 'add_students',
            label: 'Añadir alumnos',
            icon: Icons.person_add_outlined,
            route: '/students/add',
          ),
        ],
      ),
      // NavigationItemData(
      //   id: 'tutors_management',
      //   label: 'Gestión de tutores',
      //   icon: Icons.school_outlined,
      //   selectedIcon: Icons.school,
      //   // Los usuarios no admin van directamente a su academia
      //   route: currentUser.isAdmin
      //       ? '/tutors'
      //       : '/tutors/${currentUser.academyId}',
      // ),
    ];
  }

  void _showAddTopicTypeDialog(BuildContext context, TopicLevel level) {
    showDialog(
      context: context,
      builder: (_) => AddTopicTypeDialog(level: level),
    );
  }

// 👇 Nueva función helper para manejar los estados
  List<NavigationItemData> _buildTestChildren(
    TopicState topicState,
    List<NavigationItemData> testChildren,
    VoidCallback onAdd,
  ) {
    final List<NavigationItemData> children = [];

    // Si está cargando
    if (topicState.fetchStatus.status == Status.loading) {
      children.add(
        NavigationItemData(
          id: 'loading',
          label: 'Cargando...',
          icon: Icons.hourglass_empty,
        ),
      );
    } // Si hay error
    else if (topicState.fetchStatus.status == Status.error) {
      children.add(
        NavigationItemData(
          id: 'error',
          label: 'Error al cargar',
          icon: Icons.error_outline,
        ),
      );
    } // Si está done, añadir los tipos y el botón de añadir
    else {
      children.addAll(testChildren);
      children.add(
        NavigationItemData(
          id: 'add_new_topic',
          label: 'Añadir nuevo tipo',
          icon: Icons.add_circle_outline,
          onTap: onAdd,
        ),
      );
    }
    return children;
  }

  // Helper para asignar iconos según el nombre del tipo de test
  IconData _getIconForTopicType(String typeName) {
    final nameLower = typeName.toLowerCase();

    if (nameLower.contains('simulacro')) return Icons.school;
    if (nameLower.contains('temario') || nameLower.contains('bloque'))
      return Icons.menu_book;
    if (nameLower.contains('oficial')) return Icons.verified;
    if (nameLower.contains('especial')) return Icons.star;
    if (nameLower.contains('psicotécnico')) return Icons.psychology;
    if (nameLower.contains('inglés') || nameLower.contains('ingles'))
      return Icons.language;

    return Icons.quiz; // Icono por defecto
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLayoutCubit, AppLayoutState>(
      builder: (context, layoutState) {
        // Cargar topic types si no están cargados
        final topicCubit = context.read<TopicCubit>();
        if (topicCubit.state.topicTypes.isEmpty &&
            topicCubit.state.fetchStatus.status != Status.loading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            topicCubit.initialFetch();
          });
        }

        // Actualizar el tamaño de pantalla en cada rebuild
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final width = MediaQuery.of(context).size.width;
          if (width != layoutState.screenWidth) {
            context.read<AppLayoutCubit>().updateScreenSize(width);
          }
        });
        // Obtener el usuario actual y filtrar items según su rol
        final currentUser = context.watch<AuthCubit>().state.user;
        // Obtener todos los items de navegación
        final allNavigationItems = _getNavigationItems(context, currentUser);

        // Definir restricciones de roles para items específicos
        final roleRestrictions = {
          'specialties':
              RoleRestriction.superAdminOnly, // Solo Admin y SuperAdmin
          'academies':
              RoleRestriction.superAdminOnly, // Solo Admin y SuperAdmin
          'memberships': RoleRestriction.superAdminOnly
        };

        final filteredNavigationItems = filterNavigationItems(
          allNavigationItems,
          roleRestrictions,
          currentUser,
        );

        // Usar siempre NavigationRail (solo desktop/tablet)
        return _buildWithNavigationRail(
            context, layoutState, filteredNavigationItems);
      },
    );
  }

  // ==========================================
  // 🖥️ VERSIÓN DESKTOP/TABLET - NavigationRail
  // ==========================================

  Widget _buildWithNavigationRail(
    BuildContext context,
    AppLayoutState layoutState,
    List<NavigationItemData> items,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExtended = layoutState.isNavigationExpanded;
    return Scaffold(
      body: Column(
        children: [
          TopMenuWidget(),
          Expanded(
            child: Row(
              children: [
                // NavigationRail personalizado
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(
                      left: 8, top: 0, bottom: 8, right: 8),
                  width: isExtended ? 280 : 72,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      right: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: ClipRect(
                    child: Column(
                      children: [
                        // Header
                        // _buildNavigationRailHeader(context, layoutState),
                        // Items de navegación
                        Expanded(
                          child: _NavigationItemsList(
                            items: items,
                            isExpanded: isExtended,
                            layoutState: layoutState,
                            currentRoute: _getCurrentRoute(context),
                            onNavigate: (route) =>
                                _navigateToRoute(context, route),
                            onExpandMenu: () {
                              // ✅ Expandir el menú cuando se pulsa un item con children
                              if (!isExtended) {
                                context
                                    .read<AppLayoutCubit>()
                                    .setNavigationExpanded(true);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Contenido principal
                Expanded(child: navigationShell),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRailHeader(
    BuildContext context,
    AppLayoutState layoutState,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExpanded = layoutState.isNavigationExpanded;

    if (!isExpanded) {
      // Cuando está colapsado, no mostrar nada o un logo pequeño
      return const SizedBox(height: 16);
    }

    return ClipRect(
      child: Container(
        height: 64,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Navegación',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Panel de Control',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimary.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRailFooter(
    BuildContext context,
    AppLayoutState layoutState,
  ) {
    // Footer vacío o con información adicional si lo necesitas
    return const SizedBox.shrink();
  }

  // ==========================================
  // 🛠️ UTILIDADES
  // ==========================================

  String _getCurrentRoute(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }

  Future<void> _navigateToRoute(BuildContext context, String route) async {
    // Parsear la ruta de forma segura y extraer segmentos
    try {
      final uri = Uri.parse(route);
      final segments = uri.pathSegments;
      // Esperamos rutas como /tests/<id>
      if (segments.length >= 2 && segments[0] == 'tests') {
        final id = int.tryParse(segments[1]);
        if (id != null) {
          try {
            final topicCubit = context.read<TopicCubit>();
            await topicCubit.fetchTopicsByType(id);
          } catch (_) {
            // No bloquear la navegación si falla la carga
          }
        }
      }
    } catch (_) {
      // Si la ruta no es un URI válido, ignorar y navegar de todas formas
    }

    // Navegar (se realiza aunque la descarga falle)
    context.go(route);
  }
}

// ==========================================
// 📋 LISTA DE ITEMS DE NAVEGACIÓN
// ==========================================

class _NavigationItemsList extends StatelessWidget {
  final List<NavigationItemData> items;
  final bool isExpanded;
  final AppLayoutState layoutState;
  final String currentRoute;
  final Future<void> Function(String) onNavigate;
  final VoidCallback? onExpandMenu;

  const _NavigationItemsList({
    required this.items,
    required this.isExpanded,
    required this.layoutState,
    required this.currentRoute,
    required this.onNavigate,
    this.onExpandMenu,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: layoutState.spacing),
      children: items.map((item) {
        return _NavigationItem(
          item: item,
          isExpanded: isExpanded,
          layoutState: layoutState,
          currentRoute: currentRoute,
          onNavigate: onNavigate,
          onExpandMenu: onExpandMenu,
        );
      }).toList(),
    );
  }
}

// ==========================================
// 🎯 ITEM DE NAVEGACIÓN INDIVIDUAL
// ==========================================

class _NavigationItem extends StatefulWidget {
  final NavigationItemData item;
  final bool isExpanded;
  final AppLayoutState layoutState;
  final String currentRoute;
  final Future<void> Function(String) onNavigate;
  final VoidCallback? onExpandMenu;
  final int level;

  const _NavigationItem({
    required this.item,
    required this.isExpanded,
    required this.layoutState,
    required this.currentRoute,
    required this.onNavigate,
    this.onExpandMenu,
    this.level = 0,
  });

  @override
  State<_NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<_NavigationItem> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.item.isExpandedByDefault;
  }

  bool get _isSelected {
    if (widget.item.route != null && widget.currentRoute == widget.item.route) {
      return true;
    }

    // Verificar si algún hijo está seleccionado
    if (widget.item.hasChildren) {
      return widget.item.children!.any(
          (child) => child.route != null && widget.currentRoute == child.route);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Si está colapsado, mostrar solo icono
    if (!widget.isExpanded) {
      return _buildCollapsedItem(context, theme, colorScheme);
    }

    // Si tiene hijos, mostrar expansion tile
    if (widget.item.hasChildren) {
      return _buildExpandableItem(context, theme, colorScheme);
    }

    // Item simple
    return _buildSimpleItem(context, theme, colorScheme);
  }

  Widget _buildCollapsedItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Tooltip(
      message: widget.item.label,
      preferBelow: false,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 4,
          horizontal: widget.layoutState.spacing / 2,
        ),
        child: ClipRect(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                // ✅ Si tiene hijos, expandir el menú
                if (widget.item.hasChildren) {
                  widget.onExpandMenu?.call();
                }
                // ✅ Si tiene ruta, navegar
                else if (widget.item.route != null) {
                  widget.onNavigate(widget.item.route!);
                }
                // ✅ Si tiene onTap, ejecutarlo
                else {
                  widget.item.onTap?.call();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSelected
                      ? colorScheme.primaryContainer.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      _isSelected
                          ? widget.item.displaySelectedIcon
                          : widget.item.displayIcon,
                      color: _isSelected
                          ? colorScheme.primary
                          : colorScheme.onPrimary,
                      size: widget.item.iconSize,
                    ),
                    if (widget.item.badge != null)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: widget.item.badgeColor ?? colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 8,
                            minHeight: 8,
                          ),
                        ),
                      ),
                    // ✅ Indicador de que tiene children
                    if (widget.item.hasChildren)
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final leftPadding = widget.level * 16.0 + widget.layoutState.contentPadding;
    final scale = widget.isExpanded ? 1.0 : 0.7;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.layoutState.contentPadding / 2,
        vertical: 2,
      ),
      child: Column(
        children: [
          ClipRect(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: leftPadding,
                    vertical: widget.layoutState.spacing,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      AnimatedScale(
                        scale: scale,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: Icon(
                          _isSelected
                              ? widget.item.displaySelectedIcon
                              : widget.item.displayIcon,
                          size: widget.item.iconSize,
                          color: _isSelected
                              ? colorScheme.primary
                              : colorScheme.onPrimary,
                        ),
                      ),
                      if (widget.isExpanded)
                        SizedBox(width: widget.layoutState.spacing),
                      if (widget.isExpanded)
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            style: theme.textTheme.bodyMedium!.copyWith(
                              fontWeight: _isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: _isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onPrimary,
                              fontSize:
                                  (theme.textTheme.bodyMedium?.fontSize ?? 14) *
                                      scale,
                            ),
                            child: Text(
                              widget.item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      if (widget.item.badge != null && widget.isExpanded)
                        AnimatedScale(
                          scale: scale,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: Container(
                            margin: EdgeInsets.only(
                                left: widget.layoutState.spacing),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  widget.item.badgeColor ?? colorScheme.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.item.badge!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (widget.isExpanded)
                        AnimatedScale(
                          scale: scale,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: colorScheme.onPrimary,
                            size: widget.item.iconSize,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isExpanded)
            ...widget.item.children!.map((child) {
              return _NavigationItem(
                item: child,
                isExpanded: widget.isExpanded,
                layoutState: widget.layoutState,
                currentRoute: widget.currentRoute,
                onNavigate: widget.onNavigate,
                onExpandMenu: widget.onExpandMenu,
                level: widget.level + 1,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSimpleItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final leftPadding = widget.level * 16.0 + widget.layoutState.contentPadding;
    final isChild = widget.level > 0;
    final scale = widget.isExpanded ? 1.0 : 0.7;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.layoutState.contentPadding / 2,
        vertical: 2,
      ),
      child: ClipRect(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.item.route != null
                ? () => widget.onNavigate(widget.item.route!)
                : widget.item.onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: leftPadding,
                vertical: widget.layoutState.spacing,
              ),
              decoration: BoxDecoration(
                color: _isSelected
                    ? colorScheme.primaryContainer.withOpacity(0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  AnimatedScale(
                    scale: scale,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: Icon(
                      _isSelected
                          ? widget.item.displaySelectedIcon
                          : widget.item.displayIcon,
                      size: isChild
                          ? widget.item.iconSize * 0.8
                          : widget.item.iconSize,
                      color: _isSelected
                          ? colorScheme.primary
                          : colorScheme.onPrimary,
                    ),
                  ),
                  if (widget.isExpanded)
                    SizedBox(width: widget.layoutState.spacing),
                  if (widget.isExpanded)
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight:
                              _isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: _isSelected
                              ? colorScheme.primary
                              : colorScheme.onPrimary,
                          fontSize: (isChild
                                  ? 13
                                  : theme.textTheme.bodyMedium?.fontSize ??
                                      14) *
                              scale,
                        ),
                        child: Text(
                          widget.item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  if (widget.item.badge != null && widget.isExpanded)
                    AnimatedScale(
                      scale: scale,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.item.badgeColor ?? colorScheme.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.item.badge!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

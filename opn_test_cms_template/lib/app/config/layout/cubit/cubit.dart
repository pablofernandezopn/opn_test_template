// lib/core/layout/cubit/app_layout_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/config/layout/cubit/state.dart';
import '../../../../bootstrap.dart';
import '../../preferences_service.dart';


class AppLayoutCubit extends Cubit<AppLayoutState> {
  final PreferencesService _prefs;

  AppLayoutCubit(this._prefs) : super(const AppLayoutState()) {
    _loadPreferences();
  }

  // ==========================================
  // 📱 NAVEGACIÓN
  // ==========================================

  /// Actualiza el tipo de navegación basado en el ancho de pantalla
  void updateScreenSize(double width) {
    logger.debug('📏 [APP_LAYOUT] Screen width: $width');

    NavigationType newType;

    if (width < 600) {
      newType = NavigationType.drawer;
    } else if (width < 1200) {
      newType = NavigationType.rail;
    } else {
      newType = NavigationType.railExtended;
    }

    // Si el tipo de navegación cambió
    if (state.navigationType != newType) {
      logger.info('📱 [APP_LAYOUT] Navigation type changed: ${state.navigationType} -> $newType');

      emit(state.copyWith(
        navigationType: newType,
        screenWidth: width,
        // En desktop, expandir por defecto
        isNavigationExpanded: newType == NavigationType.railExtended,
        // Cerrar drawer si salimos de móvil
        isDrawerOpen: newType == NavigationType.drawer ? state.isDrawerOpen : false,
      ));
    } else {
      emit(state.copyWith(screenWidth: width));
    }
  }

  /// Toggle del menú de navegación (NavigationRail)
  Future<void> toggleNavigation() async {
    // Solo tiene efecto en tablet/desktop
    if (state.isMobile) {
      logger.warning('⚠️ [APP_LAYOUT] Cannot toggle navigation in mobile mode');
      return;
    }

    final newValue = !state.isNavigationExpanded;
    logger.debug('🔄 [APP_LAYOUT] Toggling navigation: $newValue');

    emit(state.copyWith(isNavigationExpanded: newValue));

    // Guardar preferencia
    await _prefs.setBool('navigation_expanded', newValue);
  }

  /// Establecer estado del menú
  Future<void> setNavigationExpanded(bool value) async {
    if (state.isMobile) return;

    logger.debug('📍 [APP_LAYOUT] Setting navigation expanded: $value');
    emit(state.copyWith(isNavigationExpanded: value));
    await _prefs.setBool('navigation_expanded', value);
  }

  /// Toggle del drawer (solo móvil)
  void toggleDrawer() {
    logger.debug('🔄 [APP_LAYOUT] Toggling drawer: ${!state.isDrawerOpen}');
      emit(state.copyWith(isDrawerOpen: !state.isDrawerOpen));
  }

  /// Abrir drawer
  void openDrawer() {
    if (!state.isMobile) return;
    logger.debug('📂 [APP_LAYOUT] Opening drawer');
    emit(state.copyWith(isDrawerOpen: true));
  }

  /// Cerrar drawer
  void closeDrawer() {
    logger.debug('📁 [APP_LAYOUT] Closing drawer');
    emit(state.copyWith(isDrawerOpen: false));
  }

  // ==========================================
  // 🎨 TEMA
  // ==========================================

  /// Toggle del modo oscuro
  Future<void> toggleDarkMode() async {
    final newValue = !state.isDarkMode;
    logger.info('🌓 [APP_LAYOUT] Toggling dark mode: $newValue');

    emit(state.copyWith(isDarkMode: newValue));
    await _prefs.setBool('dark_mode', newValue);
  }

  /// Establecer modo oscuro
  Future<void> setDarkMode(bool value) async {
    logger.info('🎨 [APP_LAYOUT] Setting dark mode: $value');
    emit(state.copyWith(isDarkMode: value));
    await _prefs.setBool('dark_mode', value);
  }

  // ==========================================
  // 📏 DENSIDAD
  // ==========================================

  /// Cambiar densidad de la UI
  Future<void> setDensity(UIDensity density) async {
    logger.info('📏 [APP_LAYOUT] Setting UI density: ${density.name}');
    emit(state.copyWith(density: density));
    await _prefs.set('ui_density', density.name);
  }

  /// Ciclar entre densidades (compact -> comfortable -> spacious -> compact)
  Future<void> cycleDensity() async {
    final currentIndex = UIDensity.values.indexOf(state.density);
    final nextIndex = (currentIndex + 1) % UIDensity.values.length;
    final nextDensity = UIDensity.values[nextIndex];

    await setDensity(nextDensity);
  }

  // ==========================================
  // 💾 PREFERENCIAS
  // ==========================================

  /// Cargar preferencias guardadas
  Future<void> _loadPreferences() async {
    logger.info('💾 [APP_LAYOUT] Loading preferences...');

    try {
      final isNavigationExpanded = await _prefs.getBool('navigation_expanded') ?? true;
      final isDarkMode = await _prefs.getBool('dark_mode') ?? false;
      final densityString = await _prefs.get('ui_density') ?? 'comfortable';

      final density = UIDensity.values.firstWhere(
            (d) => d.name == densityString,
        orElse: () => UIDensity.comfortable,
      );

      logger.debug('  Navigation expanded: $isNavigationExpanded');
      logger.debug('  Dark mode: $isDarkMode');
      logger.debug('  Density: ${density.name}');

      emit(state.copyWith(
        isNavigationExpanded: isNavigationExpanded,
        isDarkMode: isDarkMode,
        density: density,
      ));

      logger.info('✅ [APP_LAYOUT] Preferences loaded successfully');
    } catch (e, stackTrace) {
      logger.error('❌ [APP_LAYOUT] Error loading preferences: $e', e, stackTrace);
    }
  }

  /// Resetear todas las preferencias
  Future<void> resetToDefaults() async {
    logger.info('🔄 [APP_LAYOUT] Resetting to defaults...');

    try {
      await _prefs.remove('navigation_expanded');
      await _prefs.remove('dark_mode');
      await _prefs.remove('ui_density');

      emit(const AppLayoutState());

      logger.info('✅ [APP_LAYOUT] Reset completed');
    } catch (e, stackTrace) {
      logger.error('❌ [APP_LAYOUT] Error resetting preferences: $e', e, stackTrace);
    }
  }

  /// Guardar todas las preferencias actuales
  Future<void> saveCurrentState() async {
    logger.info('💾 [APP_LAYOUT] Saving current state...');

    try {
      await _prefs.setBool('navigation_expanded', state.isNavigationExpanded);
      await _prefs.setBool('dark_mode', state.isDarkMode);
      await _prefs.set('ui_density', state.density.name);

      logger.info('✅ [APP_LAYOUT] State saved successfully');
    } catch (e, stackTrace) {
      logger.error('❌ [APP_LAYOUT] Error saving state: $e', e, stackTrace);
    }
  }

  // ==========================================
  // 🛠️ UTILIDADES
  // ==========================================

  /// Obtiene información de debug del estado actual
  Map<String, dynamic> getDebugInfo() {
    return {
      'navigationType': state.navigationType.name,
      'screenWidth': state.screenWidth,
      'isNavigationExpanded': state.isNavigationExpanded,
      'isDrawerOpen': state.isDrawerOpen,
      'isDarkMode': state.isDarkMode,
      'density': state.density.name,
      'contentPadding': state.contentPadding,
      'spacing': state.spacing,
      'isMobile': state.isMobile,
      'isTablet': state.isTablet,
      'isDesktop': state.isDesktop,
    };
  }

  /// Imprime información de debug
  void printDebugInfo() {
    final info = getDebugInfo();
    logger.debug('🐛 [APP_LAYOUT] Debug Info:');
    info.forEach((key, value) {
      logger.debug('  $key: $value');
    });
  }
}
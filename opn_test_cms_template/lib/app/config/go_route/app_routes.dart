/// 🧭 Definición de Rutas de la Aplicación
///
/// Este archivo centraliza todas las rutas de navegación de la app.
/// Cada ruta se define como una constante para evitar hardcodear strings.
///
/// **Convención:**
/// - Cada página debe tener una variable estática `route` con el nombre de la ruta
/// - Las rutas deben empezar con '/'
/// - Las sub-rutas no llevan '/' al inicio (lo maneja GoRouter automáticamente)
///
/// **Ejemplo de uso en una página:**
/// ```dart
/// class HomePage extends StatelessWidget {
///   static const String route = '/home';
///   // ...
/// }
/// ```
///
/// **Navegar a una ruta:**
/// ```dart
/// context.go(AppRoutes.home);
/// context.push(AppRoutes.settings);
/// ```
abstract class AppRoutes {
  // ==========================================
  // 🏠 RUTAS PRINCIPALES
  // ==========================================

  /// Ruta inicial de la aplicación (SignIn si no hay token)
  static const String initial = '/signin';

  /// Página de inicio/home
  static const String home = '/home';

  /// Página de test types
  static const String tests_overview = '/tests';

  /// Página de impugnaciones
  static const String challenges = '/challenges';

  /// Detalle de una impugnación específica
  /// Uso: AppRoutes.challengeDetail(challengeId)
  static String challengeDetail(int challengeId) => '/challenges/$challengeId';

  /// Página de gestión masiva de impugnaciones por pregunta
  /// Uso: AppRoutes.challengesAggregated(questionId)
  static String challengesAggregated(int questionId) =>
      '/challenges/aggregated/$questionId';

  // ==========================================
  // 🔐 AUTENTICACIÓN
  // ==========================================

  /// Página de login/signin
  static const String login = '/login';

  /// Página de signin (alias de login)
  static const String signin = '/signin';

  /// Página de registro/signup
  static const String register = '/register';

  /// Recuperación de contraseña
  static const String forgotPassword = '/forgot-password';

  /// Página de éxito después de login/registro
  static const String success = '/success';

  /// Página de selección de especialidad
  static const String specialtySelection = '/specialty-selection';

  // ==========================================
  // 👤 PERFIL Y CONFIGURACIÓN
  // ==========================================

  /// Perfil de usuario
  static const String profile = '/profile';

  /// Configuración de la app
  static const String settings = '/settings';

  // ==========================================
  // ❌ ERRORES
  // ==========================================

  /// Página de error 404 (no encontrada)
  static const String notFound = '/404';

  /// Página de error genérico
  static const String error = '/error';

  // ==========================================
  // 📱 UTILIDADES
  // ==========================================

  /// Obtiene el nombre de la ruta sin el '/' inicial
  /// Útil para analytics o logging
  static String getRouteName(String route) {
    return route.replaceFirst('/', '').replaceAll('/', '_');
  }

  /// Verifica si una ruta es pública (no requiere autenticación)
  static bool isPublicRoute(String route) {
    const publicRoutes = [
      initial,
      login,
      register,
      forgotPassword,
      notFound,
      error,
    ];
    return publicRoutes.contains(route);
  }
  // ==========================================
  // 🎓 GESTIÓN DE CONTENIDO
  // ==========================================

  /// Gestión de academias
  static const String academies = '/academias';

  /// Gestión de especialidades
  static const String specialties = '/specialties';

  /// Gestión de preguntas (base sin parámetros)
  static const String questions = '/preguntas';

  /// Gestión de preguntas con topicId específico
  /// Uso: AppRoutes.questionsByTopic(topicId)
  static String questionsByTopic(int topicId) => '/preguntas/$topicId';

  /// Dashboard de un topic específico
  /// Uso: AppRoutes.topicDashboard(topicId)
  static String topicDashboard(int topicId) => '/tests/dashboard/$topicId';

  /// Gestión de categorías
  static const String categories = '/categories';

  /// Gestión de grupos de tópicos
  // static const String topicGroups = '/topic-groups';

  /// Gestión de membresías
  static String memberships = '/memberships';

  /// Detalle de un grupo de tópicos específico
  /// Uso: AppRoutes.topicGroupDetail(topicGroupId)
  static String topicGroupDetail(int topicGroupId) =>
      '/topic-groups/$topicGroupId';

  /// Gestión de tutores (base - muestra grilla de academias)
  static const String tutors = '/tutors';

  /// Gestión de estudiantes (base - muestra grilla de academias)
  static const String students = '/students';

  /// Gestión de tutores por academia específica
  /// Uso: AppRoutes.tutorsByAcademy(academyId)
  static String tutorsByAcademy(int academyId) => '/tutors/$academyId';

  // ==========================================
  // 🔄 UTILIDADES DE NAVEGACIÓN
  // ==========================================

  /// Splash/loading durante inicialización
  static const String splash = '/splash';
}

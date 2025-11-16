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

  /// Ruta inicial de la aplicación (Welcome)
  static const String initial = '/welcome';

  /// Ruta de onboarding
  static const String onboarding = '/onboarding';

  /// Página de bienvenida
  static const String welcome = '/welcome';

  /// Página de inicio/home
  static const String home = '/home';

  /// Splash de carga inicial
  static const String loading = '/loading';

  /// Página de test por topic
  static const String topicTest = '/topic-test';

  /// Página de preview de un topic (carga por ID)
  static const String previewTopic = '/preview-topic';

  /// Página de preview de un grupo de topics (carga por ID)
  static const String previewTopicGroup = '/preview-topic-group';

  /// Página de configuración del test
  static const String testConfig = '/test-config';

  /// Página de test (sesión activa)
  static const String test = '/test';

  /// Página de modo supervivencia
  static const String survivalTest = '/survival-test';

  /// Página de preview del modo supervivencia
  static const String survivalPreview = '/survival-preview';

  /// Página de modo contra reloj
  static const String timeAttackTest = '/time-attack-test';

  /// Página de preview del modo contra reloj
  static const String timeAttackPreview = '/time-attack-preview';

  /// Página de temporizador Pomodoro
  static const String pomodoro = '/pomodoro';

  /// Página de historial de tests
  static const String history = '/history';

  /// Revisión de test desde historial (individual)
  static const String historyTestReview = '/history-test-review';

  /// Revisión de test final desde historial (agrupado)
  static const String historyFinalTestReview = '/history-final-test-review';

  /// Página de preguntas favoritas
  static const String favorites = '/favorites';

  /// Página de detalle de pregunta favorita
  static const String favoriteQuestion = '/favorite-question';

  /// Página de impugnaciones/challenges
  static const String challenges = '/challenges';

  /// Página de detalle de una impugnación
  static const String challengeDetail = '/challenge-detail';

  /// Página de ranking de un topic tipo Mock
  static const String ranking = '/ranking';

  /// Página de ranking de un topic_group
  static const String groupRanking = '/group-ranking';

  /// Página de ranking global OPN
  static const String opnRanking = '/opn-ranking';

  /// Página de estadísticas del usuario
  static const String stats = '/stats';

  /// Página de chat con IA
  static const String aiChat = '/ai-chat';

  // ==========================================
  // 🔐 AUTENTICACIÓN
  // ==========================================

  /// Página de login/signin
  static const String login = '/login';

  /// Página de signin (alias de login)
  static const String signin = '/signin';

  /// Página de registro/signup
  static const String register = '/register';

  /// Página de signup (alias de register)
  static const String signup = '/signup';

  /// Recuperación de contraseña
  static const String forgotPassword = '/forgot-password';

  /// Página de éxito después de login/registro
  static const String success = '/success';

  // ==========================================
  // 👤 PERFIL Y CONFIGURACIÓN
  // ==========================================

  /// Perfil de usuario
  static const String profile = '/profile';

  /// Configuración de la app
  static const String settings = '/settings';

  /// Configuración del chat con IA
  static const String chatSettings = '/chat-settings';

  // ==========================================
  // ❌ ERRORES
  // ==========================================

  /// Página de error 404 (no encontrada)
  static const String notFound = '/404';

  /// Página de error genérico
  static const String error = '/error';

  /// Página de error de conexión
  static const String connectionError = '/connection-error';

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
      onboarding,
      login,
      register,
      forgotPassword,
      notFound,
      error,
      loading,
    ];
    return publicRoutes.contains(route);
  }
}

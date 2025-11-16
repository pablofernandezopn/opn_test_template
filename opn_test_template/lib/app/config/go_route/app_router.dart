import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_template/app/features/home/view/home_page.dart';
import 'package:opn_test_template/app/features/loading/view/loading_view.dart';
import 'package:opn_test_template/app/features/questions/view/topic_test_page.dart';
import 'package:opn_test_template/app/features/questions/view/final_test_page.dart';
import 'package:opn_test_template/app/features/topics/model/topic_model.dart';
import 'package:opn_test_template/app/features/topics/model/grouped_test_session.dart';
import 'package:opn_test_template/app/features/topics/view/preview_topic_by_id_page.dart';
import 'package:opn_test_template/app/features/onboarding/onboarding_constants.dart';
import 'package:opn_test_template/app/features/onboarding/view/onboarding_page.dart';
import 'package:opn_test_template/app/features/test_config/view/test_config_page.dart';
import 'package:opn_test_template/app/features/test_config/model/saved_test_config.dart';
import 'package:opn_test_template/app/features/survival/view/survival_test_page.dart';
import 'package:opn_test_template/app/features/survival/view/survival_preview_page.dart';
import 'package:opn_test_template/app/features/time_attack/view/time_attack_test_page.dart';
import 'package:opn_test_template/app/features/time_attack/view/time_attack_preview_page.dart';
import 'package:opn_test_template/app/features/pomodoro/view/pomodoro_page.dart';
import 'package:opn_test_template/app/features/history/view/pages/history_page.dart';
import 'package:opn_test_template/app/features/favorites/view/favorites_list_page.dart';
import 'package:opn_test_template/app/features/favorites/view/question_detail_page.dart';
import 'package:opn_test_template/app/features/challenges/view/challenge_list_page.dart';
import 'package:opn_test_template/app/features/challenges/view/challenge_detail_page.dart';
import 'package:opn_test_template/app/features/ranking/view/ranking_page.dart';
import 'package:opn_test_template/app/features/ranking/view/group_ranking_page.dart';
import 'package:opn_test_template/app/features/opn_ranking/view/opn_ranking_page.dart';
import 'package:opn_test_template/app/features/stats/view/stats_page.dart';
import 'package:opn_test_template/app/features/ai_chat/view/ai_chat_page.dart';
import 'package:opn_test_template/app/features/ai_chat/cubit/ai_chat_cubit.dart';
import 'package:opn_test_template/app/features/chat_settings/view/chat_settings_page.dart';
import '../../features/ai_chat/repository/conversation_repository.dart';
import 'app_routes.dart';
import 'route_observer.dart';
import '../app_bloc_listeners.dart';
import '../preferences_service.dart';
import '../service_locator.dart';

// Importar páginas
import '../../authentification/signinup/welcome/welcome_page.dart';
import '../../authentification/signinup/signin/signin_page.dart';
import '../../authentification/signinup/signup/signup_page.dart';
import '../../authentification/success/success_page.dart';
import '../../authentification/auth/cubit/auth_cubit.dart';

/// 🧭 Configuración del Router de la Aplicación
///
/// Este archivo configura GoRouter con:
/// - ✅ Deep linking automático
/// - ✅ Soporte completo para web
/// - ✅ Manejo de errores 404
/// - ✅ Guards de navegación
/// - ✅ Observador de rutas para analytics
/// - ✅ Transiciones personalizadas
/// - ✅ Listener de autenticación automática
///
/// **Uso en main.dart:**
/// ```dart
/// MaterialApp.router(
///   routerConfig: AppRouter.createRouter(navigatorKey),
///   // ...
/// )
/// ```
class AppRouter {
  // ==========================================
  // 🔑 CONFIGURACIÓN DEL ROUTER
  // ==========================================

  /// Crea y configura el router con el navigatorKey
  static GoRouter createRouter(GlobalKey<NavigatorState> navigatorKey) {
    return GoRouter(
      initialLocation: AppRoutes.loading,
      debugLogDiagnostics: true,
      observers: [AppRouteObserver()],
      navigatorKey: navigatorKey,
      errorBuilder: (context, state) => _ErrorPage(error: state.error),
      redirect: (context, state) async {
        final prefs = getIt<PreferencesService>();
        final completed = (await prefs.get(onboardingPreferenceKey)) == 'true';
        final isOnboarding = state.matchedLocation == AppRoutes.onboarding;

        // Si el onboarding no está completado, redirigir a onboarding
        if (!completed && !isOnboarding) {
          return AppRoutes.onboarding;
        }

        // Si el onboarding está completado y estamos en onboarding, redirigir a loading
        if (completed && isOnboarding) {
          return AppRoutes.loading;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.onboarding,
          name: AppRoutes.onboarding,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const OnboardingPage(),
          ),
        ),
        // ==========================================
        // 🔐 SHELL ROUTE CON LISTENER DE AUTENTICACIÓN
        // ==========================================
        // Este ShellRoute envuelve TODAS las rutas y contiene
        // el listener de autenticación que se ejecuta UNA SOLA VEZ
        ShellRoute(
          builder: (context, state, child) {
            print('🐚 [SHELL_ROUTE] Building shell with listener...');
            // Envolver con el MultiBlocListener al principio
            return MultiBlocListener(
              listeners: AppBlocListeners.listeners(navigatorKey),
              child: child,
            );
          },
          routes: [
            // ------------------------------------------
            // 🏠 PÁGINA DE BIENVENIDA (WELCOME)
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.welcome,
              name: AppRoutes.welcome,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const WelcomePage(),
              ),
            ),

            // ------------------------------------------
            // 🏠 HOME
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.home,
              name: AppRoutes.home,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const HomePage(),
              ),
            ),

            GoRoute(
              path: AppRoutes.loading,
              name: AppRoutes.loading,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const LoadingView(),
              ),
            ),

            GoRoute(
              path: '${AppRoutes.topicTest}/:token',
              name: AppRoutes.topicTest,
              pageBuilder: (context, state) {
                // Manejar tanto test simple (Topic) como test grupal (Map)
                Topic? topic;
                GroupedTestSession? groupedSession;

                if (state.extra is Topic) {
                  // Test simple: extra es Topic directamente
                  topic = state.extra as Topic;
                } else if (state.extra is Map<String, dynamic>) {
                  // Test grupal: extra es Map con topic y groupedSession
                  final extra = state.extra as Map<String, dynamic>;
                  topic = extra['topic'] as Topic?;
                  groupedSession = extra['groupedSession'] as GroupedTestSession?;
                }

                return _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: TopicTestPage(
                    encryptedId: state.pathParameters['token'],
                    topic: topic,
                    groupedSession: groupedSession,
                  ),
                );
              },
            ),

            // ------------------------------------------
            // 📝 PREVIEW DE TEST (CARGA POR ID)
            // ------------------------------------------
            // Estas rutas cargan el Topic o TopicGroup por ID
            // Útil para notificaciones push que solo tienen el ID

            GoRoute(
              path: '${AppRoutes.previewTopic}/:topicId',
              name: AppRoutes.previewTopic,
              pageBuilder: (context, state) {
                final topicId = int.tryParse(state.pathParameters['topicId'] ?? '');

                if (topicId == null) {
                  return _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const _NotFoundPage(),
                  );
                }

                return _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: PreviewTopicByIdPage(topicId: topicId),
                );
              },
            ),

            GoRoute(
              path: '${AppRoutes.previewTopicGroup}/:topicGroupId',
              name: AppRoutes.previewTopicGroup,
              pageBuilder: (context, state) {
                final topicGroupId = int.tryParse(state.pathParameters['topicGroupId'] ?? '');

                if (topicGroupId == null) {
                  return _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const _NotFoundPage(),
                  );
                }

                return _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: PreviewTopicByIdPage(topicGroupId: topicGroupId),
                );
              },
            ),

            // ------------------------------------------
            // 📝 TEST
            // ------------------------------------------

            GoRoute(
              path: AppRoutes.testConfig,
              name: AppRoutes.testConfig,
              pageBuilder: (context, state) {
                SavedTestConfig? savedConfig;
                if (state.extra != null && state.extra is SavedTestConfig) {
                  savedConfig = state.extra as SavedTestConfig;
                }
                return _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: TestConfigPage(savedConfig: savedConfig),
                );
              },
            ),

            // ------------------------------------------
            // 🔥 MODO SUPERVIVENCIA
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.survivalTest,
              name: AppRoutes.survivalTest,
              pageBuilder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                return _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: SurvivalTestPage(
                    topicTypeId: extra?['topicTypeId'] as int?,
                    specialtyId: extra?['specialtyId'] as int?,
                    resumeSessionId: extra?['resumeSessionId'] as int?,
                    reviewMode: extra?['reviewMode'] as bool? ?? false,
                  ),
                );
              },
            ),

            // ------------------------------------------
            // 🔥 PREVIEW MODO SUPERVIVENCIA
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.survivalPreview,
              name: AppRoutes.survivalPreview,
              pageBuilder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final topicTypeId = extra?['topicTypeId'] as int?;

                return _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: SurvivalPreviewPage(topicTypeId: topicTypeId),
                );
              },
            ),

            // ------------------------------------------
            // ⏱️ MODO CONTRA RELOJ
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.timeAttackTest,
              name: AppRoutes.timeAttackTest,
              pageBuilder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                return _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: TimeAttackTestPage(
                    timeLimitSeconds: extra?['timeLimitSeconds'] as int? ?? 120,
                    topicTypeId: extra?['topicTypeId'] as int?,
                    specialtyId: extra?['specialtyId'] as int?,
                    resumeSessionId: extra?['resumeSessionId'] as int?,
                    reviewMode: extra?['reviewMode'] as bool? ?? false,
                  ),
                );
              },
            ),

            // ------------------------------------------
            // ⏱️ PREVIEW MODO CONTRA RELOJ
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.timeAttackPreview,
              name: AppRoutes.timeAttackPreview,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const TimeAttackPreviewPage(),
              ),
            ),

            // ------------------------------------------
            // ⏱️ POMODORO
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.pomodoro,
              name: AppRoutes.pomodoro,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const PomodoroPage(),
              ),
            ),

            // ------------------------------------------
            // 📊 HISTORIAL
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.history,
              name: AppRoutes.history,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const HistoryPage(),
              ),
            ),

            // Revisión de test individual desde historial
            GoRoute(
              path: AppRoutes.historyTestReview,
              name: AppRoutes.historyTestReview,
              pageBuilder: (context, state) {
                // El UserTest se pasa a través de extra
                final extra = state.extra as Map<String, dynamic>?;
                final isResumingTest = extra?['isResumingTest'] as bool? ?? false;
                print('🔍 [ROUTER] historyTestReview pageBuilder');
                print('🔍 [ROUTER] - extra keys: ${extra?.keys}');
                print('🔍 [ROUTER] - isResumingTest from extra: ${extra?['isResumingTest']}');
                print('🔍 [ROUTER] - isResumingTest final: $isResumingTest');
                print('🔍 [ROUTER] - isHistoryReview will be: ${!isResumingTest}');
                return _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: TopicTestPage(
                    userTest: extra?['userTest'],
                    userTestAnswers: extra?['userTestAnswers'],
                    isHistoryReview: !isResumingTest, // Si está retomando, no es revisión
                    isResumingTest: isResumingTest,
                  ),
                );
              },
            ),

            // Revisión de test final (agrupado) desde historial
            GoRoute(
              path: AppRoutes.historyFinalTestReview,
              name: AppRoutes.historyFinalTestReview,
              pageBuilder: (context, state) {
                // Los IDs se pasan a través de extra
                final extra = state.extra as Map<String, dynamic>?;
                final topicGroupId = extra?['topicGroupId'] as int?;
                final userTestIds = extra?['userTestIds'] as List<int>?;

                if (topicGroupId == null || userTestIds == null) {
                  return _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const _NotFoundPage(),
                  );
                }

                return _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: FinalTestPage(
                    topicGroupId: topicGroupId,
                    userTestIds: userTestIds,
                  ),
                );
              },
            ),

            // ------------------------------------------
            // ⭐ FAVORITOS
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.favorites,
              name: AppRoutes.favorites,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const FavoritesListPage(),
              ),
            ),

            GoRoute(
              path: AppRoutes.favoriteQuestion,
              name: AppRoutes.favoriteQuestion,
              pageBuilder: (context, state) {
                final questionId = int.tryParse(state.uri.queryParameters['id'] ?? '');
                if (questionId == null) {
                  return _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const _NotFoundPage(),
                  );
                }
                return _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: QuestionDetailPage(questionId: questionId),
                );
              },
            ),

            // ------------------------------------------
            // 🔨 IMPUGNACIONES
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.challenges,
              name: AppRoutes.challenges,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const ChallengeListPage(),
              ),
            ),

            GoRoute(
              path: '${AppRoutes.challengeDetail}/:id',
              name: AppRoutes.challengeDetail,
              pageBuilder: (context, state) {
                final challengeId = int.tryParse(state.pathParameters['id'] ?? '');
                if (challengeId == null) {
                  return _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const _NotFoundPage(),
                  );
                }
                return _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: ChallengeDetailPage(challengeId: challengeId),
                );
              },
            ),

            // ------------------------------------------
            // 🏆 RANKING
            // ------------------------------------------
            GoRoute(
              path: '${AppRoutes.ranking}/:topicId/:topicName',
              name: AppRoutes.ranking,
              pageBuilder: (context, state) {
                final topicId = int.tryParse(state.pathParameters['topicId'] ?? '');
                final topicName = Uri.decodeComponent(state.pathParameters['topicName'] ?? 'Topic Mock');

                if (topicId == null) {
                  return _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const _NotFoundPage(),
                  );
                }

                return _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: RankingPage(
                    topicId: topicId,
                    topicName: topicName,
                  ),
                );
              },
            ),

            // ------------------------------------------
            // 🏆 RANKING GRUPAL
            // ------------------------------------------
            GoRoute(
              path: '${AppRoutes.groupRanking}/:topicGroupId',
              name: AppRoutes.groupRanking,
              pageBuilder: (context, state) {
                final topicGroupId = int.tryParse(state.pathParameters['topicGroupId'] ?? '');

                if (topicGroupId == null) {
                  return _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const _NotFoundPage(),
                  );
                }

                return _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: GroupRankingPage(
                    topicGroupId: topicGroupId,
                  ),
                );
              },
            ),

            // ------------------------------------------
            // 🏆 RANKING OPN (ÍNDICE GLOBAL)
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.opnRanking,
              name: AppRoutes.opnRanking,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const OpnRankingPage(),
              ),
            ),

            // ------------------------------------------
            // 📊 ESTADÍSTICAS
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.stats,
              name: AppRoutes.stats,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: StatsPage.create(),
              ),
            ),

            // ------------------------------------------
            // 🤖 CHAT CON IA
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.aiChat,
              name: AppRoutes.aiChat,
              pageBuilder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final questionText = extra?['questionText'] as String?;
                final questionId = extra?['questionId'] as int?;
                final question = extra?['question']; // Can be Question object
                final options = extra?['options']; // Can be List<QuestionOption>
                final selectedOptionId = extra?['selectedOptionId'] as int?;

                return _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: BlocProvider(
                    create: (context) {
                      final authState = context.read<AuthCubit>().state;
                      final jwtToken = authState.token;

                      return AiChatCubit(
                        conversationRepository: getIt<ConversationRepository>(),
                        jwtToken: jwtToken,
                        questionId: questionId ?? 0,
                        userAnswer: extra?['userAnswer'] as int?,
                        userTestId: extra?['userTestId'] as int?,
                      );
                    },
                    child: AiChatPage(
                      questionText: questionText,
                      questionId: questionId,
                      question: question,
                      options: options,
                      selectedOptionId: selectedOptionId,
                    ),
                  ),
                );
              },
            ),

            // ------------------------------------------
            // ⚙️ CONFIGURACIÓN DEL CHAT IA
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.chatSettings,
              name: AppRoutes.chatSettings,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const ChatSettingsPage(),
              ),
            ),

            // ------------------------------------------
            // 🔐 AUTENTICACIÓN
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.signin,
              name: AppRoutes.signin,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: SignInPage.create(),
              ),
            ),

            GoRoute(
              path: AppRoutes.signup,
              name: AppRoutes.signup,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: SignUpPage.create(),
              ),
            ),

            GoRoute(
              path: AppRoutes.login,
              name: AppRoutes.login,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const _PlaceholderPage(
                  title: 'Login',
                  route: AppRoutes.login,
                ),
              ),
            ),

            GoRoute(
              path: AppRoutes.register,
              name: AppRoutes.register,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const _PlaceholderPage(
                  title: 'Registro',
                  route: AppRoutes.register,
                ),
              ),
            ),

            GoRoute(
              path: AppRoutes.forgotPassword,
              name: AppRoutes.forgotPassword,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const _PlaceholderPage(
                  title: 'Recuperar Contraseña',
                  route: AppRoutes.forgotPassword,
                ),
              ),
            ),

            // ------------------------------------------
            // 👤 PERFIL Y CONFIGURACIÓN
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.profile,
              name: AppRoutes.profile,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const _PlaceholderPage(
                  title: 'Perfil',
                  route: AppRoutes.profile,
                ),
              ),
            ),

            GoRoute(
              path: AppRoutes.settings,
              name: AppRoutes.settings,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const _PlaceholderPage(
                  title: 'Configuración',
                  route: AppRoutes.settings,
                ),
              ),
            ),

            // ------------------------------------------
            // ✅ PÁGINA DE ÉXITO (SUCCESS)
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.success,
              name: AppRoutes.success,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: SuccessPage.create(),
              ),
            ),

            // ------------------------------------------
            // ❌ PÁGINA DE ERROR 404
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.notFound,
              name: AppRoutes.notFound,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: const _NotFoundPage(),
              ),
            ),

            // ------------------------------------------
            // ❌ PÁGINA DE ERROR DE CONEXIÓN
            // ------------------------------------------
            GoRoute(
              path: AppRoutes.connectionError,
              name: AppRoutes.connectionError,
              pageBuilder: (context, state) => _buildPageWithTransition(
                context: context,
                state: state,
                child: _ConnectionErrorPage(),
              ),
            ),
          ],
        ),
      ],
    );
  }
  // ==========================================
  // 🎨 TRANSICIONES PERSONALIZADAS
  // ==========================================

  /// Construye una página con transición personalizada
  /// Por defecto usa una transición de fade para web y nativa para móvil
  static Page<dynamic> _buildPageWithTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Transición fade suave
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}

// ==========================================
// 📄 PÁGINAS TEMPORALES (PLACEHOLDER)
// ==========================================

/// Página temporal de placeholder
/// Reemplazar con tus páginas reales cuando las crees
class _PlaceholderPage extends StatelessWidget {
  final String title;
  final String route;

  const _PlaceholderPage({
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              '🚧 $title',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Ruta: $route',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 32),
            Text(
              'Página temporal - Reemplazar con implementación real',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            _NavigationButtons(),
          ],
        ),
      ),
    );
  }
}

/// Botones de navegación para testing
class _NavigationButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => context.go(AppRoutes.initial),
          child: const Text('Inicial'),
        ),
        ElevatedButton(
          onPressed: () => context.go(AppRoutes.home),
          child: const Text('Home'),
        ),
        ElevatedButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text('Login'),
        ),
        ElevatedButton(
          onPressed: () => context.go(AppRoutes.profile),
          child: const Text('Perfil'),
        ),
        ElevatedButton(
          onPressed: () => context.go(AppRoutes.settings),
          child: const Text('Ajustes'),
        ),
      ],
    );
  }
}

/// Página de error 404
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página no encontrada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              '404',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.home),
              label: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Página de error genérico
class _ErrorPage extends StatelessWidget {
  final Exception? error;

  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Ocurrió un error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.home),
              label: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Página de error de conexión
class _ConnectionErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono de error
                Icon(
                  Icons.cloud_off_rounded,
                  size: 120,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 32),

                // Título
                Text(
                  'Sin conexión',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Mensaje
                Text(
                  'No se pudo establecer conexión con el servidor.\n'
                      'Por favor, verifica tu conexión a internet e inténtalo de nuevo.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Botón de reintentar
                ElevatedButton.icon(
                  onPressed: () {
                    // Reintentar verificando la autenticación
                    context.read<AuthCubit>().check(firstStart: false);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Información adicional
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 Consejos:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildTip(
                        context,
                        '• Verifica que estés conectado a internet',
                      ),
                      _buildTip(
                        context,
                        '• Si estás usando Supabase local, asegúrate de que esté iniciado',
                      ),
                      _buildTip(
                        context,
                        '• Intenta cambiar entre WiFi y datos móviles',
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
  }

  Widget _buildTip(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
      ),
    );
  }
}

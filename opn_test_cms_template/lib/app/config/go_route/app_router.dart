import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/view/specialty_page.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/view/topic_page.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/view/topic_dashboard_page.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/view/topic_groups_page.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/view/topic_group_detail_page.dart';
import 'package:opn_test_guardia_civil_cms/app/features/questions/view/question_page.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/view/users_page.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/view/add_user_page.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/view/user_stats_page.dart';
import 'package:opn_test_guardia_civil_cms/app/features/memberships/view/memberships_page.dart';
import '../../features/topics/view/topic_type_page.dart';
import '../../features/academy/view/academy_page.dart';
import '../../features/academy/view/academy_detail_page.dart';
import '../../features/challenges/view/challenges_page.dart';
import '../../features/challenges/view/challenge_detail_page.dart';
import '../../features/challenges/view/challenges_aggregated_page.dart';
import '../../features/categories/view/categories_page.dart';
import '../layout/lateral_menu.dart';
import 'app_routes.dart';
import 'route_observer.dart';
import '../app_bloc_listeners.dart';

// Importar páginas
import '../../authentification/signinup/signin/signin_page.dart';
import '../../authentification/success/success_page.dart';
import '../../authentification/profile/profile_page.dart';
import '../../authentification/splash/splash_page.dart';
import '../../authentification/specialty_selection/specialty_selection_page.dart';
import '../../authentification/auth/cubit/auth_cubit.dart';
import '../../authentification/auth/cubit/auth_state.dart';

/// 🧭 Configuración del Router de la Aplicación con Menú Lateral Persistente
class AppRouter {
  static GoRouter createRouter(
      GlobalKey<NavigatorState> navigatorKey, BuildContext context) {
    return GoRouter(
      // NO especificar initialLocation para que use la URL actual del browser
      // Esto es esencial para que funcione el deep linking en web
      debugLogDiagnostics: true,
      observers: [AppRouteObserver()],
      navigatorKey: navigatorKey,
      errorBuilder: (context, state) => _ErrorPage(error: state.error),

      // 🔀 REDIRECT LOGIC MEJORADA (WEB-READY con preservación de URL)
      redirect: (context, state) {
        final authCubit = context.read<AuthCubit>();
        final authState = authCubit.state;
        final isAuthenticated = authState.status == AuthStatus.authenticated;
        final isUnknown = authState.status == AuthStatus.unknown;

        // Usar matchedLocation para la ruta actual
        final location = state.matchedLocation;

        // Guardar la URL completa original (para deep linking)
        final fullPath = state.uri.toString();

        print(
            '🔀 [REDIRECT] Location: $location, Full Path: $fullPath, Status: ${authState.status}');

        // Definir rutas públicas (accesibles sin autenticación)
        final publicRoutes = [
          AppRoutes.signin,
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.forgotPassword,
          AppRoutes.splash,
        ];

        // Ruta de selección de especialidad (accesible solo si está autenticado pero sin especialidad)
        final specialtySelectionRoute = SpecialtySelectionPage.route;

        final isPublicRoute = publicRoutes.contains(location);

        // 🏠 Manejar acceso a la raíz '/'
        if (location == '/') {
          if (isUnknown) {
            // Si el auth está desconocido, ir a splash sin guardar URL
            print('🏠 [REDIRECT] Raíz / con estado desconocido -> splash');
            return AppRoutes.splash;
          } else if (isAuthenticated) {
            print('🏠 [REDIRECT] Raíz / con usuario autenticado -> home');
            return AppRoutes.home;
          } else {
            print('🏠 [REDIRECT] Raíz / sin usuario -> signin');
            return AppRoutes.signin;
          }
        }

        // ⏳ Si el estado es desconocido, mostrar splash screen
        // PERO: Guardar la URL original para redirigir después
        if (isUnknown) {
          // Si ya estamos en splash, no redirigir
          if (location == AppRoutes.splash) {
            print('⏳ [REDIRECT] Ya en splash, esperando...');
            return null;
          }

          // Guardar la URL original en el cubit para usarla después
          if (!isPublicRoute && location != AppRoutes.splash) {
            print('⏳ [REDIRECT] Guardando URL original: $fullPath');
            authCubit.changeUri(state.uri);
          }

          print('⏳ [REDIRECT] Estado desconocido -> mostrando splash');
          return AppRoutes.splash;
        }

        // Si estamos en splash pero ya tenemos estado conocido, redirigir
        if (location == AppRoutes.splash) {
          if (isAuthenticated) {
            // Verificar si el usuario necesita seleccionar especialidad
            // if (authState.user.specialtyId == null) {
            //   print('🔀 [REDIRECT] Usuario sin especialidad -> specialty-selection');
            //   return specialtySelectionRoute;
            // }

            // Verificar si hay una URL guardada para restaurar
            final savedUri = authState.uri;
            if (savedUri != null && savedUri.toString().isNotEmpty) {
              final savedPath = savedUri.toString();
              print(
                  '🔀 [REDIRECT] Auth resuelto -> restaurando URL original: $savedPath');
              // Limpiar la URI guardada
              authCubit.changeUri(null);
              return savedPath;
            }
            print(
                '🔀 [REDIRECT] Auth resuelto -> redirigiendo a home (sin URL guardada)');
            return AppRoutes.home;
          } else {
            print('🔀 [REDIRECT] Auth resuelto -> redirigiendo a signin');
            // Limpiar la URI guardada
            authCubit.changeUri(null);
            return AppRoutes.signin;
          }
        }

        // ✅ Usuario autenticado pero sin especialidad -> redirigir a selección de especialidad
        // EXCEPTO si ya está en la página de selección de especialidad
        if (isAuthenticated &&
            authState.user.specialtyId == null &&
            location != specialtySelectionRoute) {
          print(
              '🔀 [REDIRECT] Usuario sin especialidad -> specialty-selection');
          return specialtySelectionRoute;
        }

        // ✅ Usuario autenticado con especialidad intentando acceder a ruta pública
        // -> Redirigir al home
        if (isAuthenticated &&
            authState.user.specialtyId != null &&
            isPublicRoute) {
          print(
              '🔀 [REDIRECT] Usuario autenticado en ruta pública -> redirigiendo a home');
          return AppRoutes.home;
        }

        // ✅ Usuario en página de selección de especialidad pero ya tiene especialidad
        // -> Redirigir al home
        if (isAuthenticated &&
            authState.user.specialtyId != null &&
            location == specialtySelectionRoute) {
          print('🔀 [REDIRECT] Usuario ya tiene especialidad -> home');
          return AppRoutes.home;
        }

        // 🔒 Usuario NO autenticado intentando acceder a ruta protegida
        // -> Redirigir a signin
        if (!isAuthenticated && !isPublicRoute) {
          print(
              '🔀 [REDIRECT] Usuario no autenticado -> redirigiendo a signin');
          return AppRoutes.signin;
        }

        // ✅ Todo correcto, permitir navegación
        print('✅ [REDIRECT] Navegación permitida a: $location');
        return null;
      },

      // 🛤️ REFRESCAR LISTENER (Importante para reaccionar a cambios de auth)
      refreshListenable: GoRouterRefreshStream(
        context.read<AuthCubit>().stream,
      ),

      routes: [
        // ==========================================
        // 🔄 SPLASH SCREEN (Inicialización)
        // ==========================================
        GoRoute(
          path: AppRoutes.splash,
          name: AppRoutes.splash,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const SplashPage(),
          ),
        ),

        // ==========================================
        // 🔐 RUTAS PÚBLICAS (Sin menú lateral)
        // ==========================================
        GoRoute(
          path: AppRoutes.signin,
          name: AppRoutes.signin,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: SignInPage(),
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

        // ==========================================
        // 🎓 SELECCIÓN DE ESPECIALIDAD (Ruta protegida especial)
        // ==========================================
        GoRoute(
          path: SpecialtySelectionPage.route,
          name: 'specialtySelection',
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const SpecialtySelectionPage(),
          ),
        ),

        // ==========================================
        // 🏠 RUTAS PROTEGIDAS CON MENÚ LATERAL
        // ==========================================
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            print('🐚 [SHELL_ROUTE] Building shell with navigation...');
            return MultiBlocListener(
              listeners: AppBlocListeners.listeners(navigatorKey),
              child: ScaffoldWithNavigation(navigationShell: navigationShell),
            );
          },
          branches: [
            // ------------------------------------------
            // Branch 1: HOME
            // ------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  name: AppRoutes.home,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const _PlaceholderPage(
                      title: 'Home',
                      route: AppRoutes.home,
                    ),
                  ),
                ),
              ],
            ),

            // ------------------------------------------
            // Branch 2: SUCCESS
            // ------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.success,
                  name: AppRoutes.success,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: SuccessPage.create(),
                  ),
                ),
              ],
            ),

            // ------------------------------------------
            // Branch 3: PERFIL
            // ------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.profile,
                  name: AppRoutes.profile,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const ProfilePage(),
                  ),
                ),
              ],
            ),

            // ------------------------------------------
            // Branch 4: CONFIGURACIÓN
            // ------------------------------------------
            StatefulShellBranch(
              routes: [
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
              ],
            ),

            // ------------------------------------------
            // Branch 5: TESTS (SIN PARÁMETROS EN LA RUTA BASE)
            // ------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.tests_overview,
                  name: AppRoutes.tests_overview,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const TestsOverviewScreen(),
                  ),
                  routes: [
                    // 👇 Ruta anidada CON parámetros
                    GoRoute(
                      path: ':topicTypeId',
                      name: 'testsByType',
                      pageBuilder: (context, state) {
                        final topicTypeId = state.pathParameters['topicTypeId'];

                        if (topicTypeId == null) {
                          return _buildPageWithTransition(
                            context: context,
                            state: state,
                            child: const _ErrorPage(
                              error: null,
                            ),
                          );
                        }

                        return _buildPageWithTransition(
                          context: context,
                          state: state,
                          child: TopicsManagementScreen(
                            topicTypeId: int.parse(topicTypeId),
                          ),
                        );
                      },
                    ),
                    // Dashboard de un topic específico
                    GoRoute(
                      path: 'dashboard/:topicId',
                      name: 'topicDashboard',
                      pageBuilder: (context, state) {
                        final topicIdStr = state.pathParameters['topicId'];

                        if (topicIdStr == null) {
                          return _buildPageWithTransition(
                            context: context,
                            state: state,
                            child: _ErrorPage(
                              error: Exception('Topic ID requerido'),
                            ),
                          );
                        }

                        final topicId = int.tryParse(topicIdStr);
                        if (topicId == null) {
                          return _buildPageWithTransition(
                            context: context,
                            state: state,
                            child: _ErrorPage(
                              error:
                                  Exception('Topic ID inválido: $topicIdStr'),
                            ),
                          );
                        }

                        return _buildPageWithTransition(
                          context: context,
                          state: state,
                          child: TopicDashboardPage(topicId: topicId),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            // ------------------------------------------
            // Branch 6: PREGUNTAS (WEB-READY con path params)
            // ------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.questions,
                  name: AppRoutes.questions,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const _PlaceholderPage(
                      title: 'Preguntas',
                      route: AppRoutes.questions,
                    ),
                  ),
                  routes: [
                    // Ruta anidada con parámetro topicId
                    GoRoute(
                      path: ':topicId',
                      name: 'questionsByTopic',
                      pageBuilder: (context, state) {
                        final topicIdStr = state.pathParameters['topicId'];

                        if (topicIdStr == null) {
                          return _buildPageWithTransition(
                            context: context,
                            state: state,
                            child: _ErrorPage(
                              error: Exception('Topic ID requerido'),
                            ),
                          );
                        }

                        final topicId = int.tryParse(topicIdStr);
                        if (topicId == null) {
                          return _buildPageWithTransition(
                            context: context,
                            state: state,
                            child: _ErrorPage(
                              error:
                                  Exception('Topic ID inválido: $topicIdStr'),
                            ),
                          );
                        }

                        return _buildPageWithTransition(
                          context: context,
                          state: state,
                          child: QuestionsManagementScreen.create(topicId),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            // ------------------------------------------
            // Branch 7: ACADEMIAS
            // ------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.academies,
                  name: AppRoutes.academies,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const AcademyPage(),
                  ),
                  routes: [
                    // Ruta anidada para el detalle de una academia
                    GoRoute(
                      path: ':academyId',
                      name: 'academyDetail',
                      pageBuilder: (context, state) {
                        final academyId = state.pathParameters['academyId'];

                        if (academyId == null) {
                          return _buildPageWithTransition(
                            context: context,
                            state: state,
                            child: const _ErrorPage(
                              error: null,
                            ),
                          );
                        }

                        return _buildPageWithTransition(
                          context: context,
                          state: state,
                          child: AcademyDetailPage(
                            academyId: int.parse(academyId),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            // ------------------------------------------
            // Branch 8: CATEGORÍAS
            // ------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.categories,
                  name: AppRoutes.categories,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const CategoriesPage(),
                  ),
                ),
              ],
            ),

            // ------------------------------------------
            // Branch 9: GRUPOS DE TÓPICOS
            // ------------------------------------------
            // StatefulShellBranch(
            //   routes: [
            //     GoRoute(
            //       path: AppRoutes.topicGroups,
            //       name: AppRoutes.topicGroups,
            //       pageBuilder: (context, state) => _buildPageWithTransition(
            //         context: context,
            //         state: state,
            //         child: const TopicGroupsPage(),
            //       ),
            //       routes: [
            //         // Ruta anidada para el detalle de un grupo de tópicos
            //         GoRoute(
            //           path: ':topicGroupId',
            //           name: 'topicGroupDetail',
            //           pageBuilder: (context, state) {
            //             final topicGroupIdStr = state.pathParameters['topicGroupId'];

            //             if (topicGroupIdStr == null) {
            //               return _buildPageWithTransition(
            //                 context: context,
            //                 state: state,
            //                 child: _ErrorPage(
            //                   error: Exception('Topic Group ID requerido'),
            //                 ),
            //               );
            //             }

            //             final topicGroupId = int.tryParse(topicGroupIdStr);
            //             if (topicGroupId == null) {
            //               return _buildPageWithTransition(
            //                 context: context,
            //                 state: state,
            //                 child: _ErrorPage(
            //                   error: Exception('Topic Group ID inválido: $topicGroupIdStr'),
            //                 ),
            //               );
            //             }

            //             return _buildPageWithTransition(
            //               context: context,
            //               state: state,
            //               child: TopicGroupDetailPage(topicGroupId: topicGroupId),
            //             );
            //           },
            //         ),
            //       ],
            //     ),
            //   ],
            // ),

            // ------------------------------------------
            // Branch 10: IMPUGNACIONES
            // ------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.challenges,
                  name: AppRoutes.challenges,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const ChallengesPage(),
                  ),
                  routes: [
                    // Ruta anidada para el detalle de una impugnación
                    GoRoute(
                      path: ':challengeId',
                      name: 'challengeDetail',
                      pageBuilder: (context, state) {
                        final challengeIdStr =
                            state.pathParameters['challengeId'];

                        if (challengeIdStr == null) {
                          return _buildPageWithTransition(
                            context: context,
                            state: state,
                            child: _ErrorPage(
                              error: Exception('Challenge ID requerido'),
                            ),
                          );
                        }

                        final challengeId = int.tryParse(challengeIdStr);
                        if (challengeId == null) {
                          return _buildPageWithTransition(
                            context: context,
                            state: state,
                            child: _ErrorPage(
                              error: Exception(
                                  'Challenge ID inválido: $challengeIdStr'),
                            ),
                          );
                        }

                        return _buildPageWithTransition(
                          context: context,
                          state: state,
                          child: ChallengeDetailPage.create(challengeId),
                        );
                      },
                    ),
                    // Ruta anidada para gestión masiva de impugnaciones por pregunta
                    GoRoute(
                      path: 'aggregated/:questionId',
                      name: 'challengesAggregated',
                      pageBuilder: (context, state) {
                        final questionIdStr =
                            state.pathParameters['questionId'];

                        if (questionIdStr == null) {
                          return _buildPageWithTransition(
                            context: context,
                            state: state,
                            child: _ErrorPage(
                              error: Exception('Question ID requerido'),
                            ),
                          );
                        }

                        final questionId = int.tryParse(questionIdStr);
                        if (questionId == null) {
                          return _buildPageWithTransition(
                            context: context,
                            state: state,
                            child: _ErrorPage(
                              error: Exception(
                                  'Question ID inválido: $questionIdStr'),
                            ),
                          );
                        }

                        return _buildPageWithTransition(
                          context: context,
                          state: state,
                          child: ChallengesAggregatedPage.create(questionId),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            // ------------------------------------------
            // Branch 11: ESPECIALIDADES
            // ------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.specialties,
                  name: AppRoutes.specialties,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                      context: context,
                      state: state,
                      child: const SpecialtiesPage()),
                ),
              ],
            ),

            // ------------------------------------------
            // Branch 12: USUARIOS/ALUMNOS
            // ------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.students,
                  name: AppRoutes.students,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const UsersPage(),
                  ),
                  routes: [
                    // Ruta anidada para añadir usuario
                    GoRoute(
                      path: 'add',
                      name: 'addStudent',
                      pageBuilder: (context, state) => _buildPageWithTransition(
                        context: context,
                        state: state,
                        child: const AddUserPage(),
                      ),
                    ),
                    // Ruta anidada para estadísticas del usuario
                    GoRoute(
                      path: ':id/stats',
                      name: 'userStats',
                      pageBuilder: (context, state) {
                        final userId = state.pathParameters['id'];

                        if (userId == null) {
                          return _buildPageWithTransition(
                            context: context,
                            state: state,
                            child: _ErrorPage(
                              error: Exception('User ID requerido'),
                            ),
                          );
                        }

                        return _buildPageWithTransition(
                          context: context,
                          state: state,
                          child: UserStatsPage(userId: userId),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            // ------------------------------------------
            // Branch 13: MEMBRESÍAS
            // ------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.memberships,
                  name: AppRoutes.memberships,
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: const MembershipsPage(),
                  ),
                  // routes: [
                  //   // Ruta anidada para añadir usuario
                  //   GoRoute(
                  //     path: 'add',
                  //     name: 'addStudent',
                  //     pageBuilder: (context, state) => _buildPageWithTransition(
                  //       context: context,
                  //       state: state,
                  //       child: const AddUserPage(),
                  //     ),
                  //   ),
                  //   // Ruta anidada para estadísticas del usuario
                  //   GoRoute(
                  //     path: ':id/stats',
                  //     name: 'userStats',
                  //     pageBuilder: (context, state) {
                  //       final userId = state.pathParameters['id'];

                  //       if (userId == null) {
                  //         return _buildPageWithTransition(
                  //           context: context,
                  //           state: state,
                  //           child: _ErrorPage(
                  //             error: Exception('User ID requerido'),
                  //           ),
                  //         );
                  //       }

                  //       return _buildPageWithTransition(
                  //         context: context,
                  //         state: state,
                  //         child: UserStatsPage(userId: userId),
                  //       );
                  //     },
                  //   ),
                  // ],
                ),
              ],
            ),
          ],
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
      ],
    );
  }

  // ==========================================
  // 🎨 TRANSICIONES PERSONALIZADAS
  // ==========================================

  static Page<dynamic> _buildPageWithTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}

// ==========================================
// 🔄 HELPER CLASS PARA REFRESH STREAM
// ==========================================
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ==========================================
// 📄 PÁGINAS TEMPORALES
// ==========================================

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
        automaticallyImplyLeading: MediaQuery.of(context).size.width < 600,
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
          ],
        ),
      ),
    );
  }
}

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

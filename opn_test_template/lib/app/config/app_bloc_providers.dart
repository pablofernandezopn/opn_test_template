import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_template/app/features/loading/cubit/loading_cubit.dart';
import 'package:opn_test_template/app/features/loading/cubit/video_loading_cubit.dart';
import 'package:opn_test_template/app/features/topics/cubit/topic_cubit.dart';
import 'package:opn_test_template/app/features/topics/repository/topic_repository.dart';
import 'package:opn_test_template/app/features/history/cubit/history_cubit.dart';
import 'package:opn_test_template/app/features/history/repository/history_repository.dart';
import 'package:opn_test_template/app/features/favorites/cubit/favorite_cubit.dart';
import 'package:opn_test_template/app/features/favorites/repository/favorite_repository.dart';
import 'package:opn_test_template/app/features/challenges/cubit/challenge_cubit.dart';
import 'package:opn_test_template/app/features/challenges/repository/challenge_repository.dart';
import 'package:opn_test_template/app/features/specialty/cubit/specialty_cubit.dart';
import 'package:opn_test_template/app/features/test_config/cubit/test_config_cubit.dart';

import '../authentification/auth/cubit/auth_cubit.dart';
import '../authentification/auth/cubit/auth_state.dart';
import 'service_locator.dart';

/// 🎯 Configuración de Providers Globales
///
/// Este archivo centraliza la configuración de todos los BLoCs/Cubits
/// globales de la aplicación.
///
/// **Cubits Globales:**
/// - AuthCubit: Manejo de autenticación y estado del usuario
/// - TopicCubit: Manejo de topics y topic types
///
/// **Uso:**
/// ```dart
/// runApp(
///   AppBlocProviders(
///     navigatorKey: navigatorKey,
///     child: MyApp(navigatorKey: navigatorKey),
///   ),
/// );
/// ```
class AppBlocProviders extends StatefulWidget {
  const AppBlocProviders({
    required this.child,
    required this.navigatorKey,
    super.key,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<AppBlocProviders> createState() => _AppBlocProvidersState();
}

class _AppBlocProvidersState extends State<AppBlocProviders> {
  late final AuthCubit _authCubit;
  late final TopicCubit _topicCubit;
  late final HistoryCubit _historyCubit;
  late final FavoriteCubit _favoriteCubit;
  late final ChallengeCubit _challengeCubit;
  late final SpecialtyCubit _specialtyCubit;
  late final TestConfigCubit _testConfigCubit;

  @override
  void initState() {
    super.initState();
    print('🏗️ [APP_BLOC_PROVIDERS] InitState - Getting AuthCubit from GetIt...');

    // 🔑 Obtener AuthCubit del service locator (singleton)
    _authCubit = getIt<AuthCubit>();

    _topicCubit = TopicCubit(
      getIt<TopicRepository>(),
      _authCubit,
    );

    _historyCubit = HistoryCubit(
      getIt<HistoryRepository>(),
      _authCubit,
    );

    _favoriteCubit = FavoriteCubit(
      getIt<FavoriteRepository>(),
    );

    _challengeCubit = ChallengeCubit(
      getIt<ChallengeRepository>(),
      _authCubit,
    );

    // 🎯 Obtener SpecialtyCubit del service locator (singleton)
    _specialtyCubit = getIt<SpecialtyCubit>();

    // 🎯 Obtener TestConfigCubit del service locator
    _testConfigCubit = getIt<TestConfigCubit>();

    // ✅ Llamar check() al inicio para verificar sesión guardada
    print('🔐 [APP_BLOC_PROVIDERS] AuthCubit obtained from GetIt, calling initial check()');
    _authCubit.check(firstStart: true);
  }

  @override
  void dispose() {
    print('🏗️ [APP_BLOC_PROVIDERS] Disposing Cubits...');
    _topicCubit.close();
    _historyCubit.close();
    _favoriteCubit.close();
    _challengeCubit.close();
    // No cerramos _authCubit, _specialtyCubit ni _testConfigCubit porque son singletons de GetIt
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ [APP_BLOC_PROVIDERS] Building (but cubits are stable)...');

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<TopicCubit>.value(value: _topicCubit),
        BlocProvider<HistoryCubit>.value(value: _historyCubit),
        BlocProvider<FavoriteCubit>.value(value: _favoriteCubit),
        BlocProvider<ChallengeCubit>.value(value: _challengeCubit),
        BlocProvider<SpecialtyCubit>.value(value: _specialtyCubit),
        BlocProvider<TestConfigCubit>.value(value: _testConfigCubit),
        BlocProvider<LoadingCubit>.value(value: getIt<LoadingCubit>()),
        BlocProvider<VideoLoadingCubit>.value(value: getIt<VideoLoadingCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // Cargar favoritos cuando el usuario se autentica
          if (state.user.id != 0) {
            print('👤 [APP_BLOC_PROVIDERS] User authenticated, loading favorites...');
            _favoriteCubit.loadFavorites(state.user.id);
          }
        },
        child: widget.child,
      ),
    );
  }
}

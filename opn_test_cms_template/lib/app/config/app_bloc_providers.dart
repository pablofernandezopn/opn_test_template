import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/academy/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/challenges/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/categories/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/memberships/cubit/cubit.dart';

import '../authentification/auth/cubit/auth_cubit.dart';
import '../features/specialties/cubit/cubit.dart';
import '../features/specialties/repository/repository.dart';
import '../features/topics/repository/respository.dart';
import '../features/academy/repository/academy_repository.dart';
import '../features/categories/repository/category_repository.dart';
import '../features/challenges/repository/challenge_repository.dart';
import '../features/users/repository/user_repository.dart';
import '../features/memberships/repository/membership_repository.dart';
import 'layout/cubit/cubit.dart';
import 'preferences_service.dart';
import 'service_locator.dart';

/// 🎯 Configuración de Providers Globales
///
/// Este archivo centraliza la configuración de todos los BLoCs/Cubits
/// globales de la aplicación.
///
/// **Cubits Globales:**
/// - AuthCubit: Manejo de autenticación y estado del usuario
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
  late final AppLayoutCubit _appLayoutCubit;
  late final TopicCubit _topicCubit;
  late final AcademyCubit _academyCubit;
  late final ChallengeCubit _challengeCubit;
  late final SpecialtyCubit _specialtyCubit;
  late final CategoryCubit _categoryCubit;
  late final UserCubit _userCubit;
  late final MembershipCubit _membershipCubit;

  @override
  void initState() {
    super.initState();
    print('🏗️ [APP_BLOC_PROVIDERS] InitState - Creating AuthCubit ONCE...');

    // 🔑 CLAVE: Crear el cubit UNA SOLA VEZ en initState
    _authCubit = AuthCubit(
      getIt<PreferencesService>(),
      getIt(),
    );

    _topicCubit = TopicCubit(getIt<TopicRepository>(), _authCubit);

    _appLayoutCubit = AppLayoutCubit(getIt<PreferencesService>());

    // AcademyCubit requiere AuthCubit para verificar permisos
    // Ahora también gestiona tutores (integrado desde TutorCubit)
    _academyCubit = AcademyCubit(
      getIt<AcademyRepository>(),
      _authCubit,
    );

    // ChallengeCubit requiere AuthCubit para verificar permisos
    _challengeCubit = ChallengeCubit(
      getIt<ChallengeRepository>(),
      _authCubit,
    );

    _specialtyCubit = SpecialtyCubit(getIt<SpecialtyRepository>(), _authCubit);

    // CategoryCubit
    _categoryCubit = CategoryCubit(getIt<CategoryRepository>());

    // UserCubit requiere AuthCubit para filtrar por academia
    _userCubit = UserCubit(getIt<UserRepository>(), _authCubit);

    // MembershipCubit requiere AuthCubit para filtrar por academia
    _membershipCubit =
        MembershipCubit(getIt<MembershipRepository>(), _authCubit);

    // ✅ Llamar check() al inicio para verificar sesión guardada
    print('🔐 [APP_BLOC_PROVIDERS] AuthCubit created, calling initial check()');
    _authCubit.check();
  }

  @override
  void dispose() {
    print('🏗️ [APP_BLOC_PROVIDERS] Disposing AuthCubit...');
    _authCubit.close();
    _appLayoutCubit.close();
    _topicCubit.close();
    _academyCubit.close();
    _categoryCubit.close();
    _challengeCubit.close();
    _specialtyCubit.close();
    _userCubit.close();
    _membershipCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ [APP_BLOC_PROVIDERS] Building (but cubit is stable)...');

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<AppLayoutCubit>.value(value: _appLayoutCubit),
        BlocProvider<TopicCubit>.value(value: _topicCubit),
        BlocProvider<AcademyCubit>.value(value: _academyCubit),
        BlocProvider<CategoryCubit>.value(value: _categoryCubit),
        BlocProvider<ChallengeCubit>.value(value: _challengeCubit),
        BlocProvider<SpecialtyCubit>.value(value: _specialtyCubit),
        BlocProvider<UserCubit>.value(value: _userCubit),
        BlocProvider<MembershipCubit>.value(value: _membershipCubit),
      ],
      child: widget.child,
    );
  }
}

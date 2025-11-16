import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:opn_test_template/app/config/preferences_service.dart';
import 'package:opn_test_template/app/features/topics/repository/topic_repository.dart';
import 'package:opn_test_template/app/features/questions/repository/repository.dart';
import 'package:opn_test_template/app/features/test_config/cubit/test_config_cubit.dart';
import 'package:opn_test_template/app/features/test_config/repository/test_repository.dart';
import 'package:opn_test_template/app/features/test_config/repository/saved_test_config_repository.dart';
import 'package:opn_test_template/app/features/history/repository/history_repository.dart';
import 'package:opn_test_template/app/features/favorites/repository/favorite_repository.dart';
import 'package:opn_test_template/app/features/challenges/repository/challenge_repository.dart';
import 'package:opn_test_template/app/features/ranking/repository/ranking_repository.dart';
import 'package:opn_test_template/app/features/opn_ranking/repository/opn_ranking_repository.dart';
import 'package:opn_test_template/app/features/stats/repository/stats_repository.dart';
import 'package:opn_test_template/app/features/ai_chat/repository/conversation_repository.dart';
import 'package:opn_test_template/app/features/chat_settings/repository/chat_preferences_repository.dart';
import 'package:opn_test_template/app/features/specialty/repository/specialty_repository.dart';
import 'package:opn_test_template/app/features/specialty/cubit/specialty_cubit.dart';
import 'package:opn_test_template/app/features/survival/repository/survival_repository.dart';
import 'package:opn_test_template/app/features/time_attack/repository/time_attack_repository.dart';
import 'package:opn_test_template/app/shared/services/deep_link_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart' as tl;
import '../../config/environment.dart';
import '../authentification/auth/repository/auth_repository.dart';
import '../authentification/auth/cubit/auth_cubit.dart';
import '../features/loading/cubit/loading_cubit.dart';
import '../features/loading/cubit/video_loading_cubit.dart';
import 'device/vibrator.dart';
import '../features/academy/repository/academy_repository.dart';

final getIt = GetIt.instance;

abstract class ServiceLocator {
  static Future<void> setup(Environment environment) async {
    // 1. Inicializar preferences
    final preferences = await PreferencesService.getInstance();
    getIt.registerSingleton<PreferencesService>(preferences);

    // 2. Registrar Talker TEMPRANO (antes de otros servicios que lo puedan usar)
    getIt.registerSingleton<tl.Talker>(tl.TalkerFlutter.init());

    // 3. Inicializar y registrar vibrator
    final vibrator = CustomVibrator(preferences);
    await vibrator.init();
    getIt.registerSingleton<CustomVibrator>(vibrator);

    // 3.1 Registrar servicio de deep linking
    getIt.registerSingleton<DeepLinkService>(DeepLinkService());

    // 4. Registrar repositorios y otros servicios
    getIt
      // Repositorios
      ..registerFactory<AuthRepository>(AuthRepository.new)
      ..registerFactory<AcademyRepository>(AcademyRepository.new)
      ..registerFactory<TopicRepository>(TopicRepository.new)
      ..registerFactory<QuestionRepository>(QuestionRepository.new)
      ..registerFactory<TestRepository>(TestRepository.new)
      ..registerFactory<SavedTestConfigRepository>(SavedTestConfigRepository.new)
      ..registerFactory<HistoryRepository>(HistoryRepository.new)
      ..registerFactory<FavoriteRepository>(FavoriteRepository.new)
      ..registerFactory<ChallengeRepository>(ChallengeRepository.new)
      ..registerFactory<RankingRepository>(RankingRepository.new)
      ..registerFactory<OpnRankingRepository>(OpnRankingRepository.new)
      ..registerFactory<StatsRepository>(StatsRepository.new)
      ..registerFactory<ConversationRepository>(() => ConversationRepository(Supabase.instance.client))
      ..registerFactory<ChatPreferencesRepository>(ChatPreferencesRepository.new)
      ..registerFactory<SpecialtyRepository>(SpecialtyRepository.new)
      ..registerFactory<SurvivalRepository>(SurvivalRepository.new)
      ..registerFactory<TimeAttackRepository>(TimeAttackRepository.new)
      ..registerFactory<LocalAuthentication>(LocalAuthentication.new);

    // 5. Cubits/Controllers globales
    if (!getIt.isRegistered<LoadingCubit>()) {
      getIt.registerSingleton<LoadingCubit>(LoadingCubit());
    }

    if (!getIt.isRegistered<VideoLoadingCubit>()) {
      getIt.registerSingleton<VideoLoadingCubit>(VideoLoadingCubit());
    }

    // 6. Registrar AuthCubit como singleton
    if (!getIt.isRegistered<AuthCubit>()) {
      getIt.registerSingleton<AuthCubit>(
        AuthCubit(
          getIt<PreferencesService>(),
          getIt<AuthRepository>(),
          getIt<AcademyRepository>(),
        ),
      );
    }

    // 6.1 Registrar SpecialtyCubit como singleton
    if (!getIt.isRegistered<SpecialtyCubit>()) {
      getIt.registerSingleton<SpecialtyCubit>(
        SpecialtyCubit(
          specialtyRepository: getIt<SpecialtyRepository>(),
        ),
      );
    }

    // 7. Registrar Cubits
    getIt.registerLazySingleton<TestConfigCubit>(() => TestConfigCubit(getIt<SavedTestConfigRepository>()));
  }
}

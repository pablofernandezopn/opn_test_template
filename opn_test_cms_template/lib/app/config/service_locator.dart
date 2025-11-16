import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:opn_test_guardia_civil_cms/app/config/preferences_service.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/repository/repository.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/repository/respository.dart';
import 'package:opn_test_guardia_civil_cms/app/features/questions/repository/repository.dart';
import 'package:opn_test_guardia_civil_cms/app/features/academy/repository/academy_repository.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/repository/user_repository.dart';
import 'package:opn_test_guardia_civil_cms/app/features/memberships/repository/membership_repository.dart';
import 'package:talker_flutter/talker_flutter.dart' as tl;
import '../../config/environment.dart';
import '../authentification/auth/repository/auth_repository.dart';
import '../features/categories/repository/category_repository.dart';
import '../features/challenges/repository/challenge_repository.dart';
import 'device/vibrator.dart';
import 'widgets/pickImage/image_upload_repository.dart';

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

    // 4. Registrar repositorios y otros servicios
    getIt
      // Repositorios
      ..registerFactory<AuthRepository>(AuthRepository.new)
      ..registerFactory<LocalAuthentication>(LocalAuthentication.new)
      ..registerFactory<TopicRepository>(TopicRepository.new)
      ..registerFactory<QuestionRepository>(QuestionRepository.new)
      ..registerFactory<ChallengeRepository>(ChallengeRepository.new)
      ..registerFactory<ImageUploadRepository>(ImageUploadRepository.new)
      ..registerFactory<SpecialtyRepository>(SpecialtyRepository.new)
      // AcademyRepository ahora también gestiona tutores
      ..registerFactory<AcademyRepository>(AcademyRepository.new)
      ..registerFactory<CategoryRepository>(CategoryRepository.new)
      ..registerFactory<UserRepository>(UserRepository.new)
      ..registerFactory<MembershipRepository>(MembershipRepository.new);
  }
}

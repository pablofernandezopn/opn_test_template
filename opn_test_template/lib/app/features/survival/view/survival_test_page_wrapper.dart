import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/go_route/app_routes.dart';

/// Wrapper simple que navega a TopicTestPage en modo supervivencia
class SurvivalTestPageWrapper extends StatelessWidget {
  final int? topicTypeId;
  final int? specialtyId;
  final int? resumeSessionId;

  const SurvivalTestPageWrapper({
    super.key,
    this.topicTypeId,
    this.specialtyId,
    this.resumeSessionId,
  });

  @override
  Widget build(BuildContext context) {
    // Navegar inmediatamente a TopicTestPage con modo survival activado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.pushReplacement(
        AppRoutes.topicTest,
        extra: {
          'isSurvivalMode': true,
          'survivalSessionId': resumeSessionId,
          'topicTypeId': topicTypeId,
          'specialtyId': specialtyId,
        },
      );
    });

    // Mostrar loading mientras navega
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
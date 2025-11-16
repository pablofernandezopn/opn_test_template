import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../history/model/user_test_model.dart';
import '../../topics/model/grouped_test_session.dart';
import '../../topics/model/topic_model.dart';
import '../../../config/go_route/app_routes.dart';
import '../../../config/utils/topic_encryption.dart';
import '../view/final_test_page.dart';

/// Handler para lógica de tests agrupados
///
/// Separa la lógica de tests agrupados del TopicTestPage principal
/// para mantener el código limpio y modular.
class GroupedTestHandler {
  // ============================================================
  // TIMER MANAGEMENT
  // ============================================================

  /// Calcula la duración inicial del timer para el test actual
  ///
  /// - Test agrupado: usa el tiempo restante global de la sesión
  /// - Test simple: usa la duración individual del topic
  static Duration getInitialDuration({
    required GroupedTestSession? groupedSession,
    required Topic topic,
  }) {
    if (groupedSession != null) {
      // Test agrupado: timer global compartido
      return Duration(seconds: groupedSession.remainingSeconds);
    } else {
      // Test simple: timer individual del topic
      return Duration(seconds: topic.durationSeconds ?? 0);
    }
  }

  /// Actualiza el tiempo restante en la sesión grupal
  static void updateSessionTime({
    required GroupedTestSession? groupedSession,
    required int remainingSeconds,
  }) {
    groupedSession?.remainingSeconds = remainingSeconds;
  }

  // ============================================================
  // TEST FINALIZATION
  // ============================================================

  /// Maneja la finalización de un test agrupado
  ///
  /// Guarda el resultado inmediatamente y decide el siguiente paso:
  /// - Si es la última parte → navega a FinalTestPage
  /// - Si quedan partes → navega al siguiente topic sin mostrar resultados
  static Future<void> handleGroupedFinish({
    required BuildContext context,
    required GroupedTestSession session,
    required UserTest completedTest,
    required int savedUserTestId,
  }) async {
    print('🔍 [GroupedTest] handleGroupedFinish INICIO');
    print('🔍 [GroupedTest] - currentTopicIndex: ${session.currentTopicIndex}');
    print('🔍 [GroupedTest] - totalParts: ${session.totalParts}');
    print('🔍 [GroupedTest] - isLastPart: ${session.isLastPart}');
    print('🔍 [GroupedTest] - currentTopic.id: ${session.currentTopic.id}');
    print('🔍 [GroupedTest] - savedUserTestIds: ${session.savedUserTestIds}');

    // Guardar el ID del test completado
    session.savedUserTestIds.add(savedUserTestId);
    print('🔍 [GroupedTest] - Añadido savedUserTestId: $savedUserTestId');
    print('🔍 [GroupedTest] - savedUserTestIds después: ${session.savedUserTestIds}');

    if (!context.mounted) return;

    // Decidir siguiente acción
    if (session.isLastPart) {
      print('🔍 [GroupedTest] ✅ Es última parte, navegando a FinalTestPage');
      // 🏁 Última parte → Mostrar resultados finales
      // Usar push en lugar de pushReplacement para evitar conflictos con GoRouter
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FinalTestPage(
            topicGroupId: session.topicGroup.id!,
            userTestIds: session.savedUserTestIds,
          ),
        ),
      );
    } else {
      print('🔍 [GroupedTest] ➡️ NO es última parte, avanzando a siguiente');

      // ➡️ Continuar a siguiente parte sin mostrar resultados
      session.moveToNext();

      print('🔍 [GroupedTest] - DESPUÉS de moveToNext():');
      print('🔍 [GroupedTest] - currentTopicIndex: ${session.currentTopicIndex}');
      print('🔍 [GroupedTest] - currentPartNumber: ${session.currentPartNumber}');
      print('🔍 [GroupedTest] - isLastPart: ${session.isLastPart}');

      final nextTopic = session.currentTopic;
      print('🔍 [GroupedTest] - nextTopic.id: ${nextTopic.id}');
      print('🔍 [GroupedTest] - nextTopic.topicName: ${nextTopic.topicName}');

      final encodedId = TopicEncryption.encode(nextTopic.id!);
      final route = '${AppRoutes.topicTest}/$encodedId';
      print('🔍 [GroupedTest] - Navegando a ruta: $route');

      // Usar context.push() en lugar de context.go() para mantener el extra
      // context.go() pierde el extra porque GoRouter no puede serializar objetos complejos
      context.push(
        route,
        extra: {
          'topic': nextTopic,
          'groupedSession': session,
        },
      );

      print('🔍 [GroupedTest] ✅ context.push() ejecutado');
    }
  }

  /// Maneja el timeout en un test agrupado
  ///
  /// Guarda todos los tests pendientes (con 0 respuestas) y navega a FinalTestPage
  static Future<void> handleGroupedTimeout({
    required BuildContext context,
    required GroupedTestSession session,
    required UserTest? currentPartialTest,
    required int userId,
    required Function(UserTest) saveUserTest,
  }) async {
    // 1. Guardar el test actual si hay progreso parcial
    if (currentPartialTest != null && currentPartialTest.id != null) {
      session.savedUserTestIds.add(currentPartialTest.id!);
    }

    // 2. Guardar todos los topics restantes con 0 respuestas
    final remainingTopics = session.orderedTopics.skip(session.currentTopicIndex + 1).toList();

    for (final topic in remainingTopics) {
      final emptyTest = UserTest(
        userId: userId,
        topicIds: [topic.id!],
        topicGroupId: session.topicGroup.id,
        options: topic.options,
        rightQuestions: 0,
        wrongQuestions: 0,
        questionCount: topic.totalQuestions,
        totalAnswered: 0,
        score: 0.0,
        finalized: true,
        visible: true,
        durationSeconds: topic.durationSeconds ?? 0,
        timeSpentMillis: 0,
        specialTopic: topic.id,
        specialTopicTitle: topic.topicName,
        createdAt: null,
        updatedAt: null,
        isFlashcardMode: false,
      );

      final savedTest = await saveUserTest(emptyTest);
      if (savedTest.id != null) {
        session.savedUserTestIds.add(savedTest.id!);
      }
    }

    if (!context.mounted) return;

    // 3. Navegar a resultados finales con flag de timeout
    // Usar push en lugar de pushReplacement para evitar conflictos con GoRouter
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FinalTestPage(
          topicGroupId: session.topicGroup.id!,
          userTestIds: session.savedUserTestIds,
          timedOut: true,
        ),
      ),
    );
  }

  // ============================================================
  // USER TEST CREATION
  // ============================================================

  /// Crea un UserTest con el topic_group_id vinculado
  static UserTest createUserTestForGroup({
    required int userId,
    required Topic topic,
    required GroupedTestSession session,
    required int rightQuestions,
    required int wrongQuestions,
    required int questionCount,
    required int totalAnswered,
    required double score,
    required int? timeSpentMillis,
    required bool isFlashcardMode,
  }) {
    return UserTest(
      userId: userId,
      topicIds: [topic.id!],
      topicGroupId: session.topicGroup.id, // 🔗 Vincular al grupo
      options: topic.options,
      rightQuestions: rightQuestions,
      wrongQuestions: wrongQuestions,
      questionCount: questionCount,
      totalAnswered: totalAnswered,
      score: score,
      finalized: true,
      visible: true,
      durationSeconds: (timeSpentMillis != null ? (timeSpentMillis / 1000).round() : topic.durationSeconds ?? 0),
      specialTopic: topic.id,
      specialTopicTitle: topic.topicName,
      createdAt: null,
      updatedAt: null,
      isFlashcardMode: isFlashcardMode,
    );
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  /// Título para el AppBar en modo agrupado
  static Widget buildGroupedTitle({
    required BuildContext context,
    required GroupedTestSession session,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          session.topicGroup.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        Text(
          'Parte ${session.currentPartNumber} de ${session.totalParts}',
          style: textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Diálogo de confirmación para abandonar test agrupado
  static Future<bool> showExitConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colors = Theme.of(ctx).colorScheme;
        return AlertDialog(
          icon: Icon(Icons.warning_amber_rounded, color: colors.error, size: 48),
          title: const Text('¿Abandonar examen?'),
          content: const Text(
            'Perderás el progreso de esta parte.\n\n'
            'Las partes ya completadas se mantendrán guardadas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Continuar examen'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
              ),
              child: const Text('Abandonar'),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }
}
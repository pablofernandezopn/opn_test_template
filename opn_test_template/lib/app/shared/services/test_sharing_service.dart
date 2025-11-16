import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../bootstrap.dart';

/// Servicio para compartir tests con usuarios mediante notificaciones push
class TestSharingService {
  static final _supabase = Supabase.instance.client;

  // ==========================================
  // 📤 COMPARTIR CON UN SOLO USUARIO
  // ==========================================

  /// Comparte un test individual con un usuario específico
  static Future<bool> shareTopicWithUser({
    required int userId,
    required int topicId,
    required String topicName,
    int? totalQuestions,
    int? durationMinutes,
    String? imageUrl,
  }) async {
    try {
      logger.info('📤 Compartiendo topic $topicId con usuario $userId');

      final body = _buildTopicNotificationBody(
        topicName: topicName,
        totalQuestions: totalQuestions,
        durationMinutes: durationMinutes,
      );

      final response = await _supabase.functions.invoke(
        'send-push-notification',
        body: {
          'user_id': userId,
          'title': '📝 Nuevo test disponible',
          'body': body,
          if (imageUrl != null) 'image_url': imageUrl,
          'route': '/preview-topic/$topicId',
          'data': {
            'topic_id': topicId.toString(),
            'topic_name': topicName,
            'type': 'test_share',
          }
        },
      );

      return response.status == 200;
    } catch (e, stackTrace) {
      logger.error('❌ Error compartiendo topic: $e');
      logger.debug('StackTrace: $stackTrace');
      return false;
    }
  }

  /// Comparte un test grupal con un usuario específico
  static Future<bool> shareTopicGroupWithUser({
    required int userId,
    required int topicGroupId,
    required String groupName,
    int? totalParts,
    int? totalQuestions,
    String? imageUrl,
  }) async {
    try {
      logger.info('📤 Compartiendo topic group $topicGroupId con usuario $userId');

      final body = _buildGroupNotificationBody(
        groupName: groupName,
        totalParts: totalParts,
        totalQuestions: totalQuestions,
      );

      final response = await _supabase.functions.invoke(
        'send-push-notification',
        body: {
          'user_id': userId,
          'title': '🎯 Examen completo disponible',
          'body': body,
          if (imageUrl != null) 'image_url': imageUrl,
          'route': '/preview-topic-group/$topicGroupId',
          'data': {
            'topic_group_id': topicGroupId.toString(),
            'group_name': groupName,
            'type': 'grouped_test_share',
          }
        },
      );

      return response.status == 200;
    } catch (e, stackTrace) {
      logger.error('❌ Error compartiendo topic group: $e');
      logger.debug('StackTrace: $stackTrace');
      return false;
    }
  }

  // ==========================================
  // 📤 COMPARTIR CON MÚLTIPLES USUARIOS
  // ==========================================

  /// Comparte un test individual con una lista de usuarios
  static Future<ShareResult> shareTopicWithUsers({
    required List<int> userIds,
    required int topicId,
    required String topicName,
    int? totalQuestions,
    int? durationMinutes,
    String? imageUrl,
    int delayBetweenNotifications = 100, // ms entre notificaciones
  }) async {
    logger.info('📤 Compartiendo topic $topicId con ${userIds.length} usuarios');

    final results = <int, bool>{};
    int successCount = 0;
    int failureCount = 0;

    for (final userId in userIds) {
      final success = await shareTopicWithUser(
        userId: userId,
        topicId: topicId,
        topicName: topicName,
        totalQuestions: totalQuestions,
        durationMinutes: durationMinutes,
        imageUrl: imageUrl,
      );

      results[userId] = success;
      if (success) {
        successCount++;
      } else {
        failureCount++;
      }

      // Pequeña pausa para no saturar el servidor
      if (delayBetweenNotifications > 0) {
        await Future.delayed(Duration(milliseconds: delayBetweenNotifications));
      }
    }

    logger.info('✅ Compartido: $successCount exitosos, $failureCount fallidos');

    return ShareResult(
      totalSent: userIds.length,
      successCount: successCount,
      failureCount: failureCount,
      results: results,
    );
  }

  /// Comparte un test grupal con una lista de usuarios
  static Future<ShareResult> shareTopicGroupWithUsers({
    required List<int> userIds,
    required int topicGroupId,
    required String groupName,
    int? totalParts,
    int? totalQuestions,
    String? imageUrl,
    int delayBetweenNotifications = 100,
  }) async {
    logger.info('📤 Compartiendo topic group $topicGroupId con ${userIds.length} usuarios');

    final results = <int, bool>{};
    int successCount = 0;
    int failureCount = 0;

    for (final userId in userIds) {
      final success = await shareTopicGroupWithUser(
        userId: userId,
        topicGroupId: topicGroupId,
        groupName: groupName,
        totalParts: totalParts,
        totalQuestions: totalQuestions,
        imageUrl: imageUrl,
      );

      results[userId] = success;
      if (success) {
        successCount++;
      } else {
        failureCount++;
      }

      if (delayBetweenNotifications > 0) {
        await Future.delayed(Duration(milliseconds: delayBetweenNotifications));
      }
    }

    logger.info('✅ Compartido: $successCount exitosos, $failureCount fallidos');

    return ShareResult(
      totalSent: userIds.length,
      successCount: successCount,
      failureCount: failureCount,
      results: results,
    );
  }

  // ==========================================
  // 📤 COMPARTIR CON TODOS LOS USUARIOS
  // ==========================================

  /// Comparte un test individual con TODOS los usuarios que tienen FCM token
  static Future<ShareResult> shareTopicWithAllUsers({
    required int topicId,
    required String topicName,
    int? totalQuestions,
    int? durationMinutes,
    String? imageUrl,
    int delayBetweenNotifications = 100,
  }) async {
    logger.info('📤 Obteniendo todos los usuarios con FCM token...');

    try {
      // Obtener todos los usuarios que tienen FCM token
      final response = await _supabase
          .from('users')
          .select('id')
          .not('fcm_token', 'is', null);

      final users = response as List<dynamic>;
      final userIds = users.map((u) => u['id'] as int).toList();

      logger.info('📋 Encontrados ${userIds.length} usuarios con FCM token');

      if (userIds.isEmpty) {
        logger.warning('⚠️ No hay usuarios con FCM token');
        return ShareResult(
          totalSent: 0,
          successCount: 0,
          failureCount: 0,
          results: {},
        );
      }

      // Compartir con todos
      return await shareTopicWithUsers(
        userIds: userIds,
        topicId: topicId,
        topicName: topicName,
        totalQuestions: totalQuestions,
        durationMinutes: durationMinutes,
        imageUrl: imageUrl,
        delayBetweenNotifications: delayBetweenNotifications,
      );
    } catch (e, stackTrace) {
      logger.error('❌ Error obteniendo usuarios: $e');
      logger.debug('StackTrace: $stackTrace');
      return ShareResult(
        totalSent: 0,
        successCount: 0,
        failureCount: 0,
        results: {},
      );
    }
  }

  /// Comparte un test grupal con TODOS los usuarios que tienen FCM token
  static Future<ShareResult> shareTopicGroupWithAllUsers({
    required int topicGroupId,
    required String groupName,
    int? totalParts,
    int? totalQuestions,
    String? imageUrl,
    int delayBetweenNotifications = 100,
  }) async {
    logger.info('📤 Obteniendo todos los usuarios con FCM token...');

    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .not('fcm_token', 'is', null);

      final users = response as List<dynamic>;
      final userIds = users.map((u) => u['id'] as int).toList();

      logger.info('📋 Encontrados ${userIds.length} usuarios con FCM token');

      if (userIds.isEmpty) {
        logger.warning('⚠️ No hay usuarios con FCM token');
        return ShareResult(
          totalSent: 0,
          successCount: 0,
          failureCount: 0,
          results: {},
        );
      }

      return await shareTopicGroupWithUsers(
        userIds: userIds,
        topicGroupId: topicGroupId,
        groupName: groupName,
        totalParts: totalParts,
        totalQuestions: totalQuestions,
        imageUrl: imageUrl,
        delayBetweenNotifications: delayBetweenNotifications,
      );
    } catch (e, stackTrace) {
      logger.error('❌ Error obteniendo usuarios: $e');
      logger.debug('StackTrace: $stackTrace');
      return ShareResult(
        totalSent: 0,
        successCount: 0,
        failureCount: 0,
        results: {},
      );
    }
  }

  // ==========================================
  // 📤 COMPARTIR CON FILTROS
  // ==========================================

  /// Comparte un test con usuarios premium
  static Future<ShareResult> shareTopicWithPremiumUsers({
    required int topicId,
    required String topicName,
    int? totalQuestions,
    int? durationMinutes,
    String? imageUrl,
  }) async {
    logger.info('📤 Obteniendo usuarios premium con FCM token...');

    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('is_premium', true)
          .not('fcm_token', 'is', null);

      final users = response as List<dynamic>;
      final userIds = users.map((u) => u['id'] as int).toList();

      logger.info('📋 Encontrados ${userIds.length} usuarios premium');

      return await shareTopicWithUsers(
        userIds: userIds,
        topicId: topicId,
        topicName: topicName,
        totalQuestions: totalQuestions,
        durationMinutes: durationMinutes,
        imageUrl: imageUrl,
      );
    } catch (e, stackTrace) {
      logger.error('❌ Error obteniendo usuarios premium: $e');
      logger.debug('StackTrace: $stackTrace');
      return ShareResult(
        totalSent: 0,
        successCount: 0,
        failureCount: 0,
        results: {},
      );
    }
  }

  /// Comparte un test con usuarios de una academia específica
  static Future<ShareResult> shareTopicWithAcademyUsers({
    required int academyId,
    required int topicId,
    required String topicName,
    int? totalQuestions,
    int? durationMinutes,
    String? imageUrl,
  }) async {
    logger.info('📤 Obteniendo usuarios de academia $academyId con FCM token...');

    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('academy_id', academyId)
          .not('fcm_token', 'is', null);

      final users = response as List<dynamic>;
      final userIds = users.map((u) => u['id'] as int).toList();

      logger.info('📋 Encontrados ${userIds.length} usuarios de la academia');

      return await shareTopicWithUsers(
        userIds: userIds,
        topicId: topicId,
        topicName: topicName,
        totalQuestions: totalQuestions,
        durationMinutes: durationMinutes,
        imageUrl: imageUrl,
      );
    } catch (e, stackTrace) {
      logger.error('❌ Error obteniendo usuarios de academia: $e');
      logger.debug('StackTrace: $stackTrace');
      return ShareResult(
        totalSent: 0,
        successCount: 0,
        failureCount: 0,
        results: {},
      );
    }
  }

  // ==========================================
  // 🛠️ HELPERS PRIVADOS
  // ==========================================

  static String _buildTopicNotificationBody({
    required String topicName,
    int? totalQuestions,
    int? durationMinutes,
  }) {
    final parts = <String>[topicName];

    if (totalQuestions != null) {
      parts.add('$totalQuestions preguntas');
    }

    if (durationMinutes != null) {
      parts.add('$durationMinutes min');
    }

    return parts.join(' | ');
  }

  static String _buildGroupNotificationBody({
    required String groupName,
    int? totalParts,
    int? totalQuestions,
  }) {
    final parts = <String>[groupName];

    if (totalParts != null) {
      parts.add('$totalParts partes');
    }

    if (totalQuestions != null) {
      parts.add('$totalQuestions preguntas');
    }

    return parts.join(' | ');
  }
}

/// Resultado de compartir tests con múltiples usuarios
class ShareResult {
  final int totalSent;
  final int successCount;
  final int failureCount;
  final Map<int, bool> results; // userId -> success

  ShareResult({
    required this.totalSent,
    required this.successCount,
    required this.failureCount,
    required this.results,
  });

  bool get allSuccess => failureCount == 0;
  double get successRate => totalSent > 0 ? successCount / totalSent : 0.0;

  @override
  String toString() {
    return 'ShareResult(total: $totalSent, success: $successCount, failed: $failureCount, rate: ${(successRate * 100).toStringAsFixed(1)}%)';
  }
}
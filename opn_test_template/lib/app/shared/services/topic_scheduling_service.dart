import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../bootstrap.dart';

/// Servicio para programar la publicación de topics con notificaciones automáticas
class TopicSchedulingService {
  static final _supabase = Supabase.instance.client;

  // ==========================================
  // 📅 PROGRAMAR PUBLICACIÓN DE TOPICS
  // ==========================================

  /// Programa la publicación de un topic para una fecha específica
  ///
  /// Cuando llegue la fecha, el sistema automáticamente enviará
  /// notificaciones push a todos los usuarios correspondientes
  static Future<bool> scheduleTopicPublication({
    required int topicId,
    required DateTime publishAt,
  }) async {
    try {
      logger.info('📅 Programando publicación del topic $topicId para $publishAt');

      final response = await _supabase
          .from('topic')
          .update({
            'published_at': publishAt.toUtc().toIso8601String(),
            'notification_sent_at': null, // Resetear por si acaso
          })
          .eq('id', topicId);

      logger.info('✅ Topic $topicId programado para ${publishAt.toLocal()}');
      return true;
    } catch (e, stackTrace) {
      logger.error('❌ Exception programando topic: $e');
      logger.debug('StackTrace: $stackTrace');
      return false;
    }
  }

  /// Programa la publicación de un topic group para una fecha específica
  static Future<bool> scheduleTopicGroupPublication({
    required int topicGroupId,
    required DateTime publishAt,
  }) async {
    try {
      logger.info('📅 Programando publicación del grupo $topicGroupId para $publishAt');

      final response = await _supabase
          .from('topic_groups')
          .update({
            'published_at': publishAt.toUtc().toIso8601String(),
            'notification_sent_at': null,
          })
          .eq('id', topicGroupId);

      logger.info('✅ Grupo $topicGroupId programado para ${publishAt.toLocal()}');
      return true;
    } catch (e, stackTrace) {
      logger.error('❌ Exception programando grupo: $e');
      logger.debug('StackTrace: $stackTrace');
      return false;
    }
  }

  // ==========================================
  // ⏰ HELPERS PARA FECHAS COMUNES
  // ==========================================

  /// Programa para mañana a una hora específica
  static Future<bool> scheduleTopicForTomorrow({
    required int topicId,
    int hour = 9,
    int minute = 0,
  }) async {
    final tomorrow = DateTime.now()
        .add(Duration(days: 1))
        .copyWith(hour: hour, minute: minute, second: 0, millisecond: 0);

    return scheduleTopicPublication(
      topicId: topicId,
      publishAt: tomorrow,
    );
  }

  /// Programa para la próxima semana
  static Future<bool> scheduleTopicForNextWeek({
    required int topicId,
    int weekday = DateTime.monday, // 1=lunes, 7=domingo
    int hour = 9,
    int minute = 0,
  }) async {
    final now = DateTime.now();
    final daysUntilTarget = (weekday - now.weekday + 7) % 7;
    final daysToAdd = daysUntilTarget == 0 ? 7 : daysUntilTarget;

    final nextWeek = now
        .add(Duration(days: daysToAdd))
        .copyWith(hour: hour, minute: minute, second: 0, millisecond: 0);

    return scheduleTopicPublication(
      topicId: topicId,
      publishAt: nextWeek,
    );
  }

  /// Programa para un día específico del mes
  static Future<bool> scheduleTopicForDayOfMonth({
    required int topicId,
    required int day, // 1-31
    int hour = 9,
    int minute = 0,
  }) async {
    final now = DateTime.now();
    DateTime targetDate;

    // Si el día ya pasó este mes, programar para el siguiente mes
    if (now.day >= day) {
      targetDate = DateTime(now.year, now.month + 1, day, hour, minute);
    } else {
      targetDate = DateTime(now.year, now.month, day, hour, minute);
    }

    return scheduleTopicPublication(
      topicId: topicId,
      publishAt: targetDate,
    );
  }

  // ==========================================
  // 🔍 CONSULTAR PROGRAMACIÓN
  // ==========================================

  /// Obtiene la fecha de publicación programada de un topic
  static Future<DateTime?> getTopicPublishDate(int topicId) async {
    try {
      final response = await _supabase
          .from('topic')
          .select('published_at, notification_sent_at')
          .eq('id', topicId)
          .single();

      final publishedAt = response['published_at'] as String?;

      if (publishedAt == null) {
        return null;
      }

      return DateTime.parse(publishedAt);
    } catch (e) {
      logger.error('Error obteniendo fecha de publicación: $e');
      return null;
    }
  }

  /// Verifica si un topic ya fue notificado
  static Future<bool> wasTopicNotified(int topicId) async {
    try {
      final response = await _supabase
          .from('topic')
          .select('notification_sent_at')
          .eq('id', topicId)
          .single();

      return response['notification_sent_at'] != null;
    } catch (e) {
      logger.error('Error verificando notificación: $e');
      return false;
    }
  }

  /// Obtiene todos los topics pendientes de publicar
  static Future<List<Map<String, dynamic>>> getPendingTopics() async {
    try {
      final response = await _supabase
          .from('topic')
          .select('id, topic_name, published_at, notification_sent_at')
          .not('published_at', 'is', null)
          .isFilter('notification_sent_at', null)
          .order('published_at', ascending: true);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      logger.error('Error obteniendo topics pendientes: $e');
      return [];
    }
  }

  // ==========================================
  // ❌ CANCELAR PROGRAMACIÓN
  // ==========================================

  /// Cancela la publicación programada de un topic
  static Future<bool> cancelTopicPublication(int topicId) async {
    try {
      logger.info('🚫 Cancelando publicación programada del topic $topicId');

      final response = await _supabase
          .from('topic')
          .update({
            'published_at': null,
            'notification_sent_at': null,
          })
          .eq('id', topicId);

      logger.info('✅ Programación cancelada para topic $topicId');
      return true;
    } catch (e, stackTrace) {
      logger.error('❌ Exception cancelando programación: $e');
      logger.debug('StackTrace: $stackTrace');
      return false;
    }
  }

  /// Cancela la publicación programada de un topic group
  static Future<bool> cancelTopicGroupPublication(int topicGroupId) async {
    try {
      logger.info('🚫 Cancelando publicación programada del grupo $topicGroupId');

      final response = await _supabase
          .from('topic_groups')
          .update({
            'published_at': null,
            'notification_sent_at': null,
          })
          .eq('id', topicGroupId);

      logger.info('✅ Programación cancelada para grupo $topicGroupId');
      return true;
    } catch (e, stackTrace) {
      logger.error('❌ Exception cancelando programación: $e');
      logger.debug('StackTrace: $stackTrace');
      return false;
    }
  }

  // ==========================================
  // 🔄 RE-PROGRAMAR
  // ==========================================

  /// Re-programa un topic que ya fue notificado
  ///
  /// Útil si quieres volver a enviar notificaciones del mismo topic
  static Future<bool> rescheduleTopicPublication({
    required int topicId,
    required DateTime newPublishAt,
  }) async {
    try {
      logger.info('🔄 Re-programando topic $topicId para $newPublishAt');

      final response = await _supabase
          .from('topic')
          .update({
            'published_at': newPublishAt.toUtc().toIso8601String(),
            'notification_sent_at': null, // Resetear para permitir re-notificación
          })
          .eq('id', topicId);

      logger.info('✅ Topic $topicId re-programado para ${newPublishAt.toLocal()}');
      return true;
    } catch (e, stackTrace) {
      logger.error('❌ Exception re-programando topic: $e');
      logger.debug('StackTrace: $stackTrace');
      return false;
    }
  }

  // ==========================================
  // 📊 INFORMACIÓN Y ESTADÍSTICAS
  // ==========================================

  /// Obtiene información completa de programación de un topic
  static Future<TopicScheduleInfo?> getTopicScheduleInfo(int topicId) async {
    try {
      final response = await _supabase
          .from('topic')
          .select('id, topic_name, published_at, notification_sent_at')
          .eq('id', topicId)
          .single();

      return TopicScheduleInfo.fromMap(response);
    } catch (e) {
      logger.error('Error obteniendo info de programación: $e');
      return null;
    }
  }

  /// Obtiene estadísticas de topics programados
  static Future<ScheduleStatistics> getScheduleStatistics() async {
    try {
      // Topics programados pero aún no publicados
      final pendingResponse = await _supabase
          .from('topic')
          .select('id')
          .not('published_at', 'is', null)
          .isFilter('notification_sent_at', null);

      // Topics que ya fueron publicados
      final publishedResponse = await _supabase
          .from('topic')
          .select('id')
          .not('published_at', 'is', null)
          .not('notification_sent_at', 'is', null);

      // Topics atrasados (deberían haberse publicado ya)
      final overdueResponse = await _supabase
          .from('topic')
          .select('id')
          .not('published_at', 'is', null)
          .lte('published_at', DateTime.now().toUtc().toIso8601String())
          .isFilter('notification_sent_at', null);

      return ScheduleStatistics(
        totalScheduled: (pendingResponse as List).length,
        totalPublished: (publishedResponse as List).length,
        totalOverdue: (overdueResponse as List).length,
      );
    } catch (e) {
      logger.error('Error obteniendo estadísticas: $e');
      return ScheduleStatistics(
        totalScheduled: 0,
        totalPublished: 0,
        totalOverdue: 0,
      );
    }
  }
}

// ==========================================
// 📊 MODELOS DE DATOS
// ==========================================

/// Información de programación de un topic
class TopicScheduleInfo {
  final int id;
  final String topicName;
  final DateTime? publishAt;
  final DateTime? notificationSentAt;

  TopicScheduleInfo({
    required this.id,
    required this.topicName,
    this.publishAt,
    this.notificationSentAt,
  });

  bool get isScheduled => publishAt != null;
  bool get wasNotified => notificationSentAt != null;
  bool get isPending => isScheduled && !wasNotified;
  bool get isOverdue => isPending && publishAt!.isBefore(DateTime.now());

  Duration? get timeUntilPublish {
    if (publishAt == null) return null;
    return publishAt!.difference(DateTime.now());
  }

  String get status {
    if (!isScheduled) return 'No programado';
    if (wasNotified) return 'Publicado';
    if (isOverdue) return 'Atrasado';
    return 'Programado';
  }

  factory TopicScheduleInfo.fromMap(Map<String, dynamic> map) {
    return TopicScheduleInfo(
      id: map['id'] as int,
      topicName: map['topic_name'] as String,
      publishAt: map['published_at'] != null
          ? DateTime.parse(map['published_at'] as String)
          : null,
      notificationSentAt: map['notification_sent_at'] != null
          ? DateTime.parse(map['notification_sent_at'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'TopicScheduleInfo(id: $id, name: $topicName, status: $status, publishAt: $publishAt)';
  }
}

/// Estadísticas de programación
class ScheduleStatistics {
  final int totalScheduled;
  final int totalPublished;
  final int totalOverdue;

  ScheduleStatistics({
    required this.totalScheduled,
    required this.totalPublished,
    required this.totalOverdue,
  });

  int get totalPending => totalScheduled - totalOverdue;

  @override
  String toString() {
    return 'ScheduleStatistics(scheduled: $totalScheduled, published: $totalPublished, overdue: $totalOverdue)';
  }
}
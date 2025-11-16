// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Challenge _$ChallengeFromJson(Map<String, dynamic> json) => Challenge(
      id: (json['id'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      userId: (json['user_id'] as num?)?.toInt(),
      questionId: (json['question_id'] as num?)?.toInt(),
      topicId: (json['topic_id'] as num?)?.toInt(),
      reason: json['reason'] as String?,
      state: $enumDecodeNullable(_$ChallengeStatusEnumMap, json['state']) ??
          ChallengeStatus.pendiente,
      reply: json['reply'] as String? ?? '',
      editorId: (json['editor_id'] as num?)?.toInt(),
      open: json['open'] as bool? ?? true,
      tutorUuid: json['tutor_uuid'] as String?,
      academyId: (json['academy_id'] as num?)?.toInt() ?? 1,
      specialtyId: (json['specialty_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ChallengeToJson(Challenge instance) => <String, dynamic>{
      'user_id': instance.userId,
      'question_id': instance.questionId,
      'topic_id': instance.topicId,
      'reason': instance.reason,
      'state': _$ChallengeStatusEnumMap[instance.state]!,
      'reply': instance.reply,
      'editor_id': instance.editorId,
      'open': instance.open,
      'tutor_uuid': instance.tutorUuid,
      'academy_id': instance.academyId,
      'specialty_id': instance.specialtyId,
    };

const _$ChallengeStatusEnumMap = {
  ChallengeStatus.pendiente: 'pendiente',
  ChallengeStatus.aceptada: 'aceptada',
  ChallengeStatus.rechazada: 'rechazada',
};

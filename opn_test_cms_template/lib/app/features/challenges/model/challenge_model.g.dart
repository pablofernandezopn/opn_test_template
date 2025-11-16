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
          ChallengeStatus.pending,
      reply: json['reply'] as String? ?? '',
      editorId: (json['editor_id'] as num?)?.toInt(),
      open: json['open'] as bool? ?? true,
      tutorUuid: json['tutor_uuid'] as String?,
      academyId: (json['academy_id'] as num?)?.toInt() ?? 1,
      specialtyId: (json['specialty_id'] as num?)?.toInt(),
      questionText: json['question_text'] as String?,
      topicName: json['topic_name'] as String?,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      editorName: json['editor_name'] as String?,
      academyName: json['academy_name'] as String?,
      topic: json['topic'] == null
          ? null
          : Topic.fromJson(json['topic'] as Map<String, dynamic>),
      question: json['question'] == null
          ? null
          : Question.fromJson(json['question'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      editor: json['editor'] == null
          ? null
          : CmsUser.fromJson(json['editor'] as Map<String, dynamic>),
      dirty: json['dirty'] as bool? ?? false,
    );

Map<String, dynamic> _$ChallengeToJson(Challenge instance) => <String, dynamic>{
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
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
  ChallengeStatus.pending: 'pendiente',
  ChallengeStatus.approved: 'resuelta',
  ChallengeStatus.rejected: 'rechazada',
};

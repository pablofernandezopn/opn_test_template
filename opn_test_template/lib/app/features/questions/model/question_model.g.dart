// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
      id: (json['id'] as num?)?.toInt(),
      question: json['question'] as String,
      tip: json['tip'] as String?,
      topic: (json['topic'] as num).toInt(),
      article: json['article'] as String?,
      questionImageUrl: json['question_image_url'] as String? ?? '',
      retroImageUrl: json['retro_image_url'] as String? ?? '',
      retroAudioEnable: json['retro_audio_enable'] as bool? ?? false,
      retroAudioText: json['retro_audio_text'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      published: json['published'] as bool? ?? true,
      shuffled: json['shuffled'] as bool?,
      numAnswered: (json['num_answered'] as num?)?.toInt() ?? 0,
      numFails: (json['num_fails'] as num?)?.toInt() ?? 0,
      numEmpty: (json['num_empty'] as num?)?.toInt() ?? 0,
      difficultRate: (json['difficult_rate'] as num?)?.toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String?,
      challengeByTutor: json['challenge_by_tutor'] as bool? ?? false,
      challengeReason: json['challenge_reason'] as String?,
      academyId: (json['academy_id'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'tip': instance.tip,
      'topic': instance.topic,
      'article': instance.article,
      'question_image_url': instance.questionImageUrl,
      'retro_image_url': instance.retroImageUrl,
      'retro_audio_enable': instance.retroAudioEnable,
      'retro_audio_text': instance.retroAudioText,
      'order': instance.order,
      'published': instance.published,
      'shuffled': instance.shuffled,
      'num_answered': instance.numAnswered,
      'num_fails': instance.numFails,
      'num_empty': instance.numEmpty,
      'difficult_rate': instance.difficultRate,
      'created_at': instance.createdAt?.toIso8601String(),
      'created_by': instance.createdBy,
      'challenge_by_tutor': instance.challengeByTutor,
      'challenge_reason': instance.challengeReason,
      'academy_id': instance.academyId,
    };

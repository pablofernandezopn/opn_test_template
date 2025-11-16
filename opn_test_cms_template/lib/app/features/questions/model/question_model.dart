import 'package:json_annotation/json_annotation.dart';

part 'question_model.g.dart';

@JsonSerializable()
class Question {
  /// ID único de la pregunta (bigint)
  final int? id;

  /// Texto de la pregunta (requerido)
  final String question;

  /// Tip o pista para la pregunta (opcional)
  final String? tip;

  /// ID del topic al que pertenece esta pregunta (requerido, FK)
  final int topic;

  /// Artículo de referencia (opcional)
  final String? article;

  /// URL de la imagen de la pregunta (default: '')
  @JsonKey(name: 'question_image_url', defaultValue: '')
  final String questionImageUrl;

  /// URL de la imagen de retroalimentación (default: '')
  @JsonKey(name: 'retro_image_url', defaultValue: '')
  final String retroImageUrl;

  /// Si está habilitado el audio de retroalimentación (default: false)
  @JsonKey(name: 'retro_audio_enable', defaultValue: false)
  final bool retroAudioEnable;

  /// Texto del audio de retroalimentación (default: '')
  @JsonKey(name: 'retro_audio_text', defaultValue: '')
  final String retroAudioText;

  /// URL del audio de retroalimentación generado (default: '')
  @JsonKey(name: 'retro_audio_url', defaultValue: '')
  final String retroAudioUrl;

  /// Orden de la pregunta (integer, default: 0)
  @JsonKey(name: 'order', defaultValue: 0)
  final int order;

  /// Si la pregunta está publicada (default: true)
  @JsonKey(defaultValue: true)
  final bool published;

  /// Si las opciones están mezcladas (opcional)
  final bool? shuffled;

  /// Número de veces que se ha contestado correctamente (default: 0)
  @JsonKey(name: 'num_answered', defaultValue: 0)
  final int numAnswered;

  /// Número de veces que se ha fallado (default: 0)
  @JsonKey(name: 'num_fails', defaultValue: 0)
  final int numFails;

  /// Número de veces que se ha dejado en blanco (default: 0)
  @JsonKey(name: 'num_empty', defaultValue: 0)
  final int numEmpty;

  /// Tasa de dificultad calculada (GENERATED ALWAYS, read-only)
  @JsonKey(name: 'difficult_rate')
  final double? difficultRate;

  /// Fecha de creación (default: now())
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Fecha de última actualización (actualizado automáticamente por trigger)
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// UUID del usuario que creó la pregunta (FK a auth.users)
  @JsonKey(name: 'created_by')
  final String? createdBy;

  /// Si ha sido desafiada por un tutor (default: false)
  @JsonKey(name: 'challenge_by_tutor', defaultValue: false)
  final bool challengeByTutor;

  /// Razón del desafío por el tutor (opcional)
  @JsonKey(name: 'challenge_reason')
  final String? challengeReason;

  /// ID de la academia a la que pertenece esta pregunta (bigint, default: 1)
  @JsonKey(name: 'academy_id', defaultValue: 1)
  final int academyId;

  const Question({
    this.id,
    required this.question,
    this.tip,
    required this.topic,
    this.article,
    this.questionImageUrl = '',
    this.retroImageUrl = '',
    this.retroAudioEnable = false,
    this.retroAudioText = '',
    this.retroAudioUrl = '',
    this.order = 0,
    this.published = true,
    this.shuffled,
    this.numAnswered = 0,
    this.numFails = 0,
    this.numEmpty = 0,
    this.difficultRate,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.challengeByTutor = false,
    this.challengeReason,
    this.academyId = 1,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$QuestionToJson(this);
    // Remover campos que son GENERATED o que no deberían enviarse en INSERT/UPDATE
    json.remove('difficult_rate'); // Campo calculado, no debe enviarse
    json.remove('updated_at'); // Campo actualizado automáticamente por trigger
    if (id == null) {
      json.remove('id'); // No enviar ID en INSERT
      json.remove('created_at'); // La BD lo genera automáticamente
    }
    return json;
  }

  Question copyWith({
    int? id,
    String? question,
    String? tip,
    int? topic,
    String? article,
    String? questionImageUrl,
    String? retroImageUrl,
    bool? retroAudioEnable,
    String? retroAudioText,
    String? retroAudioUrl,
    int? order,
    bool? published,
    bool? shuffled,
    int? numAnswered,
    int? numFails,
    int? numEmpty,
    double? difficultRate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? challengeByTutor,
    String? challengeReason,
    int? academyId,
  }) {
    return Question(
      id: id ?? this.id,
      question: question ?? this.question,
      tip: tip ?? this.tip,
      topic: topic ?? this.topic,
      article: article ?? this.article,
      questionImageUrl: questionImageUrl ?? this.questionImageUrl,
      retroImageUrl: retroImageUrl ?? this.retroImageUrl,
      retroAudioEnable: retroAudioEnable ?? this.retroAudioEnable,
      retroAudioText: retroAudioText ?? this.retroAudioText,
      retroAudioUrl: retroAudioUrl ?? this.retroAudioUrl,
      order: order ?? this.order,
      published: published ?? this.published,
      shuffled: shuffled ?? this.shuffled,
      numAnswered: numAnswered ?? this.numAnswered,
      numFails: numFails ?? this.numFails,
      numEmpty: numEmpty ?? this.numEmpty,
      difficultRate: difficultRate ?? this.difficultRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      challengeByTutor: challengeByTutor ?? this.challengeByTutor,
      challengeReason: challengeReason ?? this.challengeReason,
      academyId: academyId ?? this.academyId,
    );
  }
}

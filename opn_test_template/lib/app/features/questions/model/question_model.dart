import 'package:json_annotation/json_annotation.dart';

part 'question_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Question {
  /// ID único de la pregunta
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
  @JsonKey(defaultValue: '')
  final String questionImageUrl;

  /// URL de la imagen de retroalimentación (default: '')
  @JsonKey(defaultValue: '')
  final String retroImageUrl;

  /// Si está habilitado el audio de retroalimentación (default: false)
  @JsonKey(defaultValue: false)
  final bool retroAudioEnable;

  /// Texto del audio de retroalimentación (default: '')
  @JsonKey(defaultValue: '')
  final String retroAudioText;

  /// Orden de la pregunta (int8, default: 0)
  @JsonKey(name: 'order', defaultValue: 0)
  final int order;

  /// Si la pregunta está publicada (default: true)
  @JsonKey(defaultValue: true)
  final bool published;

  /// Si las opciones están mezcladas (opcional)
  final bool? shuffled;

  /// Número de veces que se ha contestado correctamente (default: 0)
  @JsonKey(defaultValue: 0)
  final int numAnswered;

  /// Número de veces que se ha fallado (default: 0)
  @JsonKey(defaultValue: 0)
  final int numFails;

  /// Número de veces que se ha dejado en blanco (default: 0)
  @JsonKey(defaultValue: 0)
  final int numEmpty;

  /// Tasa de dificultad calculada (GENERATED ALWAYS, read-only)
  final double? difficultRate;

  /// Fecha de creación (default: now())
  final DateTime? createdAt;

  /// UUID del usuario que creó la pregunta (FK a auth.users, puede ser IP)
  final String? createdBy;

  /// Si ha sido desafiada por un tutor (default: false)
  @JsonKey(defaultValue: false)
  final bool challengeByTutor;

  /// Razón del desafío por el tutor (opcional)
  final String? challengeReason;

  /// ID de la academia a la que pertenece esta pregunta
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
    this.order = 0,
    this.published = true,
    this.shuffled,
    this.numAnswered = 0,
    this.numFails = 0,
    this.numEmpty = 0,
    this.difficultRate,
    this.createdAt,
    this.createdBy,
    this.challengeByTutor = false,
    this.challengeReason,
    this.academyId = 1,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Manejar el caso donde 'topic' puede venir como objeto o como número
    int topicId;
    if (json['topic'] is Map) {
      // Si viene como objeto, extraer el ID
      topicId = (json['topic'] as Map<String, dynamic>)['id'] as int;
    } else if (json['topic'] is num) {
      // Si viene como número, usarlo directamente
      topicId = (json['topic'] as num).toInt();
    } else {
      throw Exception('Invalid topic format in JSON: ${json['topic']}');
    }

    // Crear una copia del JSON con el topic como número
    final modifiedJson = Map<String, dynamic>.from(json);
    modifiedJson['topic'] = topicId;

    return _$QuestionFromJson(modifiedJson);
  }

  Map<String, dynamic> toJson() {
    final json = _$QuestionToJson(this);
    // Remover campos que son GENERATED o que no deberían enviarse en INSERT/UPDATE
    json.remove('difficult_rate'); // Campo calculado, no debe enviarse
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
    int? order,
    bool? published,
    bool? shuffled,
    int? numAnswered,
    int? numFails,
    int? numEmpty,
    double? difficultRate,
    DateTime? createdAt,
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
      order: order ?? this.order,
      published: published ?? this.published,
      shuffled: shuffled ?? this.shuffled,
      numAnswered: numAnswered ?? this.numAnswered,
      numFails: numFails ?? this.numFails,
      numEmpty: numEmpty ?? this.numEmpty,
      difficultRate: difficultRate ?? this.difficultRate,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      challengeByTutor: challengeByTutor ?? this.challengeByTutor,
      challengeReason: challengeReason ?? this.challengeReason,
      academyId: academyId ?? this.academyId,
    );
  }
}

import 'package:json_annotation/json_annotation.dart';

part 'challenge_model.g.dart';

/// Estados posibles de una impugnación
enum ChallengeStatus {
  @JsonValue('pendiente')
  pendiente,
  @JsonValue('aceptada')
  aceptada,
  @JsonValue('rechazada')
  rechazada,
}

extension ChallengeStatusExtension on ChallengeStatus {
  String get displayName {
    switch (this) {
      case ChallengeStatus.pendiente:
        return 'Pendiente';
      case ChallengeStatus.aceptada:
        return 'Aceptada';
      case ChallengeStatus.rechazada:
        return 'Rechazada';
    }
  }
}

@JsonSerializable(explicitToJson: true)
class Challenge {
  @JsonKey(includeToJson: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: 'created_at', includeToJson: false)
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at', includeToJson: false)
  final DateTime? updatedAt;

  @JsonKey(name: 'user_id')
  final int? userId;

  @JsonKey(name: 'question_id')
  final int? questionId;

  @JsonKey(name: 'topic_id')
  final int? topicId;

  final String? reason;

  final ChallengeStatus state;

  final String reply;

  @JsonKey(name: 'editor_id')
  final int? editorId;

  final bool open;

  @JsonKey(name: 'tutor_uuid')
  final String? tutorUuid;

  @JsonKey(name: 'academy_id')
  final int academyId;

  @JsonKey(name: 'specialty_id')
  final int? specialtyId;

  const Challenge({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.questionId,
    this.topicId,
    this.reason,
    this.state = ChallengeStatus.pendiente,
    this.reply = '',
    this.editorId,
    this.open = true,
    this.tutorUuid,
    this.academyId = 1,
    this.specialtyId,
  });

  /// Crea una instancia desde JSON
  factory Challenge.fromJson(Map<String, dynamic> json) => _$ChallengeFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() => _$ChallengeToJson(this);

  /// Crea una copia con campos modificados
  Challenge copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? userId,
    int? questionId,
    int? topicId,
    String? reason,
    ChallengeStatus? state,
    String? reply,
    int? editorId,
    bool? open,
    String? tutorUuid,
    int? academyId,
    int? specialtyId,
  }) {
    return Challenge(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      questionId: questionId ?? this.questionId,
      topicId: topicId ?? this.topicId,
      reason: reason ?? this.reason,
      state: state ?? this.state,
      reply: reply ?? this.reply,
      editorId: editorId ?? this.editorId,
      open: open ?? this.open,
      tutorUuid: tutorUuid ?? this.tutorUuid,
      academyId: academyId ?? this.academyId,
      specialtyId: specialtyId ?? this.specialtyId,
    );
  }

  @override
  String toString() {
    return 'Challenge(id: $id, questionId: $questionId, state: $state, open: $open)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Challenge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
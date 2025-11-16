import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/model/user.dart';
import '../../topics/model/topic_model.dart';
import '../../questions/model/question_model.dart';
import '../../../authentification/auth/model/user.dart';

part 'challenge_model.g.dart';

/// Estados posibles de una impugnación
enum ChallengeStatus {
  /// Impugnación pendiente de revisión
  @JsonValue('pendiente')
  pending('pendiente', 'Pendiente'),

  /// Impugnación aprobada - se modificará la pregunta
  @JsonValue('resuelta')
  approved('resuelta', 'Resuelta'),

  /// Impugnación rechazada - la pregunta es correcta
  @JsonValue('rechazada')
  rejected('rechazada', 'Rechazada');

  const ChallengeStatus(this.value, this.label);
  final String value;
  final String label;

  static ChallengeStatus fromString(String value) {
    return ChallengeStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ChallengeStatus.pending,
    );
  }

  bool get isPending => this == ChallengeStatus.pending;
  bool get isApproved => this == ChallengeStatus.approved;
  bool get isRejected => this == ChallengeStatus.rejected;
}

/// Extensión para agregar configuración de UI al enum ChallengeStatus
extension ChallengeStatusConfig on ChallengeStatus {
  /// Icono representativo del estado
  IconData get icon {
    switch (this) {
      case ChallengeStatus.pending:
        return Icons.pending_actions;
      case ChallengeStatus.approved:
        return Icons.check_circle;
      case ChallengeStatus.rejected:
        return Icons.cancel;
    }
  }

  /// Color representativo del estado
  Color get color {
    switch (this) {
      case ChallengeStatus.pending:
        return Colors.orange;
      case ChallengeStatus.approved:
        return Colors.green;
      case ChallengeStatus.rejected:
        return Colors.red;
    }
  }

  /// Key para acceder a las estadísticas del estado
  String get statsKey {
    switch (this) {
      case ChallengeStatus.pending:
        return 'pendiente';
      case ChallengeStatus.approved:
        return 'resuelta';
      case ChallengeStatus.rejected:
        return 'rechazada';
    }
  }
}

/// Representa una impugnación realizada sobre una pregunta del sistema.
///
/// Las impugnaciones permiten a los usuarios reportar:
/// - Preguntas incorrectas
/// - Respuestas erróneas
/// - Problemas en el contenido
/// - Sugerencias de mejora
@JsonSerializable(explicitToJson: true)
class Challenge {
  /// ID único de la impugnación
  @JsonKey(includeToJson: false, includeIfNull: false)
  final int? id;

  /// Fecha de creación de la impugnación
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Fecha de última actualización
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// ID del usuario que creó la impugnación (FK a users)
  @JsonKey(name: 'user_id')
  final int? userId;

  /// ID de la pregunta impugnada (FK a questions)
  @JsonKey(name: 'question_id')
  final int? questionId;

  /// ID del topic de la pregunta (FK a topic)
  @JsonKey(name: 'topic_id')
  final int? topicId;

  /// Razón de la impugnación
  /// Descripción detallada del problema encontrado
  final String? reason;

  /// Estado actual de la impugnación
  @JsonKey(defaultValue: ChallengeStatus.pending)
  final ChallengeStatus state;

  /// Respuesta o comentarios del editor/revisor
  @JsonKey(defaultValue: '')
  final String reply;

  /// ID del editor CMS que revisó la impugnación (FK a cms_users)
  @JsonKey(name: 'editor_id')
  final int? editorId;

  /// Indica si la impugnación está abierta/pendiente
  @JsonKey(defaultValue: true)
  final bool open;

  /// UUID del tutor asociado (si aplica)
  @JsonKey(name: 'tutor_uuid')
  final String? tutorUuid;

  /// ID de la academia a la que pertenece esta impugnación
  @JsonKey(name: 'academy_id', defaultValue: 1)
  final int academyId;

  /// ID de la especialidad de la que proviene el challenge (NULL = compartido)
  @JsonKey(name: 'specialty_id')
  final int? specialtyId;

  // Campos denormalizados (no se envían a la BD, solo para UI)
  @JsonKey(name: 'question_text', includeToJson: false, includeIfNull: false)
  final String? questionText;

  @JsonKey(name: 'topic_name', includeToJson: false, includeIfNull: false)
  final String? topicName;

  @JsonKey(name: 'user_name', includeToJson: false, includeIfNull: false)
  final String? userName;

  @JsonKey(name: 'user_email', includeToJson: false, includeIfNull: false)
  final String? userEmail;

  @JsonKey(name: 'editor_name', includeToJson: false, includeIfNull: false)
  final String? editorName;

  @JsonKey(name: 'academy_name', includeToJson: false, includeIfNull: false)
  final String? academyName;

  /// Objeto Topic completo (solo para lectura, no se envía a BD)
  @JsonKey(includeToJson: false, includeIfNull: false)
  final Topic? topic;

  /// Objeto Question completo (solo para lectura, no se envía a BD)
  @JsonKey(includeToJson: false, includeIfNull: false)
  final Question? question;

  /// Usuario que creó la impugnación (objeto completo)
  @JsonKey(includeToJson: false, includeIfNull: false)
  final User? user;

  /// Editor que revisó la impugnación (objeto completo)
  @JsonKey(includeToJson: false, includeIfNull: false)
  final CmsUser? editor;

  /// Indica si el challenge tiene cambios pendientes de guardar (para autoguardado)
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool dirty;

  const Challenge({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.questionId,
    this.topicId,
    this.reason,
    this.state = ChallengeStatus.pending,
    this.reply = '',
    this.editorId,
    this.open = true,
    this.tutorUuid,
    this.academyId = 1,
    this.specialtyId,
    this.questionText,
    this.topicName,
    this.userName,
    this.userEmail,
    this.editorName,
    this.academyName,
    this.topic,
    this.question,
    this.user,
    this.editor,
    this.dirty = false,
  });

  /// Challenge vacío para estados iniciales
  static const Challenge empty = Challenge(
    id: null,
    userId: null,
    questionId: null,
    reason: null,
    state: ChallengeStatus.pending,
  );

  /// Crea una instancia desde JSON
  factory Challenge.fromJson(Map<String, dynamic> json) =>
      _$ChallengeFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    final json = _$ChallengeToJson(this);
    // Remover campos generados automáticamente por la BD en INSERT
    if (id == null) {
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');
    }
    return json;
  }

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
    String? questionText,
    String? topicName,
    String? userName,
    String? userEmail,
    String? editorName,
    String? academyName,
    Topic? topic,
    Question? question,
    User? user,
    CmsUser? editor,
    bool? dirty,
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
      questionText: questionText ?? this.questionText,
      topicName: topicName ?? this.topicName,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      editorName: editorName ?? this.editorName,
      academyName: academyName ?? this.academyName,
      topic: topic ?? this.topic,
      question: question ?? this.question,
      user: user ?? this.user,
      editor: editor ?? this.editor,
      dirty: dirty ?? this.dirty,
    );
  }

  /// Valida que la razón no esté vacía
  bool get hasValidReason =>
      reason != null && reason!.trim().isNotEmpty && reason!.length >= 10;

  /// Valida que el questionId sea válido
  bool get hasValidQuestionId => questionId != null && questionId! > 0;

  /// Valida todos los campos requeridos
  bool get isValid => hasValidReason && hasValidQuestionId;

  /// Indica si la impugnación está vacía
  bool get isEmpty => id == null && questionId == null && reason == null;

  /// Indica si la impugnación está pendiente
  bool get isPending => state.isPending;

  /// Indica si la impugnación fue aprobada
  bool get isApproved => state.isApproved;

  /// Indica si la impugnación fue rechazada
  bool get isRejected => state.isRejected;

  /// Obtiene el color representativo según el estado
  String get statusColor {
    switch (state) {
      case ChallengeStatus.pending:
        return '#FFA726'; // Naranja
      case ChallengeStatus.approved:
        return '#66BB6A'; // Verde
      case ChallengeStatus.rejected:
        return '#EF5350'; // Rojo
    }
  }

  /// Días desde la creación
  int get daysOld {
    if (createdAt == null) return 0;
    return DateTime.now().difference(createdAt!).inDays;
  }

  @override
  String toString() {
    return 'Challenge(id: $id, questionId: $questionId, state: ${state.label}, open: $open)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Challenge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

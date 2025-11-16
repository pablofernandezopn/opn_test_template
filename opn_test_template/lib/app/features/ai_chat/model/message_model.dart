import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

/// Rol del mensaje (compatible con OpenAI/DeepSeek/Anthropic)
enum MessageRoleDb {
  system,
  user,
  assistant,
  function,
}

/// Modelo de mensaje que representa un mensaje individual en una conversación
@JsonSerializable()
class Message {
  final int id;

  @JsonKey(name: 'conversation_id')
  final int conversationId;

  final MessageRoleDb role;
  final String content;
  final int? tokens;
  final double? cost;
  final String? model;

  @JsonKey(name: 'finish_reason')
  final String? finishReason;

  @JsonKey(name: 'function_call')
  final Map<String, dynamic>? functionCall;

  final Map<String, dynamic> metadata;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.tokens,
    this.cost,
    this.model,
    this.finishReason,
    this.functionCall,
    this.metadata = const {},
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

/// Extension para convertir entre el enum y la string de la BD
extension MessageRoleDbX on MessageRoleDb {
  String toDbString() {
    return name;
  }

  static MessageRoleDb fromDbString(String value) {
    return MessageRoleDb.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageRoleDb.user,
    );
  }
}
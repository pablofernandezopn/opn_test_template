import 'package:json_annotation/json_annotation.dart';

part 'conversation_model.g.dart';

/// Estado de la conversación
enum ConversationStatus {
  active,
  archived,
  deleted,
}

/// Proveedor de IA
enum AiProvider {
  openai,
  deepseek,
  anthropic,
  custom,
}

/// Modelo de conversación que representa una conversación con el asistente de IA
@JsonSerializable()
class Conversation {
  final int id;

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'system_prompt_id')
  final int? systemPromptId;

  final String? title;
  final ConversationStatus status;

  @JsonKey(name: 'ai_provider')
  final AiProvider aiProvider;

  final String model;

  @JsonKey(name: 'total_tokens')
  final int totalTokens;

  @JsonKey(name: 'total_cost')
  final double totalCost;

  @JsonKey(name: 'message_count')
  final int messageCount;

  final Map<String, dynamic> metadata;

  @JsonKey(name: 'last_message_at')
  final DateTime? lastMessageAt;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.userId,
    this.systemPromptId,
    this.title,
    this.status = ConversationStatus.active,
    this.aiProvider = AiProvider.openai,
    this.model = 'gpt-4o-mini',
    this.totalTokens = 0,
    this.totalCost = 0.0,
    this.messageCount = 0,
    this.metadata = const {},
    this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationToJson(this);
}

/// Extension para convertir entre los enums y las strings de la BD
extension ConversationStatusX on ConversationStatus {
  String toDbString() {
    return name;
  }

  static ConversationStatus fromDbString(String value) {
    return ConversationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ConversationStatus.active,
    );
  }
}

extension AiProviderX on AiProvider {
  String toDbString() {
    return name;
  }

  static AiProvider fromDbString(String value) {
    return AiProvider.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AiProvider.openai,
    );
  }
}
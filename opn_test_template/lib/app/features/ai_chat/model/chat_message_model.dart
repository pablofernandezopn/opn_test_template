import 'package:json_annotation/json_annotation.dart';

part 'chat_message_model.g.dart';

/// Enumerado para el tipo de mensaje
enum MessageRole {
  user,
  assistant,
  system,
}

/// Modelo de mensaje de chat
@JsonSerializable()
class ChatMessage {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLoading;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLoading = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}

/// Extension para crear mensajes fácilmente
extension ChatMessageX on ChatMessage {
  /// Crea un mensaje de usuario
  static ChatMessage user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
  }

  /// Crea un mensaje del asistente
  static ChatMessage assistant(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    );
  }

  /// Crea un mensaje de carga
  static ChatMessage loading() {
    return ChatMessage(
      id: 'loading',
      content: '',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }
}
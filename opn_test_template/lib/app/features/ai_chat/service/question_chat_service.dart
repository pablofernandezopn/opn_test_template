import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/question_chat_response_model.dart';

/// Servicio para interactuar con la Edge Function question-chat
class QuestionChatService {
  final SupabaseClient _supabase;
  final String _jwtToken;

  QuestionChatService(this._supabase, this._jwtToken);

  /// Inicializar conversación con una pregunta
  ///
  /// Devuelve el contexto de la pregunta y el ID de la conversación.
  /// Si ya existe una conversación para esta pregunta, la reutiliza.
  Future<QuestionChatResponse> initializeConversation(int questionId) async {
    try {
      final response = await _supabase.functions.invoke(
        'question-chat',
        method: HttpMethod.post,
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: {
          'question_id': questionId,
        },
      );

      if (response.status != 200) {
        throw QuestionChatException(
          'Failed to initialize conversation: ${response.status}',
          statusCode: response.status,
          data: response.data,
        );
      }

      return QuestionChatResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is QuestionChatException) rethrow;
      throw QuestionChatException('Error initializing conversation: $e');
    }
  }

  /// Enviar mensaje en la conversación
  ///
  /// Parámetros:
  /// - [questionId]: ID de la pregunta
  /// - [message]: Mensaje del usuario
  /// - [userAnswer]: Índice de la respuesta elegida (1-4) [opcional]
  /// - [userTestId]: ID del test actual [opcional]
  /// - [includeUserStats]: Si incluir estadísticas del usuario [default: false]
  Future<QuestionChatResponse> sendMessage({
    required int questionId,
    required String message,
    int? userAnswer,
    int? userTestId,
    bool includeUserStats = false,
  }) async {
    try {
      final body = {
        'question_id': questionId,
        'message': message,
        'include_user_stats': includeUserStats,
      };

      if (userAnswer != null) {
        body['user_answer'] = userAnswer;
      }

      if (userTestId != null) {
        body['user_test_id'] = userTestId;
      }

      final response = await _supabase.functions.invoke(
        'question-chat',
        method: HttpMethod.post,
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.status != 200) {
        throw QuestionChatException(
          'Failed to send message: ${response.status}',
          statusCode: response.status,
          data: response.data,
        );
      }

      return QuestionChatResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is QuestionChatException) rethrow;
      throw QuestionChatException('Error sending message: $e');
    }
  }

  /// Obtener conversación existente
  ///
  /// Devuelve null si no existe conversación para esta pregunta.
  Future<ConversationWithMessages?> getConversation(int questionId) async {
    try {
      final response = await _supabase.functions.invoke(
        'question-chat/$questionId',
        method: HttpMethod.get,
        headers: {
          'Authorization': 'Bearer $_jwtToken',
        },
      );

      if (response.status == 404) {
        return null;
      }

      if (response.status != 200) {
        throw QuestionChatException(
          'Failed to get conversation: ${response.status}',
          statusCode: response.status,
          data: response.data,
        );
      }

      return ConversationWithMessages.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is QuestionChatException) rethrow;
      throw QuestionChatException('Error getting conversation: $e');
    }
  }
}

/// Conversación con mensajes (para recuperar historial)
class ConversationWithMessages {
  final ConversationData conversation;
  final List<MessageData> messages;

  ConversationWithMessages({
    required this.conversation,
    required this.messages,
  });

  factory ConversationWithMessages.fromJson(Map<String, dynamic> json) {
    return ConversationWithMessages(
      conversation: ConversationData.fromJson(json['conversation'] as Map<String, dynamic>),
      messages: (json['messages'] as List)
          .map((m) => MessageData.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Datos básicos de conversación
class ConversationData {
  final int id;
  final int userId;
  final String? title;
  final String status;
  final DateTime createdAt;

  ConversationData({
    required this.id,
    required this.userId,
    this.title,
    required this.status,
    required this.createdAt,
  });

  factory ConversationData.fromJson(Map<String, dynamic> json) {
    return ConversationData(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Datos de mensaje
class MessageData {
  final int id;
  final String role;
  final String content;
  final DateTime createdAt;

  MessageData({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      id: json['id'] as int,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Excepción personalizada para errores del servicio de chat
class QuestionChatException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  QuestionChatException(
    this.message, {
    this.statusCode,
    this.data,
  });

  @override
  String toString() {
    final buffer = StringBuffer('QuestionChatException: $message');
    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }
    if (data != null) {
      buffer.write('\nData: $data');
    }
    return buffer.toString();
  }
}
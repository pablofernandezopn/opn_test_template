import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/conversation_model.dart';
import '../model/message_model.dart';
import '../model/question_chat_response_model.dart';
import '../service/question_chat_service.dart';

/// Repository para manejar las operaciones de conversaciones con IA
class ConversationRepository {
  final SupabaseClient _supabase;

  ConversationRepository(this._supabase);

  /// Crea una nueva conversación
  Future<Conversation> createConversation({
    required int userId,
    int? systemPromptId,
    String? title,
    AiProvider aiProvider = AiProvider.openai,
    String model = 'gpt-4o-mini',
    Map<String, dynamic> metadata = const {},
  }) async {
    final now = DateTime.now();
    final data = {
      'user_id': userId,
      'system_prompt_id': systemPromptId,
      'title': title,
      'status': ConversationStatus.active.toDbString(),
      'ai_provider': aiProvider.toDbString(),
      'model': model,
      'total_tokens': 0,
      'total_cost': 0.0,
      'message_count': 0,
      'metadata': metadata,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final response = await _supabase
        .from('conversations')
        .insert(data)
        .select()
        .single();

    return _conversationFromDb(response);
  }

  /// Obtiene una conversación por ID
  Future<Conversation?> getConversation(int conversationId) async {
    try {
      final response = await _supabase
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .single();

      return _conversationFromDb(response);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene todas las conversaciones de un usuario
  Future<List<Conversation>> getUserConversations(
    int userId, {
    ConversationStatus? status,
    int limit = 50,
  }) async {
    var query = _supabase
        .from('conversations')
        .select()
        .eq('user_id', userId)
        .order('last_message_at', ascending: false)
        .limit(limit);



    final response = await query;
    return (response as List)
        .map((json) => _conversationFromDb(json))
        .toList();
  }

  /// Actualiza el título de una conversación
  Future<void> updateConversationTitle(
    int conversationId,
    String title,
  ) async {
    await _supabase
        .from('conversations')
        .update({
          'title': title,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', conversationId);
  }

  /// Actualiza el estado de una conversación
  Future<void> updateConversationStatus(
    int conversationId,
    ConversationStatus status,
  ) async {
    await _supabase
        .from('conversations')
        .update({
          'status': status.toDbString(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', conversationId);
  }

  /// Crea un nuevo mensaje en una conversación
  Future<Message> createMessage({
    required int conversationId,
    required MessageRoleDb role,
    required String content,
    int? tokens,
    double? cost,
    String? model,
    String? finishReason,
    Map<String, dynamic>? functionCall,
    Map<String, dynamic> metadata = const {},
  }) async {
    final now = DateTime.now();
    final data = {
      'conversation_id': conversationId,
      'role': role.toDbString(),
      'content': content,
      'tokens': tokens,
      'cost': cost,
      'model': model,
      'finish_reason': finishReason,
      'function_call': functionCall,
      'metadata': metadata,
      'created_at': now.toIso8601String(),
    };

    final response = await _supabase
        .from('messages')
        .insert(data)
        .select()
        .single();

    return _messageFromDb(response);
  }

  /// Obtiene los mensajes de una conversación
  Future<List<Message>> getConversationMessages(
    int conversationId, {
    int limit = 100,
  }) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .limit(limit);

    return (response as List)
        .map((json) => _messageFromDb(json))
        .toList();
  }

  /// Elimina una conversación (marca como deleted)
  Future<void> deleteConversation(int conversationId) async {
    await updateConversationStatus(conversationId, ConversationStatus.deleted);
  }

  /// Archiva una conversación
  Future<void> archiveConversation(int conversationId) async {
    await updateConversationStatus(conversationId, ConversationStatus.archived);
  }

  // ========================================================================
  // MÉTODOS DE EDGE FUNCTION (question-chat)
  // ========================================================================

  /// Inicializar conversación con la Edge Function question-chat
  ///
  /// Devuelve el contexto de la pregunta y el ID de la conversación.
  /// Si ya existe una conversación para esta pregunta, la reutiliza.
  Future<QuestionChatResponse> initializeConversation(
    int questionId,
    String jwtToken,
  ) async {
    try {
      print('🔵 [ConversationRepository] Inicializando conversación para question_id: $questionId');
      print('🔵 [ConversationRepository] JWT Token presente: ${jwtToken.isNotEmpty}');

      final response = await _supabase.functions.invoke(
        'question-chat',
        method: HttpMethod.post,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: {
          'question_id': questionId,
        },
      );

      print('🔵 [ConversationRepository] Response status: ${response.status}');
      print('🔵 [ConversationRepository] Response data type: ${response.data.runtimeType}');

      if (response.status != 200) {
        print('🔴 [ConversationRepository] Error status ${response.status}: ${response.data}');
        throw QuestionChatException(
          'Failed to initialize conversation: ${response.status}',
          statusCode: response.status,
          data: response.data,
        );
      }

      print('🟢 [ConversationRepository] Conversación inicializada exitosamente');
      return QuestionChatResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e, stackTrace) {
      print('🔴 [ConversationRepository] Error inicializando conversación: $e');
      print('🔴 [ConversationRepository] Stack trace: $stackTrace');
      if (e is QuestionChatException) rethrow;
      throw QuestionChatException('Error initializing conversation: $e');
    }
  }

  /// Enviar mensaje a la Edge Function question-chat
  ///
  /// Parámetros:
  /// - [questionId]: ID de la pregunta
  /// - [message]: Mensaje del usuario
  /// - [jwtToken]: Token JWT para autenticación
  /// - [userAnswer]: Índice de la respuesta elegida (1-4) [opcional]
  /// - [userTestId]: ID del test actual [opcional]
  /// - [includeUserStats]: Si incluir estadísticas del usuario [default: false]
  /// - [forceRag]: Si forzar uso de RAG API [default: false]
  Future<QuestionChatResponse> sendMessageToQuestion({
    required int questionId,
    required String message,
    required String jwtToken,
    int? userAnswer,
    int? userTestId,
    bool includeUserStats = false,
    bool forceRag = false,
  }) async {
    try {
      print('🔵 [ConversationRepository] Enviando mensaje para question_id: $questionId');
      print('🔵 [ConversationRepository] Mensaje: "$message"');
      print('🔵 [ConversationRepository] Modo RAG forzado: $forceRag');

      final body = {
        'question_id': questionId,
        'message': message,
        'include_user_stats': includeUserStats,
        'force_rag': forceRag,
      };

      if (userAnswer != null) {
        body['user_answer'] = userAnswer;
        print('🔵 [ConversationRepository] Con userAnswer: $userAnswer');
      }

      if (userTestId != null) {
        body['user_test_id'] = userTestId;
        print('🔵 [ConversationRepository] Con userTestId: $userTestId');
      }


      final response = await _supabase.functions.invoke(
        'question-chat',
        method: HttpMethod.post,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('🔵 [ConversationRepository] Response status: ${response.status}');

      if (response.status != 200) {
        print('🔴 [ConversationRepository] Error status ${response.status}: ${response.data}');
        throw QuestionChatException(
          'Failed to send message: ${response.status}',
          statusCode: response.status,
          data: response.data,
        );
      }

      print('🟢 [ConversationRepository] Mensaje enviado exitosamente');
      return QuestionChatResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e, stackTrace) {
      print('🔴 [ConversationRepository] Error enviando mensaje: $e');
      print('🔴 [ConversationRepository] Stack trace: $stackTrace');
      if (e is QuestionChatException) rethrow;
      throw QuestionChatException('Error sending message: $e');
    }
  }

  /// Obtener conversación existente de la Edge Function
  ///
  /// Devuelve null si no existe conversación para esta pregunta.
  Future<ConversationWithMessages?> getConversationByQuestion(
    int questionId,
    String jwtToken,
  ) async {
    try {
      print('🔵 [ConversationRepository] Obteniendo conversación para question_id: $questionId');

      final response = await _supabase.functions.invoke(
        'question-chat/$questionId',
        method: HttpMethod.get,
        headers: {
          'Authorization': 'Bearer $jwtToken',
        },
      );

      print('🔵 [ConversationRepository] Response status: ${response.status}');

      if (response.status == 404) {
        print('🟡 [ConversationRepository] No existe conversación previa (404)');
        return null;
      }

      if (response.status != 200) {
        print('🔴 [ConversationRepository] Error status ${response.status}: ${response.data}');
        throw QuestionChatException(
          'Failed to get conversation: ${response.status}',
          statusCode: response.status,
          data: response.data,
        );
      }

      // Verificar si existe conversación en la respuesta
      final data = response.data as Map<String, dynamic>;

      if (data['conversation'] == null) {
        print('🟡 [ConversationRepository] No existe conversación (conversation: null)');
        return null;
      }

      print('🟢 [ConversationRepository] Conversación obtenida exitosamente');
      return ConversationWithMessages.fromJson(data);
    } catch (e, stackTrace) {
      print('🔴 [ConversationRepository] Error obteniendo conversación: $e');
      print('🔴 [ConversationRepository] Stack trace: $stackTrace');
      if (e is QuestionChatException) rethrow;
      throw QuestionChatException('Error getting conversation: $e');
    }
  }

  // ========================================================================
  // MÉTODOS PRIVADOS DE CONVERSIÓN
  // ========================================================================

  /// Convierte un JSON de la BD a un objeto Conversation
  Conversation _conversationFromDb(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      systemPromptId: json['system_prompt_id'] as int?,
      title: json['title'] as String?,
      status: ConversationStatusX.fromDbString(json['status'] as String),
      aiProvider: AiProviderX.fromDbString(json['ai_provider'] as String),
      model: json['model'] as String,
      totalTokens: json['total_tokens'] as int? ?? 0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      messageCount: json['message_count'] as int? ?? 0,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convierte un JSON de la BD a un objeto Message
  Message _messageFromDb(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int,
      role: MessageRoleDbX.fromDbString(json['role'] as String),
      content: json['content'] as String,
      tokens: json['tokens'] as int?,
      cost: (json['cost'] as num?)?.toDouble(),
      model: json['model'] as String?,
      finishReason: json['finish_reason'] as String?,
      functionCall: json['function_call'] as Map<String, dynamic>?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/chat_message_model.dart';
import '../repository/conversation_repository.dart';
import 'ai_chat_state.dart';

/// Cubit para manejar el estado del chat con IA usando la Edge Function
class AiChatCubit extends Cubit<AiChatState> {
  final ConversationRepository _conversationRepository;
  final String _jwtToken;
  final int _questionId;
  final int? _userAnswer;
  final int? _userTestId;

  AiChatCubit({
    required ConversationRepository conversationRepository,
    required String jwtToken,
    required int questionId,
    int? userAnswer,
    int? userTestId,
  })  : _conversationRepository = conversationRepository,
        _jwtToken = jwtToken,
        _questionId = questionId,
        _userAnswer = userAnswer,
        _userTestId = userTestId,
        super(const AiChatState()) {
    // SIEMPRE intentar cargar conversación existente primero
    _loadOrCreateConversation();
  }

  /// Carga conversación existente o crea una nueva
  /// REGLA: Una conversación por pregunta por usuario
  Future<void> _loadOrCreateConversation() async {
    print('🔵 [AiChatCubit] Iniciando carga de conversación para question_id: $_questionId');
    emit(state.copyWith(isLoading: true));

    try {
      // 1. Intentar obtener conversación existente
      print('🔵 [AiChatCubit] Buscando conversación existente...');
      final existingConv = await _conversationRepository.getConversationByQuestion(
        _questionId,
        _jwtToken,
      );

      if (existingConv != null) {
        // ✅ EXISTE: Cargar historial completo
        print('🟢 [AiChatCubit] Conversación existente encontrada, cargando historial...');
        await _loadExistingConversation(existingConv);
      } else {
        // ❌ NO EXISTE: Crear nueva conversación
        print('🟡 [AiChatCubit] No existe conversación, creando nueva...');
        await _initializeNewConversation();
      }
    } catch (e, stackTrace) {
      print('🔴 [AiChatCubit] Error al cargar/crear conversación: $e');
      print('🔴 [AiChatCubit] Stack trace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al cargar la conversación: ${e.toString()}',
      ));
    }
  }

  /// Inicializa una nueva conversación con la Edge Function
  Future<void> _initializeNewConversation() async {
    print('🔵 [AiChatCubit] Inicializando nueva conversación...');
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _conversationRepository.initializeConversation(
        _questionId,
        _jwtToken,
      );

      print('🟢 [AiChatCubit] Nueva conversación creada con ID: ${response.conversationId}');

      // Mensaje de bienvenida
      final welcomeMessage = ChatMessageX.assistant(
        'Hola! He cargado el contexto de esta pregunta. ¿En qué puedo ayudarte?',
      );

      emit(state.copyWith(
        conversationId: response.conversationId,
        questionContext: response.questionContext,
        messages: [welcomeMessage],
        isLoading: false,
        hasError: false,
      ));

      print('🟢 [AiChatCubit] Estado actualizado con mensaje de bienvenida');
    } catch (e, stackTrace) {
      print('🔴 [AiChatCubit] Error inicializando conversación: $e');
      print('🔴 [AiChatCubit] Stack trace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al inicializar la conversación: ${e.toString()}',
      ));
    }
  }

  /// Carga una conversación existente con todo su historial
  Future<void> _loadExistingConversation(dynamic conversationData) async {
    try {
      print('🔵 [AiChatCubit] Cargando conversación existente ID: ${conversationData.conversation.id}');
      print('🔵 [AiChatCubit] Mensajes en historial: ${conversationData.messages.length}');

      // Convertir mensajes de la BD a ChatMessage
      final chatMessages = conversationData.messages.map<ChatMessage>((msg) {
        return ChatMessage(
          id: msg.id.toString(),
          content: msg.content,
          role: msg.role == 'user' ? MessageRole.user : MessageRole.assistant,
          timestamp: msg.createdAt,
        );
      }).toList();

      print('🔵 [AiChatCubit] Mensajes convertidos: ${chatMessages.length}');

      // También obtener el contexto de la pregunta
      final response = await _conversationRepository.initializeConversation(
        _questionId,
        _jwtToken,
      );

      emit(state.copyWith(
        conversationId: conversationData.conversation.id,
        messages: chatMessages,
        questionContext: response.questionContext,
        isLoading: false,
        hasError: false,
      ));

      print('🟢 [AiChatCubit] Conversación existente cargada exitosamente');
    } catch (e, stackTrace) {
      print('🔴 [AiChatCubit] Error cargando historial: $e');
      print('🔴 [AiChatCubit] Stack trace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al cargar el historial: ${e.toString()}',
      ));
    }
  }

  /// Envía un mensaje del usuario
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) {
      print('🟡 [AiChatCubit] Mensaje vacío, ignorando...');
      return;
    }

    print('🔵 [AiChatCubit] Enviando mensaje: "$content"');
    print('🔵 [AiChatCubit] Modo RAG activado: ${state.ragModeEnabled}');

    // Agregar mensaje del usuario inmediatamente
    final userMessage = ChatMessageX.user(content);
    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    ));

    try {
      // Llamar a la Edge Function
      final response = await _conversationRepository.sendMessageToQuestion(
        questionId: _questionId,
        message: content,
        jwtToken: _jwtToken,
        userAnswer: _userAnswer,
        userTestId: _userTestId,
        includeUserStats: true,
        forceRag: state.ragModeEnabled,
      );

      print('🟢 [AiChatCubit] Respuesta recibida de la Edge Function');

      // Crear mensaje del asistente con la respuesta
      final assistantMessage = ChatMessageX.assistant(
        response.response ?? 'Lo siento, no pude generar una respuesta.',
      );

      // Si el modo RAG estaba activado, desactivarlo después de usarlo
      final wasRagEnabled = state.ragModeEnabled;

      emit(state.copyWith(
        messages: [...state.messages, assistantMessage],
        lastCitations: response.citations ?? [],
        performanceContext: response.performanceContext,
        isLoading: false,
        hasError: false,
        ragModeEnabled: false, // Siempre desactivar después de enviar
      ));

      if (wasRagEnabled) {
        print('🟡 [AiChatCubit] Modo RAG desactivado automáticamente después del uso');
      }

      print('🟢 [AiChatCubit] Mensaje agregado al estado');
    } catch (e, stackTrace) {
      print('🔴 [AiChatCubit] Error enviando mensaje: $e');
      print('🔴 [AiChatCubit] Stack trace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al enviar el mensaje: ${e.toString()}',
      ));
    }
  }

  /// Borra la conversación actual y crea una nueva limpia
  Future<void> deleteAndRestart() async {
    if (state.conversationId == null) return;

    emit(state.copyWith(isLoading: true));

    try {
      // Marcar conversación como deleted en la BD
      await _conversationRepository.deleteConversation(state.conversationId!);

      // Reinicializar conversación limpia
      await _initializeNewConversation();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al borrar la conversación: ${e.toString()}',
      ));
    }
  }

  /// Limpia el historial de mensajes (solo en estado, no en BD)
  void clearMessages() {
    emit(state.copyWith(messages: [], lastCitations: []));
  }

  /// Elimina el mensaje de error
  void clearError() {
    emit(state.copyWith(hasError: false, errorMessage: null));
  }

  /// Activa o desactiva el modo RAG
  void toggleRagMode() {
    final newValue = !state.ragModeEnabled;
    print('🔵 [AiChatCubit] Modo RAG ${newValue ? "ACTIVADO" : "DESACTIVADO"}');
    emit(state.copyWith(ragModeEnabled: newValue));
  }

  /// Obtiene el contexto de rendimiento actual
  String? getPerformanceInsight() {
    final perf = state.performanceContext;
    if (perf == null) return null;

    final stats = perf.userStats;
    final questionPerf = perf.questionPerformance;

    final buffer = StringBuffer();
    buffer.writeln('📊 Tu Rendimiento:');
    buffer.writeln(
      '• Precisión general: ${stats.accuracy.toStringAsFixed(0)}% (${stats.rightQuestions}/${stats.totalQuestions} preguntas)',
    );

    if (questionPerf != null) {
      buffer.writeln();
      buffer.writeln('📈 En esta pregunta:');
      buffer.writeln('• Intentos: ${questionPerf.timesAnswered}');
      buffer.writeln('• Aciertos: ${questionPerf.timesCorrect}');
      buffer.writeln('• Fallos: ${questionPerf.timesWrong}');

      if (questionPerf.lastAnswer != null) {
        final lastAnswer = questionPerf.lastAnswer!;
        buffer.writeln(
          '• Último intento: ${lastAnswer.wasCorrect ? "✅ CORRECTO" : "❌ INCORRECTO"}',
        );
      }
    }

    if (perf.currentTest != null) {
      final test = perf.currentTest!;
      buffer.writeln();
      buffer.writeln('📝 Test Actual:');
      buffer.writeln('• Progreso: ${test.answeredQuestions}/${test.totalQuestions}');
      buffer.writeln('• Aciertos: ${test.correctAnswers}');
      buffer.writeln('• Nota: ${test.currentScore.toStringAsFixed(2)}');
    }

    return buffer.toString();
  }
}
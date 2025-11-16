import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/chat_message_model.dart';
import '../model/question_chat_response_model.dart';

part 'ai_chat_state.freezed.dart';

@freezed
class AiChatState with _$AiChatState {
  const factory AiChatState({
    int? conversationId,
    @Default([]) List<ChatMessage> messages,
    @Default([]) List<Citation> lastCitations,
    PerformanceContext? performanceContext,
    QuestionContext? questionContext,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    String? errorMessage,
    @Default(false) bool ragModeEnabled,
  }) = _AiChatState;
}
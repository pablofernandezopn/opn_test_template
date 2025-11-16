// =====================================================
// MODELS: API Request Types
// =====================================================

export interface QuestionChatRequest {
  question_id: number
  message?: string
  user_answer?: number
  user_test_id?: number
  include_user_stats?: boolean
  extra_context?: string  // Solo se usa al inicio de la conversación
  force_rag?: boolean      // Si true, fuerza uso de RAG API independientemente del contenido
}

export interface QuestionChatResponse {
  conversation_id: number
  message_id?: number
  response?: string
  reasoning?: string
  citations?: any[]
  performance_context?: any
  ready?: boolean
  message?: string
  question_context?: any
}

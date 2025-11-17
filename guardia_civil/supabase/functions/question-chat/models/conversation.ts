// =====================================================
// MODELS: Conversation and Messages
// =====================================================

export interface Conversation {
  id: number
  user_id: string
  title?: string
  status: 'active' | 'archived' | 'deleted'
  system_prompt_id?: number
  message_count: number
  last_message_at?: string
  created_at: string
  updated_at: string
  metadata?: Record<string, any>
}

export interface Message {
  id: number
  conversation_id: number
  role: 'system' | 'user' | 'assistant' | 'function'
  content: string
  tokens?: number
  cost?: number
  model?: string
  finish_reason?: string
  metadata?: Record<string, any>
  created_at: string
}

export interface ConversationWithMessages {
  conversation: Conversation
  messages: Message[]
}

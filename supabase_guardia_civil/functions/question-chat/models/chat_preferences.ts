// =====================================================
// MODELS: Chat User Preferences and AI Models
// =====================================================

export type ResponseLength = 'short' | 'normal' | 'long'
export type ConversationTone = 'formal' | 'casual' | 'friendly' | 'professional'

export interface AiModel {
  id: number
  model_key: string
  display_name: string
  description?: string
  provider: string
  speed_rating: number
  thinking_capability: number
  max_tokens: number
  is_active: boolean
}

export interface ChatUserPreferences {
  user_id: number
  model_key: string
  model_display_name: string
  response_length: ResponseLength
  max_tokens: number
  custom_system_prompt: string | null
  tone: ConversationTone
  enable_emojis: boolean
}

// Default preferences when user hasn't configured any
export const DEFAULT_CHAT_PREFERENCES: Partial<ChatUserPreferences> = {
  model_key: 'gpt-5-mini-2025-08-07',
  model_display_name: 'GPT-5 Mini',
  response_length: 'normal',
  max_tokens: 1500,
  custom_system_prompt: null,
  tone: 'friendly',
  enable_emojis: true
}

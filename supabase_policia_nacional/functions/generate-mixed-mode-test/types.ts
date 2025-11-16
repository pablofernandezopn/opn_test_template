// types.ts - Type definitions for generate-mixed-mode-test function

export type TestMode = 'topics' | 'failed' | 'skipped'

export interface TopicWeight {
  id: number
  weight: number
}

export interface GenerateMixedModeTestRequest {
  // Modos de test seleccionados (puede haber múltiples)
  modes: TestMode[]

  // Para modo 'topics'
  topics?: TopicWeight[]

  // ID del usuario para modos 'failed' y 'skipped'
  userId?: string

  // Configuración general
  totalQuestions: number
  academyId?: number
  difficulties?: ('easy' | 'normal' | 'hard')[]

  // Opcional: IDs de topics específicos para filtrar preguntas falladas/en blanco
  // Si no se proporciona, se toman de todos los topics
  topicIds?: number[]
}

export interface Question {
  id: number
  question: string
  tip: string | null
  topic: number
  article: string | null
  question_image_url: string
  retro_image_url: string
  retro_audio_enable: boolean
  retro_audio_text: string
  question_order: number | null
  published: boolean
  shuffled: boolean | null
  num_answered: number
  num_fails: number
  num_empty: number
  difficult_rate: number | null
  created_at: string
  created_by: string | null
  challenge_by_tutor: boolean
  challenge_reason: string | null
  academy_id: number
  order: number | null
}

export interface ModeDistribution {
  [mode: string]: number
}

export interface TopicDistribution {
  [topicId: string]: number
}

export interface GenerateMixedModeTestResponse {
  success: boolean
  questions: Question[]
  modeDistribution: ModeDistribution
  topicDistribution: TopicDistribution
  totalQuestions: number
  requestedQuestions: number
  durationMinutes: number
  message?: string
}

export interface ErrorResponse {
  success: false
  error: string
  details?: string
}
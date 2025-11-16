// types.ts - Type definitions for generate-custom-test function

export interface TopicWeight {
  id: number
  weight: number
}

export interface GenerateTestRequest {
  topics: TopicWeight[]
  totalQuestions: number
  academyId?: number
  difficulties?: ('easy' | 'normal' | 'hard')[]  // Opcional: array de dificultades a incluir
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

export interface TopicDistribution {
  [topicId: string]: number
}

export interface GenerateTestResponse {
  success: boolean
  questions: Question[]
  distribution: TopicDistribution
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

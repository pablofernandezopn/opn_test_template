// =====================================================
// MODELS: Question and Related Types
// =====================================================

export interface QuestionOption {
  id: number
  question_id: number
  answer: string  // Nombre real de la columna
  is_correct: boolean
  option_order: number  // Orden de la opción
}

export interface Topic {
  name: string
  description?: string
}

export interface QuestionData {
  id: number
  question: string  // Nombre real de la columna
  tip?: string      // Explicación/ayuda
  difficult_rate?: number  // Dificultad numérica
  topic: number     // ID del tema (columna directa)
  topic_data?: Topic  // Datos del tema (join)
  question_options: QuestionOption[]
}

export interface QuestionContext {
  question_id: number
  statement: string
  topic: string
  difficulty?: string
  options: Array<{
    index: number
    text: string
    is_correct: boolean
  }>
  correct_answer: {
    index: number
    text?: string
  }
  user_answer?: {
    index: number
    text: string
    is_correct: boolean
  }
  explanation?: string
}

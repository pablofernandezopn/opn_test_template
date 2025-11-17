// types.ts - Type definitions for time-attack-mode function

// ============================================================================
// Session Types
// ============================================================================

export interface TimeAttackSession {
  id: number
  user_id: number
  academy_id: number
  topic_type_id: number | null
  specialty_id: number | null
  time_limit_seconds: number
  time_remaining_seconds: number
  questions_answered: number
  questions_correct: number
  questions_seen: number[]
  current_streak: number
  best_streak: number
  current_level: number
  difficulty_floor: number
  difficulty_ceiling: number
  current_score: number
  final_score: number | null
  is_active: boolean
  started_at: string
  ended_at: string | null
  last_activity_at: string
  created_at: string
  updated_at: string
}

// ============================================================================
// Request Types
// ============================================================================

export interface StartSessionRequest {
  action: 'start_session'
  userId: number
  academyId: number
  timeLimitSeconds: number // 120, 300, 600
  topicTypeId?: number
  specialtyId?: number
}

export interface GetNextQuestionRequest {
  action: 'get_next_question'
  sessionId: number
}

export interface SubmitAnswerRequest {
  action: 'submit_answer'
  sessionId: number
  questionId: number
  selectedOptionId: number | null
  wasCorrect: boolean
  timeTakenSeconds: number
}

// ============================================================================
// Response Types
// ============================================================================

export interface TimeAttackQuestionResponse {
  success: boolean
  question?: any
  options?: any[]
  session?: TimeAttackSession
  timeUp?: boolean
  message?: string
}

export interface SubmitAnswerResponse {
  success: boolean
  session: TimeAttackSession
  time_up: boolean
  final_score?: number
  points_earned?: number // Puntos ganados en esta pregunta
}

export interface ErrorResponse {
  success: false
  error: string
}
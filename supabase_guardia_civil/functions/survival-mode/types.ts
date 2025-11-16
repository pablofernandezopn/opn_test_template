// types.ts - Type definitions for survival-mode function

/**
 * Base response type
 */
export interface BaseResponse {
  success: boolean
}

/**
 * Error response
 */
export interface ErrorResponse extends BaseResponse {
  success: false
  error: string
}

/**
 * Survival session data
 */
export interface SurvivalSession {
  id: number
  user_id: number
  academy_id: number
  topic_type_id: number | null
  specialty_id: number | null
  lives_remaining: number
  current_level: number
  questions_answered: number
  questions_correct: number
  questions_seen: number[]
  difficulty_floor: number
  difficulty_ceiling: number
  started_at: string
  ended_at: string | null
  is_active: boolean
  final_score: number | null
  created_at: string
  updated_at: string
}

/**
 * Question data
 */
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
  order: number
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
}

/**
 * Question option data
 */
export interface QuestionOption {
  id: number
  question_id: number
  answer: string
  is_correct: boolean
  option_order: number
  created_at: string
}

/**
 * Request to start a new survival session
 */
export interface StartSessionRequest {
  action: 'start_session'
  userId: number
  academyId: number
  topicTypeId?: number
  specialtyId?: number
}

/**
 * Request to get the next question
 */
export interface GetNextQuestionRequest {
  action: 'get_next_question'
  sessionId: number
}

/**
 * Request to submit an answer
 */
export interface SubmitAnswerRequest {
  action: 'submit_answer'
  sessionId: number
  questionId: number
  selectedOptionId: number | null
  wasCorrect: boolean
  timeTakenSeconds?: number
}

/**
 * Response with the next question
 */
export interface SurvivalQuestionResponse extends BaseResponse {
  success: boolean
  question?: Question
  options?: QuestionOption[]
  session: SurvivalSession
  gameOver: boolean
  message?: string
}

/**
 * Response after submitting an answer
 */
export interface SubmitAnswerResponse extends BaseResponse {
  success: boolean
  session: SurvivalSession
  gameOver: boolean
  finalScore?: number
}
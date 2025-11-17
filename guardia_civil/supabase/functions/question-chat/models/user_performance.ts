// =====================================================
// MODELS: User Performance and Stats
// =====================================================

export interface UserStats {
  total_questions: number
  right_questions: number
  wrong_questions: number
  accuracy: number
}

export interface QuestionPerformance {
  times_answered: number
  times_correct: number
  times_wrong: number
  last_answer?: {
    answer_index: number
    was_correct: boolean
    test_id: number
    answered_at: string
  }
  all_attempts: Array<{
    test_id: number
    answer_index: number
    was_correct: boolean
    answered_at: string
    score?: number
  }>
}

export interface CurrentTest {
  test_id: number
  total_questions: number
  answered_questions: number
  correct_answers: number
  wrong_answers: number
  current_score: number
  answered_this_question: boolean
  this_question_correct?: boolean
}

export interface UserPerformanceContext {
  user_stats: UserStats
  question_performance?: QuestionPerformance
  current_test?: CurrentTest
}

export interface UserAnswer {
  id: number
  question_id: number
  answer_index: number
  is_correct: boolean
  answered_at: string
  user_test_id: number
  user_tests?: {
    id: number
    score?: number
    created_at: string
    user_id: string
  }
}

export interface UserTest {
  id: number
  score: number
  user_id: string
  user_test_answers: Array<{
    id: number
    question_id: number
    answer_index: number
    is_correct: boolean
  }>
}

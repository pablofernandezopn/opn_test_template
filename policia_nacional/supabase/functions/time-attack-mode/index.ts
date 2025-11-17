// index.ts - Main entry point for time-attack-mode function
console.log('🚀 Starting time-attack-mode function...')

import { createClient } from 'jsr:@supabase/supabase-js@2'
import type {
  StartSessionRequest,
  GetNextQuestionRequest,
  SubmitAnswerRequest,
  TimeAttackSession,
  TimeAttackQuestionResponse,
  ErrorResponse,
  SubmitAnswerResponse
} from './types.ts'

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Content-Type': 'application/json'
}

// ============================================================================
// Configuración del modo contra reloj
// ============================================================================

const DIFFICULTY_INCREMENT = 0.08 // Incremento de dificultad por nivel (más rápido que supervivencia)
const QUESTIONS_PER_LEVEL = 3 // Preguntas correctas para subir de nivel
const INITIAL_DIFFICULTY_FLOOR = 0.0
const INITIAL_DIFFICULTY_CEILING = 0.3
const MAX_DIFFICULTY = 1.0

// Puntuación
const BASE_POINTS_PER_CORRECT = 100
const STREAK_MULTIPLIER_BONUS = 10 // +10 puntos por cada nivel de racha
const SPEED_BONUS_MAX = 50 // Bonus máximo por velocidad
const SPEED_THRESHOLD_SECONDS = 5 // Tiempo óptimo de respuesta

// ============================================================================
// Funciones auxiliares
// ============================================================================

/**
 * Calcula el rango de dificultad basado en el nivel actual
 */
function calculateDifficultyRange(level: number): { floor: number; ceiling: number } {
  const floor = Math.min(MAX_DIFFICULTY - 0.3, (level - 1) * DIFFICULTY_INCREMENT)
  const ceiling = Math.min(MAX_DIFFICULTY, floor + 0.3)

  return {
    floor: Math.max(0, floor),
    ceiling: Math.max(0.3, ceiling)
  }
}

/**
 * Calcula el nivel basado en el número de preguntas correctas
 */
function calculateLevel(questionsCorrect: number): number {
  return Math.floor(questionsCorrect / QUESTIONS_PER_LEVEL) + 1
}

/**
 * Calcula los puntos ganados por una pregunta
 */
function calculateQuestionScore(
  wasCorrect: boolean,
  currentStreak: number,
  timeTakenSeconds: number
): number {
  if (!wasCorrect) return 0

  // Puntuación base
  let score = BASE_POINTS_PER_CORRECT

  // Bonus por racha
  const streakBonus = currentStreak * STREAK_MULTIPLIER_BONUS
  score += streakBonus

  // Bonus por velocidad (máximo si responde en <= 5 segundos)
  const speedRatio = Math.min(1, SPEED_THRESHOLD_SECONDS / timeTakenSeconds)
  const speedBonus = Math.floor(SPEED_BONUS_MAX * speedRatio)
  score += speedBonus

  return score
}

/**
 * Calcula la puntuación final al terminar la sesión
 */
function calculateFinalScore(
  currentScore: number,
  questionsCorrect: number,
  questionsAnswered: number,
  currentLevel: number
): number {
  // Bonus final por precisión
  const accuracyBonus = questionsAnswered > 0
    ? Math.floor((questionsCorrect / questionsAnswered) * 1000)
    : 0

  // Bonus por nivel alcanzado
  const levelBonus = currentLevel * 50

  return currentScore + accuracyBonus + levelBonus
}

// ============================================================================
// Handlers principales
// ============================================================================

/**
 * Inicia una nueva sesión de contra reloj
 */
async function startSession(
  supabase: any,
  request: StartSessionRequest
): Promise<TimeAttackSession> {
  console.log('⏱️ Starting new time attack session for user:', request.userId)

  // Desactivar sesiones activas anteriores del usuario
  const { error: deactivateError } = await supabase
    .from('time_attack_sessions')
    .update({ is_active: false })
    .eq('user_id', request.userId)
    .eq('is_active', true)

  if (deactivateError) {
    console.error('⚠️ Error deactivating previous sessions:', deactivateError)
  }

  // Crear nueva sesión
  const sessionData = {
    user_id: request.userId,
    academy_id: request.academyId,
    topic_type_id: request.topicTypeId ?? null,
    specialty_id: request.specialtyId ?? null,
    time_limit_seconds: request.timeLimitSeconds,
    time_remaining_seconds: request.timeLimitSeconds,
    questions_answered: 0,
    questions_correct: 0,
    questions_seen: [],
    current_streak: 0,
    best_streak: 0,
    current_level: 1,
    difficulty_floor: INITIAL_DIFFICULTY_FLOOR,
    difficulty_ceiling: INITIAL_DIFFICULTY_CEILING,
    current_score: 0,
    is_active: true
  }

  const { data, error } = await supabase
    .from('time_attack_sessions')
    .insert(sessionData)
    .select()
    .single()

  if (error) {
    console.error('❌ Error creating session:', error)
    throw new Error(`Failed to create time attack session: ${error.message}`)
  }

  console.log('✅ Session created:', data.id)
  return data
}

/**
 * Obtiene la siguiente pregunta para la sesión
 */
async function getNextQuestion(
  supabase: any,
  request: GetNextQuestionRequest
): Promise<TimeAttackQuestionResponse> {
  console.log('🎯 Getting next question for session:', request.sessionId)

  // Obtener la sesión actual
  const { data: session, error: sessionError } = await supabase
    .from('time_attack_sessions')
    .select('*')
    .eq('id', request.sessionId)
    .single()

  if (sessionError || !session) {
    throw new Error('Session not found')
  }

  // Verificar que la sesión está activa
  if (!session.is_active) {
    return {
      success: false,
      timeUp: true,
      session,
      message: 'Time up - session ended'
    }
  }

  // Calcular nuevo nivel si es necesario (basado en preguntas CORRECTAS)
  const newLevel = calculateLevel(session.questions_correct)
  let difficultyFloor = session.difficulty_floor
  let difficultyCeiling = session.difficulty_ceiling

  if (newLevel > session.current_level) {
    const newRange = calculateDifficultyRange(newLevel)
    difficultyFloor = newRange.floor
    difficultyCeiling = newRange.ceiling

    // Actualizar nivel y rango de dificultad
    await supabase
      .from('time_attack_sessions')
      .update({
        current_level: newLevel,
        difficulty_floor: difficultyFloor,
        difficulty_ceiling: difficultyCeiling
      })
      .eq('id', request.sessionId)

    console.log(`📈 Level up! New level: ${newLevel}, Difficulty: ${difficultyFloor}-${difficultyCeiling}`)
  }

  // Obtener pregunta usando la RPC function
  const { data: questions, error: questionsError } = await supabase
    .rpc('get_questions_by_difficulty_range', {
      p_min_difficulty: difficultyFloor,
      p_max_difficulty: difficultyCeiling,
      p_exclude_ids: session.questions_seen || [],
      p_academy_id: session.academy_id,
      p_topic_type_id: session.topic_type_id,
      p_specialty_id: session.specialty_id,
      p_limit: 5
    })

  if (questionsError) {
    console.error('❌ Error fetching questions:', questionsError)
    throw new Error(`Failed to fetch questions: ${questionsError.message}`)
  }

  if (!questions || questions.length === 0) {
    // No hay más preguntas en este rango, intentar con rango más amplio
    console.log('⚠️ No questions found in current difficulty range, expanding...')

    const { data: fallbackQuestions, error: fallbackError } = await supabase
      .rpc('get_questions_by_difficulty_range', {
        p_min_difficulty: 0,
        p_max_difficulty: MAX_DIFFICULTY,
        p_exclude_ids: session.questions_seen || [],
        p_academy_id: session.academy_id,
        p_topic_type_id: session.topic_type_id,
        p_specialty_id: session.specialty_id,
        p_limit: 5
      })

    if (fallbackError || !fallbackQuestions || fallbackQuestions.length === 0) {
      return {
        success: false,
        timeUp: true,
        session,
        message: 'No more questions available'
      }
    }

    questions.push(...fallbackQuestions)
  }

  // Seleccionar una pregunta aleatoria
  const selectedQuestion = questions[0]

  // Obtener las opciones de la pregunta
  const { data: options, error: optionsError } = await supabase
    .from('question_options')
    .select('*')
    .eq('question_id', selectedQuestion.id)
    .order('option_order', { ascending: true })

  if (optionsError || !options || options.length === 0) {
    throw new Error(`Failed to fetch question options: ${optionsError?.message}`)
  }

  console.log(`✅ Question selected: ${selectedQuestion.id}, Difficulty: ${selectedQuestion.difficult_rate}`)

  return {
    success: true,
    question: selectedQuestion,
    options,
    session: {
      ...session,
      current_level: newLevel,
      difficulty_floor: difficultyFloor,
      difficulty_ceiling: difficultyCeiling
    },
    timeUp: false
  }
}

/**
 * Registra una respuesta y actualiza la sesión
 */
async function submitAnswer(
  supabase: any,
  request: SubmitAnswerRequest
): Promise<SubmitAnswerResponse> {
  console.log('📝 Submitting answer for session:', request.sessionId)

  // Obtener la sesión actual
  const { data: session, error: sessionError } = await supabase
    .from('time_attack_sessions')
    .select('*')
    .eq('id', request.sessionId)
    .single()

  if (sessionError || !session) {
    throw new Error('Session not found')
  }

  // Actualizar estadísticas de la sesión
  const newQuestionsAnswered = session.questions_answered + 1
  const newQuestionsCorrect = request.wasCorrect
    ? session.questions_correct + 1
    : session.questions_correct

  // Actualizar racha
  const newCurrentStreak = request.wasCorrect ? session.current_streak + 1 : 0
  const newBestStreak = Math.max(session.best_streak, newCurrentStreak)

  // Calcular puntos ganados en esta pregunta
  const pointsEarned = calculateQuestionScore(
    request.wasCorrect,
    session.current_streak, // Usar la racha ANTES de la respuesta
    request.timeTakenSeconds
  )

  const newCurrentScore = session.current_score + pointsEarned
  const newQuestionsSeen = [...(session.questions_seen || []), request.questionId]

  // Ajustar tiempo según la respuesta: +5s si es correcta, -2s si es incorrecta
  let newTimeRemaining = session.time_remaining_seconds
  if (request.wasCorrect) {
    newTimeRemaining += 5 // Suma 5 segundos por respuesta correcta
    console.log('✅ Correct answer: +5 seconds')
  } else {
    newTimeRemaining -= 2 // Resta 2 segundos por respuesta incorrecta
    console.log('❌ Wrong answer: -2 seconds')
  }

  // Asegurar que el tiempo nunca sea negativo
  newTimeRemaining = Math.max(0, newTimeRemaining)

  // Verificar si el tiempo se agotó
  const isTimeUp = newTimeRemaining <= 0

  const finalScore = isTimeUp
    ? calculateFinalScore(newCurrentScore, newQuestionsCorrect, newQuestionsAnswered, session.current_level)
    : null

  const updateData: any = {
    questions_answered: newQuestionsAnswered,
    questions_correct: newQuestionsCorrect,
    current_streak: newCurrentStreak,
    best_streak: newBestStreak,
    current_score: newCurrentScore,
    questions_seen: newQuestionsSeen,
    time_remaining_seconds: newTimeRemaining,
    last_activity_at: new Date().toISOString()
  }

  if (isTimeUp) {
    updateData.is_active = false
    updateData.ended_at = new Date().toISOString()
    updateData.final_score = finalScore
  }

  // Actualizar la sesión
  const { data: updatedSession, error: updateError } = await supabase
    .from('time_attack_sessions')
    .update(updateData)
    .eq('id', request.sessionId)
    .select()
    .single()

  if (updateError) {
    console.error('❌ Error updating session:', updateError)
    throw new Error(`Failed to update session: ${updateError.message}`)
  }

  console.log(`✅ Answer recorded. Points earned: ${pointsEarned}, Total: ${newCurrentScore}, TimeUp: ${isTimeUp}`)

  return {
    success: true,
    session: updatedSession,
    time_up: isTimeUp,
    final_score: finalScore ?? undefined,
    points_earned: pointsEarned
  }
}

// ============================================================================
// Main handler
// ============================================================================

Deno.serve(async (request: Request) => {
  try {
    console.log(`📨 ${request.method} ${request.url}`)

    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: corsHeaders
      })
    }

    // Only allow POST requests
    if (request.method !== 'POST') {
      const errorResponse: ErrorResponse = {
        success: false,
        error: 'Method not allowed. Use POST.'
      }

      return new Response(JSON.stringify(errorResponse), {
        status: 405,
        headers: corsHeaders
      })
    }

    // Parse request body
    const body = await request.json()
    console.log('📦 Request body:', JSON.stringify(body, null, 2))

    // Create Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Route to appropriate handler based on action
    const action = body.action

    let result: any

    switch (action) {
      case 'start_session':
        result = await startSession(supabaseClient, body)
        break

      case 'get_next_question':
        result = await getNextQuestion(supabaseClient, body)
        break

      case 'submit_answer':
        result = await submitAnswer(supabaseClient, body)
        break

      default:
        throw new Error(`Unknown action: ${action}`)
    }

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: corsHeaders
    })

  } catch (error) {
    console.error('❌ Error:', error)

    const errorResponse: ErrorResponse = {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    }

    return new Response(JSON.stringify(errorResponse), {
      status: 500,
      headers: corsHeaders
    })
  }
})
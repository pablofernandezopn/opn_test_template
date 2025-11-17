// =====================================================
// UTILS: Context Builder for RAG Query
// =====================================================

import type { QuestionData } from '../models/question.ts'
import type { UserPerformanceContext } from '../models/user_performance.ts'
import type { UserProfile } from '../models/user.ts'

/**
 * Reorder options according to shuffled IDs array
 * If shuffled IDs are provided, reorder; otherwise return original order
 */
function reorderOptions(options: any[], shuffledIds?: number[] | null): any[] {
  if (!shuffledIds || shuffledIds.length === 0) {
    // No shuffled order, return sorted by option_order
    return [...options].sort((a, b) => a.option_order - b.option_order)
  }

  // Create a map of id -> option for quick lookup
  const optionMap = new Map(options.map(opt => [opt.id, opt]))

  // Reorder according to shuffled IDs
  const reordered = shuffledIds
    .map(id => optionMap.get(id))
    .filter(opt => opt !== undefined)

  console.log(`🔀 Reordered ${reordered.length} options according to shuffled IDs: [${shuffledIds.join(', ')}]`)

  return reordered
}

/**
 * Build enriched query for RAG API with all available context
 */
export function buildEnrichedQuery(
  message: string,
  questionData: QuestionData,
  userAnswer?: number,
  extraContext?: string,
  performanceContext?: UserPerformanceContext,
  userProfile?: UserProfile | null,
  shuffledOptionIds?: number[] | null
): string {
  let query = `CONTEXTO DE PREGUNTA DE TEST - OPOSICIÓN GUARDIA CIVIL

`

  // User profile section
  if (userProfile) {
    const fullName = `${userProfile.first_name || ''} ${userProfile.last_name || ''}`.trim()
    query += `👤 PERFIL DEL ESTUDIANTE:\n`
    if (fullName) query += `• Nombre: ${fullName}\n`
    if (userProfile.email) query += `• Email: ${userProfile.email}\n`
    if (userProfile.phone) query += `• Teléfono: ${userProfile.phone}\n`
    query += `\n`
  }

  query += `📚 TEMA: ${questionData.topic_data?.name || 'General'}
${questionData.difficult_rate ? `⚡ DIFICULTAD: ${questionData.difficult_rate}/10` : ''}

❓ ENUNCIADO: ${questionData.question}

📝 OPCIONES:
${reorderOptions(questionData.question_options, shuffledOptionIds)
  .map((o, index) => `${String.fromCharCode(65 + index)}. ${o.answer}${o.is_correct ? ' ✅ CORRECTA' : ''}`)
  .join('\n')}
`

  // User's answer in current session
  if (userAnswer !== undefined) {
    const opt = questionData.question_options.find(o => o.option_order === userAnswer)
    if (opt) {
      query += `\n👤 RESPUESTA DEL USUARIO (sesión actual): Opción ${userAnswer} - ${opt.answer}`
      query += `\n${opt.is_correct ? '✅ CORRECTA' : '❌ INCORRECTA'}`
    }
  }

  // Official explanation if exists
  if (questionData.tip) {
    query += `\n\n📖 EXPLICACIÓN OFICIAL: ${questionData.tip}`
  }

  // Performance context
  if (performanceContext) {
    query += buildPerformanceSection(performanceContext)
  }

  // Extra context (solo al inicio de conversación)
  if (extraContext?.trim()) {
    query += `\n\n📌 CONTEXTO ADICIONAL: ${extraContext}`
  }

  // User's question
  query += `\n\n💬 PREGUNTA DEL USUARIO: ${message}`

  return query
}

function buildPerformanceSection(performanceContext: UserPerformanceContext): string {
  let section = `\n\n📊 RENDIMIENTO DEL USUARIO:`
  section += `\n• Precisión general: ${performanceContext.user_stats.accuracy}% (${performanceContext.user_stats.right_questions}/${performanceContext.user_stats.total_questions} preguntas)`

  if (performanceContext.question_performance) {
    const qp = performanceContext.question_performance
    section += `\n\n📈 HISTORIAL EN ESTA PREGUNTA ESPECÍFICA:`
    section += `\n• Intentos totales: ${qp.times_answered}`
    section += `\n• Aciertos: ${qp.times_correct} | Fallos: ${qp.times_wrong}`

    if (qp.last_answer) {
      section += `\n• Último intento: ${qp.last_answer.was_correct ? 'CORRECTA ✅' : 'INCORRECTA ❌'}`
    }

    if (qp.times_wrong > 2) {
      section += `\n⚠️ NOTA: El usuario ha fallado esta pregunta ${qp.times_wrong} veces. Necesita explicación MÁS DETALLADA.`
    }

    // Pattern analysis
    if (qp.all_attempts.length > 1) {
      const wrongAnswers = qp.all_attempts
        .filter(a => !a.was_correct)
        .map(a => a.answer_index)

      if (wrongAnswers.length > 0) {
        const uniqueWrong = [...new Set(wrongAnswers)]
        section += `\n• Opciones incorrectas elegidas anteriormente: ${uniqueWrong.map(i => i + 1).join(', ')}`
      }
    }
  }

  if (performanceContext.current_test) {
    const ct = performanceContext.current_test
    section += `\n\n📝 TEST ACTUAL (ID: ${ct.test_id}):`
    section += `\n• Progreso: ${ct.answered_questions}/${ct.total_questions} preguntas`
    section += `\n• Aciertos: ${ct.correct_answers} | Fallos: ${ct.wrong_answers}`
    section += `\n• Nota actual: ${ct.current_score.toFixed(2)}`

    if (ct.answered_this_question) {
      section += `\n• Esta pregunta en el test: ${ct.this_question_correct ? 'ACERTADA ✅' : 'FALLADA ❌'}`
    }
  }

  return section
}

/**
 * Build basic question context (without performance data)
 */
export function buildBasicQuestionContext(
  questionData: QuestionData,
  userAnswer?: number,
  shuffledOptionIds?: number[] | null
) {
  const orderedOptions = reorderOptions(questionData.question_options, shuffledOptionIds)
  const correctOption = questionData.question_options.find(o => o.is_correct)
  const userOption = userAnswer !== undefined
    ? questionData.question_options.find(o => o.option_order === userAnswer)
    : null

  return {
    question_id: questionData.id,
    statement: questionData.question,
    topic: questionData.topic_data?.name || 'Unknown',
    difficulty: questionData.difficult_rate,
    options: orderedOptions.map((o, index) => ({
      letter: String.fromCharCode(65 + index),  // Always A, B, C, D (fixed labels)
      text: o.answer,
      is_correct: o.is_correct
    })),
    correct_answer: {
      text: correctOption?.answer
    },
    user_answer: userOption ? {
      text: userOption.answer,
      is_correct: userOption.is_correct
    } : null,
    tip: questionData.tip
  }
}

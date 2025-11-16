// =====================================================
// UTILS: Response Generator - Simple Responses
// =====================================================

import type { QuestionData } from '../models/question.ts'

/**
 * Decide if the message needs RAG API (legal database search)
 */
export function needsLegalSearch(message: string, questionData: QuestionData): boolean {
  const lowerMessage = message.toLowerCase().trim()

  // Keywords that indicate need for legal search
  const legalKeywords = [
    'artículo', 'articulo', 'ley', 'normativa', 'código', 'codigo',
    'reglamento', 'decreto', 'orden', 'real decreto', 'boe',
    'jurisprudencia', 'sentencia', 'legislación', 'legislacion',
    'según la ley', 'segun la ley', 'según el código', 'segun el codigo',
    'qué dice la ley', 'que dice la ley', 'fundamento legal', 'base legal',
    'constitución', 'constitucion', 'constitucional', 'estatuto',
    'carta magna', 'texto constitucional'
  ]

  // Check if message contains legal keywords
  const hasLegalKeywords = legalKeywords.some(keyword => lowerMessage.includes(keyword))

  if (hasLegalKeywords) {
    console.log(`🔍 Legal search needed - found legal keywords in: "${message}"`)
    return true
  }

  // Very complex questions might need legal search
  if (message.length > 200) {
    console.log(`🔍 Legal search needed - complex question (${message.length} chars)`)
    return true
  }

  // Check if explicitly asking for deep legal analysis
  const deepAnalysisKeywords = [
    'fundamento', 'base jurídica', 'base juridica', 'marco legal',
    'legislación aplicable', 'legislacion aplicable'
  ]

  const needsDeepAnalysis = deepAnalysisKeywords.some(keyword =>
    lowerMessage.includes(keyword)
  )

  if (needsDeepAnalysis) {
    console.log(`🔍 Legal search needed - deep analysis requested`)
    return true
  }

  console.log(`💬 No legal search needed - can answer with context`)
  return false
}

/**
 * Generate a simple contextual response without calling RAG API
 */
export function generateSimpleResponse(
  message: string,
  questionData: QuestionData,
  userAnswer?: number
): { response: string; reasoning: string } {
  const lowerMessage = message.toLowerCase().trim()

  // Greetings
  if (isGreeting(lowerMessage)) {
    return {
      response: `👋 ¡Hola! Estoy aquí para ayudarte con esta pregunta sobre **${questionData.topic_data?.name || 'oposición'}**.\n\n¿Qué te gustaría saber?`,
      reasoning: 'Saludo contextual con información de la pregunta'
    }
  }

  // Thanks
  if (isThanks(lowerMessage)) {
    return {
      response: `😊 ¡De nada! Si tienes más dudas sobre esta pregunta, no dudes en preguntar.\n\n💪 ¡Sigue así!`,
      reasoning: 'Respuesta de agradecimiento motivadora'
    }
  }

  // General acknowledgment
  if (isAcknowledgment(lowerMessage)) {
    return {
      response: `Perfecto. Si necesitas que te aclare algo más sobre esta pregunta de **${questionData.topic_data?.name || 'oposición'}**, aquí estoy.`,
      reasoning: 'Reconocimiento y disposición para ayudar'
    }
  }

  // Why is option X correct? (using available context)
  if (lowerMessage.includes('por qué') && lowerMessage.includes('correct')) {
    const correctOption = questionData.question_options.find(o => o.is_correct)

    let response = `La opción ${correctOption?.option_order} es la correcta.\n\n`

    if (questionData.tip) {
      response += `📖 **Explicación:**\n${questionData.tip}\n\n`
    }

    response += `💡 **Consejo:** Revisa bien cada opción y compárala con el enunciado para entender por qué las otras no son correctas.`

    return {
      response,
      reasoning: 'Explicación basada en el tip oficial de la pregunta'
    }
  }

  // Help understanding the question
  if (lowerMessage.includes('no entiendo') || lowerMessage.includes('no comprendo')) {
    let response = `Vamos a desglosar la pregunta:\n\n`
    response += `❓ **Enunciado:** ${questionData.question}\n\n`
    response += `**Opciones:**\n`

    questionData.question_options
      .sort((a, b) => a.option_order - b.option_order)
      .forEach(opt => {
        response += `${opt.option_order}. ${opt.answer} ${opt.is_correct ? '✅' : ''}\n`
      })

    if (questionData.tip) {
      response += `\n📖 **Pista:** ${questionData.tip}`
    }

    return {
      response,
      reasoning: 'Desglose de la pregunta para mejor comprensión'
    }
  }

  // User provided answer - give feedback
  if (userAnswer !== undefined) {
    const userOption = questionData.question_options.find(o => o.option_order === userAnswer)
    const correctOption = questionData.question_options.find(o => o.is_correct)

    if (userOption?.is_correct) {
      let response = `🎉 ¡Correcto! La opción ${userAnswer} es la respuesta correcta.\n\n`
      if (questionData.tip) {
        response += `📖 ${questionData.tip}\n\n`
      }
      response += `💪 ¡Sigue así!`

      return {
        response,
        reasoning: 'Confirmación de respuesta correcta con explicación'
      }
    } else {
      let response = `❌ La opción ${userAnswer} no es correcta.\n\n`
      response += `✅ La respuesta correcta es la opción ${correctOption?.option_order}.\n\n`

      if (questionData.tip) {
        response += `📖 **Por qué:**\n${questionData.tip}\n\n`
      }

      response += `💡 **Consejo:** Revisa bien la diferencia entre tu respuesta y la correcta.`

      return {
        response,
        reasoning: 'Corrección con explicación de la respuesta correcta'
      }
    }
  }

  // Default: helpful context about the question
  return {
    response: `Esta pregunta es sobre **${questionData.topic_data?.name || 'oposición'}**${questionData.difficult_rate ? ` (dificultad ${questionData.difficult_rate}/10)` : ''}.\n\n¿Quieres que te explique alguna opción en particular, o necesitas ayuda con el enunciado?`,
    reasoning: 'Respuesta contextual con información de la pregunta'
  }
}

/**
 * Helper: Check if message is a greeting
 */
function isGreeting(message: string): boolean {
  const greetings = ['hola', 'buenas', 'buenos días', 'buenos dias', 'buenas tardes', 'buenas noches', 'hey', 'hi', 'hello']
  return greetings.some(g => message.includes(g))
}

/**
 * Helper: Check if message is thanks
 */
function isThanks(message: string): boolean {
  const thanks = ['gracias', 'thank', 'muchas gracias', 'vale gracias']
  return thanks.some(t => message.includes(t))
}

/**
 * Helper: Check if message is acknowledgment
 */
function isAcknowledgment(message: string): boolean {
  const acks = ['ok', 'vale', 'entendido', 'perfecto', 'genial', 'bien', 'de acuerdo']
  // Must be short and match exactly (to avoid false positives)
  return message.length < 20 && acks.some(a => message === a || message === a + '.')
}

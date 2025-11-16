// =====================================================
// AGENT SERVICE: Intelligent Query Routing
// =====================================================
// Uses OpenAI Agents SDK to intelligently decide if a query
// needs legal database search (RAG API) or can be answered
// contextually using available question data
// =====================================================

import OpenAI from 'npm:openai@^4'
import type { QuestionData } from '../models/question.ts'

// =====================================================
// TYPE DEFINITIONS
// =====================================================

interface RoutingDecision {
  needs_rag: boolean
  reasoning: string
  suggested_response?: string
}

interface QuestionContext {
  question_text: string
  topic: string
  difficulty: number | null
  has_tip: boolean
  options_count: number
  user_provided_answer?: number
}

// =====================================================
// ROUTING AGENT CLASS
// =====================================================

export class RoutingAgent {
  private openai: OpenAI
  private apiKey: string

  constructor(apiKey?: string) {
    this.apiKey = apiKey || Deno.env.get('OPEN_AI_KEY') || ''
    if (!this.apiKey) {
      throw new Error('OpenAI API key not found in environment')
    }

    // Create OpenAI client
    this.openai = new OpenAI({
      apiKey: this.apiKey
    })
  }

  /**
   * Decide if query needs RAG API using intelligent agent
   */
  async shouldUseRAG(
    userMessage: string,
    questionData: QuestionData,
    userAnswer?: number
  ): Promise<RoutingDecision> {
    const questionContext = this.buildQuestionContext(questionData, userAnswer)

    const prompt = `**CONTEXTO DE LA PREGUNTA:**
${JSON.stringify(questionContext, null, 2)}

**MENSAJE DEL ESTUDIANTE:**
"${userMessage}"

Analiza este mensaje y decide si necesita búsqueda en base de datos legal (RAG API) o puede responderse con el contexto disponible.`

    try {
      // Use OpenAI chat completion with JSON mode
      const completion = await this.openai.chat.completions.create({
        model: 'gpt-5-nano-2025-08-07',
        messages: [
          {
            role: 'system',
            content: `Eres un agente especialista en enrutamiento de consultas educativas.

Tu tarea es analizar mensajes de estudiantes y determinar si necesitan búsqueda en base de datos legal (RAG API) o pueden responderse con el contexto de la pregunta.

**CRITERIOS PARA NECESITAR RAG (needs_rag: true):**
1. Pregunta explícita sobre leyes, artículos, códigos, normativas
2. Solicita fundamento legal o base jurídica
3. Pregunta "qué dice la ley sobre..."
4. Menciona documentos legales específicos (BOE, Real Decreto, Constitución, etc.)
5. Pregunta compleja que requiere conocimiento legal especializado
6. Consulta sobre procedimientos legales específicos

**CRITERIOS PARA RESPUESTA CONTEXTUAL (needs_rag: false):**
1. Saludos (hola, buenas, hey)
2. Agradecimientos (gracias, vale)
3. Confirmaciones simples (ok, entendido, perfecto)
4. Preguntas sobre la estructura de la pregunta ("no entiendo la pregunta")
5. Preguntas sobre por qué una opción es correcta/incorrecta
6. Solicitud de explicación de las opciones disponibles
7. Consultas generales sobre el tema sin solicitud de fuentes legales

Responde SIEMPRE en formato JSON válido con esta estructura exacta:
{
  "needs_rag": boolean,
  "reasoning": "explicación breve de tu decisión",
  "suggested_response": "si needs_rag=false, proporciona una respuesta corta y útil"
}`
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        max_completion_tokens: 500,
        response_format: { type: 'json_object' }
      })

      const outputText = completion.choices[0]?.message?.content || '{}'

      // Parse the JSON response
      let decision: RoutingDecision
      try {
        decision = JSON.parse(outputText)
      } catch (parseError) {
        console.error('❌ Could not parse agent response as JSON:', parseError)
        console.error('Response was:', outputText)
        return this.fallbackDecision(userMessage, questionData)
      }

      console.log(`🤖 Agent decision: ${decision.needs_rag ? 'RAG API' : 'Contextual'}`)
      console.log(`💭 Agent reasoning: ${decision.reasoning}`)

      return decision

    } catch (error) {
      console.error('❌ Error calling routing agent:', error)
      // Fallback to keyword-based logic
      return this.fallbackDecision(userMessage, questionData)
    }
  }

  /**
   * Build question context for the agent
   */
  private buildQuestionContext(questionData: QuestionData, userAnswer?: number): QuestionContext {
    return {
      question_text: questionData.question,
      topic: questionData.topic_data?.name || 'General',
      difficulty: questionData.difficult_rate,
      has_tip: !!questionData.tip,
      options_count: questionData.question_options.length,
      user_provided_answer: userAnswer
    }
  }

  /**
   * Fallback to simple keyword-based decision if OpenAI fails
   */
  private fallbackDecision(message: string, questionData: QuestionData): RoutingDecision {
    console.log('⚠️ Using fallback keyword-based routing')

    const lowerMessage = message.toLowerCase().trim()

    const legalKeywords = [
      'artículo', 'articulo', 'ley', 'normativa', 'código', 'codigo',
      'reglamento', 'decreto', 'orden', 'real decreto', 'boe',
      'jurisprudencia', 'sentencia', 'legislación', 'legislacion',
      'según la ley', 'segun la ley', 'según el código', 'segun el codigo',
      'qué dice la ley', 'que dice la ley', 'fundamento legal', 'base legal',
      'constitución', 'constitucion', 'constitucional', 'estatuto',
      'carta magna', 'texto constitucional'
    ]

    const hasLegalKeywords = legalKeywords.some(keyword => lowerMessage.includes(keyword))

    if (hasLegalKeywords || message.length > 200) {
      return {
        needs_rag: true,
        reasoning: 'Detected legal keywords or complex query (fallback logic)'
      }
    }

    // Simple responses for common patterns
    if (this.isGreeting(lowerMessage)) {
      return {
        needs_rag: false,
        reasoning: 'User greeting detected',
        suggested_response: `👋 ¡Hola! Estoy aquí para ayudarte con esta pregunta sobre **${questionData.topic_data?.name || 'oposición'}**.\n\n¿Qué te gustaría saber?`
      }
    }

    if (this.isThanks(lowerMessage)) {
      return {
        needs_rag: false,
        reasoning: 'User thanks detected',
        suggested_response: `😊 ¡De nada! Si tienes más dudas sobre esta pregunta, no dudes en preguntar.\n\n💪 ¡Sigue así!`
      }
    }

    return {
      needs_rag: false,
      reasoning: 'No legal keywords detected, can answer with context',
      suggested_response: `Esta pregunta es sobre **${questionData.topic_data?.name || 'oposición'}**${questionData.difficult_rate ? ` (dificultad ${questionData.difficult_rate}/10)` : ''}.\n\n¿Quieres que te explique alguna opción en particular, o necesitas ayuda con el enunciado?`
    }
  }

  private isGreeting(message: string): boolean {
    const greetings = ['hola', 'buenas', 'buenos días', 'buenos dias', 'buenas tardes', 'buenas noches', 'hey', 'hi', 'hello']
    return greetings.some(g => message.includes(g))
  }

  private isThanks(message: string): boolean {
    const thanks = ['gracias', 'thank', 'muchas gracias', 'vale gracias']
    return thanks.some(t => message.includes(t))
  }

  /**
   * Process RAG API response through OpenAI to generate natural conversational answer
   * Instead of showing raw legal texts, this creates a clean response
   */
  async processRAGResponse(
    userQuestion: string,
    ragResponse: string,
    ragCitations: any[] | undefined,
    questionData: QuestionData,
    conversationHistory: Array<{ role: string; content: string }> = [],
    userAnswer?: number,
    performanceContext?: any,
    userPreferences?: any,
    userProfile?: any
  ): Promise<{ response: string; reasoning: string }> {
    console.log(`🔄 Processing RAG response through OpenAI...`)

    // Construir el sistema prompt con el contexto de la pregunta
    let systemContent = ''

    // Add user profile info if available
    if (userProfile) {
      systemContent += `**INFORMACIÓN DEL ESTUDIANTE:**
Nombre: ${userProfile.first_name || ''} ${userProfile.last_name || ''}
Usuario: ${userProfile.username || 'N/A'}

`
    }

    systemContent += `Eres un asistente educativo especializado en oposiciones de la Guardia Civil de España.

**INFORMACIÓN IMPORTANTE SOBRE TI:**
- Si el usuario te pregunta qué modelo eres, responde: "Soy un asistente basado en ${userPreferences?.model_display_name || 'IA avanzada'}, diseñado para ayudarte con las oposiciones de la Guardia Civil."
- NO te identifiques como GPT-4 ni ningún otro modelo que no sea el indicado arriba
- NO menciones tu modelo si el usuario no pregunta

**TU TAREA:**
Un estudiante ha hecho una pregunta sobre temas legales relacionados con esta pregunta de test. Has recibido información legal relevante de una base de datos jurídica. Tu trabajo es:

1. Responder la pregunta del estudiante de forma CLARA, CONCISA y CONVERSACIONAL
2. Usar la información legal proporcionada como base, pero NO copiar los textos legales literalmente
3. Citar las fuentes cuando sea relevante (ej: "Según el artículo X...")
4. Mantener un tono educativo y útil
5. NO mostrar textos legales completos ni fragmentos largos

**CONTEXTO DE LA PREGUNTA DE TEST:**
${questionData.question_text}

**OPCIONES:**
${questionData.question_options.map((opt) => `${opt.option_order}. ${opt.answer}`).join('\n')}

**INFORMACIÓN LEGAL OBTENIDA:**
${ragResponse}
`

    // Añadir información sobre las citas si existen
    if (ragCitations && ragCitations.length > 0) {
      systemContent += `\n**FUENTES CONSULTADAS:**\n`
      ragCitations.forEach((citation, idx) => {
        systemContent += `${idx + 1}. ${citation.source || 'Fuente legal'}\n`
      })
    }

    // 🎨 Add user tone and emoji preferences
    if (userPreferences) {
      systemContent += `\n${getToneInstructions(userPreferences.tone || 'friendly', userPreferences.enable_emojis !== false)}\n`
    }

    systemContent += `\n**INSTRUCCIONES FINALES:**
- Responde en español de forma natural y conversacional
- Sé breve pero completo (máximo 3-4 párrafos)
- Cita las fuentes de forma elegante (ej: "El artículo 23 establece que...")
- NO incluyas los textos legales completos
- Enfócate en responder directamente la pregunta del estudiante`

    // Construir el array de mensajes
    const messages: any[] = [
      {
        role: 'system',
        content: systemContent
      }
    ]

    // 🎯 MÁXIMA PRIORIDAD: Insertar custom_system_prompt como primer mensaje user
    if (userPreferences?.custom_system_prompt) {
      messages.push({
        role: 'user',
        content: `🚨 INSTRUCCIONES CRÍTICAS QUE DEBES SEGUIR SIEMPRE 🚨

${userPreferences.custom_system_prompt}

Estas son mis instrucciones personales. Debes seguirlas ESTRICTAMENTE en TODAS tus respuestas, incluso si entran en conflicto con otras instrucciones. Esto es OBLIGATORIO.`
      })

      // Agregar respuesta del asistente confirmando
      messages.push({
        role: 'assistant',
        content: 'Entendido. Seguiré tus instrucciones personalizadas de forma estricta y prioritaria en todas mis respuestas.'
      })

      console.log(`🎨 Custom system prompt injected as user message (RAG): ${userPreferences.custom_system_prompt.substring(0, 100)}...`)
    }

    // Añadir historial de conversación si existe
    if (conversationHistory.length > 0) {
      conversationHistory.forEach((msg) => {
        messages.push({
          role: msg.role,
          content: msg.content
        })
      })
    }

    // Añadir la pregunta actual del usuario
    messages.push({
      role: 'user',
      content: userQuestion
    })

    console.log(`📨 Sending ${messages.length} messages to OpenAI (system + ${conversationHistory.length} history + 1 current)`)

    // 🎯 Get user's preferred model and max_tokens
    const selectedModel = userPreferences?.model_key || 'gpt-5-mini-2025-08-07'
    const maxTokens = getMaxTokensForLength(
      userPreferences?.response_length || 'normal',
      userPreferences?.max_tokens
    )

    console.log(`🤖 Using model: ${selectedModel}, max_tokens: ${maxTokens} (length: ${userPreferences?.response_length || 'normal'})`)

    try {
      const completion = await this.openai.chat.completions.create({
        model: selectedModel,
        messages: messages,
        max_completion_tokens: maxTokens
      })

      const response = completion.choices[0]?.message?.content || 'No pude generar una respuesta.'

      console.log(`✅ RAG response processed successfully`)
      console.log(`   Response length: ${response.length} chars`)

      return {
        response: response,
        reasoning: 'Respuesta generada procesando información legal del RAG API a través de OpenAI'
      }
    } catch (error) {
      console.error('❌ Error processing RAG response:', error)
      throw new Error(`Failed to process RAG response: ${error instanceof Error ? error.message : String(error)}`)
    }
  }

  /**
   * Generate direct OpenAI completion response without RAG
   */
  async generateDirectResponse(
    userMessage: string,
    questionData: QuestionData,
    userAnswer?: number,
    performanceContext?: any,
    conversationHistory?: Array<{ role: string; content: string }>,
    userPreferences?: any,
    userProfile?: any
  ): Promise<{ response: string; reasoning: string }> {
    // Build system message with question context
    let systemContent = ''

    // Add user profile info if available
    if (userProfile) {
      systemContent += `**INFORMACIÓN DEL ESTUDIANTE:**
Nombre: ${userProfile.first_name || ''} ${userProfile.last_name || ''}
Usuario: ${userProfile.username || 'N/A'}

`
    }

    systemContent += `Eres un asistente educativo especializado en ayudar a estudiantes de oposiciones de la Guardia Civil.

**INFORMACIÓN IMPORTANTE SOBRE TI:**
- Si el usuario te pregunta qué modelo eres, responde: "Soy un asistente basado en ${userPreferences?.model_display_name || 'IA avanzada'}, diseñado para ayudarte con las oposiciones de la Guardia Civil."
- NO te identifiques como GPT-4 ni ningún otro modelo que no sea el indicado arriba
- NO menciones tu modelo si el usuario no pregunta

**CONTEXTO IMPORTANTE:**
Estás ayudando a un estudiante con una pregunta de examen tipo test (opción múltiple).
Esta es una pregunta de examen real con EXACTAMENTE 4 opciones de respuesta numeradas del 1 al 4.
Solo UNA opción es correcta.

**PREGUNTA DE EXAMEN TIPO TEST:**
${questionData.question}

**OPCIONES DE RESPUESTA (1-4):**
${questionData.question_options
  .sort((a, b) => a.option_order - b.option_order)
  .map(opt => `${opt.option_order}. ${opt.answer}${opt.is_correct ? ' ✅ (ESTA ES LA RESPUESTA CORRECTA)' : ''}`)
  .join('\n')}
`

    if (questionData.tip) {
      systemContent += `\n**EXPLICACIÓN OFICIAL:**\n${questionData.tip}\n`
    }

    // Dificultad de la pregunta
    if (questionData.difficult_rate !== null && questionData.difficult_rate !== undefined) {
      const difficulty = questionData.difficult_rate
      let difficultyLabel = ''
      let difficultyEmoji = ''

      if (difficulty >= 0 && difficulty < 20) {
        difficultyLabel = 'FÁCIL'
        difficultyEmoji = '🟢'
      } else if (difficulty >= 20 && difficulty < 50) {
        difficultyLabel = 'NORMAL'
        difficultyEmoji = '🟡'
      } else if (difficulty >= 50 && difficulty < 70) {
        difficultyLabel = 'DIFÍCIL'
        difficultyEmoji = '🟠'
      } else {
        difficultyLabel = 'EXTREMADAMENTE DIFÍCIL'
        difficultyEmoji = '🔴'
      }

      systemContent += `\n**${difficultyEmoji} DIFICULTAD DE ESTA PREGUNTA: ${difficultyLabel} (${difficulty}/100)**\n`
      systemContent += `Esta pregunta tiene una dificultad de ${difficulty} sobre 100, lo que la clasifica como ${difficultyLabel}.\n`
    }

    if (performanceContext?.user_stats) {
      const stats = performanceContext.user_stats
      const failureRate = stats.total_questions > 0
        ? ((stats.wrong_questions / stats.total_questions) * 100).toFixed(1)
        : 0

      systemContent += `\n**📊 RENDIMIENTO GLOBAL DEL ESTUDIANTE EN TODAS LAS PREGUNTAS:**\n`
      systemContent += `El estudiante ha respondido ${stats.total_questions} preguntas en total.\n`
      systemContent += `De esas ${stats.total_questions} preguntas:\n`
      systemContent += `  ✅ ${stats.right_questions} CORRECTAS (${stats.accuracy}%)\n`
      systemContent += `  ❌ ${stats.wrong_questions} INCORRECTAS (${failureRate}%)\n`
      systemContent += `\nTASA DE FALLO GLOBAL DEL ESTUDIANTE: ${failureRate}%\n`
      systemContent += `PRECISIÓN GLOBAL DEL ESTUDIANTE: ${stats.accuracy}%\n`
    }

    // Add question-specific performance history
    if (performanceContext?.question_performance) {
      const qp = performanceContext.question_performance
      const questionSuccessRate = qp.times_answered > 0
        ? ((qp.times_correct / qp.times_answered) * 100).toFixed(1)
        : 0
      const questionFailureRate = qp.times_answered > 0
        ? ((qp.times_wrong / qp.times_answered) * 100).toFixed(1)
        : 0

      systemContent += `\n**📈 HISTORIAL DEL ESTUDIANTE EN ESTA PREGUNTA ESPECÍFICA:**\n`
      systemContent += `El estudiante ha intentado responder ESTA pregunta específica ${qp.times_answered} veces.\n`

      if (qp.times_answered > 0) {
        systemContent += `De esos ${qp.times_answered} intentos:\n`
        systemContent += `  ✅ ${qp.times_correct} veces ACERTÓ (${questionSuccessRate}%)\n`
        systemContent += `  ❌ ${qp.times_wrong} veces FALLÓ (${questionFailureRate}%)\n`
        systemContent += `\nTASA DE ACIERTO EN ESTA PREGUNTA: ${questionSuccessRate}%\n`
        systemContent += `TASA DE FALLO EN ESTA PREGUNTA: ${questionFailureRate}%\n`
      }

      if (qp.last_answer) {
        systemContent += `\nÚLTIMO INTENTO PREVIO EN ESTA PREGUNTA:\n`
        systemContent += `  - Seleccionó la opción ${qp.last_answer.answer_index}\n`
        systemContent += `  - Resultado: ${qp.last_answer.was_correct ? '✅ ACERTÓ' : '❌ FALLÓ'}\n`
      }
    }

    if (userAnswer !== undefined) {
      const userOption = questionData.question_options.find(o => o.option_order === userAnswer)
      const isCorrect = userOption?.is_correct || false
      const correctOption = questionData.question_options.find(o => o.is_correct)

      systemContent += `\n**⚠️⚠️⚠️ INFORMACIÓN CRÍTICA SOBRE LA RESPUESTA DEL ESTUDIANTE ⚠️⚠️⚠️**\n\n`

      if (isCorrect) {
        systemContent += `✅ EL ESTUDIANTE RESPONDIÓ CORRECTAMENTE ESTA PREGUNTA.\n`
        systemContent += `✅ Seleccionó la OPCIÓN ${userAnswer}: "${userOption?.answer}"\n`
        systemContent += `✅ Esta opción ES LA RESPUESTA CORRECTA.\n`
        systemContent += `✅ EL ESTUDIANTE ACERTÓ.\n`
      } else {
        systemContent += `❌ EL ESTUDIANTE RESPONDIÓ INCORRECTAMENTE ESTA PREGUNTA.\n`
        systemContent += `❌ Seleccionó la OPCIÓN ${userAnswer}: "${userOption?.answer}"\n`
        systemContent += `❌ Esta opción es INCORRECTA.\n`
        systemContent += `❌ EL ESTUDIANTE FALLÓ.\n\n`
        systemContent += `La respuesta CORRECTA es la OPCIÓN ${correctOption?.option_order}: "${correctOption?.answer}"\n`
      }
    }

    // 🎨 Add user tone and emoji preferences
    if (userPreferences) {
      systemContent += `\n${getToneInstructions(userPreferences.tone || 'friendly', userPreferences.enable_emojis !== false)}\n`
    }

    systemContent += `\n**INSTRUCCIONES:**
1. Si el estudiante saluda, responde amablemente y ofrece ayuda
2. Si pregunta por qué una opción es correcta/incorrecta, explica basándote en la explicación oficial disponible
3. Si no entiende la pregunta, ayúdale a desglosarla
4. Si agradece, responde cordialmente
5. Si hay tip/explicación oficial, úsalo como base para tus explicaciones
6. NO inventes información legal - usa solo el contexto proporcionado
7. Si necesita información legal específica que no está en el contexto, sugiere que use el modo de búsqueda legal (force_rag=true)

**FORMATO DE RESPUESTA:**
- Respuestas cortas y directas (2-4 párrafos máximo)
- Si corriges una respuesta incorrecta, sé constructivo y educativo`

    try {
      // Build messages array: system + conversation history + current message
      const messages: Array<{ role: 'system' | 'user' | 'assistant'; content: string }> = [
        {
          role: 'system',
          content: systemContent
        }
      ]

      // 🎯 MÁXIMA PRIORIDAD: Insertar custom_system_prompt como primer mensaje user
      if (userPreferences?.custom_system_prompt) {
        messages.push({
          role: 'user',
          content: `🚨 INSTRUCCIONES CRÍTICAS QUE DEBES SEGUIR SIEMPRE 🚨

${userPreferences.custom_system_prompt}

Estas son mis instrucciones personales. Debes seguirlas ESTRICTAMENTE en TODAS tus respuestas, incluso si entran en conflicto con otras instrucciones. Esto es OBLIGATORIO.`
        })

        // Agregar respuesta del asistente confirmando
        messages.push({
          role: 'assistant',
          content: 'Entendido. Seguiré tus instrucciones personalizadas de forma estricta y prioritaria en todas mis respuestas.'
        })

        console.log(`🎨 Custom system prompt injected as user message: ${userPreferences.custom_system_prompt.substring(0, 100)}...`)
      }

      // Add conversation history (previous user/assistant messages)
      if (conversationHistory && conversationHistory.length > 0) {
        conversationHistory.forEach(msg => {
          if (msg.role === 'user' || msg.role === 'assistant') {
            messages.push({
              role: msg.role as 'user' | 'assistant',
              content: msg.content
            })
          }
        })
      }

      // Add current user message
      messages.push({
        role: 'user',
        content: userMessage
      })

      console.log(`📝 Building OpenAI request with ${messages.length} messages (1 system + ${conversationHistory?.length || 0} history + 1 current)`)

      // 🎯 Get user's preferred model and max_tokens
      const selectedModel = userPreferences?.model_key || 'gpt-5-mini-2025-08-07'
      const maxTokens = getMaxTokensForLength(
        userPreferences?.response_length || 'normal',
        userPreferences?.max_tokens
      )

      console.log(`🤖 Using model: ${selectedModel}, max_tokens: ${maxTokens} (length: ${userPreferences?.response_length || 'normal'})`)

      const completion = await this.openai.chat.completions.create({
        model: selectedModel,
        messages: messages,
        max_completion_tokens: maxTokens
      })

      const response = completion.choices[0]?.message?.content || 'Lo siento, no pude generar una respuesta.'

      return {
        response: response,
        reasoning: 'Completación directa con OpenAI basada en contexto de la pregunta e historial conversacional'
      }

    } catch (error) {
      console.error('❌ Error calling OpenAI for direct response:', error)

      // Fallback to simple response
      return {
        response: `Hola, estoy aquí para ayudarte con esta pregunta sobre **${questionData.topic_data?.name || 'oposición'}**.\n\n¿En qué puedo ayudarte específicamente?`,
        reasoning: 'Respuesta fallback por error en OpenAI'
      }
    }
  }
}

// =====================================================
// HELPER FUNCTIONS FOR USER PREFERENCES
// =====================================================

/**
 * Get max_tokens based on user's response_length preference
 */
function getMaxTokensForLength(responseLength: string, userMaxTokens?: number): number {
  // If user has custom max_tokens configured, use it
  if (userMaxTokens && userMaxTokens > 0) {
    return userMaxTokens
  }

  // Otherwise, map response_length to appropriate token count
  switch (responseLength) {
    case 'short':
      return 500
    case 'normal':
      return 1000
    case 'long':
      return 2000
    default:
      return 1000
  }
}

/**
 * Get tone instructions based on user's tone preference
 */
function getToneInstructions(tone: string, enableEmojis: boolean): string {
  let instructions = ''

  switch (tone) {
    case 'formal':
      instructions = `**TONO DE COMUNICACIÓN: FORMAL**
- Usa un lenguaje formal y académico
- Evita contracciones y expresiones coloquiales
- Mantén un tono respetuoso y profesional en todo momento
- Dirígete al estudiante de usted`
      break

    case 'casual':
      instructions = `**TONO DE COMUNICACIÓN: CASUAL**
- Usa un lenguaje relajado y cercano
- Puedes usar expresiones coloquiales cuando sea apropiado
- Mantén un tono amigable pero educativo
- Dirígete al estudiante de tú`
      break

    case 'friendly':
      instructions = `**TONO DE COMUNICACIÓN: AMIGABLE**
- Usa un lenguaje cálido y acogedor
- Sé motivador y positivo en tus respuestas
- Celebra los aciertos y anima en los errores
- Dirígete al estudiante de tú de forma cercana`
      break

    case 'professional':
      instructions = `**TONO DE COMUNICACIÓN: PROFESIONAL**
- Mantén un equilibrio entre formalidad y cercanía
- Usa un lenguaje claro y preciso
- Enfócate en la eficacia educativa
- Dirígete al estudiante de manera respetuosa pero accesible`
      break

    default:
      instructions = `**TONO DE COMUNICACIÓN: AMIGABLE**
- Usa un lenguaje cercano y motivador
- Dirígete al estudiante de tú`
  }

  // Add emoji instructions
  if (enableEmojis) {
    instructions += '\n- Usa emojis de forma moderada para hacer más amena la conversación (2-4 emojis por respuesta)'
  } else {
    instructions += '\n- NO uses emojis en tus respuestas'
  }

  return instructions
}

/**
 * Generate contextual response when RAG is not needed
 */
export function generateContextualResponse(
  decision: RoutingDecision,
  message: string,
  questionData: QuestionData,
  userAnswer?: number
): { response: string; reasoning: string } {
  // If agent provided a suggested response, use it
  if (decision.suggested_response) {
    return {
      response: decision.suggested_response,
      reasoning: decision.reasoning
    }
  }

  // Otherwise, build response from context
  const lowerMessage = message.toLowerCase().trim()

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

  // Why is option X correct?
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

  // Default contextual response
  return {
    response: `Esta pregunta es sobre **${questionData.topic_data?.name || 'oposición'}**${questionData.difficult_rate ? ` (dificultad ${questionData.difficult_rate}/10)` : ''}.\n\n¿Quieres que te explique alguna opción en particular, o necesitas ayuda con el enunciado?`,
    reasoning: 'Respuesta contextual con información de la pregunta'
  }
}

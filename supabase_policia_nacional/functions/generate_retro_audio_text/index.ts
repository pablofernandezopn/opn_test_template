// index.ts - Edge function to generate retro audio text using AI
console.log('=� Starting generate_retro_audio_text function...')

import { createClient } from 'jsr:@supabase/supabase-js@2'

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Content-Type": "application/json"
}

// =====================================================
// TYPES & INTERFACES
// =====================================================

interface GenerateRetroAudioTextRequest {
  question_ids: number[]           // Lista de IDs de preguntas a procesar
  batch_size?: number              // Tama�o del batch (default: 10)
  prompt_slug?: string             // Slug del prompt a usar (default: 'generate_feedback_guardia_civil')
  save_to_database?: boolean       // Si guardar en BD (default: true)
}

interface QuestionData {
  id: number
  question: string
  tip?: string
  article?: string
  topic: number
  options: QuestionOption[]
}

interface QuestionOption {
  id: number
  answer: string
  is_correct: boolean
  option_order: number
}

interface GeneratedRetroAudioText {
  question_id: number
  retro_audio_text: string
  saved: boolean
  error?: string
}

interface GenerateRetroAudioTextResponse {
  success: boolean
  message: string
  total_requested: number
  total_processed: number
  total_saved: number
  total_errors: number
  results: GeneratedRetroAudioText[]
  errors?: Array<{ question_id: number; error: string }>
}

interface PromptConfig {
  prompt_text: string
  model: string
  temperature?: number
  provider?: string
}

// =====================================================
// MAIN HANDLER
// =====================================================

Deno.serve(async (request: Request) => {
  try {
    console.log(`=� ${request.method} ${request.url}`)

    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: corsHeaders
      })
    }

    // Only allow POST requests
    if (request.method !== 'POST') {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Method not allowed. Use POST.'
        }),
        {
          status: 405,
          headers: corsHeaders
        }
      )
    }

    // Create Supabase client with user JWT
    const authHeader = request.headers.get('Authorization')
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: authHeader ? { Authorization: authHeader } : {}
        }
      }
    )

    // Verify authentication
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()

    if (authError || !user) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Unauthorized',
          message: 'Valid authentication required'
        }),
        {
          status: 401,
          headers: corsHeaders
        }
      )
    }

    // Parse and validate request body
    const body: GenerateRetroAudioTextRequest = await request.json()
    console.log('=� Request body:', JSON.stringify(body, null, 2))

    // Validate required fields
    if (!body.question_ids || !Array.isArray(body.question_ids) || body.question_ids.length === 0) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'question_ids array is required and must not be empty'
        }),
        {
          status: 400,
          headers: corsHeaders
        }
      )
    }

    const batchSize = body.batch_size || 10
    const promptSlug = body.prompt_slug || 'generate_feedback_guardia_civil'
    const saveToDatabase = body.save_to_database !== false // Default true

    console.log(`<� Processing ${body.question_ids.length} questions in batches of ${batchSize}`)

    // Get prompt configuration
    const promptConfigResult = await getPromptConfig(supabaseClient, promptSlug)
    if (!promptConfigResult.success || !promptConfigResult.config) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Failed to get prompt configuration',
          details: promptConfigResult.error
        }),
        {
          status: 500,
          headers: corsHeaders
        }
      )
    }

    const promptConfig = promptConfigResult.config

    // Process questions in batches
    const results: GeneratedRetroAudioText[] = []
    const errors: Array<{ question_id: number; error: string }> = []

    for (let i = 0; i < body.question_ids.length; i += batchSize) {
      const batchQuestionIds = body.question_ids.slice(i, i + batchSize)
      console.log(`\n=� Processing batch ${Math.floor(i / batchSize) + 1} (${batchQuestionIds.length} questions)`)

      // Fetch questions data for this batch
      const questionsData = await fetchQuestionsData(supabaseClient, batchQuestionIds)

      // Process each question in the batch
      for (const questionData of questionsData) {
        try {
          console.log(`\n= Processing question ${questionData.id}`)

          // Generate retro audio text using AI
          const retroAudioText = await generateRetroAudioText(
            promptConfig,
            questionData
          )

          if (!retroAudioText) {
            throw new Error('Failed to generate retro audio text')
          }

          console.log(` Generated text: ${retroAudioText.substring(0, 100)}...`)

          // Save to database if requested
          let saved = false
          if (saveToDatabase) {
            const saveResult = await saveRetroAudioText(
              supabaseClient,
              questionData.id,
              retroAudioText
            )
            saved = saveResult.success

            if (!saved) {
              console.warn(`� Failed to save question ${questionData.id}: ${saveResult.error}`)
            }
          }

          results.push({
            question_id: questionData.id,
            retro_audio_text: retroAudioText,
            saved: saved
          })

        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : String(error)
          console.error(`L Error processing question ${questionData.id}:`, errorMessage)
          errors.push({
            question_id: questionData.id,
            error: errorMessage
          })
        }
      }

      // Add a small delay between batches to avoid rate limiting
      if (i + batchSize < body.question_ids.length) {
        console.log('� Waiting 1 second before next batch...')
        await new Promise(resolve => setTimeout(resolve, 1000))
      }
    }

    // Build response
    const response: GenerateRetroAudioTextResponse = {
      success: errors.length === 0,
      message: `Processed ${results.length} of ${body.question_ids.length} questions`,
      total_requested: body.question_ids.length,
      total_processed: results.length,
      total_saved: results.filter(r => r.saved).length,
      total_errors: errors.length,
      results: results,
      errors: errors.length > 0 ? errors : undefined
    }

    console.log('\n Processing complete!')
    console.log(`=� Stats: ${response.total_processed} processed, ${response.total_saved} saved, ${response.total_errors} errors`)

    return new Response(JSON.stringify(response), {
      status: errors.length === 0 ? 200 : 207, // 207 Multi-Status if there are errors
      headers: corsHeaders
    })

  } catch (error) {
    console.error('L Error in main handler:', error)
    const errorMessage = error instanceof Error ? error.message : String(error)

    return new Response(
      JSON.stringify({
        success: false,
        error: 'Internal server error',
        details: errorMessage
      }),
      {
        status: 500,
        headers: corsHeaders
      }
    )
  }
})

// =====================================================
// PROMPT CONFIGURATION
// =====================================================

async function getPromptConfig(
  supabaseClient: any,
  slug: string
): Promise<{ success: boolean; config?: PromptConfig; error?: string }> {
  try {
    console.log(`=� Fetching prompt config for slug: ${slug}`)

    const { data, error } = await supabaseClient
      .from('system_prompts')
      .select('prompt_text, model, temperature, ai_provider')
      .eq('slug', slug)
      .eq('is_active', true)
      .single()

    if (error) {
      console.error('L Error fetching prompt config:', error)
      return {
        success: false,
        error: `Failed to fetch prompt config: ${error.message}`
      }
    }

    if (!data) {
      return {
        success: false,
        error: `No active prompt found for slug: ${slug}`
      }
    }

    console.log(` Found prompt config (provider: ${data.provider || 'openai'}, model: ${data.model})`)

    return {
      success: true,
      config: {
        prompt_text: data.prompt_text,
        model: data.model,
        temperature: data.temperature,
        provider: data.provider || 'openai'
      }
    }

  } catch (error) {
    console.error('L Error in getPromptConfig:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : String(error)
    }
  }
}

// =====================================================
// DATABASE OPERATIONS
// =====================================================

async function fetchQuestionsData(
  supabaseClient: any,
  questionIds: number[]
): Promise<QuestionData[]> {
  try {
    console.log(`=
 Fetching data for ${questionIds.length} questions...`)

    // Fetch questions
    const { data: questions, error: questionsError } = await supabaseClient
      .from('questions')
      .select('id, question, tip, article, topic')
      .in('id', questionIds)

    if (questionsError) {
      throw new Error(`Failed to fetch questions: ${questionsError.message}`)
    }

    if (!questions || questions.length === 0) {
      console.warn('� No questions found for the provided IDs')
      return []
    }

    console.log(` Found ${questions.length} questions`)

    // Fetch options for all questions
    const { data: options, error: optionsError } = await supabaseClient
      .from('question_options')
      .select('id, question_id, answer, is_correct, option_order')
      .in('question_id', questionIds)
      .order('option_order', { ascending: true })

    if (optionsError) {
      throw new Error(`Failed to fetch options: ${optionsError.message}`)
    }

    console.log(` Found ${options?.length || 0} options`)

    // Group options by question_id
    const optionsByQuestionId: Record<number, QuestionOption[]> = {}
    if (options) {
      for (const option of options) {
        if (!optionsByQuestionId[option.question_id]) {
          optionsByQuestionId[option.question_id] = []
        }
        optionsByQuestionId[option.question_id].push({
          id: option.id,
          answer: option.answer,
          is_correct: option.is_correct,
          option_order: option.option_order
        })
      }
    }

    // Combine questions with their options
    const questionsData: QuestionData[] = questions.map(q => ({
      id: q.id,
      question: q.question,
      tip: q.tip || undefined,
      article: q.article || undefined,
      topic: q.topic,
      options: optionsByQuestionId[q.id] || []
    }))

    return questionsData

  } catch (error) {
    console.error('L Error fetching questions data:', error)
    throw error
  }
}

async function saveRetroAudioText(
  supabaseClient: any,
  questionId: number,
  retroAudioText: string
): Promise<{ success: boolean; error?: string }> {
  try {
    const { error } = await supabaseClient
      .from('questions')
      .update({
        retro_audio_text: retroAudioText
      })
      .eq('id', questionId)

    if (error) {
      return {
        success: false,
        error: error.message
      }
    }

    console.log(`=� Saved retro audio text for question ${questionId}`)

    return { success: true }

  } catch (error) {
    console.error('L Error saving retro audio text:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : String(error)
    }
  }
}

// =====================================================
// AI TEXT GENERATION
// =====================================================

async function generateRetroAudioText(
  promptConfig: PromptConfig,
  questionData: QuestionData
): Promise<string | null> {
  try {
    // Build the user prompt with question data
    const userPrompt = buildUserPrompt(questionData)

    console.log('> Calling AI API...')

    // Call the appropriate AI provider
    const provider = promptConfig.provider || 'openai'
    const result = await callAIAPI(
      provider,
      promptConfig.model,
      {
        systemPrompt: promptConfig.prompt_text,
        userPrompt: userPrompt,
        temperature: promptConfig.temperature || 0.7,
        max_tokens: 500
      }
    )

    if (!result.success) {
      throw new Error(result.error || 'AI API call failed')
    }

    console.log(` AI response received (${result.tokens} tokens, cost: $${result.cost.toFixed(4)})`)

    return result.content

  } catch (error) {
    console.error('L Error generating retro audio text:', error)
    return null
  }
}

function buildUserPrompt(questionData: QuestionData): string {
  const correctOption = questionData.options.find(o => o.is_correct)

  let prompt = `Pregunta: ${questionData.question}\n\n`

  prompt += `Opciones:\n`
  for (const option of questionData.options) {
    const marker = option.is_correct ? '' : ''
    prompt += `${marker} ${option.answer}\n`
  }

  prompt += `\nRespuesta correcta: ${correctOption?.answer || 'N/A'}\n`

  if (questionData.tip) {
    prompt += `\nPista: ${questionData.tip}\n`
  }

  if (questionData.article) {
    prompt += `\nArt�culo de referencia: ${questionData.article}\n`
  }

  return prompt
}

// =====================================================
// AI API INTEGRATION
// =====================================================

async function callAIAPI(provider: string, model: string, params: any) {
  try {
    if (provider === 'openai') {
      return await callOpenAI(model, params)
    } else if (provider === 'deepseek') {
      return await callDeepSeek(model, params)
    } else {
      return {
        success: false,
        error: `Provider ${provider} not supported`
      }
    }
  } catch (error) {
    console.error('L AI API Error:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : String(error)
    }
  }
}

async function callOpenAI(model: string, params: any) {
  const apiKey = Deno.env.get('OPEN_AI_KEY') || Deno.env.get('OPENAI_API_KEY')
  const apiUrl = Deno.env.get('OPENAI_API_URL') || 'https://api.openai.com/v1/chat/completions'

  if (!apiKey) {
    throw new Error('OPEN_AI_KEY not configured in environment variables')
  }

  const messages = [
    { role: 'system', content: params.systemPrompt },
    { role: 'user', content: params.userPrompt }
  ]

  const response = await fetch(apiUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`
    },
    body: JSON.stringify({
      model: model,
      messages: messages,
      temperature: params.temperature || 0.7,
      max_tokens: params.max_tokens || 500
    })
  })

  if (!response.ok) {
    const error = await response.text()
    throw new Error(`OpenAI API error: ${error}`)
  }

  const data = await response.json()
  const choice = data.choices[0]

  return {
    success: true,
    content: choice.message.content,
    tokens: data.usage?.total_tokens || 0,
    cost: calculateOpenAICost(model, data.usage),
    finish_reason: choice.finish_reason,
    metadata: { usage: data.usage }
  }
}

async function callDeepSeek(model: string, params: any) {
  const apiKey = Deno.env.get('DEEPSEEK_API_KEY')
  const apiUrl = Deno.env.get('DEEPSEEK_API_URL') || 'https://api.deepseek.com/v1/chat/completions'

  if (!apiKey) {
    throw new Error('DEEPSEEK_API_KEY not configured in environment variables')
  }

  const messages = [
    { role: 'system', content: params.systemPrompt },
    { role: 'user', content: params.userPrompt }
  ]

  const response = await fetch(apiUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`
    },
    body: JSON.stringify({
      model: model || 'deepseek-chat',
      messages: messages,
      temperature: params.temperature || 0.7,
      max_tokens: params.max_tokens || 500
    })
  })

  if (!response.ok) {
    const error = await response.text()
    throw new Error(`DeepSeek API error: ${error}`)
  }

  const data = await response.json()
  const choice = data.choices[0]

  return {
    success: true,
    content: choice.message.content,
    tokens: data.usage?.total_tokens || 0,
    cost: calculateDeepSeekCost(data.usage),
    finish_reason: choice.finish_reason,
    metadata: { usage: data.usage }
  }
}

// =====================================================
// COST CALCULATION
// =====================================================

function calculateOpenAICost(model: string, usage: any): number {
  if (!usage) return 0

  // Precios aproximados (verificar precios actuales en OpenAI)
  const prices: Record<string, { input: number, output: number }> = {
    'gpt-4o-mini': { input: 0.00015, output: 0.0006 }, // per 1K tokens
    'gpt-4o': { input: 0.005, output: 0.015 },
    'gpt-4-turbo': { input: 0.01, output: 0.03 },
    'gpt-3.5-turbo': { input: 0.0005, output: 0.0015 }
  }

  const modelPrice = prices[model] || prices['gpt-4o-mini']
  const inputCost = (usage.prompt_tokens / 1000) * modelPrice.input
  const outputCost = (usage.completion_tokens / 1000) * modelPrice.output

  return inputCost + outputCost
}

function calculateDeepSeekCost(usage: any): number {
  if (!usage) return 0

  // DeepSeek es muy econ�mico: ~$0.0001 per 1K tokens
  const pricePerToken = 0.0001 / 1000
  return usage.total_tokens * pricePerToken
}

console.log(' generate_retro_audio_text function loaded successfully!')

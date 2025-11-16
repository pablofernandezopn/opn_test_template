// index.ts - Main entry point for generate-retro-text function
console.log('🚀 Starting generate-retro-text function...')

import { createClient } from 'jsr:@supabase/supabase-js@2'

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Content-Type": "application/json"
}

// Main handler
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
      return new Response(
        JSON.stringify({ error: 'Method not allowed. Use POST.' }),
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

    // Verificar autenticación
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized', message: 'Valid authentication required' }),
        {
          status: 401,
          headers: corsHeaders
        }
      )
    }

    // Parse request body
    const body = await request.json()

    // Detectar si es formato individual o múltiple
    const isMultiple = Array.isArray(body.questions)

    // Validar formato
    if (isMultiple) {
      if (!body.questions || body.questions.length === 0) {
        return new Response(
          JSON.stringify({
            error: 'Bad Request',
            message: 'questions array is empty'
          }),
          {
            status: 400,
            headers: corsHeaders
          }
        )
      }

      // Validar cada pregunta
      for (const question of body.questions) {
        if (!question.text || !question.questionId || !question.topicId) {
          return new Response(
            JSON.stringify({
              error: 'Bad Request',
              message: 'Each question must have text, questionId, and topicId'
            }),
            {
              status: 400,
              headers: corsHeaders
            }
          )
        }
      }
    } else {
      // Formato individual (retrocompatibilidad)
      const { text, questionId, topicId } = body
      if (!text || !questionId || !topicId) {
        return new Response(
          JSON.stringify({
            error: 'Bad Request',
            message: 'Missing required parameters: text, questionId, topicId'
          }),
          {
            status: 400,
            headers: corsHeaders
          }
        )
      }
    }

    // Procesar preguntas
    const questionsToProcess = isMultiple
      ? body.questions
      : [{ text: body.text, questionId: body.questionId, topicId: body.topicId }]

    console.log(`🎙️ Generating retro audio for ${questionsToProcess.length} question(s)`)

    const results = []
    const errors = []

    for (const question of questionsToProcess) {
      try {
        const result = await processQuestion(supabaseClient, question.text, question.questionId, question.topicId)
        results.push(result)
      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error)
        console.error(`❌ Error processing question ${question.questionId}:`, errorMessage)
        errors.push({
          questionId: question.questionId,
          error: errorMessage
        })
      }
    }

    // Retornar respuesta según el formato
    if (isMultiple) {
      return new Response(
        JSON.stringify({
          success: errors.length === 0,
          message: `Processed ${results.length} of ${questionsToProcess.length} questions`,
          results: results,
          errors: errors.length > 0 ? errors : undefined,
          totalProcessed: results.length,
          totalErrors: errors.length
        }),
        { status: errors.length === 0 ? 200 : 207, headers: corsHeaders }
      )
    } else {
      // Formato individual
      if (results.length > 0) {
        return new Response(
          JSON.stringify({
            success: true,
            message: 'Retro audio generated successfully',
            audioPath: results[0].audioPath
          }),
          { status: 200, headers: corsHeaders }
        )
      } else {
        return new Response(
          JSON.stringify({
            success: false,
            error: errors[0].error
          }),
          { status: 500, headers: corsHeaders }
        )
      }
    }

  } catch (error) {
    console.error('❌ Error in main handler:', error)
    const errorMessage = error instanceof Error ? error.message : String(error)

    return new Response(
      JSON.stringify({
        error: 'Internal Server Error',
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
// PROCESS SINGLE QUESTION
// =====================================================

async function processQuestion(
  supabaseClient: any,
  text: string,
  questionId: string,
  topicId: string
): Promise<{ questionId: string; audioPath: string; audioSize: number }> {
  console.log(`📝 Processing question ${questionId} in topic ${topicId}`)

  // 1. Generate audio with ElevenLabs
  const audioBuffer = await generateAudioWithElevenLabs(text)

  if (!audioBuffer) {
    throw new Error('Failed to generate audio')
  }

  console.log(`✅ Audio generated successfully (${audioBuffer.byteLength} bytes)`)

  // 2. Upload audio to Supabase storage
  const audioPath = `topic_${topicId}/question_${questionId}/retro_audio.mp3`

  const { error: uploadError } = await supabaseClient.storage
    .from('topics')
    .upload(audioPath, audioBuffer, {
      contentType: 'audio/mpeg',
      upsert: true
    })

  if (uploadError) {
    console.error('❌ Error uploading audio:', uploadError)
    throw new Error(`Failed to upload audio: ${uploadError.message}`)
  }

  console.log(`✅ Audio uploaded to: ${audioPath}`)

  // 3. Get public URL for the audio file
  const { data: { publicUrl } } = supabaseClient.storage
    .from('topics')
    .getPublicUrl(audioPath)

  console.log(`📎 Public URL: ${publicUrl}`)

  // 4. Update question in database with audio URL
  const { error: updateError } = await supabaseClient
    .from('questions')
    .update({
      retro_audio_text: text,
      retro_audio_enable: true,
      retro_audio_url: audioPath
    })
    .eq('id', questionId)

  if (updateError) {
    console.error('❌ Error updating question:', updateError)
    throw new Error(`Failed to update question: ${updateError.message}`)
  }

  console.log(`✅ Question ${questionId} updated successfully`)

  return {
    questionId,
    audioPath,
    audioSize: audioBuffer.byteLength
  }
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
    console.error('AI API Error:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : String(error)
    }
  }
}

async function callOpenAI(model: string, params: any) {
  const apiKey = Deno.env.get('OPENAI_API_KEY')
  const apiUrl = Deno.env.get('OPENAI_API_URL') || 'https://api.openai.com/v1/chat/completions'

  if (!apiKey) {
    throw new Error('OPENAI_API_KEY not configured')
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
      model,
      messages,
      temperature: params.temperature || 0.7,
      max_tokens: params.max_tokens || 2000
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
    throw new Error('DEEPSEEK_API_KEY not configured')
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
      messages,
      temperature: params.temperature || 0.7,
      max_tokens: params.max_tokens || 2000
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

  // DeepSeek es muy económico: ~$0.0001 per 1K tokens
  const pricePerToken = 0.0001 / 1000
  return usage.total_tokens * pricePerToken
}

// =====================================================
// ELEVENLABS TTS INTEGRATION
// =====================================================

async function generateAudioWithElevenLabs(text: string): Promise<ArrayBuffer | null> {
  try {
    const apiKey = Deno.env.get('ELEVENLABS_API_KEY') || 'sk_eed6626d7f09c795f881c83909f7bcdf056fbd605213f162'
    const voiceId = Deno.env.get('ELEVENLABS_VOICE_ID') || '43h7ymOnaaYdWr3dRbsS'
    const elevenLabsUrl = `https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`

    console.log(`🎤 Calling ElevenLabs API with voice ${voiceId}...`)

    const response = await fetch(elevenLabsUrl, {
      method: 'POST',
      headers: {
        'Accept': 'audio/mp3',
        'Content-Type': 'application/json',
        'xi-api-key': apiKey
      },
      body: JSON.stringify({
        text: text,
        model_id: 'eleven_turbo_v2_5',
        voice_settings: {
          stability: 0.4,
          similarity_boost: 1
        }
      })
    })

    if (!response.ok) {
      const errorText = await response.text()
      console.error(`❌ ElevenLabs API error (${response.status}):`, errorText)
      throw new Error(`ElevenLabs API error: ${errorText}`)
    }

    const audioBuffer = await response.arrayBuffer()
    console.log(`✅ ElevenLabs returned ${audioBuffer.byteLength} bytes`)

    return audioBuffer
  } catch (error) {
    console.error('❌ Error generating audio with ElevenLabs:', error)
    return null
  }
}

console.log('✅ generate-retro-text function loaded successfully!')

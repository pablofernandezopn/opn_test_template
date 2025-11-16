// index.ts - Edge function to generate questions using OpenAI
console.log('=� Starting generate_ai_questions function...')

import { createClient } from 'jsr:@supabase/supabase-js@2'

// CORS headers
const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",

    "Content-Type": "application/json"
}

// Types
interface GenerateQuestionsRequest {
    topic_id: number
    topic_name: string
    context?: string
    num_questions: number
    difficulty?: number
    num_options?: number
    language?: string
    academy_id?: number
    save_to_database?: boolean
    prompt_slug?: string
}

interface QuestionOption {
    answer: string
    is_correct: boolean
    option_order: number
}

interface GeneratedQuestion {
    question: string
    tip?: string
    article?: string
    options: QuestionOption[]
    difficulty: number
}

interface GenerateQuestionsResponse {
    success: boolean
    questions: GeneratedQuestion[]
    saved_ids?: number[]
    message?: string
    error?: string
    details?: string
}

// Main handler
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
        const body: GenerateQuestionsRequest = await request.json()
        console.log('=� Request body:', JSON.stringify(body, null, 2))

        if (!body.topic_id || !body.topic_name) {
            return new Response(
                JSON.stringify({
                    success: false,
                    error: 'topic_id and topic_name are required'
                }),
                {
                    status: 400,
                    headers: corsHeaders
                }
            )
        }

        const numQuestions = body.num_questions || 5
        const numOptions = body.num_options || 4
        const difficulty = body.difficulty ?? 0
        const language = body.language || 'español'
        const context = body.context || null
        const saveToDatabase = body.save_to_database !== false // Default true
        const promptSlug = body.prompt_slug || 'generate_questions_guardia_civil' // Default prompt slug

        // Generate questions using OpenAI
        const generatedQuestions = await generateQuestionsWithOpenAI(
            supabaseClient,
            body.topic_name,
            numQuestions,
            numOptions,
            difficulty,
            language,
            context,
            promptSlug
        )

        if (!generatedQuestions.success) {
            return new Response(
                JSON.stringify({
                    success: false,
                    error: 'Failed to generate questions',
                    details: generatedQuestions.error
                }),
                {
                    status: 500,
                    headers: corsHeaders
                }
            )
        }

        // Save to database if requested
        let savedIds: number[] = []

        console.log(`=� Generated ${generatedQuestions.questions} questions`)
        if (saveToDatabase) {
            const saveResult = await saveQuestionsToDatabase(
                supabaseClient,
                generatedQuestions.questions,
                body.topic_id,
                body.academy_id || 1,
                user.id
            )

            if (saveResult.success) {
                savedIds = saveResult.questionIds
            } else {
                console.warn('� Failed to save some questions:', saveResult.error)
            }
        }

        // Build response
        const response: GenerateQuestionsResponse = {
            success: true,
            questions: generatedQuestions.questions,
            message: `Generated ${generatedQuestions.questions.length} questions successfully`
        }

        if (saveToDatabase) {
            response.saved_ids = savedIds
            response.message += `. Saved ${savedIds.length} to database.`
        }

        console.log(' Questions generated successfully')
        return new Response(JSON.stringify(response), {
            status: 200,
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
// Prompt Configuration
// =====================================================

interface PromptConfig {
    prompt_text: string
    model: string
    temperature?: number
}

async function getPromptConfig(
    supabaseClient: any,
    slug: string
): Promise<{ success: boolean; config?: PromptConfig; error?: string }> {
    try {
        console.log(`=📋 Fetching system prompt config for slug: ${slug}`)

        // Get the prompt configuration from system_prompts table
        const { data, error } = await supabaseClient
            .from('system_prompts')
            .select('prompt_text, model, temperature')
            .eq('slug', slug)
            .eq('is_active', true)
            .single()

        if (error) {
            console.error('❌ Error fetching system prompt config:', error)
            return {
                success: false,
                error: `Failed to fetch system prompt config: ${error.message}`
            }
        }

        if (!data) {
            return {
                success: false,
                error: `No active system prompt found for slug: ${slug}`
            }
        }

        console.log(`✅ Found system prompt config (model: ${data.model})`)

        return {
            success: true,
            config: {
                prompt_text: data.prompt_text,
                model: data.model,
                temperature: data.temperature
            }
        }

    } catch (error) {
        console.error('❌ Error in getPromptConfig:', error)
        return {
            success: false,
            error: error instanceof Error ? error.message : String(error)
        }
    }
}

// =====================================================
// OpenAI Integration
// =====================================================

async function generateQuestionsWithOpenAI(
    supabaseClient: any,
    topicName: string,
    numQuestions: number,
    numOptions: number,
    difficulty: number,
    language: string,
    context: string | null,
    promptSlug: string
): Promise<{ success: boolean; questions: GeneratedQuestion[]; error?: string }> {
    try {
        const apiKey = Deno.env.get('OPEN_AI_KEY')
        const apiUrl = Deno.env.get('OPENAI_API_URL') || 'https://api.openai.com/v1/chat/completions'

        if (!apiKey) {
            throw new Error('OPEN_AI_KEY not configured in environment variables')
        }

        // Get prompt configuration from system_prompts table
        const promptConfigResult = await getPromptConfig(supabaseClient, promptSlug)

        if (!promptConfigResult.success || !promptConfigResult.config) {
            throw new Error(promptConfigResult.error || 'Failed to get prompt configuration')
        }

        const { prompt_text, model, temperature } = promptConfigResult.config

        // Build the user prompt for OpenAI
        const userPrompt = buildUserPrompt(topicName, numQuestions, difficulty, context)

        console.log('> Calling OpenAI API...')

        const response = await fetch(apiUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`
            },
            body: JSON.stringify({
                model: model,
                messages: [
                    { role: 'system', content: prompt_text },
                    { role: 'user', content: userPrompt }
                ],
                temperature: temperature || 0.7,
                response_format: { type: "json_object" }
            })
        })

        if (!response.ok) {
            const error = await response.text()
            throw new Error(`OpenAI API error: ${error}`)
        }

        const data = await response.json()
        const content = data.choices[0].message.content

        console.log(' OpenAI response received')

        // Parse the JSON response
        const parsedResponse = JSON.parse(content)
        const questions: GeneratedQuestion[] = parsedResponse.questions || []

        // Ensure all questions have the difficulty field
        questions.forEach(q => {
            q.difficulty = difficulty
        })

        return {
            success: true,
            questions: questions
        }

    } catch (error) {
        console.error('L Error calling OpenAI:', error)
        return {
            success: false,
            questions: [],
            error: error instanceof Error ? error.message : String(error)
        }
    }
}

function buildUserPrompt(topicName: string, numQuestions: number, difficulty: number, context: string | null): string {
    const difficultyText = difficulty === 0 ? 'básica' : difficulty === 1 ? 'media' : 'avanzada'

    let prompt = `Genera ${numQuestions} preguntas de opción múltiple sobre el tema: "${topicName}"

Dificultad: ${difficultyText} (nivel ${difficulty})
`

    if (context) {
        prompt += `
CONTEXTO/MATERIAL BASE:
${context}

IMPORTANTE: Las preguntas deben estar basadas específicamente en el contexto proporcionado arriba. Extrae información directamente del texto y formula preguntas que evalúen la comprensión de este material específico.
`
    }

    prompt += `
Las preguntas deben:
1. Cubrir diferentes aspectos del tema${context ? ' basándose en el contexto proporcionado' : ''}
2. Ser precisas y bien redactadas
3. Tener opciones de respuesta equilibradas
4. Incluir tips educativos
5. Si aplica, referenciar la normativa legal correspondiente`

    return prompt
}

// =====================================================
// Database Operations
// =====================================================

async function saveQuestionsToDatabase(
    supabaseClient: any,
    questions: GeneratedQuestion[],
    topicId: number,
    academyId: number,
    userId: string
): Promise<{ success: boolean; questionIds: number[]; error?: string }> {
    const questionIds: number[] = []
    const errors: string[] = []

    try {
        for (const q of questions) {
            try {
                // Insert question
                const { data: questionData, error: questionError } = await supabaseClient
                    .from('questions')
                    .insert({
                        question: q.question,
                        tip: q.tip || null,
                        article: q.article || null,
                        topic: topicId,
                        academy_id: academyId,
                        created_by: userId,
                        published: false, // Keep as draft until reviewed
                        order: 0,
                        question_image_url: '',
                        retro_image_url: '',
                        retro_audio_enable: false,
                        retro_audio_text: '',
                        retro_audio_url: ''
                    })
                    .select('id')
                    .single()

                if (questionError) {
                    throw new Error(`Question insert error: ${questionError.message}`)
                }

                const questionId = questionData.id
                questionIds.push(questionId)

                // Wait a bit for the trigger to create blank options
                await new Promise(resolve => setTimeout(resolve, 100))

                // Fetch the blank options created by the trigger
                const { data: blankOptions, error: fetchError } = await supabaseClient
                    .from('question_options')
                    .select('id, option_order')
                    .eq('question_id', questionId)
                    .order('option_order', { ascending: true })

                if (fetchError) {
                    throw new Error(`Failed to fetch blank options: ${fetchError.message}`)
                }

                if (!blankOptions || blankOptions.length === 0) {
                    throw new Error(`No blank options found for question ${questionId}`)
                }

                // Update each option with the correct data
                for (let i = 0; i < q.options.length && i < blankOptions.length; i++) {
                    const generatedOption = q.options[i]
                    const blankOption = blankOptions[i]

                    const { error: updateError } = await supabaseClient
                        .from('question_options')
                        .update({
                            answer: generatedOption.answer,
                            is_correct: generatedOption.is_correct
                        })
                        .eq('id', blankOption.id)

                    if (updateError) {
                        throw new Error(`Failed to update option ${blankOption.id}: ${updateError.message}`)
                    }
                }

                console.log(` Saved question ${questionId} and updated ${q.options.length} options`)

            } catch (error) {
                const errorMsg = error instanceof Error ? error.message : String(error)
                console.error(`L Error saving question:`, errorMsg)
                errors.push(errorMsg)
            }
        }

        return {
            success: true,
            questionIds: questionIds,
            error: errors.length > 0 ? errors.join('; ') : undefined
        }

    } catch (error) {
        console.error('L Error in saveQuestionsToDatabase:', error)
        return {
            success: false,
            questionIds: questionIds,
            error: error instanceof Error ? error.message : String(error)
        }
    }
}

console.log(' generate_ai_questions function loaded successfully!')

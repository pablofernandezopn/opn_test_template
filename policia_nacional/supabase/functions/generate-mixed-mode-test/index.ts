// index.ts - Main entry point for generate-mixed-mode-test function
console.log('🚀 Starting generate-mixed-mode-test function...')

import { createClient } from 'jsr:@supabase/supabase-js@2'
import { QuestionFetcher } from './question_fetcher.ts'
import type {
  GenerateMixedModeTestRequest,
  GenerateMixedModeTestResponse,
  ErrorResponse,
  Question,
  ModeDistribution,
  TopicDistribution
} from './types.ts'

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Content-Type': 'application/json'
}

/**
 * Validate request body
 */
function validateRequest(body: any): body is GenerateMixedModeTestRequest {
  if (!body) {
    throw new Error('Request body is required')
  }

  if (!Array.isArray(body.modes) || body.modes.length === 0) {
    throw new Error('modes must be a non-empty array')
  }

  // Validate modes
  for (const mode of body.modes) {
    if (!['topics', 'failed', 'skipped'].includes(mode)) {
      throw new Error(`Invalid mode: ${mode}`)
    }
  }

  // If topics mode is selected, topics array must be provided (can be empty)
  if (body.modes.includes('topics')) {
    if (!Array.isArray(body.topics)) {
      throw new Error('topics must be an array when topics mode is selected')
    }

    // If topics is empty, topicTypeId is required to fetch all topics
    if (body.topics.length === 0) {
      if (typeof body.topicTypeId !== 'number') {
        throw new Error('topicTypeId is required when topics array is empty (to fetch all topics)')
      }
    }

    for (const topic of body.topics) {
      if (typeof topic.id !== 'number') {
        throw new Error(`Invalid topic id: ${topic.id}`)
      }
      if (typeof topic.weight !== 'number' || topic.weight < 0) {
        throw new Error(`Invalid weight for topic ${topic.id}: ${topic.weight}`)
      }
    }
  }

  // If failed or skipped mode is selected, userId must be provided
  if (body.modes.includes('failed') || body.modes.includes('skipped')) {
    if (typeof body.userId !== 'string' || body.userId.length === 0) {
      throw new Error('userId is required for failed or skipped modes')
    }
  }

  if (typeof body.totalQuestions !== 'number' || body.totalQuestions <= 0) {
    throw new Error('totalQuestions must be a positive number')
  }

  if (body.academyId !== undefined && typeof body.academyId !== 'number') {
    throw new Error('academyId must be a number')
  }

  return true
}

/**
 * Shuffle array
 */
function shuffleArray<T>(array: T[]): T[] {
  const shuffled = [...array]
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]]
  }
  return shuffled
}

/**
 * Remove duplicate questions by ID
 */
function removeDuplicates(questions: Question[]): Question[] {
  const seen = new Set<number>()
  return questions.filter(q => {
    if (seen.has(q.id)) {
      return false
    }
    seen.add(q.id)
    return true
  })
}

/**
 * Main handler
 */
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

    // Validate request
    validateRequest(body)

    // Create Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Create fetcher
    const fetcher = new QuestionFetcher(supabaseClient)

    // Calculate questions per mode
    const modesCount = body.modes.length
    const questionsPerMode = Math.ceil(body.totalQuestions / modesCount)

    // Fetch questions from each mode
    const allQuestions: Question[] = []
    const modeDistribution: ModeDistribution = {}

    // Fetch from topics
    if (body.modes.includes('topics') && body.topics) {
      const topicsQuestions = await fetcher.fetchFromTopics(
        body.topics,
        questionsPerMode,
        body.academyId,
        body.difficulties,
        body.topicTypeId
      )
      allQuestions.push(...topicsQuestions)
      modeDistribution['topics'] = topicsQuestions.length
    }

    // Fetch failed questions
    if (body.modes.includes('failed') && body.userId) {
      const failedQuestions = await fetcher.fetchFailedQuestions(
        body.userId,
        questionsPerMode,
        body.academyId,
        body.topicIds,
        body.difficulties,
        body.topicTypeId
      )
      allQuestions.push(...failedQuestions)
      modeDistribution['failed'] = failedQuestions.length
    }

    // Fetch skipped questions
    if (body.modes.includes('skipped') && body.userId) {
      const skippedQuestions = await fetcher.fetchSkippedQuestions(
        body.userId,
        questionsPerMode,
        body.academyId,
        body.topicIds,
        body.difficulties,
        body.topicTypeId
      )
      allQuestions.push(...skippedQuestions)
      modeDistribution['skipped'] = skippedQuestions.length
    }

    // Remove duplicates and shuffle
    const uniqueQuestions = removeDuplicates(allQuestions)
    const shuffledQuestions = shuffleArray(uniqueQuestions)

    // Limit to requested number (or all if we have less)
    const finalQuestions = shuffledQuestions.slice(0, body.totalQuestions)

    // Calculate topic distribution
    const topicDistribution: TopicDistribution = {}
    for (const question of finalQuestions) {
      const topicId = String(question.topic)
      topicDistribution[topicId] = (topicDistribution[topicId] || 0) + 1
    }

    // Calculate duration: half the number of questions (rounded up)
    const durationMinutes = Math.ceil(finalQuestions.length / 2)

    // Build response
    const response: GenerateMixedModeTestResponse = {
      success: true,
      questions: finalQuestions,
      modeDistribution,
      topicDistribution,
      totalQuestions: finalQuestions.length,
      requestedQuestions: body.totalQuestions,
      durationMinutes
    }

    // Add warning message if we couldn't get all requested questions
    if (finalQuestions.length < body.totalQuestions) {
      response.message = `Only ${finalQuestions.length} questions available from the selected modes (requested: ${body.totalQuestions})`
    }

    console.log('✅ Mixed-mode test generated successfully')
    console.log(`📊 Mode Distribution: ${JSON.stringify(modeDistribution)}`)
    console.log(`📊 Topic Distribution: ${JSON.stringify(topicDistribution)}`)

    return new Response(JSON.stringify(response), {
      status: 200,
      headers: corsHeaders
    })

  } catch (error) {
    console.error('❌ Error in main handler:', error)
    const errorMessage = error instanceof Error ? error.message : String(error)

    const errorResponse: ErrorResponse = {
      success: false,
      error: 'Failed to generate mixed-mode test',
      details: errorMessage
    }

    return new Response(JSON.stringify(errorResponse), {
      status: 500,
      headers: corsHeaders
    })
  }
})

console.log('✅ generate-mixed-mode-test function loaded successfully!')
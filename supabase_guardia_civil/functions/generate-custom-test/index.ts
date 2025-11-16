// index.ts - Main entry point for generate-custom-test function
console.log('🚀 Starting generate-custom-test function...')

import { createClient } from 'jsr:@supabase/supabase-js@2'
import { QuestionDistributor } from './question_distributor.ts'
import type {
  GenerateTestRequest,
  GenerateTestResponse,
  ErrorResponse
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
function validateRequest(body: any): body is GenerateTestRequest {
  if (!body) {
    throw new Error('Request body is required')
  }

  if (!Array.isArray(body.topics)) {
    throw new Error('topics must be an array')
  }

  // If topics is empty, topicTypeId is required to fetch all topics
  if (body.topics.length === 0) {
    if (typeof body.topicTypeId !== 'number') {
      throw new Error('topicTypeId is required when topics array is empty (to fetch all topics)')
    }
  }

  // Validate each topic
  for (const topic of body.topics) {
    if (typeof topic.id !== 'number') {
      throw new Error(`Invalid topic id: ${topic.id}`)
    }

    if (typeof topic.weight !== 'number' || topic.weight < 0) {
      throw new Error(`Invalid weight for topic ${topic.id}: ${topic.weight}`)
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

    // Create distributor and generate test
    const distributor = new QuestionDistributor(supabaseClient)
    const result = await distributor.generateTest(
      body.topics,
      body.totalQuestions,
      body.academyId,
      body.difficulties,
      body.topicTypeId
    )

    // Calculate duration: half the number of questions (rounded up)
    const durationMinutes = Math.ceil(result.adjustedTotal / 2)

    // Build response
    const response: GenerateTestResponse = {
      success: true,
      questions: result.questions,
      distribution: result.distribution,
      totalQuestions: result.adjustedTotal,
      requestedQuestions: body.totalQuestions,
      durationMinutes: durationMinutes
    }

    // Add warning message if we couldn't get all requested questions
    if (result.adjustedTotal < body.totalQuestions) {
      response.message = `Only ${result.adjustedTotal} questions available from the selected topics (requested: ${body.totalQuestions})`
    }

    console.log('✅ Test generated successfully')
    console.log(`📊 Distribution: ${JSON.stringify(result.distribution)}`)

    return new Response(JSON.stringify(response), {
      status: 200,
      headers: corsHeaders
    })

  } catch (error) {
    console.error('❌ Error in main handler:', error)
    const errorMessage = error instanceof Error ? error.message : String(error)

    const errorResponse: ErrorResponse = {
      success: false,
      error: 'Failed to generate test',
      details: errorMessage
    }

    return new Response(JSON.stringify(errorResponse), {
      status: 500,
      headers: corsHeaders
    })
  }
})

console.log('✅ generate-custom-test function loaded successfully!')

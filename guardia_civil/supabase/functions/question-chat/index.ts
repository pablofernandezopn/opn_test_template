// =====================================================
// EDGE FUNCTION: question-chat (Refactored)
// =====================================================
// Chat contextual para preguntas con integración RAG
// Estructura organizada por responsabilidades
// =====================================================

import { createClient } from 'jsr:@supabase/supabase-js@2'
import { SupabaseRepository } from './repositories/supabase_repository.ts'
import { RAGApiRepository } from './repositories/rag_api_repository.ts'
import { buildEnrichedQuery, buildBasicQuestionContext } from './utils/context_builder.ts'
import type { QuestionChatRequest, QuestionChatResponse } from './models/request.ts'

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json"
}

// =====================================================
// MAIN HANDLER
// =====================================================

Deno.serve(async (request: Request) => {
  console.log(`📨 ${request.method} ${request.url}`)

  if (request.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders })
  }

  try {
    // Initialize Supabase client with service role (WordPress JWT auth)
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Extract WordPress JWT token
    const authHeader = request.headers.get('Authorization')
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized - Missing token' }),
        { status: 401, headers: corsHeaders }
      )
    }

    const token = authHeader.replace('Bearer ', '')

    // Decode JWT to get user ID (WordPress JWT format)
    let userId: string
    try {
      const parts = token.split('.')
      if (parts.length !== 3) {
        throw new Error('Invalid JWT format')
      }

      const payload = JSON.parse(atob(parts[1]))

      // Support both old and new WordPress JWT formats
      const wpUserId = payload.sub || payload.data?.user?.id

      if (!wpUserId) {
        throw new Error('User ID not found in token')
      }

      // Convert WordPress user ID to string for Supabase
      userId = String(wpUserId)
      console.log(`👤 User ID from JWT: ${userId}`)
    } catch (error) {
      console.error('❌ JWT decode error:', error)
      return new Response(
        JSON.stringify({ error: 'Unauthorized - Invalid token' }),
        { status: 401, headers: corsHeaders }
      )
    }

    // Initialize repositories
    const supabaseRepo = new SupabaseRepository(supabaseClient)
    const ragRepo = new RAGApiRepository(undefined, token)  // Pass user's JWT token

    // Route requests
    let url: URL
    try {
      url = new URL(request.url)
    } catch (urlError) {
      console.error('❌ Invalid URL format:', urlError)
      return new Response(
        JSON.stringify({
          error: 'Invalid URL format',
          details: urlError instanceof Error ? urlError.message : String(urlError)
        }),
        { status: 400, headers: corsHeaders }
      )
    }
    const pathParts = url.pathname.split('/').filter(p => p)

    // GET /question-chat/:question_id
    if (request.method === 'GET' && pathParts.length > 1) {
      const questionId = parseInt(pathParts[pathParts.length - 1])
      return await handleGetConversation(supabaseRepo, userId, questionId)
    }

    // POST /question-chat
    if (request.method === 'POST') {
      const body: QuestionChatRequest = await request.json()
      return await handlePostMessage(supabaseRepo, ragRepo, userId, body)
    }

    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: corsHeaders }
    )

  } catch (error) {
    console.error('❌ Error in question-chat:', error)
    return new Response(
      JSON.stringify({
        error: 'Internal Server Error',
        details: error instanceof Error ? error.message : String(error)
      }),
      { status: 500, headers: corsHeaders }
    )
  }
})

// =====================================================
// HANDLER: GET Conversation
// =====================================================

async function handleGetConversation(
  supabaseRepo: SupabaseRepository,
  userId: string,
  questionId: number
) {
  console.log(`🔍 Getting conversation for question ${questionId}, user ${userId}`)

  // First, find conversation by question
  const conversation = await supabaseRepo.getConversationByQuestionId(userId, questionId)

  if (!conversation) {
    return new Response(
      JSON.stringify({
        conversation: null,
        message: 'No conversation found for this question'
      }),
      { status: 200, headers: corsHeaders }
    )
  }

  // Get messages
  const result = await supabaseRepo.getConversationWithMessages(conversation.id, userId)

  if (!result) {
    return new Response(
      JSON.stringify({ error: 'Conversation not found' }),
      { status: 404, headers: corsHeaders }
    )
  }

  return new Response(
    JSON.stringify(result),
    { status: 200, headers: corsHeaders }
  )
}

// =====================================================
// HANDLER: POST Message
// =====================================================

async function handlePostMessage(
  supabaseRepo: SupabaseRepository,
  ragRepo: RAGApiRepository,
  userId: string,
  body: QuestionChatRequest
) {
  const {
    question_id,
    message,
    user_answer,
    user_test_id,
    include_user_stats = true,
    extra_context,
    force_rag = false  // Por defecto NO usa RAG
  } = body

  console.log(`💬 Question chat request:`, {
    question_id,
    has_message: !!message,
    user_test_id,
    include_user_stats
  })

  // Validate request
  if (!question_id) {
    return new Response(
      JSON.stringify({ error: 'question_id is required' }),
      { status: 400, headers: corsHeaders }
    )
  }

  // 1️⃣ Get question data
  const questionData = await supabaseRepo.getQuestionById(question_id)
  if (!questionData) {
    return new Response(
      JSON.stringify({ error: 'Question not found' }),
      { status: 404, headers: corsHeaders }
    )
  }

  // 1.4️⃣ Get shuffled option IDs if available from user's test history
  const shuffledOptionIds = await supabaseRepo.getShuffledOptionIds(userId, question_id)

  // 1.5️⃣ Get user's actual answer from database if user_test_id is provided
  let actualUserAnswer = user_answer  // Start with passed parameter (fallback)

  if (user_test_id) {
    console.log(`🔍 Looking up user answer from database: user_test_id=${user_test_id}, question_id=${question_id}`)
    const dbAnswer = await supabaseRepo.getUserTestAnswer(user_test_id, question_id, questionData)

    if (dbAnswer !== null) {
      actualUserAnswer = dbAnswer
      console.log(`✅ Using answer from database: option ${actualUserAnswer}`)
    } else if (user_answer !== undefined) {
      console.log(`⚠️ No answer found in database, using passed parameter: option ${user_answer}`)
    } else {
      console.log(`⚠️ No answer found in database and no fallback provided`)
    }
  } else if (user_answer !== undefined) {
    console.log(`📝 Using passed user_answer parameter: option ${user_answer}`)
  }

  // 1.6️⃣ Get user chat preferences
  const userPreferences = await supabaseRepo.getUserChatPreferences(userId)
  console.log(`🎨 User preferences loaded: model=${userPreferences.model_key}, response_length=${userPreferences.response_length}`)

  // 1.7️⃣ Get user profile
  const userProfile = await supabaseRepo.getUserProfile(userId)
  if (userProfile) {
    console.log(`👤 User profile loaded: ${userProfile.first_name} ${userProfile.last_name} (${userProfile.email})`)
  }

  // 2️⃣ Get or create conversation
  let conversation = await supabaseRepo.getConversationByQuestionId(userId, question_id)

  if (!conversation) {
    console.log(`✨ Creating new conversation for question ${question_id}`)
    conversation = await supabaseRepo.createConversation(
      userId,
      question_id,
      `${questionData.question.substring(0, 50)}...`,
      {
        question_id: question_id,
        topic_id: questionData.topic,
        topic_name: questionData.topic_data?.name,
        difficulty: questionData.difficult_rate
      }
    )

    if (!conversation) {
      return new Response(
        JSON.stringify({ error: 'Failed to create conversation' }),
        { status: 500, headers: corsHeaders }
      )
    }
  } else {
    console.log(`♻️ Reusing existing conversation: ${conversation.id}`)
  }

  // If no message, just return conversation ready
  if (!message?.trim()) {
    const response: QuestionChatResponse = {
      conversation_id: conversation.id,
      question_context: buildBasicQuestionContext(questionData, actualUserAnswer, shuffledOptionIds),
      ready: true,
      message: 'Conversation ready. Send a message to start chatting.'
    }

    return new Response(
      JSON.stringify(response),
      { status: 200, headers: corsHeaders }
    )
  }

  // 3️⃣ Get user performance context
  let performanceContext = undefined
  if (include_user_stats) {
    performanceContext = await supabaseRepo.getUserPerformanceContext(
      userId,
      question_id,
      user_test_id
    )
  }

  // 4️⃣ Decide if use RAG - by default use direct OpenAI completion, only RAG if forced by user
  let useRAG = force_rag
  let routingReasoning = force_rag
    ? 'Usuario solicitó explícitamente uso de RAG (force_rag=true)'
    : 'Modo por defecto: completación directa con OpenAI (sin RAG)'

  console.log(`🎯 Routing decision: ${useRAG ? 'Use RAG API' : 'Direct OpenAI completion'}`)
  console.log(`💭 Reasoning: ${routingReasoning}`)

  // 5️⃣ Load conversation history (previous messages before current one)
  console.log(`📚 Loading conversation history for conversation ${conversation.id}`)
  const conversationData = await supabaseRepo.getConversationWithMessages(conversation.id, userId)
  const conversationHistory = conversationData?.messages || []
  console.log(`📜 Loaded ${conversationHistory.length} previous messages from history`)

  // 6️⃣ Save user message
  const userMsg = await supabaseRepo.createMessage(
    conversation.id,
    'user',
    message,
    {
      user_answer: actualUserAnswer,  // Use answer from database
      user_test_id: user_test_id,
      performance_context_included: !!performanceContext,
      routing_decision: routingReasoning,
      force_rag: force_rag
    }
  )

  if (!userMsg) {
    return new Response(
      JSON.stringify({ error: 'Failed to save user message' }),
      { status: 500, headers: corsHeaders }
    )
  }

  let responseData: { response: string; reasoning: string; citations?: any[] }
  let source: string

  if (useRAG) {
    // 7️⃣ A - Build enriched query and call RAG API for legal search
    console.log(`🔍 Using RAG API for legal search`)

    const enrichedQuery = buildEnrichedQuery(
      message,
      questionData,
      actualUserAnswer,
      extra_context,
      performanceContext,
      userProfile,
      shuffledOptionIds
    )

    console.log(`📝 Enriched query: ${enrichedQuery.length} chars`)

    try {
      // Step 1: Get RAG API response with legal information
      const ragData = await ragRepo.query(enrichedQuery)
      console.log(`✅ RAG API response received: ${ragData.response.length} chars, ${ragData.citations?.length || 0} citations`)

      // Step 2: Process RAG response through OpenAI for natural conversational answer
      console.log(`🔄 Processing RAG response through OpenAI to generate clean answer...`)

      const { RoutingAgent } = await import('./services/routing_agent.ts')
      const agent = new RoutingAgent()

      // Process the RAG response to generate a natural answer
      const processedResponse = await agent.processRAGResponse(
        message,
        ragData.response,
        ragData.citations,
        questionData,
        conversationHistory,
        actualUserAnswer,
        performanceContext,
        userPreferences,
        userProfile
      )

      console.log(`✅ RAG response processed: ${processedResponse.response.length} chars`)

      responseData = {
        response: processedResponse.response,
        reasoning: processedResponse.reasoning,
        citations: ragData.citations  // Keep citations for reference but won't show full texts
      }
      source = 'rag_api_processed'
    } catch (error) {
      console.error('RAG API error:', error)
      return new Response(
        JSON.stringify({
          error: 'RAG API error',
          details: error instanceof Error ? error.message : String(error)
        }),
        { status: 500, headers: corsHeaders }
      )
    }
  } else {
    // 7️⃣ B - Generate direct OpenAI completion response with conversation history
    console.log(`💬 Generating direct OpenAI completion with conversation history`)

    const { RoutingAgent } = await import('./services/routing_agent.ts')
    const agent = new RoutingAgent()

    // Use OpenAI directly for response generation, passing conversation history
    const aiResponse = await agent.generateDirectResponse(
      message,
      questionData,
      actualUserAnswer,
      performanceContext,
      conversationHistory,  // 👈 Pass conversation history for context
      userPreferences,
      userProfile  // 👈 Pass user profile for personalization
    )

    responseData = {
      response: aiResponse.response,
      reasoning: aiResponse.reasoning,
      citations: []
    }
    source = 'openai_direct'
  }

  // 8️⃣ Save assistant message
  const assistantMsg = await supabaseRepo.createMessage(
    conversation.id,
    'assistant',
    responseData.response,
    {
      reasoning: responseData.reasoning,
      citations: responseData.citations || [],
      question_id: question_id,
      user_test_id: user_test_id,
      performance_aware: !!performanceContext,
      source: source
    }
  )

  if (!assistantMsg) {
    return new Response(
      JSON.stringify({ error: 'Failed to save assistant message' }),
      { status: 500, headers: corsHeaders }
    )
  }

  // 8️⃣ Generate title if first message
  if (conversation.message_count === 0) {
    await supabaseRepo.generateConversationTitle(conversation.id)
  }

  // 9️⃣ Return response
  const response: QuestionChatResponse = {
    conversation_id: conversation.id,
    message_id: assistantMsg.id,
    response: responseData.response,
    reasoning: responseData.reasoning,
    citations: responseData.citations || [],
    performance_context: performanceContext
  }

  return new Response(
    JSON.stringify(response),
    { status: 200, headers: corsHeaders }
  )
}

console.log('✅ question-chat edge function loaded (refactored)')

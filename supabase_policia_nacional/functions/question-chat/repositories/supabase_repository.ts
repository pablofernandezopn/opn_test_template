// =====================================================
// REPOSITORY: Supabase Database Access
// =====================================================

import type { SupabaseClient } from 'jsr:@supabase/supabase-js@2'
import type { QuestionData } from '../models/question.ts'
import type { Conversation, Message } from '../models/conversation.ts'
import type { UserPerformanceContext, UserAnswer, UserTest } from '../models/user_performance.ts'
import type { ChatUserPreferences } from '../models/chat_preferences.ts'
import { DEFAULT_CHAT_PREFERENCES } from '../models/chat_preferences.ts'
import type { UserProfile } from '../models/user.ts'

export class SupabaseRepository {
  constructor(private supabase: SupabaseClient) {}

  // =====================================================
  // QUESTIONS
  // =====================================================

  async getQuestionById(questionId: number): Promise<QuestionData | null> {
    const { data, error } = await this.supabase
      .from('questions')
      .select(`
        *,
        question_options (
          *
        )
      `)
      .eq('id', questionId)
      .order('option_order', { foreignTable: 'question_options', ascending: true })
      .single()

    if (error || !data) {
      console.error('Error fetching question:', error)
      return null
    }

    // Get topic data separately
    let topicData = null
    if (data.topic) {
      const { data: topic } = await this.supabase
        .from('topic')
        .select('name, description')
        .eq('id', data.topic)
        .single()

      topicData = topic
    }

    return {
      ...data,
      topic_data: topicData,
      question_options: data.question_options || []
    }
  }

  // =====================================================
  // USER TEST ANSWERS
  // =====================================================

  /**
   * Get user's answer from user_test_answers table
   * Returns the option_order (1-4) of the selected option
   */
  async getUserTestAnswer(
    userTestId: number,
    questionId: number,
    questionData: QuestionData
  ): Promise<number | null> {
    const { data, error } = await this.supabase
      .from('user_test_answers')
      .select('selected_option_id')
      .eq('user_test_id', userTestId)
      .eq('question_id', questionId)
      .maybeSingle()

    if (error) {
      console.error('Error fetching user test answer:', error)
      return null
    }

    if (!data || !data.selected_option_id) {
      console.log(`⚠️ No answer found for user_test_id=${userTestId}, question_id=${questionId}`)
      return null
    }

    // Find the option_order for the selected_option_id
    const selectedOption = questionData.question_options.find(
      opt => opt.id === data.selected_option_id
    )

    if (!selectedOption) {
      console.error(`❌ Selected option ID ${data.selected_option_id} not found in question options`)
      return null
    }

    console.log(`✅ Found user answer: option ${selectedOption.option_order} (ID: ${data.selected_option_id})`)
    return selectedOption.option_order
  }

  /**
   * Get shuffled option IDs from user_test_answers table
   * Returns the array of option IDs in the order they were presented to the user
   * Queries the most recent finalized test where the user answered this question
   */
  async getShuffledOptionIds(
    userId: string,
    questionId: number
  ): Promise<number[] | null> {
    const { data, error } = await this.supabase
      .from('user_test_answers')
      .select('shuffled_option_ids, user_tests!inner(finalized)')
      .eq('question_id', questionId)
      .eq('user_tests.user_id', userId)
      .eq('user_tests.finalized', true)
      .not('shuffled_option_ids', 'is', null)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle()

    if (error) {
      console.error('Error fetching shuffled option IDs:', error)
      return null
    }

    if (!data || !data.shuffled_option_ids) {
      console.log(`⚠️ No shuffled options found for user ${userId}, question ${questionId}`)
      return null
    }

    console.log(`✅ Found shuffled option IDs for question ${questionId}:`, data.shuffled_option_ids)
    return data.shuffled_option_ids as number[]
  }

  // =====================================================
  // CONVERSATIONS
  // =====================================================

  async getConversationByQuestionId(
    userId: string,
    questionId: number
  ): Promise<Conversation | null> {
    const { data, error } = await this.supabase
      .from('conversation_questions')
      .select('conversation_id, conversations!inner(*)')
      .eq('question_id', questionId)
      .eq('conversations.user_id', userId)
      .eq('conversations.status', 'active')
      .maybeSingle()

    if (error) {
      console.error('Error fetching conversation:', error)
      return null
    }

    return data?.conversations || null
  }

  async createConversation(
    userId: string,
    questionId: number,
    title: string,
    metadata: Record<string, any>
  ): Promise<Conversation | null> {
    // Get system prompt ID
    const { data: systemPrompt } = await this.supabase
      .from('system_prompts')
      .select('id')
      .eq('slug', 'test-reviewer')
      .eq('is_active', true)
      .single()

    // Create conversation
    const { data: conversation, error: convError } = await this.supabase
      .from('conversations')
      .insert({
        user_id: userId,
        title: title,
        system_prompt_id: systemPrompt?.id,
        metadata: metadata
      })
      .select()
      .single()

    if (convError || !conversation) {
      console.error('Error creating conversation:', convError)
      return null
    }

    // Link conversation to question
    const { error: linkError } = await this.supabase
      .from('conversation_questions')
      .insert({
        conversation_id: conversation.id,
        question_id: questionId
      })

    if (linkError) {
      console.error('Error linking conversation to question:', linkError)
      // Conversation is created but not linked - still usable
    }

    return conversation
  }

  async getConversationWithMessages(
    conversationId: number,
    userId: string
  ): Promise<{ conversation: Conversation; messages: Message[] } | null> {
    // Get conversation
    const { data: conversation, error: convError } = await this.supabase
      .from('conversations')
      .select('*')
      .eq('id', conversationId)
      .eq('user_id', userId)
      .single()

    if (convError || !conversation) {
      return null
    }

    // Get messages
    const { data: messages } = await this.supabase
      .from('messages')
      .select('id, role, content, created_at, metadata')
      .eq('conversation_id', conversationId)
      .order('created_at', { ascending: true })

    return {
      conversation,
      messages: messages || []
    }
  }

  // =====================================================
  // MESSAGES
  // =====================================================

  async createMessage(
    conversationId: number,
    role: 'user' | 'assistant',
    content: string,
    metadata?: Record<string, any>
  ): Promise<Message | null> {
    const { data, error } = await this.supabase
      .from('messages')
      .insert({
        conversation_id: conversationId,
        role: role,
        content: content,
        metadata: metadata || {}
      })
      .select()
      .single()

    if (error) {
      console.error('Error creating message:', error)
      return null
    }

    return data
  }

  // =====================================================
  // USER PERFORMANCE
  // =====================================================

  async getUserPerformanceContext(
    userId: string,
    questionId: number,
    userTestId?: number
  ): Promise<UserPerformanceContext> {
    // 1. Get user general stats
    const { data: user } = await this.supabase
      .from('users')
      .select('totalQuestions, rightQuestions, wrongQuestions')
      .eq('id', userId)
      .single()

    const userStats = {
      total_questions: user?.totalQuestions || 0,
      right_questions: user?.rightQuestions || 0,
      wrong_questions: user?.wrongQuestions || 0,
      accuracy: user?.totalQuestions > 0
        ? Math.round((user.rightQuestions / user.totalQuestions) * 100)
        : 0
    }

    // 2. Get historical answers for this question
    const { data: answers } = await this.supabase
      .from('user_test_answers')
      .select(`
        id,
        answer_index,
        is_correct,
        answered_at,
        user_test_id,
        user_tests!inner (
          id,
          score,
          created_at,
          user_id
        )
      `)
      .eq('question_id', questionId)
      .eq('user_tests.user_id', userId)
      .order('answered_at', { ascending: false })

    const questionPerformance = answers && answers.length > 0 ? {
      times_answered: answers.length,
      times_correct: answers.filter(a => a.is_correct).length,
      times_wrong: answers.filter(a => !a.is_correct).length,
      last_answer: {
        answer_index: answers[0].answer_index,
        was_correct: answers[0].is_correct,
        test_id: answers[0].user_test_id,
        answered_at: answers[0].answered_at
      },
      all_attempts: answers.map(a => ({
        test_id: a.user_test_id,
        answer_index: a.answer_index,
        was_correct: a.is_correct,
        answered_at: a.answered_at,
        score: a.user_tests?.score
      }))
    } : undefined

    // 3. Get current test data if provided
    let currentTest = undefined
    if (userTestId) {
      const { data: testData } = await this.supabase
        .from('user_tests')
        .select(`
          id,
          score,
          user_test_answers (
            id,
            question_id,
            answer_index,
            is_correct
          )
        `)
        .eq('id', userTestId)
        .eq('user_id', userId)
        .single()

      if (testData) {
        const testAnswers = testData.user_test_answers || []
        const thisQuestionAnswer = testAnswers.find((a: any) => a.question_id === questionId)

        currentTest = {
          test_id: testData.id,
          total_questions: testAnswers.length,
          answered_questions: testAnswers.length,
          correct_answers: testAnswers.filter((a: any) => a.is_correct).length,
          wrong_answers: testAnswers.filter((a: any) => !a.is_correct).length,
          current_score: testData.score || 0,
          answered_this_question: !!thisQuestionAnswer,
          this_question_correct: thisQuestionAnswer?.is_correct
        }
      }
    }

    return {
      user_stats: userStats,
      question_performance: questionPerformance,
      current_test: currentTest
    }
  }

  // =====================================================
  // CHAT PREFERENCES
  // =====================================================

  async getUserChatPreferences(userId: string): Promise<ChatUserPreferences> {
    try {
      console.log(`🔍 Fetching chat preferences for WordPress user ${userId}`)

      // Get user's internal ID from WordPress user ID
      const { data: profile, error: profileError } = await this.supabase
        .from('profiles')
        .select('id')
        .eq('wordpress_user_id', userId)
        .single()

      if (profileError) {
        console.error(`❌ Error fetching profile for WordPress user ${userId}:`, profileError)
      }

      if (!profile) {
        console.log(`⚠️ Profile not found for WordPress user ${userId}, using defaults`)
        return {
          user_id: 0,
          ...DEFAULT_CHAT_PREFERENCES
        } as ChatUserPreferences
      }

      console.log(`✅ Found profile.id=${profile.id} for WordPress user ${userId}`)

      // Call the helper function to get preferences with defaults
      const { data, error } = await this.supabase
        .rpc('get_user_chat_preferences', { p_user_id: profile.id })
        .single()

      if (error) {
        console.error(`❌ Error calling get_user_chat_preferences RPC for profile.id=${profile.id}:`, error)
        console.log(`⚠️ Using defaults for user ${userId}`)
        return {
          user_id: profile.id,
          ...DEFAULT_CHAT_PREFERENCES
        } as ChatUserPreferences
      }

      if (!data) {
        console.log(`⚠️ RPC returned no data for profile.id=${profile.id}, using defaults`)
        return {
          user_id: profile.id,
          ...DEFAULT_CHAT_PREFERENCES
        } as ChatUserPreferences
      }

      console.log(`✅ Loaded chat preferences for user ${userId}:`, JSON.stringify(data, null, 2))

      return data as ChatUserPreferences
    } catch (error) {
      console.error('❌ Unexpected error fetching chat preferences:', error)
      return {
        user_id: 0,
        ...DEFAULT_CHAT_PREFERENCES
      } as ChatUserPreferences
    }
  }

  // =====================================================
  // UTILITIES
  // =====================================================

  async generateConversationTitle(conversationId: number): Promise<void> {
    try {
      await this.supabase.rpc('generate_conversation_title', {
        conversation_big_id: conversationId
      })
    } catch (error) {
      console.error('Error generating conversation title:', error)
    }
  }

  // =====================================================
  // USER PROFILE
  // =====================================================

  async getUserProfile(userId: string): Promise<UserProfile | null> {
    const { data, error } = await this.supabase
      .from('users')
      .select('id, username, email, first_name, last_name, phone')
      .eq('id', userId)
      .single()

    if (error || !data) {
      console.error('Error fetching user profile:', error)
      return null
    }

    return {
      id: String(data.id),
      username: data.username,
      email: data.email,
      first_name: data.first_name,
      last_name: data.last_name,
      phone: data.phone
    }
  }
}

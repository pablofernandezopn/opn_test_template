// question_fetcher.ts - Fetches questions from different sources

import type { SupabaseClient } from 'jsr:@supabase/supabase-js@2'
import type { Question, TopicWeight, TestMode } from './types.ts'

export class QuestionFetcher {
  constructor(private supabase: SupabaseClient) {}

  /**
   * Fetch all topics for a given topicTypeId
   */
  async fetchAllTopicsForType(topicTypeId: number): Promise<number[]> {
    console.log(`🔍 Fetching all topics for topicTypeId: ${topicTypeId}`)

    const { data, error } = await this.supabase
      .from('topic')
      .select('id')
      .eq('topic_type_id', topicTypeId)
      .eq('published', true)

    if (error) {
      throw new Error(`Failed to fetch topics for topicTypeId ${topicTypeId}: ${error.message}`)
    }

    if (!data || data.length === 0) {
      console.warn(`⚠️ No published topics found for topicTypeId: ${topicTypeId}`)
      return []
    }

    const topicIds = data.map(t => t.id)
    console.log(`✅ Found ${topicIds.length} topics for topicTypeId ${topicTypeId}`)
    return topicIds
  }

  /**
   * Fetch questions from topics
   */
  async fetchFromTopics(
    topics: TopicWeight[],
    maxQuestions: number,
    academyId?: number,
    difficulties?: string[],
    topicTypeId?: number
  ): Promise<Question[]> {
    console.log(`📚 Fetching up to ${maxQuestions} questions from topics...${topicTypeId ? ` (topicTypeId: ${topicTypeId})` : ''}`)

    // If topics is empty, fetch all topics for the topicTypeId
    let topicIds: number[]
    if (topics.length === 0 && topicTypeId !== undefined) {
      console.log(`⚠️ No topics provided, fetching all topics for topicTypeId: ${topicTypeId}`)
      topicIds = await this.fetchAllTopicsForType(topicTypeId)

      if (topicIds.length === 0) {
        console.warn(`⚠️ No published topics found for topicTypeId: ${topicTypeId}`)
        return []
      }

      console.log(`✅ Using all ${topicIds.length} topics from topicTypeId: ${topicTypeId}`)
    } else {
      topicIds = topics.map((t) => t.id)
    }

    let query = this.supabase
      .from('questions')
      .select(`
        *,
        topic!inner (
          id,
          topic_type_id
        )
      `)
      .in('topic', topicIds)
      .eq('published', true)

    // Add topic_type_id filter if provided
    if (topicTypeId !== undefined) {
      query = query.eq('topic.topic_type_id', topicTypeId)
    }

    if (academyId) {
      query = query.eq('academy_id', academyId)
    }

    // Si hay filtro de dificultades
    if (difficulties && difficulties.length > 0) {
      const difficultyConditions = []

      if (difficulties.includes('easy')) {
        difficultyConditions.push('difficult_rate.lt.0.3')
      }
      if (difficulties.includes('normal')) {
        difficultyConditions.push('difficult_rate.gte.0.3,difficult_rate.lte.0.7')
      }
      if (difficulties.includes('hard')) {
        difficultyConditions.push('difficult_rate.gt.0.7')
      }

      if (difficultyConditions.length > 0) {
        query = query.or(difficultyConditions.join(','))
      }
    }

    const { data, error } = await query.limit(maxQuestions)

    if (error) {
      console.error('❌ Error fetching questions from topics:', error)
      throw new Error(`Failed to fetch questions: ${error.message}`)
    }

    console.log(`✅ Fetched ${data?.length || 0} questions from topics`)
    return data || []
  }

  /**
   * Fetch failed questions for a user
   * Only includes questions where the MOST RECENT answer was incorrect
   */
  async fetchFailedQuestions(
    userId: string,
    maxQuestions: number,
    academyId?: number,
    topicIds?: number[],
    difficulties?: string[],
    topicTypeId?: number
  ): Promise<Question[]> {
    console.log(`❌ Fetching up to ${maxQuestions} failed questions for user ${userId}...${topicTypeId ? ` (topicTypeId: ${topicTypeId})` : ''}`)

    // Step 1: Get all questions the user has answered at least once incorrectly
    let questionsQuery = this.supabase
      .from('questions')
      .select(`
        *,
        topic!inner (
          id,
          topic_type_id
        )
      `)
      .eq('published', true)

    // Add topic_type_id filter if provided
    if (topicTypeId !== undefined) {
      questionsQuery = questionsQuery.eq('topic.topic_type_id', topicTypeId)
    }

    if (academyId) {
      questionsQuery = questionsQuery.eq('academy_id', academyId)
    }

    if (topicIds && topicIds.length > 0) {
      questionsQuery = questionsQuery.in('topic', topicIds)
    }

    // Filtro de dificultades
    if (difficulties && difficulties.length > 0) {
      const difficultyConditions = []

      if (difficulties.includes('easy')) {
        difficultyConditions.push('difficult_rate.lt.0.3')
      }
      if (difficulties.includes('normal')) {
        difficultyConditions.push('difficult_rate.gte.0.3,difficult_rate.lte.0.7')
      }
      if (difficulties.includes('hard')) {
        difficultyConditions.push('difficult_rate.gt.0.7')
      }

      if (difficultyConditions.length > 0) {
        questionsQuery = questionsQuery.or(difficultyConditions.join(','))
      }
    }

    const { data: questions, error: questionsError } = await questionsQuery

    if (questionsError) {
      console.error('❌ Error fetching questions:', questionsError)
      throw new Error(`Failed to fetch questions: ${questionsError.message}`)
    }

    if (!questions || questions.length === 0) {
      console.log('⚠️ No questions found matching criteria')
      return []
    }

    const questionIds = questions.map((q) => q.id)

    // Step 2: Get the most recent answer for each question
    const { data: answers, error: answersError } = await this.supabase
      .from('user_test_answers')
      .select(`
        question_id,
        correct,
        answered_at,
        user_tests!inner(user_id)
      `)
      .in('question_id', questionIds)
      .eq('user_tests.user_id', userId)
      .order('answered_at', { ascending: false })

    if (answersError) {
      console.error('❌ Error fetching answers:', answersError)
      throw new Error(`Failed to fetch answers: ${answersError.message}`)
    }

    // Step 3: Group answers by question_id and keep only the most recent one
    const mostRecentAnswers = new Map<number, boolean>()

    if (answers) {
      for (const answer of answers) {
        if (!mostRecentAnswers.has(answer.question_id)) {
          // First time seeing this question = most recent answer
          mostRecentAnswers.set(answer.question_id, answer.correct)
        }
      }
    }

    // Step 4: Filter questions where most recent answer was incorrect
    const failedQuestions = questions.filter((question) => {
      const wasCorrect = mostRecentAnswers.get(question.id)
      // Include only if most recent answer was incorrect (false)
      return wasCorrect === false
    })

    console.log(`✅ Found ${failedQuestions.length} questions with most recent answer incorrect (from ${questions.length} total)`)

    // Limit results
    return failedQuestions.slice(0, maxQuestions)
  }

  /**
   * Fetch skipped questions for a user
   * Only includes questions where the MOST RECENT answer was skipped/blank
   */
  async fetchSkippedQuestions(
    userId: string,
    maxQuestions: number,
    academyId?: number,
    topicIds?: number[],
    difficulties?: string[],
    topicTypeId?: number
  ): Promise<Question[]> {
    console.log(`⏭️ Fetching up to ${maxQuestions} skipped questions for user ${userId}...${topicTypeId ? ` (topicTypeId: ${topicTypeId})` : ''}`)

    // Step 1: Get all questions
    let questionsQuery = this.supabase
      .from('questions')
      .select(`
        *,
        topic!inner (
          id,
          topic_type_id
        )
      `)
      .eq('published', true)

    // Add topic_type_id filter if provided
    if (topicTypeId !== undefined) {
      questionsQuery = questionsQuery.eq('topic.topic_type_id', topicTypeId)
    }

    if (academyId) {
      questionsQuery = questionsQuery.eq('academy_id', academyId)
    }

    if (topicIds && topicIds.length > 0) {
      questionsQuery = questionsQuery.in('topic', topicIds)
    }

    // Filtro de dificultades
    if (difficulties && difficulties.length > 0) {
      const difficultyConditions = []

      if (difficulties.includes('easy')) {
        difficultyConditions.push('difficult_rate.lt.0.3')
      }
      if (difficulties.includes('normal')) {
        difficultyConditions.push('difficult_rate.gte.0.3,difficult_rate.lte.0.7')
      }
      if (difficulties.includes('hard')) {
        difficultyConditions.push('difficult_rate.gt.0.7')
      }

      if (difficultyConditions.length > 0) {
        questionsQuery = questionsQuery.or(difficultyConditions.join(','))
      }
    }

    const { data: questions, error: questionsError } = await questionsQuery

    if (questionsError) {
      console.error('❌ Error fetching questions:', questionsError)
      throw new Error(`Failed to fetch questions: ${questionsError.message}`)
    }

    if (!questions || questions.length === 0) {
      console.log('⚠️ No questions found matching criteria')
      return []
    }

    const questionIds = questions.map((q) => q.id)

    // Step 2: Get the most recent answer for each question
    const { data: answers, error: answersError } = await this.supabase
      .from('user_test_answers')
      .select(`
        question_id,
        selected_option_id,
        answered_at,
        user_tests!inner(user_id)
      `)
      .in('question_id', questionIds)
      .eq('user_tests.user_id', userId)
      .order('answered_at', { ascending: false })

    if (answersError) {
      console.error('❌ Error fetching answers:', answersError)
      throw new Error(`Failed to fetch answers: ${answersError.message}`)
    }

    // Step 3: Group answers by question_id and keep only the most recent one
    const mostRecentAnswers = new Map<number, number | null>()

    if (answers) {
      for (const answer of answers) {
        if (!mostRecentAnswers.has(answer.question_id)) {
          // First time seeing this question = most recent answer
          mostRecentAnswers.set(answer.question_id, answer.selected_option_id)
        }
      }
    }

    // Step 4: Filter questions where most recent answer was skipped (null)
    const skippedQuestions = questions.filter((question) => {
      const selectedOption = mostRecentAnswers.get(question.id)
      // Include only if most recent answer was skipped (null)
      return selectedOption === null
    })

    console.log(`✅ Found ${skippedQuestions.length} questions with most recent answer skipped (from ${questions.length} total)`)

    // Limit results
    return skippedQuestions.slice(0, maxQuestions)
  }
}
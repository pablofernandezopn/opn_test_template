// question_distributor.ts - Logic for distributing questions across topics

import { SupabaseClient } from 'jsr:@supabase/supabase-js@2'
import type { Question, TopicWeight, TopicDistribution } from './types.ts'

export class QuestionDistributor {
  constructor(private supabase: SupabaseClient) {}

  /**
   * Fetch all topics for a given topicTypeId
   */
  async fetchAllTopicsForType(topicTypeId: number): Promise<TopicWeight[]> {
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

    // Assign equal weight to all topics
    const equalWeight = 1
    const topics: TopicWeight[] = data.map(t => ({
      id: t.id,
      weight: equalWeight
    }))

    console.log(`✅ Found ${topics.length} topics for topicTypeId ${topicTypeId}`)
    return topics
  }

  /**
   * Calculate how many questions to get from each topic based on weights
   */
  calculateDistribution(
    topics: TopicWeight[],
    totalQuestions: number
  ): Map<number, number> {
    // Normalize weights to sum to 1
    const totalWeight = topics.reduce((sum, t) => sum + t.weight, 0)

    if (totalWeight === 0) {
      throw new Error('Total weight cannot be zero')
    }

    const distribution = new Map<number, number>()
    let assignedQuestions = 0

    // Calculate initial distribution
    topics.forEach((topic, index) => {
      const normalizedWeight = topic.weight / totalWeight

      // For the last topic, assign remaining questions to avoid rounding errors
      if (index === topics.length - 1) {
        distribution.set(topic.id, totalQuestions - assignedQuestions)
      } else {
        const questionCount = Math.floor(totalQuestions * normalizedWeight)
        distribution.set(topic.id, questionCount)
        assignedQuestions += questionCount
      }
    })

    return distribution
  }

  /**
   * Get random questions from a specific topic
   */
  async getRandomQuestions(
    topicId: number,
    count: number,
    academyId?: number,
    difficulties?: ('easy' | 'normal' | 'hard')[],
    topicTypeId?: number
  ): Promise<Question[]> {
    console.log(`📚 Fetching ${count} questions from topic ${topicId}${difficulties ? ` with difficulties: ${difficulties.join(', ')}` : ' (all difficulties)'}${topicTypeId ? ` (topicTypeId: ${topicTypeId})` : ''}`)

    // Build query with JOIN to topic table for filtering by topic_type_id
    let query = this.supabase
      .from('questions')
      .select(`
        *,
        topic!inner (
          id,
          topic_type_id
        )
      `)
      .eq('topic', topicId)
      .eq('published', true)

    // Add topic_type_id filter if provided
    if (topicTypeId !== undefined) {
      query = query.eq('topic.topic_type_id', topicTypeId)
    }

    // Add academy filter if provided
    if (academyId !== undefined) {
      query = query.eq('academy_id', academyId)
    }

    // Get all available questions
    let { data: availableQuestions, error } = await query

    if (error) {
      console.error(`❌ Error fetching questions for topic ${topicId}:`, error)
      throw new Error(`Failed to fetch questions for topic ${topicId}: ${error.message}`)
    }

    if (!availableQuestions || availableQuestions.length === 0) {
      console.warn(`⚠️ No questions available for topic ${topicId}`)
      return []
    }

    // Filter by difficulties client-side if provided
    if (difficulties && difficulties.length > 0) {
      availableQuestions = availableQuestions.filter((q: Question) => {
        if (q.difficult_rate === null) return false

        // Check if question falls in any of the selected difficulty ranges
        return difficulties.some(diff => {
          switch (diff) {
            case 'easy':
              return q.difficult_rate! <= 0.33
            case 'normal':
              return q.difficult_rate! >= 0.34 && q.difficult_rate! <= 0.66
            case 'hard':
              return q.difficult_rate! >= 0.67
            default:
              return false
          }
        })
      })

      console.log(`✅ After difficulty filter: ${availableQuestions.length} questions available`)

      if (availableQuestions.length === 0) {
        console.warn(`⚠️ No questions match the selected difficulties for topic ${topicId}`)
        return []
      }
    }

    console.log(`✅ Found ${availableQuestions.length} available questions for topic ${topicId}`)

    // If we have fewer questions than requested, return all
    if (availableQuestions.length <= count) {
      console.warn(
        `⚠️ Topic ${topicId} has only ${availableQuestions.length} questions, requested ${count}`
      )
      return availableQuestions
    }

    // Randomly select questions
    return this.shuffleArray(availableQuestions).slice(0, count)
  }

  /**
   * Generate test with distributed questions
   */
  async generateTest(
    topics: TopicWeight[],
    totalQuestions: number,
    academyId?: number,
    difficulties?: ('easy' | 'normal' | 'hard')[],
    topicTypeId?: number
  ): Promise<{
    questions: Question[]
    distribution: TopicDistribution
    adjustedTotal: number
  }> {
    console.log(`🎯 Generating test with ${totalQuestions} questions${difficulties ? ` (difficulties: ${difficulties.join(', ')})` : ' (all difficulties)'}${topicTypeId ? ` (topicTypeId: ${topicTypeId})` : ''}`)
    console.log(`📊 Topics:`, topics)

    // If topics is empty, fetch all topics for the topicTypeId
    let actualTopics = topics
    if (topics.length === 0 && topicTypeId !== undefined) {
      console.log(`⚠️ No topics provided, fetching all topics for topicTypeId: ${topicTypeId}`)
      actualTopics = await this.fetchAllTopicsForType(topicTypeId)

      if (actualTopics.length === 0) {
        throw new Error(`No published topics found for topicTypeId: ${topicTypeId}`)
      }

      console.log(`✅ Using all ${actualTopics.length} topics from topicTypeId: ${topicTypeId}`)
    }

    // Validate topics are from 'Study' type
    const topicIds = actualTopics.map(t => t.id)
    const { data: topicData, error: topicError} = await this.supabase
      .from('topic')
      .select(`
        id,
        topic_type_id,
        topic_type:topic_type_id (
          level
        )
      `)
      .in('id', topicIds)

    if (topicError) {
      throw new Error(`Failed to validate topics: ${topicError.message}`)
    }

    // Check all topics are Study level
    const invalidTopics = topicData?.filter(
      (t: any) => t.topic_type?.level !== 'Study'
    )

    if (invalidTopics && invalidTopics.length > 0) {
      throw new Error(
        `Topics must be of type 'Study'. Invalid topics: ${invalidTopics.map((t: any) => t.id).join(', ')}`
      )
    }

    // Calculate initial distribution
    const distribution = this.calculateDistribution(actualTopics, totalQuestions)
    console.log(`📈 Initial distribution:`, Object.fromEntries(distribution))

    // Fetch questions from each topic
    const questionPromises = Array.from(distribution.entries()).map(
      ([topicId, count]) => this.getRandomQuestions(topicId, count, academyId, difficulties, topicTypeId)
    )

    const questionsByTopic = await Promise.all(questionPromises)

    // Flatten all questions
    const allQuestions: Question[] = []
    const actualDistribution: TopicDistribution = {}

    questionsByTopic.forEach((questions, index) => {
      const topicId = Array.from(distribution.keys())[index]
      allQuestions.push(...questions)
      actualDistribution[topicId.toString()] = questions.length
    })

    console.log(`📊 Actual distribution:`, actualDistribution)
    console.log(`✅ Total questions collected: ${allQuestions.length}`)

    // Shuffle all questions
    const shuffledQuestions = this.shuffleArray(allQuestions)

    return {
      questions: shuffledQuestions,
      distribution: actualDistribution,
      adjustedTotal: allQuestions.length
    }
  }

  /**
   * Fisher-Yates shuffle algorithm
   */
  private shuffleArray<T>(array: T[]): T[] {
    const shuffled = [...array]
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]]
    }
    return shuffled
  }
}

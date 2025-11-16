// =====================================================
// REPOSITORY: RAG API Communication
// =====================================================

import type { RAGApiRequest, RAGApiResponse, RAGApiError } from '../models/rag_api.ts'

export class RAGApiRepository {
  private apiUrl: string
  private jwtToken: string

  constructor(apiUrl?: string, jwtToken?: string) {
    this.apiUrl = apiUrl || Deno.env.get('RAG_API_URL') ||
      'https://rag-legal-api-842602951144.us-central1.run.app'
    this.jwtToken = jwtToken || Deno.env.get('RAG_API_JWT_TOKEN') || ''

    if (!this.jwtToken) {
      console.warn('⚠️ RAG_API_JWT_TOKEN not configured')
    }
  }

  /**
   * Query the RAG API with an enriched query
   */
  async query(enrichedQuery: string): Promise<RAGApiResponse> {
    if (!this.jwtToken) {
      throw new Error('RAG_API_JWT_TOKEN not configured in environment')
    }

    const endpoint = `${this.apiUrl}/query`

    console.log(`🚀 Calling RAG API: ${endpoint}`)
    console.log(`📝 Query length: ${enrichedQuery.length} chars`)

    const request: RAGApiRequest = {
      query: enrichedQuery
    }

    try {
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.jwtToken}`
        },
        body: JSON.stringify(request)
      })

      if (!response.ok) {
        const errorText = await response.text()
        console.error(`❌ RAG API error (${response.status}):`, errorText)

        throw new Error(`RAG API error: ${response.status} - ${errorText}`)
      }

      const data: RAGApiResponse = await response.json()

      console.log(`✅ RAG API response received`)
      console.log(`   Response length: ${data.response?.length || 0} chars`)
      console.log(`   Citations: ${data.citations?.length || 0}`)
      console.log(`   Has reasoning: ${!!data.reasoning}`)

      return data

    } catch (error) {
      console.error('❌ RAG API request failed:', error)

      if (error instanceof Error) {
        throw error
      }

      throw new Error(`RAG API request failed: ${String(error)}`)
    }
  }

  /**
   * Check if RAG API is configured and accessible
   */
  async healthCheck(): Promise<boolean> {
    try {
      const response = await fetch(`${this.apiUrl}/info`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${this.jwtToken}`
        }
      })

      return response.ok
    } catch (error) {
      console.error('RAG API health check failed:', error)
      return false
    }
  }

  /**
   * Get RAG API configuration
   */
  getConfig() {
    return {
      apiUrl: this.apiUrl,
      hasToken: !!this.jwtToken
    }
  }
}

// =====================================================
// MODELS: RAG API Request and Response
// =====================================================

export interface RAGApiRequest {
  query: string
}

export interface LawCitation {
  law_item_id: number
  law_unic_id?: string
  law_title?: string
  law_identifier?: string
  item_title?: string
  content: string
  url?: string
}

export interface RAGApiResponse {
  response: string
  reasoning?: string
  citations?: LawCitation[]
}

export interface RAGApiError {
  error: string
  details?: string
  status_code?: number
}

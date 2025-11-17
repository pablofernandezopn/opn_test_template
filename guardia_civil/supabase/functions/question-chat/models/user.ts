// =====================================================
// MODELS: User Profile
// =====================================================

export interface UserProfile {
  id: string
  username: string
  email: string | null
  first_name: string | null
  last_name: string | null
  phone: string | null
}

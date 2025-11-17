// api/v1/login.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { RequestHandler } from '../../framework/request_handler.ts'
import { FnResponse } from '../../framework/fn_response.ts'
import { WpException } from '../../wp_client/model/wp_exception.ts'
import { WPClient } from '../../wp_client/wp_client.ts'
import { syncUserMemberships } from '../../sync_memberships.ts'
import { ensureUserInSupabase, type WordPressUserData } from '../../helpers/user_sync.ts'
import { syncMembershipCatalog } from './sync_membership_catalog.ts'

type SupabaseClient = ReturnType<typeof createClient>

export class WPLogin extends RequestHandler {
  async handle(
    supabaseClient: SupabaseClient,
    request: Request
  ): Promise<FnResponse> {
    const body = await this.parseJsonBody(request)

    if (!body || typeof body !== 'object') {
      throw new WpException(
        400,
        "Bad format",
        "Bad request",
        null
      )
    }

    return this.processLogin(supabaseClient, body)
  }

  private async processLogin(
    supabaseClient: SupabaseClient,
    body: Record<string, any>
  ): Promise<FnResponse> {
    // Aceptar tanto "username" como "email" (más flexible)
    const userIdentifier = body.username || body.email
    
    if (!userIdentifier || !body.password) {
      throw new WpException(
        400,
        "Missing username/email and/or password",
        "Bad request",
        undefined
      )
    }

    try {
      const wpClient = new WPClient(supabaseClient)

      // 0. ⚡ SINCRONIZAR MEMBERSHIP LEVELS DESDE WORDPRESS
      console.log('🔄 Syncing membership catalog from WordPress...')
      try {
        const syncResult = await syncMembershipCatalog()
        console.log(`✅ Membership catalog synced: ${syncResult.stats?.created || 0} created, ${syncResult.stats?.updated || 0} updated, ${syncResult.stats?.total || 0} total`)
      } catch (syncError) {
        console.error('⚠️ Error syncing membership catalog (non-fatal):', syncError)
        // No lanzamos error para que el login continúe
      }

      // 1. Login en WordPress y obtener token
      console.log(`🔐 Login attempt for: ${userIdentifier}`)
      const token = await wpClient.userLogin(userIdentifier, body.password)

      // 2. Obtener datos básicos del usuario desde WordPress
      const userDataResponse = await this.getUserBasicDataFromWP(token)
      console.log(`📥 User data from WordPress: ID=${userDataResponse.id}, username=${userDataResponse.username}`)

      // 3. ⭐ SINCRONIZAR A SUPABASE (SIEMPRE) - Crea usuario si no existe
      const wpUserDataFormatted: WordPressUserData = {
        id: userDataResponse.id,
        username: userDataResponse.username,
        email: userDataResponse.email,
        firstName: userDataResponse.first_name,
        lastName: userDataResponse.last_name
      }

      const completeUserData = await ensureUserInSupabase(
        supabaseClient,
        wpUserDataFormatted
      )

      console.log(`✅ User synchronized to Supabase: ID=${completeUserData.id}, academy_id=${completeUserData.academy_id}`)

      // 4. SINCRONIZAR MEMBRESÍAS DESDE WORDPRESS usando token de administrador
      console.log(`🔄 Syncing memberships for user ${userDataResponse.id}...`)
      let membershipsSynced = 0
      try {
        // Usar token de administrador para consultar membresías
        const adminToken = await wpClient.getAdminToken()
        const syncResult = await syncUserMemberships(userDataResponse.id, adminToken)
        membershipsSynced = syncResult.synced
        console.log(`✅ Memberships synced: ${membershipsSynced} (created: ${syncResult.created}, updated: ${syncResult.updated}, deactivated: ${syncResult.deactivated})`)
      } catch (membershipError) {
        console.error('⚠️ Error syncing memberships (non-fatal):', membershipError)
        // No lanzamos el error para que el login continúe
      }

      // 5. Obtener datos completos actualizados después de sincronizar membresías
      const { data: finalUserData, error: fetchError } = await supabaseClient
        .from('users')
        .select(`
          *,
          user_memberships(
            *,
            membership_level:membership_levels(*)
          )
        `)
        .eq('id', completeUserData.id)
        .single()

      if (fetchError) {
        console.error('⚠️ Error fetching final user data:', fetchError)
        // Usar completeUserData como fallback
      }

      // 6. Respuesta exitosa con datos completos
      return new FnResponse({
        success: true,
        token: token,
        user: finalUserData || completeUserData,
        memberships_synced: membershipsSynced
      }, {
        headers: RequestHandler.jsonHeaders,
        status: 200
      })
    } catch (error) {
      if (error instanceof WpException) {
        throw error
      }

      throw new WpException(
        500,
        "Login failed",
        "Internal Server Error",
        error instanceof Error ? error.message : String(error)
      )
    }
  }

  private async getUserBasicDataFromWP(token: string): Promise<any> {
    const wpUrl = Deno.env.get('WP_URL') || ''

    try {
      const response = await fetch(`${wpUrl}/wp-json/wp/v2/users/me?context=edit`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      })

      if (!response.ok) {
        throw new WpException(
          response.status,
          'Failed to get user from WordPress',
          response.statusText,
          undefined
        )
      }

      const userData = await response.json()

      return {
        id: userData.id,
        username: userData.username || userData.name,
        email: userData.email || '',
        first_name: userData.first_name || '',
        last_name: userData.last_name || ''
      }
    } catch (error) {
      console.error('❌ Error getting user basic data from WP:', error)
      throw error
    }
  }
}
// api/v1/register.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { RequestHandler } from '../../framework/request_handler.ts'
import { FnResponse } from '../../framework/fn_response.ts'
import { WpException } from '../../wp_client/model/wp_exception.ts'
import { RegisterRequest } from '../../wp_client/model/register_request.ts'
import { WPClient } from '../../wp_client/wp_client.ts'
import { syncUserMemberships } from '../../sync_memberships.ts'
import { ensureUserInSupabase, type WordPressUserData } from '../../helpers/user_sync.ts'
import { syncMembershipCatalog } from './sync_membership_catalog.ts'

type SupabaseClient = ReturnType<typeof createClient>

export class WPRegister extends RequestHandler {
  async handle(
    supabaseClient: SupabaseClient,
    request: Request
  ): Promise<FnResponse> {
    const body = await this.parseJsonBody(request)

    if (!body || typeof body !== 'object') {
      throw new WpException(
        400,
        "Empty request",
        "Bad request",
        null
      )
    }

    return this.processRegister(supabaseClient, body)
  }

  private async processRegister(
    supabaseClient: SupabaseClient,
    body: Record<string, any>
  ): Promise<FnResponse> {
    try {
      const registerRequest = RegisterRequest.fromJson(body)
      const wpClient = new WPClient(supabaseClient)

      // 0. ⚡ SINCRONIZAR MEMBERSHIP LEVELS DESDE WORDPRESS
      console.log('🔄 Syncing membership catalog from WordPress...')
      try {
        const syncResult = await syncMembershipCatalog()
        console.log(`✅ Membership catalog synced: ${syncResult.stats?.created || 0} created, ${syncResult.stats?.updated || 0} updated, ${syncResult.stats?.total || 0} total`)
      } catch (syncError) {
        console.error('⚠️ Error syncing membership catalog (non-fatal):', syncError)
        // No lanzamos error para que el registro continúe
      }

      // 1. Crear usuario en WordPress
      const user = await wpClient.register(registerRequest)
      console.log(`✅ User created in WordPress: ID=${user.id}, username=${user.username}`)

      // 2. ⭐ SINCRONIZAR A SUPABASE (SIEMPRE) - Crea usuario con academy_id
      const wpUserDataFormatted: WordPressUserData = {
        id: user.id,
        username: user.username,
        email: user.email,
        firstName: user.firstName || '',
        lastName: user.lastName || ''
      }

      const completeUserData = await ensureUserInSupabase(
        supabaseClient,
        wpUserDataFormatted
      )

      console.log(`✅ User synchronized to Supabase: ID=${completeUserData.id}, academy_id=${completeUserData.academy_id}`)

      // 3. 🔑 Hacer login automático para obtener el token
      console.log('🔑 Obteniendo token de autenticación...')
      const token = await wpClient.userLogin(
        registerRequest.username,
        registerRequest.password
      )

      console.log('✅ Token obtenido correctamente')

      // 4. 🔄 Sincronizar membresías desde WordPress usando token de administrador
      console.log(`🔄 Syncing memberships for new user ${user.id}...`)
      let membershipsSynced = 0
      try {
        // Usar token de administrador para consultar membresías
        const adminToken = await wpClient.getAdminToken()
        const syncResult = await syncUserMemberships(user.id, adminToken)
        membershipsSynced = syncResult.synced
        console.log(`✅ Memberships synced: ${membershipsSynced} (created: ${syncResult.created}, updated: ${syncResult.updated})`)
      } catch (membershipError) {
        console.error('⚠️ Error syncing memberships (non-fatal):', membershipError)
        // No lanzamos el error para que el registro continúe
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
      return this.jsonResponse({
        success: true,
        token: token,
        user: finalUserData || completeUserData,
        memberships_synced: membershipsSynced
      })
    } catch (error) {
      if (error instanceof WpException) {
        throw error
      }

      throw new WpException(
        500,
        "Registration failed",
        "Internal Server Error",
        error instanceof Error ? error.message : String(error)
      )
    }
  }
}
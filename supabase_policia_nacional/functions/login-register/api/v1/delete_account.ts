// api/v1/delete_account.ts
import { RequestHandler } from '../../framework/request_handler.ts'
import { FnResponse } from '../../framework/fn_response.ts'
import { WPClient } from '../../wp_client/wp_client.ts'
import { WpException } from '../../wp_client/model/wp_exception.ts'

interface DeleteAccountRequest {
  user_token: string
}

export class DeleteAccountHandler extends RequestHandler {
  async handle(supabaseClient: any, request: Request): Promise<FnResponse> {
    try {
      // Parsear el body de la request
      const requestBody = await request.json() as DeleteAccountRequest

      if (!requestBody.user_token) {
        throw new WpException(
          400,
          'Missing required field: user_token',
          'Bad Request',
          'user_token is required'
        )
      }

      const wpClient = new WPClient(supabaseClient)

      // Primero obtener información del usuario para verificar el token y obtener el ID
      console.log('🔍 Getting user information...')
      const user = await wpClient.getUser(requestBody.user_token)

      if (!user || !user.id) {
        throw new WpException(
          401,
          'Invalid user token',
          'Unauthorized',
          'Could not retrieve user information'
        )
      }

      const userId = user.id
      const userEmail = user.email

      console.log(`🗑️ Deleting user account for user ID: ${userId}, email: ${userEmail}`)

      // 1. Eliminar el usuario de RevenueCat
      try {
        console.log('🗑️ Deleting user from RevenueCat...')
        await this.deleteFromRevenueCat(userId.toString())
      } catch (rcError) {
        console.warn(`⚠️ Warning: Could not delete user from RevenueCat: ${rcError}`)
        // No bloqueamos el proceso si falla RevenueCat
      }

      // 2. Eliminar el usuario de WordPress
      await wpClient.deleteUser(userId)

      // 3. Marcar el usuario como eliminado en Supabase (soft delete)
      console.log('🗑️ Marking user as deleted in Supabase...')
      const newUsername = `user_${userId}`

      const { error: updateError } = await supabaseClient
        .from('users')
        .update({
          deleted: true,
          deleted_at: new Date().toISOString(),
          username: newUsername,
          email: null,
          first_name: null,
          last_name: null,
          phone: null,
          fcm_token: null,
          fid_token: null,
          profile_image: null,
          enabled: false
        })
        .eq('id', userId)

      if (updateError) {
        console.error(`❌ Error marking user as deleted in Supabase: ${updateError.message}`)
        throw new WpException(
          500,
          'Error marking user as deleted',
          'Internal Server Error',
          updateError.message
        )
      }

      console.log(`✓ User ${userId} marked as deleted with username: ${newUsername}`)

      return new FnResponse(
        {
          success: true,
          message: 'User account deleted successfully',
          user_id: userId
        },
        {
          headers: RequestHandler.jsonHeaders,
          status: 200
        }
      )

    } catch (error) {
      console.error('❌ Error in DeleteAccountHandler:', error)

      if (error instanceof WpException) {
        return new FnResponse(
          error.toJson(),
          {
            headers: RequestHandler.jsonHeaders,
            status: error.status,
            statusText: error.reason
          }
        )
      }

      const errorMessage = error instanceof Error ? error.message : String(error)
      const wpException = new WpException(
        500,
        'Error deleting account',
        'Internal Server Error',
        errorMessage
      )

      return new FnResponse(
        wpException.toJson(),
        {
          headers: RequestHandler.jsonHeaders,
          status: 500,
          statusText: 'Internal Server Error'
        }
      )
    }
  }

  private async deleteFromRevenueCat(appUserId: string): Promise<void> {
    const revenueCatApiKey = Deno.env.get('REVENUECAT_API_KEY')

    if (!revenueCatApiKey) {
      console.warn('⚠️ REVENUECAT_API_KEY not configured, skipping RevenueCat deletion')
      return
    }

    const url = `https://api.revenuecat.com/v1/subscribers/${appUserId}`

    console.log(`🌐 Deleting subscriber from RevenueCat: ${appUserId}`)

    try {
      const response = await fetch(url, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${revenueCatApiKey}`,
          'Content-Type': 'application/json'
        }
      })

      if (response.ok || response.status === 404) {
        console.log(`✓ User deleted from RevenueCat: ${response.status}`)
      } else {
        const errorBody = await response.text()
        console.error(`❌ RevenueCat deletion failed: ${response.status} - ${errorBody}`)
        throw new Error(`RevenueCat API error: ${response.status}`)
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error)
      console.error(`❌ Error deleting from RevenueCat: ${errorMessage}`)
      throw error
    }
  }
}

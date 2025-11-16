// api/v1/get_user.ts
import { RequestHandler } from '../../framework/request_handler.ts'
import { FnResponse } from '../../framework/fn_response.ts'
import { WpException } from '../../wp_client/model/wp_exception.ts'
import { ensureUserInSupabase, type WordPressUserData } from '../../helpers/user_sync.ts'
import { syncUserMemberships } from '../../sync_memberships.ts'
import { syncMembershipCatalog } from './sync_membership_catalog.ts'
import { WPClient } from '../../wp_client/wp_client.ts'

// WordPress Client simplificado
class WordPressClient {
  private wpUrl = 'https://oposicionesguardiacivil.online/';
  private jwtSecret = '{syqtT}C|,ENojj&BDXZE}Q+zCNd)Y,$8f!3o8zj8>PkTSl^<F_(wU^sb}FnQ[Cy';

  async getUser(token: string): Promise<any> {
    try {
      console.log('🔍 Getting user with token (length):', token.length);
      console.log('🔍 Token preview:', token.substring(0, 50) + '...');
      
      const wpEndpoint = `${this.wpUrl}wp-json/wp/v2/users/me?context=edit`;
      console.log('🔍 WordPress endpoint:', wpEndpoint);
      
      // Obtener información del usuario directamente (sin validación previa)
      const userResponse = await fetch(wpEndpoint, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      console.log('🔍 User response status:', userResponse.status);
      console.log('🔍 User response headers:', Object.fromEntries(userResponse.headers.entries()));
      
      const userData = await userResponse.json();
      console.log('🔍 User data received:', userData);

      if (!userResponse.ok) {
        console.log('❌ WordPress returned error:', userData);
        throw new WpException(
          userResponse.status, 
          "Failed to get user from WordPress", 
          userResponse.statusText, 
          JSON.stringify(userData)
        );
      }

      const result = {
        id: userData.id,
        username: userData.username || userData.name,
        email: userData.email || 'N/A',
        firstName: userData.first_name || '',
        lastName: userData.last_name || ''
      };
      
      console.log('✅ User data processed:', result);
      return result;
      
    } catch (error) {
      console.log('💥 Error in getUser:', error);
      
      if (error instanceof WpException) {
        throw error;
      }
      
      throw new WpException(
        500, 
        "Error fetching user", 
        "Internal Server Error", 
        error instanceof Error ? error.message : String(error)
      );
    }
  }
}

export class WpGetUser extends RequestHandler {
  async handle(supabaseClient: any, request: Request): Promise<FnResponse> {
    console.log('🔍 WpGetUser.handle() called - PRODUCTION VERSION');
    console.log('🔍 Debug - Request method:', request.method);
    
    // Safely log headers
    try {
      const headersObj: Record<string, string> = {};
      request.headers.forEach((value: string, key: string) => {
        headersObj[key] = value;
      });
      console.log('🔍 Debug - Request headers:', headersObj);
    } catch (e) {
      console.log('⚠️ Could not log headers:', e);
    }
    
    // Verificar que la request tenga headers
    if (!request.headers) {
      console.log('❌ No headers found');
      throw new WpException(
        400,
        "Empty request",
        "Bad request", 
        "Missing headers"
      )
    }

    console.log('✅ Headers found, proceeding to processGetUser...');
    return this.processGetUser(supabaseClient, request)
  }

  private async processGetUser(supabaseClient: any, request: Request): Promise<FnResponse> {
    console.log('🚨 processGetUser called - PRODUCTION VERSION');

    // Extraer el token JWT de WordPress de los headers
    let wpToken = request.headers.get('X-WordPress-Token');

    // Si no está en X-WordPress-Token, intentar obtenerlo de Authorization
    if (!wpToken) {
      const authHeader = request.headers.get('Authorization');
      console.log('🔍 Authorization header:', authHeader);

      // Si el Authorization no es el token de Supabase, usarlo
      if (authHeader && !authHeader.includes('sb_publishable')) {
        wpToken = authHeader.replace('Bearer ', '').trim();
      }
    }

    if (!wpToken) {
      console.log('❌ No WordPress token found in headers');
      console.log('Available headers:', Object.fromEntries(
        Array.from(request.headers.entries())
      ));
      throw new WpException(
        401,
        "Missing WordPress token",
        "Unauthorized",
        "X-WordPress-Token header is required"
      );
    }

    console.log('✅ WordPress token found (first 30 chars):', wpToken.substring(0, 30) + '...');
    console.log('📤 Fetching user data from WordPress...');

    try {
      // 0. ⚡ SINCRONIZAR MEMBERSHIP LEVELS DESDE WORDPRESS
      console.log('🔄 Syncing membership catalog from WordPress...')
      try {
        const syncResult = await syncMembershipCatalog()
        console.log(`✅ Membership catalog synced: ${syncResult.stats?.created || 0} created, ${syncResult.stats?.updated || 0} updated, ${syncResult.stats?.total || 0} total`)
      } catch (syncError) {
        console.error('⚠️ Error syncing membership catalog (non-fatal):', syncError)
        // No lanzamos error para que el get user continúe
      }

      // 1. Obtener datos básicos del usuario desde WordPress
      const wpClient = new WordPressClient();
      const wpUserData = await wpClient.getUser(wpToken);

      console.log('✅ User data retrieved from WordPress:', wpUserData);

      // 2. ⭐ SINCRONIZAR/CREAR usuario en Supabase SIEMPRE
      // Esta función garantiza que el usuario existe en Supabase
      // Si no existe, lo crea con academy_id = 1 y specialty por defecto
      const wpUserDataFormatted: WordPressUserData = {
        id: wpUserData.id,
        username: wpUserData.username,
        email: wpUserData.email,
        firstName: wpUserData.firstName,
        lastName: wpUserData.lastName
      };

      const completeUserData = await ensureUserInSupabase(
        supabaseClient,
        wpUserDataFormatted
      );

      console.log('✅ Complete user data from Supabase:', {
        id: completeUserData.id,
        email: completeUserData.email,
        academy_id: completeUserData.academy_id,
        specialty_id: completeUserData.specialty_id,
        memberships: completeUserData.user_memberships?.length || 0
      });

      // 3. SINCRONIZAR MEMBRESÍAS DESDE WORDPRESS
      console.log(`🔄 Syncing memberships for user ${wpUserData.id}...`)
      let membershipsSynced = 0
      try {
        // Usar token de administrador para consultar membresías
        const wpClientForAdmin = new WPClient(supabaseClient)
        const adminToken = await wpClientForAdmin.getAdminToken()
        const syncResult = await syncUserMemberships(wpUserData.id, adminToken)
        membershipsSynced = syncResult.synced
        console.log(`✅ Memberships synced: ${membershipsSynced} (created: ${syncResult.created}, updated: ${syncResult.updated}, deactivated: ${syncResult.deactivated})`)
      } catch (membershipError) {
        console.error('⚠️ Error syncing memberships (non-fatal):', membershipError)
        // No lanzamos el error para que el get user continúe
      }

      // 4. Obtener datos completos actualizados después de sincronizar membresías
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

      // 5. Devolver datos completos (SIEMPRE incluye membresías sincronizadas)
      return this.jsonResponse({
        success: true,
        user: finalUserData || completeUserData,
        memberships_synced: membershipsSynced
      });
    } catch (error) {
      console.log('💥 Error getting user:', error);

      if (error instanceof WpException) {
        throw error;
      }

      throw new WpException(
        500,
        "Failed to get user",
        "Internal Server Error",
        error instanceof Error ? error.message : String(error)
      );
    }
  }
}

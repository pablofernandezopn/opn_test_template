// api/v1/revenuecat_webhook.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { RequestHandler } from '../../framework/request_handler.ts'
import { FnResponse } from '../../framework/fn_response.ts'
import { WpException } from '../../wp_client/model/wp_exception.ts'
import { Membership } from '../../wp_client/model/membership.ts'
import { MembershipLevel } from '../../wp_client/model/membership_level.ts'
import { WPClient } from '../../wp_client/wp_client.ts'

type SupabaseClient = ReturnType<typeof createClient>

interface Subscription {
  expires_date?: string
  purchase_date?: string
  is_sandbox?: boolean
}

export class WpRevenueCatWebhook extends RequestHandler {
  async handle(
    supabaseClient: SupabaseClient,
    request: Request
  ): Promise<FnResponse> {
    // Verificar autenticación del webhook de RevenueCat
    const authHeader = request.headers.get('Authorization')
    
    if (!authHeader) {
      throw new WpException(401, "Unauthorized", "Unauthorized", null)
    }

    const rcWebhookSecret = Deno.env.get('RC_WEBHOOK_SECRET')
    
    if (!rcWebhookSecret || authHeader !== rcWebhookSecret) {
      throw new WpException(401, "Unauthorized", "Unauthorized", null)
    }

    const body = await this.parseJsonBody(request)
    
    if (!body) {
      throw new WpException(400, "Invalid JSON body", "Bad request", null)
    }

    return this.processWebhook(supabaseClient, body)
  }

  private async processWebhook(
    supabaseClient: SupabaseClient,
    body: Record<string, any>
  ): Promise<FnResponse> {
    if (!body.event) {
      return new FnResponse(
        "Unrecognized operation",
        { headers: { "Processed": "false" } }
      )
    }

    const event = body.event as Record<string, any>
    
    if (!event.app_user_id) {
      return new FnResponse(
        "Wrong environment, ignoring request",
        { headers: { "Processed": "false" } }
      )
    }

    const userId = event.app_user_id as string
    const apiKey = Deno.env.get('RC_SECRET_API_KEY_V1') || ""
    const isSandbox = event.environment === 'SANDBOX'

    try {
      // Obtener información del suscriptor desde RevenueCat
      const responseMap = await this.getRCSubscriberInfo(userId, apiKey, isSandbox)
      const rcSubscriptions: Record<string, string> = {}
      
      rcSubscriptions['__rc_subscriber_info_response'] = JSON.stringify(responseMap)

      const subscriber = responseMap.subscriber
      const subscriptions = subscriber.subscriptions as Record<string, any>

      // Obtener token de administrador de WordPress
      const wpClient = new WPClient(supabaseClient)
      const token = await wpClient.getAdminToken()

      // Obtener todos los tipos de membresía activos
      const membershipTypes = await this.getAllActiveMembershipTypes(supabaseClient)

      // Obtener cliente de RCP
      const customer = await wpClient.getCustomer(token, {
        userId,
        membershipTypes,
        onlyActives: false,
      })

      if (!subscriptions || Object.keys(subscriptions).length === 0) {
        rcSubscriptions['__rc_subscriber_subscriptions'] = 'No subscriptions found in RevenueCat'
      } else {
        rcSubscriptions['__rc_subscriber_subscriptions'] = 
          `Subscriptions found in RevenueCat: ${Object.keys(subscriptions).join(', ')}`
      }

      // Procesar suscripciones de RevenueCat
      for (const productId of Object.keys(subscriptions)) {
        const subscription = subscriptions[productId] as Subscription
        let status = "pending"

        try {
          // Buscar el nivel de membresía por product ID
          const membershipLevel = await this.getMembershipLevelByProductId(supabaseClient, productId)
          
          if (!membershipLevel) {
            status = "unknown"
          } else {
            // Verificar si esta suscripción existe en RCP
            const existingMembership = customer.memberships.find(m => 
              m.membershipLevel?.rcpId === membershipLevel.rcpId
            )

            if (existingMembership) {
              // Sincronizar estado entre RevenueCat y RCP
              await this.syncSubscriptionState(supabaseClient, token, subscription, existingMembership, isSandbox)
              status = "synced"
            } else {
              // Agregar suscripción a RCP
              await this.addSubscriptionToRcp(supabaseClient, token, customer.id, membershipLevel, subscription, isSandbox)
              status = "added"
            }
          }
        } catch (error) {
          status = `error: ${error instanceof Error ? error.message : String(error)}`
        }

        rcSubscriptions[productId] = status
      }

      // Procesar membresías de RCP
      const rcpSubscriptions: Record<string, string> = {}

      for (const membership of customer.memberships) {
        let status = "pending"
        
        try {
          const membershipProductIds = membership.membershipLevel?.revenueCatProductIds || []
          
          if (membershipProductIds.length === 0) {
            status = "unknown"
          } else {
            const hasActiveSubscription = membershipProductIds.some(productId => 
              subscriptions.hasOwnProperty(productId)
            )

            if (!hasActiveSubscription) {
              // Cancelar membresía en RCP
              if (membership.id) {
                await this.cancelMembershipFromRcp(supabaseClient, token, membership)
                status = "cancelled"
              }
            } else {
              status = "synced"
            }
          }
        } catch (error) {
          status = `error: ${error instanceof Error ? error.message : String(error)}`
        }

        const firstProductId = membership.membershipLevel?.revenueCatProductIds?.[0] || "unknown"
        rcpSubscriptions[firstProductId] = status
      }

      return new FnResponse(
        {
          customerId: customer.id,
          revenuecat: rcSubscriptions,
          restrict_content_pro: rcpSubscriptions,
        },
        {
          headers: { ...RequestHandler.jsonHeaders, "Processed": "true" }
        }
      )

    } catch (error) {
      console.error('Error processing webhook:', error)
      throw new WpException(
        503,
        "Request cannot be processed",
        "Internal Server Error",
        JSON.stringify({
          error: error instanceof Error ? error.message : String(error),
          stack: error instanceof Error ? error.stack : undefined,
        })
      )
    }
  }

  private async getRCSubscriberInfo(
    appUserId: string,
    apiKey: string,
    isSandbox: boolean
  ): Promise<any> {
    const url = `https://api.revenuecat.com/v1/subscribers/${appUserId}`
    const headers: Record<string, string> = {
      'Authorization': `Bearer ${apiKey}`,
    }

    if (isSandbox) {
      headers['X-Is-Sandbox'] = 'true'
    }

    const response = await fetch(url, { headers })

    if (response.status === 200 || response.status === 201) {
      return await response.json()
    } else {
      throw new Error(`${response.status} ${response.statusText}`)
    }
  }

  private async syncSubscriptionState(
    supabaseClient: SupabaseClient,
    token: string,
    subscription: Subscription,
    membership: Membership,
    isSandbox: boolean
  ): Promise<void> {
    let expiresDate: Date | undefined

    if (subscription.expires_date) {
      expiresDate = new Date(subscription.expires_date)
      if (isSandbox) {
        expiresDate.setDate(expiresDate.getDate() + 1)
      }
    }

    const isActive = !expiresDate || new Date() < expiresDate
    const renewedDate = subscription.purchase_date ? new Date(subscription.purchase_date) : undefined

    const updatedMembership = membership.copyWith({
      status: isActive ? "active" : "expired",
      renewedDate,
      expirationDate: expiresDate,
    })

    const wpClient = new WPClient(supabaseClient)
    await wpClient.updateMembership(token, updatedMembership)
  }

  private async addSubscriptionToRcp(
    supabaseClient: SupabaseClient,
    token: string,
    customerId: string,
    membershipLevel: MembershipLevel,
    subscription: Subscription,
    isSandbox: boolean
  ): Promise<void> {
    let expiresDate: Date | undefined

    if (subscription.expires_date) {
      expiresDate = new Date(subscription.expires_date)
      if (isSandbox) {
        expiresDate.setDate(expiresDate.getDate() + 1)
      }
    }

    const isActive = !expiresDate || new Date() < expiresDate
    const renewedDate = subscription.purchase_date ? new Date(subscription.purchase_date) : undefined

    const membership = new Membership(false, isActive ? "active" : "expired", false)
    membership.customerId = customerId
    membership.membershipLevel = membershipLevel
    membership.expirationDate = expiresDate
    membership.renewedDate = renewedDate

    const wpClient = new WPClient(supabaseClient)
    await wpClient.createMembership(token, membership)
  }

  private async cancelMembershipFromRcp(
    supabaseClient: SupabaseClient,
    token: string,
    membership: Membership
  ): Promise<void> {
    if (!membership.id) return

    const wpClient = new WPClient(supabaseClient)
    await wpClient.cancelMembership(token, membership.id)
  }

  private async getAllActiveMembershipTypes(supabaseClient: SupabaseClient): Promise<string[]> {
    const { data, error } = await supabaseClient
      .from('membership_levels')
      .select('wordpress_rcp_id')
      .eq('is_active', true)

    if (error) {
      throw new Error(`Error fetching membership types: ${error.message}`)
    }

    return data.map((item: any) => String(item.wordpress_rcp_id))
  }

  private async getMembershipLevelByProductId(
    supabaseClient: SupabaseClient,
    productId: string
  ): Promise<MembershipLevel | null> {
    const { data, error } = await supabaseClient
      .from('membership_levels')
      .select('*')
      .contains('revenue_cat_product_ids', [productId])
      .eq('is_active', true)
      .limit(1)
      .maybeSingle()

    if (error) {
      console.error(`Error fetching membership level by product ID: ${error.message}`)
      return null
    }

    return data ? MembershipLevel.fromJson(data) : null
  }
}
// api/v1_api_router.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { APIRouter } from '../framework/api_router.ts'
import { FnResponse } from '../framework/fn_response.ts'
import { RequestHandler } from '../framework/request_handler.ts'
import { WpException } from '../wp_client/model/wp_exception.ts'
import { CorsHandler } from './v1/cors_handler.ts'
import { WPLogin } from './v1/login.ts'
import { WpGetUser } from './v1/get_user.ts'
import { WPRegister } from './v1/register.ts'
import { WpRevenueCatWebhook } from './v1/revenuecat_webhook.ts'
import { UpdateMembershipCatalogHandler } from './v1/update_membership_catalog.ts'
import { syncMembershipCatalog } from './v1/sync_membership_catalog.ts'
import { DeleteAccountHandler } from './v1/delete_account.ts'

type SupabaseClient = ReturnType<typeof createClient>

export class V1APIRouter extends APIRouter {
  constructor(supabaseClient: SupabaseClient) {
    super(supabaseClient)
  }

  async handle(request: Request): Promise<Response> {
    const path = this.getPath(request)
    const method = request.method

    let fnResponse: FnResponse

    try {
      if (method === 'OPTIONS') {
        // Manejo de CORS preflight request
        const corsHandler = new CorsHandler()
        fnResponse = await corsHandler.handle(this.supabaseClient, request)
      } else {
        const routeKey = `${method}:${path}`
        
        switch (routeKey) {
          case 'GET:version':
            fnResponse = new FnResponse(
              { version: this.getApiVersion() },
              { 
                headers: RequestHandler.jsonHeaders,
                status: 200 
              }
            )
            break

          case 'POST:login':
            const loginHandler = new WPLogin()
            fnResponse = await loginHandler.handle(this.supabaseClient, request)
            break

          case 'POST:get_user':
            const getUserHandler = new WpGetUser()
            fnResponse = await getUserHandler.handle(this.supabaseClient, request)
            break

          case 'POST:register':
            const registerHandler = new WPRegister()
            fnResponse = await registerHandler.handle(this.supabaseClient, request)
            break

          case 'POST:revenuecat':
            const revenueCatHandler = new WpRevenueCatWebhook()
            fnResponse = await revenueCatHandler.handle(this.supabaseClient, request)
            break

          case 'POST:update_membership_catalog':
            const updateCatalogHandler = new UpdateMembershipCatalogHandler()
            fnResponse = await updateCatalogHandler.handle(this.supabaseClient, request)
            break

          case 'POST:sync_membership_catalog':
            const syncResult = await syncMembershipCatalog()
            fnResponse = new FnResponse(
              syncResult,
              {
                headers: RequestHandler.jsonHeaders,
                status: 200
              }
            )
            break

          case 'POST:delete_account':
            const deleteAccountHandler = new DeleteAccountHandler()
            fnResponse = await deleteAccountHandler.handle(this.supabaseClient, request)
            break

          default:
            const notFoundError = new WpException(
              404,
              "Resource not found",
              "Not found",
              'Resource not found'
            )
            fnResponse = new FnResponse(
              notFoundError.toJson(),
              {
                headers: RequestHandler.jsonHeaders,
                status: 404,
                statusText: "Not found"
              }
            )
        }
      }

      // Aplicar headers CORS a la respuesta
      return CorsHandler.buildResponse(request, fnResponse)

    } catch (error) {
      console.error('Error in V1APIRouter:', error)
      const errorResponse = this.handleExceptions(request, error)
      return CorsHandler.buildResponse(request, errorResponse)
    }
  }

  getApiVersion(): string {
    return "v1"
  }

  private handleExceptions(request: Request, error: unknown): FnResponse {
    let wpException: WpException

    if (error instanceof WpException) {
      wpException = error
    } else if (error instanceof Error) {
      console.warn("Unknown exception type:", error.constructor.name)
      wpException = new WpException(
        500,
        "Unknown error",
        "Internal Server Error",
        JSON.stringify({
          error: error.message,
          stack: error.stack
        })
      )
    } else {
      console.warn("Unknown exception type:", typeof error)
      wpException = new WpException(
        500,
        "Unknown error",
        "Internal Server Error",
        JSON.stringify({
          error: String(error)
        })
      )
    }

    const status = wpException.status
    const reason = wpException.reason
    const responseBody = wpException.toJson()

    console.error(
      `ERROR: Request: ${request.method} ${request.url} -> ${status} - ${reason}\nResponse:`,
      responseBody
    )

    return new FnResponse(
      responseBody,
      {
        status,
        statusText: reason,
        headers: RequestHandler.jsonHeaders
      }
    )
  }
}
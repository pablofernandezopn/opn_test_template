// api/v1/cors_handler.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { RequestHandler } from '../../framework/request_handler.ts'
import { FnResponse } from '../../framework/fn_response.ts'

type SupabaseClient = ReturnType<typeof createClient>

export class CorsHandler extends RequestHandler {
  static get corsOrigins(): string {
    return Deno.env.get('CORS_ORIGINS') || '*'
  }

  static get corsMethods(): string {
    return Deno.env.get('CORS_METHODS') || 'GET,POST,PUT,DELETE,OPTIONS'
  }

  static get corsHeaders(): string {
    return Deno.env.get('CORS_HEADERS') || 'authorization,content-type,x-client-info'
  }

  async handle(
    supabaseClient: SupabaseClient,
    request: Request
  ): Promise<FnResponse> {
    const corsOriginsList = CorsHandler.corsOrigins.split(',')
    
    // Revisar 'Origin' header
    const origin = request.headers.get('Origin')
    
    if (!origin) {
      return new FnResponse(
        'Origin header missing',
        { status: 400 }
      )
    }

    // Revisar si el origin está permitido
    if (CorsHandler.corsOrigins === '*' || corsOriginsList.includes(origin)) {
      const corsHeadersMap = {
        'Access-Control-Allow-Origin': origin,
        'Access-Control-Allow-Methods': CorsHandler.corsMethods,
        'Access-Control-Allow-Headers': CorsHandler.corsHeaders,
      }
      
      return new FnResponse(null, { 
        status: 200, 
        headers: corsHeadersMap 
      })
    } else {
      return new FnResponse(
        'Origin not allowed',
        { status: 403 }
      )
    }
  }

  static buildResponse(request: Request, provisionalResponse: FnResponse): Response {
    const corsOriginsList = CorsHandler.corsOrigins.split(',')
    let response = provisionalResponse

    // Solo agregar CORS headers en requests que no sean OPTIONS
    if (request.method !== 'OPTIONS') {
      const origin = request.headers.get('Origin')
      
      if (origin && (CorsHandler.corsOrigins === '*' || corsOriginsList.includes(origin))) {
        const corsHeadersMap = { ...provisionalResponse.headers }
        corsHeadersMap['Access-Control-Allow-Origin'] = origin

        response = new FnResponse(
          provisionalResponse.body,
          {
            headers: corsHeadersMap,
            status: provisionalResponse.status,
            statusText: provisionalResponse.statusText,
          }
        )
      }
    }

    return response.toResponse()
  }
}
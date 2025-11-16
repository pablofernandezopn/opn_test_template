// framework/request_handler.ts
import { createClient } from 'jsr:@supabase/supabase-js@2';

type SupabaseClient = ReturnType<typeof createClient>;
import { FnResponse } from './fn_response.ts';

export abstract class RequestHandler {
  abstract handle(
    supabaseClient: SupabaseClient,
    request: Request
  ): Promise<FnResponse>;

  protected extractTokenFromHeader(authHeader: string): string | null {
    const regex = /Bearer (.+)/;
    const match = authHeader.match(regex);
    
    if (match && match.length >= 2) {
      return match[1];
    }
    
    return null;
  }

  public static get jsonHeaders(): Record<string, string> {
    return {
      "Content-Type": "application/json",
    };
  }

  // Helper para extraer el token de autorización de la request
  protected extractAuthToken(request: Request): string | null {
    const authHeader = request.headers.get('Authorization');
    if (!authHeader) {
      return null;
    }
    return this.extractTokenFromHeader(authHeader);
  }

  // Helper para parsear el body JSON de la request
  protected async parseJsonBody<T = any>(request: Request): Promise<T | null> {
    try {
      const contentType = request.headers.get('Content-Type');
      if (contentType?.includes('application/json')) {
        return await request.json() as T;
      }
    } catch (error) {
      console.error('Error parsing JSON body:', error);
    }
    return null;
  }

  // Helper para crear respuestas JSON exitosas
  protected jsonResponse(data: any, status: number = 200): FnResponse {
    return new FnResponse(data, {
      headers: RequestHandler.jsonHeaders,
      status,
    });
  }

  // Helper para crear respuestas de error
  protected errorResponse(
    message: string, 
    status: number = 400, 
    code?: string
  ): FnResponse {
    const errorBody = {
      error: message,
      ...(code && { code }),
    };
    
    return new FnResponse(errorBody, {
      headers: RequestHandler.jsonHeaders,
      status,
    });
  }
}
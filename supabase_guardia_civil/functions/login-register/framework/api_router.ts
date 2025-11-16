// framework/api_router.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { extractPath, extractConcretePath } from './request_utils.ts'

type SupabaseClient = ReturnType<typeof createClient>

export abstract class APIRouter {
  protected supabaseClient: SupabaseClient;

  constructor(supabaseClient: SupabaseClient) {
    this.supabaseClient = supabaseClient;
  }

  async masterHandle(request: Request): Promise<Response> {
    try {
      return await this.handle(request);
    } catch (error) {
      console.error('Error in API router:', error);
      
      return new Response(
        JSON.stringify({
          error: 'Internal server error',
          message: error instanceof Error ? error.message : 'Unknown error'
        }),
        {
          status: 500,
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }
  }

  protected getPath(request: Request): string {
    const fullPath = extractPath(request);
    return extractConcretePath(this.getApiVersion(), fullPath);
  }

  abstract handle(request: Request): Promise<Response>;
  abstract getApiVersion(): string;
}
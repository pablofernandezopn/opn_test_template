// index.ts - Main entry point (SIMPLIFIED)
console.log('🚀 Starting WordPress login-register function...')

import { createClient } from 'jsr:@supabase/supabase-js@2'
import { V1APIRouter } from './api/v1_api_router.ts'

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json"
}

// Extract API version from request
function extractApiVersion(request: Request): string {
  const url = new URL(request.url)
  const pathname = url.pathname
  
  // Remove /login-register/ prefix
  const loginRegisterPrefix = "/login-register/"
  const prefixIndex = pathname.indexOf(loginRegisterPrefix)
  
  let path: string
  if (prefixIndex !== -1) {
    path = pathname.substring(prefixIndex + loginRegisterPrefix.length)
  } else {
    path = pathname.startsWith('/') ? pathname.substring(1) : pathname
  }
  
  // Extract version (e.g., "v1" from "v1/login")
  if (path.includes('/')) {
    return path.split('/')[0]
  }
  
  throw new Error("Invalid request without API version")
}

// Main handler
Deno.serve(async (request: Request) => {
  try {
    console.log(`📨 ${request.method} ${request.url}`)
    
    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: corsHeaders
      })
    }
    
    // Create Supabase client with service role key
    // No usamos el Authorization header del request porque causaría problemas con JWT
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )
    
    // Get API version and delegate to router
    const apiVersion = extractApiVersion(request)
    
    if (apiVersion === 'v1') {
      const router = new V1APIRouter(supabaseClient)
      return await router.handle(request)
    }
    
    // Unknown API version
    return new Response(
      JSON.stringify({ 
        error: 'API version not found', 
        version: apiVersion 
      }),
      {
        status: 404,
        headers: corsHeaders
      }
    )
    
  } catch (error) {
    console.error('❌ Error in main handler:', error)
    const errorMessage = error instanceof Error ? error.message : String(error)
    
    return new Response(
      JSON.stringify({ 
        error: 'Internal Server Error',
        details: errorMessage
      }),
      {
        status: 500,
        headers: corsHeaders
      }
    )
  }
})

console.log('✅ WordPress function loaded successfully!')

// send-push-notification/index.ts
// Edge Function para enviar notificaciones push a usuarios específicos usando Firebase Cloud Messaging
console.log('🚀 Starting send-push-notification function...')

import { createClient } from 'jsr:@supabase/supabase-js@2'

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json"
}

// Tipos para el request
interface PushNotificationRequest {
  user_id: number
  title: string
  body: string
  image_url?: string  // URL de la imagen (opcional)
  data?: Record<string, string>  // Datos adicionales (opcional)
  // Campos opcionales para navegación
  route?: string  // Ruta para navegar cuando se toca la notificación
}

// Tipo de respuesta de Firebase
interface FCMResponse {
  name?: string
  error?: {
    code: number
    message: string
    status: string
  }
}

// Obtener Access Token de Firebase usando Service Account
async function getFirebaseAccessToken(): Promise<string> {
  try {
    // Obtener las credenciales del Service Account desde variables de entorno
    const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON')

    if (!serviceAccountJson) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT_JSON not found in environment variables')
    }

    const serviceAccount = JSON.parse(serviceAccountJson)

    // Crear JWT para solicitar access token
    const now = Math.floor(Date.now() / 1000)
    const expiry = now + 3600 // Token válido por 1 hora

    const header = {
      alg: 'RS256',
      typ: 'JWT',
      kid: serviceAccount.private_key_id
    }

    const payload = {
      iss: serviceAccount.client_email,
      sub: serviceAccount.client_email,
      aud: 'https://oauth2.googleapis.com/token',
      iat: now,
      exp: expiry,
      scope: 'https://www.googleapis.com/auth/firebase.messaging'
    }

    // Importar la clave privada
    const pemKey = serviceAccount.private_key
    const privateKey = await crypto.subtle.importKey(
      'pkcs8',
      pemToBinary(pemKey),
      {
        name: 'RSASSA-PKCS1-v1_5',
        hash: 'SHA-256',
      },
      false,
      ['sign']
    )

    // Firmar el JWT
    const encodedHeader = base64UrlEncode(JSON.stringify(header))
    const encodedPayload = base64UrlEncode(JSON.stringify(payload))
    const signatureInput = `${encodedHeader}.${encodedPayload}`

    const signatureBuffer = await crypto.subtle.sign(
      'RSASSA-PKCS1-v1_5',
      privateKey,
      new TextEncoder().encode(signatureInput)
    )

    const signature = base64UrlEncode(signatureBuffer)
    const jwt = `${signatureInput}.${signature}`

    // Intercambiar JWT por Access Token
    const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt
      })
    })

    if (!tokenResponse.ok) {
      const error = await tokenResponse.text()
      throw new Error(`Failed to get access token: ${error}`)
    }

    const tokenData = await tokenResponse.json()
    return tokenData.access_token

  } catch (error) {
    console.error('❌ Error getting Firebase access token:', error)
    throw error
  }
}

// Funciones helper para JWT
function pemToBinary(pem: string): ArrayBuffer {
  const pemContent = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s/g, '')

  return Uint8Array.from(atob(pemContent), c => c.charCodeAt(0)).buffer
}

function base64UrlEncode(data: string | ArrayBuffer): string {
  let base64: string

  if (typeof data === 'string') {
    base64 = btoa(data)
  } else {
    const uint8Array = new Uint8Array(data)
    base64 = btoa(String.fromCharCode(...uint8Array))
  }

  return base64
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '')
}

// Enviar notificación push usando FCM API v1
async function sendFCMNotification(
  fcmToken: string,
  notification: PushNotificationRequest
): Promise<FCMResponse> {
  try {
    console.log('📱 Sending FCM notification...')

    // Obtener access token
    const accessToken = await getFirebaseAccessToken()

    // Obtener Project ID desde service account
    const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON')
    const serviceAccount = JSON.parse(serviceAccountJson!)
    const projectId = serviceAccount.project_id

    // Construir el mensaje de FCM
    const message: any = {
      token: fcmToken,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        }
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            'content-available': 1,
          }
        }
      }
    }

    // Agregar imagen si está presente
    if (notification.image_url) {
      message.notification.image = notification.image_url
      // Para Android
      message.android.notification.image = notification.image_url
      // Para iOS (APNS)
      if (!message.apns.payload.aps['mutable-content']) {
        message.apns.payload.aps['mutable-content'] = 1
      }
      message.apns.fcm_options = {
        image: notification.image_url
      }
    }

    // Agregar datos personalizados si están presentes
    if (notification.data || notification.route) {
      message.data = {
        ...(notification.data || {}),
        ...(notification.route ? { route: notification.route } : {})
      }
    }

    // Enviar a FCM API v1
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`

    const response = await fetch(fcmUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ message })
    })

    const responseData = await response.json()

    if (!response.ok) {
      console.error('❌ FCM Error:', responseData)
      throw new Error(`FCM Error: ${responseData.error?.message || 'Unknown error'}`)
    }

    console.log('✅ Notification sent successfully:', responseData.name)
    return responseData

  } catch (error) {
    console.error('❌ Error sending FCM notification:', error)
    throw error
  }
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

    // Solo permitir POST
    if (request.method !== 'POST') {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Method not allowed. Use POST.'
        }),
        {
          status: 405,
          headers: corsHeaders
        }
      )
    }

    // Parsear el body del request
    const requestData: PushNotificationRequest = await request.json()

    // Validar campos requeridos
    if (!requestData.user_id || !requestData.title || !requestData.body) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Missing required fields: user_id, title, body'
        }),
        {
          status: 400,
          headers: corsHeaders
        }
      )
    }

    // Crear cliente de Supabase con service role key
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Obtener el FCM token del usuario desde la base de datos
    console.log(`🔍 Looking for FCM token for user ${requestData.user_id}`)

    const { data: userData, error: userError } = await supabaseClient
      .from('users')
      .select('fcm_token, username, email')
      .eq('id', requestData.user_id)
      .single()

    if (userError || !userData) {
      console.error('❌ User not found:', userError)
      return new Response(
        JSON.stringify({
          success: false,
          error: 'User not found'
        }),
        {
          status: 404,
          headers: corsHeaders
        }
      )
    }

    if (!userData.fcm_token) {
      console.warn('⚠️ User does not have FCM token')
      return new Response(
        JSON.stringify({
          success: false,
          error: 'User does not have a FCM token. The app may not be installed or notifications are disabled.'
        }),
        {
          status: 400,
          headers: corsHeaders
        }
      )
    }

    console.log(`✅ Found FCM token for user ${userData.username}`)

    // Enviar la notificación
    const fcmResponse = await sendFCMNotification(userData.fcm_token, requestData)

    // Opcional: Guardar registro de la notificación enviada
    try {
      await supabaseClient
        .from('notification_logs')
        .insert({
          user_id: requestData.user_id,
          title: requestData.title,
          body: requestData.body,
          image_url: requestData.image_url,
          fcm_response: fcmResponse,
          sent_at: new Date().toISOString()
        })
    } catch (logError) {
      console.warn('⚠️ Failed to log notification:', logError)
      // No fallar si el log falla (la tabla puede no existir)
    }

    // Respuesta exitosa
    return new Response(
      JSON.stringify({
        success: true,
        message: 'Notification sent successfully',
        fcm_message_id: fcmResponse.name,
        user: {
          id: requestData.user_id,
          username: userData.username,
          email: userData.email
        }
      }),
      {
        status: 200,
        headers: corsHeaders
      }
    )

  } catch (error) {
    console.error('❌ Error in main handler:', error)
    const errorMessage = error instanceof Error ? error.message : String(error)

    return new Response(
      JSON.stringify({
        success: false,
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

console.log('✅ send-push-notification function loaded successfully!')
// scheduled-topic-notifications/index.ts
// Cron Job que revisa topics con publishAt y envía notificaciones automáticamente
console.log('🚀 Starting scheduled-topic-notifications function...')

import { createClient } from 'jsr:@supabase/supabase-js@2'

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json"
}

interface Topic {
  id: number
  topic_name: string
  publish_at: string | null
  notification_sent_at: string | null
  image_url: string | null
  total_questions: number
  duration_minutes: number
  is_premium: boolean
  academy_id: number
}

interface TopicGroup {
  id: number
  name: string
  publish_at: string | null
  notification_sent_at: string | null
  image_url: string | null
  academy_id: number
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

    // Crear cliente de Supabase con service role key
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const now = new Date().toISOString()
    console.log(`⏰ Checking for topics to publish at: ${now}`)

    // ==========================================
    // 1. BUSCAR TOPICS PARA PUBLICAR
    // ==========================================

    const { data: topicsToPublish, error: topicsError } = await supabaseClient
      .from('topics')
      .select('*')
      .not('publish_at', 'is', null)
      .lte('publish_at', now)
      .is('notification_sent_at', null)
      .order('publish_at', { ascending: true })

    if (topicsError) {
      console.error('❌ Error fetching topics:', topicsError)
      throw topicsError
    }

    console.log(`📋 Found ${topicsToPublish?.length || 0} topics to publish`)

    // ==========================================
    // 2. BUSCAR TOPIC GROUPS PARA PUBLICAR
    // ==========================================

    const { data: groupsToPublish, error: groupsError } = await supabaseClient
      .from('topic_groups')
      .select('*')
      .not('publish_at', 'is', null)
      .lte('publish_at', now)
      .is('notification_sent_at', null)
      .order('publish_at', { ascending: true })

    if (groupsError) {
      console.error('❌ Error fetching topic groups:', groupsError)
      throw groupsError
    }

    console.log(`📋 Found ${groupsToPublish?.length || 0} topic groups to publish`)

    const results = {
      topics: {
        total: topicsToPublish?.length || 0,
        success: 0,
        failed: 0,
        details: [] as any[]
      },
      topicGroups: {
        total: groupsToPublish?.length || 0,
        success: 0,
        failed: 0,
        details: [] as any[]
      }
    }

    // ==========================================
    // 3. ENVIAR NOTIFICACIONES PARA TOPICS
    // ==========================================

    if (topicsToPublish && topicsToPublish.length > 0) {
      for (const topic of topicsToPublish as Topic[]) {
        try {
          console.log(`📤 Processing topic: ${topic.topic_name} (ID: ${topic.id})`)

          // Obtener usuarios para notificar
          const userIds = await getUsersToNotify(supabaseClient, topic.academy_id, topic.is_premium)

          if (userIds.length === 0) {
            console.log(`⚠️ No users to notify for topic ${topic.id}`)
            results.topics.details.push({
              topic_id: topic.id,
              topic_name: topic.topic_name,
              status: 'skipped',
              reason: 'no_users'
            })
            continue
          }

          console.log(`📤 Sending notifications to ${userIds.length} users for topic ${topic.id}`)

          // Enviar notificaciones a todos los usuarios
          const notificationResults = await sendNotificationsToUsers(
            supabaseClient,
            userIds,
            {
              title: '📝 Nuevo test disponible',
              body: `${topic.topic_name} - ${topic.total_questions} preguntas | ${topic.duration_minutes} min`,
              image_url: topic.image_url,
              route: `/preview-topic/${topic.id}`,
              data: {
                topic_id: topic.id.toString(),
                topic_name: topic.topic_name,
                type: 'scheduled_topic_publish'
              }
            }
          )

          // Marcar topic como notificado
          const { error: updateError } = await supabaseClient
            .from('topics')
            .update({ notification_sent_at: new Date().toISOString() })
            .eq('id', topic.id)

          if (updateError) {
            console.error(`❌ Error updating topic ${topic.id}:`, updateError)
          } else {
            console.log(`✅ Topic ${topic.id} marked as notified`)
          }

          results.topics.success++
          results.topics.details.push({
            topic_id: topic.id,
            topic_name: topic.topic_name,
            status: 'success',
            users_notified: notificationResults.success,
            users_failed: notificationResults.failed
          })

        } catch (error) {
          console.error(`❌ Error processing topic ${topic.id}:`, error)
          results.topics.failed++
          results.topics.details.push({
            topic_id: topic.id,
            topic_name: topic.topic_name,
            status: 'error',
            error: error instanceof Error ? error.message : String(error)
          })
        }
      }
    }

    // ==========================================
    // 4. ENVIAR NOTIFICACIONES PARA TOPIC GROUPS
    // ==========================================

    if (groupsToPublish && groupsToPublish.length > 0) {
      for (const group of groupsToPublish as TopicGroup[]) {
        try {
          console.log(`📤 Processing topic group: ${group.name} (ID: ${group.id})`)

          // Obtener usuarios para notificar
          const userIds = await getUsersToNotify(supabaseClient, group.academy_id, false)

          if (userIds.length === 0) {
            console.log(`⚠️ No users to notify for group ${group.id}`)
            results.topicGroups.details.push({
              group_id: group.id,
              group_name: group.name,
              status: 'skipped',
              reason: 'no_users'
            })
            continue
          }

          console.log(`📤 Sending notifications to ${userIds.length} users for group ${group.id}`)

          // Obtener información adicional del grupo (número de topics)
          const { data: topicsInGroup } = await supabaseClient
            .from('topics')
            .select('id')
            .eq('topic_group_id', group.id)

          const totalParts = topicsInGroup?.length || 0

          // Enviar notificaciones
          const notificationResults = await sendNotificationsToUsers(
            supabaseClient,
            userIds,
            {
              title: '🎯 Nuevo examen completo disponible',
              body: `${group.name}${totalParts > 0 ? ` - ${totalParts} partes` : ''}`,
              image_url: group.image_url,
              route: `/preview-topic-group/${group.id}`,
              data: {
                topic_group_id: group.id.toString(),
                group_name: group.name,
                type: 'scheduled_group_publish'
              }
            }
          )

          // Marcar grupo como notificado
          const { error: updateError } = await supabaseClient
            .from('topic_groups')
            .update({ notification_sent_at: new Date().toISOString() })
            .eq('id', group.id)

          if (updateError) {
            console.error(`❌ Error updating group ${group.id}:`, updateError)
          } else {
            console.log(`✅ Group ${group.id} marked as notified`)
          }

          results.topicGroups.success++
          results.topicGroups.details.push({
            group_id: group.id,
            group_name: group.name,
            status: 'success',
            users_notified: notificationResults.success,
            users_failed: notificationResults.failed
          })

        } catch (error) {
          console.error(`❌ Error processing group ${group.id}:`, error)
          results.topicGroups.failed++
          results.topicGroups.details.push({
            group_id: group.id,
            group_name: group.name,
            status: 'error',
            error: error instanceof Error ? error.message : String(error)
          })
        }
      }
    }

    // ==========================================
    // 5. RESPUESTA FINAL
    // ==========================================

    const summary = {
      timestamp: now,
      topics: {
        found: results.topics.total,
        success: results.topics.success,
        failed: results.topics.failed
      },
      topicGroups: {
        found: results.topicGroups.total,
        success: results.topicGroups.success,
        failed: results.topicGroups.failed
      },
      details: results
    }

    console.log('📊 Summary:', JSON.stringify(summary, null, 2))

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Scheduled notifications processed',
        summary
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

// ==========================================
// HELPER FUNCTIONS
// ==========================================

/**
 * Obtiene lista de usuarios a notificar según filtros
 */
async function getUsersToNotify(
  supabaseClient: any,
  academyId: number,
  isPremium: boolean
): Promise<number[]> {
  try {
    let query = supabaseClient
      .from('users')
      .select('id')
      .eq('academy_id', academyId)
      .not('fcm_token', 'is', null)

    // Si el topic es premium, solo notificar a usuarios premium
    if (isPremium) {
      query = query.eq('is_premium', true)
    }

    const { data, error } = await query

    if (error) {
      console.error('Error fetching users:', error)
      return []
    }

    return (data || []).map((user: any) => user.id)
  } catch (error) {
    console.error('Exception getting users:', error)
    return []
  }
}

/**
 * Envía notificaciones a una lista de usuarios
 */
async function sendNotificationsToUsers(
  supabaseClient: any,
  userIds: number[],
  notification: {
    title: string
    body: string
    image_url?: string | null
    route: string
    data: Record<string, string>
  }
): Promise<{ success: number; failed: number }> {
  let success = 0
  let failed = 0

  for (const userId of userIds) {
    try {
      const { data, error } = await supabaseClient.functions.invoke(
        'send-push-notification',
        {
          body: {
            user_id: userId,
            title: notification.title,
            body: notification.body,
            ...(notification.image_url && { image_url: notification.image_url }),
            route: notification.route,
            data: notification.data
          }
        }
      )

      if (error) {
        console.error(`Failed to send notification to user ${userId}:`, error)
        failed++
      } else {
        success++
      }

      // Pequeña pausa para no saturar
      await new Promise(resolve => setTimeout(resolve, 100))

    } catch (error) {
      console.error(`Exception sending notification to user ${userId}:`, error)
      failed++
    }
  }

  return { success, failed }
}

console.log('✅ scheduled-topic-notifications function loaded successfully!')
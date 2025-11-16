// api/v1/update_membership_catalog.ts
import { RequestHandler } from '../../framework/request_handler.ts'
import { FnResponse } from '../../framework/fn_response.ts'
import { WpException } from '../../wp_client/model/wp_exception.ts'
import { createClient } from 'jsr:@supabase/supabase-js@2'

type SupabaseClient = ReturnType<typeof createClient>

interface MembershipLevelUpdate {
  wordpress_rcp_id: number
  name: string
  access_level: number
  description?: string
}

/**
 * Endpoint: /api/v1/update-membership-catalog
 * Método: POST
 * 
 * Permite sincronizar manualmente los nombres de las membresías
 * desde WordPress hacia Supabase.
 * 
 * Ejemplo de payload:
 * {
 *   "levels": [
 *     {
 *       "wordpress_rcp_id": 1,
 *       "name": "Gratis",
 *       "access_level": 1,
 *       "description": "Acceso gratuito"
 *     }
 *   ]
 * }
 */
export class UpdateMembershipCatalogHandler extends RequestHandler {
  async handle(supabaseClient: SupabaseClient, request: Request): Promise<FnResponse> {
    return await updateMembershipCatalogInternal(request);
  }
}

const updateMembershipCatalogInternal = async (
  req: Request
): Promise<FnResponse> => {
  console.log('📋 [Update Membership Catalog] Starting catalog update...')

  try {
    // 1. Validar método
    if (req.method !== 'POST') {
      return {
        statusCode: 405,
        body: { error: 'Method Not Allowed' },
      }
    }

    // 2. Parsear body
    const body = await req.json()
    const { levels } = body as { levels?: MembershipLevelUpdate[] }

    if (!levels || !Array.isArray(levels) || levels.length === 0) {
      return {
        statusCode: 400,
        body: { error: 'Missing or empty "levels" array in request body' },
      }
    }

    console.log(`📦 Received ${levels.length} membership levels to update`)

    // 3. Crear cliente Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!supabaseUrl || !supabaseKey) {
      throw new Error('Missing Supabase configuration')
    }

    const supabaseClient = createClient(supabaseUrl, supabaseKey)

    // 4. Procesar cada nivel
    const results = {
      updated: 0,
      created: 0,
      errors: [] as string[],
    }

    for (const level of levels) {
      try {
        // Validar datos requeridos
        if (!level.wordpress_rcp_id || !level.name || !level.access_level) {
          results.errors.push(
            `Missing required fields for level: ${JSON.stringify(level)}`
          )
          continue
        }

        // Validar access_level
        if (level.access_level < 1 || level.access_level > 3) {
          results.errors.push(
            `Invalid access_level ${level.access_level} for ${level.name}. Must be 1, 2, or 3.`
          )
          continue
        }

        console.log(
          `🔍 Processing: ${level.name} (RCP ID: ${level.wordpress_rcp_id}, Access Level: ${level.access_level})`
        )

        // Verificar si ya existe
        const { data: existingLevel, error: checkError } = await supabaseClient
          .from('membership_levels')
          .select('id, name')
          .eq('wordpress_rcp_id', level.wordpress_rcp_id)
          .single()

        if (checkError && checkError.code !== 'PGRST116') {
          console.error('❌ Error checking existing level:', checkError)
          results.errors.push(
            `Error checking level ${level.wordpress_rcp_id}: ${checkError.message}`
          )
          continue
        }

        if (existingLevel) {
          // Actualizar nivel existente
          console.log(
            `📝 Updating existing level: ${existingLevel.name} → ${level.name}`
          )

          const updateData: Record<string, unknown> = {
            name: level.name,
            access_level: level.access_level,
            updated_at: new Date().toISOString(),
          }

          if (level.description) {
            updateData.description = level.description
          }

          const { error: updateError } = await supabaseClient
            .from('membership_levels')
            .update(updateData)
            .eq('id', existingLevel.id)

          if (updateError) {
            console.error('❌ Error updating level:', updateError)
            results.errors.push(
              `Error updating level ${level.wordpress_rcp_id}: ${updateError.message}`
            )
            continue
          }

          console.log(`✅ Updated: ${level.name}`)
          results.updated++
        } else {
          // Crear nuevo nivel
          console.log(`➕ Creating new level: ${level.name}`)

          const insertData: Record<string, unknown> = {
            wordpress_rcp_id: level.wordpress_rcp_id,
            name: level.name,
            access_level: level.access_level,
          }

          if (level.description) {
            insertData.description = level.description
          }

          const { error: insertError } = await supabaseClient
            .from('membership_levels')
            .insert(insertData)

          if (insertError) {
            console.error('❌ Error creating level:', insertError)
            results.errors.push(
              `Error creating level ${level.wordpress_rcp_id}: ${insertError.message}`
            )
            continue
          }

          console.log(`✅ Created: ${level.name}`)
          results.created++
        }
      } catch (error) {
        console.error('❌ Error processing level:', error)
        results.errors.push(
          `Error processing level ${level.wordpress_rcp_id}: ${error instanceof Error ? error.message : String(error)}`
        )
      }
    }

    console.log(
      `✅ Catalog update completed: ${results.updated} updated, ${results.created} created, ${results.errors.length} errors`
    )

    // 5. Obtener el catálogo actualizado
    const { data: updatedCatalog, error: catalogError } = await supabaseClient
      .from('membership_levels')
      .select(
        'id, name, wordpress_rcp_id, access_level, description, created_at, updated_at'
      )
      .order('access_level', { ascending: true })

    if (catalogError) {
      console.error('❌ Error fetching updated catalog:', catalogError)
    }

    // 6. Retornar resultados
    return {
      statusCode: 200,
      body: {
        success: true,
        message: 'Membership catalog updated',
        results: {
          updated: results.updated,
          created: results.created,
          failed: results.errors.length,
          errors: results.errors,
        },
        catalog: updatedCatalog || [],
      },
    }
  } catch (error) {
    console.error('❌ [Update Membership Catalog] Error:', error)

    if (error instanceof WpException) {
      return {
        statusCode: error.statusCode || 500,
        body: { error: error.message, details: error.details },
      }
    }

    return {
      statusCode: 500,
      body: {
        error:
          error instanceof Error ? error.message : 'Unknown error occurred',
      },
    }
  }
}

// helpers/user_sync.ts
/**
 * Utilidades para sincronizar usuarios de WordPress a Supabase
 *
 * Garantiza que TODOS los usuarios de WordPress existan en Supabase
 * con sus datos completos (membresías, academy, specialty)
 */

import { WpException } from '../wp_client/model/wp_exception.ts';

/**
 * Datos básicos de usuario de WordPress
 */
export interface WordPressUserData {
  id: number;
  username: string;
  email: string;
  firstName?: string;
  lastName?: string;
}

/**
 * Garantiza que el usuario de WordPress existe en Supabase
 * Si no existe, lo crea con valores por defecto
 *
 * @param supabaseClient Cliente de Supabase con permisos service_role
 * @param wpUserData Datos del usuario obtenidos de WordPress
 * @returns Datos completos del usuario desde Supabase (con membresías)
 *
 * @throws WpException si hay error creando el usuario
 */
export async function ensureUserInSupabase(
  supabaseClient: any,
  wpUserData: WordPressUserData
): Promise<any> {

  console.log(`🔄 Ensuring user ${wpUserData.id} exists in Supabase...`);

  try {
    // 1. Buscar usuario existente en Supabase
    const { data: existingUser, error: selectError } = await supabaseClient
      .from('users')
      .select(`
        *,
        user_memberships(
          *,
          membership_level:membership_levels(*)
        )
      `)
      .eq('id', wpUserData.id)
      .maybeSingle();

    // Error buscando usuario
    if (selectError && selectError.code !== 'PGRST116') { // PGRST116 = no rows
      console.error('❌ Error searching for user in Supabase:', selectError);
      throw new WpException(
        500,
        'Error checking user existence',
        'Database Error',
        JSON.stringify(selectError)
      );
    }

    // 2. Usuario YA existe → devolverlo
    if (existingUser) {
      const membershipCount = existingUser.user_memberships?.length || 0;
      console.log(`✅ User ${wpUserData.id} already exists in Supabase with ${membershipCount} memberships`);
      return existingUser;
    }

    // 3. Usuario NO existe → crearlo
    console.log(`⚠️ User ${wpUserData.id} NOT found in Supabase, creating...`);

    const newUserData = {
      id: wpUserData.id,
      email: wpUserData.email || null,
      username: wpUserData.username || `user_${wpUserData.id}`,
      first_name: wpUserData.firstName || null,
      last_name: wpUserData.lastName || null,
      academy_id: 1  // OPN por defecto
      // specialty_id se asigna automáticamente por trigger si hay especialidad por defecto
      // createdAt y updatedAt se asignan automáticamente por DEFAULT now()
    };

    console.log('📝 Creating user with data:', {
      ...newUserData,
      email: newUserData.email ? '***@***' : null // Ocultar email en logs
    });

    const { data: newUser, error: insertError } = await supabaseClient
      .from('users')
      .insert(newUserData)
      .select(`
        *,
        user_memberships(
          *,
          membership_level:membership_levels(*)
        )
      `)
      .single();

    // Manejar errores de inserción
    if (insertError) {
      // Error de duplicado (race condition: usuario creado concurrentemente)
      if (insertError.code === '23505') {
        console.log('⚠️ User was created concurrently by another request, retrying select...');

        // Reintentar SELECT (recursión una sola vez)
        const { data: retryUser, error: retryError } = await supabaseClient
          .from('users')
          .select(`
            *,
            user_memberships(
              *,
              membership_level:membership_levels(*)
            )
          `)
          .eq('id', wpUserData.id)
          .single();

        if (retryError) {
          console.error('❌ Error on retry after duplicate:', retryError);
          throw new WpException(
            500,
            'Error retrieving user after concurrent creation',
            'Database Error',
            JSON.stringify(retryError)
          );
        }

        console.log('✅ User retrieved successfully after concurrent creation');
        return retryUser;
      }

      // Otro error de BD
      console.error('❌ Error creating user in Supabase:', insertError);
      throw new WpException(
        500,
        'Error creating user in database',
        'Database Error',
        JSON.stringify(insertError)
      );
    }

    // Usuario creado exitosamente
    console.log(`✅ User ${wpUserData.id} created successfully in Supabase`);
    console.log(`📊 Academy: ${newUser.academy_id}, Specialty: ${newUser.specialty_id || 'not assigned'}`);

    return newUser;

  } catch (error) {
    // Re-throw WpException tal cual
    if (error instanceof WpException) {
      throw error;
    }

    // Error inesperado
    console.error('💥 Unexpected error in ensureUserInSupabase:', error);
    throw new WpException(
      500,
      'Unexpected error syncing user',
      'Internal Server Error',
      error instanceof Error ? error.message : String(error)
    );
  }
}

/**
 * Actualiza los datos de un usuario existente en Supabase
 * (útil para sincronizar cambios desde WordPress)
 *
 * @param supabaseClient Cliente de Supabase
 * @param userId ID del usuario
 * @param updates Datos a actualizar
 */
export async function updateSupabaseUser(
  supabaseClient: any,
  userId: number,
  updates: Partial<WordPressUserData>
): Promise<void> {

  console.log(`📝 Updating user ${userId} in Supabase...`);

  const updateData = {
    ...updates,
    updatedAt: new Date().toISOString()
  };

  const { error } = await supabaseClient
    .from('users')
    .update(updateData)
    .eq('id', userId);

  if (error) {
    console.error('❌ Error updating user:', error);
    throw new WpException(
      500,
      'Error updating user',
      'Database Error',
      JSON.stringify(error)
    );
  }

  console.log(`✅ User ${userId} updated successfully`);
}

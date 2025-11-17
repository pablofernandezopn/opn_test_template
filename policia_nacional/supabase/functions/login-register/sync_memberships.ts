// sync_memberships.ts - Sistema completo de sincronización de membresías WordPress ↔ Supabase
import { createClient } from 'jsr:@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const WP_URL = 'https://oposicionesguardiacivil.online/';
const WP_USERNAME = 'admintest';
const WP_PASSWORD = 'qoVg 9Deq UmAv OiBL HrZI Isdq';

interface RCPMembership {
  id: string | number;
  customer_id: string | number;
  object_id: string | number; // Este es el wordpress_rcp_id del nivel (puede venir como string o number desde WordPress)
  object_type: string;
  status: string;
  created_date: string;
  expiration_date: string | null;
  auto_renew: boolean;
  gateway: string;
  subscription_key: string;
  name?: string; // Nombre del nivel de membresía
}

interface MembershipLevel {
  id: number;
  name: string;
  wordpress_rcp_id: number;
  access_level: number;
}

/**
 * Obtener token de administrador de WordPress
 */
async function getWPAdminToken(): Promise<string> {
  const url = `${WP_URL}wp-json/jwt-auth/v1/token`;
  
  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      username: WP_USERNAME,
      password: WP_PASSWORD
    })
  });

  if (!response.ok) {
    throw new Error(`Failed to get admin token: ${response.status}`);
  }

  const data = await response.json();
  return data.token;
}

/**
 * Obtener membresías del usuario desde WordPress RCP
 */
async function getUserMembershipsFromWP(userToken: string): Promise<RCPMembership[]> {
  const url = `${WP_URL}wp-json/rcp/v1/memberships`;
  
  console.log('📡 Fetching memberships from WordPress...');
  
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${userToken}`,
      'Content-Type': 'application/json',
    }
  });

  if (!response.ok) {
    if (response.status === 404) {
      console.log('ℹ️  User has no memberships in WordPress');
      return [];
    }
    throw new Error(`Failed to get memberships: ${response.status}`);
  }

  const memberships = await response.json();
  return Array.isArray(memberships) ? memberships : [];
}

/**
 * Sincronizar membresías de un usuario específico
 * @param userId - ID del usuario (mismo en Supabase, WordPress y RevenueCat)
 * @param userToken - Token JWT del usuario de WordPress
 */
export async function syncUserMemberships(
  userId: number,
  userToken: string
): Promise<{ synced: number; created: number; updated: number; deactivated: number }> {
  
  console.log(`\n${'='.repeat(70)}`);
  console.log(`🔄 STARTING MEMBERSHIP SYNC`);
  console.log(`   User ID: ${userId}`);
  console.log(`   Token: ${userToken.substring(0, 20)}...`);
  console.log(`${'='.repeat(70)}\n`);
  
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    console.error('❌ Supabase configuration missing!');
    throw new Error('Supabase configuration missing');
  }

  console.log(`✅ Supabase URL: ${SUPABASE_URL}`);
  console.log(`✅ Creating Supabase client...\n`);

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  });

  let created = 0;
  let updated = 0;
  let deactivated = 0;

  // 1. Obtener membresías de WordPress
  console.log(`📡 Step 1: Fetching memberships from WordPress RCP...`);
  const wpMemberships = await getUserMembershipsFromWP(userToken);
  console.log(`📦 Found ${wpMemberships.length} membership(s) in WordPress`);
  
  if (wpMemberships.length > 0) {
    console.log(`\n📋 WordPress Memberships Details:`);
    wpMemberships.forEach((wpm, index) => {
      console.log(`   ${index + 1}. ID: ${wpm.id}, Level: ${wpm.object_id}, Status: ${wpm.status}, Expires: ${wpm.expiration_date}`);
    });
    console.log('');
  }

  if (wpMemberships.length === 0) {
    console.log(`\n${'─'.repeat(70)}`);
    console.log('ℹ️  User has no memberships in WordPress');
    console.log('📝 Will assign Freemium membership automatically...');
    console.log(`${'─'.repeat(70)}\n`);
    
    // Buscar el nivel Freemium (access_level = 1)
    console.log(`🔍 Looking for Freemium level (access_level = 1)...`);
    const { data: freemiumLevel, error: freemiumError } = await supabase
      .from('membership_levels')
      .select('*')
      .eq('access_level', 1)
      .single();

    if (freemiumError) {
      console.error(`❌ Error fetching Freemium level:`, freemiumError);
    }

    if (!freemiumLevel) {
      console.error('❌ Freemium level not found in database!');
      console.error('⚠️  Please insert membership levels first using /v1/update-membership-catalog');
      return { synced: 0, created: 0, updated: 0, deactivated: 0 };
    }

    console.log(`✅ Found Freemium level:`);
    console.log(`   ID: ${freemiumLevel.id}`);
    console.log(`   Name: ${freemiumLevel.name}`);
    console.log(`   Access Level: ${freemiumLevel.access_level}`);
    console.log(`   WordPress RCP ID: ${freemiumLevel.wordpress_rcp_id}\n`);

    // Verificar si ya tiene una membresía Freemium
    console.log(`🔍 Checking if user ${userId} already has Freemium...`);
    const { data: existingFreemium, error: checkError } = await supabase
      .from('user_memberships')
      .select('*')
      .eq('user_id', userId)
      .eq('membership_level_id', freemiumLevel.id)
      .single();

    if (checkError && checkError.code !== 'PGRST116') {
      console.error(`❌ Error checking existing Freemium:`, checkError);
    }

    if (existingFreemium) {
      console.log(`✅ User already has Freemium membership (ID: ${existingFreemium.id})`);
      console.log(`   Status: ${existingFreemium.status}`);
      
      // Ya tiene Freemium, solo asegurar que esté activa
      if (existingFreemium.status !== 'active') {
        console.log('🔄 Reactivating existing Freemium membership...');
        const { error: updateError } = await supabase
          .from('user_memberships')
          .update({
            status: 'active',
            sync_status: 'synced',
            last_synced_at: new Date().toISOString()
          })
          .eq('id', existingFreemium.id);
        
        if (updateError) {
          console.error('❌ Error updating Freemium:', updateError);
        } else {
          console.log('✅ Freemium membership reactivated');
          updated = 1;
        }
      } else {
        console.log('ℹ️  Freemium membership is already active - no changes needed');
      }
    } else {
      // Crear nueva membresía Freemium
      console.log(`\n➕ Creating NEW Freemium membership for user ${userId}...`);
      console.log(`   Level ID: ${freemiumLevel.id}`);
      console.log(`   Status: active`);
      console.log(`   Expires: never (null)`);
      
      const { data: insertedData, error: createError } = await supabase
        .from('user_memberships')
        .insert({
          user_id: userId,
          membership_level_id: freemiumLevel.id,
          status: 'active',
          started_at: new Date().toISOString(),
          expires_at: null, // Freemium no expira
          auto_renews: false,
          sync_source: 'auto_freemium',
          sync_status: 'synced',
          last_synced_at: new Date().toISOString(),
          metadata: {
            auto_created: true,
            reason: 'No memberships in WordPress'
          }
        })
        .select();

      if (createError) {
        console.error('❌ Error creating Freemium membership:', createError);
        console.error('   Details:', JSON.stringify(createError, null, 2));
      } else {
        console.log('✅ Freemium membership created successfully!');
        console.log('   Data:', JSON.stringify(insertedData, null, 2));
        created = 1;
      }
    }

    // Desactivar otras membresías premium que pudiera tener
    console.log(`\n🔄 Deactivating other active memberships (if any)...`);
    const { data: deactivatedData, error: deactivateError } = await supabase
      .from('user_memberships')
      .update({
        status: 'cancelled',
        sync_status: 'synced',
        last_synced_at: new Date().toISOString()
      })
      .eq('user_id', userId)
      .neq('membership_level_id', freemiumLevel.id)
      .eq('status', 'active')
      .select();

    if (deactivateError) {
      console.error('❌ Error deactivating memberships:', deactivateError);
    } else {
      const deactivatedCount = deactivatedData?.length || 0;
      if (deactivatedCount > 0) {
        console.log(`✅ Deactivated ${deactivatedCount} other membership(s)`);
      } else {
        console.log(`ℹ️  No other memberships to deactivate`);
      }
    }

    console.log(`\n${'='.repeat(70)}`);
    console.log(`✅ SYNC COMPLETED (No WP memberships case)`);
    console.log(`   Created: ${created}`);
    console.log(`   Updated: ${updated}`);
    console.log(`   Deactivated: 0`);
    console.log(`   Total Synced: ${created + updated}`);
    console.log(`${'='.repeat(70)}\n`);

    return { synced: created + updated, created, updated, deactivated: 0 };
  }

  // 2. Obtener niveles de membresía de Supabase
  console.log(`\n📊 Step 2: Fetching membership levels from Supabase...`);
  const { data: membershipLevels, error: levelsError } = await supabase
    .from('membership_levels')
    .select('*');

  if (levelsError) {
    console.error(`❌ Error fetching membership levels:`, levelsError);
    throw new Error(`Failed to fetch membership levels: ${levelsError.message}`);
  }

  console.log(`✅ Found ${membershipLevels?.length || 0} membership level(s) in Supabase`);
  
  if (!membershipLevels || membershipLevels.length === 0) {
    console.error('❌ No membership levels found in database!');
    console.error('⚠️  Please insert membership levels first using /v1/update-membership-catalog');
    return { synced: 0, created: 0, updated: 0, deactivated: 0 };
  }
  
  console.log(`\n📋 Available Membership Levels:`);
  membershipLevels.forEach((level: any) => {
    console.log(`   - ID: ${level.id}, Name: "${level.name}", WP RCP ID: ${level.wordpress_rcp_id}, Access Level: ${level.access_level}`);
  });
  console.log('');

  // Crear mapa de wordpress_rcp_id → membership_level
  // IMPORTANTE: wordpress_rcp_id es el ID único de la membresía en WordPress
  // Múltiples membresías pueden tener el mismo access_level
  const rcpIdToLevelMap = new Map<number, MembershipLevel>();
  membershipLevels?.forEach((level: any) => {
    if (level.wordpress_rcp_id) {
      rcpIdToLevelMap.set(level.wordpress_rcp_id, level);
      console.log(`   📌 Mapped RCP ID ${level.wordpress_rcp_id} → ${level.name} (Access Level ${level.access_level})`);
    }
  });

  // 3. Obtener membresías actuales del usuario en Supabase
  console.log(`\n🔍 Step 3: Checking existing memberships for user ${userId}...`);
  const { data: existingMemberships, error: existingError } = await supabase
    .from('user_memberships')
    .select('*')
    .eq('user_id', userId);

  if (existingError) {
    console.error(`❌ Error fetching existing memberships:`, existingError);
  }

  console.log(`✅ Found ${existingMemberships?.length || 0} existing membership(s) in Supabase`);
  
  if (existingMemberships && existingMemberships.length > 0) {
    console.log(`\n📋 Existing Memberships in Supabase:`);
    existingMemberships.forEach((m: any, index: number) => {
      console.log(`   ${index + 1}. ID: ${m.id}, Level ID: ${m.membership_level_id}, Status: ${m.status}, Expires: ${m.expires_at || 'never'}`);
    });
    console.log('');
  }

  const existingMap = new Map<number, any>();
  existingMemberships?.forEach((m: any) => {
    existingMap.set(m.membership_level_id, m);
  });

  // 4. Procesar cada membresía de WordPress
  console.log(`\n🔄 Step 4: Processing WordPress memberships...\n`);
  const processedLevelIds = new Set<number>();

  for (const wpMembership of wpMemberships) {
    console.log(`\n🔍 Processing WordPress membership ID: ${wpMembership.id}`);
    console.log(`   - RCP Level ID: ${wpMembership.object_id} (type: ${typeof wpMembership.object_id})`);
    console.log(`   - Status: ${wpMembership.status}`);

    // Buscar el nivel correspondiente (convertir a número por si viene como string)
    const rcpId = typeof wpMembership.object_id === 'string' 
      ? parseInt(wpMembership.object_id, 10) 
      : wpMembership.object_id;
    
    const level = rcpIdToLevelMap.get(rcpId);

    if (!level) {
      console.warn(`⚠️  No matching level found for RCP ID ${rcpId} (original: ${wpMembership.object_id})`);
      continue;
    }

        console.log(`✅ Matched level: ${level.name} (access_level: ${level.access_level})`);

    // 5. Crear membresía en Supabase
    processedLevelIds.add(level.id);

    // Manejar expiration_date (puede ser "none", null, o una fecha válida)
    let expiresAt = null;
    if (wpMembership.expiration_date && 
        wpMembership.expiration_date !== 'none' && 
        wpMembership.expiration_date !== 'null') {
      try {
        expiresAt = new Date(wpMembership.expiration_date).toISOString();
      } catch (e) {
        console.warn(`⚠️  Invalid expiration date: ${wpMembership.expiration_date}`);
        expiresAt = null;
      }
    }

    const isActive = wpMembership.status === 'active';
    const existing = existingMap.get(level.id);

    if (existing) {
      // ACTUALIZAR si hay cambios
      const needsUpdate = 
        existing.status !== wpMembership.status ||
        existing.expires_at !== expiresAt ||
        existing.auto_renews !== wpMembership.auto_renew;

      if (needsUpdate) {
        console.log(`🔄 Updating membership ${existing.id}`);
        
        const { error: updateError } = await supabase
          .from('user_memberships')
          .update({
            status: wpMembership.status,
            expires_at: expiresAt,
            auto_renews: wpMembership.auto_renew,
            sync_status: 'synced',
            sync_error: null,
            last_synced_at: new Date().toISOString(),
            metadata: {
              wordpress_membership_id: wpMembership.id,
              wordpress_customer_id: wpMembership.customer_id,
              gateway: wpMembership.gateway,
              subscription_key: wpMembership.subscription_key
            }
          })
          .eq('id', existing.id);

        if (updateError) {
          console.error(`❌ Update error:`, updateError);
        } else {
          console.log(`✅ Membership updated`);
          updated++;
        }
      } else {
        console.log(`ℹ️  No changes detected`);
      }
    } else {
      // CREAR nueva membresía
      console.log(`➕ Creating new membership for level: ${level.name}`);
      
      const { error: createError } = await supabase
        .from('user_memberships')
        .insert({
          user_id: userId,
          membership_level_id: level.id,
          status: wpMembership.status,
          started_at: new Date(wpMembership.created_date).toISOString(),
          expires_at: expiresAt,
          auto_renews: wpMembership.auto_renew,
          sync_source: 'wordpress',
          sync_status: 'synced',
          last_synced_at: new Date().toISOString(),
          metadata: {
            wordpress_membership_id: wpMembership.id,
            wordpress_customer_id: wpMembership.customer_id,
            gateway: wpMembership.gateway,
            subscription_key: wpMembership.subscription_key
          }
        });

      if (createError) {
        console.error(`❌ Create error:`, createError);
      } else {
        console.log(`✅ Membership created`);
        created++;
      }
    }
  }

  // 5. Desactivar membresías que ya no están en WordPress
  console.log(`\n🔍 Step 5: Checking for orphaned memberships...`);
  let orphanedCount = 0;
  
  for (const [levelId, existing] of existingMap) {
    if (!processedLevelIds.has(levelId) && existing.status === 'active') {
      orphanedCount++;
      console.log(`⚠️  Found orphaned membership: ID ${existing.id}, Level ${levelId}`);
      console.log(`   This membership exists in Supabase but not in WordPress - deactivating...`);
      
      const { error: deactivateError } = await supabase
        .from('user_memberships')
        .update({
          status: 'cancelled',
          sync_status: 'synced',
          last_synced_at: new Date().toISOString()
        })
        .eq('id', existing.id);

      if (deactivateError) {
        console.error(`❌ Error deactivating membership ${existing.id}:`, deactivateError);
      } else {
        console.log(`✅ Membership ${existing.id} deactivated`);
        deactivated++;
      }
    }
  }

  if (orphanedCount === 0) {
    console.log(`ℹ️  No orphaned memberships found`);
  }

  const synced = created + updated;
  
  console.log(`\n${'='.repeat(70)}`);
  console.log(`✅ SYNC COMPLETED SUCCESSFULLY`);
  console.log(`   Created: ${created}`);
  console.log(`   Updated: ${updated}`);
  console.log(`   Deactivated: ${deactivated}`);
  console.log(`   Total Synced: ${synced}`);
  console.log(`${'='.repeat(70)}\n`);

  return { synced, created, updated, deactivated };
}

/**
 * Handler para el endpoint de sincronización manual
 */
export class SyncMembershipsHandler {
  async handle(request: Request): Promise<Response> {
    console.log('🔄 Manual membership sync triggered');

    try {
      const body = await request.json();
      
      if (!body.jwt_token) {
        return new Response(
          JSON.stringify({ 
            success: false, 
            error: 'jwt_token required in body' 
          }),
          { 
            status: 400,
            headers: { 'Content-Type': 'application/json' }
          }
        );
      }

      // Obtener info del usuario con el token
      const userInfoResponse = await fetch(`${WP_URL}wp-json/wp/v2/users/me`, {
        headers: {
          'Authorization': `Bearer ${body.jwt_token}`,
          'Content-Type': 'application/json',
        }
      });

      if (!userInfoResponse.ok) {
        return new Response(
          JSON.stringify({ 
            success: false, 
            error: 'Invalid token or user not found' 
          }),
          { 
            status: 401,
            headers: { 'Content-Type': 'application/json' }
          }
        );
      }

      const userInfo = await userInfoResponse.json();
      const userId = userInfo.id;
      const userEmail = userInfo.email;

      console.log(`📧 Syncing for user: ${userEmail} (ID: ${userId})`);

      // Sincronizar membresías usando el user ID
      const result = await syncUserMemberships(userId, body.jwt_token);

      return new Response(
        JSON.stringify({ 
          success: true,
          user_id: userId,
          user_email: userEmail,
          sync_result: result
        }),
        { 
          status: 200,
          headers: { 'Content-Type': 'application/json' }
        }
      );

    } catch (error) {
      console.error('❌ Sync error:', error);
      
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: error instanceof Error ? error.message : String(error)
        }),
        { 
          status: 500,
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }
  }
}

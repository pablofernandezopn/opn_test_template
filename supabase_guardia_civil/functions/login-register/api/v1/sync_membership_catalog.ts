// api/v1/sync_membership_catalog.ts

// @ts-ignore
/**
 * Sincroniza el catálogo de niveles de membresía desde WordPress RCP a Supabase
 * 
 * Este endpoint:
 * 1. Obtiene el token de administrador de WordPress
 * 2. Consulta todos los niveles de membresía definidos en RCP
 * 3. Actualiza/crea los niveles en la tabla membership_levels de Supabase
 * 
 * Endpoint: POST /v1/sync-membership-catalog
 * 
 * Request body: {} (vacío, no requiere parámetros)
 * 
 * Response:
 * {
 *   "success": true,
 *   "message": "Membership catalog synced successfully",
 *   "levels": [
 *     {
 *       "id": 1,
 *       "name": "Gratis",
 *       "wordpress_rcp_id": 1,
 *       "access_level": 1
 *     },
 *     ...
 *   ],
 *   "stats": {
 *     "created": 2,
 *     "updated": 1,
 *     "total": 3
 *   }
 * }
 */

export async function syncMembershipCatalog(): Promise<any> {
  console.log('📋 [Sync Membership Catalog] Starting catalog sync from WordPress...');

  const WP_CONFIG = {
    url: Deno.env.get('WP_URL') || '',
    username: Deno.env.get('WP_ADMIN_USERNAME') || '',
    password: Deno.env.get('WP_ADMIN_PASSWORD') || ''
  };

  // Paso 1: Obtener token de administrador
  console.log('🔑 Step 1: Getting admin token...');
  const tokenUrl = `${WP_CONFIG.url}/wp-json/jwt-auth/v1/token`;
  
  const tokenResponse = await fetch(tokenUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      username: WP_CONFIG.username,
      password: WP_CONFIG.password
    })
  });

  if (!tokenResponse.ok) {
    const error = await tokenResponse.text();
    console.error('❌ Failed to get admin token:', error);
    throw new Error(`Failed to get admin token: ${error}`);
  }

  const tokenData = await tokenResponse.json();
  const adminToken = tokenData.token;
  console.log('✅ Admin token obtained');

  // Paso 2: Obtener niveles de membresía desde WordPress RCP API
  console.log('📡 Step 2: Fetching membership levels from WordPress RCP API...');
  
  // Intentar primero el endpoint personalizado (rcp-custom) que consulta directamente la BD
  // Si falla, usar el endpoint oficial de RCP (que puede devolver objetos vacíos)
  const customEndpoint = `${WP_CONFIG.url}/wp-json/rcp-custom/v1/levels`;
  const officialEndpoint = `${WP_CONFIG.url}/wp-json/rcp/v1/levels/`;

  let levelsData: any[] | null = null;
  let successEndpoint: string | null = null;

  // Intentar primero el endpoint personalizado
  console.log(`🔍 Trying custom endpoint: ${customEndpoint}`);
  
  try {
    const response = await fetch(customEndpoint, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${adminToken}`,
        'Content-Type': 'application/json'
      }
    });

    console.log(`📊 Custom endpoint response status: ${response.status}`);

    if (response.ok) {
      const data = await response.json();
      console.log(`📦 Custom endpoint response:`, JSON.stringify(data, null, 2));
      
      // El endpoint personalizado devuelve { success: true, count: X, levels: [...] }
      if (data.success && data.levels && Array.isArray(data.levels) && data.levels.length > 0) {
        levelsData = data.levels;
        successEndpoint = customEndpoint;
        console.log(`✅ Custom endpoint returned ${levelsData.length} valid levels`);
      }
    } else {
      console.log(`⚠️  Custom endpoint failed (${response.status}), trying official endpoint...`);
    }
  } catch (error) {
    console.log(`⚠️  Custom endpoint error:`, error);
  }

  // Si el endpoint personalizado falló, intentar el oficial
  if (!levelsData || !Array.isArray(levelsData) || levelsData.length === 0) {
    console.log(`🔍 Trying official RCP endpoint: ${officialEndpoint}`);
    
    try {
      const response = await fetch(officialEndpoint, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      });

      console.log(`📊 Official endpoint response status: ${response.status}`);

      if (response.ok) {
        const rawText = await response.text();
        console.log(`📦 Official endpoint raw response:`, rawText);
        
        try {
          const data = JSON.parse(rawText);
          
          // Intentar diferentes estructuras
          const possibleData = [
            data,
            data?.levels,
            data?.data,
            data?.items
          ];
          
          for (const candidate of possibleData) {
            if (candidate && Array.isArray(candidate)) {
              console.log(`🔍 Found array with ${candidate.length} items in official endpoint`);
              console.log(`🔍 First item:`, JSON.stringify(candidate[0], null, 2));
              
              // Verificar que no sean objetos vacíos
              if (candidate.length > 0 && Object.keys(candidate[0] || {}).length > 0) {
                levelsData = candidate;
                successEndpoint = officialEndpoint;
                console.log(`✅ Official endpoint returned valid data`);
                break;
              }
            }
          }
        } catch (parseError) {
          console.error(`❌ JSON parse error:`, parseError);
        }
      }
    } catch (error) {
      console.log(`❌ Official endpoint error:`, error);
    }
  }

  // Verificar si los datos son válidos (no objetos vacíos)
  const hasValidData = levelsData && Array.isArray(levelsData) && levelsData.length > 0 && 
                       levelsData.some(level => level.id || level.ID || level.name || level.title);
  
  if (!hasValidData) {
    console.log('⚠️  No valid levels found via API, using hardcoded defaults');
    console.log('   API returned:', JSON.stringify(levelsData));
    
    // Si no hay endpoint disponible o devuelve objetos vacíos, usar niveles predefinidos
    levelsData = [
      {
        id: 1,
        name: 'Gratis',
        description: 'Membresía gratuita con acceso básico',
        access_level: 1,
        price: 0
      },
      {
        id: 2,
        name: 'Premium',
        description: 'Membresía Premium con acceso completo',
        access_level: 2,
        price: 19.99
      },
      {
        id: 3,
        name: 'Premium Plus',
        description: 'Membresía Premium Plus con todos los beneficios',
        access_level: 3,
        price: 29.99
      }
    ];
  }

  console.log(`📦 Found ${levelsData.length} membership level(s)`);
  console.log('📋 Levels:', JSON.stringify(levelsData, null, 2));

  // Paso 3: Obtener cliente de Supabase
  console.log('🔌 Step 3: Connecting to Supabase...');
  
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  
  if (!supabaseUrl || !supabaseKey) {
    throw new Error('Supabase configuration missing');
  }

  const { createClient } = await import('https://esm.sh/@supabase/supabase-js@2');
  const supabase = createClient(supabaseUrl, supabaseKey);
  console.log('✅ Supabase client created');

  // Paso 4: Sincronizar cada nivel
  console.log('🔄 Step 4: Syncing levels to Supabase...');
  
  const stats = {
    created: 0,
    updated: 0,
    errors: 0,
    total: 0
  };

  const syncedLevels: any[] = [];

  for (const wpLevel of levelsData) {
    try {
      // RCP API devuelve: { id, name, description, status, price, duration, duration_unit, ... }
      const wordpress_rcp_id = wpLevel.id || wpLevel.ID;
      const name = wpLevel.name || wpLevel.title?.rendered || wpLevel.post_title || 'Unknown';
      const description = wpLevel.description || wpLevel.content?.rendered || '';
      
      console.log(`\n📦 Raw level data:`, JSON.stringify(wpLevel, null, 2));

      // Usar el campo 'level' que viene de WordPress RCP
      // Si no viene, intentar access_level, y si tampoco, usar el ID como fallback
      const access_level = wpLevel.level || wpLevel.access_level || wordpress_rcp_id || 1;

      // Definir revenuecat_product_ids según el nivel
      // Mapeo flexible: nivel 1 = free, niveles 2+ = premium
      let revenuecat_product_ids: string[] = [];
      if (access_level === 1) {
        revenuecat_product_ids = ['opn_gc_free'];
      } else if (access_level >= 2) {
        // Cualquier nivel 2 o superior usa productos premium
        revenuecat_product_ids = ['premium_month', 'premium_quarter', 'premium_semester', 'premium_annual'];
      }

      console.log(`\n🔍 Processing: ${name}`);
      console.log(`   WordPress RCP ID: ${wordpress_rcp_id}`);
      console.log(`   Access Level: ${access_level}`);

      // Verificar si ya existe
      const { data: existing, error: checkError } = await supabase
        .from('membership_levels')
        .select('id, name')
        .eq('wordpress_rcp_id', wordpress_rcp_id)
        .single();

      if (checkError && checkError.code !== 'PGRST116') {
        console.error('❌ Error checking level:', checkError);
        stats.errors++;
        continue;
      }

      if (existing) {
        // Actualizar existente
        console.log(`📝 Updating existing level: ${existing.name} → ${name}`);
        
        const { data: updated, error: updateError} = await supabase
          .from('membership_levels')
          .update({
            name,
            description,
            access_level,
            revenuecat_product_ids,
            updated_at: new Date().toISOString()
          })
          .eq('id', existing.id)
          .select()
          .single();

        if (updateError) {
          console.error('❌ Update error:', updateError);
          stats.errors++;
        } else {
          console.log('✅ Level updated successfully');
          stats.updated++;
          syncedLevels.push(updated);
        }
      } else {
        // Crear nuevo
        console.log(`➕ Creating new level: ${name}`);
        
        const { data: created, error: createError } = await supabase
          .from('membership_levels')
          .insert({
            name,
            description,
            wordpress_rcp_id,
            access_level,
            revenuecat_product_ids,
            specialty_id: null // NULL for generic memberships (Freemium)
          })
          .select()
          .single();

        if (createError) {
          console.error('❌ Create error:', createError);
          stats.errors++;
        } else {
          console.log('✅ Level created successfully');
          stats.created++;
          syncedLevels.push(created);
        }
      }

      stats.total++;
    } catch (error) {
      console.error('❌ Error processing level:', error);
      stats.errors++;
    }
  }

  console.log('\n======================================================================');
  console.log('✅ SYNC COMPLETED');
  console.log(`   Created: ${stats.created}`);
  console.log(`   Updated: ${stats.updated}`);
  console.log(`   Errors: ${stats.errors}`);
  console.log(`   Total: ${stats.total}`);
  console.log('======================================================================\n');

  return {
    success: true,
    message: 'Membership catalog synced successfully',
    levels: syncedLevels,
    stats,
    source: successEndpoint || 'hardcoded defaults'
  };
}

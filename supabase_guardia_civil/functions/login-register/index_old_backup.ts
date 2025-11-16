// index.ts - Main entry point
console.log('🚀 Starting WordPress login-register function...')

import { createClient } from 'jsr:@supabase/supabase-js@2'
import { V1APIRouter } from './api/v1_api_router.ts'

// Headers CORS
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Content-Type": "application/json"
}

// Extraer versión de API y path
function extractApiVersion(request: Request): string {
  const url = new URL(request.url)
  const pathname = url.pathname
  
  const loginRegisterPrefix = "/login-register/"
  const prefixIndex = pathname.indexOf(loginRegisterPrefix)
  
  let path: string
  if (prefixIndex !== -1) {
    path = pathname.substring(prefixIndex + loginRegisterPrefix.length)
  } else {
    path = pathname.startsWith('/') ? pathname.substring(1) : pathname
  }
  
  if (path.includes('/')) {
    return path.split('/')[0]
  }
  
  throw new Error("Invalid request without API version")
}

// Clase para manejo de errores
class WpException extends Error {
  constructor(
    public status: number,
    public reason: string,
    public statusText: string,
    public details: any
  ) {
    super(reason);
  }

  toJson() {
    return {
      error: this.reason,
      status: this.status,
      statusText: this.statusText,
      details: this.details
    };
  }
}

// WordPress API Client
class WordPressClient {
  private baseUrl: string;
  private adminUsername: string;
  private adminPassword: string;

  constructor() {
    this.baseUrl = WP_CONFIG.url.endsWith('/') ? WP_CONFIG.url : WP_CONFIG.url + '/';
    this.adminUsername = WP_CONFIG.username;
    this.adminPassword = WP_CONFIG.password;
  }

  // Obtener token de administrador
  async getAdminToken(): Promise<string> {
    const url = `${this.baseUrl}wp-json/jwt-auth/v1/token`;
    
    console.log('🔑 Getting admin token from:', url);
    
    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          username: this.adminUsername,
          password: this.adminPassword
        })
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('❌ Admin token error:', response.status, errorText);
        throw new Error(`Failed to get admin token: ${response.status} ${errorText}`);
      }

      const data = await response.json();
      console.log('✅ Admin token obtained successfully');
      return data.token;
      
    } catch (error) {
      console.error('💥 Error getting admin token:', error);
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new Error(`Admin token request failed: ${errorMessage}`);
    }
  }

  // Login de usuario
  async userLogin(username: string, password: string): Promise<{ token: string, user: any }> {
    const url = `${this.baseUrl}wp-json/jwt-auth/v1/token`;
    
    console.log('🔐 User login attempt for:', username);
    
    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          username: username,
          password: password
        })
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('❌ Login failed:', response.status, errorText);
        
        if (response.status === 403) {
          throw new WpException(401, "Invalid credentials", "Unauthorized", "Username or password incorrect");
        }
        
        throw new WpException(500, "Login failed", "Internal Server Error", errorText);
      }

      const data = await response.json();
      console.log('✅ Login successful for:', username);
      
      // Decodificar JWT para obtener el user ID
      let userId = null;
      if (data.token) {
        try {
          const payload = data.token.split('.')[1];
          const decoded = JSON.parse(atob(payload));
          userId = decoded.data?.user?.id || null;
          console.log('🔍 Decoded user ID from JWT:', userId);
        } catch (e) {
          console.error('⚠️  Could not decode JWT:', e);
        }
      }
      
      return {
        token: data.token,
        user: {
          id: userId ? parseInt(userId) : null, // Convertir a número
          username: data.user_display_name || username,
          email: data.user_email || username
        }
      };
      
    } catch (error) {
      if (error instanceof WpException) {
        throw error;
      }
      console.error('💥 Login error:', error);
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new WpException(500, "Login request failed", "Internal Server Error", errorMessage);
    }
  }

  // Obtener datos del usuario con token
  async getUser(token: string): Promise<any> {
    const url = `${this.baseUrl}wp-json/wp/v2/users/me`;
    
    console.log('👤 Getting user data with token');
    
    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        }
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('❌ Get user failed:', response.status, errorText);
        
        if (response.status === 401 || response.status === 403) {
          throw new WpException(401, "Invalid or expired token", "Unauthorized", "Token validation failed");
        }
        
        throw new WpException(500, "Get user failed", "Internal Server Error", errorText);
      }

      const userData = await response.json();
      console.log('✅ User data retrieved successfully');
      
      return {
        id: userData.id,
        username: userData.username,
        email: userData.email,
        firstName: userData.first_name || '',
        lastName: userData.last_name || '',
        roles: userData.roles || [],
        capabilities: userData.capabilities || {}
      };
      
    } catch (error) {
      if (error instanceof WpException) {
        throw error;
      }
      console.error('💥 Get user error:', error);
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new WpException(500, "Get user request failed", "Internal Server Error", errorMessage);
    }
  }

  // Obtener membresías RCP del usuario
  async getUserMemberships(token: string): Promise<any> {
    const url = `${this.baseUrl}wp-json/rcp/v1/memberships`;
    
    console.log('🔒 Getting user memberships from RCP');
    
    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        }
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('❌ Get memberships failed:', response.status, errorText);
        
        if (response.status === 401 || response.status === 403) {
          throw new WpException(401, "Invalid or expired token", "Unauthorized", "Token validation failed");
        }
        
        throw new WpException(500, "Get memberships failed", "Internal Server Error", errorText);
      }

      const memberships = await response.json();
      console.log('✅ Memberships retrieved successfully');
      
      return {
        memberships: memberships,
        count: Array.isArray(memberships) ? memberships.length : 0
      };
      
    } catch (error) {
      if (error instanceof WpException) {
        throw error;
      }
      console.error('💥 Get memberships error:', error);
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new WpException(500, "Get memberships request failed", "Internal Server Error", errorMessage);
    }
  }

  // Verificar si el usuario tiene acceso a contenido específico
  async checkUserAccess(token: string, contentId: string): Promise<any> {
    console.log(`🔐 Checking access for content ID: ${contentId}`);
    
    try {
      // Obtener información del usuario y sus membresías
      const user = await this.getUser(token);
      const memberships = await this.getUserMemberships(token);
      
      // Verificar acceso al contenido específico
      const postUrl = `${this.baseUrl}wp-json/wp/v2/posts/${contentId}`;
      const postResponse = await fetch(postUrl, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        }
      });
      
      let hasAccess = false;
      let content = null;
      let restrictions = null;
      
      if (postResponse.ok) {
        content = await postResponse.json();
        hasAccess = true; // Si puede acceder al post, tiene permisos
      } else if (postResponse.status === 401 || postResponse.status === 403) {
        hasAccess = false;
        restrictions = 'Content restricted by membership level';
      }
      
      return {
        hasAccess,
        user: user,
        memberships: memberships,
        content: hasAccess ? {
          id: content?.id,
          title: content?.title?.rendered,
          excerpt: content?.excerpt?.rendered
        } : null,
        restrictions
      };
      
    } catch (error) {
      if (error instanceof WpException) {
        throw error;
      }
      console.error('💥 Check access error:', error);
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new WpException(500, "Check access request failed", "Internal Server Error", errorMessage);
    }
  }

  // Registrar nuevo usuario
  async registerUser(userData: any): Promise<any> {
    try {
      // Primero obtenemos token de admin
      const adminToken = await this.getAdminToken();
      const url = `${this.baseUrl}wp-json/wp/v2/users`;
      
      console.log('📝 Registering new user:', userData.username);
      
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          username: userData.username,
          email: userData.email,
          password: userData.password,
          first_name: userData.firstName || '',
          last_name: userData.lastName || '',
          roles: userData.roles || ['subscriber']
        })
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('❌ Registration failed:', response.status, errorText);
        
        if (response.status === 400) {
          throw new WpException(400, "Registration failed", "Bad Request", "User already exists or invalid data");
        }
        
        throw new WpException(500, "Registration failed", "Internal Server Error", errorText);
      }

      const newUser = await response.json();
      console.log('✅ User registered successfully:', newUser.id);
      
      return {
        id: newUser.id,
        username: newUser.username,
        email: newUser.email,
        firstName: newUser.first_name || '',
        lastName: newUser.last_name || ''
      };
      
    } catch (error) {
      if (error instanceof WpException) {
        throw error;
      }
      console.error('💥 Registration error:', error);
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new WpException(500, "Registration request failed", "Internal Server Error", errorMessage);
    }
  }
}

// Clase base para manejo de requests
class RequestHandler {
  static get jsonHeaders() {
    return corsHeaders;
  }

  async parseJsonBody(request: Request): Promise<any> {
    try {
      return await request.json();
    } catch (error) {
      throw new Error('Invalid JSON body');
    }
  }

  jsonResponse(data: any, status: number = 200): Response {
    return new Response(
      JSON.stringify(data),
      {
        status,
        headers: corsHeaders
      }
    );
  }
}

// Handler del login
class WPLogin extends RequestHandler {
  async handle(request: Request): Promise<Response> {
    const body = await this.parseJsonBody(request);

    if (!body || typeof body !== 'object') {
      throw new WpException(400, "Bad format", "Bad request", null);
    }

    return this.processLogin(body);
  }

  private async processLogin(body: any): Promise<Response> {
    if (!body.username || !body.password) {
      throw new WpException(400, "Missing username and/or password", "Bad request", null);
    }

    try {
      const wpClient = new WordPressClient();
      
      // 1. Login y obtener token + user
      const loginResult = await wpClient.userLogin(body.username, body.password);
      
      console.log('📥 Usuario obtenido de WordPress:', JSON.stringify({
        id: loginResult.user.id,
        username: loginResult.user.username,
        email: loginResult.user.email,
        firstName: loginResult.user.firstName,
        lastName: loginResult.user.lastName
      }));
      
      // 🆕 2. CREAR O ACTUALIZAR USUARIO EN SUPABASE
      try {
        console.log('Sincronizando usuario a Supabase...');
        const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
        const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
        
        const { createClient } = await import('jsr:@supabase/supabase-js@2');
        const supabaseClient = createClient(supabaseUrl, supabaseKey);
        
        // Verificar si el usuario ya existe
        const { data: existingUser, error: selectError } = await supabaseClient
          .from('users')
          .select('id')
          .eq('id', loginResult.user.id)
          .single();

        const userData = {
          id: loginResult.user.id,
          username: loginResult.user.username,
          email: loginResult.user.email || '',
          first_name: loginResult.user.firstName || '',
          last_name: loginResult.user.lastName || '',
        };

        if (existingUser) {
          console.log('🔄 Usuario ya existe, actualizando...');
          const { error: updateError } = await supabaseClient
            .from('users')
            .update(userData)
            .eq('id', loginResult.user.id);

          if (updateError) {
            console.error('❌ Error actualizando usuario:', updateError);
          } else {
            console.log('✅ Usuario actualizado en Supabase');
          }
        } else {
          console.log('➕ Usuario no existe, creando...');
          const { error: insertError } = await supabaseClient
            .from('users')
            .insert([userData]);

          if (insertError) {
            console.error('❌ Error creando usuario:', insertError);
          } else {
            console.log('✅ Usuario creado en Supabase');
          }
        }
      } catch (userSyncError) {
        console.error('⚠️  User sync failed (non-critical):', userSyncError);
      }
      
      // �🔄 3. SINCRONIZACIÓN AUTOMÁTICA DE MEMBRESÍAS
      let syncResult = { synced: 0, created: 0, updated: 0, deactivated: 0 };
      try {
        console.log(`🔄 Starting automatic membership sync for user ID ${loginResult.user.id}...`);
        
        // Sincronizar membresías con Supabase usando el user.id
        syncResult = await syncUserMemberships(loginResult.user.id, loginResult.token);
        console.log(`✅ Sync completed: ${syncResult.synced} total`);
      } catch (syncError) {
        // No fallar el login si falla la sincronización
        console.error('⚠️  Membership sync failed (non-critical):', syncError);
      }
      
      return this.jsonResponse({
        success: true,
        token: loginResult.token,
        user: loginResult.user,
        memberships_synced: syncResult.synced,
        sync_details: syncResult
      });
      
    } catch (error) {
      if (error instanceof WpException) {
        throw error;
      }
      
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new WpException(500, "Login failed", "Internal Server Error", errorMessage);
    }
  }
}

// Handler de get_user
class WpGetUser extends RequestHandler {
  async handle(request: Request): Promise<Response> {
    console.log('🚨 WpGetUser.handle called - JWT por BODY');
    
    const body = await this.parseJsonBody(request);
    console.log('🔍 Request body:', body);

    if (!body || !body.jwt_token) {
      throw new WpException(400, "Missing jwt_token", "Bad request", "jwt_token is required in request body");
    }

    const token = body.jwt_token;
    console.log('🔍 JWT token length:', token.length);
    console.log('🔍 JWT token start:', token.substring(0, 50) + '...');

    try {
      const wpClient = new WordPressClient();
      const user = await wpClient.getUser(token);
      
      console.log('✅ User data retrieved successfully:', user);
      return this.jsonResponse({ 
        success: true,
        user: user 
      });
      
    } catch (error) {
      console.log('💥 Error in get_user:', error);
      if (error instanceof WpException) {
        throw error;
      }
      
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new WpException(500, "Get user failed", "Internal Server Error", errorMessage);
    }
  }
}

// Handler de register
class WpRegister extends RequestHandler {
  async handle(request: Request): Promise<Response> {
    const body = await this.parseJsonBody(request);

    if (!body || !body.username || !body.password || !body.email) {
      throw new WpException(400, "Missing required fields", "Bad request", "username, password, and email are required");
    }

    try {
      const wpClient = new WordPressClient();
      const user = await wpClient.registerUser(body);
      
      // 🔄 SINCRONIZACIÓN AUTOMÁTICA DE MEMBRESÍAS después de registro
      let syncResult = { synced: 0, created: 0, updated: 0, deactivated: 0 };
      let loginToken = null;
      
      try {
        console.log('🔄 Starting automatic membership sync after registration...');
        
        // Hacer login automáticamente para obtener token
        const loginResult = await wpClient.userLogin(body.username, body.password);
        loginToken = loginResult.token;
        
        // Sincronizar membresías con Supabase usando el user.id
        syncResult = await syncUserMemberships(loginResult.user.id, loginToken);
        console.log(`✅ Sync completed: ${syncResult.synced} total`);
      } catch (syncError) {
        // No fallar el registro si falla la sincronización
        console.error('⚠️  Membership sync failed (non-critical):', syncError);
      }
      
      return this.jsonResponse({
        success: true,
        user: user,
        token: loginToken, // Incluir token para login automático
        memberships_synced: syncResult.synced,
        sync_details: syncResult
      });
      
    } catch (error) {
      if (error instanceof WpException) {
        throw error;
      }
      
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new WpException(500, "Registration failed", "Internal Server Error", errorMessage);
    }
  }
}

// Handler de membresías RCP
class WpMemberships extends RequestHandler {
  async handle(request: Request): Promise<Response> {
    console.log('🔒 WpMemberships.handle called');
    
    const body = await this.parseJsonBody(request);

    if (!body || !body.jwt_token) {
      throw new WpException(400, "Missing jwt_token", "Bad request", "jwt_token is required in request body");
    }

    try {
      const wpClient = new WordPressClient();
      const memberships = await wpClient.getUserMemberships(body.jwt_token);
      
      return this.jsonResponse({
        success: true,
        ...memberships
      });
      
    } catch (error) {
      if (error instanceof WpException) {
        throw error;
      }
      
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new WpException(500, "Get memberships failed", "Internal Server Error", errorMessage);
    }
  }
}

// Handler de verificación de acceso
class WpCheckAccess extends RequestHandler {
  async handle(request: Request): Promise<Response> {
    console.log('🔐 WpCheckAccess.handle called');
    
    const body = await this.parseJsonBody(request);

    if (!body || !body.jwt_token || !body.content_id) {
      throw new WpException(400, "Missing required fields", "Bad request", "jwt_token and content_id are required");
    }

    try {
      const wpClient = new WordPressClient();
      const accessInfo = await wpClient.checkUserAccess(body.jwt_token, body.content_id);
      
      return this.jsonResponse({
        success: true,
        ...accessInfo
      });
      
    } catch (error) {
      if (error instanceof WpException) {
        throw error;
      }
      
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new WpException(500, "Check access failed", "Internal Server Error", errorMessage);
    }
  }
}

// Handler para actualizar el catálogo de membresías
class UpdateMembershipCatalogHandler extends RequestHandler {
  async handle(request: Request): Promise<Response> {
    console.log('🔄 Starting membership catalog update...');
    
    const body = await this.parseJsonBody(request);
    const levels = body?.levels;

    if (!levels || !Array.isArray(levels) || levels.length === 0) {
      throw new WpException(400, "Invalid request", "Bad request", "levels array with at least one level is required");
    }

    console.log(`📦 Updating ${levels.length} membership level(s)...`);

    const results = {
      updated: 0,
      created: 0,
      errors: [] as string[]
    };

    // Get Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    
    if (!supabaseUrl || !supabaseKey) {
      throw new WpException(500, "Configuration error", "Internal Server Error", "Supabase configuration missing");
    }

    const { createClient } = await import('jsr:@supabase/supabase-js@2');
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Procesar cada nivel
    for (const level of levels) {
      try {
        // Validar datos requeridos
        if (!level.wordpress_rcp_id || !level.name || !level.access_level) {
          results.errors.push(
            `Missing required fields for level: ${JSON.stringify(level)}`
          );
          continue;
        }

        // Validar access_level
        if (level.access_level < 1 || level.access_level > 3) {
          results.errors.push(
            `Invalid access_level ${level.access_level} for ${level.name}. Must be 1, 2, or 3.`
          );
          continue;
        }

        console.log(`🔍 Processing: ${level.name} (RCP ID: ${level.wordpress_rcp_id}, Access Level: ${level.access_level})`);

        // Verificar si ya existe
        const { data: existingLevel, error: checkError } = await supabase
          .from('membership_levels')
          .select('id, name')
          .eq('wordpress_rcp_id', level.wordpress_rcp_id)
          .single();

        if (checkError && checkError.code !== 'PGRST116') {
          console.error('❌ Error checking existing level:', checkError);
          results.errors.push(
            `Error checking level ${level.wordpress_rcp_id}: ${checkError.message}`
          );
          continue;
        }

        if (existingLevel) {
          // Actualizar nivel existente
          console.log(`📝 Updating existing level: ${existingLevel.name} → ${level.name}`);
          
          const updateData: Record<string, unknown> = {
            name: level.name,
            access_level: level.access_level,
            updated_at: new Date().toISOString()
          };

          if (level.description) {
            updateData.description = level.description;
          }

          const { error: updateError } = await supabase
            .from('membership_levels')
            .update(updateData)
            .eq('id', existingLevel.id);

          if (updateError) {
            console.error('❌ Error updating level:', updateError);
            results.errors.push(
              `Error updating level ${level.wordpress_rcp_id}: ${updateError.message}`
            );
            continue;
          }

          console.log(`✅ Updated: ${level.name}`);
          results.updated++;
        } else {
          // Crear nuevo nivel
          console.log(`➕ Creating new level: ${level.name}`);
          
          const insertData: Record<string, unknown> = {
            wordpress_rcp_id: level.wordpress_rcp_id,
            name: level.name,
            access_level: level.access_level
          };

          if (level.description) {
            insertData.description = level.description;
          }

          const { error: insertError } = await supabase
            .from('membership_levels')
            .insert(insertData);

          if (insertError) {
            console.error('❌ Error creating level:', insertError);
            results.errors.push(
              `Error creating level ${level.wordpress_rcp_id}: ${insertError.message}`
            );
            continue;
          }

          console.log(`✅ Created: ${level.name}`);
          results.created++;
        }
      } catch (error) {
        console.error('❌ Error processing level:', error);
        results.errors.push(
          `Error processing level ${level.wordpress_rcp_id}: ${error instanceof Error ? error.message : String(error)}`
        );
      }
    }

    console.log(`✅ Catalog update completed: ${results.updated} updated, ${results.created} created, ${results.errors.length} errors`);

    // Obtener el catálogo actualizado
    const { data: updatedCatalog, error: catalogError } = await supabase
      .from('membership_levels')
      .select('id, name, wordpress_rcp_id, access_level, description, created_at, updated_at')
      .order('access_level', { ascending: true });

    if (catalogError) {
      console.error('❌ Error fetching updated catalog:', catalogError);
    }

    return this.jsonResponse({
      success: true,
      message: 'Membership catalog updated successfully',
      results,
      catalog: updatedCatalog || []
    });
  }
}

// Handler para sincronizar el catálogo desde WordPress
class SyncMembershipCatalogHandler extends RequestHandler {
  async handle(request: Request): Promise<Response> {
    console.log('🔄 SyncMembershipCatalogHandler.handle called');
    
    try {
      // Importar la función de sincronización
      const { syncMembershipCatalog } = await import('./api/v1/sync_membership_catalog.ts');
      
      // Ejecutar sincronización
      const result = await syncMembershipCatalog();
      
      return this.jsonResponse(result);
      
    } catch (error) {
      console.error('❌ Sync catalog error:', error);
      
      if (error instanceof WpException) {
        throw error;
      }
      
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new WpException(500, "Sync catalog failed", "Internal Server Error", errorMessage);
    }
  }
}

// Router principal V1
class V1APIRouter {
  private getPath(request: Request): string {
    const fullPath = extractPath(request);
    return extractConcretePath(this.getApiVersion(), fullPath);
  }

  getApiVersion(): string {
    return "v1";
  }

  async handle(request: Request): Promise<Response> {
    const path = this.getPath(request);
    const method = request.method;

    try {
      if (method === 'OPTIONS') {
        return new Response(null, { status: 200, headers: corsHeaders });
      }

      const routeKey = `${method}:${path}`;
      
      switch (routeKey) {
        case 'GET:version':
          return new Response(
            JSON.stringify({ 
              version: this.getApiVersion(),
              status: 'working',
              wordpress: {
                url: WP_CONFIG.url,
                connected: true
              },
              endpoints: ['version', 'login', 'get_user', 'register', 'memberships', 'check_access', 'sync_memberships', 'update_membership_catalog', 'sync_membership_catalog'],
              rcp: {
                enabled: true,
                features: ['memberships', 'content_restriction', 'access_control']
              }
            }),
            { headers: corsHeaders, status: 200 }
          );

        case 'POST:login':
          const loginHandler = new WPLogin();
          return await loginHandler.handle(request);

        case 'POST:get_user':
          console.log('🔍 Debug - Handling POST:get_user');
          const getUserHandler = new WpGetUser();
          return await getUserHandler.handle(request);

        case 'POST:register':
          const registerHandler = new WpRegister();
          return await registerHandler.handle(request);

        case 'POST:memberships':
          console.log('🔍 Debug - Handling POST:memberships');
          const membershipsHandler = new WpMemberships();
          return await membershipsHandler.handle(request);

        case 'POST:check_access':
          console.log('🔍 Debug - Handling POST:check_access');
          const checkAccessHandler = new WpCheckAccess();
          return await checkAccessHandler.handle(request);

        case 'POST:sync_memberships':
          console.log('🔍 Debug - Handling POST:sync_memberships');
          const syncHandler = new SyncMembershipsHandler();
          return await syncHandler.handle(request);

        case 'POST:update_membership_catalog':
          console.log('🔍 Debug - Handling POST:update_membership_catalog');
          const updateCatalogHandler = new UpdateMembershipCatalogHandler();
          return await updateCatalogHandler.handle(request);

        case 'POST:sync_membership_catalog':
          console.log('🔍 Debug - Handling POST:sync_membership_catalog');
          const syncCatalogHandler = new SyncMembershipCatalogHandler();
          return await syncCatalogHandler.handle(request);

        default:
          throw new WpException(404, "Resource not found", "Not found", `Route ${routeKey} not found`);
      }

    } catch (error) {
      console.error('Error in V1APIRouter:', error);
      return this.handleExceptions(request, error);
    }
  }

  private handleExceptions(request: Request, error: unknown): Response {
    let wpException: WpException;

    if (error instanceof WpException) {
      wpException = error;
    } else if (error instanceof Error) {
      wpException = new WpException(500, "Unknown error", "Internal Server Error", error.message);
    } else {
      wpException = new WpException(500, "Unknown error", "Internal Server Error", String(error));
    }

    console.error(`ERROR: Request: ${request.method} ${request.url} -> ${wpException.status} - ${wpException.reason}`);

    return new Response(
      JSON.stringify(wpException.toJson()),
      {
        status: wpException.status,
        statusText: wpException.statusText,
        headers: corsHeaders
      }
    );
  }
}

// Función principal
Deno.serve(async (request: Request) => {
  try {
    console.log(`📨 ${request.method} ${request.url}`);
    
    const apiVersion = extractApiVersion(request);
    let handler: V1APIRouter | null = null;

    if (apiVersion === 'v1') {
      handler = new V1APIRouter();
    }

    if (handler !== null) {
      return await handler.handle(request);
    } else {
      return new Response(
        JSON.stringify({ error: 'API version not found', version: apiVersion }),
        {
          status: 404,
          statusText: "Not found",
          headers: corsHeaders
        }
      );
    }
  } catch (error) {
    console.error('Error in main handler:', error);
    const errorMessage = error instanceof Error ? error.message : String(error);
    return new Response(
      JSON.stringify({ 
        error: 'Internal Server Error',
        details: errorMessage
      }),
      {
        status: 500,
        statusText: "Internal Server Error",
        headers: corsHeaders
      }
    );
  }
});

console.log('✅ WordPress function loaded successfully!');
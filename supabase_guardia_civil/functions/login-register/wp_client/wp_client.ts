// wp_client.ts

import { Customer } from './model/customer.ts';
import { Membership } from './model/membership.ts';
import { MembershipLevel, MembershipCategory } from './model/membership_level.ts';
import { RegisterRequest } from './model/register_request.ts';
import { User } from './model/user.ts';
import { WpException } from './model/wp_exception.ts';
import { WpJsonError } from './model/wp_json_error.ts';

export class WPClient {
  private wpUrl: string;
  private wpUsername: string;
  private wpPassword: string;
  private supabaseClient: any;

  static readonly RCP_VERSION = 'v1';
  static readonly JWT_AUTH_VERSION = 'v1';
  constructor(supabaseClient: any) {
    // Intentar primero WP_URL, luego WP_APP_URL para compatibilidad
    this.wpUrl = (Deno.env.get('WP_URL') || Deno.env.get('WP_APP_URL') || '').replace(/\/$/, '');
    this.wpUsername = Deno.env.get('WP_ADMIN_USERNAME') || Deno.env.get('WP_APP_USERNAME') || '';
    this.wpPassword = Deno.env.get('WP_ADMIN_PASSWORD') || Deno.env.get('WP_APP_PASS') || '';
    this.supabaseClient = supabaseClient;

    // Validar que las variables estén configuradas
    if (!this.wpUrl || !this.wpUsername || !this.wpPassword) {
      console.error('❌ WordPress configuration missing:');
      console.error(`  WP_URL: ${this.wpUrl ? '✓' : '✗'}`);
      console.error(`  WP_ADMIN_USERNAME: ${this.wpUsername ? '✓' : '✗'}`);
      console.error(`  WP_ADMIN_PASSWORD: ${this.wpPassword ? '✓' : '✗'}`);
    } else {
      console.log(`✓ WordPress client configured for: ${this.wpUrl}`);
    }
  }

  async getAdminToken(): Promise<string> {
    const errorMsg = 'Error getting token';
    
    const response = await this.makeWpCall(
      `jwt-auth/${WPClient.JWT_AUTH_VERSION}/token`,
      'token',
      JSON.stringify({
        username: this.wpUsername,
        password: this.wpPassword,
      }),
      undefined,
      true,
      true
    );

    this.checkResponseError(response, errorMsg);
    const data = JSON.parse(response.body);
    return data.token;
  }

  async userLogin(email: string, password: string): Promise<string> {
    const errorMsg = 'Error in sign in';
    
    const response = await this.makeWpCall(
      `jwt-auth/${WPClient.JWT_AUTH_VERSION}/token`,
      'user-login',
      JSON.stringify({
        username: email,
        password: password,
      }),
      undefined,
      true,
      true
    );

    this.checkResponseError(response, errorMsg);
    const data = JSON.parse(response.body);
    return data.token;
  }

  async getUser(userToken: string): Promise<User> {
    const errorMsg = 'Error getting user';

    const response = await this.makeWpCall(
      'wp/v2/users/me?context=edit',
      'get-user',
      undefined,
      userToken,
      false
    );

    this.checkResponseError(response, `${errorMsg}: getuser`);
    let user = User.fromJson(JSON.parse(response.body));
    const userId = user.id;

    const adminToken = await this.getAdminToken();
    const membershipTypes = await this.getAllActiveMembershipTypes();

    const customer = await this.getCustomer(adminToken, {
      userId: userId.toString(),
      membershipTypes,
      onlyActives: true,
    });

    user = user.copyWith({
      memberships: customer.memberships,
      betatester: customer.memberships.some(m => m.betatester),
    });

    return user;
  }

  async createMembership(token: string, membership: Membership): Promise<Membership> {
    const errorMsg = 'Error creating membership';

    const response = await this.makeWpCall(
      `rcp/${WPClient.RCP_VERSION}/memberships/new`,
      'new-membership',
      JSON.stringify(membership.toJson()),
      token,
      true,
      true
    );

    this.checkResponseError(response, errorMsg);
    return membership.copyWith({ id: response.body });
  }

  async updateMembership(token: string, membership: Membership): Promise<void> {
    const wpEndpoint = `rcp/${WPClient.RCP_VERSION}/memberships/update/${membership.id}`;

    await this.makeWpCall(
      wpEndpoint,
      'update-membership',
      JSON.stringify(membership.toJson()),
      token,
      true,
      true
    );
  }

  async cancelMembership(token: string, membershipId: string): Promise<void> {
    const wpEndpoint = `rcp/${WPClient.RCP_VERSION}/memberships/${membershipId}/cancel`;

    await this.makeWpCall(
      wpEndpoint,
      'cancel-membership',
      undefined,
      token
    );
  }

  async register(request: RegisterRequest): Promise<User> {
    const errorMsg = 'Error during sign up';
    const token = await this.getAdminToken();

    // Crear usuario en WordPress
    const userResponse = await this.makeWpCall(
      'wp/v2/users',
      'create-user',
      JSON.stringify(request.toJson()),
      token,
      true,
      true
    );

    this.checkResponseError(userResponse, errorMsg);
    let user = User.fromJson(JSON.parse(userResponse.body));

    // Crear customer en RCP
    const customerResponse = await this.makeWpCall(
      `rcp/${WPClient.RCP_VERSION}/customers/new`,
      'create-customer',
      JSON.stringify({ user_id: user.id }),
      token,
      true,
      true
    );

    this.checkResponseError(customerResponse, errorMsg);
    const customerId = JSON.parse(customerResponse.body);

    // Obtener membresía freemium desde Supabase
    const freemiumLevel = await this.getMembershipLevelByCategory(MembershipCategory.FREEMIUM);
    
    if (!freemiumLevel) {
      throw new WpException(500, 'Freemium membership level not found');
    }

    // Crear membresía freemium
    const membership = new Membership(false, 'active', false);
    membership.customerId = customerId.toString();
    membership.membershipLevel = freemiumLevel;

    const createdMembership = await this.createMembership(token, membership);
    user = user.copyWith({ memberships: [createdMembership] });

    return user;
  }

  async getCustomer(
    token: string,
    options: {
      userId: string;
      membershipTypes: string[];
      onlyActives?: boolean;
    }
  ): Promise<Customer> {
    const { userId, membershipTypes, onlyActives = true } = options;

    const response = await this.getCustomerByUserId(token, userId);
    const customerData = JSON.parse(response.body) as Record<string, any>;

    if (!customerData.id) {
      throw new WpException(404, 'Customer not found');
    }

    const customerId = customerData.id;

    if (!customerData.memberships || customerData.memberships.length === 0) {
      return new Customer(customerId, []);
    }

    // Construir query para obtener membresías
    const activeStatus = onlyActives ? 'status__in[]=active&status__in[]=cancelled' : '';
    const membershipIDs = customerData.memberships.map((id: any) => `id__in[]=${id}`);
    const membershipIdParams = membershipIDs.join('&');
    const objectTypeIDs = membershipTypes.map(type => `object_id__in[]=${type}`);
    const objectIdParams = objectTypeIDs.join('&');

    const wpRequestUrl = `rcp/${WPClient.RCP_VERSION}/memberships/?${activeStatus}&${membershipIdParams}&${objectIdParams}`;

    const membershipsResponse = await this.makeWpCall(
      wpRequestUrl,
      'get-user-memberships',
      undefined,
      token,
      false
    );

    let hasActiveSubscriptions = true;
    
    try {
      this.checkResponseError(membershipsResponse, 'Error getting memberships', (error) => {
        if (error.errors?.no_memberships) {
          hasActiveSubscriptions = false;
          return false;
        }
        return true;
      });
    } catch (e) {
      if (!hasActiveSubscriptions) {
        return new Customer(customerId, []);
      }
      throw e;
    }

    if (hasActiveSubscriptions) {
      const membershipsList = JSON.parse(membershipsResponse.body) as any[];
      const memberships = membershipsList.map(m => Membership.fromJson(m));
      
      const uniqueMemberships = Array.from(
        new Set(memberships.map(m => m.id))
      ).map(id => memberships.find(m => m.id === id)!);

      return new Customer(customerId, uniqueMemberships);
    }

    return new Customer(customerId, []);
  }

  private checkResponseError(
    response: { statusCode: number; reasonPhrase?: string; body: string },
    errorMsg: string,
    customErrorCheck?: (error: any) => boolean
  ): void {
    let parsedResponse: any;
    
    try {
      parsedResponse = JSON.parse(response.body);
    } catch (e) {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw new WpException(
          response.statusCode,
          errorMsg,
          response.reasonPhrase,
          response.body
        );
      }
      return;
    }

    if (parsedResponse && typeof parsedResponse === 'object') {
      if (parsedResponse.code && parsedResponse.message) {
        if (!customErrorCheck || customErrorCheck(parsedResponse)) {
          throw new WpException(
            response.statusCode,
            errorMsg,
            response.reasonPhrase,
            JSON.stringify(parsedResponse)
          );
        }
      }

      if (parsedResponse.errors) {
        const wpJsonError = WpJsonError.fromJson(parsedResponse);
        
        if (wpJsonError.errors) {
          if (!customErrorCheck || customErrorCheck(wpJsonError)) {
            throw new WpException(
              response.statusCode,
              errorMsg,
              response.reasonPhrase,
              response.body
            );
          }
        }
      }
    }
  }

  private async makeWpCall(
    wpEndpoint: string,
    wpCallName: string,
    body?: string,
    token?: string,
    isPost: boolean = true,
    isJson: boolean = false
  ): Promise<{ statusCode: number; reasonPhrase?: string; body: string }> {
    const url = `${this.wpUrl}/wp-json/${wpEndpoint}`;
    const headers: Record<string, string> = {};
    
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    console.log(`🌐 Making WordPress call: ${wpCallName} to ${url}`);

    try {
      const response = isPost
        ? await fetch(url, {
            method: 'POST',
            headers,
            body: body,
          })
        : await fetch(url, {
            method: 'GET',
            headers,
          });

      console.log(`✓ WordPress response for ${wpCallName}: ${response.status} ${response.statusText}`);

      return {
        statusCode: response.status,
        reasonPhrase: response.statusText,
        body: await response.text(),
      };
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      console.error(`❌ WordPress connection error in ${wpCallName}:`, errorMessage);
      console.error(`   URL: ${url}`);
      console.error(`   WP_URL configured: ${this.wpUrl}`);
      
      // Proporcionar un mensaje más descriptivo
      let userMessage = 'Error de conexión con WordPress';
      if (errorMessage.includes('name resolution failed')) {
        userMessage = 'No se puede conectar al servidor WordPress. Verifica tu conexión a internet y que el servidor esté disponible.';
      } else if (errorMessage.includes('network') || errorMessage.includes('timeout')) {
        userMessage = 'Tiempo de espera agotado al conectar con WordPress. El servidor podría estar caído.';
      }
      
      throw new WpException(
        503,
        userMessage,
        'Service Temporarily Unavailable',
        JSON.stringify({
          message: errorMessage,
          url: url,
          callName: wpCallName,
        })
      );
    }
  }

  private async getCustomerByUserId(token: string, userId: string): Promise<{ body: string }> {
    return this.makeWpCall(
      `rcp/${WPClient.RCP_VERSION}/customers?user_id=${userId}`,
      'get-customer',
      undefined,
      token,
      false
    );
  }

  private async getAllActiveMembershipTypes(): Promise<string[]> {
    const { data, error } = await this.supabaseClient
      .from('membership_levels')
      .select('wordpress_rcp_id')
      .eq('is_active', true);

    if (error) {
      const errorMessage = error && typeof error === 'object' && 'message' in error 
        ? (error as { message: string }).message 
        : 'Unknown error';
      throw new Error(`Error fetching membership types: ${errorMessage}`);
    }

    return data.map((item: any) => String(item.wordpress_rcp_id));
  }

  private async getMembershipLevelByCategory(category: MembershipCategory): Promise<MembershipLevel | null> {
    // Mapear category a access_level: FREEMIUM=1, PREMIUM=2, PREMIUM_PLUS=3
    let accessLevel = 1; // Default FREEMIUM
    if (category === MembershipCategory.PREMIUM || category === MembershipCategory.BASIC) {
      accessLevel = 2;
    } else if (category === MembershipCategory.PREMIUM_PLUS || category === MembershipCategory.PRO) {
      accessLevel = 3;
    }

    console.log(`🔍 Searching for membership level: category=${category}, access_level=${accessLevel}`);

    const { data, error } = await this.supabaseClient
      .from('membership_levels')
      .select('*')
      .eq('access_level', accessLevel)
      .eq('is_active', true)
      .limit(1)
      .single();

    if (error) {
      console.error(`❌ Error fetching membership level by category: ${error.message}`);
      console.error(`   Details: ${JSON.stringify(error)}`);

      // Diagnóstico: mostrar todas las membresías disponibles
      const { data: allLevels, error: allError } = await this.supabaseClient
        .from('membership_levels')
        .select('id, name, access_level, is_active, specialty_id');

      if (!allError && allLevels) {
        console.error(`📋 ALL membership levels in database (${allLevels.length} total):`);
        allLevels.forEach((level: any) => {
          console.error(`   - ${level.name}: access_level=${level.access_level}, is_active=${level.is_active}, specialty_id=${level.specialty_id}`);
        });
      } else {
        console.error(`❌ Could not fetch membership levels for diagnostics: ${allError?.message}`);
      }

      return null;
    }

    if (data) {
      console.log(`✅ Found membership level: ${data.name} (id=${data.id}, access_level=${data.access_level}, is_active=${data.is_active})`);
    } else {
      console.warn(`⚠️ No membership level found for category=${category}, access_level=${accessLevel}`);
    }

    return data ? MembershipLevel.fromJson(data) : null;
  }

  async deleteUser(userId: number): Promise<void> {
    const errorMsg = 'Error deleting user';
    const token = await this.getAdminToken();

    console.log(`🗑️ Attempting to delete user with ID: ${userId}`);

    // Eliminar usuario de WordPress usando la REST API con método DELETE
    const deleteResponse = await this.makeDeleteWpCall(
      `wp/v2/users/${userId}?force=true&reassign=1`,
      'delete-user',
      token
    );

    this.checkResponseError(deleteResponse, errorMsg);
    console.log(`✓ User ${userId} deleted successfully from WordPress`);
  }

  private async makeDeleteWpCall(
    wpEndpoint: string,
    wpCallName: string,
    token?: string
  ): Promise<{ statusCode: number; reasonPhrase?: string; body: string }> {
    const url = `${this.wpUrl}/wp-json/${wpEndpoint}`;
    const headers: Record<string, string> = {};

    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    console.log(`🌐 Making WordPress DELETE call: ${wpCallName} to ${url}`);

    try {
      const response = await fetch(url, {
        method: 'DELETE',
        headers,
      });

      console.log(`✓ WordPress response for ${wpCallName}: ${response.status} ${response.statusText}`);

      return {
        statusCode: response.status,
        reasonPhrase: response.statusText,
        body: await response.text(),
      };
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      console.error(`❌ WordPress connection error in ${wpCallName}:`, errorMessage);
      console.error(`   URL: ${url}`);
      console.error(`   WP_URL configured: ${this.wpUrl}`);

      let userMessage = 'Error de conexión con WordPress';
      if (errorMessage.includes('name resolution failed')) {
        userMessage = 'No se puede conectar al servidor WordPress. Verifica tu conexión a internet y que el servidor esté disponible.';
      } else if (errorMessage.includes('network') || errorMessage.includes('timeout')) {
        userMessage = 'Tiempo de espera agotado al conectar con WordPress. El servidor podría estar caído.';
      }

      throw new WpException(
        503,
        userMessage,
        'Service Temporarily Unavailable',
        JSON.stringify({
          message: errorMessage,
          url: url,
          callName: wpCallName,
        })
      );
    }
  }
}
// revenuecat/models/webhook_event.ts
import { Subscription } from './subscription.ts';

/**
 * RevenueCat Webhook Event Types
 * @see https://www.revenuecat.com/docs/webhooks
 */
export type WebhookEventType =
  | 'INITIAL_PURCHASE'           // Primera compra
  | 'RENEWAL'                    // Renovación automática
  | 'CANCELLATION'               // Cancelación de suscripción
  | 'UNCANCELLATION'             // Reactivación de suscripción
  | 'NON_RENEWING_PURCHASE'      // Compra no renovable
  | 'SUBSCRIPTION_PAUSED'        // Suscripción pausada
  | 'EXPIRATION'                 // Expiración de suscripción
  | 'BILLING_ISSUE'              // Problema de facturación
  | 'PRODUCT_CHANGE'             // Cambio de producto
  | 'TRANSFER'                   // Transferencia entre usuarios
  | 'TEST';                      // Evento de prueba

/**
 * Subscriber attributes from RevenueCat
 */
export interface SubscriberAttributes {
  [key: string]: {
    value: string | null;
    updated_at_ms: number;
  };
}

/**
 * Entitlement information
 */
export interface Entitlement {
  expires_date: string | null;
  grace_period_expires_date: string | null;
  purchase_date: string;
  product_identifier: string;
}

/**
 * Product information
 */
export interface Product {
  subscription?: Subscription;
  non_subscription?: {
    purchase_date: string;
    is_sandbox: boolean;
  };
}

/**
 * Complete subscriber information from RevenueCat
 */
export interface SubscriberInfo {
  /**
   * RevenueCat App User ID (puede ser email, UUID, etc.)
   */
  app_user_id: string;

  /**
   * Original App User ID (antes de alias)
   */
  original_app_user_id: string;

  /**
   * Original application version
   */
  original_application_version: string | null;

  /**
   * Original purchase date
   */
  original_purchase_date: string | null;

  /**
   * Management URL for the subscriber
   */
  management_url: string | null;

  /**
   * First seen date
   */
  first_seen: string;

  /**
   * Custom subscriber attributes
   */
  subscriber_attributes: SubscriberAttributes;

  /**
   * Active entitlements
   */
  entitlements: {
    [entitlementId: string]: Entitlement;
  };

  /**
   * All products (subscriptions and non-subscriptions)
   */
  subscriptions: {
    [productId: string]: Product;
  };

  /**
   * Non-subscription purchases
   */
  non_subscriptions: {
    [productId: string]: Array<{
      id: string;
      purchase_date: string;
      store: string;
      is_sandbox: boolean;
    }>;
  };
}

/**
 * Complete RevenueCat Webhook Event
 */
export interface RevenueCatWebhookEvent {
  /**
   * API version (always "1.0" for now)
   */
  api_version: string;

  /**
   * Type of the event
   */
  event: {
    type: WebhookEventType;
    app_user_id: string;
    original_app_user_id: string;
    product_id: string;
    entitlement_id: string | null;
    entitlement_ids: string[];
    period_type: 'trial' | 'intro' | 'normal';
    purchased_at_ms: number;
    expiration_at_ms: number | null;
    environment: 'SANDBOX' | 'PRODUCTION';
    presented_offering_id: string | null;
    transaction_id: string;
    original_transaction_id: string;
    is_family_share: boolean;
    country_code: string;
    app_id: string;
    aliases: string[];
    takehome_percentage: number;
    offer_code: string | null;
    tax_percentage: number;
    commission_percentage: number;
    currency: string;
    price: number;
    price_in_purchased_currency: number;
    subscriber_attributes: SubscriberAttributes;
    store: 'app_store' | 'mac_app_store' | 'play_store' | 'amazon' | 'stripe' | 'promotional';
    cancel_reason: string | null;
    new_product_id: string | null;
  };
}

/**
 * Helper para validar que el webhook es de RevenueCat
 */
export function isValidRevenueCatWebhook(body: unknown): body is RevenueCatWebhookEvent {
  if (!body || typeof body !== 'object') return false;
  
  const webhook = body as Record<string, unknown>;
  
  return (
    typeof webhook.api_version === 'string' &&
    webhook.event !== null &&
    typeof webhook.event === 'object' &&
    'type' in webhook.event &&
    'app_user_id' in webhook.event
  );
}

/**
 * Helper para extraer el email del app_user_id
 * (asumiendo que usamos email como app_user_id)
 */
export function extractEmailFromAppUserId(appUserId: string): string | null {
  // Si ya es un email, retornarlo
  if (appUserId.includes('@')) {
    return appUserId.toLowerCase();
  }
  
  // Si es un UUID u otro formato, necesitarás buscarlo en tu base de datos
  return null;
}

/**
 * Helper para determinar si el evento requiere sincronización
 */
export function shouldSyncEvent(eventType: WebhookEventType): boolean {
  const syncEvents: WebhookEventType[] = [
    'INITIAL_PURCHASE',
    'RENEWAL',
    'CANCELLATION',
    'UNCANCELLATION',
    'EXPIRATION',
    'PRODUCT_CHANGE',
  ];
  
  return syncEvents.includes(eventType);
}

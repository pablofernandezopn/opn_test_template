// revenuecat/examples/webhook_payloads.ts
/**
 * Ejemplos de payloads de webhooks de RevenueCat
 * Útiles para testing y desarrollo
 */

import type { RevenueCatWebhookEvent } from '../models/index.ts';

/**
 * Ejemplo: INITIAL_PURCHASE - Primera compra de Premium
 */
export const initialPurchaseExample: RevenueCatWebhookEvent = {
  api_version: "1.0",
  event: {
    type: "INITIAL_PURCHASE",
    app_user_id: "usuario@ejemplo.com",
    original_app_user_id: "usuario@ejemplo.com",
    product_id: "opn_gc_premium_monthly",
    entitlement_id: "premium_access",
    entitlement_ids: ["premium_access"],
    period_type: "normal",
    purchased_at_ms: 1696291200000,
    expiration_at_ms: 1698969600000,
    environment: "PRODUCTION",
    presented_offering_id: "default_offering",
    transaction_id: "1000000123456789",
    original_transaction_id: "1000000123456789",
    is_family_share: false,
    country_code: "ES",
    app_id: "1234567890",
    aliases: [],
    takehome_percentage: 0.85,
    offer_code: null,
    tax_percentage: 0.21,
    commission_percentage: 0.15,
    currency: "EUR",
    price: 9.99,
    price_in_purchased_currency: 9.99,
    subscriber_attributes: {
      "$email": {
        value: "usuario@ejemplo.com",
        updated_at_ms: 1696291200000
      }
    },
    store: "app_store",
    cancel_reason: null,
    new_product_id: null
  }
};

/**
 * Ejemplo: RENEWAL - Renovación automática
 */
export const renewalExample: RevenueCatWebhookEvent = {
  api_version: "1.0",
  event: {
    type: "RENEWAL",
    app_user_id: "usuario@ejemplo.com",
    original_app_user_id: "usuario@ejemplo.com",
    product_id: "opn_gc_premium_monthly",
    entitlement_id: "premium_access",
    entitlement_ids: ["premium_access"],
    period_type: "normal",
    purchased_at_ms: 1698969600000,
    expiration_at_ms: 1701648000000,
    environment: "PRODUCTION",
    presented_offering_id: "default_offering",
    transaction_id: "1000000123456790",
    original_transaction_id: "1000000123456789",
    is_family_share: false,
    country_code: "ES",
    app_id: "1234567890",
    aliases: [],
    takehome_percentage: 0.85,
    offer_code: null,
    tax_percentage: 0.21,
    commission_percentage: 0.15,
    currency: "EUR",
    price: 9.99,
    price_in_purchased_currency: 9.99,
    subscriber_attributes: {
      "$email": {
        value: "usuario@ejemplo.com",
        updated_at_ms: 1696291200000
      }
    },
    store: "app_store",
    cancel_reason: null,
    new_product_id: null
  }
};

/**
 * Ejemplo: CANCELLATION - Usuario cancela suscripción
 */
export const cancellationExample: RevenueCatWebhookEvent = {
  api_version: "1.0",
  event: {
    type: "CANCELLATION",
    app_user_id: "usuario@ejemplo.com",
    original_app_user_id: "usuario@ejemplo.com",
    product_id: "opn_gc_premium_monthly",
    entitlement_id: "premium_access",
    entitlement_ids: ["premium_access"],
    period_type: "normal",
    purchased_at_ms: 1696291200000,
    expiration_at_ms: 1698969600000,
    environment: "PRODUCTION",
    presented_offering_id: "default_offering",
    transaction_id: "1000000123456789",
    original_transaction_id: "1000000123456789",
    is_family_share: false,
    country_code: "ES",
    app_id: "1234567890",
    aliases: [],
    takehome_percentage: 0.85,
    offer_code: null,
    tax_percentage: 0.21,
    commission_percentage: 0.15,
    currency: "EUR",
    price: 9.99,
    price_in_purchased_currency: 9.99,
    subscriber_attributes: {
      "$email": {
        value: "usuario@ejemplo.com",
        updated_at_ms: 1696291200000
      }
    },
    store: "app_store",
    cancel_reason: "UNSUBSCRIBE",
    new_product_id: null
  }
};

/**
 * Ejemplo: PRODUCT_CHANGE - Upgrade de Premium a Premium+
 */
export const productChangeExample: RevenueCatWebhookEvent = {
  api_version: "1.0",
  event: {
    type: "PRODUCT_CHANGE",
    app_user_id: "usuario@ejemplo.com",
    original_app_user_id: "usuario@ejemplo.com",
    product_id: "opn_gc_premium_plus_monthly",
    entitlement_id: "premium_plus_access",
    entitlement_ids: ["premium_plus_access"],
    period_type: "normal",
    purchased_at_ms: 1697500800000,
    expiration_at_ms: 1700179200000,
    environment: "PRODUCTION",
    presented_offering_id: "upgrade_offering",
    transaction_id: "1000000123456791",
    original_transaction_id: "1000000123456789",
    is_family_share: false,
    country_code: "ES",
    app_id: "1234567890",
    aliases: [],
    takehome_percentage: 0.85,
    offer_code: null,
    tax_percentage: 0.21,
    commission_percentage: 0.15,
    currency: "EUR",
    price: 14.99,
    price_in_purchased_currency: 14.99,
    subscriber_attributes: {
      "$email": {
        value: "usuario@ejemplo.com",
        updated_at_ms: 1696291200000
      }
    },
    store: "app_store",
    cancel_reason: null,
    new_product_id: "opn_gc_premium_plus_monthly"
  }
};

/**
 * Ejemplo: EXPIRATION - Suscripción expira sin renovación
 */
export const expirationExample: RevenueCatWebhookEvent = {
  api_version: "1.0",
  event: {
    type: "EXPIRATION",
    app_user_id: "usuario@ejemplo.com",
    original_app_user_id: "usuario@ejemplo.com",
    product_id: "opn_gc_premium_monthly",
    entitlement_id: "premium_access",
    entitlement_ids: ["premium_access"],
    period_type: "normal",
    purchased_at_ms: 1696291200000,
    expiration_at_ms: 1698969600000,
    environment: "PRODUCTION",
    presented_offering_id: "default_offering",
    transaction_id: "1000000123456789",
    original_transaction_id: "1000000123456789",
    is_family_share: false,
    country_code: "ES",
    app_id: "1234567890",
    aliases: [],
    takehome_percentage: 0.85,
    offer_code: null,
    tax_percentage: 0.21,
    commission_percentage: 0.15,
    currency: "EUR",
    price: 9.99,
    price_in_purchased_currency: 9.99,
    subscriber_attributes: {
      "$email": {
        value: "usuario@ejemplo.com",
        updated_at_ms: 1696291200000
      }
    },
    store: "app_store",
    cancel_reason: null,
    new_product_id: null
  }
};

/**
 * Ejemplo: BILLING_ISSUE - Problema con el pago
 */
export const billingIssueExample: RevenueCatWebhookEvent = {
  api_version: "1.0",
  event: {
    type: "BILLING_ISSUE",
    app_user_id: "usuario@ejemplo.com",
    original_app_user_id: "usuario@ejemplo.com",
    product_id: "opn_gc_premium_monthly",
    entitlement_id: "premium_access",
    entitlement_ids: ["premium_access"],
    period_type: "normal",
    purchased_at_ms: 1696291200000,
    expiration_at_ms: 1698969600000,
    environment: "PRODUCTION",
    presented_offering_id: "default_offering",
    transaction_id: "1000000123456789",
    original_transaction_id: "1000000123456789",
    is_family_share: false,
    country_code: "ES",
    app_id: "1234567890",
    aliases: [],
    takehome_percentage: 0.85,
    offer_code: null,
    tax_percentage: 0.21,
    commission_percentage: 0.15,
    currency: "EUR",
    price: 9.99,
    price_in_purchased_currency: 9.99,
    subscriber_attributes: {
      "$email": {
        value: "usuario@ejemplo.com",
        updated_at_ms: 1696291200000
      }
    },
    store: "app_store",
    cancel_reason: null,
    new_product_id: null
  }
};

/**
 * Ejemplo: TEST - Evento de prueba desde RevenueCat dashboard
 */
export const testExample: RevenueCatWebhookEvent = {
  api_version: "1.0",
  event: {
    type: "TEST",
    app_user_id: "test_user",
    original_app_user_id: "test_user",
    product_id: "opn_gc_premium_monthly",
    entitlement_id: null,
    entitlement_ids: [],
    period_type: "normal",
    purchased_at_ms: Date.now(),
    expiration_at_ms: null,
    environment: "SANDBOX",
    presented_offering_id: null,
    transaction_id: "test_transaction",
    original_transaction_id: "test_transaction",
    is_family_share: false,
    country_code: "US",
    app_id: "1234567890",
    aliases: [],
    takehome_percentage: 0.85,
    offer_code: null,
    tax_percentage: 0,
    commission_percentage: 0.15,
    currency: "USD",
    price: 0,
    price_in_purchased_currency: 0,
    subscriber_attributes: {},
    store: "app_store",
    cancel_reason: null,
    new_product_id: null
  }
};

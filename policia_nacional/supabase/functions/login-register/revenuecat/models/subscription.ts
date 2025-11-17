// revenuecat/models/subscription.ts
/**
 * Subscription model from RevenueCat webhook
 * Represents a subscription purchase with all its lifecycle dates
 */

export interface Subscription {
  /**
   * The ISO 8601 datetime of the latest known expiration date.
   */
  expires_date: string | null;

  /**
   * The ISO 8601 datetime of the latest purchase or renewal.
   */
  purchase_date: string | null;

  /**
   * The ISO 8601 datetime of the first recorded purchase of this product.
   */
  original_purchase_date: string | null;

  /**
   * Possible values: PURCHASED, FAMILY_SHARED.
   */
  ownership_type: 'PURCHASED' | 'FAMILY_SHARED' | null;

  /**
   * Possible values: normal, trial, intro.
   */
  period_type: 'normal' | 'trial' | 'intro';

  /**
   * Possible values: app_store, mac_app_store, play_store, amazon, stripe, promotional.
   */
  store: 'app_store' | 'mac_app_store' | 'play_store' | 'amazon' | 'stripe' | 'promotional';

  /**
   * Boolean indicating whether the subscription was purchased in sandbox or production environment.
   */
  is_sandbox: boolean;

  /**
   * The ISO 8601 datetime that an unsubscribe was detected.
   */
  unsubscribe_detected_at: string | null;

  /**
   * The ISO 8601 datetime that billing issues were detected.
   */
  billing_issues_detected_at: string | null;

  /**
   * The ISO 8601 datetime when the grace period for the subscription would expire.
   */
  grace_period_expires_date: string | null;

  /**
   * The ISO 8601 datetime when the subscription was refunded.
   */
  refunded_at: string | null;

  /**
   * The ISO 8601 datetime when the subscription will resume after being paused.
   */
  auto_resume_date: string | null;
}

/**
 * Helper para parsear fechas de RevenueCat
 */
export function parseRevenueCatDate(dateString: string | null): Date | null {
  if (!dateString) return null;
  try {
    const date = new Date(dateString);
    return isNaN(date.getTime()) ? null : date;
  } catch {
    return null;
  }
}

/**
 * Helper para verificar si una suscripción está activa
 */
export function isSubscriptionActive(subscription: Subscription): boolean {
  // Si fue reembolsada, no está activa
  if (subscription.refunded_at) {
    return false;
  }

  // Si tiene problemas de facturación y no está en período de gracia, no está activa
  if (subscription.billing_issues_detected_at && !subscription.grace_period_expires_date) {
    return false;
  }

  // Si tiene fecha de expiración, verificar que no haya expirado
  if (subscription.expires_date) {
    const expiresDate = parseRevenueCatDate(subscription.expires_date);
    if (expiresDate) {
      const now = new Date();
      
      // Si tiene período de gracia, usar esa fecha
      if (subscription.grace_period_expires_date) {
        const gracePeriodExpires = parseRevenueCatDate(subscription.grace_period_expires_date);
        if (gracePeriodExpires) {
          return now < gracePeriodExpires;
        }
      }
      
      return now < expiresDate;
    }
  }

  // Si no tiene fecha de expiración, asumir que es activa (lifetime?)
  return true;
}

/**
 * Helper para obtener el status de la suscripción
 */
export function getSubscriptionStatus(subscription: Subscription): 'active' | 'cancelled' | 'expired' | 'in_grace_period' | 'billing_issues' {
  if (subscription.refunded_at) {
    return 'cancelled';
  }

  if (subscription.billing_issues_detected_at) {
    if (subscription.grace_period_expires_date) {
      const gracePeriodExpires = parseRevenueCatDate(subscription.grace_period_expires_date);
      if (gracePeriodExpires && new Date() < gracePeriodExpires) {
        return 'in_grace_period';
      }
    }
    return 'billing_issues';
  }

  if (subscription.unsubscribe_detected_at) {
    // Unsubscribe detectado pero aún puede estar activo hasta expires_date
    if (subscription.expires_date) {
      const expiresDate = parseRevenueCatDate(subscription.expires_date);
      if (expiresDate && new Date() < expiresDate) {
        return 'active'; // Activo hasta que expire
      }
    }
    return 'cancelled';
  }

  if (subscription.expires_date) {
    const expiresDate = parseRevenueCatDate(subscription.expires_date);
    if (expiresDate && new Date() >= expiresDate) {
      return 'expired';
    }
  }

  return 'active';
}

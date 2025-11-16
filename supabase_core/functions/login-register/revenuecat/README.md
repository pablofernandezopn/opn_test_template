# 📦 Modelos de RevenueCat

Esta carpeta contiene los modelos TypeScript para trabajar con los webhooks de RevenueCat.

## 📁 Estructura

```
revenuecat/
├── models/
│   ├── index.ts           # Barrel export
│   ├── subscription.ts    # Modelo de Subscription
│   └── webhook_event.ts   # Modelo completo del webhook
```

## 🔷 Modelos Principales

### **Subscription**

Representa una suscripción individual con todos sus datos de ciclo de vida:

```typescript
interface Subscription {
  expires_date: string | null;
  purchase_date: string | null;
  original_purchase_date: string | null;
  ownership_type: 'PURCHASED' | 'FAMILY_SHARED' | null;
  period_type: 'normal' | 'trial' | 'intro';
  store: 'app_store' | 'mac_app_store' | 'play_store' | 'amazon' | 'stripe' | 'promotional';
  is_sandbox: boolean;
  unsubscribe_detected_at: string | null;
  billing_issues_detected_at: string | null;
  grace_period_expires_date: string | null;
  refunded_at: string | null;
  auto_resume_date: string | null;
}
```

**Helpers disponibles:**
- `parseRevenueCatDate(dateString)`: Convierte string ISO 8601 a Date
- `isSubscriptionActive(subscription)`: Verifica si está activa
- `getSubscriptionStatus(subscription)`: Retorna el estado actual

### **RevenueCatWebhookEvent**

Evento completo enviado por RevenueCat:

```typescript
interface RevenueCatWebhookEvent {
  api_version: string;
  event: {
    type: WebhookEventType;
    app_user_id: string;
    product_id: string;
    entitlement_id: string | null;
    purchased_at_ms: number;
    expiration_at_ms: number | null;
    environment: 'SANDBOX' | 'PRODUCTION';
    transaction_id: string;
    store: string;
    price: number;
    currency: string;
    // ... más campos
  };
}
```

**Tipos de eventos:**
- `INITIAL_PURCHASE`: Primera compra
- `RENEWAL`: Renovación automática
- `CANCELLATION`: Cancelación
- `UNCANCELLATION`: Reactivación
- `EXPIRATION`: Expiración
- `BILLING_ISSUE`: Problema de pago
- `PRODUCT_CHANGE`: Cambio de plan
- `TEST`: Evento de prueba

**Helpers disponibles:**
- `isValidRevenueCatWebhook(body)`: Valida estructura del webhook
- `extractEmailFromAppUserId(appUserId)`: Extrae email del user ID
- `shouldSyncEvent(eventType)`: Determina si requiere sincronización

## 📖 Uso

### Ejemplo 1: Validar webhook

```typescript
import { 
  isValidRevenueCatWebhook,
  shouldSyncEvent 
} from './revenuecat/models/index.ts';

const body = await request.json();

if (!isValidRevenueCatWebhook(body)) {
  throw new Error('Invalid webhook');
}

if (shouldSyncEvent(body.event.type)) {
  // Sincronizar con Supabase y WordPress
}
```

### Ejemplo 2: Verificar estado de suscripción

```typescript
import { 
  isSubscriptionActive,
  getSubscriptionStatus 
} from './revenuecat/models/index.ts';

const subscription: Subscription = {
  expires_date: '2025-12-31T23:59:59Z',
  purchase_date: '2025-01-01T00:00:00Z',
  period_type: 'normal',
  store: 'app_store',
  is_sandbox: false,
  // ... resto de campos
};

if (isSubscriptionActive(subscription)) {
  console.log('Suscripción activa');
  const status = getSubscriptionStatus(subscription);
  console.log(`Estado: ${status}`); // 'active', 'cancelled', etc.
}
```

### Ejemplo 3: Parsear fechas

```typescript
import { parseRevenueCatDate } from './revenuecat/models/index.ts';

const expiresDate = parseRevenueCatDate(subscription.expires_date);
if (expiresDate) {
  const daysUntilExpiration = Math.ceil(
    (expiresDate.getTime() - Date.now()) / (1000 * 60 * 60 * 24)
  );
  console.log(`Expira en ${daysUntilExpiration} días`);
}
```

## 🔄 Mapeo con Membership Levels

Para mapear productos de RevenueCat a niveles de membresía en Supabase:

```typescript
// En membership_levels tenemos:
// revenuecat_product_ids: string[] (array de product IDs)

const productId = event.event.product_id;

// Buscar nivel correspondiente
const { data: level } = await supabase
  .from('membership_levels')
  .select('*')
  .contains('revenuecat_product_ids', [productId])
  .single();

if (level) {
  // Crear/actualizar user_membership con:
  // - membership_level_id: level.id
  // - sync_source: 'revenuecat'
  // - status basado en getSubscriptionStatus()
}
```

## 🎯 Estados de Suscripción

| Estado | Descripción | Acción |
|--------|-------------|--------|
| `active` | Suscripción activa | Otorgar acceso |
| `cancelled` | Cancelada o reembolsada | Revocar acceso |
| `expired` | Expirada sin renovación | Revocar acceso |
| `in_grace_period` | En período de gracia | Mantener acceso temporalmente |
| `billing_issues` | Problemas de pago | Mantener acceso hasta grace period |

## 🔗 Integración con WordPress

Cuando se recibe un evento de RevenueCat:

1. **Extraer datos:**
   ```typescript
   const email = extractEmailFromAppUserId(event.event.app_user_id);
   const productId = event.event.product_id;
   ```

2. **Buscar membership_level:**
   ```typescript
   const level = await findMembershipLevelByProductId(productId);
   ```

3. **Crear en Supabase:**
   ```typescript
   await createUserMembership(email, level.id, 'revenuecat');
   ```

4. **Sincronizar con WordPress:**
   ```typescript
   await createWordPressMembership(email, level.wordpress_rcp_id);
   ```

## 📚 Documentación Oficial

- [RevenueCat Webhooks](https://www.revenuecat.com/docs/webhooks)
- [Webhook Events Reference](https://www.revenuecat.com/docs/webhook-events)
- [Subscription Status](https://www.revenuecat.com/docs/subscription-status)

---

**✅ Modelos completamente tipados y listos para usar con RevenueCat**

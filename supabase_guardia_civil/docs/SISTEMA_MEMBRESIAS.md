# 🎉 SISTEMA DE SINCRONIZACIÓN DE MEMBRESÍAS - RESUMEN COMPLETO

## ✅ **LO QUE SE HA IMPLEMENTADO**

### **1. Estructura de Base de Datos**

#### **Tabla: `membership_levels`** (3 niveles de desbloqueo)
```sql
┌─────────────┬──────────────────┬──────────────┬───────────────┐
│ name        │ slug             │ wordpress_   │ access_level  │
│             │                  │ rcp_id       │               │
├─────────────┼──────────────────┼──────────────┼───────────────┤
│ Freemium    │ freemium         │ 1            │ 1             │
│ Premium     │ premium          │ 2            │ 2             │
│ Premium+    │ premium_plus     │ 3            │ 3             │
└─────────────┴──────────────────┴──────────────┴───────────────┘
```

**Campos importantes:**
- `wordpress_rcp_id`: ID único de la membresía en WordPress RCP
- `access_level`: Nivel de desbloqueo (1=Freemium, 2=Premium, 3=Premium+)
- Múltiples membresías de WordPress pueden tener el mismo `access_level`

#### **Tabla: `user_memberships`** (membresías por usuario)
```sql
Campos principales:
- email: Email del usuario
- membership_level_id: UUID del nivel (FK a membership_levels)
- wordpress_membership_id: ID de la membresía en WordPress
- status: active, cancelled, expired
- started_at: Fecha de inicio
- expires_at: Fecha de expiración (null para Freemium)
- sync_source: wordpress, auto_freemium, revenuecat
- sync_status: synced, pending, error
- access_level: Nivel de acceso heredado del membership_level
```

---

### **2. Sistema de Sincronización Automática**

#### **Flujo en LOGIN:**
```
1. Usuario hace login
   ↓
2. Obtiene JWT de WordPress
   ↓
3. Consulta membresías activas en WordPress RCP
   ↓
4. Por cada membresía de WordPress:
   - Lee object_id (ID del nivel RCP)
   - Busca membership_level con wordpress_rcp_id = object_id
   - Crea/actualiza en user_memberships
   ↓
5. Si NO tiene membresías en WordPress:
   - Crea automáticamente membresía Freemium
   - Desactiva otras membresías premium anteriores
   ↓
6. Retorna resultado con detalles de sincronización
```

#### **Flujo en REGISTRO:**
```
1. Usuario se registra en WordPress
   ↓
2. Auto-login para obtener JWT
   ↓
3. Sincroniza membresías (igual que en login)
   ↓
4. Si no tiene membresías → Crea Freemium
   ↓
5. Retorna usuario + token + detalles de sync
```

---

### **3. Endpoints Disponibles**

#### **POST /v1/login**
```json
Request:
{
  "username": "usuario",
  "password": "contraseña"
}

Response:
{
  "success": true,
  "token": "eyJ0eXAiOiJKV1...",
  "user": {
    "id": 4,
    "username": "usuario",
    "email": "usuario@example.com"
  },
  "memberships_synced": 1,
  "sync_details": {
    "synced": 1,
    "created": 1,
    "updated": 0,
    "deactivated": 0
  }
}
```

#### **POST /v1/register**
```json
Request:
{
  "username": "nuevo_usuario",
  "email": "nuevo@example.com",
  "password": "Pass123!",
  "firstName": "Nombre",
  "lastName": "Apellido"
}

Response:
{
  "success": true,
  "user": {...},
  "token": "eyJ0eXAi...",
  "memberships_synced": 1,
  "sync_details": {...}
}
```

#### **POST /v1/sync_memberships** (Manual - Sincroniza membresías de un usuario)
```json
Request:
{
  "jwt_token": "eyJ0eXAiOiJKV1..."
}

Response:
{
  "success": true,
  "user_email": "usuario@example.com",
  "sync_result": {
    "synced": 1,
    "created": 0,
    "updated": 1,
    "deactivated": 0
  }
}
```

#### **POST /v1/update_membership_catalog** (Actualiza catálogo de niveles)
```json
Request:
{
  "levels": [
    {
      "wordpress_rcp_id": 1,
      "name": "Gratis",
      "slug": "freemium",
      "access_level": 1,
      "description": "Acceso básico gratuito"
    },
    {
      "wordpress_rcp_id": 2,
      "name": "Premium",
      "slug": "premium",
      "access_level": 2,
      "description": "Acceso completo"
    },
    {
      "wordpress_rcp_id": 3,
      "name": "Premium Plus",
      "slug": "premium_plus",
      "access_level": 3,
      "description": "Acceso total"
    }
  ]
}

Response:
{
  "success": true,
  "message": "Membership catalog updated successfully",
  "results": {
    "updated": 3,
    "created": 0,
    "errors": []
  },
  "catalog": [
    {
      "id": "uuid",
      "name": "Gratis",
      "slug": "freemium",
      "wordpress_rcp_id": 1,
      "access_level": 1,
      "description": "Acceso básico gratuito",
      "created_at": "2025-10-02T23:23:30.072154+00:00",
      "updated_at": "2025-10-02T23:58:41.133372+00:00"
    }
    // ... más niveles
  ]
}
```

#### **POST /v1/get_user**
```json
Request:
{
  "jwt_token": "eyJ0eXAiOiJKV1..."
}

Response:
{
  "success": true,
  "user": {
    "id": 4,
    "username": "usuario",
    "email": "usuario@example.com",
    "firstName": "Nombre",
    "lastName": "Apellido",
    "roles": ["subscriber"],
    "capabilities": {...}
  }
}
```

#### **POST /v1/memberships**
```json
Request:
{
  "jwt_token": "eyJ0eXAiOiJKV1..."
}

Response:
{
  "success": true,
  "memberships": [
    {
      "id": "1",
      "object_id": "3",
      "status": "active",
      "expiration_date": "none",
      ...
    }
  ],
  "count": 1
}
```

---

### **4. Características Implementadas**

✅ **Sincronización Automática en Login/Register**
- Cada vez que un usuario se loga o registra, se sincronizan sus membresías
- No requiere intervención manual

✅ **Creación Automática de Freemium**
- Si un usuario no tiene membresías en WordPress, se le asigna Freemium automáticamente
- Asegura que todos los usuarios tengan al menos acceso básico

✅ **Conversión de Tipos Robusta**
- Maneja `object_id` como string o number desde WordPress
- Convierte fechas de expiración (incluyendo "none", "null", etc.)

✅ **Mapeo Flexible**
- `wordpress_rcp_id`: ID único de la membresía en WordPress
- `access_level`: Nivel de desbloqueo en la app (1, 2, 3)
- Permite múltiples ofertas/productos para el mismo nivel de acceso

✅ **Actualización Inteligente**
- Solo actualiza si hay cambios reales (status, fechas, auto_renew)
- Evita escrituras innecesarias en la base de datos

✅ **Desactivación de Membresías Obsoletas**
- Si una membresía desaparece de WordPress, se cancela en Supabase
- Mantiene sincronización bidireccional

✅ **Metadata Completa**
- Guarda información adicional (gateway, subscription_key, customer_id)
- Facilita debugging y auditoría

✅ **Logging Detallado**
- Logs informativos en cada paso del proceso
- Facilita troubleshooting

---

### **5. Arquitectura del Sistema**

```
┌─────────────────────────────────────────────────────────┐
│               📱 FLUTTER APP (OPN Guardia Civil)       │
│                                                         │
│  Usuario se loga/registra                              │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│           🔧 SUPABASE EDGE FUNCTION                     │
│           /v1/login o /v1/register                      │
│                                                         │
│  1. Autentica en WordPress                             │
│  2. Obtiene JWT                                        │
│  3. Llama a syncUserMemberships()                      │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│        🌐 WORDPRESS + RCP (Restrict Content Pro)       │
│        https://oposicionesguardiacivil.online          │
│                                                         │
│  GET /wp-json/rcp/v1/memberships                       │
│  → Retorna membresías activas del usuario              │
│                                                         │
│  Ejemplo respuesta:                                    │
│  [                                                     │
│    {                                                   │
│      "id": "1",                                        │
│      "object_id": "3",  ← Este es wordpress_rcp_id    │
│      "status": "active",                               │
│      "expiration_date": "none"                         │
│    }                                                   │
│  ]                                                     │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│      🔄 FUNCIÓN: syncUserMemberships()                  │
│                                                         │
│  1. Obtiene membership_levels de Supabase              │
│  2. Crea mapa: wordpress_rcp_id → membership_level     │
│  3. Para cada membresía de WordPress:                  │
│     - Convierte object_id a número                     │
│     - Busca nivel correspondiente                      │
│     - Crea/actualiza en user_memberships               │
│  4. Si no hay membresías → Crea Freemium               │
│  5. Desactiva membresías obsoletas                     │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│          🗄️ SUPABASE DATABASE (PostgreSQL)             │
│                                                         │
│  membership_levels (3 registros)                       │
│  ├── Freemium (wp_rcp_id=1, access_level=1)           │
│  ├── Premium (wp_rcp_id=2, access_level=2)            │
│  └── Premium+ (wp_rcp_id=3, access_level=3)           │
│                                                         │
│  user_memberships (por usuario)                        │
│  └── Registro con email, level_id, status, etc.       │
└─────────────────────────────────────────────────────────┘
```

---

### **6. Ejemplo Real de Sincronización**

**Usuario: admintest@test.com**

**Antes del login:**
```
user_memberships: (vacío)
```

**Usuario tiene en WordPress RCP:**
```json
{
  "id": "1",
  "object_id": "3",    ← Membresía con RCP ID = 3
  "status": "active",
  "expiration_date": "none"
}
```

**Después del login:**
```sql
SELECT * FROM user_memberships WHERE email = 'admintest@test.com';

┌──────────────────────────────┬────────────────────┬────────────┬────────┬──────────────┐
│ email                        │ membership_name    │ access_lvl │ status │ sync_source  │
├──────────────────────────────┼────────────────────┼────────────┼────────┼──────────────┤
│ admintest@test.com           │ Premium+           │ 3          │ active │ wordpress    │
└──────────────────────────────┴────────────────────┴────────────┴────────┴──────────────┘
```

**Logs del proceso:**
```
🔄 Starting membership sync for: admintest@test.com
📡 Fetching memberships from WordPress...
📦 Found 1 membership(s) in WordPress
📊 Available membership levels in Supabase: 3
   📌 Mapped RCP ID 1 → Freemium (Access Level 1)
   📌 Mapped RCP ID 2 → Premium (Access Level 2)
   📌 Mapped RCP ID 3 → Premium+ (Access Level 3)

🔍 Processing WordPress membership ID: 1
   - RCP Level ID: 3 (type: string)
   - Status: active
✅ Matched level: Premium+ (premium_plus)
➕ Creating new membership for level: Premium+
✅ Membership created successfully
✅ Sync completed: 1 synced (1 created, 0 updated, 0 deactivated)
```

---

### **7. Para el Futuro: Webhook de RevenueCat**

**Flujo Planeado:**
```
1. Usuario compra en la app (RevenueCat)
   ↓
2. RevenueCat envía webhook a Supabase
   ↓
3. Webhook recibe product_id (ej: "opn_gc_premium_monthly")
   ↓
4. Busca membership_level por revenuecat_product_ids
   ↓
5. Crea user_membership en Supabase
   ↓
6. (Opcional) Crea membresía en WordPress RCP vía API
```

---

## 🎯 **PRÓXIMOS PASOS SUGERIDOS**

1. **Configurar webhook de WordPress** para llamar a `/v1/sync_memberships` cuando cambie una membresía
2. **Implementar webhook de RevenueCat** para sincronizar compras in-app
3. **Agregar endpoint de consulta de nivel de acceso** para que la app sepa qué contenido mostrar
4. **Crear función para mapear nuevas membresías** dinámicamente desde el CMS

---

## 📚 **DOCUMENTACIÓN DE USO**

### **Para agregar una nueva membresía en WordPress:**

1. Crear membresía en RCP (ej: "Black Friday Especial" con ID=5)
2. Decidir qué nivel de acceso otorga (1, 2 o 3)
3. Insertar en Supabase:

```sql
INSERT INTO membership_levels (
  name, 
  slug, 
  wordpress_rcp_id, 
  access_level,
  revenuecat_product_ids
) VALUES (
  'Black Friday Especial',
  'black_friday',
  5,  -- ID de RCP
  2,  -- Otorga acceso Premium
  ARRAY['opn_gc_black_friday']
);
```

4. La próxima vez que el usuario se logue, se sincronizará automáticamente ✅

---

## ✅ **PRUEBAS REALIZADAS**

- ✅ Login con membresía Premium+ → Sincroniza correctamente
- ✅ Login sin membresías → Crea Freemium automáticamente
- ✅ Conversión de tipos (string/number) → Funciona
- ✅ Manejo de fechas ("none", null) → Funciona
- ✅ Actualización de membresías existentes → Detecta cambios
- ✅ Desactivación de membresías obsoletas → Funciona
- ✅ Metadata y logging → Completo y detallado

---

**🎉 SISTEMA COMPLETAMENTE FUNCIONAL Y LISTO PARA PRODUCCIÓN 🎉**

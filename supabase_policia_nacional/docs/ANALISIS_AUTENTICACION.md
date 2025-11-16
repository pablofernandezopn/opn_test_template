# 🔍 Análisis del Sistema de Autenticación

## Fecha: 2025-10-27

---

## 📋 Flujo Actual

### 1. Registro de Usuario

```
Usuario completa formulario
  ↓
Flutter llama: signUpAndSignIn()
  ↓
Edge Function: /login-register/v1/register
  ↓
Crea usuario en WordPress
  ↓
Devuelve token de WordPress
  ↓
Flutter guarda el token
```

### 2. Login de Usuario

```
Usuario ingresa credenciales
  ↓
Flutter llama: signIn()
  ↓
Edge Function: /login-register/v1/login
  ↓
Valida en WordPress
  ↓
Devuelve token de WordPress
  ↓
Flutter guarda el token
```

### 3. Obtener Datos del Usuario

```
App tiene token de WordPress
  ↓
Flutter llama: getUser(token)
  ↓
Edge Function: /login-register/v1/get_user
  ↓
┌─────────────────────────────────────┐
│ 1. Obtiene datos de WordPress      │
│    (id, email, username, etc.)      │
└─────────────────────────────────────┘
  ↓
┌─────────────────────────────────────┐
│ 2. Busca en Supabase tabla 'users' │
│    WHERE id = wordpress_id          │
└─────────────────────────────────────┘
  ↓
┌─────────────── SI EXISTE ───────────────────┐
│ Devuelve datos completos de Supabase:      │
│ - user data                                 │
│ - user_memberships (con membership_levels)  │
│ - academy_id                                │
│ - specialty_id                              │
└─────────────────────────────────────────────┘
  ↓
┌─────────── NO EXISTE ⚠️ ────────────┐
│ Devuelve solo datos de WordPress:  │
│ - id, email, username               │
│ - NO membresías                     │
│ - NO academy_id                     │
│ - NO specialty_id                   │
│ - source: 'wordpress_only'          │
└─────────────────────────────────────┘
```

---

## ⚠️ PROBLEMA IDENTIFICADO

### Síntoma
**"Cuando se autentica con token directamente en la BD no se cargan las membresías ni se comprueba si el usuario existe"**

### Causa Raíz

El usuario se crea en **WordPress** pero **NO se sincroniza automáticamente a la tabla `users` de Supabase**.

#### Por qué ocurre:

1. **Trigger `sync_auth_users_to_cms`** solo sincroniza desde `auth.users` → `cms_users`
2. El flujo actual **NO usa `auth.users`** de Supabase
3. WordPress es la **única fuente de verdad** para autenticación
4. No hay sincronización de **WordPress → Supabase `users`**

#### Consecuencias:

```
Usuario nuevo se registra
  ↓
Se crea en WordPress ✅
  ↓
NO se crea en Supabase 'users' ❌
  ↓
Cuando llama get_user:
  - Encuentra datos en WordPress ✅
  - NO encuentra en Supabase ❌
  - Devuelve 'wordpress_only' ⚠️
  - Sin membresías ❌
  - Sin academy_id ❌
  - Sin specialty_id ❌
```

---

## 🔍 Evidencias del Problema

### En `get_user.ts` (líneas 169-178)

```typescript
if (!supabaseUserData) {
  console.log('⚠️ User not found in Supabase, returning WordPress data only');
  // Si el usuario no existe en Supabase, devolver solo datos de WordPress
  return this.jsonResponse({
    success: true,
    user: userData,
    source: 'wordpress_only',  // 🚨 PROBLEMA AQUÍ
    note: 'User not found in Supabase database'
  });
}
```

### En `auth_repository.dart` (líneas 71-114)

El código Flutter **espera** que el Edge Function devuelva:
- `userData['user_memberships']` (línea 102)
- Campos completos de Supabase

Pero si el usuario no existe en Supabase, recibe solo datos básicos de WordPress.

---

## 📊 Tablas Involucradas

### Tabla `auth.users` (Supabase Auth)
- **NO se usa** en el flujo actual
- El trigger `sync_auth_users_to_cms` funciona aquí
- **NO relevante** para este problema

### Tabla `users` (public schema)
- **Aquí se busca** el usuario en `get_user`
- Debe contener:
  - `id` (WordPress ID)
  - `email`, `username`
  - `academy_id` ⭐
  - `specialty_id` ⭐
  - `user_memberships` (relación) ⭐

### Tabla `cms_users` (public schema)
- Para editores/administradores
- NO es relevante para usuarios finales
- Ya tiene trigger de sincronización desde `auth.users`

---

## 💡 SOLUCIÓN CORRECTA ⭐

### Principio Fundamental

**SIEMPRE verificar y sincronizar usuario de WordPress → Supabase ANTES de devolver datos**

### Escenarios a Manejar

1. **Usuario existe en WordPress pero NO en Supabase** ← MÁS COMÚN
2. **Usuario existe en ambos** ← Caso normal
3. **Usuario nuevo (registro)** ← Crear en ambos

### Implementación: Función Centralizada de Sync

**Crear función `ensureUserInSupabase()`** que se ejecute en TODOS los endpoints:

```typescript
/**
 * Garantiza que el usuario de WordPress existe en Supabase
 * Si no existe, lo crea con datos por defecto
 * Devuelve SIEMPRE los datos completos de Supabase
 */
async function ensureUserInSupabase(
  supabaseClient: any,
  wpUserData: WordPressUser
): Promise<SupabaseUser> {

  // 1. Buscar usuario en Supabase
  const { data: existingUser } = await supabaseClient
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

  // 2. Si existe, devolverlo
  if (existingUser) {
    console.log('✅ Usuario ya existe en Supabase');
    return existingUser;
  }

  // 3. Si NO existe, crearlo
  console.log('⚠️ Usuario NO existe en Supabase, creando...');

  const { data: newUser, error } = await supabaseClient
    .from('users')
    .insert({
      id: wpUserData.id,           // WordPress ID
      email: wpUserData.email,
      username: wpUserData.username,
      first_name: wpUserData.firstName,
      last_name: wpUserData.lastName,
      academy_id: 1,               // OPN por defecto
      // specialty_id lo asigna el trigger automáticamente
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    })
    .select(`
      *,
      user_memberships(
        *,
        membership_level:membership_levels(*)
      )
    `)
    .single();

  if (error) {
    // Manejar conflicto (por si se crea concurrentemente)
    if (error.code === '23505') { // Duplicate key
      console.log('⚠️ Usuario creado concurrentemente, reintentando...');
      return ensureUserInSupabase(supabaseClient, wpUserData); // Reintentar
    }
    throw error;
  }

  console.log('✅ Usuario creado en Supabase exitosamente');
  return newUser;
}
```

### Usar en TODOS los Endpoints

#### 1. En `get_user.ts` (JWT existente)

```typescript
private async processGetUser(supabaseClient: any, request: Request): Promise<FnResponse> {
  const wpToken = extractToken(request);

  // Obtener datos de WordPress
  const wpClient = new WordPressClient();
  const wpUserData = await wpClient.getUser(wpToken);

  // ⭐ SINCRONIZAR A SUPABASE (SIEMPRE)
  const completeUserData = await ensureUserInSupabase(supabaseClient, wpUserData);

  return this.jsonResponse({
    success: true,
    user: completeUserData
  });
}
```

#### 2. En `login.ts` (Login con credenciales)

```typescript
async handle(supabaseClient: any, request: Request): Promise<FnResponse> {
  const { username, password } = await request.json();

  // Validar en WordPress
  const wpClient = new WordPressClient();
  const { token, user: wpUserData } = await wpClient.login(username, password);

  // ⭐ SINCRONIZAR A SUPABASE (SIEMPRE)
  const completeUserData = await ensureUserInSupabase(supabaseClient, wpUserData);

  return this.jsonResponse({
    success: true,
    token: token,
    user: completeUserData
  });
}
```

#### 3. En `register.ts` (Registro nuevo)

```typescript
async handle(supabaseClient: any, request: Request): Promise<FnResponse> {
  const userData = await request.json();

  // Crear en WordPress
  const wpClient = new WordPressClient();
  const { token, user: wpUserData } = await wpClient.register(userData);

  // ⭐ SINCRONIZAR A SUPABASE (SIEMPRE)
  const completeUserData = await ensureUserInSupabase(supabaseClient, wpUserData);

  return this.jsonResponse({
    success: true,
    token: token,
    user: completeUserData
  });
}
```

### Ventajas de esta Solución

- ✅ **Función centralizada** - Un solo lugar para mantener
- ✅ **Siempre sincronizado** - 100% de usuarios en Supabase
- ✅ **Maneja race conditions** - Con código de error 23505
- ✅ **Sin cambios en Flutter** - Transparente para la app
- ✅ **Idempotente** - Se puede llamar múltiples veces
- ✅ **Datos completos siempre** - Membresías, academy, specialty
- ✅ **Backwards compatible** - Funciona con usuarios existentes

### Desventajas

- ⚠️ Una llamada extra a BD por login (pero necesaria)
- ⚠️ Tiempo de respuesta ligeramente mayor en primer login

---

### Opción 2: Endpoint Dedicado de Sync

Crear nuevo endpoint: `/login-register/v1/sync_user`

Llamarlo después de login/register exitoso:

```dart
// En signUpAndSignIn() y signIn()
final token = await _signIn();
if (token != null) {
  await syncUserToSupabase(token);  // Nuevo método
  final user = await getUser(token);
}
```

**Ventajas:**
- ✅ Separación de responsabilidades
- ✅ Control explícito

**Desventajas:**
- ⚠️ Requiere cambios en Flutter
- ⚠️ Llamadas HTTP adicionales

---

### Opción 3: Webhook de WordPress → Supabase

Configurar WordPress para que envíe webhook a Supabase cuando:
- Se crea un usuario
- Se actualiza un usuario
- Se cambia una membresía

**Ventajas:**
- ✅ WordPress como única fuente de verdad
- ✅ Sincronización en tiempo real

**Desventajas:**
- ⚠️ Requiere configuración en WordPress
- ⚠️ Complejidad adicional
- ⚠️ Dependencia externa

---

### Opción 4: Migrar a Supabase Auth Completo

Dejar de usar WordPress auth y migrar a `auth.users` de Supabase.

**Ventajas:**
- ✅ Sistema unificado
- ✅ Triggers funcionan automáticamente

**Desventajas:**
- ⚠️ **Migración masiva** de código
- ⚠️ Cambios en WordPress
- ⚠️ Tiempo de desarrollo alto

---

## 🎯 RECOMENDACIÓN FINAL

### Solución Inmediata: **Opción 1** (Sincronización en Edge Function)

**Por qué:**
1. ✅ Arregla el problema inmediatamente
2. ✅ Sin cambios en Flutter
3. ✅ Bajo riesgo
4. ✅ Fácil de implementar
5. ✅ Transparente para el usuario

**Implementación:**

1. Modificar `get_user.ts`:
   - Detectar si usuario no existe
   - Crearlo automáticamente con defaults
   - Devolver datos completos

2. Modificar `register.ts`:
   - Después de crear en WordPress
   - Crear también en Supabase

3. Modificar `login.ts`:
   - Verificar que usuario existe en Supabase
   - Si no, crearlo

---

## 📝 Checklist de Implementación

### Paso 1: Modificar `get_user.ts`
- [ ] Agregar función `ensureUserExistsInSupabase()`
- [ ] Si usuario no existe → crear
- [ ] Asignar academy_id = 1
- [ ] Trigger asigna specialty_id automáticamente
- [ ] Devolver datos completos siempre

### Paso 2: Modificar `register.ts`
- [ ] Después de crear en WordPress
- [ ] Insertar en tabla `users` de Supabase
- [ ] Usar mismo `id` que WordPress

### Paso 3: Modificar `login.ts`
- [ ] Después de validar en WordPress
- [ ] Verificar que usuario existe en Supabase
- [ ] Si no existe, crear (fallback)

### Paso 4: Testing
- [ ] Registro nuevo usuario
- [ ] Verificar que se crea en Supabase
- [ ] Verificar que tiene academy_id
- [ ] Verificar que tiene specialty_id
- [ ] Login usuario existente
- [ ] Verificar que carga membresías
- [ ] Login usuario sin registro previo en Supabase
- [ ] Verificar que se crea automáticamente

---

## 🔐 Consideraciones de Seguridad

1. **ID Consistency**: Usar siempre el WordPress ID como `id` en Supabase
2. **Race Conditions**: Manejar creación concurrente con `ON CONFLICT`
3. **Validación**: Verificar que email es válido
4. **Academy Assignment**: Validar que academy_id existe

---

## 📊 Métricas de Éxito

Después de implementar:
- ✅ 100% de usuarios tienen datos en Supabase
- ✅ 100% de usuarios tienen academy_id
- ✅ 100% de usuarios tienen specialty_id
- ✅ 0% de respuestas con `source: 'wordpress_only'`
- ✅ Membresías se cargan correctamente

---

## 🚀 Próximos Pasos

1. **Aprobar** solución elegida
2. **Implementar** cambios en Edge Functions
3. **Testear** en local
4. **Deploy** a producción
5. **Monitorear** logs y métricas

---

**Documentación generada**: 2025-10-27
**Versión**: 1.0
**Estado**: Pendiente de aprobación
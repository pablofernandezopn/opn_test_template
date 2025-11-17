# 📍 Referencia de Endpoints - API v1

## Base URL
```
Local: http://127.0.0.1:54321/functions/v1/
Producción: https://tu-proyecto.supabase.co/functions/v1/
```

## Formato de Rutas

### ✅ CORRECTO
```
login-register/v1/{endpoint}
```

### ❌ INCORRECTO (NO usar)
```
login-register/api/v1/{endpoint}  ← NO incluir /api/
```

---

## Endpoints Disponibles

### 1. 🔐 Login
**Ruta**: `login-register/v1/login`  
**Método**: `POST`  
**Body**:
```json
{
  "email": "usuario@ejemplo.com",     // O "username"
  "password": "tu_password"
}
```
**Response exitosa** (200):
```json
{
  "success": true,
  "token": "eyJ0eXAiOiJKV1Qi...",
  "user": {
    "id": 4,
    "username": "usuario",
    "email": "usuario@ejemplo.com"
  },
  "memberships_synced": 1
}
```

**Errores comunes**:
- 400: Credenciales faltantes
- 401: Credenciales incorrectas
- 404: Ruta incorrecta (verifica que no incluyas `/api/`)

---

### 2. ✍️ Register
**Ruta**: `login-register/v1/register`  
**Método**: `POST`  
**Body**:
```json
{
  "username": "nuevousuario",
  "email": "nuevo@ejemplo.com",
  "password": "password123",
  "first_name": "Nombre",
  "last_name": "Apellido",
  "phone": "+34123456789"
}
```
**Response exitosa** (200):
```json
{
  "success": true,
  "token": "eyJ0eXAiOiJKV1Qi...",
  "user": {
    "id": 5,
    "username": "nuevousuario",
    "email": "nuevo@ejemplo.com"
  }
}
```

---

### 3. 👤 Get User
**Ruta**: `login-register/v1/get_user`  
**Método**: `POST`  
**Headers**:
```
Authorization: Bearer {token_jwt_de_wordpress}
```
**Body**: Vacío
**Response exitosa** (200):
```json
{
  "id": 4,
  "username": "usuario",
  "email": "usuario@ejemplo.com",
  "memberships": [
    {
      "id": 1,
      "status": "active",
      "membership_level": {
        "name": "Premium",
        "access_level": 2
      }
    }
  ]
}
```

---

### 4. 🔔 RevenueCat Webhook
**Ruta**: `login-register/v1/revenuecat`  
**Método**: `POST`  
**Uso**: Interno (RevenueCat → Supabase)

---

### 5. 📝 Update Membership Catalog
**Ruta**: `login-register/v1/update_membership_catalog`  
**Método**: `POST`  
**Uso**: Interno (sincronización de catálogo)

---

### 6. ℹ️ Version
**Ruta**: `login-register/v1/version`  
**Método**: `GET`  
**Response**:
```json
{
  "version": "1"
}
```

---

## Ejemplos de Uso

### Dart/Flutter
```dart
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

// Login
final loginResult = await supa.Supabase.instance.client.functions.invoke(
  'login-register/v1/login',
  body: {
    'email': 'usuario@ejemplo.com',
    'password': 'password123'
  },
);

// Register
final registerResult = await supa.Supabase.instance.client.functions.invoke(
  'login-register/v1/register',
  body: {
    'username': 'nuevousuario',
    'email': 'nuevo@ejemplo.com',
    'password': 'password123',
    'first_name': 'Nombre',
    'last_name': 'Apellido',
    'phone': '+34123456789'
  },
);

// Get User
final userResult = await supa.Supabase.instance.client.functions.invoke(
  'login-register/v1/get_user',
  headers: {
    'Authorization': 'Bearer $wpToken',
  },
);
```

### cURL
```bash
# Login
curl -X POST http://127.0.0.1:54321/functions/v1/login-register/v1/login \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SUPABASE_ANON_KEY" \
  -d '{
    "email": "usuario@ejemplo.com",
    "password": "password123"
  }'

# Register
curl -X POST http://127.0.0.1:54321/functions/v1/login-register/v1/register \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SUPABASE_ANON_KEY" \
  -d '{
    "username": "nuevousuario",
    "email": "nuevo@ejemplo.com",
    "password": "password123",
    "first_name": "Nombre",
    "last_name": "Apellido",
    "phone": "+34123456789"
  }'

# Get User
curl -X POST http://127.0.0.1:54321/functions/v1/login-register/v1/get_user \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer WP_JWT_TOKEN"
```

---

## Checklist de Migración

Si estás actualizando de la versión anterior:

- [ ] Cambiar `login-register/api/v1/login` → `login-register/v1/login`
- [ ] Cambiar `login-register/api/v1/register` → `login-register/v1/register`
- [ ] Cambiar `login-register/api/v1/get_user` → `login-register/v1/get_user`
- [ ] Actualizar tests/scripts que usen las rutas antiguas
- [ ] Verificar que la app compile sin errores
- [ ] Probar login con usuario existente
- [ ] Probar registro de nuevo usuario

---

## Soporte

Si encuentras problemas:

1. Verifica los logs del servidor:
   ```bash
   docker logs supabase_edge_runtime_opn_gc_test --tail 50
   ```

2. Usa el script de diagnóstico:
   ```bash
   ./scripts_macos/diagnose_wordpress.sh
   ```

3. Prueba el endpoint desde terminal:
   ```bash
   ./scripts_macos/test_login_both.sh
   ```

---

**Última actualización**: 9 de octubre de 2025  
**Versión de la API**: v1

# Guía de Solución de Problemas

## Error 503: "name resolution failed" en Login

### Descripción del Problema
Cuando intentas hacer login desde la app móvil, aparece el error:
```
[error] WpException in signIn:
  Status: 503
  Message: Error de autenticación
  Reason: Service Temporarily Unavailable
  Data: {"message":"name resolution failed"}
```

### Causa
Este error ocurre cuando la aplicación Edge Function de Supabase no puede resolver el nombre de dominio del servidor WordPress. Puede deberse a:

1. **Variables de entorno no configuradas correctamente**
2. **El servidor WordPress está caído o inaccesible**
3. **Problemas de DNS o conectividad de red**
4. **URL de WordPress mal configurada**

### Solución Paso a Paso

#### 1. Verificar que el servidor WordPress está funcionando

Prueba acceder a tu sitio desde el navegador:
```bash
# Probar el endpoint de autenticación
curl -X POST https://oposicionesguardiacivil.online/wp-json/jwt-auth/v1/token \
  -H "Content-Type: application/json" \
  -d '{"username":"admintest","password":"tu_password"}'
```

Si devuelve un error 404 o timeout, el problema está en WordPress.

#### 2. Verificar variables de entorno en Supabase

**Local (desarrollo):**
```bash
# Verificar el archivo .env existe
ls -la supabase/functions/login-register/.env

# Ver las variables configuradas
cat supabase/functions/login-register/.env
```

Debe contener:
```env
WP_URL=https://oposicionesguardiacivil.online
WP_ADMIN_USERNAME=admintest
WP_ADMIN_PASSWORD=tu_password_aqui
```

**Producción (Supabase Cloud):**
```bash
# Listar secretos configurados
supabase secrets list

# Configurar los secretos si no existen
supabase secrets set WP_URL=https://oposicionesguardiacivil.online
supabase secrets set WP_ADMIN_USERNAME=admintest
supabase secrets set WP_ADMIN_PASSWORD=tu_password
```

#### 3. Verificar configuración de WordPress

Asegúrate de que los plugins necesarios están activos:

1. **JWT Authentication for WP REST API** - Para autenticación
2. **RCP Custom REST API** - Para membresías

Verifica en WordPress:
```bash
# Accede al admin de WordPress
https://oposicionesguardiacivil.online/wp-admin/plugins.php
```

#### 4. Probar desde local

```bash
# Ir al directorio del proyecto
cd supabase

# Iniciar Supabase local
supabase start

# En otra terminal, probar el endpoint
curl -X POST http://127.0.0.1:54321/functions/v1/login-register/api/v1/login \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer tu-anon-key" \
  -d '{"email":"admintest@test.com","password":"tu_password"}'
```

#### 5. Verificar logs

Los logs ahora muestran más información de debug:

```
✓ WordPress client configured for: https://oposicionesguardiacivil.online
🌐 Making WordPress call: token to https://oposicionesguardiacivil.online/wp-json/jwt-auth/v1/token
```

Si ves:
- `❌ WordPress configuration missing` → Falta configurar variables de entorno
- `❌ WordPress connection error` → Problema de conectividad
- `✓ WordPress response for token: 200 OK` → Todo funciona correctamente

### Configuración Correcta

#### Archivo `.env` para desarrollo local:
```env
# WordPress Configuration
WP_URL=https://oposicionesguardiacivil.online
WP_ADMIN_USERNAME=admintest
WP_ADMIN_PASSWORD=qoVg 9Deq UmAv OiBL HrZI Isdq

# JWT Auth Plugin Configuration
JWT_AUTH_SECRET_KEY={syqtT}C|,ENojj&BDXZE}Q+zCNd)Y,$8f!3o8zj8>PkTSl^<F_(wU^sb}FnQ[Cy
JWT_AUTH_CORS_ENABLE=true
```

#### Script para configurar secretos en producción:
```bash
#!/bin/bash
# setup-production-secrets.sh

echo "Configurando secretos en Supabase Cloud..."

supabase secrets set \
  WP_URL=https://oposicionesguardiacivil.online \
  WP_ADMIN_USERNAME=admintest \
  WP_ADMIN_PASSWORD="qoVg 9Deq UmAv OiBL HrZI Isdq" \
  JWT_AUTH_SECRET_KEY="{syqtT}C|,ENojj&BDXZE}Q+zCNd)Y,$8f!3o8zj8>PkTSl^<F_(wU^sb}FnQ[Cy"

echo "✓ Secretos configurados correctamente"
```

### Cambios Realizados en el Código

#### 1. Soporte para múltiples nombres de variables
El código ahora soporta tanto las nuevas (`WP_URL`) como las antiguas (`WP_APP_URL`) variables:

```typescript
this.wpUrl = (Deno.env.get('WP_URL') || Deno.env.get('WP_APP_URL') || '').replace(/\/$/, '');
this.wpUsername = Deno.env.get('WP_ADMIN_USERNAME') || Deno.env.get('WP_APP_USERNAME') || '';
this.wpPassword = Deno.env.get('WP_ADMIN_PASSWORD') || Deno.env.get('WP_APP_PASS') || '';
```

#### 2. Mejor logging
Se agregaron logs para identificar problemas:

```typescript
console.log(`✓ WordPress client configured for: ${this.wpUrl}`);
console.log(`🌐 Making WordPress call: ${wpCallName} to ${url}`);
console.error(`❌ WordPress connection error in ${wpCallName}:`, errorMessage);
```

#### 3. Mensajes de error más descriptivos
Los errores ahora explican mejor qué salió mal:

```typescript
if (errorMessage.includes('name resolution failed')) {
  userMessage = 'No se puede conectar al servidor WordPress. Verifica tu conexión a internet y que el servidor esté disponible.';
}
```

### Próximos Pasos

1. **Verificar que WordPress está accesible públicamente**
2. **Configurar las variables de entorno correctamente**
3. **Desplegar los cambios del código**
4. **Probar el login nuevamente desde la app**

### Comandos Útiles

```bash
# Ver logs en tiempo real (local)
supabase functions serve --debug

# Ver logs en producción
supabase functions logs login-register

# Reiniciar edge function
supabase functions deploy login-register --no-verify-jwt

# Verificar conectividad desde el servidor de Supabase
curl -v https://oposicionesguardiacivil.online/wp-json/
```

### Contacto de Soporte

Si el problema persiste después de seguir estos pasos:
1. Verifica los logs completos
2. Confirma que WordPress está respondiendo
3. Revisa la configuración de red/firewall

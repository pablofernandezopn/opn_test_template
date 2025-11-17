# ⚠️ ACCIÓN REQUERIDA: Instalar Plugins de WordPress

## Problema Detectado

El diagnóstico muestra que los siguientes plugins NO están instalados o activados en WordPress:

1. ❌ **JWT Authentication for WP REST API** - Endpoint `/wp-json/jwt-auth/v1/token` retorna 404
2. ❌ **RCP Custom REST API** - Endpoint `/wp-json/rcp/v1/membership-levels` retorna 404

## Solución

### Opción 1: Instalar desde el Administrador de WordPress (Recomendado)

#### 1. Plugin JWT Authentication

1. Accede al admin de WordPress: https://oposicionesguardiacivil.online/wp-admin/
2. Ve a **Plugins → Añadir nuevo**
3. Busca: `JWT Authentication for WP REST API`
4. Instala el plugin de **Useful Team**
5. **Activa** el plugin

**Configuración del plugin JWT:**

Edita el archivo `wp-config.php` y añade:

```php
// JWT Authentication
define('JWT_AUTH_SECRET_KEY', '{syqtT}C|,ENojj&BDXZE}Q+zCNd)Y,$8f!3o8zj8>PkTSl^<F_(wU^sb}FnQ[Cy');
define('JWT_AUTH_CORS_ENABLE', true);
```

Y en el archivo `.htaccess` añade:

```apache
RewriteCond %{HTTP:Authorization} ^(.*)
RewriteRule ^(.*) - [E=HTTP_AUTHORIZATION:%1]
```

#### 2. Plugin RCP Custom REST API

Este es un **plugin personalizado** que está en la carpeta `wordpress_plugin/` de este proyecto.

**Instalación:**

1. Ve a **Plugins → Añadir nuevo → Subir plugin**
2. Sube el archivo: `supabase/wordpress_plugin/rcp-custom-rest-api.zip`
3. **Activa** el plugin

O manualmente:

```bash
# Desde tu servidor WordPress
cd /ruta/a/wordpress/wp-content/plugins/
unzip rcp-custom-rest-api.zip
```

Luego activa desde el admin de WordPress.

### Opción 2: Instalar vía WP-CLI (Avanzado)

Si tienes acceso SSH al servidor:

```bash
# Conectarse al servidor
ssh usuario@servidor

# Instalar JWT Authentication
wp plugin install jwt-authentication-for-wp-rest-api --activate

# Instalar RCP Custom REST API
cd /ruta/a/wordpress/wp-content/plugins/
# Copiar el archivo zip desde tu máquina local
scp supabase/wordpress_plugin/rcp-custom-rest-api.zip servidor:/ruta/temporal/
unzip /ruta/temporal/rcp-custom-rest-api.zip
wp plugin activate rcp-custom-rest-api
```

## Verificación Post-Instalación

Después de instalar los plugins, ejecuta el script de diagnóstico nuevamente:

```bash
cd supabase
./scripts_macos/diagnose_wordpress.sh
```

Deberías ver:

```
4️⃣  Verificando endpoint de autenticación JWT...
  Probando: https://oposicionesguardiacivil.online/wp-json/jwt-auth/v1/token
✓ Endpoint JWT existe (HTTP 400)
  Nota: 400/401 es normal sin credenciales

5️⃣  Verificando endpoint de RCP (membresías)...
  Probando: https://oposicionesguardiacivil.online/wp-json/rcp/v1/membership-levels
✓ Endpoint RCP existe (HTTP 200)
```

## Probar el Login

Una vez instalados los plugins, prueba el login:

```bash
# Desde la app móvil
# O desde un terminal:
curl -X POST http://127.0.0.1:54321/functions/v1/login-register/api/v1/login \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGc..." \
  -d '{
    "email": "admintest@test.com",
    "password": "tu_password"
  }'
```

## Archivos Relacionados

- Plugin RCP: `supabase/wordpress_plugin/rcp-custom-rest-api.zip`
- Instrucciones de instalación: `supabase/wordpress_plugin/INSTALACION.md`
- Código fuente: `supabase/wordpress_plugin/rcp-custom-rest-api.php`

## Notas Importantes

⚠️ **El servidor WordPress debe tener instalados estos plugins para que la aplicación funcione correctamente.**

Los plugins son necesarios para:
- **JWT**: Autenticación de usuarios
- **RCP**: Gestión de membresías y subscripciones

Sin estos plugins, la app mostrará el error:
```
Status: 503
Message: Error de autenticación
Data: {"message":"name resolution failed"}
```

O después de la corrección de variables:
```
Status: 404
Message: Plugin not found
```

## Próximos Pasos

1. ✅ Instalar plugin JWT Authentication
2. ✅ Instalar plugin RCP Custom REST API
3. ✅ Verificar con el script de diagnóstico
4. ✅ Probar el login desde la app
5. ✅ Verificar que las membresías se sincronizan correctamente

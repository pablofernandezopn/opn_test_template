# 🔌 Plugin WordPress - RCP Custom REST API

Plugin personalizado para obtener los niveles de membresía de Restrict Content Pro directamente desde la base de datos.

## 📋 Problema que resuelve

El endpoint oficial de RCP REST API (`/wp-json/rcp/v1/levels/`) devuelve objetos vacíos:
```json
[{},{},{},{},{}]
```

Este plugin crea un endpoint personalizado que consulta **directamente la base de datos** de RCP y devuelve todos los datos correctamente formateados.

---

## 🚀 Instalación

### Opción 1: Como Plugin (Recomendado)

1. **Subir el archivo a WordPress:**
   - Accede al panel de administración de WordPress
   - Ve a: **Plugins → Añadir nuevo → Subir plugin**
   - Selecciona el archivo `rcp-custom-rest-api.php`
   - Haz clic en **Instalar ahora**
   - Activa el plugin

### Opción 2: Vía FTP/SFTP

1. **Conectar por FTP:**
   ```bash
   # Conectar a tu servidor
   sftp tu-usuario@oposicionesguardiacivil.online
   ```

2. **Crear carpeta del plugin:**
   ```bash
   cd wp-content/plugins
   mkdir rcp-custom-rest-api
   cd rcp-custom-rest-api
   ```

3. **Subir el archivo:**
   ```bash
   put rcp-custom-rest-api.php
   ```

4. **Activar en WordPress:**
   - Panel de administración → **Plugins**
   - Busca "RCP Custom REST API Endpoint"
   - Haz clic en **Activar**

### Opción 3: Agregar al functions.php (No recomendado)

Si no puedes instalar plugins, copia el contenido del archivo (excepto la cabecera del plugin) al `functions.php` de tu tema activo.

---

## 🔧 Uso

### Endpoint disponible:

```
GET https://oposicionesguardiacivil.online/wp-json/rcp-custom/v1/levels
```

### Autenticación requerida:

El endpoint requiere autenticación con **JWT token** y permisos de **administrador**.

### Ejemplo con curl:

```bash
# 1. Obtener token JWT
TOKEN=$(curl -s -X POST "https://oposicionesguardiacivil.online/wp-json/jwt-auth/v1/token" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admintest",
    "password": "tu-password"
  }' | jq -r '.token')

# 2. Consultar niveles
curl -X GET "https://oposicionesguardiacivil.online/wp-json/rcp-custom/v1/levels" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

### Respuesta esperada:

```json
{
  "success": true,
  "count": 6,
  "levels": [
    {
      "id": 1,
      "name": "Gratis",
      "description": "Acceso básico gratuito",
      "duration": 0,
      "duration_unit": "month",
      "price": 0,
      "fee": 0,
      "maximum_renewals": 0,
      "status": "active",
      "role": "subscriber",
      "list_order": 0
    },
    {
      "id": 2,
      "name": "Premium Mensual",
      "description": "Acceso premium por mes",
      "duration": 1,
      "duration_unit": "month",
      "price": 19.99,
      "fee": 0,
      "maximum_renewals": 0,
      "status": "active",
      "role": "subscriber",
      "list_order": 1
    }
    // ... más niveles
  ]
}
```

---

## 🔄 Integración con Supabase

Una vez instalado el plugin, necesitas actualizar el código de sincronización en Supabase para usar este nuevo endpoint.

### Actualizar `sync_membership_catalog.ts`:

Reemplaza:
```typescript
const rcpEndpoint = `${WP_CONFIG.url}/wp-json/rcp/v1/levels/`;
```

Por:
```typescript
const rcpEndpoint = `${WP_CONFIG.url}/wp-json/rcp-custom/v1/levels`;
```

---

## 🛠️ Troubleshooting

### Error: "Debes estar autenticado"

**Causa:** No se envió el token JWT o el token está expirado.

**Solución:**
```bash
# Obtener nuevo token
curl -X POST "https://oposicionesguardiacivil.online/wp-json/jwt-auth/v1/token" \
  -H "Content-Type: application/json" \
  -d '{"username":"admintest","password":"tu-password"}'
```

### Error: "No tienes permisos"

**Causa:** El usuario no es administrador.

**Solución:** Asegúrate de usar credenciales de un usuario con rol de administrador.

### Error: "Restrict Content Pro no está instalado"

**Causa:** El plugin RCP no está activo.

**Solución:**
- Ve a **Plugins** en WordPress
- Busca "Restrict Content Pro"
- Actívalo

### Error: "No se encontraron niveles activos"

**Causa:** No hay niveles de membresía con `status = 'active'` en la base de datos.

**Solución:**
- Ve a **Restrict → Membership Levels**
- Verifica que los niveles estén activos
- O modifica la consulta SQL en el código para incluir otros estados

### Ver logs de errores:

```bash
# En el servidor WordPress
tail -f wp-content/debug.log | grep "RCP Custom API"
```

---

## 📊 Estructura de la Base de Datos RCP

La tabla de niveles de membresía se encuentra en:
```
{prefix}_restrict_content_pro
```

Campos principales:
- `id` - ID único del nivel
- `name` - Nombre del nivel
- `description` - Descripción
- `duration` - Duración (número)
- `duration_unit` - Unidad (day, month, year)
- `price` - Precio
- `status` - Estado (active, inactive)
- `role` - Rol de WordPress asignado

---

## 🔐 Seguridad

Este endpoint:
- ✅ Requiere autenticación JWT
- ✅ Verifica que el usuario sea administrador
- ✅ Usa prepared statements (indirectamente via $wpdb)
- ✅ Valida que RCP esté instalado
- ✅ Maneja errores de base de datos

---

## 📚 Recursos

- **Documentación RCP:** https://docs.restrictcontentpro.com/
- **WordPress REST API:** https://developer.wordpress.org/rest-api/
- **JWT Authentication:** https://wordpress.org/plugins/jwt-authentication-for-wp-rest-api/

---

## 🎯 Próximos Pasos

Después de instalar el plugin:

1. ✅ Verificar que el endpoint responda correctamente
2. ✅ Actualizar el código de Supabase para usar el nuevo endpoint
3. ✅ Ejecutar sincronización: `./scripts_macos/sync_membership_catalog.sh`
4. ✅ Verificar que se sincronicen todas las membresías

---

**Última actualización:** 3 de octubre de 2025

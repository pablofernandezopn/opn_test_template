# 🛠️ Scripts macOS - Supabase

Scripts de utilidad para gestionar el entorno local de Supabase en macOS.

## 📋 Scripts Disponibles

### 1. `deploy_local.sh` - Despliegue Local

Inicia y configura Supabase en modo desarrollo local.

**Uso:**
```bash
./scripts_macos/deploy_local.sh
```

**Funciones:**
- ✅ Verifica que exista el archivo `.env` con las variables necesarias
- 🔐 Valida que las variables requeridas estén configuradas
- 🛑 Detiene instancias previas de Supabase
- 🚀 Inicia Supabase con todas las configuraciones
- 📊 Muestra URLs de acceso y comandos útiles
- 📝 Guarda log en `/tmp/supabase_deploy_*.log`

**Salida esperada:**
```
========================================================================
  🚀 DESPLIEGUE LOCAL DE SUPABASE
========================================================================

🔍 Verificando configuración...
✅ Archivo .env encontrado
🔐 Verificando variables de entorno...
✅ Variables de entorno configuradas

🛑 Deteniendo instancia existente (si existe)...
✅ Instancia detenida

🚀 Iniciando Supabase...
   (Esto puede tardar unos segundos)

✅ Supabase iniciado correctamente!

========================================================================
  ✅ DESPLIEGUE COMPLETADO
========================================================================

📍 URLs de acceso:
   API:      http://127.0.0.1:54321
   Database: postgresql://postgres:postgres@127.0.0.1:54322/postgres
   Studio:   http://127.0.0.1:54323
```

---

### 2. `sync_membership_catalog.sh` - Sincronización de Catálogo

Sincroniza los niveles de membresía desde WordPress RCP a Supabase.

**Uso:**
```bash
./scripts_macos/sync_membership_catalog.sh
```

**Funciones:**
- 🔍 Verifica que Supabase esté corriendo
- 📡 Llama al endpoint de sincronización
- 📊 Muestra estadísticas (creados, actualizados, errores)
- 📝 Guarda log en `/tmp/supabase_sync_logs/sync_catalog_*.log`
- 🎨 Output formateado con colores (requiere `jq` para formato JSON)

**Salida esperada:**
```
========================================================================
  🔄 SINCRONIZACIÓN DE CATÁLOGO DE MEMBRESÍAS
========================================================================

🔍 Verificando que Supabase esté corriendo...
✅ Supabase está corriendo

📡 Llamando al endpoint de sincronización...
   Endpoint: http://localhost:54321/functions/v1/login-register/v1/sync_membership_catalog

✅ Sincronización exitosa!

📊 Resultado:
{
  "success": true,
  "message": "Membership catalog synced successfully",
  "levels": [...]
}

📈 Estadísticas:
   ✓ Creados:      0
   ↻ Actualizados: 3
   ✗ Errores:      0
   Σ Total:        3

📝 Log guardado en: /tmp/supabase_sync_logs/sync_catalog_20251003_123456.log

========================================================================
✅ Proceso completado
========================================================================
```

---

## 🔧 Requisitos

### Obligatorios
- **Supabase CLI** instalado: `brew install supabase/tap/supabase`
- **curl** (incluido en macOS)
- **Archivo `.env`** configurado en `functions/.env`

### Opcionales (pero recomendados)
- **jq** para formato JSON: `brew install jq`

---

## 📝 Configuración Inicial

1. **Copiar el archivo de ejemplo:**
   ```bash
   cp functions/.env.example functions/.env
   ```

2. **Configurar variables de entorno en `functions/.env`:**
   ```bash
   WP_URL=https://tu-wordpress-site.com
   WP_ADMIN_USERNAME=tu-usuario-admin
   WP_ADMIN_PASSWORD=tu-password-admin
   WP_JWT_SECRET=tu-jwt-secret
   REVENUECAT_WEBHOOK_SECRET=tu-revenuecat-secret
   ```

3. **Hacer los scripts ejecutables:**
   ```bash
   chmod +x scripts_macos/*.sh
   ```

---

## 🚀 Flujo de Trabajo Típico

### Primera vez
```bash
# 1. Configurar .env
vim functions/.env

# 2. Iniciar Supabase
./scripts_macos/deploy_local.sh

# 3. Sincronizar catálogo de membresías
./scripts_macos/sync_membership_catalog.sh
```

### Desarrollo diario
```bash
# Iniciar Supabase (si no está corriendo)
./scripts_macos/deploy_local.sh

# Sincronizar cambios del catálogo cuando sea necesario
./scripts_macos/sync_membership_catalog.sh
```

---

## 🐛 Troubleshooting

### Error: "Supabase no está corriendo"
```bash
# Verificar estado
docker ps | grep supabase

# Si no está corriendo, ejecutar
./scripts_macos/deploy_local.sh
```

### Error: "No se encontró el archivo functions/.env"
```bash
# Copiar desde el ejemplo
cp functions/.env.example functions/.env

# Editar y configurar
vim functions/.env
```

### Error: "Variables requeridas no están configuradas"
```bash
# Verificar que las variables tengan valores reales
cat functions/.env | grep -v "^#" | grep "your-"

# Editar y reemplazar valores "your-*" con valores reales
vim functions/.env
```

### Ver logs en tiempo real
```bash
# Logs de Supabase Functions
supabase functions logs

# Logs del contenedor Edge Runtime
docker logs -f supabase_edge_runtime_opn_gc_test

# Ver todos los logs de sincronización
ls -lah /tmp/supabase_sync_logs/
tail -f /tmp/supabase_sync_logs/sync_catalog_*.log
```

---

## 📚 Recursos Adicionales

- **Documentación de Supabase CLI:** https://supabase.com/docs/guides/cli
- **Documentación de Edge Functions:** https://supabase.com/docs/guides/functions
- **WordPress RCP API:** https://docs.restrictcontentpro.com/category/1884-rest-api

---

## 🎯 Próximos Scripts (Roadmap)

- [ ] `test_endpoints.sh` - Probar todos los endpoints
- [ ] `backup_db.sh` - Backup de la base de datos local
- [ ] `restore_db.sh` - Restaurar base de datos
- [ ] `deploy_production.sh` - Despliegue a producción
- [ ] `migrate_db.sh` - Ejecutar migraciones pendientes

---

**Última actualización:** 3 de octubre de 2025

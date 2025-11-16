# 📚 Documentación Técnica - Sistema de Membresías

Documentación esencial del sistema de gestión de membresías que integra WordPress RCP, Supabase y RevenueCat.

---

## 📋 Índice de Documentos

### 🗄️ Base de Datos
- **[DATABASE_STRUCTURE.md](DATABASE_STRUCTURE.md)** - Estructura completa de las tablas, relaciones y tipos de datos
- **[DATABASE_TRIGGERS.md](DATABASE_TRIGGERS.md)** - Triggers y funciones automáticas de la base de datos

### 🔄 Sistema de Membresías
- **[SISTEMA_MEMBRESIAS.md](SISTEMA_MEMBRESIAS.md)** - Flujo completo del sistema de sincronización entre plataformas

---

## 🏗️ Arquitectura General

```
┌─────────────────┐
│   WordPress     │
│   (RCP API)     │
└────────┬────────┘
         │
         │ REST API
         ▼
┌─────────────────┐       ┌─────────────────┐
│  Supabase       │◄─────►│   RevenueCat    │
│  (Functions)    │       │   (Webhooks)    │
└────────┬────────┘       └─────────────────┘
         │
         │ PostgreSQL
         ▼
┌─────────────────┐
│   Database      │
│  - users        │
│  - memberships  │
│  - levels       │
└─────────────────┘
```

---

## 🔑 Conceptos Clave

### ID Unificado
Todos los sistemas usan el mismo ID de usuario:
- `users.id` en Supabase (bigint)
- `user_id` en WordPress
- `app_user_id` en RevenueCat

### Access Levels
Los niveles de acceso definen los permisos:
- **1** = Freemium/Gratis
- **2** = Premium
- **3** = Premium Plus

### Fuentes de Sincronización
Las membresías pueden provenir de:
- **wordpress** - Compra directa en WordPress
- **revenuecat** - Compra in-app via RevenueCat
- **manual** - Asignación manual por administrador

---

## 🔗 Enlaces Rápidos

### Repositorio de Código
- Scripts macOS: `../scripts_macos/`
- Functions: `../functions/login-register/`
- Plugin WordPress: `../wordpress_plugin/`

### Endpoints Principales
- Login: `POST /v1/login`
- Register: `POST /v1/register`
- Sync Memberships: `POST /v1/sync_memberships`
- Sync Catalog: `POST /v1/sync_membership_catalog`

---

## 🛠️ Herramientas de Desarrollo

### Scripts Útiles
```bash
# Iniciar entorno local
./scripts_macos/deploy_local.sh

# Sincronizar catálogo de membresías
./scripts_macos/sync_membership_catalog.sh
```

### Conexión a Base de Datos
```bash
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres
```

---

## 📖 Para Empezar

1. Lee primero **[SISTEMA_MEMBRESIAS.md](SISTEMA_MEMBRESIAS.md)** para entender el flujo general
2. Consulta **[DATABASE_STRUCTURE.md](DATABASE_STRUCTURE.md)** para conocer la estructura de datos
3. Revisa **[DATABASE_TRIGGERS.md](DATABASE_TRIGGERS.md)** para entender la lógica automática

---

**Última actualización:** 3 de octubre de 2025

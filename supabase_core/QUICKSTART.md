# 🚀 Quick Start - Supabase Core

## Para desarrollo LOCAL (todavía no tienes proyectos en cloud)

### 1️⃣ Setup inicial

```bash
cd supabase_core

# Copiar variables de entorno para desarrollo local
cp .env.local.example .env

# Si no existe config.toml, copiarlo desde template
cp config.toml.template config.toml
```

### 2️⃣ Levantar Supabase local

```bash
npm run dev
# o
supabase start
```

Verás URLs como:
```
API URL: http://127.0.0.1:54321
Studio URL: http://127.0.0.1:54323  ← Abre esto en el navegador
```

### 3️⃣ Desarrollar

```bash
# Crear nueva migración
npm run new:migration add_my_feature

# Edita el archivo SQL creado en migrations/

# Aplicar cambios (resetea DB)
npm run dev:reset

# Ver Studio para inspeccionar DB
# http://127.0.0.1:54323
```

### 4️⃣ Probar edge functions

```bash
# Las functions ya están desplegadas localmente
curl http://127.0.0.1:54321/functions/v1/login-register/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}'
```

---

## Para PRODUCCIÓN (cuando tengas proyectos en Supabase Cloud)

### 1️⃣ Configurar credenciales

```bash
# Editar project-configs/policia_nacional.env
PROJECT_REF="abc123def456"  # Tu Project Reference ID

# Editar project-configs/guardia_civil.env
PROJECT_REF="xyz789ghi012"  # Tu Project Reference ID
```

**¿Dónde encontrar PROJECT_REF?**
- Dashboard de Supabase → Settings → General → Reference ID

### 2️⃣ Configurar secrets

```bash
npm run secrets:policia
npm run secrets:guardia
```

### 3️⃣ Desplegar

```bash
# Desplegar a un proyecto
npm run deploy:policia

# O a todos
npm run deploy:all
```

---

## 📝 Comandos más usados

### Desarrollo local
```bash
npm run dev              # Levantar Supabase local
npm run dev:stop         # Detener Supabase local
npm run dev:reset        # Resetear DB y aplicar migraciones
npm run dev:status       # Ver status
npm run new:migration    # Crear nueva migración
```

### Producción
```bash
npm run deploy:all       # Desplegar a todos los proyectos
npm run migrate:policia  # Solo migraciones
npm run functions:guardia # Solo functions
```

---

## 🔄 Flujo típico

### Desarrollo local
```bash
# 1. Levantar Supabase
npm run dev

# 2. Crear migración
npm run new:migration add_notifications

# 3. Editar migrations/XXXX_add_notifications.sql

# 4. Aplicar cambios
npm run dev:reset

# 5. Probar en Studio: http://127.0.0.1:54323
```

### Desplegar a producción
```bash
# Cuando esté listo
npm run deploy:all
```

---

## 📚 Más info

- **LOCAL_DEV.md** - Guía completa de desarrollo local
- **MIGRATION_GUIDE.md** - Migración desde proyectos antiguos
- **README.md** - Documentación completa
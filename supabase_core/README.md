# Supabase Core - Backend Unificado Multi-Proyecto

Este repositorio contiene las **migraciones** y **edge functions** compartidas para múltiples proyectos de Supabase.

## 📁 Estructura

```
supabase_core/
├── migrations/              # ← Fuente única de migraciones
├── functions/               # ← Edge functions compartidas
├── project-configs/         # ← Configuración de cada proyecto
│   ├── policia_nacional.env
│   └── guardia_civil.env
├── scripts/                 # ← Scripts de deploy
│   ├── deploy.sh           # Desplegar todo a un proyecto
│   ├── deploy-migrations.sh
│   ├── deploy-functions.sh
│   └── deploy-all.sh       # Desplegar a todos los proyectos
├── config.toml.template
└── package.json
```

## 🚀 Configuración Inicial

### 1. Configurar credenciales de proyectos

Edita los archivos en `project-configs/`:

**project-configs/policia_nacional.env:**
```bash
PROJECT_REF="tu-project-ref-de-supabase"
SUPABASE_URL="https://tu-proyecto.supabase.co"
```

**project-configs/guardia_civil.env:**
```bash
PROJECT_REF="otro-project-ref"
SUPABASE_URL="https://otro-proyecto.supabase.co"
```

💡 **Cómo obtener el PROJECT_REF:**
- Ve a tu proyecto en Supabase Dashboard
- Settings → General → Reference ID

### 2. Instalar dependencias (opcional)

```bash
npm install
```

## 📝 Uso Diario

### Desplegar a un proyecto específico

```bash
# Usando NPM
npm run deploy:policia
npm run deploy:guardia

# O directamente con el script
./scripts/deploy.sh policia_nacional
./scripts/deploy.sh guardia_civil
```

### Desplegar solo migraciones

```bash
npm run migrate:policia
npm run migrate:guardia
```

### Desplegar solo functions

```bash
npm run functions:policia
npm run functions:guardia
```

### Desplegar a TODOS los proyectos

```bash
npm run deploy:all
```

## ✏️ Crear Nueva Migración

```bash
# Crear nueva migración
npm run new:migration nombre_de_la_migracion

# Se creará en migrations/TIMESTAMP_nombre_de_la_migracion.sql
```

Luego despliega a los proyectos:

```bash
npm run deploy:all
```

## 🔄 Flujo de Trabajo

### Escenario 1: Agregar nueva tabla

```bash
# 1. Crear migración
npm run new:migration add_users_table

# 2. Editar migrations/XXXX_add_users_table.sql
# 3. Desplegar a todos los proyectos
npm run deploy:all
```

### Escenario 2: Modificar Edge Function

```bash
# 1. Editar functions/mi-function/index.ts
# 2. Desplegar functions a todos los proyectos
npm run functions:policia
npm run functions:guardia
```

### Escenario 3: Agregar nuevo proyecto

```bash
# 1. Crear archivo de configuración
cp project-configs/policia_nacional.env project-configs/nuevo_proyecto.env

# 2. Editar nuevo_proyecto.env con las credenciales

# 3. Agregar scripts en package.json
"deploy:nuevo": "./scripts/deploy.sh nuevo_proyecto"
```

## 🔐 Variables de Entorno en Functions

Las edge functions usan **secrets** específicos para cada proyecto.

### Configurar secrets automáticamente

Los secrets ya están copiados de tus proyectos antiguos en:
- `project-configs/policia_nacional.secrets`
- `project-configs/guardia_civil.secrets`

Para aplicarlos a tus proyectos en Supabase Cloud:

```bash
# Configurar todos los secrets de Policía Nacional
npm run secrets:policia

# Configurar todos los secrets de Guardia Civil
npm run secrets:guardia
```

### Secrets incluidos

- **WordPress**: WP_URL, WP_ADMIN_USERNAME, WP_ADMIN_PASSWORD
- **JWT Auth**: JWT_AUTH_SECRET_KEY, JWT_AUTH_CORS_ENABLE
- **OpenAI**: OPEN_AI_KEY
- **RAG API**: RAG_API_URL
- **RevenueCat** (si aplica): REVENUECAT_API_KEY, RC_WEBHOOK_SECRET, RC_SECRET_API_KEY_V1

### Configurar secret individual

```bash
supabase link --project-ref TU_PROJECT_REF
supabase secrets set MY_SECRET=value
```

### Ver secrets configurados

```bash
supabase link --project-ref TU_PROJECT_REF
supabase secrets list
```

## 📊 Comparar Base de Datos vs Migraciones

```bash
# Linkear al proyecto que quieres comparar
supabase link --project-ref TU_PROJECT_REF

# Ver diferencias
npm run db:diff
```

## ⚠️ Importante

1. **Nunca edites migraciones ya aplicadas** - Crea una nueva migración para cambios
2. **Prueba primero en desarrollo** antes de desplegar a producción
3. **Las apps usan flavors** para conectarse a diferentes proyectos:
   - Flavor Policía → Apunta a proyecto policia_nacional
   - Flavor Guardia → Apunta a proyecto guardia_civil

## 🗂️ Relación con Apps

Las apps (Flutter/CMS) NO están en este repositorio. Ellas usan **flavors** para conectarse:

```dart
// App con flavor policia_nacional
SUPABASE_URL=https://policia-proyecto.supabase.co

// App con flavor guardia_civil
SUPABASE_URL=https://guardia-proyecto.supabase.co
```

Este repositorio (`supabase_core`) solo maneja el **backend**: migraciones y functions.

## 🐛 Troubleshooting

### Error: "Project not linked"
```bash
# Linkear manualmente
supabase link --project-ref TU_PROJECT_REF
```

### Ver migraciones aplicadas en un proyecto
```bash
supabase link --project-ref TU_PROJECT_REF
supabase migration list
```

### Resetear base de datos local
```bash
npm run db:reset:policia
npm run db:reset:guardia
```

## 📚 Recursos

- [Supabase CLI Docs](https://supabase.com/docs/guides/cli)
- [Migrations Guide](https://supabase.com/docs/guides/cli/local-development#database-migrations)
- [Edge Functions Guide](https://supabase.com/docs/guides/functions)
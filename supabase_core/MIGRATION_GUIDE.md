# 🔄 Guía de Migración a Supabase Core

Esta guía te ayudará a migrar desde tus proyectos actuales (`supabase_policia_nacional` y `supabase_guardia_civil`) al nuevo sistema centralizado `supabase_core`.

## ✅ Secretos ya copiados

Ya he copiado tus secrets desde los proyectos antiguos:

- ✅ WordPress (WP_URL, WP_ADMIN_USERNAME, WP_ADMIN_PASSWORD)
- ✅ JWT Auth (JWT_AUTH_SECRET_KEY, JWT_AUTH_CORS_ENABLE)
- ✅ OpenAI (OPEN_AI_KEY)
- ✅ RAG API (RAG_API_URL)

**Archivos creados:**
- `project-configs/policia_nacional.secrets`
- `project-configs/guardia_civil.secrets`

## 📝 Pasos para migración completa

### 1. Configurar PROJECT_REF

Edita los archivos `.env`:

```bash
# Editar project-configs/policia_nacional.env
PROJECT_REF="tu-project-ref-policia"

# Editar project-configs/guardia_civil.env
PROJECT_REF="tu-project-ref-guardia"
```

**¿Dónde encontrar PROJECT_REF?**
1. Ve a Supabase Dashboard
2. Selecciona tu proyecto
3. Settings → General → Reference ID

### 2. Configurar secrets en Supabase Cloud

Una vez que tengas el PROJECT_REF configurado:

```bash
cd supabase_core

# Configurar secrets para Policía Nacional
npm run secrets:policia

# Configurar secrets para Guardia Civil
npm run secrets:guardia
```

Esto subirá todos los secrets (WordPress, OpenAI, JWT, etc.) a cada proyecto.

### 3. Verificar secrets configurados

```bash
# Ver secrets en Policía Nacional
supabase link --project-ref TU_PROJECT_REF_POLICIA
supabase secrets list

# Ver secrets en Guardia Civil
supabase link --project-ref TU_PROJECT_REF_GUARDIA
supabase secrets list
```

### 4. Desplegar migraciones y functions

```bash
# Opción 1: Desplegar a ambos proyectos
npm run deploy:all

# Opción 2: Desplegar individualmente
npm run deploy:policia
npm run deploy:guardia
```

## 🔍 Verificación post-migración

### Verificar migraciones aplicadas

```bash
supabase link --project-ref TU_PROJECT_REF
supabase migration list
```

Deberías ver todas las migraciones marcadas como aplicadas.

### Verificar functions desplegadas

En Supabase Dashboard:
- Functions → Deberías ver todas las functions (login-register, etc.)

### Probar edge functions

```bash
# Probar login-register
curl -X POST https://TU_PROYECTO.supabase.co/functions/v1/login-register/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

## 📊 Comparación de estructura

### Antes (múltiples repositorios)

```
opn_test_policia_nacional/
├── supabase_policia_nacional/
│   ├── migrations/
│   ├── functions/
│   └── .env

opn_test_guardia_civil/
├── supabase_guardia_civil/
│   ├── migrations/
│   ├── functions/
│   └── .env
```

### Después (centralizado)

```
opn_test_template/
└── supabase_core/
    ├── migrations/          # ← Una sola fuente
    ├── functions/           # ← Compartidas
    ├── project-configs/
    │   ├── policia_nacional.env
    │   ├── policia_nacional.secrets
    │   ├── guardia_civil.env
    │   └── guardia_civil.secrets
    └── scripts/            # ← Deployment automatizado
```

## 🚀 Nuevo flujo de trabajo

### Agregar nueva migración

```bash
cd supabase_core
npm run new:migration add_new_feature

# Editar migrations/XXXX_add_new_feature.sql
# Desplegar a todos los proyectos
npm run deploy:all
```

### Modificar edge function

```bash
# Editar functions/login-register/index.ts
npm run functions:policia
npm run functions:guardia
```

### Agregar nuevo secret

```bash
# Editar project-configs/policia_nacional.secrets
NEW_SECRET=valor

# Aplicar
npm run secrets:policia
```

## ⚠️ Importante

1. **NO elimines** los proyectos antiguos hasta verificar que todo funciona
2. **Prueba primero** en desarrollo antes de producción
3. **Las apps NO necesitan cambios** - siguen usando flavors
4. **Mantén sincronizados** los `.secrets` files si cambias credenciales

## 🆘 Troubleshooting

### "Project not linked"
```bash
cd supabase_core
supabase link --project-ref TU_PROJECT_REF
```

### "Secret already exists"
```bash
# Sobrescribir secret
supabase secrets set MI_SECRET=nuevo_valor --linked
```

### Ver diferencias entre DB y migraciones
```bash
npm run db:diff:policia
npm run db:diff:guardia
```

## 📚 Siguiente paso

Lee el [README.md](./README.md) y [QUICKSTART.md](./QUICKSTART.md) para más detalles sobre el uso diario.
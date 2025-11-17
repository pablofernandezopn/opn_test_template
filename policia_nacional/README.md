# Proyecto Supabase - Policía Nacional

Backend de Supabase para la aplicación de Policía Nacional con datos migrados desde la base de datos anterior.

## Configuración

- **Project ID**: `policia_nacional`
- **Puertos**:
  - API: `http://127.0.0.1:54321`
  - Database: `postgresql://postgres:postgres@127.0.0.1:54322/postgres`
  - Studio: `http://127.0.0.1:54323`
  - Mailpit: `http://127.0.0.1:54324`

## Iniciar el proyecto

```bash
cd /Users/pablofernandezlucas/Documents/Isyfu/opn_test_template/policia_nacional/supabase
supabase start
```

## Detener el proyecto

```bash
supabase stop
```

## Migración de datos

Los scripts de migración están en `../migration_policia_nacional/`. Para ejecutar la migración:

```bash
cd ../migration_policia_nacional
SKIP_DOWNLOAD=true ./migrate_one_click.sh
```

## Estructura

```
policia_nacional/
└── supabase/
    ├── config.toml         # Configuración del proyecto
    ├── migrations/         # Migraciones SQL del esquema
    └── functions/          # Edge Functions de Deno
```
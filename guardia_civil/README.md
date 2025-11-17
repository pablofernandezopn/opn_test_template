# Proyecto Supabase - Guardia Civil

Backend de Supabase para la aplicación de Guardia Civil (proyecto nuevo con el mismo esquema que Policía Nacional).

## Configuración

- **Project ID**: `guardia_civil`
- **Puertos**:
  - API: `http://127.0.0.1:54341`
  - Database: `postgresql://postgres:postgres@127.0.0.1:54342/postgres`
  - Studio: `http://127.0.0.1:54343`
  - Mailpit: `http://127.0.0.1:54344`

## Iniciar el proyecto

```bash
cd /Users/pablofernandezlucas/Documents/Isyfu/opn_test_template/guardia_civil/supabase
supabase start
```

## Detener el proyecto

```bash
supabase stop
```

## Estructura

```
guardia_civil/
└── supabase/
    ├── config.toml         # Configuración del proyecto
    ├── migrations/         # Migraciones SQL del esquema (igual que policia_nacional)
    └── functions/          # Edge Functions de Deno (iguales que policia_nacional)
```

## Notas

Este proyecto tiene el mismo esquema de base de datos y edge functions que Policía Nacional, pero es una instancia independiente que se ejecuta en puertos diferentes.
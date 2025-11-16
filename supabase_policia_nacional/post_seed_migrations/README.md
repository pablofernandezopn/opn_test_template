# Migraciones Post-Seed

Este directorio contiene migraciones SQL que **deben ejecutarse después** de cargar los datos en la base de datos.

## ¿Por qué Post-Seed?

Estas migraciones realizan ajustes o cálculos sobre datos existentes, por lo que necesitan que los datos ya estén en la base de datos para funcionar correctamente.

## Migraciones

### 1. `20251031000100_seed_topic_groups_example.sql`

**Propósito:** Crear datos de ejemplo de topic groups y asignar topics existentes.

**Qué hace:**
- Crea un grupo de examen llamado "Examen Oficial 2024"
- Busca topics existentes (Conocimientos, Psicotécnicos, Ortografía)
- Asigna estos topics al grupo en orden secuencial

**Requiere:** Topics ya creados en la base de datos

---

### 2. `20251103000200_update_user_stats_all_topics.sql`

**Propósito:** Recalcular estadísticas de usuarios basándose en sus tests completados.

**Qué hace:**
- Actualiza la función `update_user_total_stats_optimized()` para contar TODOS los tipos de topics
- Recalcula desde cero las estadísticas de todos los usuarios:
  - `totalQuestions`: Total de preguntas respondidas
  - `rightQuestions`: Total de respuestas correctas
  - `wrongQuestions`: Total de respuestas incorrectas
- Muestra un resumen de las estadísticas calculadas

**Requiere:** Usuarios y user_tests ya existentes en la base de datos

---

## Ejecución Automática

Estas migraciones se ejecutan automáticamente cuando usas:

```bash
./setup_complete_database.sh
```

## Ejecución Manual

Si necesitas ejecutarlas manualmente:

```bash
cd supabase

# Ejecutar todas las post-seed migrations
for file in post_seed_migrations/*.sql; do
    PGPASSWORD=postgres psql -h localhost -p 54322 -U postgres -d postgres -f "$file"
done
```

O ejecutar una específica:

```bash
cd supabase
PGPASSWORD=postgres psql -h localhost -p 54322 -U postgres -d postgres -f post_seed_migrations/20251103000200_update_user_stats_all_topics.sql
```

## Orden de Ejecución

Las migraciones post-seed se ejecutan en orden alfabético por nombre de archivo. El formato de timestamp en el nombre garantiza el orden correcto:

1. `20251031000100_seed_topic_groups_example.sql`
2. `20251103000200_update_user_stats_all_topics.sql`

## Notas Importantes

- ⚠️ Estas migraciones NO se ejecutan con `supabase db reset` ya que no están en el directorio `migrations/`
- ✅ Son seguras de ejecutar múltiples veces (son idempotentes)
- 📊 Algunas pueden mostrar warnings si no hay datos suficientes (esto es normal)
- 🔧 Si agregas una nueva migración post-seed, úsala solo para ajustes que requieran datos existentes
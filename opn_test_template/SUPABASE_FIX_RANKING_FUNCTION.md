# Fix para función get_user_topic_group_ranking_entry en Supabase

## Problema

La función `get_user_topic_group_ranking_entry` tiene un error de tipo de datos:
```
structure of query does not match function result type
Returned type text does not match expected type character varying in column 3
```

Este error ocurre porque la función está declarada para retornar un tipo (probablemente `character varying`), pero internamente devuelve `text` en la columna 3.

## Solución

Necesitas actualizar la función en el SQL Editor de Supabase. Aquí hay dos opciones:

### Opción 1: Cambiar el tipo de retorno de la función

Si la columna 3 debe ser `text`, modifica la definición de la función:

```sql
-- Primero elimina la función existente
DROP FUNCTION IF EXISTS get_user_topic_group_ranking_entry(integer, integer);

-- Recrea la función con el tipo correcto
CREATE OR REPLACE FUNCTION get_user_topic_group_ranking_entry(
  p_topic_group_id integer,
  p_user_id integer
)
RETURNS TABLE (
  topics_completed integer,
  total_topics_in_group integer,
  column_3_name text,  -- Cambia 'column_3_name' por el nombre real y usa 'text'
  -- ... resto de columnas
) 
LANGUAGE plpgsql
AS $$
BEGIN
  -- Tu lógica aquí
  RETURN QUERY
  SELECT 
    -- tus columnas
  FROM ...;
END;
$$;
```

### Opción 2: Hacer un CAST en la consulta interna

Si la función debe devolver `character varying`, asegúrate de hacer un CAST en la columna problemática:

```sql
CREATE OR REPLACE FUNCTION get_user_topic_group_ranking_entry(
  p_topic_group_id integer,
  p_user_id integer
)
RETURNS TABLE (
  topics_completed integer,
  total_topics_in_group integer,
  column_3_name character varying,  -- Mantén como character varying
  -- ... resto de columnas
) 
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    some_col1::integer,
    some_col2::integer,
    some_col3::character varying,  -- Asegúrate de hacer CAST aquí
    -- ... resto de columnas
  FROM ...;
END;
$$;
```

## Identificar la columna problemática

Para saber cuál es la columna 3, revisa la definición actual de la función:

```sql
-- Ver la definición actual
SELECT 
  routine_name, 
  data_type,
  ordinal_position,
  parameter_name
FROM information_schema.parameters
WHERE specific_name LIKE '%get_user_topic_group_ranking_entry%'
ORDER BY ordinal_position;
```

## Notas

- La columna 3 podría ser cualquiera de estas basándose en el modelo Dart:
  - `topics_completed`
  - `total_topics_in_group`
  - Algún campo de texto como `username` o similar

- El código de la app ya ha sido actualizado para manejar este error de forma más robusta y no bloqueará la carga de datos.

## Alternativa: Usar una vista materializada

Si la función es muy compleja, considera crear una vista materializada en su lugar:

```sql
CREATE MATERIALIZED VIEW user_topic_group_rankings AS
SELECT 
  -- tus columnas con los tipos correctos
FROM ...;

-- Crear índices
CREATE INDEX idx_utg_user_id ON user_topic_group_rankings(user_id);
CREATE INDEX idx_utg_topic_group_id ON user_topic_group_rankings(topic_group_id);

-- Refrescar periódicamente
-- (puedes configurar esto con pg_cron o un trigger)
```

Luego, desde el código Dart, consultar la vista directamente en lugar de usar `rpc()`.


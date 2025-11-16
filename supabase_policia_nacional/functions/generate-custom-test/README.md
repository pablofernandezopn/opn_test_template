# Generate Custom Test - Edge Function

Edge Function para generar tests personalizados con distribución de probabilidad por topics.

## Descripción

Esta función permite crear tests personalizados seleccionando preguntas aleatorias de múltiples topics de tipo "Study", respetando una distribución de probabilidad definida por el usuario.

## Características

- ✅ Distribución personalizada de preguntas por topic
- ✅ Selección aleatoria de preguntas
- ✅ Validación de topics de tipo "Study"
- ✅ Filtrado opcional por academia
- ✅ Manejo inteligente cuando no hay suficientes preguntas
- ✅ Redistribución automática si un topic no tiene suficientes preguntas
- ✅ Mezcla final de todas las preguntas

## Endpoint

```
POST /functions/v1/generate-custom-test
```

## Request Body

```typescript
{
  "topics": [
    { "id": 1, "weight": 0.4 },   // 40% de las preguntas
    { "id": 2, "weight": 0.35 },  // 35% de las preguntas
    { "id": 3, "weight": 0.25 }   // 25% de las preguntas
  ],
  "totalQuestions": 30,           // Número total de preguntas deseadas
  "academyId": 1                  // (Opcional) Filtrar por academia
}
```

### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `topics` | `TopicWeight[]` | ✅ | Array de topics con sus pesos |
| `topics[].id` | `number` | ✅ | ID del topic |
| `topics[].weight` | `number` | ✅ | Peso/probabilidad (no necesita sumar 1, se normaliza automáticamente) |
| `totalQuestions` | `number` | ✅ | Número total de preguntas deseadas |
| `academyId` | `number` | ❌ | ID de la academia (opcional) |

## Response

### Respuesta exitosa (200)

```json
{
  "success": true,
  "questions": [
    {
      "id": 123,
      "question": "¿Cuál es...?",
      "topic": 1,
      "published": true,
      // ... resto de campos de la pregunta
    }
    // ... más preguntas
  ],
  "distribution": {
    "1": 12,  // Topic 1: 12 preguntas (40%)
    "2": 11,  // Topic 2: 11 preguntas (35%)
    "3": 7    // Topic 3: 7 preguntas (25%)
  },
  "totalQuestions": 30,
  "requestedQuestions": 30,
  "message": "Only 28 questions available..." // Solo si no hay suficientes preguntas
}
```

### Respuesta de error (400/500)

```json
{
  "success": false,
  "error": "Failed to generate test",
  "details": "Topics must be of type 'Study'. Invalid topics: 5, 7"
}
```

## Ejemplos de uso

### Ejemplo 1: Test básico con 3 topics

```bash
curl -X POST 'https://YOUR_PROJECT.supabase.co/functions/v1/generate-custom-test' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "topics": [
      { "id": 1, "weight": 0.5 },
      { "id": 2, "weight": 0.3 },
      { "id": 3, "weight": 0.2 }
    ],
    "totalQuestions": 20
  }'
```

Resultado esperado:
- Topic 1: ~10 preguntas (50%)
- Topic 2: ~6 preguntas (30%)
- Topic 3: ~4 preguntas (20%)

### Ejemplo 2: Test con pesos no normalizados

```bash
curl -X POST 'https://YOUR_PROJECT.supabase.co/functions/v1/generate-custom-test' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "topics": [
      { "id": 1, "weight": 10 },
      { "id": 2, "weight": 6 },
      { "id": 3, "weight": 4 }
    ],
    "totalQuestions": 50,
    "academyId": 1
  }'
```

La función normaliza automáticamente (10+6+4=20):
- Topic 1: ~25 preguntas (10/20 = 50%)
- Topic 2: ~15 preguntas (6/20 = 30%)
- Topic 3: ~10 preguntas (4/20 = 20%)

### Ejemplo 3: Desde Flutter/Dart

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Question>> generateCustomTest({
  required List<TopicWeight> topics,
  required int totalQuestions,
  int? academyId,
}) async {
  final response = await Supabase.instance.client.functions.invoke(
    'generate-custom-test',
    body: {
      'topics': topics.map((t) => {
        'id': t.id,
        'weight': t.weight,
      }).toList(),
      'totalQuestions': totalQuestions,
      if (academyId != null) 'academyId': academyId,
    },
  );

  if (response.status != 200) {
    throw Exception('Failed to generate test: ${response.data}');
  }

  final data = response.data as Map<String, dynamic>;
  final questions = (data['questions'] as List)
      .map((q) => Question.fromJson(q))
      .toList();

  return questions;
}

// Uso
final questions = await generateCustomTest(
  topics: [
    TopicWeight(id: 1, weight: 0.4),
    TopicWeight(id: 2, weight: 0.35),
    TopicWeight(id: 3, weight: 0.25),
  ],
  totalQuestions: 30,
  academyId: 1,
);
```

## Manejo de casos especiales

### 1. Topic sin suficientes preguntas

Si un topic no tiene suficientes preguntas publicadas, la función:
1. Devuelve todas las preguntas disponibles de ese topic
2. Continúa con los otros topics
3. Devuelve un mensaje indicando que no se alcanzó el total solicitado

### 2. Topic sin preguntas

Si un topic no tiene ninguna pregunta publicada:
1. Se omite ese topic
2. La distribución se ajusta automáticamente
3. Se refleja en el campo `distribution` de la respuesta

### 3. Weights que suman más o menos de 1

Los pesos se normalizan automáticamente, no es necesario que sumen 1:
- `[0.5, 0.3, 0.2]` → 50%, 30%, 20%
- `[5, 3, 2]` → 50%, 30%, 20%
- `[100, 60, 40]` → 50%, 30%, 20%

## Validaciones

La función valida:
- ✅ Todos los topics existen en la base de datos
- ✅ Todos los topics son de tipo "Study" (no "Mock")
- ✅ Los pesos son números positivos
- ✅ El número total de preguntas es positivo
- ✅ El academyId (si se proporciona) es un número válido

## Algoritmo de distribución

1. **Normalización de pesos**: Convierte los pesos a porcentajes
2. **Cálculo de distribución**: Asigna preguntas proporcionales a cada topic
3. **Ajuste por redondeo**: El último topic recibe las preguntas restantes para evitar errores de redondeo
4. **Consulta aleatoria**: Obtiene todas las preguntas disponibles y selecciona aleatoriamente
5. **Mezcla final**: Usa Fisher-Yates para mezclar todas las preguntas

## Performance

- ⚡ Consultas paralelas por topic (Promise.all)
- 🎲 Selección aleatoria eficiente en memoria
- 📊 Una sola consulta por topic
- 🔀 Mezcla O(n) con Fisher-Yates

## Deployment

```bash
# Desplegar la función
supabase functions deploy generate-custom-test

# Ver logs
supabase functions logs generate-custom-test
```

## Testing local

```bash
# Servir todas las funciones localmente
supabase functions serve

# Probar la función
curl -X POST 'http://localhost:54321/functions/v1/generate-custom-test' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' \
  -H 'Content-Type: application/json' \
  -d '{
    "topics": [
      { "id": 1, "weight": 0.5 },
      { "id": 2, "weight": 0.5 }
    ],
    "totalQuestions": 10
  }'
```

## Errores comunes

| Error | Causa | Solución |
|-------|-------|----------|
| `Topics must be of type 'Study'` | Topics de tipo Mock incluidos | Usar solo topics de Study |
| `topics must be a non-empty array` | Array vacío o no es array | Enviar al menos un topic |
| `Invalid weight for topic X` | Peso negativo o no numérico | Usar pesos positivos |
| `totalQuestions must be a positive number` | Número <= 0 | Usar número positivo |

## Notas

- Solo funciona con topics de tipo **Study** (no Mock)
- Las preguntas se obtienen solo si `published = true`
- Las preguntas se mezclan aleatoriamente al final
- La distribución real puede variar si no hay suficientes preguntas

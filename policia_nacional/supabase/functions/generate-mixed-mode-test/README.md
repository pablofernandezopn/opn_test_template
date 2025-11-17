# Generate Mixed-Mode Test Edge Function

Esta edge function genera tests personalizados combinando múltiples modos:
- **Temas**: Preguntas de topics seleccionados
- **Falladas**: Preguntas que el usuario ha fallado históricamente
- **En Blanco**: Preguntas que el usuario dejó en blanco

## Request Body

```typescript
{
  // Modos seleccionados (puede combinar múltiples)
  modes: ('topics' | 'failed' | 'skipped')[],

  // Para modo 'topics' (requerido si 'topics' está en modes)
  topics?: [
    { id: number, weight: number },
    ...
  ],

  // Para modos 'failed' y 'skipped' (requerido si están en modes)
  userId?: string,

  // Configuración general
  totalQuestions: number,
  academyId?: number,
  difficulties?: ('easy' | 'normal' | 'hard')[],

  // Opcional: filtrar preguntas falladas/en blanco por topics
  topicIds?: number[]
}
```

## Example Requests

### Modo Solo Temas
```json
{
  "modes": ["topics"],
  "topics": [
    { "id": 1, "weight": 1 },
    { "id": 2, "weight": 1 }
  ],
  "totalQuestions": 20,
  "academyId": 1,
  "difficulties": ["normal", "hard"]
}
```

### Modo Solo Falladas
```json
{
  "modes": ["failed"],
  "userId": "uuid-del-usuario",
  "totalQuestions": 15,
  "academyId": 1,
  "topicIds": [1, 2, 3]
}
```

### Modo Mixto (Temas + Falladas)
```json
{
  "modes": ["topics", "failed"],
  "topics": [
    { "id": 1, "weight": 1 },
    { "id": 2, "weight": 1 }
  ],
  "userId": "uuid-del-usuario",
  "totalQuestions": 30,
  "academyId": 1,
  "difficulties": ["normal"]
}
```

### Modo Completo (Todos los modos)
```json
{
  "modes": ["topics", "failed", "skipped"],
  "topics": [
    { "id": 1, "weight": 1 }
  ],
  "userId": "uuid-del-usuario",
  "totalQuestions": 50,
  "academyId": 1
}
```

## Response

```typescript
{
  success: boolean,
  questions: Question[],
  modeDistribution: {
    topics?: number,
    failed?: number,
    skipped?: number
  },
  topicDistribution: {
    [topicId: string]: number
  },
  totalQuestions: number,
  requestedQuestions: number,
  durationMinutes: number,
  message?: string
}
```

## Deployment

```bash
supabase functions deploy generate-mixed-mode-test
```

## Testing Locally

```bash
supabase functions serve generate-mixed-mode-test --env-file supabase/functions/.env
```

## Notes

- Las preguntas se mezclan (shuffle) antes de ser devueltas
- Se eliminan duplicados automáticamente
- Si no hay suficientes preguntas disponibles, se devuelven todas las disponibles con un mensaje de advertencia
- La duración se calcula como la mitad del número de preguntas (redondeado hacia arriba)
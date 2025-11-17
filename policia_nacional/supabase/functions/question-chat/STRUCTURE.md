# 📁 Question Chat - Estructura del Proyecto

Estructura organizada y escalable para la edge function de chat contextual.

## 📂 Estructura de Carpetas

```
question-chat/
├── index.ts                          # Entry point principal
├── index_old.ts                      # Backup de versión anterior
│
├── models/                           # 📦 Modelos TypeScript
│   ├── question.ts                   # QuestionData, QuestionOption, Topic
│   ├── conversation.ts               # Conversation, Message
│   ├── user_performance.ts           # UserStats, QuestionPerformance, CurrentTest
│   ├── rag_api.ts                    # RAGApiRequest, RAGApiResponse, LawCitation
│   └── request.ts                    # QuestionChatRequest, QuestionChatResponse
│
├── repositories/                     # 🗄️ Acceso a datos
│   ├── supabase_repository.ts        # Comunicación con Supabase
│   └── rag_api_repository.ts         # Comunicación con RAG API
│
├── utils/                            # 🔧 Utilidades
│   └── context_builder.ts            # Construcción de query enriquecido
│
├── test_question_chat.ts             # 🧪 Suite de tests
└── README.md                         # 📖 Documentación
```

---

## 📦 Models

### `models/question.ts`
Modelos relacionados con preguntas del test.

```typescript
export interface QuestionOption { ... }
export interface Topic { ... }
export interface QuestionData { ... }
export interface QuestionContext { ... }
```

### `models/conversation.ts`
Modelos de conversaciones y mensajes.

```typescript
export interface Conversation { ... }
export interface Message { ... }
export interface ConversationWithMessages { ... }
```

### `models/user_performance.ts`
Modelos de rendimiento del usuario.

```typescript
export interface UserStats { ... }
export interface QuestionPerformance { ... }
export interface CurrentTest { ... }
export interface UserPerformanceContext { ... }
```

### `models/rag_api.ts`
Modelos para comunicación con RAG API.

```typescript
export interface RAGApiRequest { ... }
export interface RAGApiResponse { ... }
export interface LawCitation { ... }
```

### `models/request.ts`
Modelos de request/response de la API.

```typescript
export interface QuestionChatRequest { ... }
export interface QuestionChatResponse { ... }
export interface ExtraContext { ... }
```

---

## 🗄️ Repositories

### `SupabaseRepository`
Encapsula todas las operaciones con Supabase.

**Métodos:**
- `getQuestionById(questionId)` - Obtener pregunta completa con opciones y tema
- `getConversationByQuestionId(userId, questionId)` - Buscar conversación existente
- `createConversation(userId, questionId, title, metadata)` - Crear nueva conversación
- `getConversationWithMessages(conversationId, userId)` - Obtener conversación + mensajes
- `createMessage(conversationId, role, content, metadata)` - Guardar mensaje
- `getUserPerformanceContext(userId, questionId, testId?)` - Obtener rendimiento completo
- `generateConversationTitle(conversationId)` - Generar título automático

### `RAGApiRepository`
Comunicación con el RAG API externo.

**Métodos:**
- `query(enrichedQuery)` - Enviar query al RAG y obtener respuesta
- `healthCheck()` - Verificar disponibilidad del RAG
- `getConfig()` - Obtener configuración actual

---

## 🔧 Utils

### `context_builder.ts`
Construcción del query enriquecido para el RAG.

**Funciones:**
- `buildEnrichedQuery(message, questionData, userAnswer?, extraContext?, performanceContext?)` - Construir query completo
- `buildBasicQuestionContext(questionData, userAnswer?)` - Contexto básico sin performance

---

## 🔄 Flujo de Datos

```
1. Request → index.ts
              ↓
2. Auth validation → Supabase Client
              ↓
3. Initialize Repositories
    - SupabaseRepository
    - RAGApiRepository
              ↓
4. Route Request
    - GET → handleGetConversation()
    - POST → handlePostMessage()
              ↓
5. Data Flow (POST):

    SupabaseRepository.getQuestionById()
              ↓
    SupabaseRepository.getConversationByQuestionId()
    o
    SupabaseRepository.createConversation()
              ↓
    SupabaseRepository.getUserPerformanceContext()
              ↓
    context_builder.buildEnrichedQuery()
              ↓
    SupabaseRepository.createMessage() [user]
              ↓
    RAGApiRepository.query()
              ↓
    SupabaseRepository.createMessage() [assistant]
              ↓
    Response → Client
```

---

## 📊 Tablas de Supabase Utilizadas

| Tabla | Operación | Repositorio |
|-------|-----------|-------------|
| `questions` | SELECT | `getQuestionById()` |
| `question_options` | SELECT (join) | `getQuestionById()` |
| `topic` | SELECT (join) | `getQuestionById()` |
| `conversations` | SELECT, INSERT, UPDATE | `getConversationByQuestionId()`, `createConversation()` |
| `conversation_questions` | SELECT, INSERT | `getConversationByQuestionId()`, `createConversation()` |
| `messages` | SELECT, INSERT | `getConversationWithMessages()`, `createMessage()` |
| `users` | SELECT | `getUserPerformanceContext()` |
| `user_test_answers` | SELECT | `getUserPerformanceContext()` |
| `user_tests` | SELECT | `getUserPerformanceContext()` |
| `system_prompts` | SELECT | `createConversation()` |

---

## 🎯 Ventajas de Esta Estructura

### ✅ Separación de Responsabilidades
- **Models**: Solo definiciones de tipos
- **Repositories**: Solo acceso a datos
- **Utils**: Solo lógica de negocio
- **Index**: Solo orquestación

### ✅ Reusabilidad
- Los repositories pueden usarse en otras edge functions
- Los modelos son compartibles
- Las utilidades son modulares

### ✅ Testabilidad
- Cada módulo puede testearse independientemente
- Mock de repositories es sencillo
- Aislamiento de dependencias

### ✅ Mantenibilidad
- Cambios en Supabase solo afectan `supabase_repository.ts`
- Cambios en RAG API solo afectan `rag_api_repository.ts`
- Lógica de negocio separada del acceso a datos

### ✅ Escalabilidad
- Fácil añadir nuevos repositories
- Fácil añadir nuevos modelos
- Fácil añadir nuevas utilidades

---

## 🔍 Dónde Buscar Cada Cosa

| Necesito... | Archivo |
|-------------|---------|
| Ver estructura de datos de pregunta | `models/question.ts` |
| Ver cómo se comunica con Supabase | `repositories/supabase_repository.ts` |
| Ver cómo se llama al RAG | `repositories/rag_api_repository.ts` |
| Ver cómo se construye el query | `utils/context_builder.ts` |
| Ver el flujo principal | `index.ts` (funciones `handleGetConversation`, `handlePostMessage`) |
| Ver los tipos de request/response | `models/request.ts` |

---

## 🚀 Próximas Mejoras

- [ ] Cache layer en `SupabaseRepository`
- [ ] Retry logic en `RAGApiRepository`
- [ ] Logging service centralizado
- [ ] Error handling unificado
- [ ] Metrics/analytics service
- [ ] Rate limiting por usuario
- [ ] Response streaming

---

## 📝 Notas de Desarrollo

- **TypeScript**: Uso extensivo de tipos para seguridad
- **Error Handling**: Cada repository maneja sus propios errores
- **Logging**: Console.log con emojis para mejor trazabilidad
- **Async/Await**: Manejo consistente de promesas
- **Null Safety**: Siempre validar datos antes de usar

# ⚡ TRIGGERS DE LA BASE DE DATOS

## 📊 **Resumen General**

Tu base de datos tiene **20 triggers** que automatizan 13 funciones diferentes. Están organizados por tabla y propósito.

---

## 🎯 **TRIGGERS POR CATEGORÍA**

### **1️⃣ TIMESTAMPS AUTOMÁTICOS** (3 triggers)

Actualizan automáticamente el campo `updated_at` cuando se modifica un registro.

---

#### **📌 Tabla: `challenge`**
```sql
TRIGGER: trg_update_challenge_timestamp
CUANDO: BEFORE UPDATE
FUNCIÓN: update_challenge_timestamp()
```

**¿Qué hace?**
- Actualiza `challenge.updated_at = NOW()` cada vez que se modifica una impugnación

**Ejemplo:**
```sql
-- Usuario admin responde a una impugnación
UPDATE challenge 
SET state = 'approved', reply = 'Tu observación es correcta'
WHERE id = 5;

-- Automáticamente se actualiza:
-- updated_at = '2025-10-03 15:30:00'
```

---

#### **📌 Tabla: `membership_levels`**
```sql
TRIGGER: trigger_update_membership_levels_updated_at
CUANDO: BEFORE UPDATE
FUNCIÓN: update_membership_levels_updated_at()
```

**¿Qué hace?**
- Actualiza `membership_levels.updated_at = NOW()` cuando se modifica un nivel

**Ejemplo:**
```sql
-- Cambias el precio de Premium
UPDATE membership_levels 
SET price_eur = 12.99 
WHERE slug = 'premium';

-- Automáticamente se actualiza:
-- updated_at = '2025-10-03 15:30:00'
```

---

#### **📌 Tabla: `user_memberships`**
```sql
TRIGGER: trigger_update_user_memberships_updated_at
CUANDO: BEFORE UPDATE
FUNCIÓN: update_user_memberships_updated_at()
```

**¿Qué hace?**
- Actualiza `user_memberships.updated_at = NOW()` cuando se modifica una membresía

**Ejemplo:**
```sql
-- Una suscripción expira
UPDATE user_memberships 
SET status = 'expired' 
WHERE id = 'uuid-123';

-- Automáticamente se actualiza:
-- updated_at = '2025-10-03 15:30:00'
```

---

### **2️⃣ OPCIONES DE PREGUNTAS** (2 triggers)

Gestionan las opciones de respuesta de las preguntas.

---

#### **📌 Tabla: `questions`**
```sql
TRIGGER: trg_create_blank_options
CUANDO: AFTER INSERT
FUNCIÓN: create_blank_question_options()
```

**¿Qué hace?**
- Cuando se crea una nueva pregunta, automáticamente crea **4 opciones en blanco** (A, B, C, D)

**Ejemplo:**
```sql
-- Insertas una nueva pregunta
INSERT INTO questions (question, topic) 
VALUES ('¿En qué año se aprobó la Constitución?', 5);

-- Automáticamente se crean en question_options:
-- Opción A: (en blanco)
-- Opción B: (en blanco)
-- Opción C: (en blanco)
-- Opción D: (en blanco)
```

**¿Por qué?**
Facilita la creación de preguntas tipo test, ya que siempre tienes las 4 opciones listas para rellenar.

---

### **3️⃣ CONTADORES AUTOMÁTICOS** (3 triggers)

Mantienen actualizados los contadores de preguntas en los temas.

---

#### **📌 Tabla: `questions`**
```sql
TRIGGER: trg_update_topic_question_count_insert
CUANDO: AFTER INSERT
FUNCIÓN: update_topic_question_count_optimized()

TRIGGER: trg_update_topic_question_count_update
CUANDO: AFTER UPDATE
FUNCIÓN: update_topic_question_count_optimized()

TRIGGER: trg_update_topic_question_count_delete
CUANDO: AFTER DELETE
FUNCIÓN: update_topic_question_count_optimized()
```

**¿Qué hace?**
- Cada vez que se crea, modifica o elimina una pregunta, actualiza el campo `topic.total_questions`

**Ejemplo:**
```sql
-- Tienes el tema "Constitución" con 50 preguntas
SELECT total_questions FROM topic WHERE id = 5;
-- Result: 50

-- Añades una nueva pregunta
INSERT INTO questions (question, topic) 
VALUES ('Nueva pregunta sobre Constitución', 5);

-- Automáticamente:
SELECT total_questions FROM topic WHERE id = 5;
-- Result: 51 ✅
```

**¿Por qué?**
Evita tener que contar las preguntas cada vez que se muestra un tema. El contador ya está actualizado.

---

### **4️⃣ CONFIGURACIÓN AUTOMÁTICA DE TEMAS** (1 trigger)

---

#### **📌 Tabla: `topic`**
```sql
TRIGGER: trg_set_topic_options
CUANDO: BEFORE INSERT
FUNCIÓN: set_topic_options_from_type()
```

**¿Qué hace?**
- Cuando creas un tema nuevo, hereda automáticamente las opciones de su `topic_type`
- Por ejemplo: duración, número de preguntas, si tiene penalización, etc.

**Ejemplo:**
```sql
-- topic_type "Examen Oficial" tiene configurado:
-- - duration: 90 minutos
-- - penalty: 0.33 (penalización por error)
-- - questions_count: 100

-- Creas un nuevo tema
INSERT INTO topic (topic_name, topic_type_id) 
VALUES ('Examen 2024', 3);

-- Automáticamente hereda:
-- duration = 90
-- penalty = 0.33
-- questions_count = 100
```

**¿Por qué?**
Mantiene consistencia. Todos los temas de tipo "Examen" tienen las mismas reglas.

---

### **5️⃣ GESTIÓN DE RESPUESTAS** (4 triggers)

Calculan automáticamente si una respuesta es correcta y actualizan estadísticas.

---

#### **📌 Tabla: `user_test_answers`**
```sql
TRIGGER: trg_calculate_answer_correctness (INSERT y UPDATE)
CUANDO: BEFORE INSERT y BEFORE UPDATE
FUNCIÓN: calculate_answer_correctness()
```

**¿Qué hace?**
- Cuando un usuario responde una pregunta, automáticamente determina si es correcta o incorrecta
- Compara `selected_option_id` con la opción marcada como `is_correct = true`

**Ejemplo:**
```sql
-- Usuario responde pregunta 50, selecciona opción 201
INSERT INTO user_test_answers (user_test_id, question_id, selected_option_id)
VALUES (100, 50, 201);

-- Automáticamente busca:
SELECT id FROM question_options 
WHERE question_id = 50 AND is_correct = true;
-- Result: 202

-- Compara: 201 != 202
-- Por tanto actualiza: correct = false ❌
```

---

#### **📌 Tabla: `user_test_answers`**
```sql
TRIGGER: trg_update_user_test_stats (INSERT, UPDATE, DELETE)
CUANDO: AFTER INSERT, UPDATE, DELETE
FUNCIÓN: update_user_test_stats()
```

**¿Qué hace?**
- Actualiza los contadores en `user_tests`:
  - `correct_answers`: Cuántas acertó
  - `incorrect_answers`: Cuántas falló
  - `score`: Puntuación calculada con penalización

**Ejemplo:**
```sql
-- Usuario hace un test, responde pregunta 1
INSERT INTO user_test_answers (user_test_id, question_id, selected_option_id)
VALUES (100, 50, 201);  -- Correcta

-- Automáticamente actualiza user_tests:
UPDATE user_tests 
SET 
  correct_answers = 1,
  incorrect_answers = 0,
  score = calculate_test_score(100)
WHERE id = 100;
```

**Flujo completo:**
```
Usuario responde pregunta
        ↓
trg_calculate_answer_correctness → Determina si es correcta
        ↓
trg_update_user_test_stats → Actualiza contadores del test
```

---

### **6️⃣ INICIALIZACIÓN DE TESTS** (1 trigger)

---

#### **📌 Tabla: `user_tests`**
```sql
TRIGGER: trg_set_user_test_defaults
CUANDO: BEFORE INSERT
FUNCIÓN: set_user_test_defaults_from_topic()
```

**¿Qué hace?**
- Cuando un usuario empieza un test, inicializa valores desde la configuración del tema:
  - `question_count`: Cuántas preguntas tendrá
  - `duration`: Cuánto tiempo tiene
  - `penalty`: Penalización por error
  - etc.

**Ejemplo:**
```sql
-- Usuario empieza test del tema "Constitución" (id: 5)
INSERT INTO user_tests (user_id, topic_id, started_at)
VALUES (123, 5, NOW());

-- Automáticamente copia desde topic:
-- question_count = 20
-- duration = 30 minutos
-- penalty = 0.33
```

**¿Por qué?**
Evita tener que copiar manualmente toda la configuración cada vez que alguien hace un test.

---

### **7️⃣ ESTADÍSTICAS DE TEMAS** (3 triggers)

Mantienen actualizadas las estadísticas de participación en los temas.

---

#### **📌 Tabla: `user_tests`**
```sql
TRIGGER: trg_update_topic_stats_insert
CUANDO: AFTER INSERT
FUNCIÓN: update_topic_stats_from_user_tests()

TRIGGER: trg_update_topic_stats_update
CUANDO: AFTER UPDATE
FUNCIÓN: update_topic_stats_from_user_tests()

TRIGGER: trg_update_topic_stats_delete
CUANDO: AFTER DELETE
FUNCIÓN: update_topic_stats_from_user_tests()
```

**¿Qué hace?**
- Actualiza `topic.total_participants` cuando alguien hace o termina un test

**Ejemplo:**
```sql
-- Tema "Constitución" tiene 100 participantes
SELECT total_participants FROM topic WHERE id = 5;
-- Result: 100

-- Usuario nuevo hace el test
INSERT INTO user_tests (user_id, topic_id, started_at)
VALUES (999, 5, NOW());

-- Automáticamente:
SELECT total_participants FROM topic WHERE id = 5;
-- Result: 101 ✅
```

---

### **8️⃣ ESTADÍSTICAS DE USUARIOS** (3 triggers)

Mantienen actualizadas las estadísticas globales de cada usuario.

---

#### **📌 Tabla: `user_tests`**
```sql
TRIGGER: trg_update_user_stats_insert
CUANDO: AFTER INSERT
FUNCIÓN: update_user_total_stats_optimized()

TRIGGER: trg_update_user_stats_update
CUANDO: AFTER UPDATE
FUNCIÓN: update_user_total_stats_optimized()

TRIGGER: trg_update_user_stats_delete
CUANDO: AFTER DELETE
FUNCIÓN: update_user_total_stats_optimized()
```

**¿Qué hace?**
- Actualiza las estadísticas globales en `users`:
  - `totalQuestions`: Total de preguntas respondidas
  - `rightQuestions`: Total de preguntas acertadas
  - `wrongQuestions`: Total de preguntas falladas

**Ejemplo:**
```sql
-- Usuario tiene en su perfil:
totalQuestions = 500
rightQuestions = 400
wrongQuestions = 100

-- Hace un nuevo test con 20 preguntas (15 correctas, 5 incorrectas)
INSERT INTO user_tests (...) VALUES (...);

-- Automáticamente se actualiza users:
totalQuestions = 520  (500 + 20)
rightQuestions = 415  (400 + 15)
wrongQuestions = 105  (100 + 5)
```

**¿Por qué?**
Permite mostrar el progreso global del usuario sin tener que sumar todos sus tests cada vez.

---

## 🔄 **FLUJO COMPLETO: Usuario hace un test**

Vamos a ver cómo trabajan todos los triggers juntos:

```sql
-- 1️⃣ Usuario empieza test
INSERT INTO user_tests (user_id, topic_id, started_at)
VALUES (123, 5, NOW());

   ↓ TRIGGER: trg_set_user_test_defaults
   → Copia configuración del tema (question_count, duration, etc.)
   
   ↓ TRIGGER: trg_update_topic_stats_insert
   → Incrementa topic.total_participants += 1


-- 2️⃣ Usuario responde pregunta 1
INSERT INTO user_test_answers (user_test_id, question_id, selected_option_id)
VALUES (100, 50, 201);

   ↓ TRIGGER: trg_calculate_answer_correctness
   → Compara con opción correcta
   → Marca correct = true/false
   
   ↓ TRIGGER: trg_update_user_test_stats
   → Actualiza contadores en user_tests:
     - correct_answers = 1
     - score = calculate_test_score(100)


-- 3️⃣ Usuario responde pregunta 2
INSERT INTO user_test_answers (user_test_id, question_id, selected_option_id)
VALUES (100, 51, 205);

   ↓ TRIGGER: trg_calculate_answer_correctness
   → correct = false (incorrecta)
   
   ↓ TRIGGER: trg_update_user_test_stats
   → Actualiza:
     - correct_answers = 1
     - incorrect_answers = 1
     - score = calculate_test_score(100)  ← Aplica penalización


-- 4️⃣ Usuario termina test
UPDATE user_tests 
SET completed = true, completed_at = NOW()
WHERE id = 100;

   ↓ TRIGGER: trg_update_user_stats_update
   → Actualiza estadísticas globales en users:
     - totalQuestions += 20
     - rightQuestions += 15
     - wrongQuestions += 5
```

---

## 📊 **TABLA RESUMEN**

| Tabla | Triggers | Propósito |
|-------|----------|-----------|
| `challenge` | 1 | Actualizar timestamp |
| `membership_levels` | 1 | Actualizar timestamp |
| `user_memberships` | 1 | Actualizar timestamp |
| `questions` | 4 | Crear opciones + actualizar contadores de temas |
| `topic` | 1 | Heredar configuración del topic_type |
| `user_test_answers` | 4 | Calcular correctness + actualizar stats del test |
| `user_tests` | 7 | Inicializar + actualizar stats de temas y usuarios |
| **TOTAL** | **20** | |

---

## 🎯 **BENEFICIOS DE LOS TRIGGERS**

### **✅ Ventajas:**

1. **Automatización total**
   - No necesitas calcular manualmente si una respuesta es correcta
   - Los contadores se actualizan solos

2. **Consistencia de datos**
   - Imposible que los contadores se desincronicen
   - Siempre están actualizados

3. **Mejor performance**
   - Leer `users.totalQuestions` es instantáneo
   - No necesitas hacer SUM() sobre millones de registros

4. **Menos código**
   - No tienes que hacer estos cálculos en Flutter
   - El backend los hace automáticamente

### **⚠️ Consideraciones:**

1. **Debugging más complejo**
   - Los triggers se ejecutan "en silencio"
   - Usa logs para ver qué está pasando

2. **Performance en bulk inserts**
   - Si insertas 1000 preguntas, se ejecutan 1000 triggers
   - Mejor desactivarlos temporalmente para migraciones

3. **Complejidad**
   - Hay que documentarlos bien (¡como este documento!)
   - Nuevos devs deben entenderlos

---

## 🔍 **CÓMO VER QUÉ HACE UN TRIGGER**

```sql
-- Ver el código de una función
SELECT pg_get_functiondef(oid) 
FROM pg_proc 
WHERE proname = 'calculate_answer_correctness';

-- Ver todos los triggers de una tabla
SELECT trigger_name, event_manipulation, action_statement
FROM information_schema.triggers
WHERE event_object_table = 'user_tests';

-- Desactivar un trigger temporalmente
ALTER TABLE user_tests DISABLE TRIGGER trg_update_user_stats_insert;

-- Reactivarlo
ALTER TABLE user_tests ENABLE TRIGGER trg_update_user_stats_insert;
```

---

## 📝 **EJEMPLOS DE USO DESDE LA APP**

### **Ejemplo 1: Usuario hace un test**

```dart
// En Flutter, solo necesitas insertar
final response = await supabase.from('user_tests').insert({
  'user_id': userId,
  'topic_id': topicId,
  'started_at': DateTime.now().toIso8601String(),
}).select().single();

// Los triggers automáticamente:
// ✅ Copian configuración del tema
// ✅ Incrementan total_participants
// ✅ Todo listo sin código extra
```

### **Ejemplo 2: Usuario responde pregunta**

```dart
// Solo inserta la respuesta
await supabase.from('user_test_answers').insert({
  'user_test_id': testId,
  'question_id': questionId,
  'selected_option_id': selectedOptionId,
});

// Los triggers automáticamente:
// ✅ Calculan si es correcta
// ✅ Actualizan score del test
// ✅ Actualizan estadísticas globales
// ¡Todo sin código adicional!
```

### **Ejemplo 3: Ver estadísticas del usuario**

```dart
// Solo lee de users
final stats = await supabase
  .from('users')
  .select('totalQuestions, rightQuestions, wrongQuestions')
  .eq('id', userId)
  .single();

// Los datos ya están actualizados gracias a los triggers ✅
print('Total: ${stats['totalQuestions']}');
print('Correctas: ${stats['rightQuestions']}');
print('Incorrectas: ${stats['wrongQuestions']}');
```

---

## ✅ **CONCLUSIÓN**

Tienes **20 triggers** bien organizados que automatizan:

- ✅ Timestamps de actualización
- ✅ Creación de opciones de preguntas
- ✅ Contadores de preguntas por tema
- ✅ Configuración automática de tests
- ✅ Cálculo de correctness de respuestas
- ✅ Estadísticas de tests, temas y usuarios
- ✅ Participación en temas

**Todo funciona automáticamente** sin necesidad de código extra en tu app Flutter 🎉

---

**¿Necesitas más detalles sobre algún trigger específico? 😊**

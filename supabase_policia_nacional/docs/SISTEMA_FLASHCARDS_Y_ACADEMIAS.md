# Sistema de Flashcards y Multi-Academia

## Tabla de Contenidos

1. [Sistema Multi-Academia](#sistema-multi-academia)
2. [Sistema de Flashcards](#sistema-de-flashcards)
3. [Integración entre Ambos Sistemas](#integración-entre-ambos-sistemas)

---

## Sistema Multi-Academia

### Descripción General

El sistema multi-academia permite que múltiples instituciones educativas (academias) operen de forma independiente dentro de la misma plataforma, manteniendo sus propios usuarios, contenidos y datos completamente aislados.

### Concepto

Cada **academia** es una entidad independiente que agrupa:
- Usuarios editores/tutores (cms_users)
- Usuarios finales/estudiantes (users)
- Contenido educativo (topics, questions)
- Desafíos/reportes (challenges)

**Academia por defecto**: **OPN** (ID: 1)

### Arquitectura

#### Tabla Principal: `academies`

```sql
CREATE TABLE academies (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,        -- Nombre de la academia
    slug VARCHAR(100) UNIQUE NOT NULL,        -- Identificador URL-friendly
    description TEXT,
    logo_url TEXT,                            -- Logo de la academia
    website TEXT,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    address TEXT,
    is_active BOOLEAN DEFAULT true,           -- Si está operativa
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Academia OPN (predeterminada)**:
```sql
INSERT INTO academies (id, name, slug, description, is_active)
VALUES (1, 'OPN', 'opn', 'Academia por defecto del sistema OPN Test Guardia Civil', true);
```

#### Tablas con `academy_id`

Todas estas tablas tienen una columna `academy_id BIGINT NOT NULL DEFAULT 1`:

| Tabla | Descripción | FK Constraint |
|-------|-------------|---------------|
| `cms_users` | Usuarios editores/tutores | `academy_id` → `academies(id)` RESTRICT |
| `users` | Usuarios finales/estudiantes | `academy_id` → `academies(id)` RESTRICT |
| `topic` | Temas de estudio | `academy_id` → `academies(id)` RESTRICT |
| `questions` | Preguntas | `academy_id` → `academies(id)` RESTRICT |
| `challenge` | Desafíos/reportes | `academy_id` → `academies(id)` RESTRICT |

#### Política de Borrado: RESTRICT

**⚠️ IMPORTANTE**: Todos los `ON DELETE` están configurados en **RESTRICT**, no en CASCADE.

**¿Qué significa?**
- No se puede eliminar una academia si tiene datos asociados
- No se puede eliminar un topic si tiene preguntas asociadas
- No se puede eliminar una pregunta si tiene respuestas/challenges

**Ventaja**: Evita borrados accidentales masivos de datos.

**Ejemplo**:
```sql
-- Esto fallará si existen usuarios en la academia
DELETE FROM academies WHERE id = 1;
-- ERROR: update or delete on table "academies" violates foreign key constraint
```

### Flujo de Datos

#### 1. Creación de Usuario en CMS

Cuando se crea un usuario en `auth.users`, el trigger `sync_auth_users_to_cms` automáticamente:

```sql
INSERT INTO cms_users (
    user_uuid,
    email,
    username,
    nombre,
    apellido,
    role_id,
    academy_id  -- Siempre se asigna 1 (OPN) por defecto
) VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.email, 'sin usuario'),
    'sin nombre',
    'sin apellido',
    4,  -- Role por defecto
    1   -- Academia OPN
);
```

**Desde la app**: El usuario puede cambiar de academia posteriormente.

#### 2. Creación de Contenido

**Topics**:
```sql
INSERT INTO topic (topic_type_id, topic_name, academy_id, enabled)
VALUES (1, 'Vocabulario Inglés', 1, true);
-- academy_id = 1 (OPN) por defecto
```

**Questions**:
```sql
INSERT INTO questions (topic, academy_id, question, published)
VALUES (topic_id, 1, 'What is...?', true);
-- academy_id hereda del topic o se especifica explícitamente
```

#### 3. Filtrado por Academia

**En la App (importante)**:

Todas las queries deben filtrar por `academy_id`:

```sql
-- Obtener topics de una academia
SELECT * FROM topic
WHERE academy_id = 1 AND enabled = true;

-- Obtener preguntas de una academia
SELECT q.*
FROM questions q
JOIN topic t ON q.topic = t.id
WHERE t.academy_id = 1 AND q.published = true;

-- Obtener usuarios de una academia
SELECT * FROM users WHERE academy_id = 1;
```

### Casos de Uso

#### Caso 1: Crear una Nueva Academia

```sql
-- 1. Crear la academia
INSERT INTO academies (name, slug, description, is_active)
VALUES ('Academia Madrid', 'academia-madrid', 'Centro de formación en Madrid', true)
RETURNING id;
-- Supongamos que retorna id = 2

-- 2. Crear usuario editor para esa academia
INSERT INTO cms_users (user_uuid, email, username, academy_id, role_id)
VALUES (uuid, 'admin@madrid.com', 'Admin Madrid', 2, 1);

-- 3. Crear contenido para esa academia
INSERT INTO topic (topic_type_id, topic_name, academy_id)
VALUES (1, 'Oposiciones Madrid', 2);
```

#### Caso 2: Migrar Usuarios a Otra Academia

```sql
-- Cambiar usuarios de academia (requiere permisos)
UPDATE users
SET academy_id = 2
WHERE id IN (1, 2, 3) AND academy_id = 1;

UPDATE cms_users
SET academy_id = 2
WHERE id IN (10, 20) AND academy_id = 1;
```

#### Caso 3: Estadísticas por Academia

```sql
-- Total de usuarios por academia
SELECT
    a.name,
    COUNT(u.id) as total_users
FROM academies a
LEFT JOIN users u ON u.academy_id = a.id
GROUP BY a.id, a.name;

-- Total de preguntas por academia
SELECT
    a.name,
    COUNT(q.id) as total_questions
FROM academies a
LEFT JOIN questions q ON q.academy_id = a.id
WHERE q.published = true
GROUP BY a.id, a.name;
```

### Índices para Rendimiento

```sql
-- Usuarios por academia
idx_users_academy_id ON users(academy_id)
idx_cms_users_academy_id ON cms_users(academy_id)

-- Contenido por academia
idx_topic_academy_id ON topic(academy_id)
idx_questions_academy_id ON questions(academy_id)

-- Índices compuestos
idx_topic_academy_enabled ON topic(academy_id, enabled) WHERE enabled = true
idx_questions_academy_published ON questions(academy_id, published) WHERE published = true
```

### Consideraciones para la App

1. **Login**: Identificar `academy_id` del usuario al autenticarse
2. **Filtrado Global**: Aplicar filtro `academy_id` en TODAS las queries
3. **UI**: Mostrar logo/nombre de la academia en la interfaz
4. **Permisos**: Solo admin global puede crear/editar academias
5. **Cambio de Academia**: Implementar endpoint seguro para migrar usuarios

---

## Sistema de Flashcards

### Descripción General

Sistema de tarjetas de estudio (flashcards) con **repetición espaciada** basado en el algoritmo **SM-2** (SuperMemo), similar a Anki. Permite a los usuarios estudiar mediante auto-evaluación y programa automáticamente la próxima revisión según su nivel de dominio.

### Concepto

Una **flashcard** es una pregunta con exactamente **2 opciones**:
- **Opción 1**: Pregunta/Frente (lo que se muestra primero)
- **Opción 2**: Respuesta/Reverso (lo que el usuario debe recordar)

**Características**:
- No hay respuesta "correcta" o "incorrecta" validada automáticamente
- El usuario auto-evalúa su nivel de dominio: Again, Hard, Medium, Easy
- El sistema calcula cuándo debe revisar esa flashcard nuevamente
- No afecta las estadísticas globales de right/wrong questions

### Arquitectura

#### 1. Enum `topic_level`

```sql
CREATE TYPE topic_level AS ENUM ('Mock', 'Study', 'Flashcard');
```

- **Mock**: Simulacros de examen
- **Study**: Estudio normal con preguntas de opción múltiple
- **Flashcard**: Tarjetas de estudio con spaced repetition

#### 2. Topic Type para Flashcards

```sql
INSERT INTO topic_type (
    topic_type_name,
    default_number_options,
    level,
    penalty
) VALUES (
    'Vocabulario - Flashcards',
    2,              -- Siempre 2 opciones
    'Flashcard',
    0.0             -- Sin penalización (no aplica)
);
```

**Validación automática**: Si `level = 'Flashcard'`, entonces `default_number_options = 2` (trigger lo fuerza).

#### 3. Estructura de Datos

##### Tabla `user_test_answers` - Campos Nuevos

```sql
ALTER TABLE user_test_answers ADD COLUMN
    difficulty_rating VARCHAR(10),           -- 'again', 'hard', 'medium', 'easy'
    next_review_date TIMESTAMPTZ,            -- Cuándo revisar nuevamente
    review_interval_days INTEGER DEFAULT 1,  -- Intervalo en días
    ease_factor DECIMAL(4,2) DEFAULT 2.50,   -- Factor de facilidad (1.30-2.50)
    repetitions INTEGER DEFAULT 0;           -- Veces recordada correctamente
```

##### Tabla `user_tests` - Campo Nuevo

```sql
ALTER TABLE user_tests ADD COLUMN
    is_flashcard_mode BOOLEAN DEFAULT false; -- Identifica sesión de flashcards
```

### Algoritmo SM-2 (SuperMemo)

#### ¿Cómo funciona?

El algoritmo SM-2 ajusta el intervalo de revisión según la dificultad reportada por el usuario.

**Variables**:
- `interval`: Días hasta la próxima revisión
- `ease_factor`: Factor de facilidad (qué tan fácil es recordar)
- `repetitions`: Contador de veces recordada correctamente

#### Ratings y Comportamiento

| Rating | Significado | Intervalo | Ease Factor | Repetitions |
|--------|-------------|-----------|-------------|-------------|
| **again** | No la sabía | 1 día | -0.20 (mín 1.30) | Reset a 0 |
| **hard** | Difícil de recordar | intervalo × 1.2 | -0.15 (mín 1.30) | +1 |
| **medium** | Normal | 1 → 6 → ease × intervalo | Sin cambio | +1 |
| **easy** | Muy fácil | 4 → ease × 1.3 × intervalo | +0.15 (máx 2.50) | +1 |

#### Implementación

```sql
CREATE FUNCTION calculate_next_review_flashcard(
    p_difficulty_rating VARCHAR(10),
    p_current_ease_factor DECIMAL(4,2),
    p_current_interval_days INTEGER,
    p_current_repetitions INTEGER
)
RETURNS TABLE(
    next_review_date TIMESTAMPTZ,
    new_interval_days INTEGER,
    new_ease_factor DECIMAL(4,2),
    new_repetitions INTEGER
) AS $$
DECLARE
    v_ease_factor DECIMAL(4,2);
    v_interval INTEGER;
    v_repetitions INTEGER;
BEGIN
    v_ease_factor := p_current_ease_factor;
    v_interval := p_current_interval_days;
    v_repetitions := p_current_repetitions;

    CASE p_difficulty_rating
        WHEN 'again' THEN
            v_interval := 1;
            v_repetitions := 0;
            v_ease_factor := GREATEST(1.30, v_ease_factor - 0.20);

        WHEN 'hard' THEN
            v_interval := GREATEST(1, FLOOR(v_interval * 1.2));
            v_repetitions := v_repetitions + 1;
            v_ease_factor := GREATEST(1.30, v_ease_factor - 0.15);

        WHEN 'medium' THEN
            IF v_repetitions = 0 THEN
                v_interval := 1;
            ELSIF v_repetitions = 1 THEN
                v_interval := 6;
            ELSE
                v_interval := FLOOR(v_interval * v_ease_factor);
            END IF;
            v_repetitions := v_repetitions + 1;

        WHEN 'easy' THEN
            IF v_repetitions = 0 THEN
                v_interval := 4;
            ELSE
                v_interval := FLOOR(v_interval * v_ease_factor * 1.3);
            END IF;
            v_repetitions := v_repetitions + 1;
            v_ease_factor := LEAST(2.50, v_ease_factor + 0.15);
    END CASE;

    RETURN QUERY SELECT
        (NOW() + (v_interval || ' days')::INTERVAL)::TIMESTAMPTZ,
        v_interval,
        v_ease_factor,
        v_repetitions;
END;
$$ LANGUAGE plpgsql;
```

#### Ejemplo Práctico

**Primera vez** (nueva flashcard):
```
Rating: 'medium'
→ interval = 1 día, ease_factor = 2.50, repetitions = 1
→ next_review_date = HOY + 1 día
```

**Segunda revisión** (recordada medium):
```
Rating: 'medium'
→ interval = 6 días, ease_factor = 2.50, repetitions = 2
→ next_review_date = HOY + 6 días
```

**Tercera revisión** (recordada medium):
```
Rating: 'medium'
→ interval = 6 × 2.50 = 15 días, ease_factor = 2.50, repetitions = 3
→ next_review_date = HOY + 15 días
```

**Si fallas** (rating: 'again'):
```
Rating: 'again'
→ interval = 1 día, ease_factor = 2.30, repetitions = 0
→ next_review_date = HOY + 1 día
→ Reinicia el ciclo
```

### Creación de Flashcards

#### 1. Crear Topic de Flashcards

```sql
INSERT INTO topic (
    topic_type_id,
    topic_name,
    academy_id,
    enabled
) VALUES (
    (SELECT id FROM topic_type WHERE level = 'Flashcard'),
    'Vocabulario Inglés',
    1,  -- Academia OPN
    true
);
-- Automáticamente tendrá options = 2
```

#### 2. Crear Question (Flashcard)

```sql
INSERT INTO questions (
    topic,
    academy_id,
    question,
    published
) VALUES (
    topic_id,
    1,
    'Hello',  -- Pregunta/Frente
    true
);
```

**Trigger automático** `create_blank_question_options()` crea 2 opciones:
```sql
-- Opción 1 (order=1)
answer = 'Pregunta/Frente'
is_correct = false

-- Opción 2 (order=2)
answer = 'Respuesta/Reverso'
is_correct = false
```

**Editar las opciones**:
```sql
-- Opción 1: Pregunta
UPDATE question_options
SET answer = 'Hello'
WHERE question_id = X AND option_order = 1;

-- Opción 2: Respuesta
UPDATE question_options
SET answer = 'Hola'
WHERE question_id = X AND option_order = 2;
```

### Flujo de Estudio

#### 1. Iniciar Sesión de Flashcards

```sql
INSERT INTO user_tests (
    user_id,
    topic_ids,
    question_count,
    minutes,
    is_flashcard_mode,    -- TRUE para flashcards
    special_topic
) VALUES (
    999,
    ARRAY[topic_id],
    10,  -- 10 flashcards
    15,  -- 15 minutos
    true,
    topic_id
);
```

#### 2. Usuario Estudia una Flashcard

**Frontend Flow**:
1. Mostrar pregunta (opción 1): "Hello"
2. Usuario intenta recordar
3. Usuario voltea la tarjeta
4. Mostrar respuesta (opción 2): "Hola"
5. Usuario califica dificultad: Again, Hard, Medium, Easy

#### 3. Registrar Respuesta

```sql
INSERT INTO user_test_answers (
    user_test_id,
    question_id,
    selected_option_id,    -- Opción 2 (respuesta)
    difficulty_rating,     -- 'medium'
    question_order
) VALUES (
    test_id,
    question_id,
    option2_id,
    'medium',
    1
);
```

**Trigger automático** `update_flashcard_review_schedule()` ejecuta:
1. Llama a `calculate_next_review_flashcard('medium', 2.50, 1, 0)`
2. Obtiene: `next_review_date`, `new_interval`, `new_ease_factor`, `new_repetitions`
3. Actualiza automáticamente esos campos en `user_test_answers`

**Resultado**:
```sql
-- Campos actualizados automáticamente por el trigger:
difficulty_rating = 'medium'
next_review_date = '2025-10-19 15:00:00'  -- Mañana
review_interval_days = 1
ease_factor = 2.50
repetitions = 1
correct = NULL  -- No aplica para flashcards
```

#### 4. Obtener Flashcards Pendientes

```sql
SELECT
    q.id,
    q.question,
    qo1.answer as front,
    qo2.answer as back,
    uta.next_review_date,
    uta.review_interval_days,
    uta.ease_factor,
    uta.repetitions
FROM user_test_answers uta
JOIN questions q ON uta.question_id = q.id
JOIN question_options qo1 ON qo1.question_id = q.id AND qo1.option_order = 1
JOIN question_options qo2 ON qo2.question_id = q.id AND qo2.option_order = 2
WHERE uta.next_review_date <= NOW()  -- Vencidas
  AND q.academy_id = 1
ORDER BY uta.next_review_date ASC
LIMIT 20;
```

### Estadísticas de Flashcards

#### ¿Qué NO se actualiza?

```sql
-- Para tests con is_flashcard_mode = true:
right_questions = 0     -- No se cuenta
wrong_questions = 0     -- No se cuenta
score = NULL            -- No se calcula
```

#### ¿Qué SÍ se actualiza?

```sql
total_answered = COUNT(*)  -- Total de flashcards revisadas
```

**Función modificada** `update_user_test_stats()`:
```sql
IF is_flashcard THEN
    UPDATE user_tests
    SET total_answered = COUNT(*)
    WHERE id = test_id;
    -- NO actualiza right_questions, wrong_questions, score
END IF;
```

#### Estadísticas Útiles

```sql
-- Total de flashcards por nivel de dificultad
SELECT
    difficulty_rating,
    COUNT(*) as total
FROM user_test_answers
WHERE user_test_id IN (
    SELECT id FROM user_tests WHERE is_flashcard_mode = true
)
GROUP BY difficulty_rating;

-- Flashcards con mayor dificultad (ease_factor más bajo)
SELECT
    q.question,
    qo.answer as respuesta,
    uta.ease_factor,
    uta.repetitions
FROM user_test_answers uta
JOIN questions q ON uta.question_id = q.id
JOIN question_options qo ON qo.question_id = q.id AND qo.option_order = 2
WHERE uta.ease_factor < 2.0
ORDER BY uta.ease_factor ASC;

-- Flashcards dominadas (ease_factor alto, muchas repeticiones)
SELECT
    q.question,
    uta.ease_factor,
    uta.repetitions,
    uta.next_review_date
FROM user_test_answers uta
JOIN questions q ON uta.question_id = q.id
WHERE uta.repetitions >= 5 AND uta.ease_factor >= 2.3
ORDER BY uta.repetitions DESC;
```

### Validaciones Implementadas

#### 1. Validación de 2 Opciones

**Trigger** `validate_flashcard_options()`:
- ✅ Impide agregar más de 2 opciones a una flashcard
- ✅ Ejecuta en INSERT/UPDATE de `question_options`

```sql
-- Esto fallará:
INSERT INTO question_options (question_id, answer, option_order)
VALUES (flashcard_question_id, 'Tercera opción', 3);
-- ERROR: Las flashcards solo pueden tener exactamente 2 opciones
```

#### 2. Validación de Topic Type

**Trigger** `validate_flashcard_topic_type()`:
- ✅ Si `level = 'Flashcard'` → fuerza `default_number_options = 2`
- ✅ Ejecuta en INSERT/UPDATE de `topic_type`

```sql
-- Esto se auto-corrige:
INSERT INTO topic_type (topic_type_name, level, default_number_options)
VALUES ('Test', 'Flashcard', 4);
-- Se ajusta automáticamente a 2
```

#### 3. No hay "respuesta correcta"

**Función modificada** `calculate_answer_correctness()`:
```sql
IF is_flashcard_mode THEN
    NEW.correct := NULL;  -- No aplica concepto de correcta/incorrecta
    RETURN NEW;
END IF;
```

### Índices para Performance

```sql
-- Buscar flashcards pendientes de revisión
CREATE INDEX idx_user_test_answers_next_review
ON user_test_answers(user_test_id, next_review_date)
WHERE next_review_date IS NOT NULL;

-- Filtrar por dificultad
CREATE INDEX idx_user_test_answers_difficulty
ON user_test_answers(difficulty_rating)
WHERE difficulty_rating IS NOT NULL;

-- Buscar flashcards vencidas
CREATE INDEX idx_user_test_answers_flashcard_review
ON user_test_answers(next_review_date, question_id)
WHERE next_review_date IS NOT NULL AND next_review_date <= NOW();

-- Filtrar tests de flashcards
CREATE INDEX idx_user_tests_flashcard_mode
ON user_tests(is_flashcard_mode, user_id)
WHERE is_flashcard_mode = true;
```

---

## Integración entre Ambos Sistemas

### Flashcards por Academia

Cada academia tiene sus propias flashcards:

```sql
-- Crear flashcards para Academia OPN
INSERT INTO topic (topic_type_id, topic_name, academy_id)
VALUES (
    (SELECT id FROM topic_type WHERE level = 'Flashcard'),
    'Vocabulario OPN',
    1  -- Academia OPN
);

-- Crear flashcards para Academia Madrid
INSERT INTO topic (topic_type_id, topic_name, academy_id)
VALUES (
    (SELECT id FROM topic_type WHERE level = 'Flashcard'),
    'Vocabulario Madrid',
    2  -- Academia Madrid
);
```

### Query Completo: Flashcards por Usuario y Academia

```sql
SELECT
    a.name as academia,
    t.topic_name,
    q.question as pregunta,
    qo1.answer as frente,
    qo2.answer as reverso,
    uta.difficulty_rating,
    uta.next_review_date,
    uta.ease_factor,
    uta.repetitions
FROM user_test_answers uta
JOIN user_tests ut ON uta.user_test_id = ut.id
JOIN users u ON ut.user_id = u.id
JOIN questions q ON uta.question_id = q.id
JOIN topic t ON q.topic = t.id
JOIN topic_type tt ON t.topic_type_id = tt.id
JOIN academies a ON t.academy_id = a.id
JOIN question_options qo1 ON qo1.question_id = q.id AND qo1.option_order = 1
JOIN question_options qo2 ON qo2.question_id = q.id AND qo2.option_order = 2
WHERE ut.is_flashcard_mode = true
  AND u.academy_id = 1  -- Filtro por academia
  AND tt.level = 'Flashcard'
  AND uta.next_review_date <= NOW()
ORDER BY uta.next_review_date ASC;
```

### Consideraciones para la App

#### Backend/API

1. **Autenticación**: Obtener `academy_id` del usuario logueado
2. **Middleware**: Aplicar filtro `academy_id` automáticamente en todas las queries
3. **Endpoints de Flashcards**:
   - `GET /flashcards/pending` → Flashcards vencidas
   - `GET /flashcards/topic/:topicId` → Flashcards de un topic
   - `POST /flashcards/answer` → Registrar respuesta con rating
   - `GET /flashcards/stats` → Estadísticas de estudio

#### Frontend (Flutter)

**UI de Flashcard**:
```dart
// 1. Mostrar pregunta (frente)
Card(
  child: Text(flashcard.front), // "Hello"
);

// 2. Botón "Voltear"
ElevatedButton(
  onPressed: () => setState(() => showAnswer = true),
  child: Text('Ver Respuesta'),
);

// 3. Mostrar respuesta (reverso)
if (showAnswer)
  Card(
    child: Text(flashcard.back), // "Hola"
  );

// 4. Botones de auto-evaluación
Row(
  children: [
    ElevatedButton(
      style: ButtonStyle(backgroundColor: Colors.red),
      onPressed: () => submitRating('again'),
      child: Text('Again\n<1d'),
    ),
    ElevatedButton(
      style: ButtonStyle(backgroundColor: Colors.orange),
      onPressed: () => submitRating('hard'),
      child: Text('Hard\n<6d'),
    ),
    ElevatedButton(
      style: ButtonStyle(backgroundColor: Colors.green),
      onPressed: () => submitRating('medium'),
      child: Text('Medium\n6d'),
    ),
    ElevatedButton(
      style: ButtonStyle(backgroundColor: Colors.blue),
      onPressed: () => submitRating('easy'),
      child: Text('Easy\n15d'),
    ),
  ],
);
```

**Función submitRating**:
```dart
Future<void> submitRating(String rating) async {
  await supabase.from('user_test_answers').insert({
    'user_test_id': currentTestId,
    'question_id': flashcard.id,
    'selected_option_id': flashcard.backOptionId,
    'difficulty_rating': rating,
    'question_order': currentOrder,
  });
  // El trigger calculará automáticamente next_review_date

  loadNextFlashcard();
}
```

### Mejores Prácticas

#### Para Academias

1. **Siempre filtrar por academy_id** en todas las queries
2. **Validar permisos**: Usuario solo accede a su academia
3. **Migración entre academias**: Requiere rol admin
4. **Auditoría**: Registrar cambios de academia en log

#### Para Flashcards

1. **Límite de estudio**: Max 20-30 flashcards por sesión
2. **Orden de estudio**: Priorizar `next_review_date` más antiguas
3. **Mezclar**: Combinar nuevas y vencidas en cada sesión
4. **Estadísticas**: Mostrar progreso (% dominadas, ease_factor promedio)
5. **Backup**: Exportar flashcards antes de ediciones masivas

### Troubleshooting

#### Problema: No se calculan las fechas de revisión

**Verificar**:
```sql
-- ¿El test está en modo flashcard?
SELECT is_flashcard_mode FROM user_tests WHERE id = X;

-- ¿Existe el trigger?
SELECT tgname FROM pg_trigger WHERE tgname = 'trg_update_flashcard_schedule';

-- ¿Existe la función?
SELECT proname FROM pg_proc WHERE proname = 'calculate_next_review_flashcard';
```

#### Problema: No se pueden crear más de 2 opciones

**Esto es correcto**: Las flashcards están limitadas a 2 opciones por diseño.

**Solución**: Si necesitas más opciones, usa un topic con `level = 'Study'` o `'Mock'`.

#### Problema: Las estadísticas no se actualizan

**Verificar**:
```sql
-- ¿Es modo flashcard?
SELECT is_flashcard_mode FROM user_tests WHERE id = X;
-- Si es true, right_questions y wrong_questions no se actualizan (diseño correcto)

-- Solo se actualiza total_answered
SELECT total_answered FROM user_tests WHERE id = X;
```

---

## Resumen

### Sistema Multi-Academia
- ✅ Aislamiento total de datos entre academias
- ✅ Academia OPN por defecto (ID: 1)
- ✅ Política RESTRICT para evitar borrados accidentales
- ✅ Filtrado obligatorio por `academy_id`
- ✅ Trigger automático asigna OPN en nuevos usuarios

### Sistema de Flashcards
- ✅ Algoritmo SM-2 (SuperMemo) para spaced repetition
- ✅ Exactamente 2 opciones: Pregunta/Respuesta
- ✅ 4 niveles de dificultad: Again, Hard, Medium, Easy
- ✅ Cálculo automático de próxima revisión
- ✅ Factor de facilidad adaptativo (1.30-2.50)
- ✅ No afecta estadísticas globales (right/wrong)
- ✅ Compatible con sistema multi-academia

### Integración
- ✅ Cada academia tiene sus propias flashcards
- ✅ Filtrado combinado: `academy_id` + `is_flashcard_mode`
- ✅ Índices optimizados para ambos sistemas
- ✅ Triggers coordinados para automatización completa

---

**Documentación generada**: 2025-10-18
**Versión de BD**: Migraciones 20251018140114 (academias) + 20251018151802 (flashcards)
**Sistema**: OPN Test Guardia Civil

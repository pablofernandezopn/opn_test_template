# 🚀 Migración de Datos: Policía Nacional → Guardia Civil

Migración ETL (Extract, Transform, Load) de la base de datos de Policía Nacional a la nueva estructura de Guardia Civil.

## 📋 Tabla de Contenidos
- [Requisitos Previos](#-requisitos-previos)
- [Instalación](#-instalación)
- [Estructura de Base de Datos](#-estructura-de-base-de-datos)
- [Migraciones Realizadas](#-migraciones-realizadas)
- [Scripts Disponibles](#-scripts-disponibles)
- [Ejecución](#-ejecución)
- [Troubleshooting](#-troubleshooting)

---

## 📋 Requisitos Previos

- Python 3.8+
- PostgreSQL local (puerto 54322) con BD antigua de Policía Nacional
- Credenciales de Supabase para base de datos remota (si aplica)

## 🔧 Instalación

1. **Crear entorno virtual:**
```bash
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
```

2. **Instalar dependencias:**
```bash
pip install -r requirements.txt
```

3. **Configurar credenciales:**
```bash
cp .env.example .env
# Editar .env con las credenciales
```

### Archivo `.env`
```env
# BD Antigua (Policía Nacional - REMOTA)
OLD_DB_URL=https://xxxxx.supabase.co
OLD_DB_KEY=tu_service_key_antigua

# BD Nueva (Guardia Civil - LOCAL O REMOTA)
NEW_DB_URL=https://xxxxx.supabase.co
NEW_DB_KEY=tu_service_key_nueva

# Opciones
FORCE_DOWNLOAD=False  # True para forzar descarga aunque datos existan
```

---

## 🗄️ Estructura de Base de Datos

### Base de Datos ANTIGUA (Policía Nacional)

```
topics (tabla antigua)
├── id
├── name
├── number (1-45 = Temario, >45 = Test/Mock)
├── isMock, isPsychoTechnical, isOfficial, isSpecial
├── category
├── specialty
└── questions → Lista de IDs JSON "[1,2,3]"

questions (tabla antigua)
├── id
├── question (texto de pregunta)
├── topic (FK a topics.id)
├── answer1, answer2, answer3, answer4
├── answerCorrect (1-4, cuál es correcta)
└── tip, article, images, audio, etc.
```

### Base de Datos NUEVA (Guardia Civil)

```
topic_type (NUEVA TABLA)
├── id (SERIAL)
├── topic_type_name (ej: 'Bloque de Temario', 'Simulacros', 'Flashcards')
├── description
├── level (ENUM: 'Study', 'Mock', 'Flashcard')
├── default_number_options (2, 3 o 4)
├── penalty (0, 0.5)
├── time_by_question (0.5, 1)
└── order_of_appearance

topic (tabla nueva)
├── id (SERIAL)
├── topic_type_id (FK a topic_type.id)
├── topic_name
├── category_id (FK a categories.id)
├── specialty_id (FK a specialty.id)
├── options (número de opciones: 2, 3 o 4)
├── enabled, is_premium, published_at
└── total_questions, total_participants, etc.

questions (tabla nueva)
├── id (BIGINT, mismo que BD antigua)
├── question (texto)
├── topic (FK a topic.id) → Dónde está la pregunta
├── source_topic_id (FK a topic.id) → Tema de estudio para clasificación
├── tip, article
├── question_image_url, retro_image_url
├── retro_audio_enable, retro_audio_text, retro_audio_url
├── order, published, shuffled
└── num_answered, num_fails, num_empty

question_options (NUEVA TABLA)
├── id (SERIAL)
├── question_id (FK a questions.id)
├── option_order (1, 2, 3 o 4)
├── answer (texto de la opción)
└── is_correct (boolean)
```

### 🔥 Triggers Importantes

#### `create_blank_question_options`
**Dispara en:** `INSERT ON questions`

**Qué hace:**
1. Lee el campo `topic.options` del topic asociado
2. Crea automáticamente N opciones vacías en `question_options`
3. Ejemplo: Si `topic.options = 3`, crea 3 filas con `option_order = 1, 2, 3`

**Implicaciones:**
- ✅ No necesitas insertar opciones manualmente al crear una pregunta
- ⚠️ Debes actualizar las opciones después con contenido real
- 💡 Usado en la migración de questions y flashcards

#### `update_topic_questions_count`
**Dispara en:** `INSERT/UPDATE/DELETE ON questions`

**Qué hace:**
- Actualiza automáticamente `topic.total_questions`
- Mantiene el contador sincronizado

---

## ✅ Migraciones Realizadas

### 1. Topic Types (6 tipos creados)

| ID | Nombre | Level | Opciones | Penalty | Time/Q |
|----|--------|-------|----------|---------|--------|
| 1 | Bloque de Temario | Study | 3 | 0.5 | 0.5 |
| 2 | Simulacros | Mock | 3 | 0.5 | 0.5 |
| 3 | Psicotécnicos | Mock | 4 | 0.5 | 0.5 |
| 4 | Exámenes Oficiales | Mock | 3 | 0.5 | 0.5 |
| 5 | Test Especiales | Mock | 3 | 0.5 | 0.5 |
| 6 | Flashcards | Flashcard | 2 | 0 | 1 |

**Script:** `config.py` (TOPIC_TYPES), cargado por `load_all_fast.py`

### 2. Categories

- ✅ **14 categorías** migradas
- Mapeo directo: `old.id` → `new.id`
- Sin cambios en estructura

**Scripts:**
- Extracción: Incluida en scripts de extracción general
- Transformación: `transform/transform_data.py` (si existe) o directo
- Carga: `load_all_fast.py`

### 3. Topics

- ✅ **237 topics** migrados
- Clasificados automáticamente en topic_types según:
  - `number <= 45` → Bloque de Temario
  - `isMock=true` → Simulacros
  - `isPsychoTechnical=true` → Psicotécnicos
  - `isOfficial=true` → Exámenes Oficiales
  - `isSpecial=true` → Test Especiales

**Script:** `load_all_fast.py`

**Campos importantes:**
- `options`: Determina cuántas opciones tendrá cada pregunta (3 o 4)
- `topic_type_id`: FK al topic_type correspondiente

### 4. Questions + Question Options

- ✅ **17,462 questions** migradas (de 20,862 totales)
- ❌ **3,400 questions con topic=null** (inglés) no migradas
- ✅ **67,974 opciones** creadas (mix de 3 y 4 opciones)

**Proceso:**
1. Trigger crea opciones vacías al insertar question
2. Script actualiza opciones con `answer1-4` y `is_correct`
3. Si `answer4` es null/vacío, se usan solo 3 opciones

**Scripts:**
- Carga: `load_questions_only.py` o `load_all_fast.py`

**Detalles:**
- IDs preservados de BD antigua
- Campo `questions` (lista JSON) de topics se ignora
- Se usa relación FK `questions.topic → topic.id`

### 5. Flashcards

- ✅ **52 flash_cards_stack** → **52 topics** (topic_type_id=6)
- ✅ **1,305 flashcards** → **1,305 questions** + **2,610 opciones**

**Estructura de flashcard:**
- Cada flashcard = 1 question con **exactamente 2 opciones**
- Opción 1: `flash_card_question` (front/pregunta)
- Opción 2: `flash_card_answer` (back/respuesta)
- Ambas opciones: `is_correct = false` (no hay respuesta correcta)
- `shuffled = false` (no se mezclan las caras)

**IDs asignados:**
- Questions: 30,000,000 - 30,001,305 (offset para evitar conflictos)
- Topics: Auto-generados por BD

**Mapeo:**
- `flashcard_stack_mapping.json`: Mapea `old_stack_id → new_topic_id`

**Scripts:**
- Extracción: `extract_flashcards.py`
- Transformación: `transform_flashcards.py`
- Carga: `load_flashcards.py`

**Validaciones realizadas:**
- ✅ Todas las 1,305 questions tienen exactamente 2 opciones
- ✅ Todas tienen `shuffled=false`
- ✅ Todas las opciones tienen `is_correct=false`

---

## 📜 Scripts Disponibles

### Extracción

| Script | Descripción |
|--------|-------------|
| `extract/extract_data.py` | Extrae datos generales (categories, topics, questions, users) |
| `extract_flashcards.py` | Extrae flash_cards_stack y flashcards |
| `check_flashcards.py` | Verifica existencia de tablas de flashcards en BD antigua |

### Transformación

| Script | Descripción |
|--------|-------------|
| `transform/transform_data.py` | Transforma datos generales a nueva estructura |
| `transform_flashcards.py` | Transforma flashcards a questions con 2 opciones |

### Carga

| Script | Descripción |
|--------|-------------|
| `load_all_fast.py` | Carga todo: topic_types, categories, topics |
| `load_questions_only.py` | Carga solo questions + opciones |
| `load_flashcards.py` | Carga flashcards (topic_type, topics, questions) |

### Validación

| Script | Descripción |
|--------|-------------|
| `validate/validate.py` | Valida migración general |

### Otros

| Script | Descripción |
|--------|-------------|
| `config.py` | Configuración central (rutas, topic_types, constantes) |
| `main.py` | ETL completo (legacy, no usado actualmente) |
| `migrate.sh` | Script bash para ejecutar pipeline completo |

---

## 🏃 Ejecución

### Opción 1: Migración Completa Automatizada
```bash
./migrate.sh
```

Este script ejecuta:
1. Extracción de datos (si `FORCE_DOWNLOAD=true` o no existen)
2. Transformación
3. Carga a BD nueva
4. Validación

### Opción 2: Ejecución Manual por Fases

#### Fase 1: Extracción
```bash
# Datos generales
python extract/extract_data.py

# Flashcards
python extract_flashcards.py
```

#### Fase 2: Transformación
```bash
# Datos generales
python transform/transform_data.py

# Flashcards
python transform_flashcards.py
```

#### Fase 3: Carga
```bash
# Topic types, categories, topics
python load_all_fast.py

# Questions + opciones
python load_questions_only.py

# Flashcards
python load_flashcards.py
```

#### Fase 4: Validación
```bash
python validate/validate.py
```

### Opción 3: Usar Datos Cacheados (MÁS RÁPIDO)

Para evitar re-extraer datos de BD remota:
```bash
export FORCE_DOWNLOAD=false
./migrate.sh
```

O editar `.env`:
```env
FORCE_DOWNLOAD=False
```

---

## 📁 Estructura de Archivos

```
migration_policia_nacional/
├── README.md                         # Este archivo
├── config.py                         # Configuración central
├── requirements.txt                  # Dependencias
├── .env                              # Credenciales (NO commitear)
├── .env.example                      # Ejemplo de credenciales
├── migrate.sh                        # Script bash de migración completa
│
├── extract/
│   └── extract_data.py              # Extrae datos generales
├── extract_flashcards.py            # Extrae flashcards
├── check_flashcards.py              # Verifica tablas flashcards
│
├── transform/
│   └── transform_data.py            # Transforma datos generales
├── transform_flashcards.py          # Transforma flashcards
│
├── load/
│   └── load_data.py                 # Carga datos generales
├── load_all_fast.py                 # Carga topic_types, categories, topics
├── load_questions_only.py           # Carga questions + opciones
├── load_flashcards.py               # Carga flashcards
│
├── validate/
│   └── validate.py                  # Valida migración
│
├── data/                            # Datos extraídos (JSON)
│   ├── categories.json
│   ├── topics.json
│   ├── questions.json
│   ├── users.json
│   ├── flash_cards_stack.json
│   ├── flashcards.json
│   └── transformed/                 # Datos transformados
│       ├── topic_types.json
│       ├── categories.json
│       ├── topics.json
│       ├── questions.json
│       ├── question_options.json
│       ├── flashcard_topics.json
│       ├── flashcard_questions.json
│       ├── flashcard_options.json
│       └── flashcard_stack_mapping.json
│
└── logs/                            # Logs de migración
    └── migration.log
```

---

## 🗺️ Mapeo Detallado de Datos

### Topic Types (Clasificación Automática)

```
BD ANTIGUA                          →  BD NUEVA
──────────────────────────────────────────────────────────────
topics WHERE number <= 45           →  topic_type_id = 1 (Bloque de Temario)
topics WHERE isMock = true          →  topic_type_id = 2 (Simulacros)
topics WHERE isPsychoTechnical      →  topic_type_id = 3 (Psicotécnicos)
topics WHERE isOfficial = true      →  topic_type_id = 4 (Exámenes Oficiales)
topics WHERE isSpecial = true       →  topic_type_id = 5 (Test Especiales)
flash_cards_stack                   →  topic_type_id = 6 (Flashcards)
```

### Topics

```
BD ANTIGUA                          →  BD NUEVA
──────────────────────────────────────────────────────────────
topics.id                           →  topic.id (preservado)
topics.name                         →  topic.topic_name
topics.category                     →  topic.category_id
topics.specialty                    →  topic.specialty_id
topics.number                       →  (usado para clasificar topic_type_id)
topics.isMock, etc.                 →  (usado para clasificar topic_type_id)
topics.questions (JSON list)        →  (ignorado, se usa FK questions.topic)
```

### Questions + Options

```
BD ANTIGUA                          →  BD NUEVA
──────────────────────────────────────────────────────────────
questions.id                        →  questions.id (preservado)
questions.question                  →  questions.question
questions.topic                     →  questions.topic (FK)
questions.tip                       →  questions.tip
questions.article                   →  questions.article
questions.answer1                   →  question_options WHERE option_order=1
questions.answer2                   →  question_options WHERE option_order=2
questions.answer3                   →  question_options WHERE option_order=3
questions.answer4                   →  question_options WHERE option_order=4
questions.answerCorrect (1-4)       →  question_options.is_correct = true
```

### Flashcards

```
BD ANTIGUA                          →  BD NUEVA
──────────────────────────────────────────────────────────────
flash_cards_stack.id                →  (NO usado, BD genera nuevo)
flash_cards_stack.name              →  topic.topic_name
flash_cards_stack.num_cards         →  topic.total_questions

flashcard.id                        →  questions.id + 30000000 (offset)
flashcard.flash_card_question       →  questions.question
                                    →  question_options[0].answer (cara 1)
flashcard.flash_card_answer         →  question_options[1].answer (cara 2)
flashcard.flash_card_stack          →  questions.topic (FK a nuevo topic_id)
```

---

## ⚠️ Consideraciones Importantes

### IDs
- **Topics, Categories, Questions regulares:** IDs preservados de BD antigua
- **Flashcards questions:** IDs con offset +30,000,000
- **Flashcards topics:** IDs auto-generados (mapeo en `flashcard_stack_mapping.json`)
- **Topic Types, Question Options:** IDs auto-generados

### Academy & Specialty
- **academy_id:** Todos los datos van a `academy_id = 1` (Policía Nacional)
- **specialty_id:** Generalmente `NULL` (configurable en `config.py`)

### Opciones de Preguntas
- **Trigger automático:** Al insertar question, se crean opciones vacías
- **Número de opciones:** Determinado por `topic.options` (2, 3 o 4)
- **Actualización:** Script actualiza opciones vacías con contenido real

### Clasificación Temática (source_topic_id)
- **Campo `source_topic_id`:** Permite clasificar preguntas por tema de estudio (1-45)
- **Preguntas Study:** `source_topic_id = topic` (mismo valor)
- **Preguntas Mock:** `source_topic_id` apunta al tema de estudio correspondiente (para estadísticas)
- **Preguntas Flashcard:** `source_topic_id = NULL` (sin clasificación temática)
- **Uso:** Estadísticas granulares por tema en simulacros y tests

**Ejemplo de uso futuro:**
```sql
-- Crear pregunta en Mock clasificada como "Constitución Española (I)" (tema 2)
INSERT INTO questions (question, topic, source_topic_id, ...)
VALUES (
  '¿Cuántos artículos tiene la Constitución?',
  150,  -- Topic Mock "Simulacro Oficial 2023"
  2,    -- Topic Study "Constitución Española (I)"
  ...
);
```

**Queries útiles:**
```sql
-- Estadísticas por tema en todos los mocks
SELECT
  st.topic_name,
  COUNT(*) as total,
  AVG(uta.is_correct::int) * 100 as porcentaje_acierto
FROM user_test_answers uta
JOIN questions q ON uta.question_id = q.id
JOIN topic st ON q.source_topic_id = st.id
WHERE uta.user_id = ?
GROUP BY st.id, st.topic_name;
```

### Flashcards
- **Siempre 2 opciones:** No hay respuesta correcta (`is_correct=false` en ambas)
- **No se mezclan:** `shuffled=false`
- **Penalty 0:** Sin penalización en flashcards
- **Time = 1:** 1 segundo por pregunta

### Datos No Migrados
- ❌ **3,400 questions con topic=null** (preguntas de inglés sin topic asignado)
- ℹ️ Estas preguntas existen en BD antigua pero no tienen topic válido

---

## 🐛 Troubleshooting

### Error: "Connection refused" (BD Local)
```bash
# Verificar que Supabase local esté corriendo
supabase status

# Si no está corriendo
supabase start
```

### Error: "Invalid API key" (BD Remota)
- Verificar que `OLD_DB_KEY` y `NEW_DB_KEY` en `.env` sean correctos
- Usar **service_role_key**, no anon key

### Error: "duplicate key value violates unique constraint"
```sql
-- Resetear secuencias (ejemplo para topic_type)
SELECT setval('topic_type_id_seq', (SELECT MAX(id) FROM topic_type));

-- Para topic
SELECT setval('topic_id_seq', (SELECT MAX(id) FROM topic));
```

### Error: "column does not exist"
- Verificar nombre exacto de columnas con `\d nombre_tabla` en psql
- Ejemplo: `topic_type.name` es incorrecto → `topic_type.topic_type_name`

### Error: "invalid input value for enum"
```sql
-- Ver valores válidos de enum
SELECT unnest(enum_range(NULL::topic_level));
-- Resultado: 'Study', 'Mock', 'Flashcard' (singular, no 'Flashcards')
```

### Error: Trigger no crea opciones
- Verificar que `topic.options` tenga valor válido (2, 3 o 4)
- Verificar que trigger existe: `\df create_blank_question_options`

### Datos no se extraen
```bash
# Forzar re-extracción
export FORCE_DOWNLOAD=true
./migrate.sh
```

### Ver logs detallados
```bash
# Durante ejecución
tail -f logs/migration.log

# Después de ejecución
cat logs/migration.log | grep ERROR
```

---

## 📊 Estado Actual de la Migración

### ✅ Completado
- [x] Topic Types (6 tipos)
- [x] Categories (14)
- [x] Topics (237)
- [x] Questions (17,462) + Options (67,974)
- [x] Flashcards: Topics (52) + Questions (1,305) + Options (2,610)

### ⏳ Pendiente (Opcional)
- [ ] Users
- [ ] User Tests
- [ ] User Test Answers
- [ ] User Favorite Questions
- [ ] Questions con topic=null (3,400 de inglés)

### 📈 Estadísticas

| Tabla | BD Antigua | BD Nueva | % Migrado |
|-------|------------|----------|-----------|
| topic_type | - | 6 | ✅ 100% (nuevo) |
| categories | 14 | 14 | ✅ 100% |
| topics | 237 | 289 | ✅ 100% + 52 flashcards |
| questions | 20,862 | 18,767 | ✅ 90% (excluyendo topic=null) |
| question_options | - | 70,584 | ✅ 100% (nuevo) |

**Total questions migradas:** 18,767 (17,462 normales + 1,305 flashcards)

---

## 🔗 Recursos

- **Supabase Docs:** https://supabase.com/docs
- **PostgreSQL Triggers:** https://www.postgresql.org/docs/current/triggers.html
- **Python psycopg2:** https://www.psycopg.org/docs/

---

## 📝 Notas Finales

- **Performance:** Con `FORCE_DOWNLOAD=false` la migración es muy rápida (usa datos cacheados)
- **Seguridad:** NUNCA commitear `.env` con credenciales reales
- **Testing:** Siempre probar primero en BD local antes de producción
- **Backups:** Hacer backup de BD antes de cargar datos

**Última actualización:** 2025-11-16
**Versión:** 2.0 (incluye flashcards)

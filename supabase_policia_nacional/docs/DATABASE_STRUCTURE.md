# 🗄️ ESTRUCTURA COMPLETA DE LA BASE DE DATOS

## 📊 **Tablas en la Base de Datos**

Tu base de datos tiene **12 tablas** organizadas en 4 categorías:

---

## 1️⃣ **TABLAS DE USUARIOS Y AUTENTICACIÓN**

### **`users`** (Usuarios de la app)
```sql
┌─────────────────────────┬──────────────────────────┬─────────────────────────────┐
│ Campo                   │ Tipo                     │ Descripción                 │
├─────────────────────────┼──────────────────────────┼─────────────────────────────┤
│ id                      │ bigint (PK)              │ ID único del usuario        │
│ username                │ varchar                  │ Nombre de usuario           │
│ email                   │ text                     │ Email del usuario           │
│ first_name              │ text                     │ Nombre                      │
│ last_name               │ text                     │ Apellido                    │
│ phone                   │ text                     │ Teléfono                    │
│ totalQuestions          │ bigint                   │ Total preguntas hechas      │
│ rightQuestions          │ bigint                   │ Preguntas correctas         │
│ wrongQuestions          │ bigint                   │ Preguntas incorrectas       │
│ tester                  │ boolean                  │ ¿Es usuario de prueba?      │
│ fcm_token               │ text                     │ Token para notificaciones   │
│ fid_token               │ text                     │ Token Firebase ID           │
│ profile_image           │ text                     │ URL imagen de perfil        │
│ unlocked_at             │ timestamp                │ Cuándo desbloqueó contenido │
│ unlock_duration_minutes │ integer                  │ Duración del desbloqueo     │
│ enabled                 │ boolean                  │ Usuario activo              │
│ tutorial                │ boolean                  │ Completó tutorial           │
│ createdAt               │ timestamp                │ Fecha creación              │
│ updatedAt               │ timestamp                │ Fecha actualización         │
└─────────────────────────┴──────────────────────────┴─────────────────────────────┘
```

**Propósito:** Gestiona los usuarios de tu app Flutter

---

### **`cms_users`** (Usuarios del CMS/Admin)
```sql
┌────────────┬─────────┬─────────────────────────────┐
│ Campo      │ Tipo    │ Descripción                 │
├────────────┼─────────┼─────────────────────────────┤
│ id         │ bigint  │ ID único                    │
│ username   │ varchar │ Usuario admin               │
│ email      │ text    │ Email admin                 │
│ password   │ text    │ Contraseña hasheada         │
│ role_id    │ bigint  │ FK a tabla role             │
│ enabled    │ boolean │ Usuario activo              │
│ created_at │ timestamp│ Fecha creación             │
│ updated_at │ timestamp│ Fecha actualización        │
└────────────┴─────────┴─────────────────────────────┘
```

**Propósito:** Usuarios que gestionan el contenido (administradores, editores)

---

### **`role`** (Roles de usuarios CMS)
```sql
┌─────────────┬─────────┬─────────────────────────────┐
│ Campo       │ Tipo    │ Descripción                 │
├─────────────┼─────────┼─────────────────────────────┤
│ id          │ bigint  │ ID único                    │
│ name        │ varchar │ Nombre del rol              │
│ permissions │ jsonb   │ Permisos del rol            │
│ created_at  │ timestamp│ Fecha creación            │
└─────────────┴─────────┴─────────────────────────────┘
```

**Propósito:** Define roles como Admin, Editor, Viewer, etc.

---

## 2️⃣ **TABLAS DE MEMBRESÍAS** (Sistema WordPress + RevenueCat)

### **`membership_levels`** (Catálogo de niveles)
```sql
┌───────────────────────────┬──────────┬──────────────────────────────────────┐
│ Campo                     │ Tipo     │ Descripción                          │
├───────────────────────────┼──────────┼──────────────────────────────────────┤
│ id                        │ bigint   │ ID único (PK)                        │
│ name                      │ varchar  │ Nombre: Gratis, Premium, Premium+    │
│ description               │ text     │ Descripción del nivel                │
│ wordpress_rcp_id          │ integer  │ ID en WordPress RCP                  │
│ revenuecat_product_ids    │ array    │ IDs de productos en RevenueCat       │
│ revenuecat_entitlement_id │ varchar  │ Entitlement en RevenueCat            │
│ access_level              │ integer  │ 1=Gratis, 2=Premium, 3=Premium+      │
│ duration_days             │ integer  │ Duración en días                     │
│ price_eur                 │ numeric  │ Precio en euros                      │
│ features                  │ jsonb    │ Features del nivel                   │
│ is_active                 │ boolean  │ Nivel activo                         │
│ created_at                │ timestamp│ Fecha creación                       │
│ updated_at                │ timestamp│ Fecha actualización                  │
└───────────────────────────┴──────────┴──────────────────────────────────────┘
```

**Datos actuales:**
```
┌──────────────┬─────────────────────────────────────────┬──────────────┐
│ name         │ revenuecat_product_ids                  │ access_level │
├──────────────┼─────────────────────────────────────────┼──────────────┤
│ Gratis       │ {opn_gc_free}                           │ 1            │
│ Premium      │ {premium_month, premium_quarter,        │ 2            │
│              │  premium_semester, premium_annual}      │              │
│ Premium Plus │ {opn_gc_premium_plus}                   │ 3            │
└──────────────┴─────────────────────────────────────────┴──────────────┘
```

---

### **`user_memberships`** (Membresías de usuarios)
```sql
┌──────────────────────────┬───────────┬─────────────────────────────────────────┐
│ Campo                    │ Tipo      │ Descripción                             │
├──────────────────────────┼───────────┼─────────────────────────────────────────┤
│ id                       │ bigint    │ ID único (PK)                           │
│ user_id                  │ bigint    │ FK → users.id (REQUIRED)                │
│ membership_level_id      │ bigint    │ FK → membership_levels.id (REQUIRED)    │
│ status                   │ varchar   │ active, inactive, cancelled, expired    │
│ started_at               │ timestamp │ Inicio de membresía                     │
│ expires_at               │ timestamp │ Expiración (null = lifetime)            │
│ cancelled_at             │ timestamp │ Cuándo se canceló                       │
│ auto_renews              │ boolean   │ Se renueva automáticamente              │
│ renewal_grace_period_days│ integer   │ Días de gracia antes de expirar         │
│ last_synced_at           │ timestamp │ Última sincronización                   │
│ sync_source              │ varchar   │ revenuecat, wordpress, manual           │
│ sync_status              │ varchar   │ synced, pending, error                  │
│ sync_error               │ text      │ Mensaje de error si falla sync          │
│ metadata                 │ jsonb     │ Datos adicionales (RC/WP info)          │
│ created_at               │ timestamp │ Fecha creación                          │
│ updated_at               │ timestamp │ Fecha actualización                     │
└──────────────────────────┴───────────┴─────────────────────────────────────────┘

**Nota importante**: 
- user_id es el MISMO en users.id, WordPress user ID y RevenueCat app_user_id
- Ya no hay campos redundantes como email, wordpress_user_id separado
- Todo se centraliza en users.id con FK obligatoria
```

**Propósito:** Registra qué membresía tiene cada usuario y desde dónde fue creada

---

## 3️⃣ **TABLAS DE CONTENIDO (Preguntas y Tests)**

### **`topic_type`** (Tipos de temas)
```sql
┌─────────────┬─────────┬─────────────────────────────┐
│ Campo       │ Tipo    │ Descripción                 │
├─────────────┼─────────┼─────────────────────────────┤
│ id          │ bigint  │ ID único                    │
│ name        │ varchar │ Nombre del tipo             │
│ description │ text    │ Descripción                 │
│ created_at  │ timestamp│ Fecha creación            │
└─────────────┴─────────┴─────────────────────────────┘
```

**Ejemplos:** "Examen", "Test", "Simulacro", "Temario"

---

### **`topic`** (Temas de estudio)
```sql
┌───────────────────────────┬───────────┬──────────────────────────────────┐
│ Campo                     │ Tipo      │ Descripción                      │
├───────────────────────────┼───────────┼──────────────────────────────────┤
│ id                        │ bigint    │ ID único                         │
│ topic_type_id             │ bigint    │ FK a topic_type                  │
│ topic_name                │ text      │ Nombre del tema                  │
│ description               │ text      │ Descripción                      │
│ enabled                   │ boolean   │ Tema activo                      │
│ is_premium                │ boolean   │ ¿Requiere Premium?               │
│ is_hidden_but_premium     │ boolean   │ Oculto pero accesible con Premium│
│ published_at              │ timestamp │ Fecha publicación                │
│ total_participants        │ bigint    │ Usuarios que lo han hecho        │
│ total_questions           │ bigint    │ Número de preguntas              │
└───────────────────────────┴───────────┴──────────────────────────────────┘
```

**Propósito:** Organiza el contenido en temas (ej: "Constitución", "Derecho Penal")

---

### **`questions`** (Preguntas del test)
```sql
┌────────────────────┬─────────┬────────────────────────────────────┐
│ Campo              │ Tipo    │ Descripción                        │
├────────────────────┼─────────┼────────────────────────────────────┤
│ id                 │ bigint  │ ID único                           │
│ question           │ text    │ Texto de la pregunta               │
│ tip                │ text    │ Ayuda/pista                        │
│ topic              │ bigint  │ FK a topic                         │
│ article            │ text    │ Artículo de ley relacionado        │
│ question_image_url │ text    │ Imagen de la pregunta              │
│ retro_image_url    │ text    │ Imagen de retroalimentación        │
│ retro_audio_enable │ boolean │ ¿Tiene audio?                      │
│ retro_audio_text   │ text    │ Texto del audio                    │
│ question_order     │ integer │ Orden en el tema                   │
└────────────────────┴─────────┴────────────────────────────────────┘
```

---

### **`question_options`** (Opciones de respuesta)
```sql
┌─────────────┬─────────┬─────────────────────────────┐
│ Campo       │ Tipo    │ Descripción                 │
├─────────────┼─────────┼─────────────────────────────┤
│ id          │ bigint  │ ID único                    │
│ question_id │ bigint  │ FK a questions              │
│ option_text │ text    │ Texto de la opción          │
│ is_correct  │ boolean │ ¿Es correcta?               │
│ order       │ integer │ Orden de la opción          │
└─────────────┴─────────┴─────────────────────────────┘
```

**Ejemplo:**
```
Pregunta: "¿En qué año se aprobó la Constitución?"
  Opción A: 1975 (is_correct: false)
  Opción B: 1978 (is_correct: true)  ← Correcta
  Opción C: 1980 (is_correct: false)
  Opción D: 1982 (is_correct: false)
```

---

## 4️⃣ **TABLAS DE ACTIVIDAD DEL USUARIO**

### **`user_tests`** (Tests realizados por usuarios)
```sql
┌──────────────────┬───────────┬────────────────────────────────┐
│ Campo            │ Tipo      │ Descripción                    │
├──────────────────┼───────────┼────────────────────────────────┤
│ id               │ bigint    │ ID único                       │
│ user_id          │ bigint    │ FK a users                     │
│ topic_id         │ bigint    │ FK a topic                     │
│ started_at       │ timestamp │ Cuándo empezó                  │
│ completed_at     │ timestamp │ Cuándo terminó                 │
│ total_questions  │ integer   │ Total de preguntas             │
│ correct_answers  │ integer   │ Respuestas correctas           │
│ incorrect_answers│ integer   │ Respuestas incorrectas         │
│ score            │ numeric   │ Puntuación (0-100)             │
│ time_spent       │ integer   │ Tiempo en segundos             │
│ completed        │ boolean   │ ¿Completó el test?             │
└──────────────────┴───────────┴────────────────────────────────┘
```

**Propósito:** Registra cada test que hace un usuario

---

### **`user_test_answers`** (Respuestas individuales)
```sql
┌─────────────────┬───────────┬────────────────────────────────┐
│ Campo           │ Tipo      │ Descripción                    │
├─────────────────┼───────────┼────────────────────────────────┤
│ id              │ bigint    │ ID único                       │
│ user_test_id    │ bigint    │ FK a user_tests                │
│ question_id     │ bigint    │ FK a questions                 │
│ selected_option │ bigint    │ FK a question_options          │
│ is_correct      │ boolean   │ ¿Respondió bien?               │
│ answered_at     │ timestamp │ Cuándo respondió               │
│ time_taken      │ integer   │ Tiempo en responder (segundos) │
└─────────────────┴───────────┴────────────────────────────────┘
```

**Propósito:** Detalle de cada respuesta que dio el usuario

---

### **`challenge`** (Impugnaciones/reportes)
```sql
┌─────────────┬───────────┬────────────────────────────────────┐
│ Campo       │ Tipo      │ Descripción                        │
├─────────────┼───────────┼────────────────────────────────────┤
│ id          │ bigint    │ ID único                           │
│ user_id     │ bigint    │ FK a users (quien reporta)         │
│ question_id │ bigint    │ FK a questions (pregunta reportada)│
│ topic_id    │ bigint    │ FK a topic                         │
│ reason      │ text      │ Motivo de la impugnación           │
│ state       │ enum      │ pending, approved, rejected        │
│ reply       │ text      │ Respuesta del admin                │
│ editor_id   │ bigint    │ FK a cms_users (quien resolvió)    │
│ created_at  │ timestamp │ Fecha creación                     │
│ updated_at  │ timestamp │ Fecha actualización                │
└─────────────┴───────────┴────────────────────────────────────┘
```

**Propósito:** Usuarios pueden reportar preguntas incorrectas o confusas

---

## 🔗 **RELACIONES PRINCIPALES**

```
users
  ↓ (1:N)
user_memberships → membership_levels
  ↓ (1:N)
user_tests → topic → topic_type
  ↓ (1:N)          ↓ (1:N)
user_test_answers → questions → question_options
                     ↓ (1:N)
                   challenge → cms_users (editor)

cms_users → role (permisos)
```

---

## 📊 **RESUMEN POR FUNCIONALIDAD**

| Funcionalidad | Tablas Involucradas |
|---------------|---------------------|
| **Autenticación** | `users`, `cms_users`, `role` |
| **Membresías/Pagos** | `membership_levels`, `user_memberships` |
| **Contenido** | `topic_type`, `topic`, `questions`, `question_options` |
| **Actividad Usuario** | `user_tests`, `user_test_answers` |
| **Moderación** | `challenge` |

---

## 🎯 **CASOS DE USO**

### **1. Usuario hace un test:**
```sql
-- 1. Crear registro de test
INSERT INTO user_tests (user_id, topic_id, started_at)
VALUES (1, 5, NOW());

-- 2. Guardar cada respuesta
INSERT INTO user_test_answers (user_test_id, question_id, selected_option, is_correct)
VALUES (100, 50, 201, true);

-- 3. Al terminar, actualizar user_tests
UPDATE user_tests 
SET completed = true, 
    completed_at = NOW(),
    correct_answers = 8,
    incorrect_answers = 2,
    score = 80
WHERE id = 100;

-- 4. Actualizar estadísticas del usuario
UPDATE users 
SET totalQuestions = totalQuestions + 10,
    rightQuestions = rightQuestions + 8,
    wrongQuestions = wrongQuestions + 2
WHERE id = 1;
```

### **2. Usuario compra Premium desde app:**
```sql
-- 1. RevenueCat envía webhook → Crear membresía
INSERT INTO user_memberships (
  email, 
  membership_level_id,
  revenuecat_product_id,
  sync_source,
  status,
  started_at,
  expires_at
) VALUES (
  'maria@ejemplo.com',
  (SELECT id FROM membership_levels WHERE access_level = 2),
  'premium_annual',
  'revenuecat',
  'active',
  NOW(),
  NOW() + INTERVAL '1 year'
);

-- 2. Sincronizar con WordPress (en backend)
```

### **3. Verificar acceso a contenido premium:**
```sql
SELECT 
  t.topic_name,
  t.is_premium,
  um.status as membership_status,
  ml.access_level
FROM topic t
LEFT JOIN user_memberships um ON um.email = 'user@ejemplo.com'
LEFT JOIN membership_levels ml ON um.membership_level_id = ml.id
WHERE t.id = 10;

-- Si access_level >= 2 Y is_premium = true → Tiene acceso ✅
```

---

**✅ Base de datos completa y lista para tu app de oposiciones a Guardia Civil!**

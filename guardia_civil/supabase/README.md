# 🚀 Supabase - Sistema OPN Guardia Civil

Sistema integral de gestión para la aplicación móvil de preparación de oposiciones que integra:
- **WordPress RCP** - Gestión de membresías y usuarios
- **Supabase** - Backend as a Service (Base de datos, Edge Functions, Storage)
- **RevenueCat** - Gestión de suscripciones móviles (iOS/Android)

---

## 📁 Estructura del Proyecto

```
supabase/
├── docs/                           # 📚 Documentación técnica completa
│   ├── README.md                   # Índice de documentación
│   ├── DATABASE_STRUCTURE.md       # Estructura de la base de datos
│   ├── DATABASE_TRIGGERS.md        # Triggers y funciones
│   ├── SISTEMA_MEMBRESIAS.md       # Flujo del sistema de membresías
│   ├── SISTEMA_FLASHCARDS_Y_ACADEMIAS.md  # Sistema de flashcards
│   ├── SISTEMA_ESPECIALIDADES.md   # Sistema de especialidades
│   └── API_ENDPOINTS_REFERENCE.md  # Referencia completa de API
│
├── functions/                      # ⚡ Edge Functions (Deno)
│   ├── login-register/             # Autenticación y sincronización
│   │   ├── api/v1/                # Endpoints versión 1
│   │   ├── framework/             # Framework común
│   │   ├── wp_client/             # Cliente WordPress
│   │   └── sync_memberships.ts    # Sincronización de membresías
│   │
│   └── generate-custom-test/       # Generación de tests personalizados
│       ├── index.ts               # Punto de entrada
│       ├── types.ts               # Tipos TypeScript
│       ├── question_distributor.ts # Lógica de distribución
│       └── README.md              # Documentación de la función
│
├── migrations/                     # 🗄️ Migraciones de base de datos
│   └── [timestamps]_*.sql         # Archivos de migración SQL
│
├── scripts_macos/                  # 🛠️ Scripts de utilidad
│   ├── deploy_local.sh            # Despliegue local
│   └── sync_membership_catalog.sh # Sincronización de catálogo
│
├── wordpress_plugin/               # 🔌 Plugin personalizado de WordPress
│   ├── rcp-custom-rest-api.php    # Código fuente del plugin
│   ├── rcp-custom-rest-api.zip    # Plugin listo para instalar
│   └── README.md                  # Instrucciones de instalación
│
└── config.toml                    # ⚙️ Configuración de Supabase
```

---

## 🎯 Características Principales

### 🔐 Autenticación y Membresías
- Login/Register con WordPress JWT
- **Sincronización automática de membresías** en cada login/registro
- Asignación automática de membresía Freemium para nuevos usuarios
- Integración con WordPress RCP y RevenueCat
- Sistema de niveles de acceso (Freemium, Básico, Premium)

### 📚 Sistema de Contenidos
- Gestión de preguntas con opciones múltiples
- Sistema de topics por especialidades
- Flashcards con algoritmo de repetición espaciada (SM-2)
- Sistema multi-academia
- Tests simulacro y modo estudio

### 🎲 Generación de Tests Personalizados
- Distribución configurable de preguntas por topics
- Selección aleatoria de preguntas
- Validación de topics de tipo "Study"
- Filtrado por academia

---

## 🚀 Inicio Rápido

### 1. Requisitos Previos
- [Supabase CLI](https://supabase.com/docs/guides/cli) instalado
- [Docker](https://www.docker.com/) instalado y corriendo
- [Deno](https://deno.land/) (opcional, para desarrollo local)

### 2. Configurar Variables de Entorno

```bash
# Copiar el archivo de ejemplo
cp functions/.env.example functions/.env

# Editar y configurar valores
nano functions/.env
```

**Variables requeridas:**
```bash
WP_URL=https://tu-wordpress.com
WP_ADMIN_USERNAME=tu-usuario
WP_ADMIN_PASSWORD=tu-password
WP_JWT_SECRET=tu-jwt-secret
REVENUECAT_WEBHOOK_SECRET=tu-webhook-secret
```

### 3. Iniciar Entorno Local

```bash
# Usar el script de despliegue
./scripts_macos/deploy_local.sh

# O manualmente
supabase start
```

### 4. Sincronizar Catálogo de Membresías

```bash
./scripts_macos/sync_membership_catalog.sh
```

---

## 📡 API Endpoints

Base URL local: `http://127.0.0.1:54321/functions/v1/login-register/v1`

### 🔐 Autenticación

#### POST `/v1/login`
Login de usuario con sincronización automática de membresías

**Request:**
```json
{
  "username": "usuario@email.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "token": "jwt_token_here",
  "user": {
    "id": 123,
    "username": "usuario",
    "email": "usuario@email.com",
    "user_memberships": [...]
  },
  "memberships_synced": 2
}
```

#### POST `/v1/register`
Registro de nuevo usuario con sincronización automática

**Request:**
```json
{
  "username": "nuevousuario",
  "email": "nuevo@email.com",
  "password": "password123",
  "first_name": "Nombre",
  "last_name": "Apellido"
}
```

**Response:**
```json
{
  "success": true,
  "token": "jwt_token_here",
  "id": 124,
  "username": "nuevousuario",
  "email": "nuevo@email.com",
  "memberships_synced": 1
}
```

#### POST `/v1/get_user`
Obtener datos completos del usuario

**Request:**
```json
{
  "jwt_token": "token_here"
}
```

### 💳 Membresías

#### POST `/v1/update_membership_catalog`
Sincronizar catálogo completo de membresías desde WordPress

**Request:**
```json
{}
```

#### POST `/v1/revenuecat`
Webhook de RevenueCat para sincronización de suscripciones

---

## 🎲 Edge Function: Generate Custom Test

Genera tests personalizados con distribución configurable de preguntas por topics.

**Endpoint:** `POST /functions/v1/generate-custom-test`

**Request:**
```json
{
  "topics": [
    { "id": 1, "weight": 0.4 },   // 40% de las preguntas
    { "id": 2, "weight": 0.35 },  // 35% de las preguntas
    { "id": 3, "weight": 0.25 }   // 25% de las preguntas
  ],
  "totalQuestions": 30,
  "academyId": 1  // Opcional
}
```

**Response:**
```json
{
  "success": true,
  "questions": [...],  // Array de 30 preguntas mezcladas
  "distribution": {
    "1": 12,
    "2": 11,
    "3": 7
  },
  "totalQuestions": 30,
  "requestedQuestions": 30
}
```

**Características:**
- ✅ Normalización automática de pesos (no necesitan sumar 1)
- ✅ Selección aleatoria con algoritmo Fisher-Yates
- ✅ Validación de topics de tipo "Study"
- ✅ Manejo inteligente cuando no hay suficientes preguntas
- ✅ Consultas paralelas para mejor performance

📖 **[Ver documentación completa](functions/generate-custom-test/README.md)**

---

## 🔄 Sistema de Sincronización de Membresías

### Flujo Automático

1. **Login/Register**:
   - ✅ Crea/actualiza usuario en Supabase
   - ✅ Sincroniza automáticamente membresías desde WordPress RCP
   - ✅ Asigna membresía Freemium si no tiene ninguna

2. **Sincronización de Membresías**:
   - Obtiene membresías activas desde WordPress RCP
   - Crea nuevas membresías en Supabase
   - Actualiza membresías existentes
   - Desactiva membresías que ya no están en WordPress
   - Si no hay membresías, asigna Freemium automáticamente

3. **Niveles de Membresía**:
   - **Freemium** (access_level: 1) - Acceso básico
   - **Básico** (access_level: 2) - Acceso intermedio
   - **Premium** (access_level: 3) - Acceso completo

### Sincronización Manual

```bash
# Endpoint de sincronización manual
curl -X POST http://127.0.0.1:54321/functions/v1/login-register/v1/sync_membership_catalog
```

---

## 🗄️ Base de Datos

### Tablas Principales

- **users** - Usuarios sincronizados desde WordPress
- **membership_levels** - Catálogo de niveles de membresía
- **user_memberships** - Membresías activas/inactivas de usuarios
- **academies** - Multi-academia (Guardia Civil, Policía, etc.)
- **topic_type** - Tipos de topics (Study, Mock)
- **topic** - Topics/temas de estudio
- **questions** - Preguntas con opciones
- **question_options** - Opciones de respuesta
- **user_tests** - Tests realizados por usuarios
- **flashcards** - Sistema de flashcards con SM-2
- **specialties** - Especialidades por academia

### Triggers Automáticos

- `trg_update_topic_question_count_*` - Actualiza contador de preguntas
- `trg_update_academy_total_questions` - Actualiza total de preguntas por academia
- `trg_create_blank_options` - Crea opciones en blanco para nuevas preguntas
- `trg_challenge_by_tutor_update` - Notifica cambios en preguntas desafiadas
- `trg_update_topic_duration_*` - Calcula duración estimada de topics

📖 **[Ver estructura completa](docs/DATABASE_STRUCTURE.md)**

---

## 🔧 Comandos Útiles

### Gestión de Supabase

```bash
# Iniciar
supabase start

# Detener
supabase stop

# Reiniciar
supabase stop && supabase start

# Ver estado
supabase status

# Ver todos los containers
docker ps | grep supabase
```

### Base de Datos

```bash
# Conectar a PostgreSQL
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres

# Crear nueva migración
supabase migration new nombre_descriptivo

# Aplicar migraciones
supabase db push

# Reset completo (⚠️ borra todos los datos)
supabase db reset
```

### Edge Functions

```bash
# Desplegar función específica
supabase functions deploy login-register
supabase functions deploy generate-custom-test

# Ver logs en tiempo real
supabase functions logs login-register --follow

# Servir todas las funciones localmente
supabase functions serve
```

### Ver Logs

```bash
# Logs de Edge Functions (local)
docker logs -f supabase_edge_runtime_opn_gc_test

# Logs de PostgreSQL
docker logs -f supabase_db_opn_gc_test

# Logs de producción
supabase functions logs login-register
```

---

## 📦 Deploy a Producción

### 1. Login y Link

```bash
# Login a Supabase
supabase login

# Link al proyecto
supabase link --project-ref tu-project-ref
```

### 2. Aplicar Migraciones

```bash
# Aplicar todas las migraciones
supabase db push
```

### 3. Deploy Edge Functions

```bash
# Desplegar todas las funciones
supabase functions deploy login-register
supabase functions deploy generate-custom-test

# O una por una
supabase functions deploy login-register --no-verify-jwt
```

### 4. Configurar Secrets

```bash
# Configurar variables de entorno
supabase secrets set WP_URL=https://tu-wordpress.com
supabase secrets set WP_ADMIN_USERNAME=tu-usuario
supabase secrets set WP_ADMIN_PASSWORD=tu-password
supabase secrets set WP_JWT_SECRET=tu-jwt-secret
supabase secrets set REVENUECAT_WEBHOOK_SECRET=tu-webhook-secret

# Ver secrets configurados
supabase secrets list

# O desde archivo
supabase secrets set --env-file functions/.env.production
```

### 5. ⚠️ Seguridad en Producción

**IMPORTANTE:** Cambiar en `config.toml`:
```toml
verify_jwt = true  # DEBE ser true en producción
```

---

## 🔌 Plugin WordPress

El plugin personalizado `rcp-custom-rest-api` permite acceso directo a la base de datos de RCP.

### Instalación

1. Subir `wordpress_plugin/rcp-custom-rest-api.zip` a WordPress
2. Activar el plugin
3. El endpoint estará disponible en `/wp-json/rcp-custom/v1/levels`

### Endpoints del Plugin

```bash
# Obtener todos los niveles de membresía
GET /wp-json/rcp-custom/v1/levels
```

📖 **[Ver documentación completa](wordpress_plugin/README.md)**

---

## 🛠️ Desarrollo

### Agregar Nueva Edge Function

1. Crear directorio: `functions/nueva-funcion/`
2. Crear `index.ts` con el handler:
```typescript
Deno.serve(async (request: Request) => {
  // Tu lógica aquí
  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```
3. Desplegar: `supabase functions deploy nueva-funcion`

### Agregar Endpoint a login-register

1. Crear archivo en `functions/login-register/api/v1/tu_endpoint.ts`
2. Implementar clase que extienda `RequestHandler`
3. Registrar en `api/v1_api_router.ts`:
```typescript
case 'POST:tu_endpoint':
  const handler = new TuEndpoint()
  fnResponse = await handler.handle(this.supabaseClient, request)
  break
```

### Testing Local

```bash
# Test de endpoint
curl -X POST http://127.0.0.1:54321/functions/v1/login-register/v1/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test@email.com","password":"password"}'

# Test de generate-custom-test
curl -X POST http://127.0.0.1:54321/functions/v1/generate-custom-test \
  -H "Content-Type: application/json" \
  -d '{
    "topics": [{"id": 1, "weight": 0.5}, {"id": 2, "weight": 0.5}],
    "totalQuestions": 20
  }'
```

---

## 🐛 Troubleshooting

### Supabase no inicia

```bash
# Ver contenedores
docker ps -a

# Ver logs específicos
docker logs <container_id>

# Limpiar todo y reiniciar
supabase stop
docker system prune -f
supabase start
```

### Edge Functions no responden

```bash
# Verificar que estén corriendo
docker ps | grep edge_runtime

# Ver logs en tiempo real
docker logs -f supabase_edge_runtime_opn_gc_test

# Reiniciar solo las funciones
supabase functions serve
```

### Error 401 en desarrollo local

⚠️ Asegurar que `verify_jwt = false` en `config.toml`

### Membresías no se sincronizan

```bash
# Ver logs de sincronización
docker logs -f supabase_edge_runtime_opn_gc_test | grep "Syncing memberships"

# Verificar que el plugin esté activo en WordPress
curl https://tu-wordpress.com/wp-json/rcp-custom/v1/levels

# Sincronizar manualmente
curl -X POST http://127.0.0.1:54321/functions/v1/login-register/v1/update_membership_catalog
```

### Migraciones fallan

```bash
# Ver estado de migraciones
supabase migration list

# Reset completo (⚠️ CUIDADO: borra datos)
supabase db reset

# Aplicar una migración específica
supabase migration up
```

---

## 📚 Documentación Completa

### Índice de Documentos

- **[docs/README.md](docs/README.md)** - Índice completo con arquitectura
- **[docs/DATABASE_STRUCTURE.md](docs/DATABASE_STRUCTURE.md)** - Tablas, índices y relaciones
- **[docs/DATABASE_TRIGGERS.md](docs/DATABASE_TRIGGERS.md)** - Triggers y funciones PL/pgSQL
- **[docs/SISTEMA_MEMBRESIAS.md](docs/SISTEMA_MEMBRESIAS.md)** - Flujo completo de membresías
- **[docs/SISTEMA_FLASHCARDS_Y_ACADEMIAS.md](docs/SISTEMA_FLASHCARDS_Y_ACADEMIAS.md)** - Sistema de flashcards
- **[docs/SISTEMA_ESPECIALIDADES.md](docs/SISTEMA_ESPECIALIDADES.md)** - Especialidades por academia
- **[docs/API_ENDPOINTS_REFERENCE.md](docs/API_ENDPOINTS_REFERENCE.md)** - Referencia API completa

### Edge Functions

- **[functions/generate-custom-test/README.md](functions/generate-custom-test/README.md)** - Generación de tests
- **[functions/login-register/revenuecat/README.md](functions/login-register/revenuecat/README.md)** - RevenueCat

---

## 📞 Recursos Externos

- **[Documentación Supabase](https://supabase.com/docs)**
- **[Documentación RCP](https://docs.restrictcontentpro.com/)**
- **[Documentación RevenueCat](https://www.revenuecat.com/docs)**
- **[Deno Manual](https://deno.land/manual)**
- **[Supabase CLI Reference](https://supabase.com/docs/reference/cli)**

---

## 📊 URLs de Acceso Local

Una vez iniciado con `supabase start`:

| Servicio | URL |
|----------|-----|
| **API** | http://127.0.0.1:54321 |
| **Studio** | http://127.0.0.1:54323 |
| **Database** | postgresql://postgres:postgres@127.0.0.1:54322/postgres |
| **Inbucket (Email)** | http://127.0.0.1:54324 |

**Base URL Functions:**
- Login/Register: `http://127.0.0.1:54321/functions/v1/login-register/v1`
- Generate Test: `http://127.0.0.1:54321/functions/v1/generate-custom-test`

---

## ✅ Estado del Proyecto

### ✅ Completado

- [x] Sistema de autenticación con WordPress JWT
- [x] **Sincronización automática de membresías en login/register**
- [x] Edge Function de generación de tests personalizados
- [x] Sistema multi-academia completo
- [x] Sistema de flashcards con SM-2
- [x] Sistema de especialidades
- [x] Base de datos con triggers optimizados
- [x] Plugin WordPress instalado y funcionando
- [x] Scripts de automatización (deploy, sync)
- [x] Documentación técnica completa

### 🚧 En Desarrollo

- [ ] Sistema de rankings y estadísticas
- [ ] Notificaciones push
- [ ] Sistema de gamificación
- [ ] Análisis de rendimiento por especialidad

### 📋 Por Hacer

- [ ] Deploy a producción
- [ ] Configurar CDN para imágenes
- [ ] Implementar caché de consultas frecuentes
- [ ] Tests automatizados (unit + integration)
- [ ] Monitoreo y alertas

---

## 📝 Changelog

### v2.0.0 - 2025-10-27
- ✨ **Nueva**: Edge Function `generate-custom-test` para tests personalizados
- ✨ **Nueva**: Sincronización automática de membresías en login y register
- 🔧 Limpieza de código: eliminados tests antiguos y documentos redundantes
- 📚 Documentación consolidada en README principal
- 🐛 Correcciones en sistema de membresías

### v1.0.0 - 2025-10-03
- 🎉 Release inicial
- ✅ Sistema completo de membresías
- ✅ Autenticación con WordPress
- ✅ Integración con RevenueCat

---

**Versión:** 2.0.0
**Última actualización:** 27 de octubre de 2025
**Estado:** ✅ Sistema completamente funcional
**Mantenido por:** Equipo OPN Guardia Civil

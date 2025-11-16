# 🏠 Desarrollo Local con Supabase Core

Para desarrollo local, puedes trabajar con cualquiera de las dos configuraciones de base de datos.

## 🚀 Iniciar desarrollo local

### Opción 1: Modo genérico (sin configuración específica)

```bash
npm run dev
# o
./scripts/dev-start.sh
```

### Opción 2: Con configuración de Policía Nacional

```bash
npm run dev:policia
# o
./scripts/dev-start.sh policia_nacional
```

Esto:
- Carga secrets desde `project-configs/policia_nacional.secrets`
- Configura el `project_id` como "policia_nacional"
- Inicia Supabase con esa configuración

### Opción 3: Con configuración de Guardia Civil

```bash
npm run dev:guardia
# o
./scripts/dev-start.sh guardia_civil
```

## 🔄 Cambiar entre proyectos

Si ya tienes un proyecto corriendo y quieres cambiar a otro:

```bash
# Cambiar a Policía Nacional
npm run dev:switch policia_nacional

# Cambiar a Guardia Civil
npm run dev:switch guardia_civil

# O manualmente
./scripts/dev-switch.sh policia_nacional
```

Esto automáticamente:
1. Detiene el proyecto actual
2. Cambia la configuración
3. Inicia el nuevo proyecto

## 📊 URLs locales

Una vez iniciado, tendrás:

```
API URL:      http://127.0.0.1:54321
Studio URL:   http://127.0.0.1:54323  ← Interfaz web
Database URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
Mailpit URL:  http://127.0.0.1:54324  ← Ver emails de test
```

## 🛠️ Comandos útiles

```bash
# Ver status
npm run dev:status

# Detener
npm run dev:stop

# Resetear DB (aplica todas las migraciones)
npm run dev:reset

# Crear nueva migración
npm run new:migration add_my_feature

# Abrir Studio
open http://127.0.0.1:54323
```

## 📝 Estructura de archivos

```
supabase_core/
├── .env                           # Variables de entorno activas
├── config.toml                    # Configuración de Supabase
├── project-configs/
│   ├── policia_nacional.secrets   # Secrets para Policía
│   └── guardia_civil.secrets      # Secrets para Guardia
├── migrations/                    # Migraciones compartidas
└── functions/                     # Edge functions compartidas
```

## 🔐 Variables de entorno

Los scripts automáticamente cargan los secrets apropiados según el proyecto:

- **Policía Nacional**: Usa `project-configs/policia_nacional.secrets`
- **Guardia Civil**: Usa `project-configs/guardia_civil.secrets`

Estos archivos contienen:
- WordPress credentials
- OpenAI API key
- JWT secrets
- RAG API URL
- etc.

## 🔄 Flujo de trabajo típico

### Desarrollo con Policía Nacional

```bash
# 1. Iniciar con configuración de Policía
npm run dev:policia

# 2. Abrir Studio
open http://127.0.0.1:54323

# 3. Desarrollar (crear migraciones, modificar functions, etc.)
npm run new:migration add_new_feature

# 4. Aplicar cambios
npm run dev:reset

# 5. Probar en Studio o con la app
```

### Cambiar a Guardia Civil

```bash
# Cambiar rápidamente
npm run dev:switch guardia_civil

# Ahora estás trabajando con configuración de Guardia Civil
```

## ⚙️ Diferencias entre proyectos

Cuando cambias entre proyectos, lo que cambia es:

| Aspecto | Policía Nacional | Guardia Civil |
|---------|------------------|---------------|
| **project_id** | policia_nacional | guardia_civil |
| **Secrets** | policia_nacional.secrets | guardia_civil.secrets |
| **WordPress URL** | (según secrets) | (según secrets) |
| **OpenAI Key** | (según secrets) | (según secrets) |

Las **migraciones y functions son las mismas** para ambos.

## 🎯 Ventajas de este setup

- ✅ **Una sola base de código** (migraciones y functions)
- ✅ **Múltiples configuraciones** (secrets diferentes)
- ✅ **Cambio rápido** entre proyectos con un comando
- ✅ **Mismo flujo** para desarrollo y producción

## 🔄 Flujo: Local → Producción

### 1. Desarrolla en local

```bash
npm run dev:policia
# Desarrolla, prueba, itera
```

### 2. Despliega a producción

```bash
# Configura PROJECT_REF en project-configs/policia_nacional.env
# Luego despliega
npm run deploy:policia
```

### 3. Mismo código, diferentes destinos

Las migraciones y functions que probaste en local se despliegan exactamente igual a producción.

## 📚 Recursos

- **QUICKSTART.md** - Guía rápida de inicio
- **README.md** - Documentación completa
- **MIGRATION_GUIDE.md** - Migración a producción
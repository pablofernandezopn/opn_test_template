#!/bin/bash

# ============================================================================
# SCRIPT DE MIGRACIÓN AUTOMÁTICA DE UN SOLO CLICK
# Migra toda la base de datos remota (Policía Nacional) a la base local
# ============================================================================
#
# USO:
#   ./migrate_one_click.sh                    # Migración completa
#   SKIP_DOWNLOAD=true ./migrate_one_click.sh # Reusar datos ya descargados
#
# DESCRIPCIÓN:
#   1. Extrae datos de Supabase REMOTA (producción)
#   2. Transforma estructura de datos
#   3. Resetea base de datos LOCAL
#   4. Carga datos con optimizaciones (PostgreSQL COPY, triggers desactivados)
#   5. Aplica correcciones post-migración (topic_types, etc.)
#   6. Valida integridad de datos
# ============================================================================

set -e  # Detener en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Rutas
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="/Users/pablofernandezlucas/Documents/Isyfu/opn_test_policia_nacional"
NEW_DB_DIR="$BASE_DIR/nueva_app"
MIGRATION_DIR="$NEW_DB_DIR/supabase/migration_policia_nacional"

# Configuración
SKIP_DOWNLOAD=${SKIP_DOWNLOAD:-false}
DB_URL="postgresql://postgres:postgres@127.0.0.1:54322/postgres"
LOG_FILE="$MIGRATION_DIR/migration_$(date +%Y%m%d_%H%M%S).log"

# ============================================================================
# FUNCIONES AUXILIARES
# ============================================================================

print_header() {
    echo -e "\n${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "\n${MAGENTA}▶ [$1/$2] $3${NC}"
    echo -e "${BLUE}────────────────────────────────────────────────────────────────${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Función para ejecutar comando con logging
run_cmd() {
    echo -e "${BLUE}  → $1${NC}"
    if eval "$1" 2>&1 | tee -a "$LOG_FILE"; then
        return 0
    else
        return 1
    fi
}

# Verificar que Supabase local está corriendo
check_supabase() {
    print_info "Verificando Supabase local..."

    if ! psql "$DB_URL" -c "SELECT 1" &>/dev/null; then
        print_warning "Supabase local no está corriendo. Iniciando..."
        cd "$NEW_DB_DIR"
        supabase start
        sleep 3
    fi

    print_success "Supabase local activo"
}

# Resetear base de datos local
reset_database() {
    print_info "Reseteando base de datos local..."

    cd "$NEW_DB_DIR"

    # Detener Supabase
    supabase stop 2>/dev/null || true

    # Resetear
    supabase db reset --linked=false

    print_success "Base de datos reseteada"
}

# Aplicar correcciones post-migración
apply_post_migration_fixes() {
    print_info "Aplicando correcciones post-migración..."

    # Crear topic_types para isMarkCollection e isEnglish
    psql "$DB_URL" <<EOF
-- Topic type para Plantillas de examen (isMarkCollection)
INSERT INTO topic_type (
    topic_type_name, description, level,
    default_number_options, penalty, time_by_question, order_of_appearance
) VALUES (
    'Plantillas de examen',
    'Plantillas de examen configurables',
    'Mock', 3, 0.50, 0.50, 6
)
ON CONFLICT (topic_type_name) DO NOTHING;

-- Topic type para Inglés (isEnglish)
INSERT INTO topic_type (
    topic_type_name, description, level,
    default_number_options, penalty, time_by_question, order_of_appearance
) VALUES (
    'Inglés',
    'Tests de inglés y gramática',
    'Mock', 3, 0.50, 0.50, 7
)
ON CONFLICT (topic_type_name) DO NOTHING;

-- Actualizar topics con isMarkCollection=true a "Plantillas de examen"
UPDATE topic t
SET topic_type_id = (SELECT id FROM topic_type WHERE topic_type_name = 'Plantillas de examen')
WHERE t.id IN (315, 316, 317, 329, 664, 665, 666, 667);

-- Actualizar topics con isEnglish=true a "Inglés"
UPDATE topic t
SET topic_type_id = (SELECT id FROM topic_type WHERE topic_type_name = 'Inglés')
WHERE t.id IN (108, 111, 120, 121, 125, 128, 129, 134, 137, 320, 321, 323, 324, 325, 607);
EOF

    print_success "Correcciones aplicadas"
}

# Verificar counts finales
verify_data() {
    print_info "Verificando counts de datos..."

    psql "$DB_URL" <<EOF
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
\echo 'RESUMEN DE DATOS MIGRADOS'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

SELECT
    'topic_types' as tabla,
    COUNT(*) as registros
FROM topic_type
UNION ALL
SELECT 'categories', COUNT(*) FROM categories
UNION ALL
SELECT 'topics', COUNT(*) FROM topic
UNION ALL
SELECT 'questions', COUNT(*) FROM questions
UNION ALL
SELECT 'question_options', COUNT(*) FROM question_options
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'user_tests', COUNT(*) FROM user_tests
UNION ALL
SELECT 'user_test_answers', COUNT(*) FROM user_test_answers
UNION ALL
SELECT 'topic_mock_rankings', COUNT(*) FROM topic_mock_rankings
ORDER BY
    CASE tabla
        WHEN 'topic_types' THEN 1
        WHEN 'categories' THEN 2
        WHEN 'topics' THEN 3
        WHEN 'questions' THEN 4
        WHEN 'question_options' THEN 5
        WHEN 'users' THEN 6
        WHEN 'user_tests' THEN 7
        WHEN 'user_test_answers' THEN 8
        WHEN 'topic_mock_rankings' THEN 9
    END;

\echo ''
\echo 'Topic Types creados:'
SELECT id, topic_type_name, level FROM topic_type ORDER BY id;

\echo ''
\echo 'Verificación de Topics especiales:'
SELECT
    tt.topic_type_name,
    COUNT(*) as count
FROM topic t
JOIN topic_type tt ON t.topic_type_id = tt.id
WHERE tt.topic_type_name IN ('Plantillas de examen', 'Inglés')
GROUP BY tt.topic_type_name;
EOF

    print_success "Verificación completada"
}

# ============================================================================
# FLUJO PRINCIPAL
# ============================================================================

main() {
    START_TIME=$(date +%s)

    print_header "🚀 MIGRACIÓN AUTOMÁTICA DE UN SOLO CLICK"
    print_info "Inicio: $(date '+%Y-%m-%d %H:%M:%S')"
    print_info "Log: $LOG_FILE"

    cd "$MIGRATION_DIR"

    # Activar entorno virtual si existe
    if [ -d "venv" ]; then
        source venv/bin/activate
    fi

    TOTAL_STEPS=8
    CURRENT_STEP=0

    # ========================================================================
    # PASO 1: EXTRACCIÓN DE DATOS REMOTOS
    # ========================================================================
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_step $CURRENT_STEP $TOTAL_STEPS "EXTRACCIÓN DE DATOS REMOTOS"

    if [ "$SKIP_DOWNLOAD" = "true" ]; then
        print_warning "Saltando descarga (SKIP_DOWNLOAD=true)"
    else
        print_info "Extrayendo desde Supabase REMOTA (producción)..."

        # Extraer datos principales
        run_cmd "python3 extract/extract_data.py" || {
            print_error "Error en extracción de datos principales"
            exit 1
        }

        # Extraer flashcards
        run_cmd "python3 extract_flashcards.py" || print_warning "Error extrayendo flashcards (continuando...)"

        # Extraer CMS y challenges
        run_cmd "python3 extract_cms_and_challenges.py" || print_warning "Error extrayendo CMS (continuando...)"

        # Extraer academias
        run_cmd "python3 extract_academies.py" || print_warning "Error extrayendo academias (continuando...)"

        # Extraer user_test_answers
        run_cmd "python3 extract_user_test_answers.py" || print_warning "Error extrayendo user_test_answers"

        print_success "Extracción completada"
    fi

    # ========================================================================
    # PASO 2: TRANSFORMACIÓN DE DATOS
    # ========================================================================
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_step $CURRENT_STEP $TOTAL_STEPS "TRANSFORMACIÓN DE DATOS"

    print_info "Transformando estructura de datos..."

    # Transformar datos principales
    run_cmd "python3 transform/transform_data.py" || {
        print_error "Error en transformación de datos principales"
        exit 1
    }

    # Transformar flashcards
    run_cmd "python3 transform_flashcards.py" || print_warning "Error transformando flashcards (continuando...)"

    # Transformar user_tests
    run_cmd "python3 transform_user_tests.py" || print_warning "Error transformando user_tests"

    # Transformar user_test_answers
    run_cmd "python3 transform_user_test_answers.py" || print_warning "Error transformando user_test_answers"

    print_success "Transformación completada"

    # ========================================================================
    # PASO 3: RESET DE BASE DE DATOS LOCAL
    # ========================================================================
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_step $CURRENT_STEP $TOTAL_STEPS "RESET DE BASE DE DATOS LOCAL"

    reset_database

    # ========================================================================
    # PASO 4: VERIFICAR SUPABASE LOCAL
    # ========================================================================
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_step $CURRENT_STEP $TOTAL_STEPS "VERIFICACIÓN DE SUPABASE LOCAL"

    check_supabase

    # ========================================================================
    # PASO 5: CARGA DE DATOS BÁSICOS (OPTIMIZADA)
    # ========================================================================
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_step $CURRENT_STEP $TOTAL_STEPS "CARGA DE DATOS BÁSICOS"

    print_info "Cargando topic_types, categories, topics, questions..."

    run_cmd "python3 load_all_fast.py" || {
        print_error "Error cargando datos básicos"
        exit 1
    }

    print_success "Datos básicos cargados"

    # ========================================================================
    # PASO 6: CARGA DE DATOS DE USUARIOS (ULTRA-OPTIMIZADA)
    # ========================================================================
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_step $CURRENT_STEP $TOTAL_STEPS "CARGA DE DATOS DE USUARIOS"

    print_info "Cargando users, user_tests, user_test_answers..."
    print_warning "Este paso puede tardar varios minutos (~5-10 min)"

    # Cargar usuarios
    run_cmd "python3 load_users.py" || print_warning "Error cargando users (continuando...)"

    # Cargar user_tests y answers con optimización COPY
    run_cmd "python3 load_user_tests_and_answers.py" || {
        print_error "Error cargando user_tests"
        exit 1
    }

    # Usar load_fast.py si existe mapping (para user_test_answers)
    if [ -f "data/transformed/user_test_id_old_to_new.json" ]; then
        print_info "Usando carga ultra-rápida para user_test_answers..."
        run_cmd "python3 load_fast.py" || print_warning "Error en carga rápida de answers"
    fi

    print_success "Datos de usuarios cargados"

    # ========================================================================
    # PASO 7: CARGA DE DATOS ADICIONALES
    # ========================================================================
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_step $CURRENT_STEP $TOTAL_STEPS "CARGA DE DATOS ADICIONALES"

    # Flashcards
    if [ -f "data/transformed/flashcards.json" ]; then
        print_info "Cargando flashcards..."
        run_cmd "python3 load_flashcards.py" || print_warning "Error cargando flashcards (continuando...)"
    fi

    # Academias
    if [ -f "data/transformed/academies.json" ]; then
        print_info "Cargando academias..."
        run_cmd "python3 load_academies.py" || print_warning "Error cargando academias (continuando...)"
    fi

    # Challenges
    if [ -f "data/transformed/challenges.json" ]; then
        print_info "Cargando challenges..."
        run_cmd "python3 load_challenges.py" || print_warning "Error cargando challenges (continuando...)"
    fi

    # CMS users
    if [ -f "data/transformed/cms_users.json" ]; then
        print_info "Cargando usuarios CMS..."
        run_cmd "python3 load_cms_users_with_auth.py" || print_warning "Error cargando CMS users (continuando...)"
    fi

    print_success "Datos adicionales cargados"

    # ========================================================================
    # PASO 8: CORRECCIONES POST-MIGRACIÓN
    # ========================================================================
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_step $CURRENT_STEP $TOTAL_STEPS "CORRECCIONES Y VALIDACIÓN"

    apply_post_migration_fixes

    # ========================================================================
    # VERIFICACIÓN FINAL
    # ========================================================================
    print_header "📊 VERIFICACIÓN FINAL"

    verify_data

    # ========================================================================
    # RESUMEN
    # ========================================================================
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    MINUTES=$((DURATION / 60))
    SECONDS=$((DURATION % 60))

    print_header "✅ MIGRACIÓN COMPLETADA EXITOSAMENTE"

    echo -e "${GREEN}Tiempo total: ${MINUTES}m ${SECONDS}s${NC}"
    echo -e "${BLUE}Log completo: $LOG_FILE${NC}"
    echo -e "${CYAN}Base de datos lista en: postgresql://postgres:postgres@127.0.0.1:54322/postgres${NC}"

    print_info "Puedes ver el log completo en: $LOG_FILE"
    print_info "Conectar a BD: psql \"$DB_URL\""

    echo ""
}

# ============================================================================
# EJECUCIÓN
# ============================================================================

# Trap para capturar errores
trap 'print_error "Migración interrumpida"; exit 1' INT TERM

# Ejecutar migración
main "$@"

exit 0

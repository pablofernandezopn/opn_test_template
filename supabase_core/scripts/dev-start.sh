#!/bin/bash

# Script para iniciar desarrollo local con configuración específica
# Uso: ./scripts/dev-start.sh [policia_nacional|guardia_civil]
# Sin parámetro: usa configuración genérica

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_section() { echo -e "\n${BLUE}========================================${NC}"; echo -e "${BLUE}$1${NC}"; echo -e "${BLUE}========================================${NC}\n"; }

# Proyecto a iniciar (opcional)
PROJECT=${1:-""}

# Detener cualquier proyecto corriendo
log_info "Deteniendo proyectos Supabase existentes..."
supabase stop --all 2>/dev/null || true

if [ -z "$PROJECT" ]; then
    # Modo genérico (sin proyecto específico)
    log_section "Iniciando Supabase Core (genérico)"

    log_info "Configuración: Genérica"
    log_info "Puerto API: 54321"
    log_info "Puerto DB: 54322"
    log_info "Puerto Studio: 54323"

    supabase start

else
    # Modo específico para proyecto
    log_section "Iniciando Supabase Core - $PROJECT"

    # Verificar que existe el archivo de configuración
    ENV_FILE="project-configs/${PROJECT}.env"
    SECRETS_FILE="project-configs/${PROJECT}.secrets"

    if [ ! -f "$ENV_FILE" ]; then
        log_error "No existe el archivo de configuración: $ENV_FILE"
        echo ""
        echo "Proyectos disponibles:"
        ls -1 project-configs/*.env 2>/dev/null | xargs -n 1 basename | sed 's/.env$//' || echo "  (ninguno)"
        exit 1
    fi

    # Cargar configuración
    source "$ENV_FILE"

    log_info "Proyecto: $PROJECT"
    log_info "Puerto API: 54321"
    log_info "Puerto DB: 54322"
    log_info "Puerto Studio: 54323"

    # Crear .env temporal con las variables del proyecto
    if [ -f "$SECRETS_FILE" ]; then
        log_info "Cargando secrets desde $SECRETS_FILE..."
        cp "$SECRETS_FILE" .env
    else
        log_warning "No se encontró $SECRETS_FILE, usando .env genérico"
        if [ -f ".env" ]; then
            log_info "Usando .env existente"
        else
            log_warning "No hay archivo .env, las edge functions no tendrán secrets"
        fi
    fi

    # Actualizar project_id en config.toml
    log_info "Configurando project_id en config.toml..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/^project_id = .*/project_id = \"$PROJECT\"/" config.toml
    else
        # Linux
        sed -i "s/^project_id = .*/project_id = \"$PROJECT\"/" config.toml
    fi

    supabase start
fi

log_section "✅ Supabase iniciado exitosamente"

echo "📊 URLs disponibles:"
echo ""
supabase status | grep -E "URL|key"
echo ""
echo "💡 Tips:"
echo "  - Abre Studio: http://127.0.0.1:54323"
echo "  - Ver status: npm run dev:status"
echo "  - Detener: npm run dev:stop"
echo "  - Resetear DB: npm run dev:reset"
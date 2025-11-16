#!/bin/bash

# Script para cambiar entre proyectos rápidamente
# Uso: ./scripts/dev-switch.sh [policia_nacional|guardia_civil]

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_section() { echo -e "\n${BLUE}========================================${NC}"; echo -e "${BLUE}$1${NC}"; echo -e "${BLUE}========================================${NC}\n"; }

PROJECT=$1

if [ -z "$PROJECT" ]; then
    echo "Uso: ./scripts/dev-switch.sh [policia_nacional|guardia_civil]"
    echo ""
    echo "Proyectos disponibles:"
    ls -1 project-configs/*.env 2>/dev/null | xargs -n 1 basename | sed 's/.env$//'
    exit 1
fi

log_section "Cambiando a proyecto: $PROJECT"

# Detener proyecto actual
log_info "Deteniendo proyecto actual..."
supabase stop 2>/dev/null || true

# Iniciar nuevo proyecto
log_info "Iniciando $PROJECT..."
./scripts/dev-start.sh "$PROJECT"

log_section "✅ Cambiado a $PROJECT exitosamente"
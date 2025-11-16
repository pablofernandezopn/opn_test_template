#!/bin/bash

# Script para desplegar a TODOS los proyectos configurados
# Uso: ./scripts/deploy-all.sh

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_section() { echo -e "\n${BLUE}========================================${NC}"; echo -e "${BLUE}$1${NC}"; echo -e "${BLUE}========================================${NC}\n"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_CONFIGS_DIR="$SCRIPT_DIR/../project-configs"

# Obtener todos los proyectos
PROJECTS=$(ls -1 "$PROJECT_CONFIGS_DIR"/*.env | xargs -n 1 basename | sed 's/.env$//')

log_section "Desplegando a todos los proyectos"

for PROJECT in $PROJECTS; do
    log_section "Desplegando a $PROJECT"
    "$SCRIPT_DIR/deploy.sh" "$PROJECT"
done

log_section "✅ Todos los despliegues completados"
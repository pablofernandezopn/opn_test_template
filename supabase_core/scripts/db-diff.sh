#!/bin/bash

# Script para comparar base de datos remota vs migraciones locales
# Uso: ./scripts/db-diff.sh policia_nacional

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

if [ -z "$1" ]; then
    log_error "Debes especificar un proyecto"
    echo "Uso: ./scripts/db-diff.sh <proyecto>"
    exit 1
fi

PROJECT=$1
CONFIG_FILE="project-configs/${PROJECT}.env"

if [ ! -f "$CONFIG_FILE" ]; then
    log_error "No existe el archivo de configuración: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

log_info "Comparando base de datos remota de $PROJECT_NAME..."
log_warning "Esto te mostrará las diferencias entre tu DB remota y las migraciones locales"

supabase link --project-ref "$PROJECT_REF"
supabase db diff --use-migra

log_info "Si hay diferencias, considera crear una nueva migración:"
echo "npm run new:migration nombre_de_cambios"
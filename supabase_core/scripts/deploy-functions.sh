#!/bin/bash

# Script para desplegar SOLO edge functions a un proyecto
# Uso: ./scripts/deploy-functions.sh policia_nacional

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

if [ -z "$1" ]; then
    log_error "Debes especificar un proyecto"
    exit 1
fi

PROJECT=$1
CONFIG_FILE="project-configs/${PROJECT}.env"

if [ ! -f "$CONFIG_FILE" ]; then
    log_error "No existe el archivo de configuración: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

log_info "Desplegando SOLO functions a $PROJECT_NAME..."
supabase link --project-ref "$PROJECT_REF"
supabase functions deploy --no-verify-jwt

log_info "✅ Functions desplegadas exitosamente"
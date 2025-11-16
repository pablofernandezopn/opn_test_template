#!/bin/bash

# Script para desplegar migraciones y functions a un proyecto específico
# Uso: ./scripts/deploy.sh policia_nacional
# O: ./scripts/deploy.sh guardia_civil

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Validar argumentos
if [ -z "$1" ]; then
    log_error "Debes especificar un proyecto: policia_nacional o guardia_civil"
    echo "Uso: ./scripts/deploy.sh <proyecto>"
    echo "Proyectos disponibles:"
    ls -1 project-configs/*.env | xargs -n 1 basename | sed 's/.env$//'
    exit 1
fi

PROJECT=$1
CONFIG_FILE="project-configs/${PROJECT}.env"

# Verificar que existe el archivo de configuración
if [ ! -f "$CONFIG_FILE" ]; then
    log_error "No existe el archivo de configuración: $CONFIG_FILE"
    exit 1
fi

# Cargar configuración
log_info "Cargando configuración de $PROJECT..."
source "$CONFIG_FILE"

# Verificar que PROJECT_REF está configurado
if [ "$PROJECT_REF" = "your-${PROJECT}-project-ref" ]; then
    log_error "Debes configurar PROJECT_REF en $CONFIG_FILE"
    exit 1
fi

log_info "Proyecto: $PROJECT_NAME"
log_info "Project REF: $PROJECT_REF"

# Linkear al proyecto
log_info "Linkeando al proyecto $PROJECT_REF..."
supabase link --project-ref "$PROJECT_REF"

# Desplegar migraciones
log_info "Desplegando migraciones..."
supabase db push

# Desplegar functions
log_info "Desplegando edge functions..."
supabase functions deploy --no-verify-jwt

log_info "✅ Despliegue completado exitosamente para $PROJECT_NAME"
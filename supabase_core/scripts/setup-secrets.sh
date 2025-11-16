#!/bin/bash

# Script para configurar secrets en un proyecto de Supabase
# Uso: ./scripts/setup-secrets.sh policia_nacional

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_section() { echo -e "\n${BLUE}========================================${NC}"; echo -e "${BLUE}$1${NC}"; echo -e "${BLUE}========================================${NC}\n"; }

if [ -z "$1" ]; then
    log_error "Debes especificar un proyecto"
    echo "Uso: ./scripts/setup-secrets.sh <proyecto>"
    echo ""
    echo "Proyectos disponibles:"
    ls -1 project-configs/*.secrets 2>/dev/null | xargs -n 1 basename | sed 's/.secrets$//' || echo "  (ninguno encontrado)"
    exit 1
fi

PROJECT=$1
CONFIG_FILE="project-configs/${PROJECT}.env"
SECRETS_FILE="project-configs/${PROJECT}.secrets"

# Verificar archivos
if [ ! -f "$CONFIG_FILE" ]; then
    log_error "No existe el archivo de configuración: $CONFIG_FILE"
    exit 1
fi

if [ ! -f "$SECRETS_FILE" ]; then
    log_error "No existe el archivo de secrets: $SECRETS_FILE"
    log_info "Crea uno basado en .secrets.example"
    exit 1
fi

# Cargar configuración
source "$CONFIG_FILE"

if [ "$PROJECT_REF" = "your-${PROJECT}-project-ref" ] || [ -z "$PROJECT_REF" ]; then
    log_error "Debes configurar PROJECT_REF en $CONFIG_FILE primero"
    exit 1
fi

log_section "Configurando secrets para $PROJECT_NAME"

# Linkear al proyecto
log_info "Linkeando al proyecto $PROJECT_REF..."
supabase link --project-ref "$PROJECT_REF"

# Leer secrets del archivo y configurarlos
log_info "Leyendo secrets de $SECRETS_FILE..."

while IFS='=' read -r key value; do
    # Ignorar comentarios y líneas vacías
    [[ "$key" =~ ^#.*$ ]] && continue
    [[ -z "$key" ]] && continue

    # Eliminar espacios
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)

    # Verificar que el valor no esté vacío
    if [ -z "$value" ]; then
        log_warning "⚠️  $key está vacío, omitiendo..."
        continue
    fi

    # Configurar secret
    log_info "Configurando $key..."
    echo "$value" | supabase secrets set "$key" --env-file /dev/stdin

done < "$SECRETS_FILE"

log_section "✅ Secrets configurados exitosamente"

echo "Para verificar los secrets configurados:"
echo "  supabase secrets list --linked"
echo ""
echo "Para actualizar un secret individual:"
echo "  supabase secrets set MI_SECRET=valor --linked"
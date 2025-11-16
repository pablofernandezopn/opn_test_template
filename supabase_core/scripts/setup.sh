#!/bin/bash

# Script de configuración inicial
# Uso: ./scripts/setup.sh

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_section() { echo -e "\n${BLUE}========================================${NC}"; echo -e "${BLUE}$1${NC}"; echo -e "${BLUE}========================================${NC}\n"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

log_section "Configuración Inicial de Supabase Core"

# Verificar que supabase CLI está instalado
if ! command -v supabase &> /dev/null; then
    log_warning "Supabase CLI no está instalado"
    echo "Instalar con: brew install supabase/tap/supabase"
    exit 1
fi

log_info "✓ Supabase CLI instalado: $(supabase --version)"

# Verificar archivos de configuración
log_section "Verificando Configuraciones de Proyectos"

for config_file in project-configs/*.env; do
    if [ "$config_file" = "project-configs/.env.example" ]; then
        continue
    fi

    project_name=$(basename "$config_file" .env)

    # Leer PROJECT_REF del archivo
    project_ref=$(grep PROJECT_REF "$config_file" | cut -d'=' -f2 | tr -d '"')

    if [ "$project_ref" = "your-${project_name}-project-ref" ] || [ -z "$project_ref" ]; then
        log_warning "⚠ $project_name.env necesita configuración"
    else
        log_info "✓ $project_name.env configurado"
    fi
done

log_section "Próximos pasos"

echo "1. Configura tus proyectos en project-configs/*.env"
echo "   - Edita policia_nacional.env con tu PROJECT_REF"
echo "   - Edita guardia_civil.env con tu PROJECT_REF"
echo ""
echo "2. Despliega a tus proyectos:"
echo "   npm run deploy:policia"
echo "   npm run deploy:guardia"
echo "   npm run deploy:all"
echo ""
echo "3. Para crear nueva migración:"
echo "   npm run new:migration nombre_de_tu_migracion"
echo ""

log_info "Setup completado. Lee README.md para más información."
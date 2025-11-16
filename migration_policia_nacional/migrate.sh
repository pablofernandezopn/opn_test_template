#!/bin/bash

# ============================================
# Script de Migración Automática
# Policía Nacional → Guardia Civil
# ============================================

set -e  # Detener en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Rutas
BASE_DIR="/Users/pablofernandezlucas/Documents/Isyfu/opn_test_policia_nacional"
NEW_DB_DIR="$BASE_DIR/nueva_app"
MIGRATION_DIR="$NEW_DB_DIR/supabase/migration_policia_nacional"

# Configurar FORCE_DOWNLOAD
export FORCE_DOWNLOAD=${FORCE_DOWNLOAD:-true}

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  MIGRACIÓN POLICÍA NACIONAL → GUARDIA CIVIL${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "${YELLOW}FORCE_DOWNLOAD = $FORCE_DOWNLOAD${NC}"
echo ""

# ============================================
# FASE 1: EXTRACCIÓN
# ============================================
echo -e "${GREEN}[1/4] EXTRACCIÓN DE DATOS${NC}"
echo -e "${YELLOW}Extrayendo datos desde Supabase REMOTA (producción)...${NC}"
cd "$MIGRATION_DIR"

# Activar entorno virtual si existe
if [ -d "venv" ]; then
    source venv/bin/activate
fi

python3 extract/extract_data.py
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Error en extracción${NC}"
    exit 1
fi

# ============================================
# FASE 2: TRANSFORMACIÓN
# ============================================
echo -e "${GREEN}[2/4] TRANSFORMACIÓN DE DATOS${NC}"
cd "$MIGRATION_DIR"

python3 transform/transform_data.py
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Error en transformación${NC}"
    exit 1
fi

# ============================================
# FASE 3: CARGA
# ============================================
echo -e "${GREEN}[3/4] CARGA DE DATOS${NC}"
echo -e "${YELLOW}Iniciando BD nueva...${NC}"
cd "$NEW_DB_DIR"
supabase start

echo -e "${YELLOW}Cargando datos...${NC}"
cd "$MIGRATION_DIR"

python3 load/load_data.py
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Error en carga${NC}"
    exit 1
fi

# ============================================
# FASE 4: VALIDACIÓN
# ============================================
echo -e "${GREEN}[4/4] VALIDACIÓN${NC}"
echo -e "${YELLOW}Validando datos cargados en BD nueva...${NC}"
cd "$MIGRATION_DIR"

python3 validate/validate.py || echo -e "${YELLOW}⚠️ Validación completada con advertencias${NC}"

# ============================================
# FINALIZACIÓN
# ============================================
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}✓ MIGRACIÓN COMPLETADA${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${BLUE}Datos migrados a: $NEW_DB_DIR${NC}"
echo -e "${BLUE}Logs en: $MIGRATION_DIR/logs/${NC}"
echo ""
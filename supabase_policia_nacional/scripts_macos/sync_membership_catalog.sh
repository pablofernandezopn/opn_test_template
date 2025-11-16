#!/bin/bash

# ========================================================================
# Script: Sincronización de Catálogo de Membresías
# Descripción: Sincroniza los niveles de membresía desde WordPress RCP a Supabase
# ========================================================================

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuración
SUPABASE_URL="http://127.0.0.1:54321"
ENDPOINT="${SUPABASE_URL}/functions/v1/login-register/v1/sync_membership_catalog"
LOG_DIR="/tmp/supabase_sync_logs"
LOG_FILE="${LOG_DIR}/sync_catalog_$(date +%Y%m%d_%H%M%S).log"

# Crear directorio de logs si no existe
mkdir -p "${LOG_DIR}"

echo -e "${BLUE}========================================================================${NC}"
echo -e "${BLUE}  🔄 SINCRONIZACIÓN DE CATÁLOGO DE MEMBRESÍAS${NC}"
echo -e "${BLUE}========================================================================${NC}"
echo ""

# Verificar que Supabase esté corriendo
echo -e "${YELLOW}🔍 Verificando que Supabase esté corriendo...${NC}"

# Intentar varias veces con retries
MAX_RETRIES=3
RETRY_COUNT=0
SUPABASE_RUNNING=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if curl -s "${SUPABASE_URL}/functions/v1/login-register/v1/version" > /dev/null 2>&1; then
    SUPABASE_RUNNING=true
    break
  fi
  RETRY_COUNT=$((RETRY_COUNT + 1))
  if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
    echo -e "${YELLOW}   Reintentando (${RETRY_COUNT}/${MAX_RETRIES})...${NC}"
    sleep 2
  fi
done

if [ "$SUPABASE_RUNNING" = false ]; then
  echo -e "${RED}❌ Error: Supabase no está corriendo en ${SUPABASE_URL}${NC}"
  echo -e "${YELLOW}   Ejecuta: supabase start${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Supabase está corriendo${NC}"
echo ""

# Ejecutar sincronización
echo -e "${YELLOW}📡 Llamando al endpoint de sincronización...${NC}"
echo -e "${BLUE}   Endpoint: ${ENDPOINT}${NC}"
echo ""

HTTP_CODE=$(curl -s -X POST "${ENDPOINT}" \
  -H "Content-Type: application/json" \
  -d '{}' \
  -o /tmp/sync_response.json \
  -w "%{http_code}")

HTTP_BODY=$(cat /tmp/sync_response.json)

# Guardar en log
echo "=== Sincronización $(date) ===" >> "${LOG_FILE}"
echo "HTTP Code: ${HTTP_CODE}" >> "${LOG_FILE}"
echo "Response: ${HTTP_BODY}" >> "${LOG_FILE}"
echo "" >> "${LOG_FILE}"

# Verificar respuesta
if [ "$HTTP_CODE" -eq 200 ]; then
  echo -e "${GREEN}✅ Sincronización exitosa!${NC}"
  echo ""
  
  # Mostrar resultado formateado si jq está disponible
  if command -v jq &> /dev/null; then
    echo -e "${BLUE}📊 Resultado:${NC}"
    echo "$HTTP_BODY" | jq '.'
    echo ""
    
    # Mostrar estadísticas
    CREATED=$(echo "$HTTP_BODY" | jq -r '.stats.created // 0')
    UPDATED=$(echo "$HTTP_BODY" | jq -r '.stats.updated // 0')
    ERRORS=$(echo "$HTTP_BODY" | jq -r '.stats.errors // 0')
    TOTAL=$(echo "$HTTP_BODY" | jq -r '.stats.total // 0')
    
    echo -e "${BLUE}📈 Estadísticas:${NC}"
    echo -e "   ${GREEN}✓ Creados:      ${CREATED}${NC}"
    echo -e "   ${BLUE}↻ Actualizados: ${UPDATED}${NC}"
    echo -e "   ${RED}✗ Errores:      ${ERRORS}${NC}"
    echo -e "   ${YELLOW}Σ Total:        ${TOTAL}${NC}"
  else
    echo "$HTTP_BODY"
    echo ""
    echo -e "${YELLOW}💡 Instala 'jq' para ver el resultado formateado: brew install jq${NC}"
  fi
else
  echo -e "${RED}❌ Error en la sincronización (HTTP ${HTTP_CODE})${NC}"
  echo ""
  echo -e "${RED}Respuesta:${NC}"
  echo "$HTTP_BODY"
  echo ""
  exit 1
fi

echo ""
echo -e "${BLUE}📝 Log guardado en: ${LOG_FILE}${NC}"
echo ""
echo -e "${BLUE}========================================================================${NC}"
echo -e "${GREEN}✅ Proceso completado${NC}"
echo -e "${BLUE}========================================================================${NC}"

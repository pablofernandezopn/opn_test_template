#!/bin/bash

# ========================================================================
# Script: Despliegue Local de Supabase
# Descripción: Inicia y configura Supabase en modo desarrollo local
# ========================================================================

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuración
SUPABASE_DIR="/Users/pablofernandezlucas/Documents/Isyfu/opn_guardia_civil/supabase"
LOG_FILE="/tmp/supabase_deploy_$(date +%Y%m%d_%H%M%S).log"

echo -e "${BLUE}========================================================================${NC}"
echo -e "${BLUE}  🚀 DESPLIEGUE LOCAL DE SUPABASE${NC}"
echo -e "${BLUE}========================================================================${NC}"
echo ""

# Cambiar al directorio del proyecto
cd "${SUPABASE_DIR}" || {
  echo -e "${RED}❌ Error: No se pudo acceder al directorio ${SUPABASE_DIR}${NC}"
  exit 1
}

# Verificar que exista el archivo .env
echo -e "${YELLOW}🔍 Verificando configuración...${NC}"
if [ ! -f "functions/.env" ]; then
  echo -e "${RED}❌ Error: No se encontró el archivo functions/.env${NC}"
  echo -e "${YELLOW}   Copia functions/.env.example a functions/.env y configura los valores${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Archivo .env encontrado${NC}"

# Verificar variables de entorno requeridas
echo -e "${YELLOW}🔐 Verificando variables de entorno...${NC}"
REQUIRED_VARS=("WP_URL" "WP_ADMIN_USERNAME" "WP_ADMIN_PASSWORD")
MISSING_VARS=()

while IFS= read -r line; do
  # Ignorar líneas vacías y comentarios
  if [[ ! "$line" =~ ^# ]] && [[ -n "$line" ]]; then
    VAR_NAME=$(echo "$line" | cut -d'=' -f1)
    VAR_VALUE=$(echo "$line" | cut -d'=' -f2-)
    
    # Verificar si es una variable requerida y está vacía
    for required in "${REQUIRED_VARS[@]}"; do
      if [[ "$VAR_NAME" == "$required" ]] && [[ -z "$VAR_VALUE" || "$VAR_VALUE" == "your-"* ]]; then
        MISSING_VARS+=("$VAR_NAME")
      fi
    done
  fi
done < "functions/.env"

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
  echo -e "${RED}❌ Las siguientes variables requeridas no están configuradas:${NC}"
  for var in "${MISSING_VARS[@]}"; do
    echo -e "   ${RED}✗ ${var}${NC}"
  done
  echo ""
  echo -e "${YELLOW}   Configura estas variables en functions/.env${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Variables de entorno configuradas${NC}"
echo ""

# Detener Supabase si ya está corriendo
echo -e "${YELLOW}🛑 Deteniendo instancia existente (si existe)...${NC}"
supabase stop > /dev/null 2>&1
echo -e "${GREEN}✅ Instancia detenida${NC}"
echo ""

# Iniciar Supabase
echo -e "${YELLOW}🚀 Iniciando Supabase...${NC}"
echo -e "${CYAN}   (Esto puede tardar unos segundos)${NC}"
echo ""

if supabase start 2>&1 | tee -a "${LOG_FILE}"; then
  echo ""
  echo -e "${GREEN}✅ Supabase iniciado correctamente!${NC}"
else
  echo ""
  echo -e "${RED}❌ Error al iniciar Supabase${NC}"
  echo -e "${YELLOW}   Ver log completo en: ${LOG_FILE}${NC}"
  exit 1
fi

echo ""
echo -e "${BLUE}========================================================================${NC}"
echo -e "${GREEN}  ✅ DESPLIEGUE COMPLETADO${NC}"
echo -e "${BLUE}========================================================================${NC}"
echo ""

# Obtener información de conexión
API_URL=$(grep "API URL:" "${LOG_FILE}" | tail -1 | awk '{print $NF}')
DB_URL=$(grep "Database URL:" "${LOG_FILE}" | tail -1 | awk '{print $NF}')
STUDIO_URL=$(grep "Studio URL:" "${LOG_FILE}" | tail -1 | awk '{print $NF}')

echo -e "${CYAN}📍 URLs de acceso:${NC}"
echo -e "   ${GREEN}API:${NC}      ${API_URL}"
echo -e "   ${GREEN}Database:${NC} ${DB_URL}"
echo -e "   ${GREEN}Studio:${NC}   ${STUDIO_URL}"
echo ""

echo -e "${CYAN}🔧 Comandos útiles:${NC}"
echo -e "   ${YELLOW}Ver logs:${NC}            supabase functions logs"
echo -e "   ${YELLOW}Detener:${NC}             supabase stop"
echo -e "   ${YELLOW}Reiniciar:${NC}           supabase stop && supabase start"
echo -e "   ${YELLOW}Ver estado:${NC}          docker ps | grep supabase"
echo ""

echo -e "${CYAN}📡 Endpoints disponibles:${NC}"
echo -e "   ${BLUE}Login:${NC}               POST ${API_URL}/functions/v1/login-register/v1/login"
echo -e "   ${BLUE}Register:${NC}            POST ${API_URL}/functions/v1/login-register/v1/register"
echo -e "   ${BLUE}Sync Memberships:${NC}    POST ${API_URL}/functions/v1/login-register/v1/sync_memberships"
echo -e "   ${BLUE}Sync Catalog:${NC}        POST ${API_URL}/functions/v1/login-register/v1/sync_membership_catalog"
echo ""

echo -e "${CYAN}🧪 Probar sincronización del catálogo:${NC}"
echo -e "   ${YELLOW}./scripts_macos/sync_membership_catalog.sh${NC}"
echo ""

echo -e "${BLUE}========================================================================${NC}"
echo -e "${GREEN}🎉 ¡Listo para desarrollar!${NC}"
echo -e "${BLUE}========================================================================${NC}"

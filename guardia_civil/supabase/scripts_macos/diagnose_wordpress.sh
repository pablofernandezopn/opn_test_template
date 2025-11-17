#!/bin/bash

# Script de diagnóstico para problemas de conexión con WordPress

echo "🔍 Diagnóstico de Conexión con WordPress"
echo "========================================"
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. Verificar variables de entorno
echo "1️⃣  Verificando variables de entorno..."
ENV_FILE="./functions/login-register/.env"

if [ -f "$ENV_FILE" ]; then
  echo -e "${GREEN}✓${NC} Archivo .env encontrado"
  
  # Extraer WP_URL
  WP_URL=$(grep "^WP_URL=" "$ENV_FILE" | cut -d '=' -f2- | tr -d '"' | tr -d "'" | xargs)
  WP_ADMIN_USERNAME=$(grep "^WP_ADMIN_USERNAME=" "$ENV_FILE" | cut -d '=' -f2- | tr -d '"' | tr -d "'" | xargs)
  
  if [ -z "$WP_URL" ]; then
    WP_URL=$(grep "^WP_APP_URL=" "$ENV_FILE" | cut -d '=' -f2- | tr -d '"' | tr -d "'" | xargs)
  fi
  
  if [ -z "$WP_ADMIN_USERNAME" ]; then
    WP_ADMIN_USERNAME=$(grep "^WP_APP_USERNAME=" "$ENV_FILE" | cut -d '=' -f2- | tr -d '"' | tr -d "'" | xargs)
  fi
  
  if [ -n "$WP_URL" ]; then
    echo -e "  ${GREEN}✓${NC} WP_URL: $WP_URL"
  else
    echo -e "  ${RED}✗${NC} WP_URL no configurada"
  fi
  
  if [ -n "$WP_ADMIN_USERNAME" ]; then
    echo -e "  ${GREEN}✓${NC} WP_ADMIN_USERNAME: $WP_ADMIN_USERNAME"
  else
    echo -e "  ${RED}✗${NC} WP_ADMIN_USERNAME no configurada"
  fi
  
  if grep -q "^WP_ADMIN_PASSWORD=" "$ENV_FILE" || grep -q "^WP_APP_PASS=" "$ENV_FILE"; then
    echo -e "  ${GREEN}✓${NC} WP_ADMIN_PASSWORD: configurada"
  else
    echo -e "  ${RED}✗${NC} WP_ADMIN_PASSWORD no configurada"
  fi
else
  echo -e "${RED}✗${NC} Archivo .env NO encontrado en ./functions/login-register/"
  echo "  Copia .env.example a .env y configura las variables"
  WP_URL=""
fi

echo ""

# 2. Verificar resolución DNS
if [ -n "$WP_URL" ]; then
  echo "2️⃣  Verificando resolución DNS..."
  DOMAIN=$(echo "$WP_URL" | sed -E 's|https?://||' | cut -d'/' -f1)
  
  if host "$DOMAIN" > /dev/null 2>&1; then
    IP=$(host "$DOMAIN" | grep "has address" | head -1 | awk '{print $4}')
    echo -e "${GREEN}✓${NC} DNS resuelve correctamente: $DOMAIN → $IP"
  else
    echo -e "${RED}✗${NC} No se puede resolver DNS para: $DOMAIN"
    echo "  Verifica tu conexión a internet"
  fi
else
  echo "2️⃣  ${YELLOW}⚠${NC}  Saltando verificación DNS (WP_URL no configurada)"
fi

echo ""

# 3. Verificar conectividad HTTP
if [ -n "$WP_URL" ]; then
  echo "3️⃣  Verificando conectividad HTTP..."
  
  # Quitar barra final si existe
  WP_URL_CLEAN="${WP_URL%/}"
  
  echo "  Probando: $WP_URL_CLEAN/wp-json/"
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "$WP_URL_CLEAN/wp-json/" 2>/dev/null)
  
  if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓${NC} WordPress REST API responde correctamente (HTTP $HTTP_CODE)"
  elif [ "$HTTP_CODE" = "000" ]; then
    echo -e "${RED}✗${NC} No se puede conectar (timeout o error de red)"
    echo "  El servidor podría estar caído o bloqueando la conexión"
  else
    echo -e "${YELLOW}⚠${NC}  WordPress responde pero con código HTTP $HTTP_CODE"
  fi
else
  echo "3️⃣  ${YELLOW}⚠${NC}  Saltando verificación HTTP (WP_URL no configurada)"
fi

echo ""

# 4. Verificar endpoint de autenticación JWT
if [ -n "$WP_URL" ]; then
  echo "4️⃣  Verificando endpoint de autenticación JWT..."
  
  WP_URL_CLEAN="${WP_URL%/}"
  JWT_URL="$WP_URL_CLEAN/wp-json/jwt-auth/v1/token"
  
  echo "  Probando: $JWT_URL"
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "$JWT_URL" 2>/dev/null)
  
  if [ "$HTTP_CODE" = "400" ] || [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓${NC} Endpoint JWT existe (HTTP $HTTP_CODE)"
    echo "  Nota: 400/401 es normal sin credenciales"
  elif [ "$HTTP_CODE" = "404" ]; then
    echo -e "${RED}✗${NC} Plugin JWT no encontrado (HTTP 404)"
    echo "  Instala el plugin 'JWT Authentication for WP REST API'"
  elif [ "$HTTP_CODE" = "000" ]; then
    echo -e "${RED}✗${NC} No se puede conectar (timeout)"
  else
    echo -e "${YELLOW}⚠${NC}  Respuesta inesperada: HTTP $HTTP_CODE"
  fi
else
  echo "4️⃣  ${YELLOW}⚠${NC}  Saltando verificación JWT (WP_URL no configurada)"
fi

echo ""

# 5. Verificar endpoint de RCP
if [ -n "$WP_URL" ]; then
  echo "5️⃣  Verificando endpoint de RCP (membresías)..."
  
  WP_URL_CLEAN="${WP_URL%/}"
  RCP_URL="$WP_URL_CLEAN/wp-json/rcp/v1/membership-levels"
  
  echo "  Probando: $RCP_URL"
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "$RCP_URL" 2>/dev/null)
  
  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "401" ]; then
    echo -e "${GREEN}✓${NC} Endpoint RCP existe (HTTP $HTTP_CODE)"
  elif [ "$HTTP_CODE" = "404" ]; then
    echo -e "${RED}✗${NC} Plugin RCP no encontrado (HTTP 404)"
    echo "  Instala el plugin 'rcp-custom-rest-api'"
  elif [ "$HTTP_CODE" = "000" ]; then
    echo -e "${RED}✗${NC} No se puede conectar (timeout)"
  else
    echo -e "${YELLOW}⚠${NC}  Respuesta inesperada: HTTP $HTTP_CODE"
  fi
else
  echo "5️⃣  ${YELLOW}⚠${NC}  Saltando verificación RCP (WP_URL no configurada)"
fi

echo ""

# 6. Verificar si Supabase está corriendo
echo "6️⃣  Verificando Supabase local..."

if curl -s http://127.0.0.1:54321/functions/v1/login-register > /dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Supabase local está corriendo"
else
  echo -e "${YELLOW}⚠${NC}  Supabase local no está corriendo"
  echo "  Ejecuta: supabase start"
fi

echo ""

# Resumen
echo "📋 Resumen"
echo "=========="

if [ -z "$WP_URL" ]; then
  echo -e "${RED}❌ ERROR CRÍTICO:${NC} Variables de entorno no configuradas"
  echo ""
  echo "Solución:"
  echo "  1. cd supabase/functions/login-register"
  echo "  2. cp .env.example .env"
  echo "  3. Edita .env con tus credenciales de WordPress"
  exit 1
elif [ "$HTTP_CODE" = "000" ]; then
  echo -e "${RED}❌ ERROR CRÍTICO:${NC} No se puede conectar a WordPress"
  echo ""
  echo "Posibles causas:"
  echo "  - El servidor WordPress está caído"
  echo "  - Problemas de red o firewall"
  echo "  - La URL en WP_URL es incorrecta"
  echo ""
  echo "Solución:"
  echo "  1. Verifica que WordPress está online: $WP_URL"
  echo "  2. Prueba desde el navegador"
  echo "  3. Contacta con el administrador del servidor"
  exit 1
else
  echo -e "${GREEN}✅ Configuración correcta${NC}"
  echo ""
  echo "Siguiente paso:"
  echo "  - Prueba el login desde la app"
  echo "  - Revisa los logs: supabase functions serve --debug"
fi

echo ""

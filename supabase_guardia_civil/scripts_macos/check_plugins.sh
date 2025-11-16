#!/bin/bash

# Script para verificar que los plugins están instalados correctamente

echo "🔍 Verificación Rápida de Plugins de WordPress"
echo "=============================================="
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

WP_URL="https://oposicionesguardiacivil.online"

echo "📍 URL WordPress: $WP_URL"
echo ""

# Verificar JWT
echo -n "🔐 Plugin JWT Authentication... "
JWT_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "$WP_URL/wp-json/jwt-auth/v1/token" 2>/dev/null)

if [ "$JWT_CODE" = "400" ] || [ "$JWT_CODE" = "401" ] || [ "$JWT_CODE" = "200" ]; then
  echo -e "${GREEN}✅ INSTALADO${NC} (HTTP $JWT_CODE)"
elif [ "$JWT_CODE" = "404" ]; then
  echo -e "${RED}❌ NO INSTALADO${NC} (HTTP 404)"
  echo "   Acción: Instalar 'JWT Authentication for WP REST API'"
else
  echo -e "${YELLOW}⚠️  ESTADO DESCONOCIDO${NC} (HTTP $JWT_CODE)"
fi

# Verificar RCP
echo -n "👥 Plugin RCP Custom API... "
RCP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "$WP_URL/wp-json/rcp/v1/membership-levels" 2>/dev/null)

if [ "$RCP_CODE" = "200" ] || [ "$RCP_CODE" = "401" ]; then
  echo -e "${GREEN}✅ INSTALADO${NC} (HTTP $RCP_CODE)"
elif [ "$RCP_CODE" = "404" ]; then
  echo -e "${RED}❌ NO INSTALADO${NC} (HTTP 404)"
  echo "   Acción: Subir y activar 'rcp-custom-rest-api.zip'"
else
  echo -e "${YELLOW}⚠️  ESTADO DESCONOCIDO${NC} (HTTP $RCP_CODE)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Resultado
if [ "$JWT_CODE" = "400" ] || [ "$JWT_CODE" = "401" ] || [ "$JWT_CODE" = "200" ]; then
  if [ "$RCP_CODE" = "200" ] || [ "$RCP_CODE" = "401" ]; then
    echo -e "${GREEN}✅ TODOS LOS PLUGINS INSTALADOS${NC}"
    echo ""
    echo "🎉 ¡Sistema listo para usar!"
    echo ""
    echo "Próximo paso:"
    echo "  1. Reinicia Supabase si no lo has hecho: ./scripts_macos/restart_supabase.sh"
    echo "  2. Prueba el login desde la app"
    echo "  3. Verifica logs: supabase functions serve login-register --debug"
  else
    echo -e "${YELLOW}⚠️  FALTA INSTALAR PLUGIN RCP${NC}"
    echo ""
    echo "Instalación:"
    echo "  1. Ir a: $WP_URL/wp-admin/plugins.php"
    echo "  2. Plugins → Añadir nuevo → Subir plugin"
    echo "  3. Subir: wordpress_plugin/rcp-custom-rest-api.zip"
    echo "  4. Activar el plugin"
    echo "  5. Ejecutar este script nuevamente"
  fi
else
  if [ "$RCP_CODE" = "200" ] || [ "$RCP_CODE" = "401" ]; then
    echo -e "${YELLOW}⚠️  FALTA INSTALAR PLUGIN JWT${NC}"
    echo ""
    echo "Instalación:"
    echo "  1. Ir a: $WP_URL/wp-admin/plugins.php"
    echo "  2. Plugins → Añadir nuevo"
    echo "  3. Buscar: 'JWT Authentication for WP REST API'"
    echo "  4. Instalar y activar"
    echo "  5. Configurar en wp-config.php (ver docs/WORDPRESS_PLUGINS_REQUIRED.md)"
    echo "  6. Ejecutar este script nuevamente"
  else
    echo -e "${RED}❌ AMBOS PLUGINS NECESITAN SER INSTALADOS${NC}"
    echo ""
    echo "Ver instrucciones completas en:"
    echo "  docs/WORDPRESS_PLUGINS_REQUIRED.md"
    echo ""
    echo "O seguir los pasos en:"
    echo "  PROBLEMA_LOGIN_SOLUCION.md"
  fi
fi

echo ""

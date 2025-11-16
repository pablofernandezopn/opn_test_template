#!/bin/bash

# Script de prueba para enviar notificaciones push
# Uso: ./test-notification.sh

# Configuración
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_ANON_KEY="your-anon-key-here"
FUNCTION_URL="${SUPABASE_URL}/functions/v1/send-push-notification"

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔔 Testing Push Notification Function${NC}"
echo "================================================"

# Test 1: Notificación simple
echo -e "\n${YELLOW}Test 1: Simple notification${NC}"
curl -X POST "${FUNCTION_URL}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -d '{
    "user_id": 1,
    "title": "Test Simple",
    "body": "Esta es una notificación de prueba simple"
  }' \
  | jq '.'

# Test 2: Notificación con imagen
echo -e "\n${YELLOW}Test 2: Notification with image${NC}"
curl -X POST "${FUNCTION_URL}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -d '{
    "user_id": 1,
    "title": "Test con Imagen 🖼️",
    "body": "Esta notificación incluye una imagen",
    "image_url": "https://picsum.photos/1200/600"
  }' \
  | jq '.'

# Test 3: Notificación con navegación
echo -e "\n${YELLOW}Test 3: Notification with navigation${NC}"
curl -X POST "${FUNCTION_URL}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -d '{
    "user_id": 1,
    "title": "Test con Navegación 🧭",
    "body": "Toca para ir al perfil",
    "route": "/profile"
  }' \
  | jq '.'

# Test 4: Notificación completa
echo -e "\n${YELLOW}Test 4: Complete notification${NC}"
curl -X POST "${FUNCTION_URL}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -d '{
    "user_id": 1,
    "title": "🎉 Nuevo logro desbloqueado",
    "body": "Has completado 100 tests exitosamente",
    "image_url": "https://picsum.photos/1200/600",
    "route": "/achievements",
    "data": {
      "achievement_id": "100_tests",
      "points": "500"
    }
  }' \
  | jq '.'

echo -e "\n${GREEN}✅ Tests completed!${NC}"
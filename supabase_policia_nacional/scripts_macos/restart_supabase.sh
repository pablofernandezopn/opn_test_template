#!/bin/bash

# Script para reiniciar Supabase y aplicar los cambios

echo "🔄 Reiniciando Supabase con configuración actualizada..."
echo ""

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

cd /Users/pablofernandezlucas/Documents/Isyfu/opn_guardia_civil/supabase

echo "1️⃣  Deteniendo Supabase..."
supabase stop

echo ""
echo "2️⃣  Iniciando Supabase..."
supabase start

echo ""
echo "3️⃣  Verificando estado..."
supabase status

echo ""
echo -e "${GREEN}✓${NC} Supabase reiniciado correctamente"
echo ""
echo "📋 Siguiente paso:"
echo "  - Prueba el login desde la app"
echo "  - Los logs mejorados ahora mostrarán más información"
echo ""
echo "Ver logs en tiempo real:"
echo -e "  ${BLUE}supabase functions serve login-register --debug${NC}"
echo ""

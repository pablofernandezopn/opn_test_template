#!/bin/bash

# Script maestro para compilar la aplicación en diferentes plataformas
# Autor: Claude Code
# Uso: ./scripts/build.sh [android|ios|web|all]

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para mostrar el banner
show_banner() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                        ║${NC}"
    echo -e "${CYAN}║   ${GREEN}OPN Test Guardia Civil${CYAN}            ║${NC}"
    echo -e "${CYAN}║   ${BLUE}Build Script${CYAN}                      ║${NC}"
    echo -e "${CYAN}║                                        ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""
}

# Función para mostrar el menú
show_menu() {
    echo -e "${BLUE}Selecciona la plataforma a compilar:${NC}"
    echo ""
    echo "  1) 📱 Android (App Bundle)"
    echo "  2) 🍎 iOS (IPA)"
    echo "  3) 🌐 Web"
    echo "  4) 🚀 Todas las plataformas"
    echo "  5) ❌ Salir"
    echo ""
}

# Función para compilar Android
build_android() {
    echo -e "${GREEN}Compilando Android...${NC}"
    ./scripts/build_android.sh
}

# Función para compilar iOS
build_ios() {
    echo -e "${GREEN}Compilando iOS...${NC}"
    ./scripts/build_ios.sh
}

# Función para compilar Web
build_web() {
    echo -e "${GREEN}Compilando Web...${NC}"
    ./scripts/build_web.sh
}

# Función para compilar todas las plataformas
build_all() {
    echo -e "${YELLOW}Compilando todas las plataformas...${NC}"
    echo ""

    # Android
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}1/3: Android${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    build_android
    echo ""

    # iOS (solo en macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}2/3: iOS${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        build_ios
        echo ""
    else
        echo -e "${YELLOW}⚠ iOS: Omitido (requiere macOS)${NC}"
        echo ""
    fi

    # Web
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}3/3: Web${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    build_web
    echo ""

    echo -e "${GREEN}✓ Todas las compilaciones completadas!${NC}"
}

# Main
show_banner

# Si se pasa un argumento, ejecutar directamente
if [ $# -eq 1 ]; then
    case $1 in
        android)
            build_android
            ;;
        ios)
            build_ios
            ;;
        web)
            build_web
            ;;
        all)
            build_all
            ;;
        *)
            echo -e "${RED}Opción no válida: $1${NC}"
            echo "Uso: $0 [android|ios|web|all]"
            exit 1
            ;;
    esac
    exit 0
fi

# Si no se pasa argumento, mostrar menú interactivo
while true; do
    show_menu
    read -p "Opción: " option
    echo ""

    case $option in
        1)
            build_android
            break
            ;;
        2)
            build_ios
            break
            ;;
        3)
            build_web
            break
            ;;
        4)
            build_all
            break
            ;;
        5)
            echo "👋 Saliendo..."
            exit 0
            ;;
        *)
            echo -e "${RED}Opción no válida. Intenta de nuevo.${NC}"
            echo ""
            ;;
    esac
done

echo ""
echo -e "${GREEN}✓ Proceso completado!${NC}"
echo ""
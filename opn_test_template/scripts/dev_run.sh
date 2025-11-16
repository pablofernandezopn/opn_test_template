u#!/bin/bash

# Script para ejecutar la aplicación en modo desarrollo (debug)
# Autor: Claude Code
# Uso: ./scripts/dev_run.sh [android|ios|web|chrome]

set -e  # Detener si hay algún error

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

show_banner() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   ${GREEN}OPN - Modo Desarrollo${CYAN}             ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""
}

# Función para mostrar dispositivos disponibles
show_devices() {
    echo -e "${BLUE}Dispositivos/emuladores disponibles:${NC}"
    flutter devices
    echo ""
}

# Función principal
show_banner

# Verificar si se pasó un argumento
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Uso: $0 [android|ios|web|chrome|devices]${NC}"
    echo ""
    echo "Opciones:"
    echo "  android  - Ejecutar en Android (emulador o dispositivo)"
    echo "  ios      - Ejecutar en iOS (simulador o dispositivo)"
    echo "  web      - Ejecutar en navegador web (Chrome)"
    echo "  chrome   - Ejecutar en Chrome (alias de web)"
    echo "  devices  - Listar dispositivos disponibles"
    echo ""
    exit 1
fi

PLATFORM=$1

# Obtener dependencias si es necesario
print_step "Verificando dependencias..."
flutter pub get
print_success "Dependencias actualizadas"
echo ""

case $PLATFORM in
    android)
        print_step "Ejecutando en Android..."
        print_warning "Asegúrate de tener un emulador ejecutándose o un dispositivo conectado"
        echo ""
        flutter run -d android
        ;;
    ios)
        if [[ "$OSTYPE" != "darwin"* ]]; then
            print_error "iOS solo está disponible en macOS"
            exit 1
        fi
        print_step "Ejecutando en iOS..."
        print_warning "Asegúrate de tener un simulador ejecutándose o un dispositivo conectado"
        echo ""
        flutter run -d ios
        ;;
    web|chrome)
        print_step "Ejecutando en navegador..."
        print_success "La app se abrirá en Chrome"
        echo ""
        flutter run -d chrome --web-renderer html
        ;;
    devices)
        show_devices
        ;;
    *)
        print_error "Plataforma no válida: $PLATFORM"
        echo "Opciones válidas: android, ios, web, chrome, devices"
        exit 1
        ;;
esac
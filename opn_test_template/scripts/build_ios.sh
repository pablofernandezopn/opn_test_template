#!/bin/bash

# Script para compilar la aplicación para iOS (IPA)
# Autor: Claude Code
# Uso: ./scripts/build_ios.sh

set -e  # Detener si hay algún error

echo "========================================="
echo "  🍎 BUILD iOS APP"
echo "========================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función para imprimir con color
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

# Verificar que estamos en macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "Este script solo puede ejecutarse en macOS"
    exit 1
fi

# 1. Limpiar builds anteriores
print_step "Limpiando builds anteriores..."
flutter clean
print_success "Build limpiado"
echo ""

# 2. Obtener dependencias
print_step "Obteniendo dependencias..."
flutter pub get
print_success "Dependencias obtenidas"
echo ""

# 3. Generar código (build_runner)
print_step "Generando código (freezed, json_serializable)..."
flutter pub run build_runner build --delete-conflicting-outputs
print_success "Código generado"
echo ""

# 4. Actualizar CocoaPods
print_step "Actualizando CocoaPods..."
cd ios
pod install --repo-update
cd ..
print_success "CocoaPods actualizados"
echo ""

# 5. Compilar IPA
print_step "Compilando iOS App (release)..."
print_warning "Nota: Se abrirá Xcode para archivar. Cierra Xcode después de exportar el IPA."
flutter build ipa --release

if [ $? -eq 0 ]; then
    print_success "Compilación exitosa!"
    echo ""

    # 6. Mostrar ubicación del archivo
    echo "========================================="
    echo -e "${GREEN}✓ BUILD COMPLETADO${NC}"
    echo "========================================="
    echo ""
    echo "📦 IPA generado en:"
    echo "   build/ios/ipa/"
    echo ""

    if [ -d "build/ios/ipa" ]; then
        echo "📊 Archivos generados:"
        ls -lh build/ios/ipa/
        echo ""
    fi

    echo "🚀 Siguiente paso:"
    echo "   1. Abre Xcode y archiva la app (Product > Archive)"
    echo "   2. O sube el .ipa a App Store Connect usando:"
    echo "      xcrun altool --upload-app --file build/ios/ipa/*.ipa"
    echo ""
else
    print_error "Error durante la compilación"
    exit 1
fi
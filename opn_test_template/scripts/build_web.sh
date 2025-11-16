#!/bin/bash

# Script para compilar la aplicación para Web
# Autor: Claude Code
# Uso: ./scripts/build_web.sh

set -e  # Detener si hay algún error

echo "========================================="
echo "  🌐 BUILD WEB APP"
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

# 4. Compilar para Web
print_step "Compilando aplicación Web (release)..."
print_warning "Usando renderer HTML para mejor compatibilidad"
flutter build web --release --web-renderer html

if [ $? -eq 0 ]; then
    print_success "Compilación exitosa!"
    echo ""

    # 5. Mostrar ubicación de archivos
    echo "========================================="
    echo -e "${GREEN}✓ BUILD COMPLETADO${NC}"
    echo "========================================="
    echo ""
    echo "📦 Aplicación Web generada en:"
    echo "   build/web/"
    echo ""
    echo "📊 Estructura de archivos:"
    ls -lh build/web/ | head -10
    echo ""
    echo "📏 Tamaño total del build:"
    du -sh build/web/
    echo ""
    echo "🚀 Siguiente paso:"
    echo "   1. Para probar localmente:"
    echo "      python3 -m http.server 8000 --directory build/web"
    echo "      Luego abre: http://localhost:8000"
    echo ""
    echo "   2. Para desplegar en producción:"
    echo "      - Sube el contenido de build/web/ a tu servidor"
    echo "      - O usa Firebase Hosting, Netlify, Vercel, etc."
    echo ""

    # Opcional: Crear un archivo ZIP para fácil distribución
    print_step "Creando archivo ZIP para distribución..."
    cd build
    zip -r web.zip web/
    cd ..
    print_success "ZIP creado: build/web.zip"
    echo ""
else
    print_error "Error durante la compilación"
    exit 1
fi
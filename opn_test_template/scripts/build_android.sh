#!/bin/bash

# Script para compilar la aplicación para Android (App Bundle)
# Autor: Claude Code
# Uso: ./scripts/build_android.sh

set -e  # Detener si hay algún error

# Configurar JAVA_HOME si no está configurado
if [ -z "$JAVA_HOME" ]; then
    # Buscar Java en Android Studio (macOS)
    if [ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]; then
        export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
        export PATH="$JAVA_HOME/bin:$PATH"
    # Buscar Java usando java_home (macOS)
    elif [ -x "/usr/libexec/java_home" ]; then
        JAVA_HOME_DETECTED=$(/usr/libexec/java_home 2>/dev/null || true)
        if [ -n "$JAVA_HOME_DETECTED" ]; then
            export JAVA_HOME="$JAVA_HOME_DETECTED"
            export PATH="$JAVA_HOME/bin:$PATH"
        fi
    fi
fi

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "========================================="
echo "  📱 BUILD ANDROID APP BUNDLE"
echo "========================================="
echo ""

# Verificar que Java está disponible
if ! command -v java &> /dev/null; then
    echo -e "${RED}✗ Error: Java no está instalado o configurado${NC}"
    echo -e "${YELLOW}⚠ Por favor instala Java JDK 17 o superior${NC}"
    echo ""
    echo "Opciones:"
    echo "  1. Instala Android Studio (incluye Java)"
    echo "  2. Instala Java desde: https://adoptium.net/"
    echo ""
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1)
echo -e "${GREEN}✓ Java encontrado: $JAVA_VERSION${NC}"
echo ""

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

# 4. Verificar configuración de Android
print_step "Verificando configuración de Android..."
if [ -f "android/key.properties" ]; then
    print_success "key.properties encontrado ✓"

    # Verificar que el keystore existe
    KEYSTORE_PATH=$(grep "storeFile=" android/key.properties | cut -d'=' -f2)
    if [ -f "android/$KEYSTORE_PATH" ]; then
        print_success "Keystore encontrado: $KEYSTORE_PATH ✓"
    else
        print_error "Keystore no encontrado: android/$KEYSTORE_PATH"
        print_warning "La compilación fallará sin el keystore"
        exit 1
    fi
else
    print_error "No se encontró android/key.properties"
    print_warning "Asegúrate de tener la configuración de firma correcta"
    print_warning "La compilación continuará pero puede fallar en la firma"
fi
print_success "Configuración verificada"
echo ""

# 5. Compilar App Bundle
print_step "Compilando Android App Bundle (release)..."
flutter build appbundle --release
print_success "Compilación exitosa!"
echo ""

# 6. Mostrar ubicación del archivo
echo "========================================="
echo -e "${GREEN}✓ BUILD COMPLETADO${NC}"
echo "========================================="
echo ""
echo "📦 App Bundle generado en:"
echo "   build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "📊 Información del bundle:"
ls -lh build/app/outputs/bundle/release/app-release.aab
echo ""
echo "🚀 Siguiente paso:"
echo "   Sube el archivo .aab a Google Play Console"
echo ""
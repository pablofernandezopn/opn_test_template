#!/bin/bash

# 🚀 Script maestro para ejecutar todas las pruebas de deep links en iOS

echo "🚀 Ejecutando todas las pruebas de Deep Links en iOS"
echo "====================================================="
echo ""

# Verificar que hay un simulador activo
DEVICE_ID=$(xcrun simctl list devices | grep Booted | head -1 | grep -o '[A-F0-9-]\{36\}')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ No hay ningún simulador iniciado"
    echo ""
    echo "Por favor:"
    echo "  1. Inicia un simulador: open -a Simulator"
    echo "  2. Espera a que cargue completamente"
    echo "  3. Ejecuta: flutter run"
    echo "  4. Vuelve a ejecutar este script"
    echo ""
    exit 1
fi

echo "✅ Simulador detectado: $DEVICE_ID"
echo ""

# Directorio de los scripts
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Hacer todos los scripts ejecutables
chmod +x "$SCRIPT_DIR"/*.sh

echo "📋 Se ejecutarán las siguientes pruebas:"
echo "   1. Deep links con esquema personalizado (opngc://)"
echo "   2. Deep links con URLs web (https://)"
echo "   3. Deep links con parámetros"
echo ""

read -p "¿Continuar? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Pruebas canceladas"
    exit 0
fi

echo ""
echo "═════════════════════════════════════════════════════"
echo "  Prueba 1: Esquemas personalizados (opngc://)"
echo "═════════════════════════════════════════════════════"
echo ""
"$SCRIPT_DIR/test_custom_scheme_ios.sh"

echo ""
echo "Presiona ENTER para continuar con la siguiente prueba..."
read

echo ""
echo "═════════════════════════════════════════════════════"
echo "  Prueba 2: URLs web / Universal Links (https://)"
echo "═════════════════════════════════════════════════════"
echo ""
"$SCRIPT_DIR/test_web_links_ios.sh"

echo ""
echo "Presiona ENTER para continuar con la siguiente prueba..."
read

echo ""
echo "═════════════════════════════════════════════════════"
echo "  Prueba 3: Deep links con parámetros"
echo "═════════════════════════════════════════════════════"
echo ""
"$SCRIPT_DIR/test_with_params_ios.sh"

echo ""
echo "🎉 ¡Todas las pruebas completadas!"
echo ""
echo "📊 Resumen:"
echo "   ✅ Esquemas personalizados probados"
echo "   ✅ URLs web probadas"
echo "   ✅ Parámetros probados"
echo ""
echo "💡 Próximos pasos:"
echo "   1. Revisa los logs de la app en Xcode"
echo "   2. Verifica que la navegación funcionó correctamente"
echo "   3. Configura los archivos del servidor para Universal Links"
echo ""
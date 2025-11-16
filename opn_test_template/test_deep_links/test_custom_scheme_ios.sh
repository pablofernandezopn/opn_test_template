#!/bin/bash

# 🔗 Script para probar deep links con esquema personalizado (opngc://) en iOS
# Este script prueba todos los deep links usando el esquema personalizado

echo "🔗 Probando Deep Links con esquema personalizado (opngc://) en iOS"
echo "================================================================"
echo ""
echo "⚠️  IMPORTANTE: Asegúrate de que la app esté instalada en el simulador"
echo "    Ejecuta primero: flutter run"
echo ""

# Detectar el simulador activo
DEVICE_ID=$(xcrun simctl list devices | grep Booted | head -1 | grep -o '[A-F0-9-]\{36\}')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ No hay ningún simulador iniciado"
    echo "   Inicia un simulador con: open -a Simulator"
    exit 1
fi

echo "✅ Usando simulador: $DEVICE_ID"
echo ""

# Función para probar un deep link
test_link() {
    local url=$1
    local description=$2

    echo "📱 Probando: $description"
    echo "   URL: $url"

    xcrun simctl openurl "$DEVICE_ID" "$url"

    if [ $? -eq 0 ]; then
        echo "   ✅ Comando ejecutado correctamente"
    else
        echo "   ❌ Error al ejecutar el comando"
    fi

    echo ""
    sleep 2
}

# Probar diferentes rutas
echo "🧪 Iniciando pruebas..."
echo ""

test_link "opngc://home" "Página principal"
test_link "opngc://test-config" "Configuración de test"
test_link "opngc://history" "Historial de tests"
test_link "opngc://stats" "Estadísticas"
test_link "opngc://profile" "Perfil de usuario"
test_link "opngc://favorites" "Favoritos"
test_link "opngc://challenges" "Impugnaciones"
test_link "opngc://opn-ranking" "Ranking global"
test_link "opngc://survival-test" "Modo supervivencia"
test_link "opngc://ai-chat" "Chat con IA"

echo "✅ Todas las pruebas completadas"
echo ""
echo "💡 Verifica en el simulador que la app navegó correctamente a cada pantalla"
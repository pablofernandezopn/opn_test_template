#!/bin/bash

# 🔗 Script para probar deep links con parámetros en iOS

echo "🔗 Probando Deep Links con parámetros en iOS"
echo "============================================"
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

# Probar deep links con parámetros
echo "🧪 Probando URLs con parámetros..."
echo ""

# Esquemas personalizados con parámetros
test_link "opngc://preview-topic/123" "Preview de tema con ID 123"
test_link "opngc://ranking/456/Test%20de%20Prueba" "Ranking de tema con ID 456"
test_link "opngc://challenge-detail/789" "Detalle de impugnación con ID 789"
test_link "opngc://favorite-question?id=101" "Pregunta favorita con query param"
test_link "opngc://test-config?topicId=202&mode=practice" "Configuración con múltiples parámetros"

echo ""
echo "🌐 Probando URLs web con parámetros..."
echo ""

# URLs web con parámetros
test_link "https://oposicionesguardiacivil.online/preview-topic/123" "Preview de tema (web)"
test_link "https://oposicionesguardiacivil.online/ranking/456/Test%20de%20Prueba" "Ranking (web)"
test_link "https://oposicionesguardiacivil.online/challenge-detail/789" "Detalle impugnación (web)"
test_link "https://oposicionesguardiacivil.online/favorite-question?id=101" "Pregunta favorita (web)"
test_link "https://oposicionesguardiacivil.online/test-config?topicId=202&mode=practice" "Configuración con params (web)"

echo "✅ Todas las pruebas completadas"
echo ""
echo "💡 Verifica en los logs de la app que los parámetros se recibieron correctamente"
echo "   Busca líneas que digan: '🔗 Deep Link recibido:'"
#!/bin/bash

# 🌐 Script para probar deep links con URLs web (Universal Links) en iOS
# Este script prueba todos los deep links usando el dominio web

echo "🌐 Probando Universal Links (https://) en iOS"
echo "=============================================="
echo ""
echo "⚠️  IMPORTANTE:"
echo "    1. La app debe estar instalada en el simulador"
echo "    2. Los archivos de verificación deben estar en el servidor:"
echo "       https://oposicionesguardiacivil.online/.well-known/apple-app-site-association"
echo "    3. El Team ID debe estar correctamente configurado"
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

test_link "https://oposicionesguardiacivil.online/home" "Página principal"
test_link "https://oposicionesguardiacivil.online/test-config" "Configuración de test"
test_link "https://oposicionesguardiacivil.online/history" "Historial de tests"
test_link "https://oposicionesguardiacivil.online/stats" "Estadísticas"
test_link "https://oposicionesguardiacivil.online/profile" "Perfil de usuario"
test_link "https://oposicionesguardiacivil.online/favorites" "Favoritos"
test_link "https://oposicionesguardiacivil.online/challenges" "Impugnaciones"
test_link "https://oposicionesguardiacivil.online/opn-ranking" "Ranking global"
test_link "https://oposicionesguardiacivil.online/survival-test" "Modo supervivencia"
test_link "https://oposicionesguardiacivil.online/ai-chat" "Chat con IA"

echo "✅ Todas las pruebas completadas"
echo ""
echo "💡 Notas sobre Universal Links:"
echo "   - Si no funcionan, verifica que el archivo apple-app-site-association"
echo "     esté accesible en el servidor"
echo "   - Los Universal Links NO funcionan si abres el link desde la misma app"
echo "   - Deben abrirse desde Safari, Notas, Mail, etc."
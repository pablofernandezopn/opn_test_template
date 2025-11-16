#!/bin/bash

# 🚀 Script rápido para probar un deep link específico

if [ -z "$1" ]; then
    echo "❌ Error: Debes proporcionar una URL"
    echo ""
    echo "Uso:"
    echo "  ./quick_test.sh <URL>"
    echo ""
    echo "Ejemplos:"
    echo "  ./quick_test.sh opngc://home"
    echo "  ./quick_test.sh https://oposicionesguardiacivil.online/profile"
    echo "  ./quick_test.sh \"opngc://test-config?topicId=123\""
    echo ""
    exit 1
fi

URL=$1

# Detectar el simulador activo
DEVICE_ID=$(xcrun simctl list devices | grep Booted | head -1 | grep -o '[A-F0-9-]\{36\}')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ No hay ningún simulador iniciado"
    echo ""
    echo "Inicia un simulador con: open -a Simulator"
    echo "Luego ejecuta: flutter run"
    echo ""
    exit 1
fi

echo "🔗 Abriendo deep link..."
echo "   Simulador: $DEVICE_ID"
echo "   URL: $URL"
echo ""

xcrun simctl openurl "$DEVICE_ID" "$URL"

if [ $? -eq 0 ]; then
    echo "✅ Link abierto correctamente"
    echo ""
    echo "💡 Verifica en el simulador que la navegación funcionó"
    echo "   Busca en los logs: '🔗 Deep Link recibido:'"
else
    echo "❌ Error al abrir el link"
fi
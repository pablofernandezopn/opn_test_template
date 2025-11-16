#!/bin/bash

# Script para monitorear la carga de user_test_answers
# Muestra progreso cada 5 minutos y notifica cuando termina

LOG_FILE="/Users/pablofernandezlucas/Documents/Isyfu/opn_test_policia_nacional/nueva_app/supabase/migration_policia_nacional/load_final_corrected.log"
PID_FILE="/tmp/load_user_tests.pid"

echo "🔍 Monitoreando carga de user_test_answers..."
echo "📝 Log: $LOG_FILE"
echo ""

# Función para obtener el progreso
get_progress() {
    # Buscar la última línea que indica qué archivo se está procesando
    CURRENT_FILE=$(grep -o "Archivo [0-9]*/85" "$LOG_FILE" | tail -1)

    # Buscar si hay mensaje de finalización
    if grep -q "CARGA COMPLETADA EXITOSAMENTE" "$LOG_FILE"; then
        return 0
    else
        return 1
    fi
}

# Función para mostrar progreso
show_progress() {
    CURRENT_FILE=$(grep -o "Archivo [0-9]*/85" "$LOG_FILE" | tail -1)
    LAST_BATCH=$(grep "Insertando:" "$LOG_FILE" | tail -1)

    echo "⏰ $(date '+%H:%M:%S')"
    echo "📊 Progreso: $CURRENT_FILE"
    echo "📦 Último batch: $LAST_BATCH"

    # Contar user_test_answers insertados hasta ahora
    TOTAL_ANSWERS=$(psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -t -c "SELECT COUNT(*) FROM user_test_answers" 2>/dev/null)
    if [ ! -z "$TOTAL_ANSWERS" ]; then
        echo "✅ Answers en BD: $(echo $TOTAL_ANSWERS | xargs)"
    fi
    echo ""
}

# Bucle de monitoreo
while true; do
    if get_progress; then
        echo "🎉 ¡CARGA COMPLETADA!"
        echo ""
        echo "📊 RESUMEN FINAL:"
        tail -30 "$LOG_FILE"

        # Notificación del sistema (macOS)
        osascript -e 'display notification "La carga de user_test_answers ha finalizado exitosamente" with title "Migración Completada" sound name "Glass"'

        # Verificar counts
        echo ""
        echo "🔢 Verificando counts en BD:"
        psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -c "
            SELECT
                'user_tests' as tabla, COUNT(*) as registros
            FROM user_tests
            UNION ALL
            SELECT
                'user_test_answers' as tabla, COUNT(*) as registros
            FROM user_test_answers
            UNION ALL
            SELECT
                'topic_mock_rankings' as tabla, COUNT(*) as registros
            FROM topic_mock_rankings;
        "

        exit 0
    fi

    # Verificar si el proceso sigue corriendo
    if ! pgrep -f "load_user_tests_and_answers.py" > /dev/null; then
        echo "⚠️  ADVERTENCIA: El proceso no está corriendo"
        echo "📋 Últimas líneas del log:"
        tail -20 "$LOG_FILE"

        osascript -e 'display notification "El proceso de carga se detuvo inesperadamente" with title "Advertencia Migración" sound name "Basso"'

        exit 1
    fi

    # Mostrar progreso
    show_progress

    # Esperar 5 minutos antes de volver a chequear
    sleep 300
done

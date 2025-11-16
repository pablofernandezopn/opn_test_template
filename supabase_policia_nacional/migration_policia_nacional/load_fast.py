#!/usr/bin/env python3
"""
Carga ULTRA-RÁPIDA de user_test_answers usando PostgreSQL COPY
10-50x más rápido que INSERT individual
"""
import json
import sys
import os
import psycopg2
from tqdm import tqdm
import glob
from io import StringIO
import time

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from config import TRANSFORMED_DIR

DB_URL = "postgresql://postgres:postgres@127.0.0.1:54322/postgres"

def load_json(filepath):
    """Cargar JSON"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

def load_user_test_answers_fast(conn, old_to_new_mapping):
    """Cargar user_test_answers usando COPY (ultra-rápido)"""
    print(f"\n📥 Cargando user_test_answers con COPY...")

    # Buscar archivos transformados
    answer_files = sorted(glob.glob(f'{TRANSFORMED_DIR}/user_test_answers_*.json'))

    if not answer_files:
        print(f"   ⚠️  No se encontraron archivos transformados")
        return

    print(f"   📊 {len(answer_files)} archivos a procesar")

    cur = conn.cursor()

    total_inserted = 0
    total_skipped = 0
    start_time = time.time()

    for file_num, answer_file in enumerate(answer_files, 1):
        print(f"\n   📄 Archivo {file_num}/{len(answer_files)}: {os.path.basename(answer_file)}")

        answers = load_json(answer_file)

        # Preparar datos para COPY en formato CSV
        csv_buffer = StringIO()
        skipped_in_file = 0

        for answer in tqdm(answers, desc="      Preparando"):
            # Mapear old user_test_id → new user_test_id
            old_user_test_id = answer['user_test_id']
            new_user_test_id = old_to_new_mapping.get(str(old_user_test_id))

            if not new_user_test_id:
                skipped_in_file += 1
                continue

            # Formatear valores para CSV
            # user_test_id, question_id, selected_option_id, question_order, challenge_by_tutor
            selected_option_id = answer['selected_option_id'] if answer['selected_option_id'] is not None else '\\N'
            challenge_by_tutor = 't' if answer['challenge_by_tutor'] else 'f'

            csv_buffer.write(f"{new_user_test_id}\t{answer['question_id']}\t{selected_option_id}\t{answer['question_order']}\t{challenge_by_tutor}\n")

        total_skipped += skipped_in_file

        # COPY masivo desde buffer
        csv_buffer.seek(0)

        print(f"      Insertando con COPY...")
        copy_start = time.time()

        cur.copy_expert(
            """
            COPY user_test_answers (
                user_test_id, question_id, selected_option_id,
                question_order, challenge_by_tutor
            )
            FROM STDIN WITH (FORMAT TEXT, NULL '\\N')
            """,
            csv_buffer
        )

        conn.commit()

        copy_time = time.time() - copy_start
        records_in_file = len(answers) - skipped_in_file
        total_inserted += records_in_file

        if copy_time > 0:
            rate = records_in_file / copy_time
            print(f"      ✓ {records_in_file:,} registros en {copy_time:.1f}s ({rate:,.0f} rec/s)")

    cur.close()

    elapsed = time.time() - start_time
    avg_rate = total_inserted / elapsed if elapsed > 0 else 0

    print(f"\n   ✓ Total insertado: {total_inserted:,}")
    print(f"   ⚠️  Total omitido: {total_skipped:,}")
    print(f"   ⏱️  Tiempo total: {elapsed:.1f}s")
    print(f"   🚀 Velocidad promedio: {avg_rate:,.0f} registros/segundo")

def enable_triggers(conn):
    """Reactivar triggers"""
    print(f"\n✅ Reactivando triggers...")
    cur = conn.cursor()

    # user_test_answers
    cur.execute("ALTER TABLE user_test_answers ENABLE TRIGGER trg_calculate_answer_correctness")
    cur.execute("ALTER TABLE user_test_answers ENABLE TRIGGER trg_update_flashcard_review_schedule")
    cur.execute("ALTER TABLE user_test_answers ENABLE TRIGGER trg_update_question_stats")
    cur.execute("ALTER TABLE user_test_answers ENABLE TRIGGER trg_update_user_test_stats")

    # user_tests
    cur.execute("ALTER TABLE user_tests ENABLE TRIGGER trigger_update_daily_activity_and_streak")

    conn.commit()
    cur.close()
    print(f"   ✓ Triggers reactivados")

def finalize_tests_and_trigger_ranking(conn):
    """
    Finalizar tests y disparar triggers de ranking
    """
    print(f"\n🎯 Finalizando tests y disparando triggers...")

    cur = conn.cursor()

    # Actualizar finalized=true para tests que lo eran originalmente
    # Esto dispara los triggers de ranking/stats
    cur.execute("""
        UPDATE user_tests
        SET finalized = true
        WHERE id IN (
            -- Solo tests que originalmente estaban finalized
            -- Asumimos que todos los que tienen score están finalized
            SELECT id FROM user_tests WHERE score IS NOT NULL
        )
    """)

    updated = cur.rowcount
    conn.commit()
    cur.close()

    print(f"   ✓ {updated:,} tests finalizados")
    print(f"   ✓ Triggers de ranking disparados automáticamente")

def update_answer_correctness(conn):
    """
    Actualizar el campo 'correct' en todas las respuestas
    Ya que el trigger estaba desactivado durante la carga
    """
    print(f"\n🔄 Actualizando campo 'correct' en respuestas...")

    cur = conn.cursor()

    # Usar la misma lógica que el trigger calculate_answer_correctness
    cur.execute("""
        UPDATE user_test_answers uta
        SET correct = (
            uta.selected_option_id IS NOT NULL
            AND EXISTS (
                SELECT 1
                FROM question_options qo
                WHERE qo.id = uta.selected_option_id
                AND qo.is_correct = true
            )
        )
        WHERE correct IS NULL OR correct != (
            uta.selected_option_id IS NOT NULL
            AND EXISTS (
                SELECT 1
                FROM question_options qo
                WHERE qo.id = uta.selected_option_id
                AND qo.is_correct = true
            )
        )
    """)

    updated = cur.rowcount
    conn.commit()
    cur.close()

    print(f"   ✓ {updated:,} respuestas actualizadas con correctness")

def main():
    """Función principal"""
    print("\n" + "="*60)
    print("🚀 CARGA ULTRA-RÁPIDA CON POSTGRESQL COPY")
    print("="*60)

    conn = psycopg2.connect(DB_URL)

    try:
        # Cargar mapping de IDs
        mapping_file = f'{TRANSFORMED_DIR}/user_test_id_old_to_new.json'

        if not os.path.exists(mapping_file):
            print(f"\n⚠️  Error: No se encontró {mapping_file}")
            print(f"   Ejecuta primero el script de carga original para generar el mapping")
            return False

        with open(mapping_file, 'r') as f:
            old_to_new_mapping = json.load(f)

        print(f"   ✓ {len(old_to_new_mapping):,} user_tests mapeados")

        # Cargar user_test_answers con COPY
        load_user_test_answers_fast(conn, old_to_new_mapping)

        # Actualizar campo 'correct'
        update_answer_correctness(conn)

        # Reactivar triggers
        enable_triggers(conn)

        # Finalizar tests
        finalize_tests_and_trigger_ranking(conn)

        print("\n" + "="*60)
        print("✓ CARGA COMPLETADA EXITOSAMENTE")
        print("="*60)

        return True

    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()

        # Asegurar reactivación de triggers
        try:
            enable_triggers(conn)
        except:
            pass

        return False
    finally:
        conn.close()

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)

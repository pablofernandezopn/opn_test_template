#!/usr/bin/env python3
"""
Carga user_tests y user_test_answers en la BD nueva
Opción de desactivar triggers para mayor velocidad
"""
import json
import sys
import os
import psycopg2
import psycopg2.extras
from tqdm import tqdm
import glob
import argparse

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from config import TRANSFORMED_DIR

DB_URL = "postgresql://postgres:postgres@127.0.0.1:54322/postgres"

def load_json(filepath):
    """Cargar JSON"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

def disable_triggers(conn):
    """Desactivar triggers personalizados (no ALL para evitar error con system triggers)"""
    print(f"\n⚠️  Desactivando triggers personalizados...")
    cur = conn.cursor()

    # Solo desactivar trigger personalizado en user_tests
    cur.execute("ALTER TABLE user_tests DISABLE TRIGGER trigger_update_daily_activity_and_streak")
    # user_test_answers no tiene triggers personalizados

    conn.commit()
    cur.close()
    print(f"   ✓ Triggers personalizados desactivados")

def enable_triggers(conn):
    """Reactivar triggers personalizados"""
    print(f"\n✅ Reactivando triggers personalizados...")
    cur = conn.cursor()

    # Solo reactivar trigger personalizado en user_tests
    cur.execute("ALTER TABLE user_tests ENABLE TRIGGER trigger_update_daily_activity_and_streak")

    conn.commit()
    cur.close()
    print(f"   ✓ Triggers personalizados reactivados")

def load_user_tests(conn, disable_triggers_flag):
    """Cargar user_tests"""
    print(f"\n📥 Cargando user_tests...")

    # Cargar datos transformados
    user_tests_file = f'{TRANSFORMED_DIR}/user_tests.json'
    user_tests = load_json(user_tests_file)

    print(f"   📊 {len(user_tests):,} user_tests a cargar")

    cur = conn.cursor()

    inserted = 0
    errors = []
    old_id_to_new_id = {}  # Mapeo para user_test_answers

    batch_size = 500

    for i in tqdm(range(0, len(user_tests), batch_size), desc="   Insertando"):
        batch = user_tests[i:i + batch_size]

        for test in batch:
            try:
                # Insertar con finalized=false si se desactivan triggers
                # Para evitar disparo prematuro de triggers de ranking
                finalized_value = False if disable_triggers_flag else test['finalized']

                cur.execute("""
                    INSERT INTO user_tests (
                        user_id, topic_ids, options, right_questions,
                        wrong_questions, question_count, total_answered, score,
                        finalized, visible, study_mode, study_failed, study_white,
                        mock, survival, mark_collection, minutes, time_spent_millis,
                        special_topic, special_topic_title, difficulty_end,
                        number_of_lives, created_at, updated_at,
                        is_flashcard_mode, duration_seconds, topic_group_id,
                        total_time_seconds, survival_session_id, time_attack_session_id
                    )
                    VALUES (
                        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                    )
                    RETURNING id
                """, (
                    test['user_id'], test['topic_ids'], test['options'],
                    test['right_questions'], test['wrong_questions'],
                    test['question_count'], test['total_answered'], test['score'],
                    finalized_value, test['visible'], test['study_mode'],
                    test['study_failed'], test['study_white'], test['mock'],
                    test['survival'], test['mark_collection'], test['minutes'],
                    test['time_spent_millis'], test['special_topic'],
                    test['special_topic_title'], test['difficulty_end'],
                    test['number_of_lives'], test['created_at'], test['updated_at'],
                    test['is_flashcard_mode'], test['duration_seconds'],
                    test['topic_group_id'], test['total_time_seconds'],
                    test['survival_session_id'], test['time_attack_session_id']
                ))

                new_id = cur.fetchone()[0]
                old_id = test['_old_id']
                old_id_to_new_id[old_id] = new_id

                inserted += 1

            except Exception as e:
                conn.rollback()
                error_msg = f"Test {test.get('_old_id')}: {str(e)[:100]}"
                if len(errors) < 10:
                    errors.append(error_msg)

        # Commit batch
        conn.commit()

    cur.close()

    print(f"\n   ✓ User_tests insertados: {inserted:,}")

    if errors:
        print(f"   ⚠️  Errores: {len(errors)}")
        for error in errors:
            print(f"      - {error}")

    # Guardar mapping para user_test_answers
    mapping_file = f'{TRANSFORMED_DIR}/user_test_id_old_to_new.json'
    with open(mapping_file, 'w') as f:
        json.dump(old_id_to_new_id, f)

    print(f"   ✓ Mapping guardado: {mapping_file}")

    return old_id_to_new_id

def load_user_test_answers(conn, old_to_new_mapping):
    """Cargar user_test_answers"""
    print(f"\n📥 Cargando user_test_answers...")

    # Buscar archivos transformados
    answer_files = sorted(glob.glob(f'{TRANSFORMED_DIR}/user_test_answers_*.json'))

    if not answer_files:
        print(f"   ⚠️  No se encontraron archivos transformados")
        return

    print(f"   📊 {len(answer_files)} archivos a procesar")

    cur = conn.cursor()

    total_inserted = 0
    total_skipped = 0
    errors = []

    batch_size = 5000

    for file_num, answer_file in enumerate(answer_files, 1):
        print(f"\n   📄 Archivo {file_num}/{len(answer_files)}: {os.path.basename(answer_file)}")

        answers = load_json(answer_file)

        for i in tqdm(range(0, len(answers), batch_size), desc="      Insertando"):
            batch = answers[i:i + batch_size]

            for answer in batch:
                try:
                    # Mapear old user_test_id → new user_test_id
                    old_user_test_id = answer['user_test_id']
                    new_user_test_id = old_to_new_mapping.get(old_user_test_id)

                    if not new_user_test_id:
                        total_skipped += 1
                        continue

                    cur.execute("""
                        INSERT INTO user_test_answers (
                            user_test_id, question_id, selected_option_id,
                            question_order, challenge_by_tutor
                        )
                        VALUES (%s, %s, %s, %s, %s)
                    """, (
                        new_user_test_id, answer['question_id'],
                        answer['selected_option_id'], answer['question_order'],
                        answer['challenge_by_tutor']
                    ))

                    total_inserted += 1

                except Exception as e:
                    conn.rollback()
                    total_skipped += 1
                    if len(errors) < 20:
                        errors.append(f"Answer {answer.get('_old_id')}: {str(e)[:80]}")

            # Commit batch
            conn.commit()

    cur.close()

    print(f"\n   ✓ Answers insertados: {total_inserted:,}")
    print(f"   ⚠️  Answers omitidos: {total_skipped:,}")

    if errors:
        print(f"\n   📋 Errores:")
        for error in errors[:20]:
            print(f"      - {error}")

def finalize_tests_and_trigger_ranking(conn):
    """
    Finalizar tests y disparar triggers de ranking para tests Mock
    """
    print(f"\n🎯 Finalizando tests y disparando triggers de ranking...")

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

def main():
    """Función principal"""
    parser = argparse.ArgumentParser(description='Cargar user_tests y user_test_answers')
    parser.add_argument('--disable-triggers', action='store_true',
                        help='Desactivar triggers para carga más rápida')
    args = parser.parse_args()

    print("\n" + "="*60)
    print("📥 CARGA DE USER_TESTS Y USER_TEST_ANSWERS")
    if args.disable_triggers:
        print("⚡ MODO: Triggers desactivados (MÁS RÁPIDO)")
    else:
        print("🐢 MODO: Triggers activados (MÁS LENTO)")
    print("="*60)

    conn = psycopg2.connect(DB_URL)

    try:
        # Desactivar triggers si se solicitó
        if args.disable_triggers:
            disable_triggers(conn)

        # 1. Cargar user_tests
        old_to_new_mapping = load_user_tests(conn, args.disable_triggers)

        # 2. Cargar user_test_answers
        load_user_test_answers(conn, old_to_new_mapping)

        # 3. Si triggers desactivados, reactivar y finalizar
        if args.disable_triggers:
            enable_triggers(conn)
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
        if args.disable_triggers:
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

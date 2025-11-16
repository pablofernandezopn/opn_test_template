#!/usr/bin/env python3
"""
Transforma user_test_answers del schema antiguo al nuevo
- Convierte answer (índice) a selected_option_id
- Calcula question_order
- Mapea userTestId a user_test_id
"""
import json
import sys
import os
import psycopg2
from tqdm import tqdm
from collections import defaultdict
import glob

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from config import DATA_DIR, TRANSFORMED_DIR

DB_URL = "postgresql://postgres:postgres@127.0.0.1:54322/postgres"

def load_json(filepath):
    """Cargar JSON"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_json(data, filepath):
    """Guardar JSON"""
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def build_question_options_map(conn):
    """
    Construir mapa: question_id → [option_id1, option_id2, option_id3, option_id4]
    Ordenados por 'option_order' field
    """
    print(f"\n📋 Construyendo mapa de opciones...")
    cur = conn.cursor()

    # Obtener todas las opciones ordenadas
    cur.execute("""
        SELECT question_id, id, option_order
        FROM question_options
        ORDER BY question_id, option_order
    """)

    question_options = defaultdict(list)

    for question_id, option_id, order in cur.fetchall():
        question_options[question_id].append((order, option_id))

    # Ordenar y extraer solo los IDs
    question_options_map = {
        q_id: [opt_id for _, opt_id in sorted(options)]
        for q_id, options in question_options.items()
    }

    cur.close()

    print(f"   ✓ {len(question_options_map):,} preguntas con opciones")

    return question_options_map

def build_user_test_id_mapping(conn):
    """
    Construir mapa: old_user_test_id → new_user_test_id
    Necesario porque los IDs cambiarán al insertar
    Por ahora, usaremos el mapping basado en el orden
    """
    # Cargar el mapping creado en transform_user_tests
    mapping_file = f'{TRANSFORMED_DIR}/user_tests_id_mapping.json'
    if os.path.exists(mapping_file):
        return load_json(mapping_file)
    else:
        print(f"   ⚠️  No se encontró mapping de user_tests")
        return {}

def transform_answer(answer_old, question_options_map, user_test_old_id_mapping, valid_questions):
    """Transformar una respuesta individual"""

    user_test_old_id = answer_old.get('userTestId')
    question_id = answer_old.get('question')
    answer_index = answer_old.get('answer')  # 1, 2, 3, 4

    # Validar question_id existe
    if question_id not in valid_questions:
        return None, f"question_id {question_id} no existe"

    # Validar user_test_id en mapping (convertir a string para comparar con keys del JSON)
    user_test_old_id_str = str(user_test_old_id)
    if user_test_old_id_str not in user_test_old_id_mapping:
        return None, f"userTestId {user_test_old_id} no mapeado"

    # Obtener opciones de la pregunta
    if question_id not in question_options_map:
        return None, f"question {question_id} sin opciones"

    options = question_options_map[question_id]

    # Convertir índice (1-based) a option_id
    # Si answer es None, significa que el usuario no contestó (dejar selected_option_id = None)
    if answer_index is None:
        selected_option_id = None
    elif answer_index < 1 or answer_index > len(options):
        return None, f"answer {answer_index} inválido para question {question_id} (tiene {len(options)} opciones)"
    else:
        selected_option_id = options[answer_index - 1]  # answer es 1-based

    # Transformar
    answer_new = {
        'user_test_id': user_test_old_id,  # Usamos el ID antiguo, lo mapearemos al cargar
        'question_id': question_id,
        'selected_option_id': selected_option_id,
        'challenge_by_tutor': answer_old.get('challenge_by_tutor', False),
        # Campos que se calculan con triggers
        'correct': None,  # Se calcula con trigger
        'time_taken_seconds': None,
        'question_order': None,  # Se calculará después
        # Preservar ID original
        '_old_id': answer_old.get('id')
    }

    return answer_new, None

def calculate_question_order(answers):
    """Calcular question_order agrupando por user_test_id"""
    print(f"\n📊 Calculando question_order...")

    # Agrupar por user_test_id
    by_test = defaultdict(list)
    for answer in answers:
        by_test[answer['user_test_id']].append(answer)

    # Ordenar cada grupo por _old_id y asignar order
    for user_test_id, test_answers in by_test.items():
        test_answers.sort(key=lambda x: x['_old_id'])
        for i, answer in enumerate(test_answers):
            answer['question_order'] = i + 1  # 1-based

    print(f"   ✓ Question_order calculado para {len(by_test):,} tests")

def get_valid_questions(conn):
    """Obtener set de question_ids válidos"""
    cur = conn.cursor()
    cur.execute("SELECT id FROM questions")
    valid_questions = {row[0] for row in cur.fetchall()}
    cur.close()
    return valid_questions

def main():
    """Función principal"""
    print("\n" + "="*60)
    print("🔄 TRANSFORMACIÓN DE USER_TEST_ANSWERS")
    print("="*60)

    conn = psycopg2.connect(DB_URL)

    try:
        # Construir mapas
        question_options_map = build_question_options_map(conn)
        user_test_id_mapping = build_user_test_id_mapping(conn)
        valid_questions = get_valid_questions(conn)

        print(f"   ✓ {len(user_test_id_mapping):,} user_tests mapeados")
        print(f"   ✓ {len(valid_questions):,} preguntas válidas")

        # Buscar todos los archivos de user_test_answers
        answer_files = sorted(glob.glob(f'{DATA_DIR}/user_test_answers_*.json'))

        if not answer_files:
            print(f"\n⚠️  No se encontraron archivos user_test_answers_*.json")
            print(f"   Ejecuta primero: python3 extract_user_test_answers.py")
            return False

        print(f"\n📊 Archivos encontrados: {len(answer_files)}")

        # Procesar cada archivo
        all_transformed = []
        all_errors = []
        total_processed = 0
        total_skipped = 0

        for file_num, answer_file in enumerate(answer_files, 1):
            print(f"\n📄 Procesando archivo {file_num}/{len(answer_files)}: {os.path.basename(answer_file)}")

            # Cargar answers de este archivo
            answers_old = load_json(answer_file)
            print(f"   {len(answers_old):,} respuestas en archivo")

            # Transformar
            for answer_old in tqdm(answers_old, desc="   Transformando"):
                total_processed += 1
                answer_new, error = transform_answer(
                    answer_old,
                    question_options_map,
                    user_test_id_mapping,
                    valid_questions
                )

                if answer_new:
                    all_transformed.append(answer_new)
                else:
                    total_skipped += 1
                    if len(all_errors) < 50:
                        all_errors.append(f"Answer {answer_old.get('id')}: {error}")

        # Calcular question_order
        calculate_question_order(all_transformed)

        # Guardar en batches (para no crear archivo gigante)
        print(f"\n💾 Guardando resultados en batches...")

        batch_size = 100000
        num_batches = (len(all_transformed) + batch_size - 1) // batch_size

        for batch_num in range(num_batches):
            start = batch_num * batch_size
            end = min((batch_num + 1) * batch_size, len(all_transformed))
            batch_data = all_transformed[start:end]

            output_file = f'{TRANSFORMED_DIR}/user_test_answers_{batch_num + 1:03d}.json'
            save_json(batch_data, output_file)
            print(f"   ✓ Batch {batch_num + 1}/{num_batches}: {len(batch_data):,} registros → {output_file}")

        print(f"\n   ✓ Total transformados: {len(all_transformed):,}")
        print(f"   ⚠️  Total omitidos: {total_skipped:,}")

        if all_errors:
            print(f"\n   📋 Primeros errores:")
            for error in all_errors[:20]:
                print(f"      - {error}")

        print("\n" + "="*60)
        if total_skipped == 0:
            print("✓ TRANSFORMACIÓN COMPLETADA EXITOSAMENTE")
        else:
            print("⚠️ TRANSFORMACIÓN COMPLETADA CON ADVERTENCIAS")
        print(f"   {len(all_transformed):,} transformados, {total_skipped:,} omitidos")
        print("="*60)

        return True

    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        conn.close()

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)

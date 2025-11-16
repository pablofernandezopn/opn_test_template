#!/usr/bin/env python3
"""
Transforma user_tests del schema antiguo al nuevo
- Mapea campos
- Corrige topic_ids vacíos usando specialTopic
- Valida user_id existe
"""
import json
import sys
import os
import psycopg2
from tqdm import tqdm

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from config import DATA_FILES, TRANSFORMED_DIR, TARGET_ACADEMY_ID

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

def get_valid_users(conn):
    """Obtener set de user_ids válidos"""
    cur = conn.cursor()
    cur.execute("SELECT id FROM users")
    valid_users = {row[0] for row in cur.fetchall()}
    cur.close()
    return valid_users

def transform_user_test(test_old, valid_users):
    """Transformar un user_test individual"""

    # Validar user_id
    user_id = test_old.get('userId')
    if not user_id or user_id not in valid_users:
        return None, f"user_id {user_id} no existe"

    # Transformar topic_ids
    topics_old = test_old.get('topics', [])

    if not topics_old or len(topics_old) == 0:
        # Si topics está vacío, usar specialTopic si existe
        special_topic = test_old.get('specialTopic')
        if special_topic and special_topic > 0:
            topic_ids = [special_topic]
        else:
            # Test de estudio sin topic específico
            topic_ids = [-1]  # Virtual topic ID
    else:
        topic_ids = topics_old

    # Calcular question_count del array questions
    questions = test_old.get('questions', [])
    question_count = len(questions) if questions else test_old.get('question_count', 0)

    # Transformar campos
    test_new = {
        'user_id': user_id,
        'topic_ids': topic_ids,
        'options': test_old.get('options', 4),
        'right_questions': test_old.get('rightQuestions', 0),
        'wrong_questions': test_old.get('wrongQuestions', 0),
        'question_count': question_count,
        'total_answered': test_old.get('rightQuestions', 0) + test_old.get('wrongQuestions', 0),
        'score': test_old.get('score'),
        'finalized': test_old.get('finalized', False),
        'visible': test_old.get('visible', True),
        'study_mode': test_old.get('studyMode', False),
        'study_failed': test_old.get('studyFailed', False),
        'study_white': test_old.get('studyWhite', False),
        'mock': test_old.get('isMock'),  # Puede ser NULL
        'survival': test_old.get('isSurvival', False),
        'mark_collection': test_old.get('markCollection'),
        'minutes': test_old.get('minutes'),
        'time_spent_millis': test_old.get('timeSpentMillis'),
        'special_topic': test_old.get('specialTopic'),
        'special_topic_title': test_old.get('specialTopicTitle'),
        'difficulty_end': test_old.get('difficulty_end'),
        'number_of_lives': test_old.get('number_of_lives', 0),
        'created_at': test_old.get('updatedAt'),  # Usar updatedAt como created_at
        'updated_at': test_old.get('updatedAt'),
        # Campos nuevos con defaults
        'is_flashcard_mode': False,
        'duration_seconds': None,
        'topic_group_id': None,
        'total_time_seconds': 0,
        'survival_session_id': None,
        'time_attack_session_id': None,
        # Preservar ID original para mapeo con user_test_answers
        '_old_id': test_old.get('id')
    }

    return test_new, None

def main():
    """Función principal"""
    print("\n" + "="*60)
    print("🔄 TRANSFORMACIÓN DE USER_TESTS")
    print("="*60)

    conn = psycopg2.connect(DB_URL)

    try:
        # Cargar user_tests
        user_tests_old = load_json(DATA_FILES['user_tests'])
        print(f"\n📊 User_tests cargados: {len(user_tests_old):,}")

        # Obtener usuarios válidos
        print(f"\n📋 Cargando usuarios válidos...")
        valid_users = get_valid_users(conn)
        print(f"   ✓ {len(valid_users):,} usuarios válidos")

        # Transformar
        print(f"\n🔄 Transformando user_tests...")

        transformed = []
        skipped = []
        errors = []

        for test_old in tqdm(user_tests_old, desc="   Transformando"):
            test_new, error = transform_user_test(test_old, valid_users)

            if test_new:
                transformed.append(test_new)
            else:
                skipped.append(test_old.get('id'))
                if len(errors) < 20:
                    errors.append(f"Test {test_old.get('id')}: {error}")

        # Guardar transformados
        output_file = f'{TRANSFORMED_DIR}/user_tests.json'
        save_json(transformed, output_file)

        # Guardar mapeo old_id → para referencia
        id_mapping = {test['_old_id']: i for i, test in enumerate(transformed)}
        save_json(id_mapping, f'{TRANSFORMED_DIR}/user_tests_id_mapping.json')

        print(f"\n   ✓ Transformados: {len(transformed):,}")
        print(f"   ⚠️  Omitidos: {len(skipped):,}")

        if errors:
            print(f"\n   📋 Primeros errores:")
            for error in errors[:10]:
                print(f"      - {error}")

        print(f"\n   ✓ Guardado en: {output_file}")

        print("\n" + "="*60)
        if len(skipped) == 0:
            print("✓ TRANSFORMACIÓN COMPLETADA EXITOSAMENTE")
        else:
            print("⚠️ TRANSFORMACIÓN COMPLETADA CON ADVERTENCIAS")
        print("="*60)

        return len(errors) == 0

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

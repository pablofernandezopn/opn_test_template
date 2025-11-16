#!/usr/bin/env python3
"""
Carga flashcards transformadas a la BD nueva
1. Crear topic_type "Flashcards"
2. Cargar topics de flashcards
3. Actualizar mapeo stack_id → topic_id
4. Cargar questions de flashcards
"""
import json
import sys
import psycopg2
import psycopg2.extras
from tqdm import tqdm

sys.path.append('.')
from config import TRANSFORMED_FILES

DB_URL = "postgresql://postgres:postgres@127.0.0.1:54322/postgres"

def load_json(filepath):
    """Cargar JSON"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_json(data, filepath):
    """Guardar JSON"""
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def create_topic_type_flashcards(conn):
    """Crear topic_type 'Flashcards'"""
    print("\n📋 Creando topic_type 'Flashcards'...")

    cur = conn.cursor()

    # Verificar si ya existe
    cur.execute("SELECT id FROM topic_type WHERE topic_type_name = 'Flashcards'")
    existing = cur.fetchone()

    if existing:
        topic_type_id = existing[0]
        print(f"   ℹ️  topic_type 'Flashcards' ya existe (ID: {topic_type_id})")
    else:
        # Crear
        cur.execute("""
            INSERT INTO topic_type (topic_type_name, description, level, default_number_options, penalty, time_by_question, created_at, updated_at)
            VALUES ('Flashcards', 'Tarjetas de estudio con dos caras', 'Flashcard', 2, 0, 1, NOW(), NOW())
            RETURNING id
        """)
        topic_type_id = cur.fetchone()[0]
        conn.commit()
        print(f"   ✓ topic_type 'Flashcards' creado (ID: {topic_type_id})")

    cur.close()
    return topic_type_id

def load_flashcard_topics(conn, topic_type_id):
    """
    Cargar topics de flashcards y actualizar mapeo

    Retorna: diccionario {old_stack_id: new_topic_id}
    """
    print("\n🎯 Cargando topics de flashcards...")

    topics = load_json(TRANSFORMED_FILES['flashcard_topics'])
    stack_mapping = load_json(TRANSFORMED_FILES['flashcard_stack_mapping'])

    cur = conn.cursor()
    inserted = 0
    id_mapping = {}  # {old_stack_id: new_topic_id}

    with tqdm(total=len(topics), desc="   Insertando topics", unit="topic") as pbar:
        for topic in topics:
            old_stack_id = topic.pop('old_stack_id')  # Remover campo temporal

            # Asignar topic_type_id
            topic['topic_type_id'] = topic_type_id

            # Insertar topic (sin especificar ID, se autogenera)
            columns = list(topic.keys())
            values = [topic[col] for col in columns]
            placeholders = ', '.join(['%s'] * len(columns))
            cols_str = ', '.join([f'"{col}"' if col == 'order' else col for col in columns])

            cur.execute(f"""
                INSERT INTO topic ({cols_str})
                VALUES ({placeholders})
                RETURNING id
            """, values)

            new_topic_id = cur.fetchone()[0]
            inserted += 1

            # Guardar mapeo
            id_mapping[old_stack_id] = new_topic_id

            # Actualizar stack_mapping
            if str(old_stack_id) in stack_mapping:
                stack_mapping[str(old_stack_id)]['new_topic_id'] = new_topic_id

            pbar.update(1)

    conn.commit()
    cur.close()

    # Guardar mapeo actualizado
    save_json(stack_mapping, TRANSFORMED_FILES['flashcard_stack_mapping'])

    print(f"   ✓ Insertados: {inserted} topics")
    print(f"   ✓ Mapeo actualizado y guardado")

    return id_mapping

def load_flashcard_questions(conn, id_mapping):
    """
    Cargar questions de flashcards

    1. Actualizar topic IDs en questions
    2. Insertar questions (trigger crea 2 opciones vacías)
    3. Actualizar opciones con contenido
    """
    print("\n📇 Cargando questions de flashcards...")

    questions = load_json(TRANSFORMED_FILES['flashcard_questions'])
    options_map = load_json(TRANSFORMED_FILES['flashcard_options'])

    # Actualizar topic IDs en questions
    print("   Actualizando topic IDs en questions...")
    for q in questions:
        old_topic = q['topic']
        if old_topic in id_mapping:
            q['topic'] = id_mapping[old_topic]
        else:
            print(f"\n   ⚠️ Question {q['id']} tiene topic={old_topic} sin mapeo")

    cur = conn.cursor()
    inserted = 0
    options_updated = 0
    errors = []

    print(f"   Insertando {len(questions)} questions...")

    with tqdm(total=len(questions), desc="   Insertando questions", unit="q") as pbar:
        for question in questions:
            try:
                # 1. Insertar question (trigger crea 2 opciones vacías)
                cur.execute("""
                    INSERT INTO questions (
                        id, question, tip, topic, article,
                        question_image_url, retro_image_url,
                        retro_audio_enable, retro_audio_text, retro_audio_url,
                        "order", published, shuffled,
                        num_answered, num_fails, num_empty,
                        challenge_by_tutor, challenge_reason,
                        academy_id, created_by, created_at, updated_at
                    ) VALUES (
                        %s, %s, %s, %s, %s,
                        %s, %s,
                        %s, %s, %s,
                        %s, %s, %s,
                        %s, %s, %s,
                        %s, %s,
                        %s, %s, %s, %s
                    )
                """, (
                    question['id'], question['question'], question['tip'],
                    question['topic'], question['article'],
                    question['question_image_url'], question['retro_image_url'],
                    question['retro_audio_enable'], question['retro_audio_text'],
                    question['retro_audio_url'],
                    question['order'], question['published'], question['shuffled'],
                    question['num_answered'], question['num_fails'], question['num_empty'],
                    question['challenge_by_tutor'], question['challenge_reason'],
                    question['academy_id'], question['created_by'],
                    question['created_at'], question['updated_at']
                ))

                inserted += 1

                # 2. Actualizar opciones creadas por trigger
                opciones = options_map.get(str(question['id']), [])

                for opcion in opciones:
                    cur.execute("""
                        UPDATE question_options
                        SET answer = %s, is_correct = %s
                        WHERE question_id = %s AND option_order = %s
                    """, (
                        opcion['answer'],
                        opcion['is_correct'],
                        question['id'],
                        opcion['order']
                    ))
                    options_updated += 1

                # Commit cada 100 registros
                if inserted % 100 == 0:
                    conn.commit()

            except Exception as e:
                conn.rollback()
                error_msg = f"Question {question.get('id', '?')}: {str(e)[:100]}"
                errors.append(error_msg)
                if len(errors) <= 5:
                    print(f"\n   ✗ {error_msg}")

            pbar.update(1)

    # Commit final
    conn.commit()
    cur.close()

    print(f"   ✓ Insertadas: {inserted} questions")
    print(f"   ✓ Actualizadas: {options_updated} opciones")

    if errors:
        print(f"   ⚠️ {len(errors)} errores encontrados")

    return len(errors) == 0

def main():
    """Función principal"""
    print("\n" + "="*60)
    print("📥 CARGA DE FLASHCARDS A BD NUEVA")
    print("="*60)

    conn = psycopg2.connect(DB_URL)

    try:
        # 1. Crear topic_type "Flashcards"
        topic_type_id = create_topic_type_flashcards(conn)

        # 2. Cargar topics de flashcards
        id_mapping = load_flashcard_topics(conn, topic_type_id)

        # 3. Cargar questions de flashcards
        success = load_flashcard_questions(conn, id_mapping)

        print("\n" + "="*60)
        if success:
            print("✓ CARGA COMPLETADA EXITOSAMENTE")
            print(f"   ✓ topic_type 'Flashcards' (ID: {topic_type_id})")
            print(f"   ✓ {len(id_mapping)} topics de flashcards")
            print(f"   ✓ 1,305 questions de flashcards (esperadas)")
        else:
            print("⚠️ CARGA COMPLETADA CON ERRORES")
        print("="*60)

        return success

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

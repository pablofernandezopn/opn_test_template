#!/usr/bin/env python3
"""
Script rápido para cargar topic_types, categories, topics y questions
Usa psycopg2 directamente, sin Supabase client
"""
import json
import sys
import psycopg2
import psycopg2.extras
from tqdm import tqdm

# Rutas de archivos
TRANSFORMED_FILES = {
    'topic_types': 'data/transformed/topic_types.json',
    'categories': 'data/transformed/categories.json',
    'topics': 'data/transformed/topics.json',
    'questions': 'data/transformed/questions.json',
    'question_options': 'data/transformed/question_options.json'
}

def load_json(filepath):
    """Cargar datos de archivo JSON"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"⚠️ Archivo no encontrado: {filepath}")
        return [] if filepath.endswith('.json') else {}
    except json.JSONDecodeError as e:
        print(f"✗ Error decodificando JSON en {filepath}: {e}")
        return [] if filepath.endswith('.json') else {}

def insert_batch(conn, table_name, records, batch_size=500):
    """Insertar registros en lotes usando psycopg2"""
    if not records:
        print(f"   ⚠️ No hay registros para insertar en {table_name}")
        return True

    print(f"\n📤 Insertando en {table_name}: {len(records):,} registros")

    cur = conn.cursor()
    inserted = 0
    errors = []

    with tqdm(total=len(records), desc=f"   Insertando {table_name}", unit="reg") as pbar:
        for i in range(0, len(records), batch_size):
            batch = records[i:i + batch_size]

            try:
                # Usar execute_values para inserción rápida
                if batch:
                    # Obtener nombres de columnas del primer registro
                    columns = list(batch[0].keys())
                    values = [[rec.get(col) for col in columns] for rec in batch]

                    # Construir query
                    cols_str = ', '.join([f'"{col}"' if col == 'order' else col for col in columns])
                    placeholders = ', '.join(['%s'] * len(columns))

                    query = f"INSERT INTO {table_name} ({cols_str}) VALUES ({placeholders})"

                    # Ejecutar batch
                    psycopg2.extras.execute_batch(cur, query, values)
                    conn.commit()

                    inserted += len(batch)

            except Exception as e:
                conn.rollback()
                error_msg = f"Lote {i//batch_size + 1}: {str(e)[:200]}"
                errors.append(error_msg)
                print(f"\n   ✗ {error_msg}")

            pbar.update(len(batch))

    cur.close()

    print(f"   ✓ Insertados: {inserted:,} / {len(records):,} registros")

    if errors:
        print(f"   ⚠️ {len(errors)} errores encontrados")

    return len(errors) == 0

def load_questions(conn):
    """
    Cargar questions y actualizar question_options

    1. Insertar question → trigger create_blank_question_options crea opciones vacías
    2. Actualizar opciones con contenido real (answer, is_correct)
    """
    questions = load_json(TRANSFORMED_FILES['questions'])
    options_map = load_json(TRANSFORMED_FILES['question_options'])

    if not questions:
        print("\n   ⚠️ No hay questions para cargar")
        return True

    print(f"\n📤 Cargando {len(questions):,} questions con opciones")

    cur = conn.cursor()
    inserted = 0
    options_updated = 0
    errors = []

    with tqdm(total=len(questions), desc="   Cargando questions", unit="q") as pbar:
        for question in questions:
            try:
                # 1. Insertar question (trigger crea opciones vacías)
                cur.execute("""
                    INSERT INTO questions (
                        id, question, tip, topic, article,
                        question_image_url, retro_image_url,
                        retro_audio_enable, retro_audio_text, retro_audio_url,
                        "order", published, shuffled,
                        num_answered, num_fails, num_empty,
                        challenge_by_tutor, challenge_reason,
                        academy_id, created_by
                    ) VALUES (
                        %s, %s, %s, %s, %s,
                        %s, %s,
                        %s, %s, %s,
                        %s, %s, %s,
                        %s, %s, %s,
                        %s, %s,
                        %s, %s
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
                    question['academy_id'], question['created_by']
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

    print(f"   ✓ Insertadas: {inserted:,} questions")
    print(f"   ✓ Actualizadas: {options_updated:,} opciones")

    if errors:
        print(f"   ⚠️ {len(errors)} errores encontrados")

    return len(errors) == 0

def main():
    """Función principal"""
    print("\n" + "="*60)
    print("📥 CARGA RÁPIDA DE DATOS")
    print("="*60)
    print("⚠️  topic_types → categories → topics → questions")
    print("="*60)

    # Conectar a BD local
    conn = psycopg2.connect("postgresql://postgres:postgres@127.0.0.1:54322/postgres")

    try:
        # Orden de carga (respetando Foreign Keys)
        load_sequence = [
            ('topic_type', TRANSFORMED_FILES['topic_types']),
            ('categories', TRANSFORMED_FILES['categories']),
            ('topic', TRANSFORMED_FILES['topics']),
        ]

        all_success = True

        # Cargar topic_types, categories, topics
        for table_name, file_path in load_sequence:
            data = load_json(file_path)
            success = insert_batch(conn, table_name, data)
            if not success:
                all_success = False
                print(f"   ⚠️ Carga de {table_name} tuvo errores")

        # Cargar questions (con lógica especial)
        if all_success:
            success = load_questions(conn)
            if not success:
                all_success = False
                print(f"   ⚠️ Carga de questions tuvo errores")

        print("\n" + "="*60)
        if all_success:
            print("✓ CARGA COMPLETADA EXITOSAMENTE")
            print("   ✓ topic_types, categories, topics y questions cargados")
        else:
            print("⚠️ CARGA COMPLETADA CON ERRORES")
        print("="*60)

        return all_success

    except Exception as e:
        print(f"\n✗ Error durante la carga: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        conn.close()

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)
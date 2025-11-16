#!/usr/bin/env python3
"""
Script rápido para cargar solo questions
Usa psycopg2 directamente, sin Supabase client
"""
import json
import sys
import psycopg2
from tqdm import tqdm

# Rutas de archivos
QUESTIONS_FILE = 'data/transformed/questions.json'
OPTIONS_MAP_FILE = 'data/transformed/question_options.json'

def load_json(filepath):
    """Cargar datos de archivo JSON"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"⚠️ Archivo no encontrado: {filepath}")
        return []
    except json.JSONDecodeError as e:
        print(f"✗ Error decodificando JSON en {filepath}: {e}")
        return []

def load_questions():
    """
    Cargar questions y actualizar question_options

    1. Insertar question → trigger create_blank_question_options crea opciones vacías
    2. Actualizar opciones con contenido real (answer, is_correct)
    """
    print("\n" + "="*60)
    print("📤 CARGA DE QUESTIONS")
    print("="*60)

    questions = load_json(QUESTIONS_FILE)
    options_map = load_json(OPTIONS_MAP_FILE)

    if not questions:
        print("\n   ⚠️ No hay questions para cargar")
        return False

    print(f"\n📤 Cargando {len(questions):,} questions con opciones")

    # Conectar a BD local usando psycopg2
    conn = psycopg2.connect("postgresql://postgres:postgres@127.0.0.1:54322/postgres")
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
                error_msg = f"Question {question['id']}: {str(e)[:100]}"
                errors.append(error_msg)
                if len(errors) <= 5:  # Solo mostrar primeros 5 errores
                    print(f"\n   ✗ {error_msg}")

            pbar.update(1)

    # Commit final
    conn.commit()
    cur.close()
    conn.close()

    print(f"\n   ✓ Insertadas: {inserted:,} questions")
    print(f"   ✓ Actualizadas: {options_updated:,} opciones")

    if errors:
        print(f"   ⚠️ {len(errors)} errores encontrados")
        for err in errors[:10]:  # Mostrar primeros 10 errores
            print(f"      - {err}")

    print("\n" + "="*60)
    if len(errors) == 0:
        print("✓ CARGA COMPLETADA EXITOSAMENTE")
    else:
        print("⚠️ CARGA COMPLETADA CON ERRORES")
    print("="*60)

    return len(errors) == 0

if __name__ == '__main__':
    try:
        success = load_questions()
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"\n✗ Error durante la carga: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
#!/usr/bin/env python3
"""
Transforma flashcards a la nueva estructura
- flash_cards_stack → topics
- flashcard → questions con 2 opciones
"""
import json
from datetime import datetime
from tqdm import tqdm
import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from config import DATA_FILES, TRANSFORMED_FILES, TARGET_ACADEMY_ID

def load_json(filepath):
    """Cargar JSON"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"⚠️ Archivo no encontrado: {filepath}")
        return []

def save_json(data, filepath):
    """Guardar JSON"""
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def transform_stacks_to_topics(stacks):
    """
    Transformar flash_cards_stack → topics

    NO usar el ID original del stack, dejar que se autogenere
    Guardar mapeo old_stack_id → nuevo_topic_id para usarlo en flashcards
    """
    print("\n🎯 Transformando stacks → topics...")

    topics = []
    stack_mapping = {}  # {old_stack_id: nuevo_topic_id} - se completará después de INSERT

    # Ordenar por ID para mantener consistencia
    stacks_sorted = sorted(stacks, key=lambda x: x['id'])

    for idx, stack in enumerate(tqdm(stacks_sorted, desc="   Transformando stacks"), start=1):
        topic = {
            # NO incluir 'id' - se autogenerará en la BD
            # Pero guardar el old_id para el mapeo posterior
            'old_stack_id': stack['id'],  # Para referencia temporal
            'topic_type_id': None,  # Se asignará después de crear topic_type "Flashcards"
            'topic_name': stack.get('name', f"Flashcard Stack {stack['id']}"),
            'description': '',
            'enabled': True,
            'is_premium': False,
            'is_hidden_but_premium': False,
            'published_at': datetime.now().isoformat(),
            'total_participants': 0,
            'total_questions': stack.get('num_cards', 0),
            'total_score': 0,
            'options': 2,  # ✅ Flashcards siempre tienen 2 opciones
            'max_score': 0,
            'min_score': 0,
            'academy_id': stack.get('academy', TARGET_ACADEMY_ID),
            'duration_seconds': 0,
            'image_url': None,
            'order': idx,  # Orden secuencial
            'category_id': None,
            'specialty_id': None,
            'topic_group_id': None,
            'group_order': None,
            'created_at': stack.get('created_at', datetime.now().isoformat()),
            'updated_at': datetime.now().isoformat()
        }

        topics.append(topic)

        # Guardar mapeo temporal (se completará después del INSERT)
        stack_mapping[stack['id']] = {
            'old_stack_id': stack['id'],
            'stack_name': stack.get('name', f"Stack {stack['id']}"),
            'num_cards': stack.get('num_cards', 0),
            'new_topic_id': None  # Se completará después del INSERT
        }

    print(f"   ✓ {len(topics)} topics de flashcards transformados")

    return topics, stack_mapping

def transform_flashcards_to_questions(flashcards, stack_mapping):
    """
    Transformar flashcard → questions con 2 opciones

    IMPORTANTE: Usar IDs altos para evitar conflictos con questions normales
    """
    print("\n📇 Transformando flashcards → questions...")

    questions = []
    options_map = {}  # {question_id: [{order, answer, is_correct}]}

    # Usar offset alto para IDs de flashcards (30000000+)
    ID_OFFSET = 30000000

    for fc in tqdm(flashcards, desc="   Transformando flashcards"):
        question_id = ID_OFFSET + fc['id']

        # Obtener topic_id del mapeo (por ahora usamos old_stack_id, se actualizará después)
        old_stack_id = fc.get('flash_card_stack')

        if old_stack_id not in stack_mapping:
            print(f"\n   ⚠️ Flashcard {fc['id']} tiene stack_id={old_stack_id} que no existe en stacks")
            continue

        question = {
            'id': question_id,
            'question': fc.get('flash_card_question', ''),  # Pregunta/Front
            'tip': '',
            'topic': old_stack_id,  # TEMPORAL: Se actualizará después con new_topic_id
            'article': None,
            'question_image_url': '',
            'retro_image_url': '',
            'retro_audio_enable': False,
            'retro_audio_text': '',
            'retro_audio_url': '',
            'order': fc.get('order', 0),
            'published': True,
            'shuffled': False,  # ✅ NO mezclar flashcards
            'num_answered': 0,
            'num_fails': 0,
            'num_empty': 0,
            'challenge_by_tutor': False,
            'challenge_reason': None,
            'academy_id': TARGET_ACADEMY_ID,
            'created_by': None,
            'created_at': fc.get('created_at', datetime.now().isoformat()),
            'updated_at': datetime.now().isoformat()
        }

        questions.append(question)

        # Crear 2 opciones (2 caras de la flashcard)
        options = [
            {
                'order': 1,
                'answer': fc.get('flash_card_question', ''),  # Cara 1 (front/pregunta)
                'is_correct': False  # No hay respuesta "correcta" en flashcards
            },
            {
                'order': 2,
                'answer': fc.get('flash_card_answer', ''),  # Cara 2 (back/respuesta)
                'is_correct': False  # No hay respuesta "correcta" en flashcards
            }
        ]

        options_map[str(question_id)] = options

    print(f"   ✓ {len(questions)} flashcards transformadas")
    print(f"   ✓ {len(questions) * 2} opciones preparadas")

    return questions, options_map

def main():
    """Función principal"""
    print("\n" + "="*60)
    print("🔄 TRANSFORMACIÓN DE FLASHCARDS")
    print("="*60)

    try:
        # Cargar datos
        stacks = load_json(DATA_FILES['flash_cards_stack'])
        flashcards = load_json(DATA_FILES['flashcards'])

        print(f"\n📊 Datos cargados:")
        print(f"   - {len(stacks)} flash_cards_stacks")
        print(f"   - {len(flashcards)} flashcards")

        # Transformar stacks → topics
        topics, stack_mapping = transform_stacks_to_topics(stacks)

        # Transformar flashcards → questions
        questions, options_map = transform_flashcards_to_questions(flashcards, stack_mapping)

        # Guardar
        save_json(topics, TRANSFORMED_FILES['flashcard_topics'])
        save_json(questions, TRANSFORMED_FILES['flashcard_questions'])
        save_json(options_map, TRANSFORMED_FILES['flashcard_options'])
        save_json(stack_mapping, TRANSFORMED_FILES['flashcard_stack_mapping'])

        print("\n" + "="*60)
        print("✓ TRANSFORMACIÓN COMPLETADA")
        print(f"   ✓ {len(topics)} topics de flashcards")
        print(f"   ✓ {len(questions)} questions de flashcards")
        print(f"   ✓ Mapeo de stacks guardado")
        print("="*60)
        print("\n⚠️ NOTA: Los IDs de topics se asignarán en la BD")
        print("   El mapeo stack_id → topic_id se completará después del INSERT")

        return True

    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)

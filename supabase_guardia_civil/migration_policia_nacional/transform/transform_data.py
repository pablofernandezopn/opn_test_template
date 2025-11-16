"""
Transforma datos de la estructura antigua a la nueva
Aplica mapeos, conversiones y crea nuevas estructuras
"""
import json
import sys
import os
from datetime import datetime
from tqdm import tqdm

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import (
    DATA_FILES, TRANSFORMED_FILES, TOPIC_TYPES,
    TARGET_ACADEMY_ID, TARGET_SPECIALTY_ID
)

class DataTransformer:
    def __init__(self):
        self.topic_type_map = {}  # topic_type_name -> id
        self.question_options_map = {}  # question_id -> [option_ids]

    def load_json(self, filepath):
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

    def save_json(self, data, filepath):
        """Guardar datos a archivo JSON"""
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

    def determine_topic_type_name(self, topic):
        """
        Determina el nombre del topic_type según los flags del topic antiguo

        Prioridad:
        1. isPsychoTechnical → "Psicotécnicos"
        2. isOfficial → "Exámenes Oficiales"
        3. isSpecial → "Test Especiales"
        4. number <= 45 → "Bloque de Temario"
        5. isMock → "Simulacros"
        6. default → "Simulacros"
        """
        if topic.get('isPsychoTechnical'):
            return 'Psicotécnicos'
        elif topic.get('isOfficial'):
            return 'Exámenes Oficiales'
        elif topic.get('isSpecial'):
            return 'Test Especiales'
        elif topic.get('number', 0) <= 45:
            return 'Bloque de Temario'
        elif topic.get('isMock'):
            return 'Simulacros'
        else:
            return 'Simulacros'

    def transform_topic_types(self):
        """
        Crear topic_types (no existen en BD antigua)
        Los IDs se asignarán en orden: 1, 2, 3, 4, 5
        """
        print("\n📋 Transformando topic_types...")

        topic_types = []
        for idx, tt in enumerate(TOPIC_TYPES, start=1):
            topic_type = {
                'id': idx,
                'topic_type_name': tt['topic_type_name'],
                'description': tt['description'],
                'level': tt['level'],
                'default_number_options': tt['default_number_options'],
                'penalty': tt['penalty'],
                'time_by_question': tt['time_by_question'],
                'order_of_appearance': tt['order_of_appearance'],
                'created_at': datetime.now().isoformat(),
                'updated_at': datetime.now().isoformat()
            }
            topic_types.append(topic_type)
            self.topic_type_map[tt['topic_type_name']] = idx

        self.save_json(topic_types, TRANSFORMED_FILES['topic_types'])
        print(f"   ✓ {len(topic_types)} topic_types creados")
        print(f"   Mapeo: {self.topic_type_map}")
        return topic_types

    def transform_categories(self):
        """
        Transformar categories
        antigua.categories → nueva.categories
        """
        print("\n📁 Transformando categories...")

        old_categories = self.load_json(DATA_FILES['categories'])
        new_categories = []

        # Por defecto asignar topic_type "Bloque de Temario"
        default_topic_type_id = self.topic_type_map['Bloque de Temario']

        for cat in tqdm(old_categories, desc="   Procesando categories"):
            new_cat = {
                'id': cat['id'],
                'name': cat['name'],
                'topic_type': default_topic_type_id,  # FK a topic_type
                'created_at': datetime.now().isoformat(),
                'updated_at': datetime.now().isoformat()
            }
            new_categories.append(new_cat)

        self.save_json(new_categories, TRANSFORMED_FILES['categories'])
        print(f"   ✓ {len(new_categories)} categories transformadas")
        return new_categories

    def transform_topics(self):
        """
        Transformar topics
        antigua.topics → nueva.topic

        IMPORTANTE: El order se calcula en función de la posición del topic
        dentro de cada topic_type_id, ordenado por id ascendente.
        """
        print("\n🎯 Transformando topics...")

        old_topics = self.load_json(DATA_FILES['topics'])
        new_topics = []

        # Primera pasada: crear topics con order temporal
        for topic in tqdm(old_topics, desc="   Procesando topics"):
            # Determinar topic_type
            topic_type_name = self.determine_topic_type_name(topic)
            topic_type_id = self.topic_type_map[topic_type_name]

            new_topic = {
                'id': topic['id'],
                'topic_type_id': topic_type_id,
                'topic_name': topic['name'],
                'description': None,
                'enabled': not topic.get('isHidden', False),
                'is_premium': topic.get('isPremium', False),
                'is_hidden_but_premium': topic.get('isHidden', False) and topic.get('isPremium', False),
                'published_at': datetime.now().isoformat(),
                'total_participants': 0,
                'total_questions': topic.get('questions', 0),
                'total_score': 0,
                'created_at': datetime.now().isoformat(),
                'updated_at': datetime.now().isoformat(),
                'options': topic.get('options', 3),
                'max_score': 0,
                'min_score': 0,
                'academy_id': TARGET_ACADEMY_ID,
                'duration_seconds': (topic.get('minutes', 0) or 0) * 60,
                'image_url': None,
                'order': 100,  # Temporal, se calculará después
                'category_id': topic.get('category'),
                'specialty_id': TARGET_SPECIALTY_ID,
                'topic_group_id': None,
                'group_order': None
            }
            new_topics.append(new_topic)

        # Segunda pasada: calcular order correcto
        # Agrupar por topic_type_id y ordenar por id
        from collections import defaultdict
        topics_by_type = defaultdict(list)

        for topic in new_topics:
            topics_by_type[topic['topic_type_id']].append(topic)

        # Asignar order secuencial dentro de cada tipo
        for topic_type_id, topics in topics_by_type.items():
            # Ordenar por id
            topics.sort(key=lambda t: t['id'])
            # Asignar order secuencial (1, 2, 3...)
            for idx, topic in enumerate(topics, start=1):
                topic['order'] = idx

        self.save_json(new_topics, TRANSFORMED_FILES['topics'])
        print(f"   ✓ {len(new_topics)} topics transformados")
        print(f"   ✓ Order calculado por topic_type (secuencial por id)")
        return new_topics

    def transform_questions(self):
        """
        Transformar questions
        antigua.questions → nueva.questions

        IMPORTANTE: Las opciones se crearán automáticamente por el trigger
        create_blank_question_options al insertar cada pregunta.
        Aquí solo guardamos el mapeo de contenido para actualizar después.
        """
        print("\n❓ Transformando questions...")

        old_questions = self.load_json(DATA_FILES['questions'])
        new_questions = []
        question_options_map = {}  # question_id → [{order, answer, is_correct}]

        # Calcular order por topic (igual que con topics)
        from collections import defaultdict
        questions_by_topic = defaultdict(list)
        for q in old_questions:
            questions_by_topic[q['topic']].append(q)

        # Asignar order secuencial dentro de cada topic
        for topic_id, questions in questions_by_topic.items():
            questions.sort(key=lambda q: q['id'])
            for idx, question in enumerate(questions, start=1):
                question['calculated_order'] = idx

        for q in tqdm(old_questions, desc="   Procesando questions"):
            # Determinar número de opciones (3 o 4)
            num_options = 3 if not q.get('answer4') else 4

            # Transformar question (solo metadatos)
            new_q = {
                'id': q['id'],
                'question': q['question'],
                'tip': q.get('tip', ''),
                'topic': q['topic'],
                'article': q.get('article'),
                'question_image_url': '',  # TODO: mapear si image=true
                'retro_image_url': '',     # TODO: mapear si retro_image=true
                'retro_audio_enable': q.get('retro_audio', False),
                'retro_audio_text': q.get('retro_text', ''),
                'retro_audio_url': '',
                'order': q.get('calculated_order', 0),
                'published': q.get('publised', True),
                'shuffled': q.get('shuffled', False),
                'num_answered': q.get('num_answered', 0),
                'num_fails': q.get('num_fails', 0),
                'num_empty': q.get('num_empty', 0),
                'created_at': datetime.now().isoformat(),
                'updated_at': datetime.now().isoformat(),
                'created_by': None,  # TODO: mapear si existe
                'challenge_by_tutor': q.get('challenge_by_tutor', False),
                'challenge_reason': q.get('challenge_reason'),
                'academy_id': TARGET_ACADEMY_ID
            }
            new_questions.append(new_q)

            # Guardar contenido de opciones para actualizar después
            # El trigger creará las opciones vacías, nosotros las actualizaremos
            solution = q.get('solution', 1)  # 1-indexed
            opciones = [
                {'order': 1, 'answer': q.get('answer1', ''), 'is_correct': (solution == 1)},
                {'order': 2, 'answer': q.get('answer2', ''), 'is_correct': (solution == 2)},
                {'order': 3, 'answer': q.get('answer3', ''), 'is_correct': (solution == 3)},
            ]

            if num_options == 4:
                opciones.append({
                    'order': 4,
                    'answer': q.get('answer4', ''),
                    'is_correct': (solution == 4)
                })

            question_options_map[q['id']] = opciones

        self.save_json(new_questions, TRANSFORMED_FILES['questions'])
        self.save_json(question_options_map, TRANSFORMED_FILES['question_options'])

        print(f"   ✓ {len(new_questions)} questions transformadas")
        print(f"   ✓ {sum(len(opts) for opts in question_options_map.values())} opciones preparadas para actualización")
        print(f"   ✓ Order calculado por topic (secuencial por id)")

        return new_questions, question_options_map

    def transform_users(self):
        """
        Transformar users
        antigua.users → nueva.users
        """
        print("\n👥 Transformando users...")

        old_users = self.load_json(DATA_FILES['users'])
        new_users = []

        for user in tqdm(old_users, desc="   Procesando users"):
            new_user = {
                'id': user['id'],
                'username': user['username'],
                'email': None,
                'first_name': None,
                'last_name': None,
                'phone': None,
                'totalQuestions': user.get('totalQuestions', 0),
                'rightQuestions': user.get('rightQuestions', 0),
                'wrongQuestions': user.get('wrongQuestions', 0),
                'tester': False,
                'lastUsed': None,
                'fcm_token': None,
                'fid_token': None,
                'profile_image': None,
                'unlocked_at': None,
                'unlock_duration_minutes': 0,
                'enabled': user.get('enabled', True),
                'tutorial': False,
                'createdAt': user.get('createdAt'),
                'updatedAt': user.get('updatedAt'),
                'wordpress_user_id': None,
                'display_name': None,
                'academy_id': TARGET_ACADEMY_ID,
                'specialty_id': TARGET_SPECIALTY_ID,
                'question_goal': user.get('goal', 50),
                'deleted': False,
                'deleted_at': None
            }
            new_users.append(new_user)

        self.save_json(new_users, TRANSFORMED_FILES['users'])
        print(f"   ✓ {len(new_users)} users transformados")
        return new_users

    def transform_user_tests(self):
        """
        Transformar user_tests
        antigua.user_tests → nueva.user_tests
        """
        print("\n📝 Transformando user_tests...")

        old_tests = self.load_json(DATA_FILES['user_tests'])
        new_tests = []

        for test in tqdm(old_tests, desc="   Procesando user_tests"):
            # Calcular campos derivados
            question_count = len(test.get('questions', []))
            total_answered = test.get('rightQuestions', 0) + test.get('wrongQuestions', 0)

            new_test = {
                'id': test['id'],
                'user_id': test['userId'],
                'topic_ids': test.get('topics', []),
                'options': test.get('options', 4),
                'right_questions': test.get('rightQuestions', 0),
                'wrong_questions': test.get('wrongQuestions', 0),
                'question_count': question_count,
                'total_answered': total_answered,
                'score': None,
                'finalized': test.get('finalized', False),
                'visible': True,
                'study_mode': test.get('studyMode', False),
                'study_failed': test.get('studyFailed', False),
                'study_white': test.get('studyWhite', False),
                'mock': None,
                'survival': False,
                'mark_collection': None,
                'minutes': test.get('minutes'),
                'time_spent_millis': test.get('timeSpentMillis'),
                'special_topic': test.get('specialTopic'),
                'special_topic_title': None,
                'difficulty_end': None,
                'number_of_lives': 0,
                'created_at': datetime.now().isoformat(),
                'updated_at': test.get('updatedAt'),
                'is_flashcard_mode': False,
                'duration_seconds': (test.get('minutes', 0) or 0) * 60,
                'topic_group_id': None
            }
            new_tests.append(new_test)

        self.save_json(new_tests, TRANSFORMED_FILES['user_tests'])
        print(f"   ✓ {len(new_tests)} user_tests transformados")
        return new_tests

    def transform_user_test_answers(self):
        """
        Transformar user_test_answers
        antigua.user_test_answers → nueva.user_test_answers

        IMPORTANTE: Mapear answer (int) → selected_option_id
        """
        print("\n✍️ Transformando user_test_answers...")

        old_answers = self.load_json(DATA_FILES['user_test_answers'])
        old_tests = self.load_json(DATA_FILES['user_tests'])

        # Crear índice de tests para obtener el orden de las preguntas
        tests_index = {t['id']: t for t in old_tests}

        new_answers = []

        for ans in tqdm(old_answers, desc="   Procesando user_test_answers"):
            question_id = ans['question']
            answer_num = ans.get('answer')  # 1, 2, 3, 4 o None

            # Obtener las opciones de esta pregunta
            question_options = self.question_options_map.get(question_id, [])

            # Mapear answer (1-4) al option_id correspondiente
            selected_option_id = None
            if answer_num and 1 <= answer_num <= len(question_options):
                # answer es 1-indexed, lista es 0-indexed
                selected_option_id = question_options[answer_num - 1]

            # Calcular question_order del array questions del test
            test = tests_index.get(ans['userTestId'])
            question_order = 0
            if test and 'questions' in test:
                try:
                    question_order = test['questions'].index(question_id)
                except ValueError:
                    question_order = 0

            new_ans = {
                'id': ans['id'],
                'user_test_id': ans['userTestId'],
                'question_id': question_id,
                'selected_option_id': selected_option_id,
                'correct': None,  # Se calculará en la carga
                'time_taken_seconds': None,
                'question_order': question_order,
                'challenge_by_tutor': False,
                'answered_at': datetime.now().isoformat(),
                'difficulty_rating': None,
                'next_review_date': None,
                'review_interval_days': 1,
                'ease_factor': 2.50,
                'repetitions': 0,
                'time': None
            }
            new_answers.append(new_ans)

        self.save_json(new_answers, TRANSFORMED_FILES['user_test_answers'])
        print(f"   ✓ {len(new_answers)} user_test_answers transformados")
        return new_answers

    def transform_user_favorite_questions(self):
        """
        Transformar users_favorite_questions
        antigua.users_favorite_questions → nueva.user_favorite_questions
        """
        print("\n⭐ Transformando user_favorite_questions...")

        old_favs = self.load_json(DATA_FILES['user_favorite_questions'])
        new_favs = []

        for fav in tqdm(old_favs, desc="   Procesando favorites"):
            new_fav = {
                'id': None,  # Se auto-generará
                'user_id': fav['userId'],
                'question_id': fav['questionId'],
                'created_at': fav.get('createdAt', datetime.now().isoformat())
            }
            new_favs.append(new_fav)

        self.save_json(new_favs, TRANSFORMED_FILES['user_favorite_questions'])
        print(f"   ✓ {len(new_favs)} user_favorite_questions transformados")
        return new_favs

    def transform_all(self):
        """Ejecutar todas las transformaciones"""
        print("\n" + "="*60)
        print("🔄 TRANSFORMACIÓN DE DATOS")
        print("="*60)
        print("⚠️  MIGRACIÓN: topic_types, categories, topics y questions")
        print("="*60)

        try:
            # Orden de transformaciones
            self.transform_topic_types()
            self.transform_categories()  # Necesario para FK de topics
            self.transform_topics()
            self.transform_questions()  # NUEVO: Transformar questions

            # TODO: Pendientes de compatibilizar
            # self.transform_users()
            # self.transform_user_tests()
            # self.transform_user_test_answers()
            # self.transform_user_favorite_questions()

            print("\n" + "="*60)
            print("✓ TRANSFORMACIÓN COMPLETADA")
            print("   ✓ topic_types, categories, topics y questions transformados")
            print("   ⏸️  Pendientes: users, tests, answers...")
            print("="*60)
            return True

        except Exception as e:
            print(f"\n✗ Error durante transformación: {e}")
            import traceback
            traceback.print_exc()
            return False

def main():
    """Función principal"""
    transformer = DataTransformer()
    success = transformer.transform_all()
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
"""
Configuración para la migración de Policía Nacional
"""
import os
from dotenv import load_dotenv

load_dotenv()

# ============================================
# BASE DE DATOS ANTIGUA (Policía Nacional - DONANTE REMOTA)
# ============================================
OLD_DB_CONFIG = {
    'url': os.getenv('OLD_DB_URL', ''),  # Supabase URL remota
    'key': os.getenv('OLD_DB_KEY', ''),  # Supabase service key remota
}

# ============================================
# BASE DE DATOS NUEVA (Guardia Civil)
# ============================================
# NOTA: Estas credenciales deben ser proporcionadas
NEW_DB_CONFIG = {
    'url': os.getenv('NEW_DB_URL', ''),  # Supabase URL
    'key': os.getenv('NEW_DB_KEY', ''),  # Supabase anon/service key
}

# ============================================
# CONFIGURACIÓN DE MIGRACIÓN
# ============================================
BATCH_SIZE = 500  # Registros por lote
TARGET_ACADEMY_ID = 1  # Policía Nacional
TARGET_SPECIALTY_ID = None  # NULL por defecto

# FORCE: Si True, fuerza descarga de datos aunque ya existan
# Si False, usa datos existentes si están disponibles
FORCE_DOWNLOAD = os.getenv('FORCE_DOWNLOAD', 'False').lower() in ('true', '1', 'yes')

# ============================================
# TOPIC_TYPES CONFIGURATION
# ============================================
TOPIC_TYPES = [
    {
        'topic_type_name': 'Bloque de Temario',
        'description': 'Bloques de temario para estudio secuencial',
        'level': 'Study',
        'default_number_options': 3,
        'penalty': 0.5,
        'time_by_question': 0.5,
        'order_of_appearance': 1
    },
    {
        'topic_type_name': 'Simulacros',
        'description': 'Simulacros de examen completo',
        'level': 'Mock',
        'default_number_options': 3,
        'penalty': 0.5,
        'time_by_question': 0.5,
        'order_of_appearance': 2
    },
    {
        'topic_type_name': 'Psicotécnicos',
        'description': 'Test psicotécnicos y de aptitudes',
        'level': 'Mock',
        'default_number_options': 4,  # ← ÚNICO con 4 opciones
        'penalty': 0.5,
        'time_by_question': 0.5,
        'order_of_appearance': 3
    },
    {
        'topic_type_name': 'Exámenes Oficiales',
        'description': 'Exámenes oficiales de convocatorias anteriores',
        'level': 'Mock',
        'default_number_options': 3,
        'penalty': 0.5,
        'time_by_question': 0.5,
        'order_of_appearance': 4
    },
    {
        'topic_type_name': 'Test Especiales',
        'description': 'Test especiales y de repaso',
        'level': 'Mock',
        'default_number_options': 3,
        'penalty': 0.5,
        'time_by_question': 0.5,
        'order_of_appearance': 5
    }
]

# ============================================
# ARCHIVOS DE DATOS
# ============================================
DATA_DIR = 'data'
TRANSFORMED_DIR = 'data/transformed'
LOG_DIR = 'logs'

DATA_FILES = {
    'categories': f'{DATA_DIR}/categories.json',
    'topics': f'{DATA_DIR}/topics.json',
    'questions': f'{DATA_DIR}/questions.json',
    'users': f'{DATA_DIR}/users.json',
    'user_tests': f'{DATA_DIR}/user_tests.json',
    'user_test_answers': f'{DATA_DIR}/user_test_answers.json',
    'user_favorite_questions': f'{DATA_DIR}/user_favorite_questions.json',
    'flash_cards_stack': f'{DATA_DIR}/flash_cards_stack.json',
    'flashcards': f'{DATA_DIR}/flashcards.json',
    'cms_users': f'{DATA_DIR}/cms_users.json',
    'challenges': f'{DATA_DIR}/challenges.json',
}

TRANSFORMED_FILES = {
    'topic_types': f'{TRANSFORMED_DIR}/topic_types.json',
    'categories': f'{TRANSFORMED_DIR}/categories.json',
    'topics': f'{TRANSFORMED_DIR}/topics.json',
    'questions': f'{TRANSFORMED_DIR}/questions.json',
    'question_options': f'{TRANSFORMED_DIR}/question_options.json',
    'users': f'{TRANSFORMED_DIR}/users.json',
    'user_tests': f'{TRANSFORMED_DIR}/user_tests.json',
    'user_test_answers': f'{TRANSFORMED_DIR}/user_test_answers.json',
    'user_favorite_questions': f'{TRANSFORMED_DIR}/user_favorite_questions.json',
    'flashcard_topics': f'{TRANSFORMED_DIR}/flashcard_topics.json',
    'flashcard_questions': f'{TRANSFORMED_DIR}/flashcard_questions.json',
    'flashcard_options': f'{TRANSFORMED_DIR}/flashcard_options.json',
    'flashcard_stack_mapping': f'{TRANSFORMED_DIR}/flashcard_stack_mapping.json',
}
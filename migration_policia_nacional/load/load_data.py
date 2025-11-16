"""
Carga datos transformados a la base de datos nueva (Guardia Civil)
Usa Supabase client para inserción por lotes
"""
import json
import sys
import os
from tqdm import tqdm
from supabase import create_client, Client
import psycopg2
import psycopg2.extras

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import NEW_DB_CONFIG, TRANSFORMED_FILES, BATCH_SIZE

class NewDBLoader:
    def __init__(self):
        self.client: Client = None
        self.question_options_correct_map = {}  # option_id -> is_correct

    def connect(self):
        """Conectar a Supabase"""
        try:
            if not NEW_DB_CONFIG['url'] or not NEW_DB_CONFIG['key']:
                print("✗ Error: NEW_DB_URL y NEW_DB_KEY deben estar configurados en .env")
                return False

            self.client = create_client(
                NEW_DB_CONFIG['url'],
                NEW_DB_CONFIG['key']
            )
            print("✓ Conectado a base de datos nueva (Guardia Civil)")
            return True

        except Exception as e:
            print(f"✗ Error conectando a BD nueva: {e}")
            return False

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

    def insert_batch(self, table_name, records, batch_size=BATCH_SIZE):
        """
        Insertar registros en lotes

        Args:
            table_name: Nombre de la tabla
            records: Lista de registros a insertar
            batch_size: Tamaño del lote
        """
        if not records:
            print(f"   ⚠️ No hay registros para insertar en {table_name}")
            return True

        total = len(records)
        print(f"\n📤 Insertando en {table_name}: {total:,} registros")

        inserted = 0
        errors = []

        with tqdm(total=total, desc=f"   Insertando {table_name}", unit="reg") as pbar:
            for i in range(0, total, batch_size):
                batch = records[i:i + batch_size]

                try:
                    # Insertar lote
                    response = self.client.table(table_name).insert(batch).execute()

                    # Verificar respuesta
                    if hasattr(response, 'data') and response.data:
                        inserted += len(batch)
                    else:
                        errors.append(f"Lote {i//batch_size + 1}: Sin datos en respuesta")

                except Exception as e:
                    error_msg = f"Lote {i//batch_size + 1}: {str(e)}"
                    errors.append(error_msg)
                    print(f"\n   ✗ {error_msg}")

                pbar.update(len(batch))

        print(f"   ✓ Insertados: {inserted:,} / {total:,} registros")

        if errors:
            print(f"   ⚠️ {len(errors)} errores encontrados")
            for err in errors[:5]:  # Mostrar primeros 5 errores
                print(f"      - {err}")

        return len(errors) == 0

    def load_topic_types(self):
        """Cargar topic_types"""
        data = self.load_json(TRANSFORMED_FILES['topic_types'])
        return self.insert_batch('topic_type', data)

    def load_categories(self):
        """Cargar categories"""
        data = self.load_json(TRANSFORMED_FILES['categories'])
        return self.insert_batch('categories', data)

    def load_topics(self):
        """Cargar topics"""
        data = self.load_json(TRANSFORMED_FILES['topics'])
        return self.insert_batch('topic', data)

    def load_questions(self):
        """
        Cargar questions y actualizar question_options

        1. Insertar question → trigger create_blank_question_options crea opciones vacías
        2. Recuperar IDs de opciones creadas por el trigger
        3. Actualizar opciones con contenido real (answer, is_correct)
        """
        questions = self.load_json(TRANSFORMED_FILES['questions'])
        options_map = self.load_json(TRANSFORMED_FILES['question_options'])

        if not questions:
            print("\n   ⚠️ No hay questions para cargar")
            return True

        print(f"\n📤 Cargando {len(questions):,} questions con opciones")

        # Usar psycopg2 directamente para mejor control
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

        print(f"   ✓ Insertadas: {inserted:,} questions")
        print(f"   ✓ Actualizadas: {options_updated:,} opciones")

        if errors:
            print(f"   ⚠️ {len(errors)} errores encontrados")

        return len(errors) == 0

    def load_question_options(self):
        """Cargar question_options y crear mapeo de correctas"""
        data = self.load_json(TRANSFORMED_FILES['question_options'])

        # Crear mapeo option_id -> is_correct para usar en user_test_answers
        for opt in data:
            self.question_options_correct_map[opt['id']] = opt['is_correct']

        return self.insert_batch('question_options', data)

    def load_users(self):
        """Cargar users"""
        data = self.load_json(TRANSFORMED_FILES['users'])
        return self.insert_batch('users', data)

    def load_user_tests(self):
        """Cargar user_tests"""
        data = self.load_json(TRANSFORMED_FILES['user_tests'])
        return self.insert_batch('user_tests', data)

    def load_user_test_answers(self):
        """
        Cargar user_test_answers
        Calcular campo 'correct' basándose en question_options.is_correct
        """
        data = self.load_json(TRANSFORMED_FILES['user_test_answers'])

        # Calcular campo 'correct' para cada respuesta
        for ans in data:
            selected_option_id = ans.get('selected_option_id')
            if selected_option_id:
                ans['correct'] = self.question_options_correct_map.get(selected_option_id, False)
            else:
                ans['correct'] = None  # No respondida

        return self.insert_batch('user_test_answers', data)

    def load_user_favorite_questions(self):
        """Cargar user_favorite_questions"""
        data = self.load_json(TRANSFORMED_FILES['user_favorite_questions'])

        # Remover campo 'id' ya que se auto-genera
        for fav in data:
            if 'id' in fav:
                del fav['id']

        return self.insert_batch('user_favorite_questions', data)

    def load_all(self):
        """Cargar todas las tablas en orden correcto (respetando FKs)"""
        print("\n" + "="*60)
        print("📥 CARGA DE DATOS A BASE DE DATOS NUEVA")
        print("="*60)
        print("⚠️  MIGRACIÓN: topic_types, categories, topics y questions")
        print("="*60)

        # Orden de carga (respetando Foreign Keys)
        load_sequence = [
            ('topic_types', self.load_topic_types),
            ('categories', self.load_categories),
            ('topics', self.load_topics),
            ('questions', self.load_questions),  # NUEVO: Carga questions + opciones
        ]

        # TODO: Pendientes de compatibilizar
        # ('users', self.load_users),
        # ('user_tests', self.load_user_tests),
        # ('user_test_answers', self.load_user_test_answers),
        # ('user_favorite_questions', self.load_user_favorite_questions),

        all_success = True

        for name, load_func in load_sequence:
            try:
                success = load_func()
                if not success:
                    all_success = False
                    print(f"   ⚠️ Carga de {name} tuvo errores")
            except Exception as e:
                all_success = False
                print(f"   ✗ Error cargando {name}: {e}")
                import traceback
                traceback.print_exc()

        print("\n" + "="*60)
        if all_success:
            print("✓ CARGA COMPLETADA EXITOSAMENTE")
            print("   ✓ topic_types, categories, topics y questions cargados")
            print("   ⏸️  Pendientes: users, tests, answers...")
        else:
            print("⚠️ CARGA COMPLETADA CON ERRORES")
        print("="*60)

        return all_success

def main():
    """Función principal"""
    loader = NewDBLoader()

    try:
        # Conectar
        if not loader.connect():
            return False

        # Cargar todas las tablas
        success = loader.load_all()

        return success

    except Exception as e:
        print(f"\n✗ Error durante la carga: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)
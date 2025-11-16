"""
Valida la migración comparando datos entre BD antigua y nueva
"""
import psycopg2
from psycopg2.extras import RealDictCursor
from supabase import create_client, Client
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import OLD_DB_CONFIG, NEW_DB_CONFIG

class MigrationValidator:
    def __init__(self):
        self.old_conn = None
        self.old_cursor = None
        self.new_client: Client = None
        self.validation_results = []

    def connect_old_db(self):
        """Conectar a BD antigua"""
        try:
            self.old_conn = psycopg2.connect(
                host=OLD_DB_CONFIG['host'],
                port=OLD_DB_CONFIG['port'],
                database=OLD_DB_CONFIG['database'],
                user=OLD_DB_CONFIG['user'],
                password=OLD_DB_CONFIG['password']
            )
            self.old_cursor = self.old_conn.cursor(cursor_factory=RealDictCursor)
            print("✓ Conectado a BD antigua")
            return True
        except Exception as e:
            print(f"✗ Error conectando a BD antigua: {e}")
            return False

    def connect_new_db(self):
        """Conectar a BD nueva"""
        try:
            if not NEW_DB_CONFIG['url'] or not NEW_DB_CONFIG['key']:
                print("✗ Error: NEW_DB_URL y NEW_DB_KEY requeridos")
                return False

            self.new_client = create_client(
                NEW_DB_CONFIG['url'],
                NEW_DB_CONFIG['key']
            )
            print("✓ Conectado a BD nueva")
            return True
        except Exception as e:
            print(f"✗ Error conectando a BD nueva: {e}")
            return False

    def get_old_count(self, table_name):
        """Obtener conteo de registros en BD antigua"""
        try:
            self.old_cursor.execute(f'SELECT COUNT(*) as count FROM public."{table_name}"')
            result = self.old_cursor.fetchone()
            return result['count']
        except Exception as e:
            print(f"   ✗ Error obteniendo conteo de {table_name} en BD antigua: {e}")
            return -1

    def get_new_count(self, table_name):
        """Obtener conteo de registros en BD nueva"""
        try:
            response = self.new_client.table(table_name).select('id', count='exact').limit(1).execute()
            return response.count if hasattr(response, 'count') else 0
        except Exception as e:
            print(f"   ✗ Error obteniendo conteo de {table_name} en BD nueva: {e}")
            return -1

    def validate_table_count(self, old_table, new_table, expected_ratio=1.0, description=""):
        """
        Validar conteo de registros entre tablas

        Args:
            old_table: Nombre tabla en BD antigua
            new_table: Nombre tabla en BD nueva
            expected_ratio: Ratio esperado (nueva/antigua). Por defecto 1.0 (igual)
            description: Descripción de la validación
        """
        old_count = self.get_old_count(old_table)
        new_count = self.get_new_count(new_table)

        if old_count < 0 or new_count < 0:
            status = "ERROR"
            message = "No se pudo obtener conteo"
        elif old_count == 0:
            status = "SKIP" if new_count == 0 else "WARNING"
            message = "Tabla antigua vacía"
        else:
            actual_ratio = new_count / old_count if old_count > 0 else 0
            if abs(actual_ratio - expected_ratio) < 0.01:  # Tolerancia 1%
                status = "PASS"
                message = "Conteos coinciden"
            else:
                status = "FAIL"
                message = f"Ratio {actual_ratio:.2f} != esperado {expected_ratio:.2f}"

        result = {
            'check': description or f"{old_table} → {new_table}",
            'old_count': old_count,
            'new_count': new_count,
            'status': status,
            'message': message
        }

        self.validation_results.append(result)
        return status == "PASS"

    def validate_migration(self):
        """Ejecutar todas las validaciones"""
        print("\n" + "="*60)
        print("🔍 VALIDACIÓN DE MIGRACIÓN")
        print("="*60)

        print("\n📊 Validando conteos de registros...\n")

        # Validaciones de tablas
        validations = [
            # (tabla_antigua, tabla_nueva, ratio_esperado, descripción)
            ('categories', 'categories', 1.0, 'Categories'),
            ('topics', 'topic', 1.0, 'Topics'),
            ('questions', 'questions', 1.0, 'Questions'),
            ('questions', 'question_options', 3.0, 'Question Options (min 3 por pregunta)'),
            ('users', 'users', 1.0, 'Users'),
            ('user_tests', 'user_tests', 1.0, 'User Tests'),
            ('user_test_answers', 'user_test_answers', 1.0, 'User Test Answers'),
            ('users_favorite_questions', 'user_favorite_questions', 1.0, 'Favorite Questions'),
        ]

        for old_table, new_table, ratio, desc in validations:
            self.validate_table_count(old_table, new_table, ratio, desc)

        # Validar que topic_types se creó (5 registros)
        topic_types_count = self.get_new_count('topic_type')
        if topic_types_count == 5:
            result = {
                'check': 'Topic Types (nuevo)',
                'old_count': 0,
                'new_count': topic_types_count,
                'status': 'PASS',
                'message': '5 topic_types creados'
            }
        else:
            result = {
                'check': 'Topic Types (nuevo)',
                'old_count': 0,
                'new_count': topic_types_count,
                'status': 'FAIL',
                'message': f'Esperados 5, encontrados {topic_types_count}'
            }

        self.validation_results.append(result)

    def print_results(self):
        """Imprimir resultados de validación"""
        print("\n" + "="*60)
        print("📋 RESULTADOS DE VALIDACIÓN")
        print("="*60 + "\n")

        # Contar resultados por estado
        stats = {'PASS': 0, 'FAIL': 0, 'WARNING': 0, 'ERROR': 0, 'SKIP': 0}

        # Imprimir tabla de resultados
        print(f"{'Check':<35} {'Antigua':<12} {'Nueva':<12} {'Estado':<10} {'Mensaje'}")
        print("-" * 95)

        for result in self.validation_results:
            status_symbol = {
                'PASS': '✓',
                'FAIL': '✗',
                'WARNING': '⚠',
                'ERROR': '✗',
                'SKIP': '○'
            }.get(result['status'], '?')

            old_count_str = f"{result['old_count']:,}" if result['old_count'] >= 0 else "N/A"
            new_count_str = f"{result['new_count']:,}" if result['new_count'] >= 0 else "N/A"

            print(f"{result['check']:<35} {old_count_str:<12} {new_count_str:<12} {status_symbol} {result['status']:<8} {result['message']}")

            stats[result['status']] += 1

        # Resumen
        print("\n" + "="*60)
        print("📊 RESUMEN")
        print("="*60)
        print(f"✓ PASS:    {stats['PASS']}")
        print(f"✗ FAIL:    {stats['FAIL']}")
        print(f"⚠ WARNING: {stats['WARNING']}")
        print(f"✗ ERROR:   {stats['ERROR']}")
        print(f"○ SKIP:    {stats['SKIP']}")

        all_passed = stats['FAIL'] == 0 and stats['ERROR'] == 0

        print("\n" + "="*60)
        if all_passed:
            print("✓ VALIDACIÓN EXITOSA - Migración completada correctamente")
        else:
            print("⚠️ VALIDACIÓN CON ERRORES - Revisar resultados")
        print("="*60)

        return all_passed

    def close(self):
        """Cerrar conexiones"""
        if self.old_cursor:
            self.old_cursor.close()
        if self.old_conn:
            self.old_conn.close()
        print("\n✓ Conexiones cerradas")

def main():
    """Función principal"""
    validator = MigrationValidator()

    try:
        # Conectar a ambas BDs
        if not validator.connect_old_db():
            return False
        if not validator.connect_new_db():
            return False

        # Ejecutar validaciones
        validator.validate_migration()

        # Imprimir resultados
        success = validator.print_results()

        return success

    except Exception as e:
        print(f"\n✗ Error durante validación: {e}")
        import traceback
        traceback.print_exc()
        return False

    finally:
        validator.close()

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)
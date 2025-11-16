"""
Extrae datos de la base de datos antigua REMOTA (Policía Nacional - Producción)
Usa Supabase client con paginación de 500 registros por lote
"""
import json
from supabase import create_client, Client
from tqdm import tqdm
import sys
import os

# Añadir el directorio padre al path para importar config
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import OLD_DB_CONFIG, DATA_FILES, BATCH_SIZE, FORCE_DOWNLOAD

class OldDBExtractor:
    def __init__(self):
        self.client: Client = None

    def connect(self):
        """Conectar a Supabase remota (producción)"""
        try:
            if not OLD_DB_CONFIG['url'] or not OLD_DB_CONFIG['key']:
                print("✗ Error: OLD_DB_URL y OLD_DB_KEY deben estar configurados en .env")
                print("   Configura las credenciales de la BD de producción (DONANTE)")
                return False

            self.client = create_client(
                OLD_DB_CONFIG['url'],
                OLD_DB_CONFIG['key']
            )
            print(f"✓ Conectado a Supabase remota: {OLD_DB_CONFIG['url']}")
            print("   (Base de datos DONANTE - Producción)")
            return True

        except Exception as e:
            print(f"✗ Error conectando a Supabase remota: {e}")
            return False

    def close(self):
        """Cerrar conexión (no necesario en Supabase client, pero mantener compatibilidad)"""
        print("✓ Conexión cerrada")

    def get_total_count(self, table_name):
        """
        Obtener total de registros en una tabla usando Supabase

        Args:
            table_name: Nombre de la tabla

        Returns:
            int: Total de registros
        """
        try:
            # Usar count='exact' para obtener el total
            response = self.client.table(table_name).select('*', count='exact').limit(1).execute()
            return response.count if hasattr(response, 'count') else 0
        except Exception as e:
            print(f"   ⚠️ Error contando registros en {table_name}: {e}")
            return 0

    def extract_table_paginated(self, table_name, output_file, order_by='id'):
        """
        Extrae datos de una tabla de forma paginada usando Supabase client

        Args:
            table_name: Nombre de la tabla
            output_file: Archivo de salida JSON
            order_by: Campo para ordenar (importante para paginación consistente)
        """
        print(f"\n📊 Extrayendo tabla: {table_name}")

        # Verificar si el archivo ya existe y no forzamos descarga
        if os.path.exists(output_file) and not FORCE_DOWNLOAD:
            try:
                with open(output_file, 'r', encoding='utf-8') as f:
                    existing_data = json.load(f)
                    print(f"   ✓ Datos ya existentes: {len(existing_data):,} registros")
                    print(f"   ℹ️ Usando datos guardados (FORCE_DOWNLOAD=False)")
                    return
            except (json.JSONDecodeError, IOError):
                print(f"   ⚠️ Archivo corrupto, re-extrayendo...")
                # Si el archivo está corrupto, continuar con la extracción

        # Obtener total de registros
        total = self.get_total_count(table_name)
        print(f"   Total de registros: {total:,}")

        if total == 0:
            print(f"   ⚠️ Tabla vacía, saltando...")
            # Crear archivo vacío
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump([], f)
            return

        # Extraer datos en lotes
        all_data = []
        offset = 0

        with tqdm(total=total, desc=f"   Extrayendo {table_name}", unit="reg") as pbar:
            while offset < total:
                try:
                    # Consulta con paginación usando Supabase
                    # range() usa límites inclusivos: range(0, 499) devuelve 500 registros
                    end_offset = offset + BATCH_SIZE - 1

                    response = self.client.table(table_name)\
                        .select('*')\
                        .order(order_by)\
                        .range(offset, end_offset)\
                        .execute()

                    batch = response.data if hasattr(response, 'data') else []

                    if not batch:
                        break

                    # Los datos ya vienen como dicts desde Supabase
                    all_data.extend(batch)

                    offset += len(batch)
                    pbar.update(len(batch))

                    # Si recibimos menos datos de los esperados, hemos terminado
                    if len(batch) < BATCH_SIZE:
                        break

                except Exception as e:
                    print(f"\n   ✗ Error en lote offset={offset}: {e}")
                    raise

        # Guardar en archivo JSON
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(all_data, f, ensure_ascii=False, indent=2)

        print(f"   ✓ Guardado en {output_file}")
        print(f"   ✓ {len(all_data):,} registros extraídos")

    def extract_all(self):
        """Extraer todas las tablas necesarias"""
        print("\n" + "="*60)
        print("🚀 EXTRACCIÓN DE DATOS - SUPABASE REMOTA (DONANTE)")
        print("="*60)

        if FORCE_DOWNLOAD:
            print("⚠️ FORCE_DOWNLOAD = True - Descargando datos nuevos")
        else:
            print("ℹ️ FORCE_DOWNLOAD = False - Usando datos existentes si están disponibles")
        print("="*60)

        # Tablas a extraer en orden
        tables_config = [
            ('categories', DATA_FILES['categories'], 'id'),
            ('topics', DATA_FILES['topics'], 'id'),
            ('questions', DATA_FILES['questions'], 'id'),
            ('users', DATA_FILES['users'], 'id'),
            ('user_tests', DATA_FILES['user_tests'], 'id'),
            ('user_test_answers', DATA_FILES['user_test_answers'], 'id'),
            ('users_favorite_questions', DATA_FILES['user_favorite_questions'], 'userId'),
        ]

        for table_name, output_file, order_by in tables_config:
            try:
                self.extract_table_paginated(table_name, output_file, order_by)
            except Exception as e:
                print(f"   ✗ Error extrayendo {table_name}: {e}")
                raise

        print("\n" + "="*60)
        print("✓ EXTRACCIÓN COMPLETADA")
        print("="*60)

def main():
    """Función principal"""
    extractor = OldDBExtractor()

    try:
        # Conectar
        if not extractor.connect():
            return False

        # Extraer todas las tablas
        extractor.extract_all()

        return True

    except Exception as e:
        print(f"\n✗ Error durante la extracción: {e}")
        import traceback
        traceback.print_exc()
        return False

    finally:
        extractor.close()

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)
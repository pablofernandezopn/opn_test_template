#!/usr/bin/env python3
"""
Extrae user_test_answers de la BD antigua en batches
Maneja millones de registros dividiéndolos en múltiples archivos
"""
import json
import sys
import os
from supabase import create_client
from tqdm import tqdm
import time

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from config import OLD_DB_CONFIG, DATA_DIR

BATCH_SIZE = 50000  # 50K registros por archivo
MAX_RETRIES = 3

def save_json(data, filepath):
    """Guardar JSON"""
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def extract_batch(client, offset, limit):
    """Extraer un batch con retry"""
    for attempt in range(MAX_RETRIES):
        try:
            response = client.table('user_test_answers')\
                .select('*')\
                .range(offset, offset + limit - 1)\
                .execute()
            return response.data
        except Exception as e:
            if attempt < MAX_RETRIES - 1:
                wait_time = (attempt + 1) * 5
                print(f"\n   ⚠️  Error en offset {offset}, reintentando en {wait_time}s...")
                time.sleep(wait_time)
            else:
                raise e

def main():
    """Función principal"""
    print("\n" + "="*60)
    print("📥 EXTRACCIÓN DE USER_TEST_ANSWERS")
    print("="*60)

    try:
        # Conectar
        client = create_client(OLD_DB_CONFIG['url'], OLD_DB_CONFIG['key'])
        print(f"✓ Conectado a BD antigua")

        # Estimar total (sin COUNT que da timeout)
        # Intentamos obtener el último ID
        print(f"\n📊 Estimando total de registros...")
        try:
            last_record = client.table('user_test_answers')\
                .select('id')\
                .order('id', desc=True)\
                .limit(1)\
                .execute()

            if last_record.data:
                max_id = last_record.data[0]['id']
                print(f"   Último ID encontrado: {max_id:,}")
                print(f"   Estimación: ~{max_id:,} registros")
            else:
                print(f"   ⚠️  No se pudo estimar total")
                max_id = 10000000  # Default: 10M
        except:
            print(f"   ⚠️  Error estimando, usando 10M como máximo")
            max_id = 10000000

        # Extraer en batches
        print(f"\n📤 Extrayendo en batches de {BATCH_SIZE:,} registros...")

        offset = 0
        batch_num = 1
        total_extracted = 0
        empty_batches = 0
        max_empty_batches = 5  # Parar si 5 batches consecutivos vacíos

        while empty_batches < max_empty_batches:
            try:
                print(f"\n   Batch {batch_num} (offset {offset:,})...")

                # Extraer batch
                batch_data = extract_batch(client, offset, BATCH_SIZE)

                if not batch_data:
                    empty_batches += 1
                    print(f"      ⚠️  Batch vacío ({empty_batches}/{max_empty_batches})")
                    offset += BATCH_SIZE
                    continue

                # Reset empty counter
                empty_batches = 0

                # Guardar batch
                output_file = f"{DATA_DIR}/user_test_answers_{batch_num:03d}.json"
                save_json(batch_data, output_file)

                total_extracted += len(batch_data)
                print(f"      ✓ {len(batch_data):,} registros guardados en {output_file}")
                print(f"      📊 Total acumulado: {total_extracted:,}")

                # Siguiente batch
                offset += BATCH_SIZE
                batch_num += 1

                # Break si el batch es menor que BATCH_SIZE (último batch)
                if len(batch_data) < BATCH_SIZE:
                    print(f"\n   ✓ Último batch detectado (< {BATCH_SIZE:,} registros)")
                    break

            except Exception as e:
                print(f"\n   ✗ Error en batch {batch_num}: {str(e)[:200]}")
                # Continuar con siguiente batch
                offset += BATCH_SIZE
                batch_num += 1

        print("\n" + "="*60)
        print("✓ EXTRACCIÓN COMPLETADA")
        print(f"   Total extraído: {total_extracted:,} registros")
        print(f"   Archivos generados: {batch_num - 1}")
        print("="*60)

        return True

    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)

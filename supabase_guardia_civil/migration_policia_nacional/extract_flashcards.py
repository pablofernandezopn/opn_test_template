#!/usr/bin/env python3
"""
Extrae flash_cards_stack y flashcard de la BD remota
"""
import json
from supabase import create_client
from tqdm import tqdm
import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from config import OLD_DB_CONFIG, DATA_FILES

def extract_table(client, table_name, output_file):
    """Extraer tabla completa"""
    print(f"\n📊 Extrayendo {table_name}...")

    # Obtener total
    response = client.table(table_name).select('*', count='exact').limit(1).execute()
    total = response.count

    print(f"   Total de registros: {total:,}")

    if total == 0:
        print(f"   ⚠️ Tabla vacía")
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump([], f)
        return []

    # Extraer todos los datos
    all_data = []
    batch_size = 1000
    offset = 0

    with tqdm(total=total, desc=f"   Extrayendo {table_name}", unit="reg") as pbar:
        while offset < total:
            response = client.table(table_name).select('*').range(offset, offset + batch_size - 1).execute()
            batch = response.data

            if not batch:
                break

            all_data.extend(batch)
            offset += len(batch)
            pbar.update(len(batch))

            if len(batch) < batch_size:
                break

    # Guardar
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(all_data, f, ensure_ascii=False, indent=2)

    print(f"   ✓ Guardado en {output_file}")
    print(f"   ✓ {len(all_data):,} registros extraídos")

    return all_data

def main():
    """Función principal"""
    print("\n" + "="*60)
    print("📥 EXTRACCIÓN DE FLASHCARDS")
    print("="*60)

    try:
        # Conectar
        client = create_client(OLD_DB_CONFIG['url'], OLD_DB_CONFIG['key'])
        print(f"✓ Conectado a: {OLD_DB_CONFIG['url']}")

        # Extraer flash_cards_stack
        stacks = extract_table(client, 'flash_cards_stack', DATA_FILES['flash_cards_stack'])

        # Extraer flashcard
        flashcards = extract_table(client, 'flashcard', DATA_FILES['flashcards'])

        print("\n" + "="*60)
        print("✓ EXTRACCIÓN COMPLETADA")
        print(f"   ✓ {len(stacks)} stacks")
        print(f"   ✓ {len(flashcards)} flashcards")
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

#!/usr/bin/env python3
"""
Extrae cms_users y challenges de la BD antigua
"""
import json
import sys
import os
from supabase import create_client
from tqdm import tqdm

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from config import OLD_DB_CONFIG, DATA_FILES

def save_json(data, filepath):
    """Guardar JSON"""
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def extract_table(client, table_name, output_file):
    """Extraer tabla completa"""
    print(f"\n📊 Extrayendo {table_name}...")

    # Obtener total
    response = client.table(table_name).select('*', count='exact').limit(1).execute()
    total = response.count

    print(f"   Total de registros: {total:,}")

    if total == 0:
        print(f"   ⚠️ Tabla vacía")
        save_json([], output_file)
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
    save_json(all_data, output_file)

    print(f"   ✓ Guardado en {output_file}")
    print(f"   ✓ {len(all_data):,} registros extraídos")

    return all_data

def main():
    """Función principal"""
    print("\n" + "="*60)
    print("📥 EXTRACCIÓN DE CMS_USERS Y CHALLENGES")
    print("="*60)

    try:
        # Conectar
        client = create_client(OLD_DB_CONFIG['url'], OLD_DB_CONFIG['key'])
        print(f"✓ Conectado a: {OLD_DB_CONFIG['url']}")

        # Extraer cms_users
        cms_users = extract_table(client, 'cms_users', DATA_FILES.get('cms_users', 'data/cms_users.json'))

        # Extraer challenges
        challenges = extract_table(client, 'challenge', DATA_FILES.get('challenges', 'data/challenges.json'))

        print("\n" + "="*60)
        print("✓ EXTRACCIÓN COMPLETADA")
        print(f"   ✓ {len(cms_users)} cms_users")
        print(f"   ✓ {len(challenges)} challenges")
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

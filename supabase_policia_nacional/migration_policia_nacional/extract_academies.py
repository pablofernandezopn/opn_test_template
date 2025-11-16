#!/usr/bin/env python3
"""
Extrae academies de la BD antigua
"""
import json
import sys
import os
from supabase import create_client

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from config import OLD_DB_CONFIG

def save_json(data, filepath):
    """Guardar JSON"""
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def main():
    print("\n" + "="*60)
    print("📥 EXTRACCIÓN DE ACADEMIES")
    print("="*60)

    try:
        client = create_client(OLD_DB_CONFIG['url'], OLD_DB_CONFIG['key'])
        print(f"✓ Conectado a BD antigua")

        # Extraer academies
        response = client.table('academy').select('*').execute()
        academies = response.data

        print(f"\n✓ Academias extraídas: {len(academies)}")

        # Mostrar info
        for academy in academies:
            print(f"   - ID {academy.get('id')}: {academy.get('name')}")

        # Guardar
        output_file = 'data/academies.json'
        save_json(academies, output_file)
        print(f"\n✓ Guardado en {output_file}")

        return True

    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)

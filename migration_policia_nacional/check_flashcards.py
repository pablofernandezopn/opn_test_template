#!/usr/bin/env python3
"""
Verificar si existe una tabla de flashcards en la BD remota
"""
from supabase import create_client
import sys
import os

# Añadir el directorio padre al path para importar config
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from config import OLD_DB_CONFIG

try:
    # Conectar a BD remota
    client = create_client(OLD_DB_CONFIG['url'], OLD_DB_CONFIG['key'])
    print(f"✓ Conectado a: {OLD_DB_CONFIG['url']}")

    # Intentar consultar tabla flashcards
    print("\n🔍 Buscando tabla 'flashcards'...")
    try:
        response = client.table('flashcards').select('*', count='exact').limit(5).execute()
        print(f"✓ Tabla 'flashcards' encontrada!")
        print(f"   Total de registros: {response.count:,}")

        if response.data:
            print(f"\n📋 Ejemplo de flashcard:")
            flashcard = response.data[0]
            for key, value in flashcard.items():
                print(f"   {key}: {value}")

    except Exception as e:
        print(f"✗ Tabla 'flashcards' no encontrada o error: {e}")

        # Intentar con otros nombres posibles
        possible_names = ['flashcard', 'flash_cards', 'flash_card', 'cards', 'card']
        print("\n🔍 Buscando con otros nombres posibles...")

        for name in possible_names:
            try:
                response = client.table(name).select('*', count='exact').limit(1).execute()
                print(f"✓ Tabla '{name}' encontrada! ({response.count:,} registros)")
            except:
                print(f"✗ Tabla '{name}' no encontrada")

except Exception as e:
    print(f"✗ Error: {e}")
    import traceback
    traceback.print_exc()
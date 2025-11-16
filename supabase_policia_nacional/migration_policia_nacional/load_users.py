#!/usr/bin/env python3
"""
Carga users de la BD antigua a la nueva
Mapea campos y preserva IDs originales para mantener relaciones con challenges
"""
import json
import sys
import os
import psycopg2
import psycopg2.extras
from tqdm import tqdm

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from config import DATA_FILES, TARGET_ACADEMY_ID

DB_URL = "postgresql://postgres:postgres@127.0.0.1:54322/postgres"

def load_json(filepath):
    """Cargar JSON"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

def main():
    """Función principal"""
    print("\n" + "="*60)
    print("📥 CARGA DE USERS")
    print("="*60)

    conn = psycopg2.connect(DB_URL)

    try:
        # Cargar datos
        users_old = load_json(DATA_FILES['users'])

        print(f"\n📊 Datos cargados:")
        print(f"   - {len(users_old):,} usuarios")

        # Verificar usuarios existentes
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) FROM users")
        existing_count = cur.fetchone()[0]

        if existing_count > 0:
            print(f"\n   ⚠️  Ya hay {existing_count:,} usuarios en la BD")
            response = input(f"   ¿Continuar y agregar más? (s/N): ").strip().lower()
            if response != 's':
                print(f"\n   ⏸️  Carga abortada")
                return False

        # Procesar usuarios
        print(f"\n📤 Insertando usuarios...")

        inserted = 0
        updated = 0
        skipped = 0
        errors = []

        for user_old in tqdm(users_old, desc="   Procesando usuarios"):
            try:
                # Extraer datos con valores por defecto
                old_id = user_old.get('id')
                username = user_old.get('username')
                email = user_old.get('email')
                first_name = user_old.get('first_name')
                last_name = user_old.get('last_name')
                phone = user_old.get('phone')
                total_questions = user_old.get('totalQuestions', 0)
                right_questions = user_old.get('rightQuestions', 0)
                wrong_questions = user_old.get('wrongQuestions', 0)
                tester = user_old.get('tester', False)
                last_used = user_old.get('lastUsed')
                fcm_token = user_old.get('fcm_token')
                fid_token = user_old.get('fid_token')
                profile_image = user_old.get('profile_image')
                unlocked_at = user_old.get('unlocked_at')
                unlock_duration_minutes = user_old.get('unlock_duration_minutes', 0)
                enabled = user_old.get('enabled', True)
                tutorial = user_old.get('tutorial', False)
                created_at = user_old.get('createdAt')
                updated_at = user_old.get('updatedAt')
                academy = user_old.get('academy', TARGET_ACADEMY_ID)

                # Validaciones
                if not username:
                    skipped += 1
                    errors.append(f"User {old_id}: sin username")
                    continue

                # Verificar si ya existe por username
                cur.execute("SELECT id FROM users WHERE username = %s", (username,))
                existing = cur.fetchone()

                if existing:
                    # Usuario ya existe, actualizar
                    cur.execute("""
                        UPDATE users
                        SET
                            email = COALESCE(%s, email),
                            first_name = COALESCE(%s, first_name),
                            last_name = COALESCE(%s, last_name),
                            phone = COALESCE(%s, phone),
                            "totalQuestions" = %s,
                            "rightQuestions" = %s,
                            "wrongQuestions" = %s,
                            tester = %s,
                            "lastUsed" = %s,
                            fcm_token = %s,
                            fid_token = %s,
                            profile_image = %s,
                            unlocked_at = %s,
                            unlock_duration_minutes = %s,
                            enabled = %s,
                            tutorial = %s,
                            academy_id = %s,
                            "updatedAt" = COALESCE(%s, NOW())
                        WHERE username = %s
                    """, (
                        email, first_name, last_name, phone,
                        total_questions, right_questions, wrong_questions,
                        tester, last_used, fcm_token, fid_token,
                        profile_image, unlocked_at, unlock_duration_minutes,
                        enabled, tutorial, academy, updated_at, username
                    ))
                    updated += 1
                else:
                    # Insertar nuevo usuario
                    # IMPORTANTE: Usar el ID original para mantener relaciones con challenges
                    cur.execute("""
                        INSERT INTO users (
                            id,
                            username,
                            email,
                            first_name,
                            last_name,
                            phone,
                            "totalQuestions",
                            "rightQuestions",
                            "wrongQuestions",
                            tester,
                            "lastUsed",
                            fcm_token,
                            fid_token,
                            profile_image,
                            unlocked_at,
                            unlock_duration_minutes,
                            enabled,
                            tutorial,
                            "createdAt",
                            "updatedAt",
                            academy_id,
                            specialty_id,
                            deleted
                        )
                        VALUES (
                            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                            %s, %s, %s
                        )
                    """, (
                        old_id,  # Preservar ID original
                        username,
                        email,
                        first_name,
                        last_name,
                        phone,
                        total_questions,
                        right_questions,
                        wrong_questions,
                        tester,
                        last_used,
                        fcm_token,
                        fid_token,
                        profile_image,
                        unlocked_at,
                        unlock_duration_minutes,
                        enabled,
                        tutorial,
                        created_at,
                        updated_at,
                        academy,
                        None,  # specialty_id = NULL
                        False  # deleted = false
                    ))
                    inserted += 1

                # Commit cada 500
                if (inserted + updated) % 500 == 0:
                    conn.commit()

            except psycopg2.IntegrityError as e:
                conn.rollback()
                error_msg = str(e)

                if 'users_username_key' in error_msg:
                    # Username duplicado, skip
                    skipped += 1
                    if len(errors) < 10:
                        errors.append(f"User {old_id}: username '{username}' duplicado")
                else:
                    skipped += 1
                    if len(errors) < 10:
                        errors.append(f"User {old_id}: {str(e)[:100]}")

            except Exception as e:
                conn.rollback()
                error_msg = f"User {user_old.get('id', '?')}: {str(e)[:100]}"
                skipped += 1
                if len(errors) < 10:
                    errors.append(error_msg)

        # Commit final
        conn.commit()

        # Actualizar secuencia para que futuros inserts no colisionen
        cur.execute("""
            SELECT setval(
                pg_get_serial_sequence('users', 'id'),
                (SELECT MAX(id) FROM users)
            )
        """)
        conn.commit()

        cur.close()

        print(f"\n   ✓ Usuarios insertados: {inserted:,}")
        print(f"   ✓ Usuarios actualizados: {updated:,}")
        print(f"   ⚠️ Usuarios omitidos: {skipped:,}")

        if errors:
            print(f"\n   📋 Primeros errores ({len(errors)} mostrados):")
            for error in errors[:10]:
                print(f"      - {error}")

        print("\n" + "="*60)
        if skipped == 0:
            print("✓ CARGA COMPLETADA EXITOSAMENTE")
        else:
            print("⚠️ CARGA COMPLETADA CON ADVERTENCIAS")
            print(f"   {inserted:,} insertados, {updated:,} actualizados, {skipped:,} omitidos")
        print("="*60)

        return True

    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        conn.close()

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)

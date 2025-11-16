#!/usr/bin/env python3
"""
Carga challenges de la BD antigua a la nueva
- Mapea questionId → question_id
- Mapea topicId → topic_id
- Mapea tutor (UUID) → tutor_uuid (enlaza con cms_users.user_uuid)
- Ignora campo editor antiguo
- Maneja user_id (FK a users.id)
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

def get_user_id_mapping(conn):
    """
    Obtener mapeo de user_id antiguo → nuevo
    Si users está vacío, retorna dict vacío
    """
    cur = conn.cursor()

    # Verificar si hay usuarios
    cur.execute("SELECT COUNT(*) FROM users")
    count = cur.fetchone()[0]

    if count == 0:
        print(f"\n   ⚠️  Tabla 'users' vacía - challenges se insertarán sin validar user_id")
        cur.close()
        return {}

    # Aquí deberíamos tener un mapeo de old_user_id → new_user_id
    # pero por ahora retornamos vacío ya que users no está migrado
    cur.close()
    return {}

def normalize_state(state_old):
    """
    Normalizar estado de challenge
    Valores posibles en enum: pendiente, resuelta, rechazada
    """
    if not state_old:
        return 'pendiente'

    state_lower = state_old.lower()

    # Mapeo de estados
    if state_lower in ['pendiente', 'pending']:
        return 'pendiente'
    elif state_lower in ['aceptada', 'accepted', 'aprobada', 'resuelta', 'resolved']:
        return 'resuelta'  # "Aceptada" → "resuelta"
    elif state_lower in ['rechazada', 'rejected', 'denegada']:
        return 'rechazada'
    else:
        print(f"      ⚠️  Estado desconocido '{state_old}', usando 'pendiente'")
        return 'pendiente'

def main():
    """Función principal"""
    print("\n" + "="*60)
    print("📥 CARGA DE CHALLENGES")
    print("="*60)

    conn = psycopg2.connect(DB_URL)

    try:
        # Cargar datos
        challenges_old = load_json(DATA_FILES['challenges'])

        print(f"\n📊 Datos cargados:")
        print(f"   - {len(challenges_old)} challenges")

        # Verificar usuarios
        user_mapping = get_user_id_mapping(conn)

        # Verificar si hay users
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) FROM users")
        users_count = cur.fetchone()[0]

        print(f"\n📋 Estado de dependencias:")
        print(f"   - Users en BD: {users_count}")

        if users_count == 0:
            print(f"\n   ⚠️  ADVERTENCIA: No hay usuarios en la tabla 'users'")
            print(f"   ⚠️  Se intentará usar user_id original de challenges")
            print(f"   ⚠️  Challenges con user_id inexistente serán omitidos por FK constraint")
            print(f"\n   ▶️  Continuando con carga...")

        # Procesar challenges
        print(f"\n📤 Insertando challenges...")

        inserted = 0
        skipped = 0
        errors = []

        for challenge_old in tqdm(challenges_old, desc="   Procesando challenges"):
            try:
                # Extraer datos
                user_id = challenge_old.get('user_id')
                question_id = challenge_old.get('questionId')
                topic_id = challenge_old.get('topicId')
                reason = challenge_old.get('reason', '')
                state_old = challenge_old.get('state', 'Pendiente')
                reply = challenge_old.get('replay', '')  # replay → reply
                open_status = challenge_old.get('open', True)
                tutor_uuid = challenge_old.get('tutor')  # UUID enlaza con cms_users.user_uuid
                created_at = challenge_old.get('created_at')

                # Validaciones
                if not question_id:
                    skipped += 1
                    errors.append(f"Challenge {challenge_old.get('id')}: sin question_id")
                    continue

                if not user_id:
                    skipped += 1
                    errors.append(f"Challenge {challenge_old.get('id')}: sin user_id")
                    continue

                # Normalizar estado
                state = normalize_state(state_old)

                # Insertar
                cur.execute("""
                    INSERT INTO challenge (
                        user_id,
                        question_id,
                        topic_id,
                        reason,
                        state,
                        reply,
                        editor_id,
                        open,
                        tutor_uuid,
                        academy_id,
                        specialty_id,
                        created_at
                    )
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    user_id,           # Usar user_id original
                    question_id,
                    topic_id,
                    reason,
                    state,
                    reply,
                    None,              # editor_id = NULL (ignorar campo antiguo "editor")
                    open_status,
                    tutor_uuid,        # UUID del tutor (enlaza con cms_users.user_uuid)
                    TARGET_ACADEMY_ID, # academy_id = 1 (Policía Nacional)
                    None,              # specialty_id = NULL
                    created_at
                ))

                # Commit inmediatamente para evitar rollbacks masivos
                conn.commit()
                inserted += 1

            except psycopg2.IntegrityError as e:
                conn.rollback()
                error_msg = str(e)

                # Identificar tipo de error
                if 'challenge_tutor_uuid_fkey' in error_msg:
                    # Reintentar sin tutor_uuid si no existe
                    try:
                        cur.execute("""
                            INSERT INTO challenge (
                                user_id, question_id, topic_id, reason, state,
                                reply, editor_id, open, tutor_uuid,
                                academy_id, specialty_id, created_at
                            )
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                        """, (
                            user_id, question_id, topic_id, reason, state,
                            reply, None, open_status, None,  # tutor_uuid = NULL
                            TARGET_ACADEMY_ID, None, created_at
                        ))
                        conn.commit()
                        inserted += 1
                    except:
                        conn.rollback()
                        skipped += 1
                        if len(errors) < 10:
                            errors.append(f"Challenge {challenge_old.get('id')}: tutor_uuid inválido, fallo retry")

                elif 'challenge_user_id_fkey' in error_msg:
                    skipped += 1
                    if len(errors) < 10:
                        errors.append(f"Challenge {challenge_old.get('id')}: user_id {user_id} no existe")
                elif 'challenge_question_id_fkey' in error_msg:
                    skipped += 1
                    if len(errors) < 10:
                        errors.append(f"Challenge {challenge_old.get('id')}: question_id {question_id} no existe")
                elif 'challenge_topic_id_fkey' in error_msg:
                    skipped += 1
                    if len(errors) < 10:
                        errors.append(f"Challenge {challenge_old.get('id')}: topic_id {topic_id} no existe")
                else:
                    skipped += 1
                    if len(errors) < 10:
                        errors.append(f"Challenge {challenge_old.get('id')}: {str(e)[:100]}")

            except Exception as e:
                conn.rollback()
                error_msg = f"Challenge {challenge_old.get('id', '?')}: {str(e)[:100]}"
                skipped += 1
                if len(errors) < 10:
                    errors.append(error_msg)

        # Commit final
        conn.commit()
        cur.close()

        print(f"\n   ✓ Challenges insertados: {inserted:,}")
        print(f"   ⚠️ Challenges omitidos: {skipped:,}")

        if errors:
            print(f"\n   📋 Primeros errores ({len(errors)} mostrados):")
            for error in errors[:10]:
                print(f"      - {error}")

        print("\n" + "="*60)
        if skipped == 0:
            print("✓ CARGA COMPLETADA EXITOSAMENTE")
        else:
            print("⚠️ CARGA COMPLETADA CON ERRORES")
            print(f"   {inserted} insertados, {skipped} omitidos")
        print("="*60)

        return skipped == 0

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

#!/usr/bin/env python3
"""
Carga cms_users creando primero usuarios en auth.users
1. Crea usuarios en auth.users con email + password automática
2. El trigger crea automáticamente el registro en cms_users
3. Actualiza cms_users con datos completos (nombre, apellido, rol, etc.)
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

def create_auth_user(conn, email, password):
    """
    Crear usuario en auth.users usando función de Supabase
    Retorna el UUID del usuario creado
    """
    cur = conn.cursor()

    # Usar la función auth.create_user de Supabase para crear usuario sin confirmación
    # NOTA: Esta función requiere privilegios de service_role
    try:
        cur.execute("""
            SELECT id FROM auth.users WHERE email = %s
        """, (email,))

        existing = cur.fetchone()
        if existing:
            print(f"      ℹ️  Usuario {email} ya existe (UUID: {existing[0]})")
            return existing[0]

        # Crear usuario en auth.users directamente
        # Supabase local permite insertar directamente en auth.users
        cur.execute("""
            INSERT INTO auth.users (
                instance_id,
                id,
                aud,
                role,
                email,
                encrypted_password,
                email_confirmed_at,
                confirmation_token,
                recovery_token,
                email_change_token_new,
                email_change,
                created_at,
                updated_at,
                raw_app_meta_data,
                raw_user_meta_data,
                is_super_admin,
                phone,
                phone_confirmed_at,
                phone_change,
                phone_change_token,
                email_change_token_current,
                email_change_confirm_status,
                banned_until,
                reauthentication_token,
                reauthentication_sent_at,
                is_sso_user,
                deleted_at,
                is_anonymous
            )
            VALUES (
                '00000000-0000-0000-0000-000000000000',
                gen_random_uuid(),
                'authenticated',
                'authenticated',
                %s,
                crypt(%s, gen_salt('bf')),
                NOW(),
                '',
                '',
                '',
                '',
                NOW(),
                NOW(),
                '{"provider":"email","providers":["email"]}',
                '{}',
                FALSE,
                NULL,
                NULL,
                '',
                '',
                '',
                0,
                NULL,
                '',
                NULL,
                FALSE,
                NULL,
                FALSE
            )
            RETURNING id
        """, (email, password))

        user_id = cur.fetchone()[0]
        conn.commit()

        print(f"      ✓ Usuario creado: {email} (UUID: {user_id})")
        return user_id

    except Exception as e:
        conn.rollback()
        print(f"      ✗ Error creando usuario {email}: {str(e)[:100]}")
        return None

def get_role_id_mapping(conn):
    """Obtener mapeo de roles nombre → ID"""
    cur = conn.cursor()
    cur.execute("SELECT id, name FROM role")
    roles = cur.fetchall()
    cur.close()

    # Crear mapeo
    role_map = {name.lower(): id for id, name in roles}

    print(f"\n📋 Roles disponibles:")
    for name, id in role_map.items():
        print(f"   - {name}: {id}")

    return role_map

def main():
    """Función principal"""
    print("\n" + "="*60)
    print("📥 CARGA DE CMS_USERS CON AUTH")
    print("="*60)

    conn = psycopg2.connect(DB_URL)

    try:
        # Cargar datos
        cms_users_old = load_json(DATA_FILES['cms_users'])

        print(f"\n📊 Datos cargados:")
        print(f"   - {len(cms_users_old)} cms_users")

        # Obtener mapeo de roles
        role_map = get_role_id_mapping(conn)

        # Procesarpor usuario
        print(f"\n👥 Creando usuarios en auth...")

        created = 0
        updated = 0
        errors = []
        uuid_mapping = {}  # old_id → new_uuid

        cur = conn.cursor()

        for user_old in tqdm(cms_users_old, desc="   Procesando usuarios"):
            try:
                email = user_old.get('email')
                if not email or '@' not in email:
                    print(f"\n   ⚠️ Usuario {user_old.get('id')} sin email válido, saltando")
                    continue

                # Generar password automática
                email_prefix = email.split('@')[0]
                password = f"norecuerdo_{email_prefix}"

                # 1. Crear usuario en auth.users (o obtener UUID si ya existe)
                user_uuid = create_auth_user(conn, email, password)

                if not user_uuid:
                    errors.append(f"Usuario {email}: No se pudo crear en auth")
                    continue

                created += 1
                uuid_mapping[user_old['id']] = user_uuid

                # 2. El trigger ya creó el registro en cms_users, ahora actualizarlo
                # Mapear rol
                rol_old = user_old.get('rol', 'admin')
                role_id = role_map.get(rol_old.lower() if rol_old else 'admin', 4)  # Default: 4 (admin?)

                cur.execute("""
                    UPDATE cms_users
                    SET
                        username = %s,
                        nombre = %s,
                        apellido = %s,
                        avatar_url = %s,
                        email = %s,
                        phone = %s,
                        address = %s,
                        role_id = %s,
                        academy_id = %s,
                        specialty_id = NULL,
                        updated_at = NOW()
                    WHERE user_uuid = %s
                """, (
                    user_old.get('username', 'sin usuario'),
                    user_old.get('nombre', 'sin nombre'),
                    user_old.get('apellido', 'sin apellido'),
                    user_old.get('avatar_url'),
                    email,
                    user_old.get('phone'),
                    user_old.get('address'),
                    role_id,
                    TARGET_ACADEMY_ID,
                    user_uuid
                ))

                updated += 1

                # Commit cada 10
                if created % 10 == 0:
                    conn.commit()

            except Exception as e:
                conn.rollback()
                error_msg = f"Usuario {user_old.get('id', '?')}: {str(e)[:100]}"
                errors.append(error_msg)
                if len(errors) <= 5:
                    print(f"\n   ✗ {error_msg}")

        # Commit final
        conn.commit()
        cur.close()

        print(f"\n   ✓ Usuarios creados en auth: {created}")
        print(f"   ✓ Registros cms_users actualizados: {updated}")

        if errors:
            print(f"   ⚠️ {len(errors)} errores encontrados")

        # Guardar mapeo UUID para challenges
        with open('data/transformed/cms_users_uuid_mapping.json', 'w') as f:
            json.dump(uuid_mapping, f, indent=2)

        print(f"   ✓ Mapeo UUID guardado")

        print("\n" + "="*60)
        if len(errors) == 0:
            print("✓ CARGA COMPLETADA EXITOSAMENTE")
        else:
            print("⚠️ CARGA COMPLETADA CON ERRORES")
        print("="*60)

        return len(errors) == 0

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

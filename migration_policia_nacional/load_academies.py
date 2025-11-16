#!/usr/bin/env python3
"""
Carga academies preservando IDs originales
- Academy ID 1 (Policía Nacional): UPDATE
- Otras academies: INSERT con ID original
"""
import json
import sys
import os
import psycopg2

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

DB_URL = "postgresql://postgres:postgres@127.0.0.1:54322/postgres"

def load_json(filepath):
    """Cargar JSON"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

def main():
    """Función principal"""
    print("\n" + "="*60)
    print("📥 CARGA DE ACADEMIES")
    print("="*60)

    conn = psycopg2.connect(DB_URL)

    try:
        # Cargar datos
        academies = load_json('data/academies.json')

        print(f"\n📊 Academias a cargar: {len(academies)}")
        for academy in academies:
            print(f"   - ID {academy.get('id')}: {academy.get('name')}")

        cur = conn.cursor()

        inserted = 0
        updated = 0
        errors = []

        for academy in academies:
            try:
                academy_id = academy.get('id')
                name = academy.get('name')
                description = academy.get('description')
                logo_url = academy.get('logo_url')
                website = academy.get('website')
                contact_email = academy.get('contact_email')
                contact_phone = academy.get('contact_phone')
                address = academy.get('address')
                is_active = academy.get('is_active', True)
                created_at = academy.get('created_at')

                # Generar slug a partir del nombre
                slug = name.lower().replace(' ', '-') if name else f'academy-{academy_id}'

                # Verificar si existe
                cur.execute("SELECT id FROM academies WHERE id = %s", (academy_id,))
                existing = cur.fetchone()

                if existing:
                    # Academy existe, actualizar
                    print(f"\n   📝 Actualizando academy {academy_id}: {name}")
                    cur.execute("""
                        UPDATE academies
                        SET
                            name = %s,
                            slug = %s,
                            description = %s,
                            logo_url = %s,
                            website = %s,
                            contact_email = %s,
                            contact_phone = %s,
                            address = %s,
                            is_active = %s,
                            updated_at = NOW()
                        WHERE id = %s
                    """, (
                        name, slug, description, logo_url, website,
                        contact_email, contact_phone, address, is_active,
                        academy_id
                    ))
                    updated += 1
                else:
                    # Insertar nueva academy
                    print(f"\n   ➕ Insertando academy {academy_id}: {name}")
                    cur.execute("""
                        INSERT INTO academies (
                            id,
                            name,
                            slug,
                            description,
                            logo_url,
                            website,
                            contact_email,
                            contact_phone,
                            address,
                            is_active,
                            created_at
                        )
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, COALESCE(%s, NOW()))
                    """, (
                        academy_id, name, slug, description, logo_url,
                        website, contact_email, contact_phone, address,
                        is_active, created_at
                    ))
                    inserted += 1

                conn.commit()

            except psycopg2.IntegrityError as e:
                conn.rollback()
                error_msg = str(e)
                if 'academies_slug_key' in error_msg:
                    # Slug duplicado, intentar con sufijo
                    try:
                        alt_slug = f"{slug}-{academy_id}"
                        print(f"      ⚠️  Slug '{slug}' duplicado, usando '{alt_slug}'")

                        if existing:
                            cur.execute("""
                                UPDATE academies SET slug = %s WHERE id = %s
                            """, (alt_slug, academy_id))
                            updated += 1
                        else:
                            cur.execute("""
                                INSERT INTO academies (
                                    id, name, slug, description, logo_url, website,
                                    contact_email, contact_phone, address, is_active, created_at
                                )
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, COALESCE(%s, NOW()))
                            """, (
                                academy_id, name, alt_slug, description, logo_url,
                                website, contact_email, contact_phone, address,
                                is_active, created_at
                            ))
                            inserted += 1

                        conn.commit()
                    except Exception as retry_e:
                        conn.rollback()
                        errors.append(f"Academy {academy_id}: {str(retry_e)[:80]}")
                else:
                    errors.append(f"Academy {academy_id}: {str(e)[:100]}")

            except Exception as e:
                conn.rollback()
                errors.append(f"Academy {academy_id}: {str(e)[:100]}")

        # Actualizar secuencia
        cur.execute("""
            SELECT setval(
                pg_get_serial_sequence('academies', 'id'),
                (SELECT MAX(id) FROM academies)
            )
        """)
        conn.commit()

        cur.close()

        print(f"\n" + "="*60)
        print(f"✓ Academias insertadas: {inserted}")
        print(f"✓ Academias actualizadas: {updated}")
        if errors:
            print(f"⚠️ Errores: {len(errors)}")
            for error in errors:
                print(f"   - {error}")
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

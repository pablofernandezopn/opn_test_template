"""
Script principal de migración ETL
Orquesta todo el proceso: Extract → Transform → Load → Validate
"""
import sys
import os
from datetime import datetime

# Importar módulos de ETL
from extract.extract_data import OldDBExtractor
from transform.transform_data import DataTransformer
from load.load_data import NewDBLoader
from validate.validate import MigrationValidator

def print_header(title):
    """Imprimir encabezado"""
    print("\n" + "="*70)
    print(f"  {title}")
    print("="*70)

def print_step(step_num, total_steps, description):
    """Imprimir paso actual"""
    print(f"\n🔹 PASO {step_num}/{total_steps}: {description}")
    print("-" * 70)

def confirm_migration():
    """Confirmar que el usuario quiere ejecutar la migración"""
    print("\n" + "="*70)
    print("⚠️  ADVERTENCIA - MIGRACIÓN DE DATOS")
    print("="*70)
    print("\nEsta operación:")
    print("  1. Extraerá datos de la BD antigua (Policía Nacional)")
    print("  2. Transformará la estructura de datos")
    print("  3. Cargará datos a la BD nueva (Guardia Civil)")
    print("  4. Validará la integridad de la migración")
    print("\n⚠️  IMPORTANTE:")
    print("  - Asegúrate de tener un backup de la BD nueva")
    print("  - La BD antigua no será modificada")
    print("  - Este proceso puede tardar varios minutos")
    print("\n" + "="*70)

    response = input("\n¿Continuar con la migración? (escribe 'SI' para continuar): ")

    if response.strip().upper() != 'SI':
        print("\n❌ Migración cancelada por el usuario")
        return False

    return True

def main():
    """Función principal de migración"""
    start_time = datetime.now()

    print_header("🚀 MIGRACIÓN ETL: POLICÍA NACIONAL → GUARDIA CIVIL")
    print(f"\nInicio: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")

    # Confirmar migración
    if not confirm_migration():
        return False

    total_steps = 4
    current_step = 0

    # ========================================
    # PASO 1: EXTRACT
    # ========================================
    current_step += 1
    print_step(current_step, total_steps, "EXTRACCIÓN DE DATOS")

    extractor = OldDBExtractor()
    try:
        if not extractor.connect():
            print("\n✗ Error: No se pudo conectar a la BD antigua")
            return False

        extractor.extract_all()
        extractor.close()
        print("\n✓ Extracción completada")

    except Exception as e:
        print(f"\n✗ Error durante extracción: {e}")
        import traceback
        traceback.print_exc()
        extractor.close()
        return False

    # ========================================
    # PASO 2: TRANSFORM
    # ========================================
    current_step += 1
    print_step(current_step, total_steps, "TRANSFORMACIÓN DE DATOS")

    transformer = DataTransformer()
    try:
        if not transformer.transform_all():
            print("\n✗ Error durante transformación")
            return False
        print("\n✓ Transformación completada")

    except Exception as e:
        print(f"\n✗ Error durante transformación: {e}")
        import traceback
        traceback.print_exc()
        return False

    # ========================================
    # PASO 3: LOAD
    # ========================================
    current_step += 1
    print_step(current_step, total_steps, "CARGA DE DATOS")

    loader = NewDBLoader()
    try:
        if not loader.connect():
            print("\n✗ Error: No se pudo conectar a la BD nueva")
            print("\n💡 Verifica que NEW_DB_URL y NEW_DB_KEY estén configurados en .env")
            return False

        if not loader.load_all():
            print("\n⚠️ Carga completada con errores")
            # Continuar a validación para ver detalles

    except Exception as e:
        print(f"\n✗ Error durante carga: {e}")
        import traceback
        traceback.print_exc()
        return False

    # ========================================
    # PASO 4: VALIDATE
    # ========================================
    current_step += 1
    print_step(current_step, total_steps, "VALIDACIÓN DE MIGRACIÓN")

    validator = MigrationValidator()
    try:
        if not validator.connect_old_db() or not validator.connect_new_db():
            print("\n✗ Error conectando para validación")
            return False

        validator.validate_migration()
        success = validator.print_results()
        validator.close()

        if not success:
            print("\n⚠️ Validación encontró diferencias")
            return False

    except Exception as e:
        print(f"\n✗ Error durante validación: {e}")
        import traceback
        traceback.print_exc()
        validator.close()
        return False

    # ========================================
    # RESUMEN FINAL
    # ========================================
    end_time = datetime.now()
    duration = end_time - start_time

    print_header("✅ MIGRACIÓN COMPLETADA EXITOSAMENTE")
    print(f"\nInicio:    {start_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Fin:       {end_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Duración:  {duration}")
    print("\n" + "="*70)

    return True

if __name__ == '__main__':
    try:
        success = main()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\n❌ Migración interrumpida por el usuario")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n✗ Error inesperado: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
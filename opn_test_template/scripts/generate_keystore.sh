#!/bin/bash

# ════════════════════════════════════════════════════════════════
# Script para generar keystore y configuración de firma automática
# ════════════════════════════════════════════════════════════════

set -e  # Salir si hay error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ════════════════════════════════════════════════════════════════
# VALIDAR PARÁMETROS
# ════════════════════════════════════════════════════════════════
if [ -z "$1" ]; then
    echo -e "${RED}❌ Error: Falta el nombre del flavor${NC}"
    echo -e "${YELLOW}Uso: ./generate_keystore.sh <flavor_name> [organization]${NC}"
    echo -e "${YELLOW}Ejemplo: ./generate_keystore.sh policia_nacional \"Policía Nacional\"${NC}"
    exit 1
fi

FLAVOR=$1
ORGANIZATION=${2:-"OPN Test"}
FLAVOR_DIR="flavors/$FLAVOR"
ANDROID_DIR="$FLAVOR_DIR/android"

# Validar que existe el directorio del flavor
if [ ! -d "$FLAVOR_DIR" ]; then
    echo -e "${RED}❌ Error: El directorio del flavor no existe: $FLAVOR_DIR${NC}"
    exit 1
fi

# Crear directorio android si no existe
mkdir -p "$ANDROID_DIR"

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🔐 GENERANDO KEYSTORE PARA: ${FLAVOR}${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"

# ════════════════════════════════════════════════════════════════
# GENERAR PASSWORDS SEGUROS
# ════════════════════════════════════════════════════════════════
echo -e "${YELLOW}📝 Generando passwords seguros...${NC}"

STORE_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
KEY_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
KEY_ALIAS="opn-${FLAVOR}"
KEYSTORE_FILE="upload-keystore.jks"

echo -e "${GREEN}✅ Passwords generados${NC}\n"

# ════════════════════════════════════════════════════════════════
# GENERAR KEYSTORE
# ════════════════════════════════════════════════════════════════
echo -e "${YELLOW}🔨 Generando keystore...${NC}"

# Verificar si ya existe keystore
if [ -f "$ANDROID_DIR/$KEYSTORE_FILE" ]; then
    echo -e "${RED}⚠️  WARNING: Ya existe un keystore en $ANDROID_DIR/$KEYSTORE_FILE${NC}"
    read -p "¿Deseas sobrescribirlo? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}❌ Operación cancelada${NC}"
        exit 1
    fi
    rm "$ANDROID_DIR/$KEYSTORE_FILE"
fi

# Generar keystore
keytool -genkey -v \
    -keystore "$ANDROID_DIR/$KEYSTORE_FILE" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=$ORGANIZATION, OU=Mobile, O=Isyfu, L=Madrid, S=Madrid, C=ES" \
    2>/dev/null

echo -e "${GREEN}✅ Keystore generado exitosamente${NC}\n"

# ════════════════════════════════════════════════════════════════
# CREAR ARCHIVO key.properties
# ════════════════════════════════════════════════════════════════
echo -e "${YELLOW}📄 Creando archivo key.properties...${NC}"

cat > "$ANDROID_DIR/key.properties" << EOF
# ════════════════════════════════════════════════════════════════
# SIGNING CONFIG - $FLAVOR
# ════════════════════════════════════════════════════════════════
# IMPORTANTE: Este archivo contiene información sensible.
# NO commitear a git. Debe estar en .gitignore
# ════════════════════════════════════════════════════════════════

storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=$KEYSTORE_FILE

# ════════════════════════════════════════════════════════════════
# INFORMACIÓN ADICIONAL
# ════════════════════════════════════════════════════════════════
# Generado: $(date)
# Organización: $ORGANIZATION
# Validez: 10000 días (~27 años)
# Algoritmo: RSA 2048
# ════════════════════════════════════════════════════════════════
EOF

echo -e "${GREEN}✅ Archivo key.properties creado${NC}\n"

# ════════════════════════════════════════════════════════════════
# CREAR ARCHIVO DE BACKUP SEGURO
# ════════════════════════════════════════════════════════════════
echo -e "${YELLOW}💾 Creando backup de credenciales...${NC}"

BACKUP_FILE="$ANDROID_DIR/keystore_credentials_BACKUP.txt"

cat > "$BACKUP_FILE" << EOF
════════════════════════════════════════════════════════════════
🔐 CREDENCIALES DE FIRMA - BACKUP
════════════════════════════════════════════════════════════════

⚠️  INFORMACIÓN MUY SENSIBLE - GUARDAR EN LUGAR SEGURO ⚠️

Flavor: $FLAVOR
Organización: $ORGANIZATION
Generado: $(date)

════════════════════════════════════════════════════════════════
CREDENCIALES
════════════════════════════════════════════════════════════════

Keystore File:     $KEYSTORE_FILE
Key Alias:         $KEY_ALIAS
Store Password:    $STORE_PASSWORD
Key Password:      $KEY_PASSWORD

════════════════════════════════════════════════════════════════
RUTAS
════════════════════════════════════════════════════════════════

Keystore:          $ANDROID_DIR/$KEYSTORE_FILE
Key Properties:    $ANDROID_DIR/key.properties

════════════════════════════════════════════════════════════════
INFORMACIÓN DEL CERTIFICADO
════════════════════════════════════════════════════════════════

DN: CN=$ORGANIZATION, OU=Mobile, O=Isyfu, L=Madrid, S=Madrid, C=ES
Validez: 10000 días
Algoritmo: RSA
Tamaño de clave: 2048 bits

════════════════════════════════════════════════════════════════
⚠️  INSTRUCCIONES DE SEGURIDAD ⚠️
════════════════════════════════════════════════════════════════

1. GUARDAR este archivo en un gestor de contraseñas (1Password, LastPass, etc.)
2. HACER BACKUP del keystore (.jks) en almacenamiento seguro
3. NO COMMITEAR key.properties ni este archivo a git
4. NO COMPARTIR estas credenciales por email/chat sin cifrar
5. Si pierdes el keystore, NO PODRÁS actualizar la app en Google Play

════════════════════════════════════════════════════════════════
EOF

echo -e "${GREEN}✅ Backup creado en: $BACKUP_FILE${NC}\n"

# ════════════════════════════════════════════════════════════════
# VERIFICAR KEYSTORE
# ════════════════════════════════════════════════════════════════
echo -e "${YELLOW}🔍 Verificando keystore...${NC}"

keytool -list -v \
    -keystore "$ANDROID_DIR/$KEYSTORE_FILE" \
    -storepass "$STORE_PASSWORD" \
    2>/dev/null | head -n 20

# ════════════════════════════════════════════════════════════════
# RESUMEN FINAL
# ════════════════════════════════════════════════════════════════
echo -e "\n${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ KEYSTORE GENERADO EXITOSAMENTE${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"

echo -e "${GREEN}📦 Flavor:${NC}              $FLAVOR"
echo -e "${GREEN}🔑 Key Alias:${NC}           $KEY_ALIAS"
echo -e "${GREEN}📁 Keystore:${NC}            $ANDROID_DIR/$KEYSTORE_FILE"
echo -e "${GREEN}📄 Properties:${NC}          $ANDROID_DIR/key.properties"
echo -e "${GREEN}💾 Backup:${NC}              $BACKUP_FILE"

echo -e "\n${YELLOW}════════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}⚠️  ACCIONES IMPORTANTES${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════════${NC}\n"

echo -e "${RED}1.${NC} Guarda las credenciales del backup en un lugar SEGURO"
echo -e "${RED}2.${NC} Haz backup del archivo .jks en almacenamiento cifrado"
echo -e "${RED}3.${NC} NO commitees key.properties ni el keystore a git"
echo -e "${RED}4.${NC} Agrega estas rutas a .gitignore:"
echo -e "   ${BLUE}flavors/*/android/upload-keystore.jks${NC}"
echo -e "   ${BLUE}flavors/*/android/key.properties${NC}"
echo -e "   ${BLUE}flavors/*/android/keystore_credentials_BACKUP.txt${NC}"

echo -e "\n${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}📝 PRÓXIMOS PASOS${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}\n"

echo -e "1. Verificar que build.gradle.kts esté configurado para este flavor"
echo -e "2. Build de prueba:"
echo -e "   ${BLUE}flutter build apk --flavor ${FLAVOR//_/} --release -t lib/main_${FLAVOR}.dart${NC}"
echo -e "3. Verificar firma del APK:"
echo -e "   ${BLUE}keytool -printcert -jarfile build/app/outputs/flutter-apk/app-${FLAVOR//_/}-release.apk${NC}\n"

echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}\n"

# Scripts de Compilación - OPN Test Guardia Civil

Scripts automatizados para compilar la aplicación en diferentes plataformas.

## 📋 Contenido

### Scripts de Producción
- `build.sh` - Script maestro con menú interactivo
- `build_android.sh` - Compilación para Android (App Bundle)
- `build_ios.sh` - Compilación para iOS (IPA)
- `build_web.sh` - Compilación para Web

### Scripts de Desarrollo
- `dev_run.sh` - Ejecutar app en modo desarrollo (debug)

## 🚀 Uso Rápido

### Opción 1: Menú Interactivo

```bash
./scripts/build.sh
```

Muestra un menú para seleccionar la plataforma a compilar.

### Opción 2: Línea de Comandos

```bash
# Compilar Android
./scripts/build.sh android

# Compilar iOS
./scripts/build.sh ios

# Compilar Web
./scripts/build.sh web

# Compilar todas las plataformas
./scripts/build.sh all
```

### Opción 3: Scripts Individuales

```bash
# Android
./scripts/build_android.sh

# iOS
./scripts/build_ios.sh

# Web
./scripts/build_web.sh
```

## 📱 Android

### Qué hace el script:
1. Limpia builds anteriores
2. Obtiene dependencias
3. Genera código (freezed, json_serializable)
4. Verifica configuración de firma
5. Compila el App Bundle (.aab)

### Requisitos previos:
- Flutter SDK instalado
- Android SDK instalado
- Archivo `android/key.properties` configurado con las credenciales de firma

### Salida:
```
build/app/outputs/bundle/release/app-release.aab
```

### Siguiente paso:
Sube el archivo `.aab` a Google Play Console.

---

## 🍎 iOS

### Qué hace el script:
1. Verifica que estés en macOS
2. Limpia builds anteriores
3. Obtiene dependencias
4. Genera código (freezed, json_serializable)
5. Actualiza CocoaPods
6. Compila el IPA

### Requisitos previos:
- macOS
- Xcode instalado
- Certificados de desarrollo/distribución de Apple configurados
- CocoaPods instalado

### Salida:
```
build/ios/ipa/
```

### Siguiente paso:
1. Archiva en Xcode: `Product > Archive`
2. O sube usando: `xcrun altool --upload-app --file build/ios/ipa/*.ipa`

---

## 🌐 Web

### Qué hace el script:
1. Limpia builds anteriores
2. Obtiene dependencias
3. Genera código (freezed, json_serializable)
4. Compila la aplicación Web usando renderer HTML
5. Crea un ZIP para distribución

### Requisitos previos:
- Flutter SDK instalado
- Soporte Web habilitado en Flutter

### Salida:
```
build/web/
build/web.zip
```

### Probar localmente:
```bash
python3 -m http.server 8000 --directory build/web
```
Luego abre: http://localhost:8000

### Desplegar en producción:
- Sube el contenido de `build/web/` a tu servidor
- O usa Firebase Hosting, Netlify, Vercel, etc.

---

## 👨‍💻 Modo Desarrollo

Para ejecutar la app en modo desarrollo (debug) sin hacer un build completo:

```bash
# Ejecutar en Android
./scripts/dev_run.sh android

# Ejecutar en iOS
./scripts/dev_run.sh ios

# Ejecutar en Web (Chrome)
./scripts/dev_run.sh web

# Ver dispositivos disponibles
./scripts/dev_run.sh devices
```

### Ventajas del modo desarrollo:
- ✅ Hot reload habilitado
- ✅ No limpia builds anteriores
- ✅ Más rápido que build completo
- ✅ Perfecto para desarrollo iterativo

---

## ⚙️ Configuración

### Permisos de ejecución

Si los scripts no tienen permisos de ejecución:

```bash
chmod +x scripts/*.sh
```

### Variables de entorno

Los scripts usan las configuraciones del proyecto en:
- `android/key.properties` - Credenciales de firma Android
- `ios/Runner.xcodeproj` - Configuración de Xcode
- `lib/app/config/revenue_cat_keys.dart` - Claves de RevenueCat

---

## 🛠️ Troubleshooting

### Error: "flutter: command not found"
Asegúrate de que Flutter esté en tu PATH:
```bash
export PATH="$PATH:/path/to/flutter/bin"
```

### Error: "pod: command not found" (iOS)
Instala CocoaPods:
```bash
sudo gem install cocoapods
```

### Error de firma en Android
Verifica que `android/key.properties` exista y contenga:
```properties
storePassword=tu_password
keyPassword=tu_password
keyAlias=tu_alias
storeFile=/ruta/a/tu/keystore.jks
```

### Error de firma en iOS
Abre el proyecto en Xcode y verifica:
1. Equipo de desarrollo seleccionado
2. Certificados válidos
3. Provisioning profiles configurados

---

## 📝 Notas

- **Android**: El script genera un App Bundle (.aab), no un APK. Google Play requiere App Bundles desde agosto 2021.
- **iOS**: Requiere macOS y Xcode. No se puede compilar en Windows/Linux.
- **Web**: Usa el renderer HTML para mejor compatibilidad con navegadores antiguos. Para mejor rendimiento, puedes cambiar a `--web-renderer canvaskit`.

---

## 🔄 Actualización de scripts

Si necesitas modificar algún script:

1. Edita el archivo `.sh` correspondiente
2. Asegúrate de mantener `set -e` al inicio (detiene ejecución si hay error)
3. Usa las funciones de colores para output consistente

---

## 📧 Soporte

Si encuentras algún problema con los scripts, contacta al equipo de desarrollo.

---

**Última actualización**: 2025-01-06
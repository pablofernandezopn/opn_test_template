# 🎨 Sistema de Flavors Multi-App

Este proyecto utiliza un sistema de **flavors (sabores)** para generar múltiples aplicaciones desde un único codebase. Cada flavor representa una app diferente con su propio branding, configuración y credenciales.

## 📋 Tabla de Contenidos

- [¿Qué es un Flavor?](#qué-es-un-flavor)
- [Estructura de Archivos](#estructura-de-archivos)
- [Flavors Disponibles](#flavors-disponibles)
- [Crear un Nuevo Flavor](#crear-un-nuevo-flavor)
- [Configuración por Flavor](#configuración-por-flavor)
- [Compilar una App](#compilar-una-app)
- [Deep Links por Flavor](#deep-links-por-flavor)
- [Signing y Keystores](#signing-y-keystores)
- [Troubleshooting](#troubleshooting)

---

## ¿Qué es un Flavor?

Un **flavor** (sabor) es una variante de la app con configuración personalizada:

- 🏷️ **Nombre diferente**: "OPN Test Guardia Civil" vs "OPN Test Policía Nacional"
- 🎨 **Branding único**: Logos, colores, textos personalizados
- 🔐 **Credenciales propias**: Supabase, Firebase, RevenueCat distintos
- 📦 **Package ID diferente**: Pueden coexistir en el mismo dispositivo
- 🔗 **Deep links únicos**: Cada app responde a sus propios enlaces

**Ventajas:**
- ✅ Un solo código base para mantener
- ✅ Bugs fixes se propagan a todas las apps
- ✅ Features nuevos disponibles para todos
- ✅ Fácil crear nuevas apps white-label

---

## Estructura de Archivos

```
OPN_Test_Guardia_Civil/
├── lib/
│   ├── main.dart                    # Entry point genérico (template)
│   ├── main_guardia_civil.dart      # Entry point flavor Guardia Civil
│   ├── main_policia_nacional.dart   # Entry point flavor Policía Nacional
│   └── config/
│       └── flavor_config.dart       # Clase que maneja configuración
│
├── flavors/                         # 🎨 Configuración por flavor
│   ├── guardia_civil/
│   │   ├── config.json              # Configuración del flavor
│   │   ├── .env.guardia_civil       # Variables de entorno
│   │   ├── android/
│   │   │   ├── upload-keystore.jks  # 🔐 Keystore de firma (NO GIT)
│   │   │   └── key.properties       # 🔐 Credenciales (NO GIT)
│   │   ├── ios/
│   │   │   └── GoogleService-Info.plist
│   │   └── assets/
│   │       └── images/
│   │           └── logo.png
│   │
│   └── policia_nacional/
│       └── ...                      # Misma estructura
│
├── android/
│   └── app/
│       └── build.gradle.kts         # Configuración de flavors Android
│
└── scripts/
    └── generate_keystore.sh         # Script para generar keystores
```

---

## Flavors Disponibles

### 1. Guardia Civil (`guardiaCivil`)

```bash
# Development
flutter run -t lib/main_guardia_civil.dart --flavor guardiaCivil

# Release APK
flutter build apk -t lib/main_guardia_civil.dart --flavor guardiaCivil --release

# Release App Bundle
flutter build appbundle -t lib/main_guardia_civil.dart --flavor guardiaCivil --release
```

**Configuración:**
- Package ID: `com.isyfu.opn.guardiacivil`
- Bundle ID: `com.isyfu.opn.guardiacivil`
- Deep Link: `opngc://`
- Domain: `oposicionesguardiacivil.online`

### 2. Policía Nacional (`policiaNacional`) - Ejemplo

```bash
flutter run -t lib/main_policia_nacional.dart --flavor policiaNacional
```

**Configuración:**
- Package ID: `com.isyfu.opn.policianacional`
- Bundle ID: `com.isyfu.opn.policianacional`
- Deep Link: `opnpn://`
- Domain: `oposicionespolicianacional.online`

---

## Crear un Nuevo Flavor

### Paso 1: Crear Estructura de Directorios

```bash
mkdir -p flavors/policia_nacional/{android,ios,assets/images}
```

### Paso 2: Crear Configuración (`config.json`)

Crear `flavors/policia_nacional/config.json`:

```json
{
  "app": {
    "name": "OPN Test Policía Nacional",
    "organizationName": "Oposiciones Policía Nacional",
    "domain": "oposicionespolicianacional.online",
    "website": "www.oposicionespolicianacional.online",
    "supportEmail": "hola@oposicionespolicianacional.online",
    "termsUrl": "https://oposicionespolicianacional.online/aviso-legal/",
    "privacyUrl": "https://oposicionespolicianacional.online/politica-privacidad/"
  },
  "identifiers": {
    "packageName": "com.isyfu.opn.policianacional",
    "bundleId": "com.isyfu.opn.policianacional"
  },
  "deepLinks": {
    "scheme": "opnpn",
    "domain": "oposicionespolicianacional.online"
  },
  "branding": {
    "primaryColor": "#1976D2",
    "secondaryColor": "#424242",
    "accentColor": "#FF5722",
    "logoPath": "flavors/policia_nacional/assets/images/logo.png"
  },
  "services": {
    "supabase": {
      "url": "https://YOUR_SUPABASE_PROJECT.supabase.co",
      "anonKey": "YOUR_SUPABASE_ANON_KEY"
    }
  },
  "texts": {
    "disclaimer": "Descargo de responsabilidad...",
    "welcomeSubtitle": "Consigue tu apto para la Policía Nacional",
    "signInInfo": "Tus datos de acceso son los mismos que en www.oposicionespolicianacional.online"
  }
}
```

### Paso 3: Crear Variables de Entorno

Crear `flavors/policia_nacional/.env.policia_nacional`:

```env
DEEP_LINK_DOMAIN=oposicionespolicianacional.online
DEEP_LINK_SCHEME=opnpn
```

### Paso 4: Generar Keystore para Android

```bash
cd scripts
./generate_keystore.sh policia_nacional "Policía Nacional"
```

Esto creará:
- `flavors/policia_nacional/android/upload-keystore.jks`
- `flavors/policia_nacional/android/key.properties`
- `flavors/policia_nacional/android/keystore_credentials_BACKUP.txt`

⚠️ **IMPORTANTE**: Guarda el archivo de backup en un lugar seguro (1Password, etc.)

### Paso 5: Agregar Assets

Copiar logo y otros assets:

```bash
cp tu_logo.png flavors/policia_nacional/assets/images/logo.png
```

### Paso 6: Crear Entry Point

Crear `lib/main_policia_nacional.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:opn_test_template/bootstrap.dart';
import 'package:opn_test_template/config/environment.dart';
import 'package:opn_test_template/config/flavor_config.dart';

import 'app/app.dart';
import 'app/config/app_bloc_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlavorConfig.initialize('policia_nacional');
  FlavorConfig.instance.printConfig();

  final navigatorKey = GlobalKey<NavigatorState>();

  bootstrap(
    navigatorKey,
    BuildVariant.production,
    () => AppBlocProviders(
      navigatorKey: navigatorKey,
      child: MyApp(navigatorKey: navigatorKey),
    ),
  );
}
```

### Paso 7: Configurar Android Gradle

Agregar en `android/app/build.gradle.kts`:

```kotlin
// En signingConfigs
create("policiaNacional") {
    val keystorePropertiesFile = rootProject.file("../../flavors/policia_nacional/android/key.properties")
    if (keystorePropertiesFile.exists()) {
        val keystoreProperties = java.util.Properties()
        keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))

        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = rootProject.file("../../flavors/policia_nacional/android/${keystoreProperties["storeFile"]}")
        storePassword = keystoreProperties["storePassword"] as String
    }
}

// En productFlavors
create("policiaNacional") {
    dimension = "app"
    applicationId = "com.isyfu.opn.policianacional"
    versionNameSuffix = "-pn"
    resValue("string", "app_name", "OPN Test Policía Nacional")
    signingConfig = signingConfigs.getByName("policiaNacional")
}
```

### Paso 8: Actualizar pubspec.yaml

Agregar assets del nuevo flavor:

```yaml
flutter:
  assets:
    - flavors/policia_nacional/
    - flavors/policia_nacional/assets/images/
```

### Paso 9: Configurar iOS (opcional)

Crear configuraciones específicas en Xcode para el flavor.

---

## Configuración por Flavor

### config.json

Cada flavor tiene un `config.json` con toda su configuración:

```json
{
  "app": { },              // Información de la app
  "identifiers": { },      // Package name y Bundle ID
  "deepLinks": { },        // Configuración de deep links
  "branding": { },         // Colores y logo
  "services": { },         // Supabase, Firebase, RevenueCat, etc.
  "texts": { }             // Textos personalizados
}
```

### Acceder a la Configuración

En el código Dart:

```dart
// Acceder a valores
final appName = FlavorConfig.instance.appName;
final primaryColor = FlavorConfig.instance.primaryColor;
final supabaseUrl = FlavorConfig.instance.supabaseUrl;

// Generar URLs
final termsUrl = FlavorConfig.instance.termsUrl;
final deepLink = FlavorConfig.instance.getDeepLink('/home'); // 'opngc://home'
final appLink = FlavorConfig.instance.getAppLink('/test'); // 'https://domain.com/test'
```

---

## Compilar una App

### Android

```bash
# Debug (para testing)
flutter build apk -t lib/main_guardia_civil.dart --flavor guardiaCivil --debug

# Release APK (para distribución directa)
flutter build apk -t lib/main_guardia_civil.dart --flavor guardiaCivil --release

# Release App Bundle (para Google Play)
flutter build appbundle -t lib/main_guardia_civil.dart --flavor guardiaCivil --release
```

Los archivos generados estarán en:
- APK: `build/app/outputs/flutter-apk/app-guardiaCivil-release.apk`
- AAB: `build/app/outputs/bundle/guardiaCivilRelease/app-guardiaCivil-release.aab`

### iOS

```bash
flutter build ios -t lib/main_guardia_civil.dart --release
```

Luego abrir Xcode para archive y upload.

---

## Deep Links por Flavor

Cada flavor tiene sus propios deep links configurados en `config.json`:

### Guardia Civil
```json
{
  "deepLinks": {
    "scheme": "opngc",
    "domain": "oposicionesguardiacivil.online"
  }
}
```

**Soporta:**
- Custom scheme: `opngc://home`
- Universal Links: `https://oposicionesguardiacivil.online/home`

### Policía Nacional (ejemplo)
```json
{
  "deepLinks": {
    "scheme": "opnpn",
    "domain": "oposicionespolicianacional.online"
  }
}
```

**Soporta:**
- Custom scheme: `opnpn://home`
- Universal Links: `https://oposicionespolicianacional.online/home`

### Configurar en Android

El `AndroidManifest.xml` base tiene placeholders genéricos. Para configuración específica, puedes crear manifests por flavor en `android/app/src/guardiaCivil/AndroidManifest.xml`.

### Configurar en iOS

Actualizar `Info.plist` por flavor o usar configuraciones de Xcode.

---

## Signing y Keystores

### Generar Keystore

Usa el script automático:

```bash
cd scripts
./generate_keystore.sh <flavor_name> "<Organization Name>"

# Ejemplo
./generate_keystore.sh policia_nacional "Policía Nacional"
```

Esto genera:
- **upload-keystore.jks**: El archivo de firma
- **key.properties**: Credenciales
- **keystore_credentials_BACKUP.txt**: Backup para guardar

### Seguridad de Keystores

⚠️ **MUY IMPORTANTE**:

1. **NO commitear** keystores ni key.properties a Git
2. **Guardar backup** en gestor de contraseñas (1Password, LastPass)
3. **Hacer copia de seguridad** del .jks en almacenamiento cifrado
4. Si pierdes el keystore, **NO podrás actualizar** la app en Google Play

### Verificar Firma

```bash
# Verificar firma del APK
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-guardiaCivil-release.apk

# Ver detalles del keystore
keytool -list -v -keystore flavors/guardia_civil/android/upload-keystore.jks
```

---

## Troubleshooting

### Error: "FlavorConfig no ha sido inicializado"

**Solución**: Asegúrate de llamar a `FlavorConfig.initialize()` antes de `runApp()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlavorConfig.initialize('guardia_civil'); // ← Importante
  runApp(MyApp());
}
```

### Error: "No se encontró key.properties"

**Solución**: Genera el keystore:

```bash
cd scripts
./generate_keystore.sh guardia_civil "Guardia Civil"
```

### Error: "Unable to load asset flavors/X/config.json"

**Solución**: Verifica que el archivo exista y esté agregado en `pubspec.yaml`:

```yaml
flutter:
  assets:
    - flavors/guardia_civil/
```

### Deep links no funcionan

**Solución**:

1. Android: Verificar que el `scheme` en AndroidManifest coincida con `config.json`
2. iOS: Verificar que el `scheme` en Info.plist coincida con `config.json`
3. Universal Links: Verificar que existe `assetlinks.json` / `apple-app-site-association`

### La app se crashea al inicio

**Solución**: Ejecuta con logs:

```bash
flutter run -t lib/main_guardia_civil.dart --flavor guardiaCivil -v
```

Verifica en los logs que FlavorConfig se inicializa correctamente.

---

## 📝 Checklist para Nuevo Flavor

- [ ] Crear directorio en `flavors/<flavor_name>/`
- [ ] Crear `config.json` con toda la configuración
- [ ] Crear `.env.<flavor_name>` con variables de entorno
- [ ] Generar keystore con `generate_keystore.sh`
- [ ] Guardar backup del keystore en lugar seguro
- [ ] Agregar logo y assets en `assets/images/`
- [ ] Crear `lib/main_<flavor_name>.dart`
- [ ] Actualizar `android/app/build.gradle.kts` con flavor
- [ ] Actualizar `pubspec.yaml` con assets del flavor
- [ ] Configurar iOS si es necesario
- [ ] Probar build debug y release
- [ ] Verificar deep links
- [ ] Subir a stores

---

## 🎯 Próximos Pasos

1. **Crear flavor Policía Nacional** siguiendo esta guía
2. **Automatizar** más el proceso con scripts
3. **CI/CD**: Configurar GitHub Actions para builds automáticos
4. **Fastlane**: Automatizar deployment a stores

---

## 📚 Recursos

- [Flutter Flavors Documentation](https://docs.flutter.dev/deployment/flavors)
- [Android Product Flavors](https://developer.android.com/studio/build/build-variants)
- [iOS Multiple Environments](https://developer.apple.com/documentation/xcode/customizing-the-build-schemes-for-a-project)

---

**Creado por**: OPN Test Team
**Última actualización**: 2025-01-16

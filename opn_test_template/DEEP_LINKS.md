# 🔗 Configuración de Deep Links

Esta aplicación soporta deep links tanto para iOS como para Android. Los usuarios pueden abrir la app usando:

## 📱 Tipos de Deep Links

### 1. Esquema personalizado (Custom URL Scheme)
```
opngc://home
opngc://test-config
opngc://profile
```

### 2. URLs web (Universal Links / App Links)
```
https://oposicionesguardiacivil.online/home
https://oposicionesguardiacivil.online/test-config
https://oposicionesguardiacivil.online/profile
```

## ⚙️ Configuración realizada

### ✅ Android
- ✅ Intent filters configurados en `AndroidManifest.xml`
- ✅ Soporte para esquema personalizado `opngc://`
- ✅ Soporte para App Links (https)
- ✅ autoVerify activado para verificación automática

### ✅ iOS
- ✅ CFBundleURLTypes configurado en `Info.plist`
- ✅ Associated Domains configurado en entitlements
- ✅ Soporte para esquema personalizado `opngc://`
- ✅ Soporte para Universal Links (https)

### ✅ Flutter
- ✅ Servicio de Deep Links implementado
- ✅ Integración con GoRouter
- ✅ Manejo de deep links iniciales (app cerrada)
- ✅ Escucha de deep links en tiempo real (app abierta)
- ✅ Variables de entorno para cambiar dominio fácilmente

## 🌐 Configuración del servidor web

Para que los **App Links (Android)** y **Universal Links (iOS)** funcionen correctamente, debes configurar archivos de verificación en tu servidor web.

### 📄 Para Android - assetlinks.json

Crea el archivo en:
```
https://oposicionesguardiacivil.online/.well-known/assetlinks.json
```

Contenido del archivo:
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.isyfu.opnTestGuardiaCivil",
    "sha256_cert_fingerprints": [
      "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    ]
  }
}]
```

#### 🔐 Cómo obtener el SHA256 fingerprint:

**Para keystore de debug:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Para keystore de producción:**
```bash
keytool -list -v -keystore /ruta/a/tu/keystore.jks -alias tu_alias
```

O desde Google Play Console:
1. Ve a **Configuración de la app > Integridad de la app**
2. Busca **SHA-256 certificate fingerprint** en la sección de firmas

**IMPORTANTE:** Necesitarás agregar **dos** fingerprints:
- Uno para tu keystore local (debug/release)
- Uno para la firma de Google Play (si usas App Signing)

### 🍎 Para iOS - apple-app-site-association

Crea el archivo en:
```
https://oposicionesguardiacivil.online/.well-known/apple-app-site-association
```

O alternativamente en:
```
https://oposicionesguardiacivil.online/apple-app-site-association
```

Contenido del archivo (SIN extensión .json):
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.isyfu.opnTestGuardiaCivil",
        "paths": [
          "/home",
          "/test-config",
          "/profile",
          "/history",
          "/stats",
          "/ranking/*",
          "/topic-test/*",
          "/preview-topic/*",
          "/survival-test",
          "/*"
        ]
      }
    ]
  }
}
```

#### 🔐 Cómo obtener tu Team ID:

1. Ve a [Apple Developer](https://developer.apple.com/account)
2. Ve a **Membership**
3. Encuentra tu **Team ID** (formato: XXXXXXXXXX)
4. Reemplaza `TEAM_ID` en el archivo con tu Team ID real

### 🚀 Configuración del servidor

Los archivos deben servirse con:
- **Content-Type:** `application/json`
- **HTTPS:** Obligatorio (no funcionará con HTTP)
- **Sin redirecciones:** El archivo debe ser accesible directamente

#### Ejemplo con Nginx:
```nginx
location /.well-known/assetlinks.json {
    default_type application/json;
    add_header Access-Control-Allow-Origin *;
}

location /.well-known/apple-app-site-association {
    default_type application/json;
    add_header Access-Control-Allow-Origin *;
}
```

#### Ejemplo con Apache (.htaccess):
```apache
<Files "assetlinks.json">
    Header set Content-Type "application/json"
    Header set Access-Control-Allow-Origin "*"
</Files>

<Files "apple-app-site-association">
    Header set Content-Type "application/json"
    Header set Access-Control-Allow-Origin "*"
</Files>
```

## ✅ Verificación

### Android App Links:
1. Verifica que el archivo esté accesible:
```bash
curl https://oposicionesguardiacivil.online/.well-known/assetlinks.json
```

2. Usa la herramienta de Google:
https://developers.google.com/digital-asset-links/tools/generator

3. Prueba con ADB:
```bash
adb shell am start -a android.intent.action.VIEW -d "https://oposicionesguardiacivil.online/home" com.isyfu.opnTestGuardiaCivil
```

### iOS Universal Links:
1. Verifica que el archivo esté accesible:
```bash
curl https://oposicionesguardiacivil.online/.well-known/apple-app-site-association
```

2. Usa el validador de Apple:
https://search.developer.apple.com/appsearch-validation-tool/

3. Prueba desde Safari:
   - Abre Safari en iOS
   - Escribe: `https://oposicionesguardiacivil.online/home`
   - Presiona el banner "Abrir en OPN Test Guardia Civil"

## 🧪 Testing

### Probar esquemas personalizados:

**Android:**
```bash
adb shell am start -a android.intent.action.VIEW -d "opngc://home"
```

**iOS (Simulator):**
```bash
xcrun simctl openurl booted "opngc://home"
```

### Probar URLs web:

**Android:**
```bash
adb shell am start -a android.intent.action.VIEW -d "https://oposicionesguardiacivil.online/home"
```

**iOS:**
Desde Safari, navega a: `https://oposicionesguardiacivil.online/home`

## 🔄 Cambiar el dominio

Si necesitas cambiar el dominio:

1. Edita el archivo `.env`:
```env
DEEP_LINK_DOMAIN=tu-nuevo-dominio.com
DEEP_LINK_SCHEME=opngc
```

2. Ejecuta:
```bash
flutter pub get
flutter clean
flutter run
```

## 📋 Rutas soportadas

Todas las rutas de la app soportan deep links:

- `/home` - Página principal
- `/test-config` - Configuración de test
- `/topic-test/:token` - Test de un tema
- `/preview-topic/:topicId` - Preview de un tema
- `/survival-test` - Modo supervivencia
- `/history` - Historial de tests
- `/stats` - Estadísticas
- `/ranking/:topicId/:topicName` - Ranking de un tema
- `/opn-ranking` - Ranking global
- `/profile` - Perfil de usuario
- `/settings` - Configuración
- `/favorites` - Preguntas favoritas
- `/challenges` - Impugnaciones
- `/ai-chat` - Chat con IA
- Y más...

Para ver la lista completa, consulta `lib/app/config/go_route/app_routes.dart`

## 🐛 Troubleshooting

### Android App Links no funcionan:
1. Verifica que el archivo `assetlinks.json` sea accesible vía HTTPS
2. Verifica que el SHA256 fingerprint sea correcto
3. Verifica que el package name coincida
4. Reinstala la app después de configurar el archivo
5. Limpia los datos de la app: Settings > Apps > OPN Test > Storage > Clear Data

### iOS Universal Links no funcionan:
1. Verifica que el archivo `apple-app-site-association` sea accesible vía HTTPS
2. Verifica que el Team ID y Bundle ID sean correctos
3. Verifica que Associated Domains esté habilitado en Xcode
4. Los Universal Links NO funcionan desde la misma app (Safari -> App ✅, App -> App ❌)
5. Reinstala la app después de configurar el archivo

### Deep links no navegan a la ruta correcta:
1. Verifica los logs en consola (busca 🔗)
2. Verifica que la ruta exista en `app_routes.dart`
3. Verifica que el formato del link sea correcto

## 📚 Referencias

- [Android App Links](https://developer.android.com/training/app-links)
- [iOS Universal Links](https://developer.apple.com/ios/universal-links/)
- [app_links package](https://pub.dev/packages/app_links)
- [GoRouter Deep Linking](https://pub.dev/documentation/go_router/latest/topics/Deep%20linking-topic.html)
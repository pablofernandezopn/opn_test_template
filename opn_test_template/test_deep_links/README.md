# 🧪 Scripts de Prueba para Deep Links en iOS

Esta carpeta contiene scripts para probar los deep links de la aplicación en iOS.

## 📋 Scripts disponibles

### 1. `test_all_ios.sh` - Script maestro
Ejecuta todas las pruebas secuencialmente con pausas entre cada una.

```bash
./test_all_ios.sh
```

### 2. `test_custom_scheme_ios.sh` - Esquemas personalizados
Prueba deep links con el esquema `opngc://`

```bash
./test_custom_scheme_ios.sh
```

Ejemplos de URLs probadas:
- `opngc://home`
- `opngc://test-config`
- `opngc://profile`

### 3. `test_web_links_ios.sh` - Universal Links
Prueba deep links con URLs web `https://oposicionesguardiacivil.online/`

```bash
./test_web_links_ios.sh
```

Ejemplos de URLs probadas:
- `https://oposicionesguardiacivil.online/home`
- `https://oposicionesguardiacivil.online/test-config`
- `https://oposicionesguardiacivil.online/profile`

### 4. `test_with_params_ios.sh` - Deep links con parámetros
Prueba deep links que incluyen parámetros en la URL

```bash
./test_with_params_ios.sh
```

Ejemplos de URLs probadas:
- `opngc://preview-topic/123`
- `opngc://test-config?topicId=202&mode=practice`
- `https://oposicionesguardiacivil.online/ranking/456/Test%20de%20Prueba`

## 🚀 Cómo usar

### Paso 1: Preparación

1. **Inicia el simulador de iOS:**
```bash
open -a Simulator
```

2. **Ejecuta la app en el simulador:**
```bash
flutter run
```

3. **Espera a que la app cargue completamente**

### Paso 2: Hacer los scripts ejecutables

```bash
cd test_deep_links
chmod +x *.sh
```

### Paso 3: Ejecutar las pruebas

**Opción A: Ejecutar todas las pruebas**
```bash
./test_all_ios.sh
```

**Opción B: Ejecutar pruebas individuales**
```bash
# Solo esquemas personalizados
./test_custom_scheme_ios.sh

# Solo URLs web
./test_web_links_ios.sh

# Solo parámetros
./test_with_params_ios.sh
```

## 🔍 Qué verificar

### En el simulador:
- ✅ La app se abre automáticamente
- ✅ La navegación lleva a la pantalla correcta
- ✅ Los parámetros se pasan correctamente

### En los logs de Xcode:
Busca estas líneas en los logs:
```
🔗 Deep Link recibido: opngc://home
📍 Navegando a: /home
```

### Para ver los logs:
1. Abre Xcode
2. Ve a **Window > Devices and Simulators**
3. Selecciona tu simulador
4. Click en **Open Console**
5. Filtra por "Deep Link" o "🔗"

## ⚠️ Solución de problemas

### El simulador no se detecta
```bash
# Verifica que el simulador esté iniciado
xcrun simctl list devices | grep Booted

# Si no hay ninguno, inicia uno:
open -a Simulator
```

### La app no se abre
- Verifica que la app esté instalada: `flutter run`
- Verifica que el bundle ID sea correcto
- Reinstala la app si es necesario

### Los Universal Links no funcionan
1. Verifica que el archivo `apple-app-site-association` esté en el servidor:
```bash
curl https://oposicionesguardiacivil.online/.well-known/apple-app-site-association
```

2. Verifica tu Team ID en Xcode
3. Reinstala la app después de configurar el servidor
4. Recuerda: Los Universal Links **no funcionan** desde la misma app, solo desde otras apps como Safari

### Permiso denegado al ejecutar scripts
```bash
chmod +x *.sh
```

## 📊 Resultado esperado

Si todo funciona correctamente, deberías ver:

1. **En el terminal:**
```
🔗 Probando Deep Links con esquema personalizado (opngc://) en iOS
================================================================

✅ Usando simulador: ED5DA080-A498-498D-9F26-A82D8F89631E

📱 Probando: Página principal
   URL: opngc://home
   ✅ Comando ejecutado correctamente
```

2. **En el simulador:**
- La app se abre (o viene al frente si ya estaba abierta)
- Navega a la pantalla correspondiente

3. **En los logs de Flutter:**
```
🔗 Deep Link recibido: opngc://home
📍 Navegando a: /home
```

## 🎯 Próximos pasos después de probar

1. **Si los esquemas personalizados funcionan:** ✅ Configuración básica OK
2. **Si los Universal Links funcionan:** ✅ Configuración completa OK
3. **Si los parámetros funcionan:** ✅ Navegación dinámica OK

Una vez que todo funcione en el simulador, prueba en un **dispositivo físico** para validar completamente.

## 📖 Más información

Consulta `DEEP_LINKS.md` en la raíz del proyecto para documentación completa sobre:
- Configuración del servidor
- Verificación de enlaces
- Troubleshooting avanzado
# 🔧 Configuración de Supabase Local con Edge Functions

## ⚠️ Situación Actual

Actualmente, el modo **Development** está configurado para usar **Supabase de Producción** porque las Edge Functions no están corriendo localmente.

## 📋 Para usar Supabase completamente local

### 1. Instalar Supabase CLI

```bash
# macOS
brew install supabase/tap/supabase

# Verificar instalación
supabase --version
```

### 2. Iniciar Supabase localmente

```bash
cd /path/to/your/project

# Iniciar todos los servicios de Supabase (incluidas Edge Functions)
supabase start

# Esto iniciará:
# - PostgreSQL (base de datos)
# - PostgREST (API REST)
# - Realtime
# - Storage
# - Edge Functions
# - Studio (UI de administración)
```

### 3. Verificar que las Edge Functions estén corriendo

```bash
# Ver el estado de todos los servicios
supabase status

# Deberías ver algo como:
# API URL: http://localhost:54321
# Edge Functions URL: http://localhost:54321/functions/v1
```

### 4. Desplegar las Edge Functions localmente

Si tienes las funciones en un directorio `supabase/functions/`:

```bash
# Desplegar todas las funciones
supabase functions serve

# O desplegar una función específica
supabase functions serve login-register
```

### 5. Actualizar el código de Flutter

Una vez que Supabase local esté corriendo con Edge Functions, descomentar el código en `lib/config/environment.dart`:

```dart
case BuildVariant.development:
  // Descomentar esta sección:
  const localIp = String.fromEnvironment(
    'LOCAL_IP',
    defaultValue: '127.0.0.1',
  );

  final baseIp = Platform.isAndroid && localIp == '127.0.0.1'
      ? '10.0.2.2'
      : localIp;

  _supabaseUrl = 'http://$baseIp:54321';
  _supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
  // ... resto de la configuración
```

Y cambiar:
```dart
bool get isLocal => true; // Cambiar de false a true
```

### 6. Edge Functions necesarias

Tu app necesita estas funciones:

1. **login-register/v1/login** - Para iniciar sesión
2. **login-register/v1/register** - Para registrarse
3. **login-register/v1/get_user** - Para obtener datos del usuario

## 🔍 Verificar que funciona

1. Abrir Supabase Studio: http://localhost:54323
2. Ir a la sección de Edge Functions
3. Probar las funciones directamente desde el Studio

## 📝 Notas

- **Producción**: Las Edge Functions ya están desplegadas y funcionando
- **Desarrollo local**: Solo la base de datos está corriendo, las Edge Functions NO
- **Solución temporal**: Usar Supabase de producción en modo desarrollo

## 🚀 Comandos útiles

```bash
# Detener Supabase local
supabase stop

# Reiniciar Supabase local
supabase stop && supabase start

# Ver logs de Edge Functions
supabase functions logs login-register

# Limpiar y reiniciar desde cero
supabase db reset
```

## 📚 Documentación oficial

- [Supabase CLI](https://supabase.com/docs/guides/cli)
- [Edge Functions](https://supabase.com/docs/guides/functions)
- [Local Development](https://supabase.com/docs/guides/cli/local-development)


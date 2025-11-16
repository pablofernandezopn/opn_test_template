# 🎨 Sistema de Temas de la Aplicación

Este directorio contiene la configuración completa del sistema de temas de la aplicación, organizado de manera modular para facilitar su mantenimiento y comprensión.

## 📁 Estructura de Archivos

```
theme/
├── README.md                    # Este archivo - Guía del sistema de temas
├── color.dart                   # Paleta de colores (light & dark)
├── theme.dart                   # Configuración principal de temas
├── app_text_theme.dart         # Estilos de tipografía
├── app_button_theme.dart       # Estilos de botones
├── app_input_theme.dart        # Estilos de campos de texto
├── app_component_theme.dart    # Otros componentes (AppBar, Checkbox, etc.)
└── app_icons.dart              # Iconos personalizados de la app
```

## 🚀 Cómo Usar

### 1. Aplicar el Tema Principal

En tu `MaterialApp`, aplica el tema:

```dart
MaterialApp(
  theme: AppTheme.light,        // Tema claro
  darkTheme: AppTheme.dark,     // Tema oscuro
  themeMode: ThemeMode.system,  // Automático según el sistema
  // ...
)
```

### 2. Usar Colores del Tema

Accede a los colores a través del `Theme.of(context)`:

```dart
// ✅ FORMA RECOMENDADA - Usa el ColorScheme
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Hola',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
  ),
)

// También puedes acceder directamente a las clases de colores
Container(
  color: AppColorsLight.primary,  // Solo si necesitas forzar un color específico
)
```

### 3. Usar Estilos de Texto

```dart
// Usa los estilos predefinidos del tema
Text(
  'Título Grande',
  style: Theme.of(context).textTheme.titleLarge,
)

Text(
  'Cuerpo de texto',
  style: Theme.of(context).textTheme.bodyMedium,
)
```

### 4. Usar Botones con Estilos del Tema

Los botones automáticamente usan los estilos definidos:

```dart
// Botón principal (fondo sólido)
ElevatedButton(
  onPressed: () {},
  child: Text('Botón Principal'),
)

// Botón secundario (borde)
OutlinedButton(
  onPressed: () {},
  child: Text('Botón Secundario'),
)
```

### 5. Usar Iconos Personalizados

```dart
Icon(AppIcons.lockIcon)
Icon(AppIcons.correctIcon, color: Colors.green)
```

## 🎨 Paleta de Colores

### Tema Claro (Light Theme)

| Color | Uso Principal | Ejemplo |
|-------|---------------|---------|
| **primary** | AppBar, botones principales, elementos destacados | Botones de acción |
| **primaryContainer** | Fondos de secciones destacadas | Cards importantes |
| **secondary** | Botones secundarios, elementos interactivos | Chips, badges |
| **secondaryContainer** | Cards, contenedores de información | Listas agrupadas |
| **tertiary** | Badges, notificaciones, llamadas a la acción | Insignias doradas |
| **tertiaryContainer** | Banners informativos, alertas suaves | Avisos importantes |
| **surface** | Cards, Dialogs, BottomSheets | Tarjetas |
| **background** | Fondo general de la app | Scaffold |
| **error** | Mensajes de error, validaciones fallidas | SnackBars de error |

### Colores "On" (Texto/Iconos sobre otros colores)

Los colores que empiezan con `on` se usan para texto e iconos sobre otros colores:

- `onPrimary` - Texto blanco sobre `primary`
- `onSurface` - Texto oscuro sobre `surface`
- `onError` - Texto blanco sobre `error`
- etc.

## 📝 Estilos de Tipografía

| Estilo | Tamaño | Peso | Uso |
|--------|--------|------|-----|
| `titleLarge` | 32px | Bold | Títulos principales de pantalla |
| `bodyLarge` | 16px | Regular | Párrafos importantes |
| `bodyMedium` | 14px | Regular | Texto normal |
| `bodySmall` | 12px | Regular | Texto secundario, notas |
| `labelLarge` | 14px | Medium | Etiquetas de botones |

## 🔧 Componentes Personalizados

### AppBar
- Fondo: `background` color
- Sin elevación
- Iconos en color `primary`

### Botones
- Border radius: 8px
- Altura mínima: 48px
- Ancho completo por defecto

### Campos de Texto (TextField)
- Border radius: 8px
- Padding: 16px horizontal, 12px vertical
- Fondo: `surface` color

### Checkboxes y Switches
- Color activo: `primary`
- Bordes: 2px

### Tabs
- Indicador personalizado con color `tertiary`
- Border radius: 8px

## 🌙 Tema Oscuro

El tema oscuro utiliza una paleta de grises para mantener legibilidad:
- Fondos: Grises oscuros (#1E1E1E, #2A2A2A)
- Texto: Gris claro (#E0E0E0)
- Primario: Gris claro para contraste

## 💡 Mejores Prácticas

### ✅ DO (Hacer)
- Usa `Theme.of(context).colorScheme.primary` en lugar de valores hardcodeados
- Usa los estilos de texto predefinidos
- Respeta la jerarquía de colores (primary > secondary > tertiary)

### ❌ DON'T (No Hacer)
- No uses colores hardcodeados como `Color(0xFF006B54)` en widgets
- No ignores los colores "on" (pueden causar problemas de contraste)
- No definas nuevos estilos de texto sin añadirlos al tema

## 🔄 Cómo Extender el Tema

### Añadir un Nuevo Color

1. Añádelo a `color.dart`:
```dart
abstract class AppColorsLight {
  // ...existing colors...
  static const Color myNewColor = Color(0xFF123456);
}
```

2. Úsalo en tu app:
```dart
Container(color: AppColorsLight.myNewColor)
```

### Añadir un Nuevo Estilo de Texto

1. Añádelo a `app_text_theme.dart` (cuando lo creemos)
2. Úsalo: `Theme.of(context).textTheme.myNewStyle`

## 📱 Transiciones de Página

La app usa `CupertinoPageTransitionsBuilder` en Android para transiciones suaves estilo iOS.

---

**Nota:** Este sistema de temas sigue las guías de Material Design y está optimizado para Flutter.


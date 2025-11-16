# 📋 Índice del Sistema de Temas

## 📁 Estructura de Archivos

```
theme/
├── 📘 README.md                    # Guía principal del sistema
├── 📗 EXAMPLES.md                  # Ejemplos prácticos de uso
├── 📄 theme_exports.dart           # Archivo de barril (importar todo)
│
├── 🎨 theme.dart                   # ⭐ Configuración principal
├── 🎨 color.dart                   # Paleta de colores
│
├── 📝 app_text_theme.dart         # Estilos de tipografía
├── 🔘 app_button_theme.dart       # Estilos de botones
├── 📝 app_input_theme.dart        # Estilos de campos de texto
├── 🎯 app_component_theme.dart    # Otros componentes
└── 🎯 app_icons.dart              # Iconos personalizados
```

## 🚀 Inicio Rápido

### 1. Importar el Tema

```dart
// Opción 1: Importar solo lo que necesitas
import 'package:opn_app/app/config/theme/theme.dart';

// Opción 2: Importar todo
import 'package:opn_app/app/config/theme/theme_exports.dart';
```

### 2. Aplicar en MaterialApp

```dart
MaterialApp(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: ThemeMode.system,
  // ...
)
```

### 3. Usar en Widgets

```dart
// Colores
Container(
  color: Theme.of(context).colorScheme.primary,
)

// Texto
Text(
  'Hola',
  style: Theme.of(context).textTheme.bodyLarge,
)

// Iconos
Icon(AppIcons.correctIcon)
```

## 📚 Guías de Referencia

| Documento | Descripción |
|-----------|-------------|
| **README.md** | Guía completa del sistema, cómo funciona cada parte |
| **EXAMPLES.md** | Ejemplos de código para casos comunes |
| **INDEX.md** | Este archivo - vista rápida |

## 🎨 Componentes del Sistema

### Colores (color.dart)
- `AppColors` - Colores base genéricos
- `AppColorsLight` - Paleta para tema claro
- `AppColorsDark` - Paleta para tema oscuro

### Tipografía (app_text_theme.dart)
- `AppTextTheme.light` - Estilos de texto claro
- `AppTextTheme.dark` - Estilos de texto oscuro

### Botones (app_button_theme.dart)
- `AppButtonTheme.elevatedLight/Dark` - Botones principales
- `AppButtonTheme.outlinedLight/Dark` - Botones secundarios

### Inputs (app_input_theme.dart)
- `AppInputTheme.light/dark` - TextFields y formularios

### Componentes (app_component_theme.dart)
- AppBar
- Checkboxes
- Switches
- Tabs
- Sliders
- ProgressIndicators
- Scrollbars
- BottomSheets

### Iconos (app_icons.dart)
- `AppIcons` - Todos los iconos personalizados de la app

## 🎯 Mejoras Implementadas

### ✅ Organización
- ✨ Código separado en módulos especializados
- 📦 Archivo de barril para importaciones simples
- 📚 Documentación completa con ejemplos

### ✅ Mantenibilidad
- 🔍 Cada componente en su propio archivo
- 📝 Comentarios explicativos en cada clase
- 🎨 Nombres descriptivos y consistentes

### ✅ Usabilidad
- 💡 Ejemplos de uso en cada archivo
- 📖 Guía de mejores prácticas
- 🎓 Documentación para nuevos desarrolladores

## 🔄 Flujo de Trabajo

```
1. Abrir theme.dart
   ↓
2. Ver los imports de módulos
   ↓
3. Cada módulo es independiente
   ↓
4. Fácil de modificar sin afectar otros
```

## 💡 Consejos

1. **Leer primero:** `README.md` para entender la arquitectura
2. **Aprender haciendo:** `EXAMPLES.md` para ver código real
3. **Referencia rápida:** Este archivo para encontrar lo que necesitas
4. **Modificar:** Edita el módulo específico que necesites cambiar

## 🎨 Paleta de Colores Resumida

### Tema Claro
- 🟢 **Primary:** Verde Guardia Civil (#015341)
- 🟩 **Secondary Container:** Verde pastel (#F0F9F7)
- 🟡 **Tertiary:** Amarillo dorado (#F1BF00)
- ⚪ **Surface:** Blanco (#FFFFFF)
- 🔴 **Error:** Rojo (#C60B1E)

### Tema Oscuro
- ⚪ **Primary:** Gris claro (#E0E0E0)
- ⬛ **Surface:** Gris oscuro (#1E1E1E)
- 🔴 **Error:** Rojo suave (#CF6679)

## 🔗 Enlaces Útiles

- [Material Design Color System](https://m3.material.io/styles/color/overview)
- [Flutter ThemeData](https://api.flutter.dev/flutter/material/ThemeData-class.html)
- [ColorScheme](https://api.flutter.dev/flutter/material/ColorScheme-class.html)

---

**Última actualización:** Octubre 2025
**Versión del sistema:** 2.0 (Modular)


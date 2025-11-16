# CustomSnackBar - Guía de Uso

SnackBars modernos y estilizados con iconos, colores personalizados y animaciones suaves.

## Características

- 🎨 **4 tipos predefinidos**: Success, Error, Info, Warning
- 🎯 **Iconos integrados**: Cada tipo tiene su propio icono y colores
- 🌗 **Soporte Dark/Light**: Se adapta automáticamente al tema
- 🎭 **Animación flotante**: Comportamiento moderno desde abajo
- 📱 **Responsive**: Se ajusta al ancho de la pantalla

## Uso Básico

### 1. Importar el widget

```dart
import 'package:opn_test_guardia_civil/app/shared/widgets/custom_snackbar.dart';
```

### 2. Mostrar SnackBar de éxito

```dart
CustomSnackBar.success(
  context: context,
  message: '¡Test completado exitosamente!',
);
```

### 3. Mostrar SnackBar de error

```dart
CustomSnackBar.error(
  context: context,
  message: 'Error al cargar las preguntas',
);
```

### 4. Mostrar SnackBar de información

```dart
CustomSnackBar.info(
  context: context,
  message: 'Tienes 5 preguntas sin responder',
);
```

### 5. Mostrar SnackBar de advertencia

```dart
CustomSnackBar.warning(
  context: context,
  message: 'El tiempo está por agotarse',
);
```

## Uso Avanzado

### Con acción personalizada

```dart
CustomSnackBar.show(
  context: context,
  message: 'Test finalizado',
  type: SnackBarType.success,
  actionLabel: 'Ver Resultados',
  onActionPressed: () {
    // Navegar a resultados
    context.go('/results');
  },
);
```

### Con duración personalizada

```dart
CustomSnackBar.error(
  context: context,
  message: 'Error crítico detectado',
  duration: const Duration(seconds: 5),
);
```

## Ejemplos por Contexto

### Guardar cambios

```dart
void _saveChanges() async {
  try {
    await saveToDatabase();

    if (mounted) {
      CustomSnackBar.success(
        context: context,
        message: 'Cambios guardados correctamente',
      );
    }
  } catch (e) {
    if (mounted) {
      CustomSnackBar.error(
        context: context,
        message: 'Error al guardar: ${e.toString()}',
      );
    }
  }
}
```

### Validación de formulario

```dart
void _submitForm() {
  if (_formKey.currentState?.validate() != true) {
    CustomSnackBar.warning(
      context: context,
      message: 'Por favor completa todos los campos',
    );
    return;
  }

  // Continuar con el envío...
}
```

### Información de red

```dart
void _checkConnection() {
  if (!isConnected) {
    CustomSnackBar.info(
      context: context,
      message: 'Trabajando en modo offline',
      duration: const Duration(seconds: 4),
    );
  }
}
```

## Personalización de Colores

Los colores se adaptan automáticamente según el tipo:

| Tipo      | Color Principal | Uso                        |
|-----------|----------------|----------------------------|
| Success   | Verde (#4CAF50)| Operaciones exitosas       |
| Error     | Rojo (#F44336) | Errores y fallos           |
| Warning   | Naranja (#FF9800)| Advertencias              |
| Info      | Azul (#2196F3) | Información general        |

## SnackBar básico (sin iconos)

Si solo quieres usar el tema básico sin iconos:

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Mensaje simple'),
    // El tema se aplicará automáticamente
  ),
);
```

## Mejores Prácticas

1. **No abusar**: No mostrar múltiples SnackBars seguidos
2. **Mensajes concisos**: Máximo 1-2 líneas
3. **Contexto claro**: Usa el tipo apropiado para cada situación
4. **Mounted check**: Siempre verificar `if (mounted)` en async
5. **Acciones opcionales**: Solo agregar acción si es realmente útil

## Compatibilidad

- ✅ Material 2 y Material 3
- ✅ iOS y Android
- ✅ Dark mode y Light mode
- ✅ Tablets y móviles
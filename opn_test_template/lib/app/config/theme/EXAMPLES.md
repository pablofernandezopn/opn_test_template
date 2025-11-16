# 📚 Ejemplos de Uso del Sistema de Temas

Este documento proporciona ejemplos prácticos de cómo usar el sistema de temas en diferentes situaciones comunes.

## 🎨 Colores

### Usando Colores del Tema (Recomendado)

```dart
// ✅ MEJOR PRÁCTICA: Usar colores del tema
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Texto Principal',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
  ),
)

// Para cards y contenedores
Card(
  color: Theme.of(context).colorScheme.secondaryContainer,
  child: Text(
    'Contenido',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSecondaryContainer,
    ),
  ),
)
```

### Usando Colores Directos (Solo cuando sea necesario)

```dart
// ⚠️ Solo usar cuando necesites un color específico que no cambia con el tema
import 'package:opn_app/app/config/theme/color.dart';

Container(
  color: AppColors.gold, // Para medallas
)

Icon(
  Icons.star,
  color: AppColors.goldLight,
)
```

## 📝 Tipografía

### Estilos de Texto Predefinidos

```dart
// Título principal de pantalla
Text(
  'Bienvenido',
  style: Theme.of(context).textTheme.titleLarge,
)

// Texto de cuerpo principal
Text(
  'Este es el contenido principal de la app',
  style: Theme.of(context).textTheme.bodyLarge,
)

// Texto secundario
Text(
  'Información adicional',
  style: Theme.of(context).textTheme.bodyMedium,
)

// Texto pequeño (notas, fechas, etc.)
Text(
  'Última actualización: hace 5 min',
  style: Theme.of(context).textTheme.bodySmall,
)
```

### Modificando Estilos de Texto

```dart
// Agregar color a un estilo existente
Text(
  'Texto importante',
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    color: Theme.of(context).colorScheme.error,
    fontWeight: FontWeight.bold,
  ),
)

// Combinar estilos
Text(
  'Título personalizado',
  style: Theme.of(context).textTheme.titleLarge?.copyWith(
    color: Theme.of(context).colorScheme.tertiary,
    letterSpacing: 1.2,
  ),
)
```

## 🔘 Botones

### Botón Principal (Elevated)

```dart
ElevatedButton(
  onPressed: () {
    // Acción
  },
  child: Text('Guardar'),
)

// Con icono
ElevatedButton.icon(
  onPressed: () {},
  icon: Icon(Icons.save),
  label: Text('Guardar'),
)

// Deshabilitado
ElevatedButton(
  onPressed: null, // null = deshabilitado
  child: Text('No disponible'),
)
```

### Botón Secundario (Outlined)

```dart
OutlinedButton(
  onPressed: () {
    // Acción secundaria
  },
  child: Text('Cancelar'),
)

// Con icono
OutlinedButton.icon(
  onPressed: () {},
  icon: Icon(Icons.close),
  label: Text('Cancelar'),
)
```

### Botón de Texto (Text Button)

```dart
TextButton(
  onPressed: () {},
  child: Text('Más información'),
)
```

## 📝 Campos de Texto

### TextField Básico

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Nombre',
    hintText: 'Ingresa tu nombre',
    helperText: 'Tu nombre completo',
  ),
)
```

### TextField con Validación

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    prefixIcon: Icon(Icons.email),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un email';
    }
    return null;
  },
)
```

### TextField con Iconos

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Buscar',
    prefixIcon: Icon(Icons.search),
    suffixIcon: IconButton(
      icon: Icon(Icons.clear),
      onPressed: () {
        // Limpiar campo
      },
    ),
  ),
)
```

## 🎯 Cards y Contenedores

### Card Básica

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Título',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 8),
        Text(
          'Contenido de la tarjeta',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  ),
)
```

### Card con Color del Tema

```dart
Card(
  color: Theme.of(context).colorScheme.secondaryContainer,
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text(
      'Card destacada',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    ),
  ),
)
```

### Container con Borde del Tema

```dart
Container(
  decoration: BoxDecoration(
    border: Border.all(
      color: Theme.of(context).colorScheme.outline,
      width: 1,
    ),
    borderRadius: BorderRadius.circular(8),
  ),
  padding: EdgeInsets.all(16),
  child: Text('Contenido'),
)
```

## 🎨 AppBar

### AppBar Básica

```dart
AppBar(
  title: Text('Mi App'),
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {},
    ),
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {},
    ),
  ],
)
```

### AppBar con Color Personalizado

```dart
AppBar(
  backgroundColor: Theme.of(context).colorScheme.primary,
  foregroundColor: Theme.of(context).colorScheme.onPrimary,
  title: Text('Mi App'),
)
```

## 📊 Componentes de Estado

### Checkbox

```dart
bool isChecked = false;

Checkbox(
  value: isChecked,
  onChanged: (bool? value) {
    setState(() {
      isChecked = value ?? false;
    });
  },
)

// Con etiqueta
CheckboxListTile(
  title: Text('Acepto los términos'),
  value: isChecked,
  onChanged: (bool? value) {
    setState(() {
      isChecked = value ?? false;
    });
  },
)
```

### Switch

```dart
bool isEnabled = false;

Switch(
  value: isEnabled,
  onChanged: (bool value) {
    setState(() {
      isEnabled = value;
    });
  },
)

// Con etiqueta
SwitchListTile(
  title: Text('Notificaciones'),
  value: isEnabled,
  onChanged: (bool value) {
    setState(() {
      isEnabled = value;
    });
  },
)
```

### Progress Indicators

```dart
// Circular
CircularProgressIndicator()

// Linear
LinearProgressIndicator()

// Con tamaño personalizado
SizedBox(
  width: 50,
  height: 50,
  child: CircularProgressIndicator(
    strokeWidth: 3,
  ),
)
```

## 🎯 Iconos

### Usando Iconos del Tema

```dart
import 'package:opn_app/app/config/theme/app_icons.dart';

// Icono de bloqueo
Icon(AppIcons.lockIcon)

// Icono de correcto
Icon(
  AppIcons.correctIcon,
  color: Colors.green,
  size: 32,
)

// Icono de error
Icon(
  AppIcons.wrongIcon,
  color: Theme.of(context).colorScheme.error,
)

// Medalla
Icon(
  AppIcons.medalIcon,
  color: AppColors.gold,
  size: 48,
)
```

## 🔀 Tabs

### TabBar Básica

```dart
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      title: Text('Mi App'),
      bottom: TabBar(
        tabs: [
          Tab(icon: Icon(Icons.home), text: 'Inicio'),
          Tab(icon: Icon(Icons.star), text: 'Favoritos'),
          Tab(icon: Icon(Icons.person), text: 'Perfil'),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        // Contenido de cada tab
        Center(child: Text('Inicio')),
        Center(child: Text('Favoritos')),
        Center(child: Text('Perfil')),
      ],
    ),
  ),
)
```

## 🎨 BottomSheet

### Mostrar BottomSheet

```dart
void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Opciones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Compartir'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Editar'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
```

## 🎨 Mensajes y Diálogos

### SnackBar

```dart
// SnackBar normal
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Operación exitosa'),
  ),
);

// SnackBar de error
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Error al guardar'),
    backgroundColor: Theme.of(context).colorScheme.error,
  ),
);

// SnackBar con acción
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Elemento eliminado'),
    action: SnackBarAction(
      label: 'Deshacer',
      onPressed: () {
        // Deshacer acción
      },
    ),
  ),
);
```

### Dialog

```dart
void _showDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar'),
        content: Text('¿Estás seguro de continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Acción
              Navigator.pop(context);
            },
            child: Text('Continuar'),
          ),
        ],
      );
    },
  );
}
```

## 🌓 Cambiar entre Tema Claro y Oscuro

### En MaterialApp

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light 
          ? ThemeMode.dark 
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: MyHomePage(onToggleTheme: _toggleTheme),
    );
  }
}
```

### Botón para Cambiar Tema

```dart
IconButton(
  icon: Icon(
    _themeMode == ThemeMode.light 
        ? Icons.dark_mode 
        : Icons.light_mode,
  ),
  onPressed: _toggleTheme,
)
```

---

**Nota:** Todos estos ejemplos usan automáticamente los estilos definidos en el sistema de temas. Si cambias un color o estilo en los archivos de tema, todos estos componentes se actualizarán automáticamente.


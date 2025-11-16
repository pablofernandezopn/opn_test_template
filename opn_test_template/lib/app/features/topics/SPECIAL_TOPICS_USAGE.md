# Uso de Topics Especiales y Topics Completados

Este documento explica cómo usar las nuevas funcionalidades para consultar topics especiales completados por el usuario y verificar qué topics ha realizado.

## 📚 Funcionalidades Disponibles

### 1. Topics Especiales del Usuario

Obtiene los topics "especiales" que el usuario ha completado, con estadísticas agregadas como:
- Total de intentos
- Mejor puntuación
- Primera puntuación
- Promedio de puntuaciones
- Total de preguntas, correctas e incorrectas
- Fechas de primer y último intento

**Características:**
- ✅ Paginación (scroll infinito)
- ✅ Ordenado por fecha de último intento (más recientes primero)
- ✅ Solo los últimos 20 por defecto
- ✅ Optimizado con función de base de datos

### 2. Topics Completados por el Usuario

Obtiene todos los IDs de topics que el usuario ha completado al menos una vez, combinando datos de:
- `user_tests` (tests normales)
- `topic_mock_rankings` (tests Mock)

**Características:**
- ✅ Vista completa de todos los topics completados
- ✅ Información de intentos y mejor score
- ✅ Útil para mostrar indicadores visuales (checkmarks, progreso)

## 🚀 Ejemplos de Uso

### Ejemplo 1: Obtener los primeros 20 topics especiales

```dart
import 'package:opn_test_guardia_civil/app/features/topics/repository/topic_repository.dart';

final repository = TopicRepository();
final userId = 123; // ID del usuario actual

// Obtener los primeros 20 topics especiales
final specialTopics = await repository.fetchUserSpecialTopics(
  userId: userId,
  limit: 20,
  offset: 0,
);

// Mostrar en UI
for (final topic in specialTopics) {
  print('Topic: ${topic.specialTopicTitle}');
  print('Intentos: ${topic.totalAttempts}');
  print('Mejor Score: ${topic.bestScore}');
  print('Tasa de éxito: ${topic.successRate.toStringAsFixed(1)}%');
  print('¿Mejorando?: ${topic.isImproving}');
  print('---');
}
```

### Ejemplo 2: Implementar Scroll Infinito

```dart
class SpecialTopicsPage extends StatefulWidget {
  @override
  State<SpecialTopicsPage> createState() => _SpecialTopicsPageState();
}

class _SpecialTopicsPageState extends State<SpecialTopicsPage> {
  final repository = TopicRepository();
  final scrollController = ScrollController();

  List<UserSpecialTopic> topics = [];
  bool isLoading = false;
  bool hasMore = true;
  int currentOffset = 0;
  final int pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadInitialTopics();
    scrollController.addListener(_onScroll);
  }

  Future<void> _loadInitialTopics() async {
    setState(() => isLoading = true);

    final newTopics = await repository.fetchUserSpecialTopics(
      userId: getCurrentUserId(),
      limit: pageSize,
      offset: 0,
    );

    setState(() {
      topics = newTopics;
      currentOffset = pageSize;
      hasMore = newTopics.length == pageSize;
      isLoading = false;
    });
  }

  Future<void> _loadMoreTopics() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    final newTopics = await repository.fetchUserSpecialTopics(
      userId: getCurrentUserId(),
      limit: pageSize,
      offset: currentOffset,
    );

    setState(() {
      topics.addAll(newTopics);
      currentOffset += pageSize;
      hasMore = newTopics.length == pageSize;
      isLoading = false;
    });
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreTopics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: topics.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == topics.length) {
          return Center(child: CircularProgressIndicator());
        }

        final topic = topics[index];
        return SpecialTopicCard(topic: topic);
      },
    );
  }
}
```

### Ejemplo 3: Verificar Topics Completados

```dart
// Obtener todos los topics completados
final completedTopics = await repository.fetchUserCompletedTopics(
  userId: userId,
);

print('Total de topics completados: ${completedTopics.length}');

// Verificar si un topic específico está completado
final topicId = 456;
final isCompleted = await repository.hasUserCompletedTopic(
  userId: userId,
  topicId: topicId,
);

if (isCompleted != null) {
  print('✅ Topic completado!');
  print('Intentos: ${isCompleted.attempts}');
  print('Mejor score: ${isCompleted.bestScore}');
} else {
  print('❌ Topic no completado');
}
```

### Ejemplo 4: Mostrar Indicadores de Progreso

```dart
// Obtener set de IDs completados (optimizado)
final completedIds = await repository.fetchUserCompletedTopicIds(
  userId: userId,
);

// Mostrar lista de topics con indicadores
Widget buildTopicList(List<Topic> allTopics) {
  return ListView.builder(
    itemCount: allTopics.length,
    itemBuilder: (context, index) {
      final topic = allTopics[index];
      final isCompleted = completedIds.contains(topic.id);

      return ListTile(
        title: Text(topic.topicName),
        trailing: isCompleted
          ? Icon(Icons.check_circle, color: Colors.green)
          : Icon(Icons.radio_button_unchecked, color: Colors.grey),
      );
    },
  );
}
```

### Ejemplo 5: Dashboard de Estadísticas

```dart
// Obtener los 5 topics más recientes
final recentTopics = await repository.fetchUserSpecialTopics(
  userId: userId,
  limit: 5,
  offset: 0,
);

// Calcular estadísticas generales
int totalAttempts = 0;
double averageScore = 0;
int improvingCount = 0;

for (final topic in recentTopics) {
  totalAttempts += topic.totalAttempts;
  averageScore += topic.averageScore ?? 0;
  if (topic.isImproving) improvingCount++;
}

averageScore = recentTopics.isNotEmpty
  ? averageScore / recentTopics.length
  : 0;

print('📊 Resumen:');
print('Total intentos: $totalAttempts');
print('Score promedio: ${averageScore.toStringAsFixed(1)}');
print('Topics mejorando: $improvingCount/${recentTopics.length}');
```

## 🗄️ Base de Datos

### Función: `get_user_special_topics`

**Parámetros:**
- `p_user_id` (BIGINT): ID del usuario
- `p_limit` (INTEGER): Número de resultados (default: 20)
- `p_offset` (INTEGER): Offset para paginación (default: 0)

**Retorna:** Tabla con estadísticas agregadas de topics especiales

### Función: `get_user_completed_topic_ids`

**Parámetros:**
- `p_user_id` (BIGINT): ID del usuario

**Retorna:** Tabla con IDs de topics completados y estadísticas básicas

### Índices Creados

- `idx_user_tests_user_special_topic`: Optimiza búsquedas de special_topic por usuario
- `idx_user_tests_topic_ids_gin`: Índice GIN para búsquedas en arrays de topic_ids

## ⚡ Optimizaciones

1. **Funciones SQL**: Las consultas complejas se ejecutan en la base de datos, reduciendo transferencia de datos
2. **Índices**: Índices específicos para consultas frecuentes
3. **Paginación**: Carga incremental de datos (20 items a la vez)
4. **Caché**: El `Set<int>` de topics completados se puede cachear en memoria para verificaciones rápidas

## 🔄 Aplicar Migración

Para aplicar los cambios en Supabase:

```bash
cd supabase
supabase db reset  # Para desarrollo local
# O
supabase db push   # Para producción (¡cuidado!)
```

## 📝 Notas

- Los topics especiales son aquellos con `special_topic != null` en `user_tests`
- Solo se consideran tests finalizados y visibles
- Las estadísticas se agregan por `special_topic_id`
- La combinación de `user_tests` y `topic_mock_rankings` da una vista completa del progreso

## 🐛 Troubleshooting

### Error: "function get_user_special_topics does not exist"
**Solución:** Ejecutar la migración `20251103120000_create_user_special_topics_function.sql`

### Rendimiento lento
**Solución:** Verificar que los índices estén creados correctamente:
```sql
SELECT * FROM pg_indexes WHERE tablename = 'user_tests';
```

### Topics duplicados
**Solución:** Verificar que el `GROUP BY` en la función incluya `special_topic_title`
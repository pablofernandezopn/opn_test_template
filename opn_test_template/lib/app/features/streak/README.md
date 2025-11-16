# 🔥 Sistema de Rachas

Sistema completo de rachas para motivar el estudio diario de los usuarios.

## 📋 Descripción

El sistema de rachas registra automáticamente la actividad diaria del usuario (tests completados) y mantiene un contador de días consecutivos de estudio. Incluye:

- **Racha actual**: Días consecutivos con al menos 1 test completado
- **Récord personal**: Mejor racha histórica del usuario
- **Widget semanal**: Visualización de los últimos 7 días con indicadores de actividad
- **Sistema de badges**: Niveles motivacionales (Principiante, Iniciado, Guerrero, Campeón, Leyenda)
- **Actualización automática**: Trigger que actualiza la racha al finalizar cada test

## 🗄️ Base de Datos

### Tablas

#### `users` (campos añadidos)
```sql
current_streak         INT      -- Racha actual en días
longest_streak         INT      -- Récord histórico
last_activity_date     DATE     -- Última actividad
streak_updated_at      TIMESTAMP -- Última actualización
```

#### `user_daily_activity` (nueva)
```sql
id                     BIGINT PRIMARY KEY
user_id                BIGINT   -- FK a users
activity_date          DATE     -- Fecha de la actividad
tests_completed        INT      -- Tests completados ese día
questions_answered     INT      -- Preguntas respondidas
correct_answers        INT      -- Respuestas correctas
total_time_seconds     INT      -- Tiempo total dedicado
```

### Funciones

#### `calculate_user_streak(p_user_id)`
Calcula la racha actual y récord histórico del usuario basándose en `user_tests`.

**Retorna:**
- `current_streak`: Racha actual (0 si no hay actividad en los últimos 2 días)
- `longest_streak`: Mejor racha histórica
- `last_activity_date`: Última fecha de actividad

#### `get_week_activity(p_user_id)`
Obtiene la actividad de los últimos 7 días para el widget.

**Retorna:** Lista con:
- `day_of_week`: 0-6 (0=Domingo)
- `day_name`: L, M, M, J, V, S, D
- `activity_date`: Fecha
- `has_activity`: Boolean si completó al menos 1 test
- `is_today`: Boolean si es hoy
- `tests_completed`: Número de tests ese día
- `questions_answered`: Número de preguntas

#### `get_user_streak_data(p_user_id)`
Retorna todos los datos de racha en formato JSON, incluyendo actividad semanal.

### Trigger

**`trigger_update_daily_activity_and_streak`**
- Se ejecuta automáticamente al finalizar un test (`user_tests.finalized = true`)
- Actualiza `user_daily_activity` (insert o update)
- Recalcula y actualiza la racha del usuario

### Vista

**`user_streak_stats`**
Vista con estadísticas enriquecidas:
- `completed_today`: Boolean si completó tests hoy
- `streak_status`: 'active', 'inactive_recent', 'inactive'
- `streak_badge`: 'novice', 'beginner', 'warrior', 'champion', 'legend'

## 📱 Flutter - Modelos

### `StreakData`
Modelo principal con toda la información de racha del usuario.

```dart
class StreakData {
  final int userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final bool completedToday;
  final List<WeekDayActivity> weekActivity;

  // Helpers útiles
  double get weekCompletionRate;    // % de días completados esta semana
  int get weekCompletedDays;        // Días completados esta semana
  bool get atRisk;                  // En riesgo de perder la racha
  StreakBadge get badge;            // Badge actual
  String get motivationalMessage;   // Mensaje motivacional
}
```

### `WeekDayActivity`
Información de un día de la semana.

```dart
class WeekDayActivity {
  final int dayOfWeek;          // 0-6
  final String dayName;         // L, M, M, J, V, S, D
  final DateTime activityDate;
  final bool hasActivity;
  final bool isToday;
  final int testsCompleted;
  final int questionsAnswered;

  String get fullDayName;       // Nombre completo: "Lunes", etc.
}
```

### `StreakBadge` (Enum)
Sistema de badges con 5 niveles:
- **Principiante** 🌱: 0+ días
- **Iniciado** ⭐: 3+ días
- **Guerrero** ⚔️: 7+ días
- **Campeón** 🏆: 14+ días
- **Leyenda** 👑: 30+ días

## 🔌 Repository

### `StreakRepository`

```dart
// Obtener datos completos de racha
Future<StreakData> getUserStreakData(int userId)

// Obtener solo actividad semanal
Future<List<WeekDayActivity>> getWeekActivity(int userId)

// Recalcular racha manualmente
Future<Map<String, dynamic>> recalculateUserStreak(int userId)

// Stream en tiempo real
Stream<StreakData> watchUserStreakData(int userId)

// Top usuarios con mejores rachas
Future<List<Map<String, dynamic>>> getTopStreaks({int limit = 10})
```

## 🎨 Widgets

### `StreakWidget`
Widget principal que muestra:
- Fuego 🔥 con contador de días
- Badge del usuario
- Días de la semana con indicadores visuales
- Alerta si está en riesgo de perder la racha

```dart
StreakWidget(
  streakData: streakData,
  onTap: () {
    // Acción al tocar (ej: navegar a detalles)
  },
)
```

### `StreakLoadingWidget`
Skeleton loader mientras se cargan los datos.

### `StreakErrorWidget`
Widget de error con botón de reintentar.

## 🎯 Estado - Cubit

### `StreakCubit`

```dart
// Crear el cubit
final cubit = StreakCubit(
  repository: StreakRepository(),
  userId: currentUserId,
);

// Cargar datos
await cubit.loadStreakData();

// Recalcular racha
await cubit.recalculateStreak();

// Refrescar
await cubit.refresh();
```

### `StreakState`
Estados posibles:
- `initial()`: Estado inicial
- `loading()`: Cargando datos
- `loaded(StreakData)`: Datos cargados
- `error(String)`: Error con mensaje

## 🚀 Uso en la Home

### Opción 1: Con BlocProvider local

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/streak/cubit/streak_cubit.dart';
import 'package:app/features/streak/view/components/streak_widget.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id;

    return Scaffold(
      body: Column(
        children: [
          // ... otros widgets

          // Widget de racha
          BlocProvider(
            create: (context) => StreakCubit(
              repository: StreakRepository(),
              userId: userId!,
            )..loadStreakData(),
            child: BlocBuilder<StreakCubit, StreakState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const StreakLoadingWidget(),
                  loading: () => const StreakLoadingWidget(),
                  loaded: (data) => StreakWidget(
                    streakData: data,
                    onTap: () => _showStreakDetails(context, data),
                  ),
                  error: (msg) => StreakErrorWidget(
                    errorMessage: msg,
                    onRetry: () => context.read<StreakCubit>().loadStreakData(),
                  ),
                );
              },
            ),
          ),

          // ... otros widgets
        ],
      ),
    );
  }
}
```

### Opción 2: Widget de ejemplo simplificado

```dart
import 'package:app/features/streak/view/streak_example.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id;

    return Scaffold(
      body: Column(
        children: [
          // ... otros widgets

          StreakExample(userId: userId!),

          // ... otros widgets
        ],
      ),
    );
  }
}
```

## 🔄 Flujo de Actualización

```
Usuario finaliza test (user_tests.finalized = true)
    ↓
Trigger: update_daily_activity_and_streak()
    ↓
1. Inserta/actualiza user_daily_activity
2. Calcula racha con calculate_user_streak()
3. Actualiza users (current_streak, longest_streak, etc.)
    ↓
Widget escucha cambios via stream/cubit
    ↓
UI se actualiza automáticamente
```

## 📊 Ejemplos de Uso Avanzado

### Mostrar top 10 rachas en ranking

```dart
final topStreaks = await StreakRepository().getTopStreaks(limit: 10);

ListView.builder(
  itemCount: topStreaks.length,
  itemBuilder: (context, index) {
    final user = topStreaks[index];
    return ListTile(
      leading: Text('#${index + 1}'),
      title: Text(user['username']),
      trailing: Text('🔥 ${user['current_streak']} días'),
    );
  },
);
```

### Notificaciones de racha

```dart
final streakData = await StreakRepository().getUserStreakData(userId);

if (streakData.atRisk) {
  // Enviar notificación push
  NotificationService.send(
    title: '¡Tu racha está en riesgo!',
    body: 'Completa un test hoy para mantener tu racha de ${streakData.currentStreak} días',
  );
}
```

### Historial de actividad

```dart
final history = await StreakRepository().getDailyActivity(
  userId: userId,
  startDate: DateTime.now().subtract(Duration(days: 30)),
  endDate: DateTime.now(),
);

// Graficar actividad de los últimos 30 días
```

## 🎨 Personalización

### Cambiar colores de badges

Edita `streak_data_model.dart:146-163`:

```dart
String get colorHex {
  switch (this) {
    case StreakBadge.legend:
      return '#FFD700'; // Cambiar a dorado
    // ...
  }
}
```

### Cambiar número de días para badges

Edita `streak_data_model.dart:132`:

```dart
enum StreakBadge {
  novice('Principiante', 0),
  beginner('Iniciado', 5),    // De 3 a 5 días
  warrior('Guerrero', 10),    // De 7 a 10 días
  // ...
}
```

## 🐛 Troubleshooting

### La racha no se actualiza automáticamente
1. Verifica que el test tenga `finalized = true`
2. Revisa logs del trigger en Supabase
3. Recalcula manualmente: `recalculateUserStreak(userId)`

### Datos inconsistentes
Ejecuta migración manual para recalcular todas las rachas:

```sql
-- En Supabase SQL Editor
DO $$
DECLARE
    v_user record;
    v_streak_info record;
BEGIN
    FOR v_user IN SELECT id FROM public.users WHERE deleted = false
    LOOP
        SELECT * INTO v_streak_info
        FROM "public"."calculate_user_streak"(v_user.id);

        UPDATE public.users
        SET
            current_streak = v_streak_info.current_streak,
            longest_streak = GREATEST(longest_streak, v_streak_info.longest_streak),
            last_activity_date = v_streak_info.last_activity_date,
            streak_updated_at = now()
        WHERE id = v_user.id;
    END LOOP;
END $$;
```

## 📝 Notas

- La racha permite 1 día de gracia (si última actividad fue ayer, la racha sigue activa)
- Los datos históricos se migran automáticamente al aplicar la migración
- El widget es responsive y se adapta a diferentes tamaños de pantalla
- Todos los cálculos se hacen en PostgreSQL para máxima eficiencia

## 🔜 Mejoras Futuras

- [ ] Gamificación: premios por rachas largas
- [ ] Compartir racha en redes sociales
- [ ] Desafíos entre usuarios
- [ ] Estadísticas mensuales/anuales
- [ ] Recordatorios personalizados
- [ ] Modo oscuro para el widget

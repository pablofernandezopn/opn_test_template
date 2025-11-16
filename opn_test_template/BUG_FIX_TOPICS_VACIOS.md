# 🐛 Bug Fix: Topics vacíos al cambiar de especialidad

## Problema detectado

Al cambiar de especialidad, los topics aparecían vacíos en lugar de mostrar los topics de la nueva especialidad.

## Causa raíz

Había una **condición de carrera** (race condition) entre dos procesos que intentaban cargar los topics:

### Flujo problemático:

```
1. Usuario cambia especialidad
   ↓
2. change_specialty_page.dart llama a authCubit.refreshUser()
   ↓
3. AuthCubit emite un nuevo estado con specialty_id actualizado
   ↓
4. ⚠️ El listener _listenToAuthChanges() en TopicCubit detecta el cambio
   ↓
5. ⚠️ El listener llama a fetchTopics() ANTES del refresh manual
   ↓
6. Se cargan topics con el nuevo specialty_id PERO con el estado anterior
   ↓
7. change_specialty_page.dart llama a topicCubit.refresh()
   ↓
8. refresh() limpia el estado con _clearState()
   ↓
9. ⚠️ Los topics se pierden porque el estado se limpia DESPUÉS de cargar
   ↓
10. refresh() intenta cargar de nuevo pero el listener ya se ejecutó
    ↓
11. RESULTADO: Lista de topics vacía
```

### Diagrama del problema:

```
Timeline:

t0: Usuario cambia especialidad
    │
t1: authCubit.refreshUser() actualiza specialty_id
    │
t2: ├─> Listener detecta cambio → fetchTopics() [Carga topics con nuevo specialty_id]
    │   (Lista tiene 4 topics)
    │
t3: topicCubit.refresh() se ejecuta
    │
t4: └─> _clearState() limpia TODO → emit(TopicState.initial())
        (Lista queda vacía)
    
t5: fetchTopics() y fetchTopicGroups() se ejecutan
    (Pero el listener ya se ejecutó y ahora no hay nada que cargar)

RESULTADO: topics = [] (vacío) ❌
```

## Solución implementada

### 1. Agregar bandera `_isManualRefreshing`

```dart
class TopicCubit extends Cubit<TopicState> {
  // ...
  bool _isManualRefreshing = false;
  // ...
}
```

### 2. Modificar el listener para respetar la bandera

```dart
void _listenToAuthChanges() {
  _authSubscription = _authCubit.stream.listen((authState) {
    print('🔄 [TOPIC_CUBIT] Auth state changed: ${authState.status}');
    
    // 🛡️ No recargar automáticamente si estamos haciendo un refresh manual
    if (_isManualRefreshing) {
      print('⏸️ [TOPIC_CUBIT] Manual refresh en progreso, ignorando listener de auth');
      return;
    }
    
    if (authState.status == AuthStatus.authenticated) {
      print('✅ [TOPIC_CUBIT] Usuario autenticado, cargando topics...');
      fetchTopics();
    }
  });
}
```

### 3. Activar/desactivar bandera en refresh()

```dart
Future<void> refresh() async {
  logger.info('🔄 [TOPIC_CUBIT] Refreshing all data...');

  // 🛡️ Activar bandera para evitar interferencia del listener
  _isManualRefreshing = true;

  try {
    // 1. Limpiar todo el estado primero
    _clearState();

    // 2. Esperar un momento para que el listener se dispare y sea ignorado
    await Future.delayed(const Duration(milliseconds: 100));

    // 3. Recargar topics y topic_groups en paralelo
    await Future.wait([
      fetchTopics(),
      fetchTopicGroups(),
    ]);

    logger.info('✅ [TOPIC_CUBIT] Refresh completed successfully');
  } catch (e) {
    logger.error('❌ [TOPIC_CUBIT] Error during refresh: $e');
    getIt<LoadingCubit>().markReady();
    rethrow;
  } finally {
    // 🛡️ Desactivar bandera al terminar
    _isManualRefreshing = false;
  }
}
```

## Flujo corregido

### Nuevo flujo sin condición de carrera:

```
Timeline:

t0: Usuario cambia especialidad
    │
t1: authCubit.refreshUser() actualiza specialty_id
    │
t2: topicCubit.refresh() se ejecuta
    ├─> _isManualRefreshing = true 🛡️
    │
t3: ├─> Listener detecta cambio de auth
    │   └─> ⏸️ Ve que _isManualRefreshing = true
    │       └─> IGNORA el evento (no llama a fetchTopics)
    │
t4: └─> _clearState() limpia TODO
        (Lista queda vacía temporalmente)
    
t5: await Future.delayed(100ms) para asegurar que listener terminó
    
t6: fetchTopics() y fetchTopicGroups() se ejecutan
    (Cargan topics de la nueva especialidad)
    
t7: _isManualRefreshing = false 🛡️
    (Permite que el listener vuelva a funcionar normalmente)

RESULTADO: topics = [Topic(...), Topic(...), ...] ✅
```

### Diagrama visual:

```
┌─────────────────────────────────────────────────────────────┐
│  authCubit.refreshUser()                                     │
│  └─> Emite nuevo estado con specialty_id actualizado        │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌──────────────────┐    ┌────────────────────────┐
│  Listener Auth   │    │  topicCubit.refresh()  │
│  (automático)    │    │  (manual)              │
└────────┬─────────┘    └────────┬───────────────┘
         │                       │
         │                       ▼
         │              _isManualRefreshing = true 🛡️
         │                       │
         ▼                       │
    ❓ Verifica bandera          │
         │                       │
         │                       ▼
    _isManualRefreshing == true? _clearState()
         │                       │
         └─YES─> ⏸️ IGNORA       │
                                 ▼
                         await delay(100ms)
                                 │
                                 ▼
                         fetchTopics()
                         fetchTopicGroups()
                                 │
                                 ▼
                         _isManualRefreshing = false 🛡️
                                 │
                                 ▼
                         ✅ ÉXITO
```

## Archivos modificados

- ✅ `/lib/app/features/topics/cubit/topic_cubit.dart`
  - Agregada variable `_isManualRefreshing`
  - Modificado `_listenToAuthChanges()` para respetar la bandera
  - Modificado `refresh()` para activar/desactivar la bandera

## Testing

### Caso de prueba 1: Cambiar de Sin especialidad → Escala Básica

**Logs esperados:**
```
[info] Especialidad actualizada a: Escala Básica
[info] Refreshing user data for user: 35
[debug] Updated specialty_id: 2
🔄 [TOPIC_CUBIT] Auth state changed: AuthStatus.authenticated
⏸️ [TOPIC_CUBIT] Manual refresh en progreso, ignorando listener de auth
[info] 🔄 [TOPIC_CUBIT] Refreshing all data...
[info] 🧹 [TOPIC_CUBIT] Clearing all state...
[debug] ✅ [TOPIC_CUBIT] Fetched 4 topics for specialty_id=2  ← ÉXITO
[debug] First topic: Simulacro 3 - Escala Básica
[info] ✅ [TOPIC_CUBIT] Refresh completed successfully
```

### Caso de prueba 2: Cambiar de Escala Básica → Cabos y Guardias

**Resultado esperado:**
- ✅ Lista de topics se vacía (estado inicial)
- ✅ Se cargan 4-5 topics de Cabos y Guardias
- ✅ No se muestra contenido de Escala Básica
- ✅ El listener de auth NO interfiere

### Caso de prueba 3: Cambiar varias veces seguidas

**Resultado esperado:**
- ✅ Cada cambio respeta la bandera
- ✅ No hay acumulación de datos
- ✅ Siempre muestra solo los topics de la especialidad actual

## Ventajas de esta solución

1. **✅ Simple**: Solo una variable booleana
2. **✅ No invasiva**: No modifica la lógica existente del listener
3. **✅ Segura**: El `finally` asegura que la bandera se resetea incluso si hay error
4. **✅ Compatible**: No afecta el flujo normal de autenticación inicial
5. **✅ Predecible**: El listener solo se silencia durante el refresh manual

## Alternativas consideradas (y por qué no se usaron)

### ❌ Opción 1: Cancelar el listener temporalmente
```dart
_authSubscription?.cancel();  // Cancelar
// hacer refresh
_listenToAuthChanges();      // Recrear
```
**Problema**: Podríamos perder eventos de auth importantes

### ❌ Opción 2: Comparar specialty_id antes/después
```dart
if (previousSpecialtyId != currentSpecialtyId) {
  // solo entonces recargar
}
```
**Problema**: Requiere mantener estado adicional y es más complejo

### ❌ Opción 3: Eliminar el listener automático
**Problema**: Rompe la funcionalidad de carga automática al autenticarse

## Conclusión

El problema estaba causado por una condición de carrera entre:
- El listener automático de cambios de auth
- El refresh manual al cambiar especialidad

La solución usa una bandera simple para coordinar ambos procesos sin eliminar funcionalidad existente.


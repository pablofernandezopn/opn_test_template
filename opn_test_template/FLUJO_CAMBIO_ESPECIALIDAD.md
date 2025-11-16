# Flujo de Cambio de Especialidad - Diagrama

## 🔄 Flujo completo al cambiar de especialidad

```
┌─────────────────────────────────────────────────────────────────┐
│  USUARIO CAMBIA ESPECIALIDAD                                     │
│  (change_specialty_page.dart)                                    │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│  1. Actualizar especialidad en Supabase                          │
│     - SpecialtyCubit.updateSpecialty()                           │
│     - UPDATE users SET specialty_id = X                          │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│  2. Refrescar usuario en AuthCubit                               │
│     - AuthCubit.refreshUser()                                    │
│     - Obtiene usuario actualizado con nuevo specialty_id         │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│  3. Resetear LoadingCubit                                        │
│     - LoadingCubit.reset()                                       │
│     - Estado: true → false                                       │
│     - ⚡ Esto dispara el listener en app_bloc_listeners.dart     │
│       que resetea _hasNavigatedToHome = false                    │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│  4. Navegar a /loading                                           │
│     - context.go(AppRoutes.loading)                              │
│     - Usuario ve pantalla de carga                               │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│  5. Ejecutar TopicCubit.refresh()                                │
│     ┌─────────────────────────────────────────────────────┐     │
│     │ 5.1 Limpiar estado (_clearState)                    │     │
│     │     - emit(TopicState.initial())                     │     │
│     │     - 🧹 Elimina todos los topics antiguos           │     │
│     │     - 🧹 Elimina completed topics antiguos           │     │
│     │     - 🧹 Elimina topic groups antiguos               │     │
│     └─────────────────┬───────────────────────────────────┘     │
│                       │                                           │
│                       ▼                                           │
│     ┌─────────────────────────────────────────────────────┐     │
│     │ 5.2 Cargar datos nuevos en paralelo                 │     │
│     │     - fetchTopics() con nuevo specialty_id          │     │
│     │     - fetchTopicGroups()                             │     │
│     │     - ⏱️ Timeout: 15 segundos                        │     │
│     └─────────────────┬───────────────────────────────────┘     │
│                       │                                           │
│                       ▼                                           │
│     ┌─────────────────────────────────────────────────────┐     │
│     │ 5.3 Marcar como ready                               │     │
│     │     - LoadingCubit.markReady()                       │     │
│     │     - Estado: false → true                           │     │
│     │     - ⚡ Dispara listener en app_bloc_listeners.dart │     │
│     └─────────────────────────────────────────────────────┘     │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│  6. Listener detecta que dataReady=true y videoReady=true        │
│     (app_bloc_listeners.dart)                                    │
│     - Verifica: !_hasNavigatedToHome = true ✅                   │
│     - Navega automáticamente: context.go(AppRoutes.home)         │
│     - Marca: _hasNavigatedToHome = true                          │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│  7. Usuario ve HOME con topics de la nueva especialidad          │
│     ✅ Datos limpios y actualizados                              │
│     ✅ Sin topics de la especialidad anterior                    │
└─────────────────────────────────────────────────────────────────┘
```

## ⚠️ Puntos críticos del flujo

### 1. **Limpieza del estado (Paso 5.1)**
```dart
void _clearState() {
  logger.info('🧹 [TOPIC_CUBIT] Clearing all state...');
  emit(TopicState.initial());
}
```
- **¿Por qué?** Si no limpiamos, los topics de la especialidad anterior quedan en memoria
- **¿Qué limpia?** Todos los datos: topics, topicGroups, completedTopics, status, etc.
- **¿Cuándo?** ANTES de cargar los nuevos datos

### 2. **Reset de LoadingCubit (Paso 3)**
```dart
loadingCubit.reset(); // true → false
```
- **¿Por qué?** Resetea la variable `_hasNavigatedToHome` en el listener
- **¿Qué pasa si no?** La navegación automática a home no funciona (se queda en loading)

### 3. **Listener de LoadingCubit**
```dart
// En app_bloc_listeners.dart
if (!dataReady) {
  debugPrint('🔄 Reseteando navegación');
  _hasNavigatedToHome = false;
  _safetyTimeoutStarted = false;
  return;
}
```
- **¿Por qué?** Permite que la navegación a home ocurra de nuevo después de cambiar especialidad
- **¿Qué pasa si no?** `_hasNavigatedToHome` queda en `true` y bloquea la navegación

### 4. **Navegación automática vs manual**
- ❌ **ANTES**: Se navegaba manualmente a home con `context.go()`
- ✅ **AHORA**: Los listeners manejan la navegación automáticamente
- **Beneficio**: Evita navegaciones duplicadas y mantiene consistencia

## 🔍 Verificación del flujo

### Logs esperados al cambiar de especialidad:

```
[info] Especialidad actualizada a: Escala Básica
[info] Refreshing user data for user: 35
[debug] Updated specialty_id: 2
📊 LoadingCubit cambió a false                    # ← Reset
🔄 Reseteando navegación                          # ← Listener detecta reset
[GoRouter] going to /loading
[info] 🔄 [TOPIC_CUBIT] Refreshing all data...
[info] 🧹 [TOPIC_CUBIT] Clearing all state...     # ← Limpieza
[debug] ✅ Fetched 4 topics for specialty_id=2    # ← Nuevos datos
[debug] ✅ Fetched 3 topic groups
[info] ✅ [TOPIC_CUBIT] Refresh completed
📊 LoadingCubit cambió a true                     # ← Marca ready
✅ Navegando a home desde /loading                # ← Navegación automática
```

## 🧪 Testing recomendado

1. **Cambiar de "Sin especialidad" a "Escala Básica"**
   - ✅ Debe limpiar topics generales
   - ✅ Debe cargar topics de Escala Básica

2. **Cambiar de "Escala Básica" a "Escala de Cabos y Guardias"**
   - ✅ Debe limpiar topics de Escala Básica
   - ✅ Debe cargar topics de Cabos y Guardias

3. **Cambiar varias veces seguidas**
   - ✅ No debe acumular datos en memoria
   - ✅ Siempre debe mostrar solo los topics de la especialidad actual

4. **Verificar con error de red**
   - ✅ Debe marcar ready incluso si falla la carga
   - ✅ No debe quedarse colgado en loading
   - ✅ Debe aplicar timeout de 15 segundos


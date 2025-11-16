import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/user_stats_model.dart';

part 'stats_state.freezed.dart';

enum StatsStatus { initial, loading, success, error }

@freezed
class StatsState with _$StatsState {
  const factory StatsState({
    /// Estado de la carga
    @Default(StatsStatus.initial) StatsStatus status,

    /// Estadísticas globales del usuario
    @Default(UserStats()) UserStats globalStats,

    /// Estadísticas por cada topic Mock
    @Default([]) List<TopicMockStats> topicStats,

    /// Datos para gráficos de evolución
    @Default([]) List<StatsDataPoint> evolutionData,

    /// Datos de evolución agrupados por topic_type
    @Default([]) List<TopicTypeEvolutionData> evolutionByTopicType,

    /// Datos de progreso/mejora
    @Default([]) List<Map<String, dynamic>> progressData,

    /// Comparación con promedio (para un topic específico)
    Map<String, dynamic>? comparisonData,

    /// ID del topic seleccionado para comparación
    int? selectedTopicId,

    /// Mensaje de error (si hay)
    String? errorMessage,

    /// Timestamp de la última actualización (para caché)
    DateTime? lastUpdated,
  }) = _StatsState;

  const StatsState._();

  /// Helper para crear estado inicial
  factory StatsState.initial() => const StatsState();

  /// Verifica si está en estado de carga
  bool get isLoading => status == StatsStatus.loading;

  /// Verifica si tiene datos
  bool get hasData => globalStats.hasData;

  /// Verifica si está en estado de error
  bool get hasError => status == StatsStatus.error;

  /// Verifica si los datos están actualizados (menos de 5 minutos)
  bool get isDataFresh {
    if (lastUpdated == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);
    return difference.inMinutes < 5;
  }
}
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stats_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$StatsState {
  /// Estado de la carga
  StatsStatus get status => throw _privateConstructorUsedError;

  /// Estadísticas globales del usuario
  UserStats get globalStats => throw _privateConstructorUsedError;

  /// Estadísticas por cada topic Mock
  List<TopicMockStats> get topicStats => throw _privateConstructorUsedError;

  /// Datos para gráficos de evolución
  List<StatsDataPoint> get evolutionData => throw _privateConstructorUsedError;

  /// Datos de evolución agrupados por topic_type
  List<TopicTypeEvolutionData> get evolutionByTopicType =>
      throw _privateConstructorUsedError;

  /// Datos de progreso/mejora
  List<Map<String, dynamic>> get progressData =>
      throw _privateConstructorUsedError;

  /// Comparación con promedio (para un topic específico)
  Map<String, dynamic>? get comparisonData =>
      throw _privateConstructorUsedError;

  /// ID del topic seleccionado para comparación
  int? get selectedTopicId => throw _privateConstructorUsedError;

  /// Mensaje de error (si hay)
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Timestamp de la última actualización (para caché)
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Create a copy of StatsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatsStateCopyWith<StatsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatsStateCopyWith<$Res> {
  factory $StatsStateCopyWith(
          StatsState value, $Res Function(StatsState) then) =
      _$StatsStateCopyWithImpl<$Res, StatsState>;
  @useResult
  $Res call(
      {StatsStatus status,
      UserStats globalStats,
      List<TopicMockStats> topicStats,
      List<StatsDataPoint> evolutionData,
      List<TopicTypeEvolutionData> evolutionByTopicType,
      List<Map<String, dynamic>> progressData,
      Map<String, dynamic>? comparisonData,
      int? selectedTopicId,
      String? errorMessage,
      DateTime? lastUpdated});
}

/// @nodoc
class _$StatsStateCopyWithImpl<$Res, $Val extends StatsState>
    implements $StatsStateCopyWith<$Res> {
  _$StatsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? globalStats = null,
    Object? topicStats = null,
    Object? evolutionData = null,
    Object? evolutionByTopicType = null,
    Object? progressData = null,
    Object? comparisonData = freezed,
    Object? selectedTopicId = freezed,
    Object? errorMessage = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StatsStatus,
      globalStats: null == globalStats
          ? _value.globalStats
          : globalStats // ignore: cast_nullable_to_non_nullable
              as UserStats,
      topicStats: null == topicStats
          ? _value.topicStats
          : topicStats // ignore: cast_nullable_to_non_nullable
              as List<TopicMockStats>,
      evolutionData: null == evolutionData
          ? _value.evolutionData
          : evolutionData // ignore: cast_nullable_to_non_nullable
              as List<StatsDataPoint>,
      evolutionByTopicType: null == evolutionByTopicType
          ? _value.evolutionByTopicType
          : evolutionByTopicType // ignore: cast_nullable_to_non_nullable
              as List<TopicTypeEvolutionData>,
      progressData: null == progressData
          ? _value.progressData
          : progressData // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      comparisonData: freezed == comparisonData
          ? _value.comparisonData
          : comparisonData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      selectedTopicId: freezed == selectedTopicId
          ? _value.selectedTopicId
          : selectedTopicId // ignore: cast_nullable_to_non_nullable
              as int?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StatsStateImplCopyWith<$Res>
    implements $StatsStateCopyWith<$Res> {
  factory _$$StatsStateImplCopyWith(
          _$StatsStateImpl value, $Res Function(_$StatsStateImpl) then) =
      __$$StatsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {StatsStatus status,
      UserStats globalStats,
      List<TopicMockStats> topicStats,
      List<StatsDataPoint> evolutionData,
      List<TopicTypeEvolutionData> evolutionByTopicType,
      List<Map<String, dynamic>> progressData,
      Map<String, dynamic>? comparisonData,
      int? selectedTopicId,
      String? errorMessage,
      DateTime? lastUpdated});
}

/// @nodoc
class __$$StatsStateImplCopyWithImpl<$Res>
    extends _$StatsStateCopyWithImpl<$Res, _$StatsStateImpl>
    implements _$$StatsStateImplCopyWith<$Res> {
  __$$StatsStateImplCopyWithImpl(
      _$StatsStateImpl _value, $Res Function(_$StatsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of StatsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? globalStats = null,
    Object? topicStats = null,
    Object? evolutionData = null,
    Object? evolutionByTopicType = null,
    Object? progressData = null,
    Object? comparisonData = freezed,
    Object? selectedTopicId = freezed,
    Object? errorMessage = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$StatsStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StatsStatus,
      globalStats: null == globalStats
          ? _value.globalStats
          : globalStats // ignore: cast_nullable_to_non_nullable
              as UserStats,
      topicStats: null == topicStats
          ? _value._topicStats
          : topicStats // ignore: cast_nullable_to_non_nullable
              as List<TopicMockStats>,
      evolutionData: null == evolutionData
          ? _value._evolutionData
          : evolutionData // ignore: cast_nullable_to_non_nullable
              as List<StatsDataPoint>,
      evolutionByTopicType: null == evolutionByTopicType
          ? _value._evolutionByTopicType
          : evolutionByTopicType // ignore: cast_nullable_to_non_nullable
              as List<TopicTypeEvolutionData>,
      progressData: null == progressData
          ? _value._progressData
          : progressData // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      comparisonData: freezed == comparisonData
          ? _value._comparisonData
          : comparisonData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      selectedTopicId: freezed == selectedTopicId
          ? _value.selectedTopicId
          : selectedTopicId // ignore: cast_nullable_to_non_nullable
              as int?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$StatsStateImpl extends _StatsState {
  const _$StatsStateImpl(
      {this.status = StatsStatus.initial,
      this.globalStats = const UserStats(),
      final List<TopicMockStats> topicStats = const [],
      final List<StatsDataPoint> evolutionData = const [],
      final List<TopicTypeEvolutionData> evolutionByTopicType = const [],
      final List<Map<String, dynamic>> progressData = const [],
      final Map<String, dynamic>? comparisonData,
      this.selectedTopicId,
      this.errorMessage,
      this.lastUpdated})
      : _topicStats = topicStats,
        _evolutionData = evolutionData,
        _evolutionByTopicType = evolutionByTopicType,
        _progressData = progressData,
        _comparisonData = comparisonData,
        super._();

  /// Estado de la carga
  @override
  @JsonKey()
  final StatsStatus status;

  /// Estadísticas globales del usuario
  @override
  @JsonKey()
  final UserStats globalStats;

  /// Estadísticas por cada topic Mock
  final List<TopicMockStats> _topicStats;

  /// Estadísticas por cada topic Mock
  @override
  @JsonKey()
  List<TopicMockStats> get topicStats {
    if (_topicStats is EqualUnmodifiableListView) return _topicStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topicStats);
  }

  /// Datos para gráficos de evolución
  final List<StatsDataPoint> _evolutionData;

  /// Datos para gráficos de evolución
  @override
  @JsonKey()
  List<StatsDataPoint> get evolutionData {
    if (_evolutionData is EqualUnmodifiableListView) return _evolutionData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_evolutionData);
  }

  /// Datos de evolución agrupados por topic_type
  final List<TopicTypeEvolutionData> _evolutionByTopicType;

  /// Datos de evolución agrupados por topic_type
  @override
  @JsonKey()
  List<TopicTypeEvolutionData> get evolutionByTopicType {
    if (_evolutionByTopicType is EqualUnmodifiableListView)
      return _evolutionByTopicType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_evolutionByTopicType);
  }

  /// Datos de progreso/mejora
  final List<Map<String, dynamic>> _progressData;

  /// Datos de progreso/mejora
  @override
  @JsonKey()
  List<Map<String, dynamic>> get progressData {
    if (_progressData is EqualUnmodifiableListView) return _progressData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_progressData);
  }

  /// Comparación con promedio (para un topic específico)
  final Map<String, dynamic>? _comparisonData;

  /// Comparación con promedio (para un topic específico)
  @override
  Map<String, dynamic>? get comparisonData {
    final value = _comparisonData;
    if (value == null) return null;
    if (_comparisonData is EqualUnmodifiableMapView) return _comparisonData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// ID del topic seleccionado para comparación
  @override
  final int? selectedTopicId;

  /// Mensaje de error (si hay)
  @override
  final String? errorMessage;

  /// Timestamp de la última actualización (para caché)
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'StatsState(status: $status, globalStats: $globalStats, topicStats: $topicStats, evolutionData: $evolutionData, evolutionByTopicType: $evolutionByTopicType, progressData: $progressData, comparisonData: $comparisonData, selectedTopicId: $selectedTopicId, errorMessage: $errorMessage, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.globalStats, globalStats) ||
                other.globalStats == globalStats) &&
            const DeepCollectionEquality()
                .equals(other._topicStats, _topicStats) &&
            const DeepCollectionEquality()
                .equals(other._evolutionData, _evolutionData) &&
            const DeepCollectionEquality()
                .equals(other._evolutionByTopicType, _evolutionByTopicType) &&
            const DeepCollectionEquality()
                .equals(other._progressData, _progressData) &&
            const DeepCollectionEquality()
                .equals(other._comparisonData, _comparisonData) &&
            (identical(other.selectedTopicId, selectedTopicId) ||
                other.selectedTopicId == selectedTopicId) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      globalStats,
      const DeepCollectionEquality().hash(_topicStats),
      const DeepCollectionEquality().hash(_evolutionData),
      const DeepCollectionEquality().hash(_evolutionByTopicType),
      const DeepCollectionEquality().hash(_progressData),
      const DeepCollectionEquality().hash(_comparisonData),
      selectedTopicId,
      errorMessage,
      lastUpdated);

  /// Create a copy of StatsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatsStateImplCopyWith<_$StatsStateImpl> get copyWith =>
      __$$StatsStateImplCopyWithImpl<_$StatsStateImpl>(this, _$identity);
}

abstract class _StatsState extends StatsState {
  const factory _StatsState(
      {final StatsStatus status,
      final UserStats globalStats,
      final List<TopicMockStats> topicStats,
      final List<StatsDataPoint> evolutionData,
      final List<TopicTypeEvolutionData> evolutionByTopicType,
      final List<Map<String, dynamic>> progressData,
      final Map<String, dynamic>? comparisonData,
      final int? selectedTopicId,
      final String? errorMessage,
      final DateTime? lastUpdated}) = _$StatsStateImpl;
  const _StatsState._() : super._();

  /// Estado de la carga
  @override
  StatsStatus get status;

  /// Estadísticas globales del usuario
  @override
  UserStats get globalStats;

  /// Estadísticas por cada topic Mock
  @override
  List<TopicMockStats> get topicStats;

  /// Datos para gráficos de evolución
  @override
  List<StatsDataPoint> get evolutionData;

  /// Datos de evolución agrupados por topic_type
  @override
  List<TopicTypeEvolutionData> get evolutionByTopicType;

  /// Datos de progreso/mejora
  @override
  List<Map<String, dynamic>> get progressData;

  /// Comparación con promedio (para un topic específico)
  @override
  Map<String, dynamic>? get comparisonData;

  /// ID del topic seleccionado para comparación
  @override
  int? get selectedTopicId;

  /// Mensaje de error (si hay)
  @override
  String? get errorMessage;

  /// Timestamp de la última actualización (para caché)
  @override
  DateTime? get lastUpdated;

  /// Create a copy of StatsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatsStateImplCopyWith<_$StatsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

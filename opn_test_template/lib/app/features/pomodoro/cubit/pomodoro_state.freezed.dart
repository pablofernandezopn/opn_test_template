// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pomodoro_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PomodoroState {
  /// Configuración actual del pomodoro
  PomodoroConfig get config => throw _privateConstructorUsedError;

  /// Tipo de sesión actual
  PomodoroSessionType get sessionType => throw _privateConstructorUsedError;

  /// Estado del timer
  TimerStatus get timerStatus => throw _privateConstructorUsedError;

  /// Segundos restantes en la sesión actual
  int get remainingSeconds => throw _privateConstructorUsedError;

  /// Número de sesión de trabajo completadas
  int get completedSessions => throw _privateConstructorUsedError;

  /// Total de sesiones de trabajo completadas hoy
  int get totalSessionsToday => throw _privateConstructorUsedError;

  /// Total de minutos estudiados hoy
  int get totalMinutesToday => throw _privateConstructorUsedError;

  /// Si se está mostrando la configuración
  bool get showingSettings => throw _privateConstructorUsedError;

  /// Create a copy of PomodoroState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PomodoroStateCopyWith<PomodoroState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PomodoroStateCopyWith<$Res> {
  factory $PomodoroStateCopyWith(
          PomodoroState value, $Res Function(PomodoroState) then) =
      _$PomodoroStateCopyWithImpl<$Res, PomodoroState>;
  @useResult
  $Res call(
      {PomodoroConfig config,
      PomodoroSessionType sessionType,
      TimerStatus timerStatus,
      int remainingSeconds,
      int completedSessions,
      int totalSessionsToday,
      int totalMinutesToday,
      bool showingSettings});
}

/// @nodoc
class _$PomodoroStateCopyWithImpl<$Res, $Val extends PomodoroState>
    implements $PomodoroStateCopyWith<$Res> {
  _$PomodoroStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PomodoroState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? config = null,
    Object? sessionType = null,
    Object? timerStatus = null,
    Object? remainingSeconds = null,
    Object? completedSessions = null,
    Object? totalSessionsToday = null,
    Object? totalMinutesToday = null,
    Object? showingSettings = null,
  }) {
    return _then(_value.copyWith(
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as PomodoroConfig,
      sessionType: null == sessionType
          ? _value.sessionType
          : sessionType // ignore: cast_nullable_to_non_nullable
              as PomodoroSessionType,
      timerStatus: null == timerStatus
          ? _value.timerStatus
          : timerStatus // ignore: cast_nullable_to_non_nullable
              as TimerStatus,
      remainingSeconds: null == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      completedSessions: null == completedSessions
          ? _value.completedSessions
          : completedSessions // ignore: cast_nullable_to_non_nullable
              as int,
      totalSessionsToday: null == totalSessionsToday
          ? _value.totalSessionsToday
          : totalSessionsToday // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutesToday: null == totalMinutesToday
          ? _value.totalMinutesToday
          : totalMinutesToday // ignore: cast_nullable_to_non_nullable
              as int,
      showingSettings: null == showingSettings
          ? _value.showingSettings
          : showingSettings // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PomodoroStateImplCopyWith<$Res>
    implements $PomodoroStateCopyWith<$Res> {
  factory _$$PomodoroStateImplCopyWith(
          _$PomodoroStateImpl value, $Res Function(_$PomodoroStateImpl) then) =
      __$$PomodoroStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PomodoroConfig config,
      PomodoroSessionType sessionType,
      TimerStatus timerStatus,
      int remainingSeconds,
      int completedSessions,
      int totalSessionsToday,
      int totalMinutesToday,
      bool showingSettings});
}

/// @nodoc
class __$$PomodoroStateImplCopyWithImpl<$Res>
    extends _$PomodoroStateCopyWithImpl<$Res, _$PomodoroStateImpl>
    implements _$$PomodoroStateImplCopyWith<$Res> {
  __$$PomodoroStateImplCopyWithImpl(
      _$PomodoroStateImpl _value, $Res Function(_$PomodoroStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PomodoroState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? config = null,
    Object? sessionType = null,
    Object? timerStatus = null,
    Object? remainingSeconds = null,
    Object? completedSessions = null,
    Object? totalSessionsToday = null,
    Object? totalMinutesToday = null,
    Object? showingSettings = null,
  }) {
    return _then(_$PomodoroStateImpl(
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as PomodoroConfig,
      sessionType: null == sessionType
          ? _value.sessionType
          : sessionType // ignore: cast_nullable_to_non_nullable
              as PomodoroSessionType,
      timerStatus: null == timerStatus
          ? _value.timerStatus
          : timerStatus // ignore: cast_nullable_to_non_nullable
              as TimerStatus,
      remainingSeconds: null == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      completedSessions: null == completedSessions
          ? _value.completedSessions
          : completedSessions // ignore: cast_nullable_to_non_nullable
              as int,
      totalSessionsToday: null == totalSessionsToday
          ? _value.totalSessionsToday
          : totalSessionsToday // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutesToday: null == totalMinutesToday
          ? _value.totalMinutesToday
          : totalMinutesToday // ignore: cast_nullable_to_non_nullable
              as int,
      showingSettings: null == showingSettings
          ? _value.showingSettings
          : showingSettings // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$PomodoroStateImpl extends _PomodoroState {
  const _$PomodoroStateImpl(
      {required this.config,
      required this.sessionType,
      required this.timerStatus,
      required this.remainingSeconds,
      this.completedSessions = 0,
      this.totalSessionsToday = 0,
      this.totalMinutesToday = 0,
      this.showingSettings = false})
      : super._();

  /// Configuración actual del pomodoro
  @override
  final PomodoroConfig config;

  /// Tipo de sesión actual
  @override
  final PomodoroSessionType sessionType;

  /// Estado del timer
  @override
  final TimerStatus timerStatus;

  /// Segundos restantes en la sesión actual
  @override
  final int remainingSeconds;

  /// Número de sesión de trabajo completadas
  @override
  @JsonKey()
  final int completedSessions;

  /// Total de sesiones de trabajo completadas hoy
  @override
  @JsonKey()
  final int totalSessionsToday;

  /// Total de minutos estudiados hoy
  @override
  @JsonKey()
  final int totalMinutesToday;

  /// Si se está mostrando la configuración
  @override
  @JsonKey()
  final bool showingSettings;

  @override
  String toString() {
    return 'PomodoroState(config: $config, sessionType: $sessionType, timerStatus: $timerStatus, remainingSeconds: $remainingSeconds, completedSessions: $completedSessions, totalSessionsToday: $totalSessionsToday, totalMinutesToday: $totalMinutesToday, showingSettings: $showingSettings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PomodoroStateImpl &&
            (identical(other.config, config) || other.config == config) &&
            (identical(other.sessionType, sessionType) ||
                other.sessionType == sessionType) &&
            (identical(other.timerStatus, timerStatus) ||
                other.timerStatus == timerStatus) &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds) &&
            (identical(other.completedSessions, completedSessions) ||
                other.completedSessions == completedSessions) &&
            (identical(other.totalSessionsToday, totalSessionsToday) ||
                other.totalSessionsToday == totalSessionsToday) &&
            (identical(other.totalMinutesToday, totalMinutesToday) ||
                other.totalMinutesToday == totalMinutesToday) &&
            (identical(other.showingSettings, showingSettings) ||
                other.showingSettings == showingSettings));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      config,
      sessionType,
      timerStatus,
      remainingSeconds,
      completedSessions,
      totalSessionsToday,
      totalMinutesToday,
      showingSettings);

  /// Create a copy of PomodoroState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PomodoroStateImplCopyWith<_$PomodoroStateImpl> get copyWith =>
      __$$PomodoroStateImplCopyWithImpl<_$PomodoroStateImpl>(this, _$identity);
}

abstract class _PomodoroState extends PomodoroState {
  const factory _PomodoroState(
      {required final PomodoroConfig config,
      required final PomodoroSessionType sessionType,
      required final TimerStatus timerStatus,
      required final int remainingSeconds,
      final int completedSessions,
      final int totalSessionsToday,
      final int totalMinutesToday,
      final bool showingSettings}) = _$PomodoroStateImpl;
  const _PomodoroState._() : super._();

  /// Configuración actual del pomodoro
  @override
  PomodoroConfig get config;

  /// Tipo de sesión actual
  @override
  PomodoroSessionType get sessionType;

  /// Estado del timer
  @override
  TimerStatus get timerStatus;

  /// Segundos restantes en la sesión actual
  @override
  int get remainingSeconds;

  /// Número de sesión de trabajo completadas
  @override
  int get completedSessions;

  /// Total de sesiones de trabajo completadas hoy
  @override
  int get totalSessionsToday;

  /// Total de minutos estudiados hoy
  @override
  int get totalMinutesToday;

  /// Si se está mostrando la configuración
  @override
  bool get showingSettings;

  /// Create a copy of PomodoroState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PomodoroStateImplCopyWith<_$PomodoroStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

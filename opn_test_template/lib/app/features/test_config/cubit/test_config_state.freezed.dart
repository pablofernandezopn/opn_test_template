// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_config_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TestConfigState {
  /// Configuración actual del test
  TestConfig get config => throw _privateConstructorUsedError;

  /// Lista de topics disponibles de tipo Study
  List<Topic> get availableTopics => throw _privateConstructorUsedError;

  /// Estado de carga de los topics
  Status get fetchTopicsStatus => throw _privateConstructorUsedError;

  /// Estado de validación de la configuración
  Status get validationStatus => throw _privateConstructorUsedError;

  /// Configuraciones guardadas del usuario
  List<SavedTestConfig> get savedConfigs => throw _privateConstructorUsedError;

  /// Estado de carga de las configuraciones guardadas
  Status get savedConfigsStatus => throw _privateConstructorUsedError;

  /// Indica si está en modo juego (true) o estudio (false)
  bool get isGameMode => throw _privateConstructorUsedError;

  /// Mensaje de error si hay alguno
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of TestConfigState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestConfigStateCopyWith<TestConfigState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestConfigStateCopyWith<$Res> {
  factory $TestConfigStateCopyWith(
          TestConfigState value, $Res Function(TestConfigState) then) =
      _$TestConfigStateCopyWithImpl<$Res, TestConfigState>;
  @useResult
  $Res call(
      {TestConfig config,
      List<Topic> availableTopics,
      Status fetchTopicsStatus,
      Status validationStatus,
      List<SavedTestConfig> savedConfigs,
      Status savedConfigsStatus,
      bool isGameMode,
      String? error});
}

/// @nodoc
class _$TestConfigStateCopyWithImpl<$Res, $Val extends TestConfigState>
    implements $TestConfigStateCopyWith<$Res> {
  _$TestConfigStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestConfigState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? config = null,
    Object? availableTopics = null,
    Object? fetchTopicsStatus = null,
    Object? validationStatus = null,
    Object? savedConfigs = null,
    Object? savedConfigsStatus = null,
    Object? isGameMode = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as TestConfig,
      availableTopics: null == availableTopics
          ? _value.availableTopics
          : availableTopics // ignore: cast_nullable_to_non_nullable
              as List<Topic>,
      fetchTopicsStatus: null == fetchTopicsStatus
          ? _value.fetchTopicsStatus
          : fetchTopicsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      validationStatus: null == validationStatus
          ? _value.validationStatus
          : validationStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      savedConfigs: null == savedConfigs
          ? _value.savedConfigs
          : savedConfigs // ignore: cast_nullable_to_non_nullable
              as List<SavedTestConfig>,
      savedConfigsStatus: null == savedConfigsStatus
          ? _value.savedConfigsStatus
          : savedConfigsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      isGameMode: null == isGameMode
          ? _value.isGameMode
          : isGameMode // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TestConfigStateImplCopyWith<$Res>
    implements $TestConfigStateCopyWith<$Res> {
  factory _$$TestConfigStateImplCopyWith(_$TestConfigStateImpl value,
          $Res Function(_$TestConfigStateImpl) then) =
      __$$TestConfigStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TestConfig config,
      List<Topic> availableTopics,
      Status fetchTopicsStatus,
      Status validationStatus,
      List<SavedTestConfig> savedConfigs,
      Status savedConfigsStatus,
      bool isGameMode,
      String? error});
}

/// @nodoc
class __$$TestConfigStateImplCopyWithImpl<$Res>
    extends _$TestConfigStateCopyWithImpl<$Res, _$TestConfigStateImpl>
    implements _$$TestConfigStateImplCopyWith<$Res> {
  __$$TestConfigStateImplCopyWithImpl(
      _$TestConfigStateImpl _value, $Res Function(_$TestConfigStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestConfigState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? config = null,
    Object? availableTopics = null,
    Object? fetchTopicsStatus = null,
    Object? validationStatus = null,
    Object? savedConfigs = null,
    Object? savedConfigsStatus = null,
    Object? isGameMode = null,
    Object? error = freezed,
  }) {
    return _then(_$TestConfigStateImpl(
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as TestConfig,
      availableTopics: null == availableTopics
          ? _value._availableTopics
          : availableTopics // ignore: cast_nullable_to_non_nullable
              as List<Topic>,
      fetchTopicsStatus: null == fetchTopicsStatus
          ? _value.fetchTopicsStatus
          : fetchTopicsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      validationStatus: null == validationStatus
          ? _value.validationStatus
          : validationStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      savedConfigs: null == savedConfigs
          ? _value._savedConfigs
          : savedConfigs // ignore: cast_nullable_to_non_nullable
              as List<SavedTestConfig>,
      savedConfigsStatus: null == savedConfigsStatus
          ? _value.savedConfigsStatus
          : savedConfigsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      isGameMode: null == isGameMode
          ? _value.isGameMode
          : isGameMode // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TestConfigStateImpl extends _TestConfigState {
  const _$TestConfigStateImpl(
      {required this.config,
      final List<Topic> availableTopics = const [],
      required this.fetchTopicsStatus,
      required this.validationStatus,
      final List<SavedTestConfig> savedConfigs = const [],
      required this.savedConfigsStatus,
      this.isGameMode = false,
      this.error})
      : _availableTopics = availableTopics,
        _savedConfigs = savedConfigs,
        super._();

  /// Configuración actual del test
  @override
  final TestConfig config;

  /// Lista de topics disponibles de tipo Study
  final List<Topic> _availableTopics;

  /// Lista de topics disponibles de tipo Study
  @override
  @JsonKey()
  List<Topic> get availableTopics {
    if (_availableTopics is EqualUnmodifiableListView) return _availableTopics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableTopics);
  }

  /// Estado de carga de los topics
  @override
  final Status fetchTopicsStatus;

  /// Estado de validación de la configuración
  @override
  final Status validationStatus;

  /// Configuraciones guardadas del usuario
  final List<SavedTestConfig> _savedConfigs;

  /// Configuraciones guardadas del usuario
  @override
  @JsonKey()
  List<SavedTestConfig> get savedConfigs {
    if (_savedConfigs is EqualUnmodifiableListView) return _savedConfigs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_savedConfigs);
  }

  /// Estado de carga de las configuraciones guardadas
  @override
  final Status savedConfigsStatus;

  /// Indica si está en modo juego (true) o estudio (false)
  @override
  @JsonKey()
  final bool isGameMode;

  /// Mensaje de error si hay alguno
  @override
  final String? error;

  @override
  String toString() {
    return 'TestConfigState(config: $config, availableTopics: $availableTopics, fetchTopicsStatus: $fetchTopicsStatus, validationStatus: $validationStatus, savedConfigs: $savedConfigs, savedConfigsStatus: $savedConfigsStatus, isGameMode: $isGameMode, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestConfigStateImpl &&
            (identical(other.config, config) || other.config == config) &&
            const DeepCollectionEquality()
                .equals(other._availableTopics, _availableTopics) &&
            (identical(other.fetchTopicsStatus, fetchTopicsStatus) ||
                other.fetchTopicsStatus == fetchTopicsStatus) &&
            (identical(other.validationStatus, validationStatus) ||
                other.validationStatus == validationStatus) &&
            const DeepCollectionEquality()
                .equals(other._savedConfigs, _savedConfigs) &&
            (identical(other.savedConfigsStatus, savedConfigsStatus) ||
                other.savedConfigsStatus == savedConfigsStatus) &&
            (identical(other.isGameMode, isGameMode) ||
                other.isGameMode == isGameMode) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      config,
      const DeepCollectionEquality().hash(_availableTopics),
      fetchTopicsStatus,
      validationStatus,
      const DeepCollectionEquality().hash(_savedConfigs),
      savedConfigsStatus,
      isGameMode,
      error);

  /// Create a copy of TestConfigState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestConfigStateImplCopyWith<_$TestConfigStateImpl> get copyWith =>
      __$$TestConfigStateImplCopyWithImpl<_$TestConfigStateImpl>(
          this, _$identity);
}

abstract class _TestConfigState extends TestConfigState {
  const factory _TestConfigState(
      {required final TestConfig config,
      final List<Topic> availableTopics,
      required final Status fetchTopicsStatus,
      required final Status validationStatus,
      final List<SavedTestConfig> savedConfigs,
      required final Status savedConfigsStatus,
      final bool isGameMode,
      final String? error}) = _$TestConfigStateImpl;
  const _TestConfigState._() : super._();

  /// Configuración actual del test
  @override
  TestConfig get config;

  /// Lista de topics disponibles de tipo Study
  @override
  List<Topic> get availableTopics;

  /// Estado de carga de los topics
  @override
  Status get fetchTopicsStatus;

  /// Estado de validación de la configuración
  @override
  Status get validationStatus;

  /// Configuraciones guardadas del usuario
  @override
  List<SavedTestConfig> get savedConfigs;

  /// Estado de carga de las configuraciones guardadas
  @override
  Status get savedConfigsStatus;

  /// Indica si está en modo juego (true) o estudio (false)
  @override
  bool get isGameMode;

  /// Mensaje de error si hay alguno
  @override
  String? get error;

  /// Create a copy of TestConfigState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestConfigStateImplCopyWith<_$TestConfigStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

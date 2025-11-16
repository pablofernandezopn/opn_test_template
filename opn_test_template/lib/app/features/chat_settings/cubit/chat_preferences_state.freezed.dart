// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_preferences_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChatPreferencesState {
// Lista de modelos disponibles
  List<AiModel> get availableModels =>
      throw _privateConstructorUsedError; // Preferencias actuales del usuario
  ChatUserPreferences? get preferences =>
      throw _privateConstructorUsedError; // Modelo actualmente seleccionado
  AiModel? get selectedModel =>
      throw _privateConstructorUsedError; // Estados de carga
  bool get isLoadingModels => throw _privateConstructorUsedError;
  bool get isLoadingPreferences => throw _privateConstructorUsedError;
  bool get isSaving => throw _privateConstructorUsedError; // Estados de error
  String? get errorMessage => throw _privateConstructorUsedError;
  bool get hasError =>
      throw _privateConstructorUsedError; // Flag para saber si hubo cambios sin guardar
  bool get hasUnsavedChanges => throw _privateConstructorUsedError;

  /// Create a copy of ChatPreferencesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatPreferencesStateCopyWith<ChatPreferencesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatPreferencesStateCopyWith<$Res> {
  factory $ChatPreferencesStateCopyWith(ChatPreferencesState value,
          $Res Function(ChatPreferencesState) then) =
      _$ChatPreferencesStateCopyWithImpl<$Res, ChatPreferencesState>;
  @useResult
  $Res call(
      {List<AiModel> availableModels,
      ChatUserPreferences? preferences,
      AiModel? selectedModel,
      bool isLoadingModels,
      bool isLoadingPreferences,
      bool isSaving,
      String? errorMessage,
      bool hasError,
      bool hasUnsavedChanges});

  $ChatUserPreferencesCopyWith<$Res>? get preferences;
  $AiModelCopyWith<$Res>? get selectedModel;
}

/// @nodoc
class _$ChatPreferencesStateCopyWithImpl<$Res,
        $Val extends ChatPreferencesState>
    implements $ChatPreferencesStateCopyWith<$Res> {
  _$ChatPreferencesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatPreferencesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? availableModels = null,
    Object? preferences = freezed,
    Object? selectedModel = freezed,
    Object? isLoadingModels = null,
    Object? isLoadingPreferences = null,
    Object? isSaving = null,
    Object? errorMessage = freezed,
    Object? hasError = null,
    Object? hasUnsavedChanges = null,
  }) {
    return _then(_value.copyWith(
      availableModels: null == availableModels
          ? _value.availableModels
          : availableModels // ignore: cast_nullable_to_non_nullable
              as List<AiModel>,
      preferences: freezed == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as ChatUserPreferences?,
      selectedModel: freezed == selectedModel
          ? _value.selectedModel
          : selectedModel // ignore: cast_nullable_to_non_nullable
              as AiModel?,
      isLoadingModels: null == isLoadingModels
          ? _value.isLoadingModels
          : isLoadingModels // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingPreferences: null == isLoadingPreferences
          ? _value.isLoadingPreferences
          : isLoadingPreferences // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaving: null == isSaving
          ? _value.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      hasUnsavedChanges: null == hasUnsavedChanges
          ? _value.hasUnsavedChanges
          : hasUnsavedChanges // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of ChatPreferencesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatUserPreferencesCopyWith<$Res>? get preferences {
    if (_value.preferences == null) {
      return null;
    }

    return $ChatUserPreferencesCopyWith<$Res>(_value.preferences!, (value) {
      return _then(_value.copyWith(preferences: value) as $Val);
    });
  }

  /// Create a copy of ChatPreferencesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AiModelCopyWith<$Res>? get selectedModel {
    if (_value.selectedModel == null) {
      return null;
    }

    return $AiModelCopyWith<$Res>(_value.selectedModel!, (value) {
      return _then(_value.copyWith(selectedModel: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatPreferencesStateImplCopyWith<$Res>
    implements $ChatPreferencesStateCopyWith<$Res> {
  factory _$$ChatPreferencesStateImplCopyWith(_$ChatPreferencesStateImpl value,
          $Res Function(_$ChatPreferencesStateImpl) then) =
      __$$ChatPreferencesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<AiModel> availableModels,
      ChatUserPreferences? preferences,
      AiModel? selectedModel,
      bool isLoadingModels,
      bool isLoadingPreferences,
      bool isSaving,
      String? errorMessage,
      bool hasError,
      bool hasUnsavedChanges});

  @override
  $ChatUserPreferencesCopyWith<$Res>? get preferences;
  @override
  $AiModelCopyWith<$Res>? get selectedModel;
}

/// @nodoc
class __$$ChatPreferencesStateImplCopyWithImpl<$Res>
    extends _$ChatPreferencesStateCopyWithImpl<$Res, _$ChatPreferencesStateImpl>
    implements _$$ChatPreferencesStateImplCopyWith<$Res> {
  __$$ChatPreferencesStateImplCopyWithImpl(_$ChatPreferencesStateImpl _value,
      $Res Function(_$ChatPreferencesStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatPreferencesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? availableModels = null,
    Object? preferences = freezed,
    Object? selectedModel = freezed,
    Object? isLoadingModels = null,
    Object? isLoadingPreferences = null,
    Object? isSaving = null,
    Object? errorMessage = freezed,
    Object? hasError = null,
    Object? hasUnsavedChanges = null,
  }) {
    return _then(_$ChatPreferencesStateImpl(
      availableModels: null == availableModels
          ? _value._availableModels
          : availableModels // ignore: cast_nullable_to_non_nullable
              as List<AiModel>,
      preferences: freezed == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as ChatUserPreferences?,
      selectedModel: freezed == selectedModel
          ? _value.selectedModel
          : selectedModel // ignore: cast_nullable_to_non_nullable
              as AiModel?,
      isLoadingModels: null == isLoadingModels
          ? _value.isLoadingModels
          : isLoadingModels // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingPreferences: null == isLoadingPreferences
          ? _value.isLoadingPreferences
          : isLoadingPreferences // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaving: null == isSaving
          ? _value.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      hasUnsavedChanges: null == hasUnsavedChanges
          ? _value.hasUnsavedChanges
          : hasUnsavedChanges // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ChatPreferencesStateImpl extends _ChatPreferencesState {
  const _$ChatPreferencesStateImpl(
      {final List<AiModel> availableModels = const [],
      this.preferences,
      this.selectedModel,
      this.isLoadingModels = false,
      this.isLoadingPreferences = false,
      this.isSaving = false,
      this.errorMessage,
      this.hasError = false,
      this.hasUnsavedChanges = false})
      : _availableModels = availableModels,
        super._();

// Lista de modelos disponibles
  final List<AiModel> _availableModels;
// Lista de modelos disponibles
  @override
  @JsonKey()
  List<AiModel> get availableModels {
    if (_availableModels is EqualUnmodifiableListView) return _availableModels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableModels);
  }

// Preferencias actuales del usuario
  @override
  final ChatUserPreferences? preferences;
// Modelo actualmente seleccionado
  @override
  final AiModel? selectedModel;
// Estados de carga
  @override
  @JsonKey()
  final bool isLoadingModels;
  @override
  @JsonKey()
  final bool isLoadingPreferences;
  @override
  @JsonKey()
  final bool isSaving;
// Estados de error
  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final bool hasError;
// Flag para saber si hubo cambios sin guardar
  @override
  @JsonKey()
  final bool hasUnsavedChanges;

  @override
  String toString() {
    return 'ChatPreferencesState(availableModels: $availableModels, preferences: $preferences, selectedModel: $selectedModel, isLoadingModels: $isLoadingModels, isLoadingPreferences: $isLoadingPreferences, isSaving: $isSaving, errorMessage: $errorMessage, hasError: $hasError, hasUnsavedChanges: $hasUnsavedChanges)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatPreferencesStateImpl &&
            const DeepCollectionEquality()
                .equals(other._availableModels, _availableModels) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences) &&
            (identical(other.selectedModel, selectedModel) ||
                other.selectedModel == selectedModel) &&
            (identical(other.isLoadingModels, isLoadingModels) ||
                other.isLoadingModels == isLoadingModels) &&
            (identical(other.isLoadingPreferences, isLoadingPreferences) ||
                other.isLoadingPreferences == isLoadingPreferences) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.hasUnsavedChanges, hasUnsavedChanges) ||
                other.hasUnsavedChanges == hasUnsavedChanges));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_availableModels),
      preferences,
      selectedModel,
      isLoadingModels,
      isLoadingPreferences,
      isSaving,
      errorMessage,
      hasError,
      hasUnsavedChanges);

  /// Create a copy of ChatPreferencesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatPreferencesStateImplCopyWith<_$ChatPreferencesStateImpl>
      get copyWith =>
          __$$ChatPreferencesStateImplCopyWithImpl<_$ChatPreferencesStateImpl>(
              this, _$identity);
}

abstract class _ChatPreferencesState extends ChatPreferencesState {
  const factory _ChatPreferencesState(
      {final List<AiModel> availableModels,
      final ChatUserPreferences? preferences,
      final AiModel? selectedModel,
      final bool isLoadingModels,
      final bool isLoadingPreferences,
      final bool isSaving,
      final String? errorMessage,
      final bool hasError,
      final bool hasUnsavedChanges}) = _$ChatPreferencesStateImpl;
  const _ChatPreferencesState._() : super._();

// Lista de modelos disponibles
  @override
  List<AiModel> get availableModels; // Preferencias actuales del usuario
  @override
  ChatUserPreferences? get preferences; // Modelo actualmente seleccionado
  @override
  AiModel? get selectedModel; // Estados de carga
  @override
  bool get isLoadingModels;
  @override
  bool get isLoadingPreferences;
  @override
  bool get isSaving; // Estados de error
  @override
  String? get errorMessage;
  @override
  bool get hasError; // Flag para saber si hubo cambios sin guardar
  @override
  bool get hasUnsavedChanges;

  /// Create a copy of ChatPreferencesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatPreferencesStateImplCopyWith<_$ChatPreferencesStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

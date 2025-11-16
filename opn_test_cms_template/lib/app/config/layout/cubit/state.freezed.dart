// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppLayoutState {
  /// Si el menú está expandido (solo aplica a NavigationRail)
  bool get isNavigationExpanded => throw _privateConstructorUsedError;

  /// Si el drawer está abierto (solo móvil)
  bool get isDrawerOpen => throw _privateConstructorUsedError;

  /// Tema actual (light/dark)
  bool get isDarkMode => throw _privateConstructorUsedError;

  /// Densidad de la UI (comfortable/compact/spacious)
  UIDensity get density => throw _privateConstructorUsedError;

  /// Tipo de navegación actual
  NavigationType get navigationType => throw _privateConstructorUsedError;

  /// Ancho actual de la pantalla
  double get screenWidth => throw _privateConstructorUsedError;

  /// Create a copy of AppLayoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppLayoutStateCopyWith<AppLayoutState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppLayoutStateCopyWith<$Res> {
  factory $AppLayoutStateCopyWith(
          AppLayoutState value, $Res Function(AppLayoutState) then) =
      _$AppLayoutStateCopyWithImpl<$Res, AppLayoutState>;
  @useResult
  $Res call(
      {bool isNavigationExpanded,
      bool isDrawerOpen,
      bool isDarkMode,
      UIDensity density,
      NavigationType navigationType,
      double screenWidth});
}

/// @nodoc
class _$AppLayoutStateCopyWithImpl<$Res, $Val extends AppLayoutState>
    implements $AppLayoutStateCopyWith<$Res> {
  _$AppLayoutStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppLayoutState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isNavigationExpanded = null,
    Object? isDrawerOpen = null,
    Object? isDarkMode = null,
    Object? density = null,
    Object? navigationType = null,
    Object? screenWidth = null,
  }) {
    return _then(_value.copyWith(
      isNavigationExpanded: null == isNavigationExpanded
          ? _value.isNavigationExpanded
          : isNavigationExpanded // ignore: cast_nullable_to_non_nullable
              as bool,
      isDrawerOpen: null == isDrawerOpen
          ? _value.isDrawerOpen
          : isDrawerOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      isDarkMode: null == isDarkMode
          ? _value.isDarkMode
          : isDarkMode // ignore: cast_nullable_to_non_nullable
              as bool,
      density: null == density
          ? _value.density
          : density // ignore: cast_nullable_to_non_nullable
              as UIDensity,
      navigationType: null == navigationType
          ? _value.navigationType
          : navigationType // ignore: cast_nullable_to_non_nullable
              as NavigationType,
      screenWidth: null == screenWidth
          ? _value.screenWidth
          : screenWidth // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppLayoutStateImplCopyWith<$Res>
    implements $AppLayoutStateCopyWith<$Res> {
  factory _$$AppLayoutStateImplCopyWith(_$AppLayoutStateImpl value,
          $Res Function(_$AppLayoutStateImpl) then) =
      __$$AppLayoutStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isNavigationExpanded,
      bool isDrawerOpen,
      bool isDarkMode,
      UIDensity density,
      NavigationType navigationType,
      double screenWidth});
}

/// @nodoc
class __$$AppLayoutStateImplCopyWithImpl<$Res>
    extends _$AppLayoutStateCopyWithImpl<$Res, _$AppLayoutStateImpl>
    implements _$$AppLayoutStateImplCopyWith<$Res> {
  __$$AppLayoutStateImplCopyWithImpl(
      _$AppLayoutStateImpl _value, $Res Function(_$AppLayoutStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppLayoutState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isNavigationExpanded = null,
    Object? isDrawerOpen = null,
    Object? isDarkMode = null,
    Object? density = null,
    Object? navigationType = null,
    Object? screenWidth = null,
  }) {
    return _then(_$AppLayoutStateImpl(
      isNavigationExpanded: null == isNavigationExpanded
          ? _value.isNavigationExpanded
          : isNavigationExpanded // ignore: cast_nullable_to_non_nullable
              as bool,
      isDrawerOpen: null == isDrawerOpen
          ? _value.isDrawerOpen
          : isDrawerOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      isDarkMode: null == isDarkMode
          ? _value.isDarkMode
          : isDarkMode // ignore: cast_nullable_to_non_nullable
              as bool,
      density: null == density
          ? _value.density
          : density // ignore: cast_nullable_to_non_nullable
              as UIDensity,
      navigationType: null == navigationType
          ? _value.navigationType
          : navigationType // ignore: cast_nullable_to_non_nullable
              as NavigationType,
      screenWidth: null == screenWidth
          ? _value.screenWidth
          : screenWidth // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$AppLayoutStateImpl extends _AppLayoutState {
  const _$AppLayoutStateImpl(
      {this.isNavigationExpanded = true,
      this.isDrawerOpen = false,
      this.isDarkMode = false,
      this.density = UIDensity.comfortable,
      this.navigationType = NavigationType.railExtended,
      this.screenWidth = 1920.0})
      : super._();

  /// Si el menú está expandido (solo aplica a NavigationRail)
  @override
  @JsonKey()
  final bool isNavigationExpanded;

  /// Si el drawer está abierto (solo móvil)
  @override
  @JsonKey()
  final bool isDrawerOpen;

  /// Tema actual (light/dark)
  @override
  @JsonKey()
  final bool isDarkMode;

  /// Densidad de la UI (comfortable/compact/spacious)
  @override
  @JsonKey()
  final UIDensity density;

  /// Tipo de navegación actual
  @override
  @JsonKey()
  final NavigationType navigationType;

  /// Ancho actual de la pantalla
  @override
  @JsonKey()
  final double screenWidth;

  @override
  String toString() {
    return 'AppLayoutState(isNavigationExpanded: $isNavigationExpanded, isDrawerOpen: $isDrawerOpen, isDarkMode: $isDarkMode, density: $density, navigationType: $navigationType, screenWidth: $screenWidth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppLayoutStateImpl &&
            (identical(other.isNavigationExpanded, isNavigationExpanded) ||
                other.isNavigationExpanded == isNavigationExpanded) &&
            (identical(other.isDrawerOpen, isDrawerOpen) ||
                other.isDrawerOpen == isDrawerOpen) &&
            (identical(other.isDarkMode, isDarkMode) ||
                other.isDarkMode == isDarkMode) &&
            (identical(other.density, density) || other.density == density) &&
            (identical(other.navigationType, navigationType) ||
                other.navigationType == navigationType) &&
            (identical(other.screenWidth, screenWidth) ||
                other.screenWidth == screenWidth));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isNavigationExpanded,
      isDrawerOpen, isDarkMode, density, navigationType, screenWidth);

  /// Create a copy of AppLayoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppLayoutStateImplCopyWith<_$AppLayoutStateImpl> get copyWith =>
      __$$AppLayoutStateImplCopyWithImpl<_$AppLayoutStateImpl>(
          this, _$identity);
}

abstract class _AppLayoutState extends AppLayoutState {
  const factory _AppLayoutState(
      {final bool isNavigationExpanded,
      final bool isDrawerOpen,
      final bool isDarkMode,
      final UIDensity density,
      final NavigationType navigationType,
      final double screenWidth}) = _$AppLayoutStateImpl;
  const _AppLayoutState._() : super._();

  /// Si el menú está expandido (solo aplica a NavigationRail)
  @override
  bool get isNavigationExpanded;

  /// Si el drawer está abierto (solo móvil)
  @override
  bool get isDrawerOpen;

  /// Tema actual (light/dark)
  @override
  bool get isDarkMode;

  /// Densidad de la UI (comfortable/compact/spacious)
  @override
  UIDensity get density;

  /// Tipo de navegación actual
  @override
  NavigationType get navigationType;

  /// Ancho actual de la pantalla
  @override
  double get screenWidth;

  /// Create a copy of AppLayoutState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppLayoutStateImplCopyWith<_$AppLayoutStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

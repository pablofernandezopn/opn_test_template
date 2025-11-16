// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'opn_ranking_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OpnRankingState {
  /// Lista de entradas del ranking OPN
  List<OpnRankingEntry> get entries => throw _privateConstructorUsedError;

  /// Entrada del usuario actual (si tiene índice OPN)
  OpnRankingEntry? get userEntry => throw _privateConstructorUsedError;

  /// Estado actual de la carga
  OpnRankingStatus get status => throw _privateConstructorUsedError;

  /// Página actual (para paginación)
  int get currentPage => throw _privateConstructorUsedError;

  /// Indica si hay más páginas disponibles
  bool get hasMore => throw _privateConstructorUsedError;

  /// Total de participantes en el ranking
  int get totalParticipants => throw _privateConstructorUsedError;

  /// Mensaje de error (si hay)
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of OpnRankingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OpnRankingStateCopyWith<OpnRankingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OpnRankingStateCopyWith<$Res> {
  factory $OpnRankingStateCopyWith(
          OpnRankingState value, $Res Function(OpnRankingState) then) =
      _$OpnRankingStateCopyWithImpl<$Res, OpnRankingState>;
  @useResult
  $Res call(
      {List<OpnRankingEntry> entries,
      OpnRankingEntry? userEntry,
      OpnRankingStatus status,
      int currentPage,
      bool hasMore,
      int totalParticipants,
      String? errorMessage});
}

/// @nodoc
class _$OpnRankingStateCopyWithImpl<$Res, $Val extends OpnRankingState>
    implements $OpnRankingStateCopyWith<$Res> {
  _$OpnRankingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OpnRankingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entries = null,
    Object? userEntry = freezed,
    Object? status = null,
    Object? currentPage = null,
    Object? hasMore = null,
    Object? totalParticipants = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      entries: null == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<OpnRankingEntry>,
      userEntry: freezed == userEntry
          ? _value.userEntry
          : userEntry // ignore: cast_nullable_to_non_nullable
              as OpnRankingEntry?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OpnRankingStatus,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      totalParticipants: null == totalParticipants
          ? _value.totalParticipants
          : totalParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OpnRankingStateImplCopyWith<$Res>
    implements $OpnRankingStateCopyWith<$Res> {
  factory _$$OpnRankingStateImplCopyWith(_$OpnRankingStateImpl value,
          $Res Function(_$OpnRankingStateImpl) then) =
      __$$OpnRankingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<OpnRankingEntry> entries,
      OpnRankingEntry? userEntry,
      OpnRankingStatus status,
      int currentPage,
      bool hasMore,
      int totalParticipants,
      String? errorMessage});
}

/// @nodoc
class __$$OpnRankingStateImplCopyWithImpl<$Res>
    extends _$OpnRankingStateCopyWithImpl<$Res, _$OpnRankingStateImpl>
    implements _$$OpnRankingStateImplCopyWith<$Res> {
  __$$OpnRankingStateImplCopyWithImpl(
      _$OpnRankingStateImpl _value, $Res Function(_$OpnRankingStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of OpnRankingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entries = null,
    Object? userEntry = freezed,
    Object? status = null,
    Object? currentPage = null,
    Object? hasMore = null,
    Object? totalParticipants = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$OpnRankingStateImpl(
      entries: null == entries
          ? _value._entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<OpnRankingEntry>,
      userEntry: freezed == userEntry
          ? _value.userEntry
          : userEntry // ignore: cast_nullable_to_non_nullable
              as OpnRankingEntry?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OpnRankingStatus,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      totalParticipants: null == totalParticipants
          ? _value.totalParticipants
          : totalParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$OpnRankingStateImpl extends _OpnRankingState {
  const _$OpnRankingStateImpl(
      {final List<OpnRankingEntry> entries = const [],
      this.userEntry,
      this.status = OpnRankingStatus.initial,
      this.currentPage = 0,
      this.hasMore = true,
      this.totalParticipants = 0,
      this.errorMessage})
      : _entries = entries,
        super._();

  /// Lista de entradas del ranking OPN
  final List<OpnRankingEntry> _entries;

  /// Lista de entradas del ranking OPN
  @override
  @JsonKey()
  List<OpnRankingEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  /// Entrada del usuario actual (si tiene índice OPN)
  @override
  final OpnRankingEntry? userEntry;

  /// Estado actual de la carga
  @override
  @JsonKey()
  final OpnRankingStatus status;

  /// Página actual (para paginación)
  @override
  @JsonKey()
  final int currentPage;

  /// Indica si hay más páginas disponibles
  @override
  @JsonKey()
  final bool hasMore;

  /// Total de participantes en el ranking
  @override
  @JsonKey()
  final int totalParticipants;

  /// Mensaje de error (si hay)
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'OpnRankingState(entries: $entries, userEntry: $userEntry, status: $status, currentPage: $currentPage, hasMore: $hasMore, totalParticipants: $totalParticipants, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OpnRankingStateImpl &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.userEntry, userEntry) ||
                other.userEntry == userEntry) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.totalParticipants, totalParticipants) ||
                other.totalParticipants == totalParticipants) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_entries),
      userEntry,
      status,
      currentPage,
      hasMore,
      totalParticipants,
      errorMessage);

  /// Create a copy of OpnRankingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OpnRankingStateImplCopyWith<_$OpnRankingStateImpl> get copyWith =>
      __$$OpnRankingStateImplCopyWithImpl<_$OpnRankingStateImpl>(
          this, _$identity);
}

abstract class _OpnRankingState extends OpnRankingState {
  const factory _OpnRankingState(
      {final List<OpnRankingEntry> entries,
      final OpnRankingEntry? userEntry,
      final OpnRankingStatus status,
      final int currentPage,
      final bool hasMore,
      final int totalParticipants,
      final String? errorMessage}) = _$OpnRankingStateImpl;
  const _OpnRankingState._() : super._();

  /// Lista de entradas del ranking OPN
  @override
  List<OpnRankingEntry> get entries;

  /// Entrada del usuario actual (si tiene índice OPN)
  @override
  OpnRankingEntry? get userEntry;

  /// Estado actual de la carga
  @override
  OpnRankingStatus get status;

  /// Página actual (para paginación)
  @override
  int get currentPage;

  /// Indica si hay más páginas disponibles
  @override
  bool get hasMore;

  /// Total de participantes en el ranking
  @override
  int get totalParticipants;

  /// Mensaje de error (si hay)
  @override
  String? get errorMessage;

  /// Create a copy of OpnRankingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OpnRankingStateImplCopyWith<_$OpnRankingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

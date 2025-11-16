// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ranking_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RankingState {
  /// Lista de entradas del ranking
  List<RankingEntry> get entries => throw _privateConstructorUsedError;

  /// Entrada del usuario actual (si participa en el ranking)
  RankingEntry? get userEntry => throw _privateConstructorUsedError;

  /// Estado actual de la carga
  RankingStatus get status => throw _privateConstructorUsedError;

  /// Página actual (para paginación)
  int get currentPage => throw _privateConstructorUsedError;

  /// Indica si hay más páginas disponibles
  bool get hasMore => throw _privateConstructorUsedError;

  /// Total de participantes en el ranking
  int get totalParticipants => throw _privateConstructorUsedError;

  /// Mensaje de error (si hay)
  String? get errorMessage => throw _privateConstructorUsedError;

  /// ID del topic actual
  int? get topicId => throw _privateConstructorUsedError;

  /// ID del grupo de topics (si aplica)
  int? get topicGroupId => throw _privateConstructorUsedError;

  /// Create a copy of RankingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RankingStateCopyWith<RankingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RankingStateCopyWith<$Res> {
  factory $RankingStateCopyWith(
          RankingState value, $Res Function(RankingState) then) =
      _$RankingStateCopyWithImpl<$Res, RankingState>;
  @useResult
  $Res call(
      {List<RankingEntry> entries,
      RankingEntry? userEntry,
      RankingStatus status,
      int currentPage,
      bool hasMore,
      int totalParticipants,
      String? errorMessage,
      int? topicId,
      int? topicGroupId});
}

/// @nodoc
class _$RankingStateCopyWithImpl<$Res, $Val extends RankingState>
    implements $RankingStateCopyWith<$Res> {
  _$RankingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RankingState
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
    Object? topicId = freezed,
    Object? topicGroupId = freezed,
  }) {
    return _then(_value.copyWith(
      entries: null == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<RankingEntry>,
      userEntry: freezed == userEntry
          ? _value.userEntry
          : userEntry // ignore: cast_nullable_to_non_nullable
              as RankingEntry?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RankingStatus,
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
      topicId: freezed == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as int?,
      topicGroupId: freezed == topicGroupId
          ? _value.topicGroupId
          : topicGroupId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RankingStateImplCopyWith<$Res>
    implements $RankingStateCopyWith<$Res> {
  factory _$$RankingStateImplCopyWith(
          _$RankingStateImpl value, $Res Function(_$RankingStateImpl) then) =
      __$$RankingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<RankingEntry> entries,
      RankingEntry? userEntry,
      RankingStatus status,
      int currentPage,
      bool hasMore,
      int totalParticipants,
      String? errorMessage,
      int? topicId,
      int? topicGroupId});
}

/// @nodoc
class __$$RankingStateImplCopyWithImpl<$Res>
    extends _$RankingStateCopyWithImpl<$Res, _$RankingStateImpl>
    implements _$$RankingStateImplCopyWith<$Res> {
  __$$RankingStateImplCopyWithImpl(
      _$RankingStateImpl _value, $Res Function(_$RankingStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RankingState
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
    Object? topicId = freezed,
    Object? topicGroupId = freezed,
  }) {
    return _then(_$RankingStateImpl(
      entries: null == entries
          ? _value._entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<RankingEntry>,
      userEntry: freezed == userEntry
          ? _value.userEntry
          : userEntry // ignore: cast_nullable_to_non_nullable
              as RankingEntry?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RankingStatus,
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
      topicId: freezed == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as int?,
      topicGroupId: freezed == topicGroupId
          ? _value.topicGroupId
          : topicGroupId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$RankingStateImpl extends _RankingState {
  const _$RankingStateImpl(
      {final List<RankingEntry> entries = const [],
      this.userEntry,
      this.status = RankingStatus.initial,
      this.currentPage = 0,
      this.hasMore = true,
      this.totalParticipants = 0,
      this.errorMessage,
      this.topicId,
      this.topicGroupId})
      : _entries = entries,
        super._();

  /// Lista de entradas del ranking
  final List<RankingEntry> _entries;

  /// Lista de entradas del ranking
  @override
  @JsonKey()
  List<RankingEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  /// Entrada del usuario actual (si participa en el ranking)
  @override
  final RankingEntry? userEntry;

  /// Estado actual de la carga
  @override
  @JsonKey()
  final RankingStatus status;

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

  /// ID del topic actual
  @override
  final int? topicId;

  /// ID del grupo de topics (si aplica)
  @override
  final int? topicGroupId;

  @override
  String toString() {
    return 'RankingState(entries: $entries, userEntry: $userEntry, status: $status, currentPage: $currentPage, hasMore: $hasMore, totalParticipants: $totalParticipants, errorMessage: $errorMessage, topicId: $topicId, topicGroupId: $topicGroupId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RankingStateImpl &&
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
                other.errorMessage == errorMessage) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.topicGroupId, topicGroupId) ||
                other.topicGroupId == topicGroupId));
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
      errorMessage,
      topicId,
      topicGroupId);

  /// Create a copy of RankingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RankingStateImplCopyWith<_$RankingStateImpl> get copyWith =>
      __$$RankingStateImplCopyWithImpl<_$RankingStateImpl>(this, _$identity);
}

abstract class _RankingState extends RankingState {
  const factory _RankingState(
      {final List<RankingEntry> entries,
      final RankingEntry? userEntry,
      final RankingStatus status,
      final int currentPage,
      final bool hasMore,
      final int totalParticipants,
      final String? errorMessage,
      final int? topicId,
      final int? topicGroupId}) = _$RankingStateImpl;
  const _RankingState._() : super._();

  /// Lista de entradas del ranking
  @override
  List<RankingEntry> get entries;

  /// Entrada del usuario actual (si participa en el ranking)
  @override
  RankingEntry? get userEntry;

  /// Estado actual de la carga
  @override
  RankingStatus get status;

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

  /// ID del topic actual
  @override
  int? get topicId;

  /// ID del grupo de topics (si aplica)
  @override
  int? get topicGroupId;

  /// Create a copy of RankingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RankingStateImplCopyWith<_$RankingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

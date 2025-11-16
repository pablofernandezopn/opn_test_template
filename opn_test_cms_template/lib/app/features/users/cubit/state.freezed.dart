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
mixin _$UserState {
  List<User> get users => throw _privateConstructorUsedError;
  User? get selectedUser => throw _privateConstructorUsedError;
  Status get fetchUsersStatus => throw _privateConstructorUsedError;
  Status get createUserStatus => throw _privateConstructorUsedError;
  Status get updateUserStatus => throw _privateConstructorUsedError;
  Status get deleteUserStatus => throw _privateConstructorUsedError;
  Status get searchUsersStatus => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get searchQuery =>
      throw _privateConstructorUsedError; // Nuevos campos para paginación
  int get currentPage => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  bool get hasMorePages => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserStateCopyWith<UserState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStateCopyWith<$Res> {
  factory $UserStateCopyWith(UserState value, $Res Function(UserState) then) =
      _$UserStateCopyWithImpl<$Res, UserState>;
  @useResult
  $Res call(
      {List<User> users,
      User? selectedUser,
      Status fetchUsersStatus,
      Status createUserStatus,
      Status updateUserStatus,
      Status deleteUserStatus,
      Status searchUsersStatus,
      String? error,
      String? searchQuery,
      int currentPage,
      int pageSize,
      bool hasMorePages,
      bool isLoadingMore});
}

/// @nodoc
class _$UserStateCopyWithImpl<$Res, $Val extends UserState>
    implements $UserStateCopyWith<$Res> {
  _$UserStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? users = null,
    Object? selectedUser = freezed,
    Object? fetchUsersStatus = null,
    Object? createUserStatus = null,
    Object? updateUserStatus = null,
    Object? deleteUserStatus = null,
    Object? searchUsersStatus = null,
    Object? error = freezed,
    Object? searchQuery = freezed,
    Object? currentPage = null,
    Object? pageSize = null,
    Object? hasMorePages = null,
    Object? isLoadingMore = null,
  }) {
    return _then(_value.copyWith(
      users: null == users
          ? _value.users
          : users // ignore: cast_nullable_to_non_nullable
              as List<User>,
      selectedUser: freezed == selectedUser
          ? _value.selectedUser
          : selectedUser // ignore: cast_nullable_to_non_nullable
              as User?,
      fetchUsersStatus: null == fetchUsersStatus
          ? _value.fetchUsersStatus
          : fetchUsersStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createUserStatus: null == createUserStatus
          ? _value.createUserStatus
          : createUserStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateUserStatus: null == updateUserStatus
          ? _value.updateUserStatus
          : updateUserStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteUserStatus: null == deleteUserStatus
          ? _value.deleteUserStatus
          : deleteUserStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      searchUsersStatus: null == searchUsersStatus
          ? _value.searchUsersStatus
          : searchUsersStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      hasMorePages: null == hasMorePages
          ? _value.hasMorePages
          : hasMorePages // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserStateImplCopyWith<$Res>
    implements $UserStateCopyWith<$Res> {
  factory _$$UserStateImplCopyWith(
          _$UserStateImpl value, $Res Function(_$UserStateImpl) then) =
      __$$UserStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<User> users,
      User? selectedUser,
      Status fetchUsersStatus,
      Status createUserStatus,
      Status updateUserStatus,
      Status deleteUserStatus,
      Status searchUsersStatus,
      String? error,
      String? searchQuery,
      int currentPage,
      int pageSize,
      bool hasMorePages,
      bool isLoadingMore});
}

/// @nodoc
class __$$UserStateImplCopyWithImpl<$Res>
    extends _$UserStateCopyWithImpl<$Res, _$UserStateImpl>
    implements _$$UserStateImplCopyWith<$Res> {
  __$$UserStateImplCopyWithImpl(
      _$UserStateImpl _value, $Res Function(_$UserStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? users = null,
    Object? selectedUser = freezed,
    Object? fetchUsersStatus = null,
    Object? createUserStatus = null,
    Object? updateUserStatus = null,
    Object? deleteUserStatus = null,
    Object? searchUsersStatus = null,
    Object? error = freezed,
    Object? searchQuery = freezed,
    Object? currentPage = null,
    Object? pageSize = null,
    Object? hasMorePages = null,
    Object? isLoadingMore = null,
  }) {
    return _then(_$UserStateImpl(
      users: null == users
          ? _value._users
          : users // ignore: cast_nullable_to_non_nullable
              as List<User>,
      selectedUser: freezed == selectedUser
          ? _value.selectedUser
          : selectedUser // ignore: cast_nullable_to_non_nullable
              as User?,
      fetchUsersStatus: null == fetchUsersStatus
          ? _value.fetchUsersStatus
          : fetchUsersStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createUserStatus: null == createUserStatus
          ? _value.createUserStatus
          : createUserStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateUserStatus: null == updateUserStatus
          ? _value.updateUserStatus
          : updateUserStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteUserStatus: null == deleteUserStatus
          ? _value.deleteUserStatus
          : deleteUserStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      searchUsersStatus: null == searchUsersStatus
          ? _value.searchUsersStatus
          : searchUsersStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      hasMorePages: null == hasMorePages
          ? _value.hasMorePages
          : hasMorePages // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$UserStateImpl extends _UserState {
  const _$UserStateImpl(
      {final List<User> users = const [],
      this.selectedUser,
      required this.fetchUsersStatus,
      required this.createUserStatus,
      required this.updateUserStatus,
      required this.deleteUserStatus,
      required this.searchUsersStatus,
      this.error,
      this.searchQuery,
      this.currentPage = 0,
      this.pageSize = 20,
      this.hasMorePages = true,
      this.isLoadingMore = false})
      : _users = users,
        super._();

  final List<User> _users;
  @override
  @JsonKey()
  List<User> get users {
    if (_users is EqualUnmodifiableListView) return _users;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_users);
  }

  @override
  final User? selectedUser;
  @override
  final Status fetchUsersStatus;
  @override
  final Status createUserStatus;
  @override
  final Status updateUserStatus;
  @override
  final Status deleteUserStatus;
  @override
  final Status searchUsersStatus;
  @override
  final String? error;
  @override
  final String? searchQuery;
// Nuevos campos para paginación
  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final int pageSize;
  @override
  @JsonKey()
  final bool hasMorePages;
  @override
  @JsonKey()
  final bool isLoadingMore;

  @override
  String toString() {
    return 'UserState(users: $users, selectedUser: $selectedUser, fetchUsersStatus: $fetchUsersStatus, createUserStatus: $createUserStatus, updateUserStatus: $updateUserStatus, deleteUserStatus: $deleteUserStatus, searchUsersStatus: $searchUsersStatus, error: $error, searchQuery: $searchQuery, currentPage: $currentPage, pageSize: $pageSize, hasMorePages: $hasMorePages, isLoadingMore: $isLoadingMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStateImpl &&
            const DeepCollectionEquality().equals(other._users, _users) &&
            (identical(other.selectedUser, selectedUser) ||
                other.selectedUser == selectedUser) &&
            (identical(other.fetchUsersStatus, fetchUsersStatus) ||
                other.fetchUsersStatus == fetchUsersStatus) &&
            (identical(other.createUserStatus, createUserStatus) ||
                other.createUserStatus == createUserStatus) &&
            (identical(other.updateUserStatus, updateUserStatus) ||
                other.updateUserStatus == updateUserStatus) &&
            (identical(other.deleteUserStatus, deleteUserStatus) ||
                other.deleteUserStatus == deleteUserStatus) &&
            (identical(other.searchUsersStatus, searchUsersStatus) ||
                other.searchUsersStatus == searchUsersStatus) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.hasMorePages, hasMorePages) ||
                other.hasMorePages == hasMorePages) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_users),
      selectedUser,
      fetchUsersStatus,
      createUserStatus,
      updateUserStatus,
      deleteUserStatus,
      searchUsersStatus,
      error,
      searchQuery,
      currentPage,
      pageSize,
      hasMorePages,
      isLoadingMore);

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStateImplCopyWith<_$UserStateImpl> get copyWith =>
      __$$UserStateImplCopyWithImpl<_$UserStateImpl>(this, _$identity);
}

abstract class _UserState extends UserState {
  const factory _UserState(
      {final List<User> users,
      final User? selectedUser,
      required final Status fetchUsersStatus,
      required final Status createUserStatus,
      required final Status updateUserStatus,
      required final Status deleteUserStatus,
      required final Status searchUsersStatus,
      final String? error,
      final String? searchQuery,
      final int currentPage,
      final int pageSize,
      final bool hasMorePages,
      final bool isLoadingMore}) = _$UserStateImpl;
  const _UserState._() : super._();

  @override
  List<User> get users;
  @override
  User? get selectedUser;
  @override
  Status get fetchUsersStatus;
  @override
  Status get createUserStatus;
  @override
  Status get updateUserStatus;
  @override
  Status get deleteUserStatus;
  @override
  Status get searchUsersStatus;
  @override
  String? get error;
  @override
  String? get searchQuery; // Nuevos campos para paginación
  @override
  int get currentPage;
  @override
  int get pageSize;
  @override
  bool get hasMorePages;
  @override
  bool get isLoadingMore;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserStateImplCopyWith<_$UserStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

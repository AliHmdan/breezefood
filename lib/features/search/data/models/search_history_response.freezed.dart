// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_history_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SearchHistoryResponse _$SearchHistoryResponseFromJson(
    Map<String, dynamic> json) {
  return _SearchHistoryResponse.fromJson(json);
}

/// @nodoc
mixin _$SearchHistoryResponse {
  List<SearchHistoryItem> get history => throw _privateConstructorUsedError;

  /// Serializes this SearchHistoryResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchHistoryResponseCopyWith<SearchHistoryResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchHistoryResponseCopyWith<$Res> {
  factory $SearchHistoryResponseCopyWith(SearchHistoryResponse value,
          $Res Function(SearchHistoryResponse) then) =
      _$SearchHistoryResponseCopyWithImpl<$Res, SearchHistoryResponse>;
  @useResult
  $Res call({List<SearchHistoryItem> history});
}

/// @nodoc
class _$SearchHistoryResponseCopyWithImpl<$Res,
        $Val extends SearchHistoryResponse>
    implements $SearchHistoryResponseCopyWith<$Res> {
  _$SearchHistoryResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? history = null,
  }) {
    return _then(_value.copyWith(
      history: null == history
          ? _value.history
          : history // ignore: cast_nullable_to_non_nullable
              as List<SearchHistoryItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchHistoryResponseImplCopyWith<$Res>
    implements $SearchHistoryResponseCopyWith<$Res> {
  factory _$$SearchHistoryResponseImplCopyWith(
          _$SearchHistoryResponseImpl value,
          $Res Function(_$SearchHistoryResponseImpl) then) =
      __$$SearchHistoryResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<SearchHistoryItem> history});
}

/// @nodoc
class __$$SearchHistoryResponseImplCopyWithImpl<$Res>
    extends _$SearchHistoryResponseCopyWithImpl<$Res,
        _$SearchHistoryResponseImpl>
    implements _$$SearchHistoryResponseImplCopyWith<$Res> {
  __$$SearchHistoryResponseImplCopyWithImpl(_$SearchHistoryResponseImpl _value,
      $Res Function(_$SearchHistoryResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? history = null,
  }) {
    return _then(_$SearchHistoryResponseImpl(
      history: null == history
          ? _value._history
          : history // ignore: cast_nullable_to_non_nullable
              as List<SearchHistoryItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchHistoryResponseImpl implements _SearchHistoryResponse {
  const _$SearchHistoryResponseImpl(
      {final List<SearchHistoryItem> history = const <SearchHistoryItem>[]})
      : _history = history;

  factory _$SearchHistoryResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchHistoryResponseImplFromJson(json);

  final List<SearchHistoryItem> _history;
  @override
  @JsonKey()
  List<SearchHistoryItem> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  @override
  String toString() {
    return 'SearchHistoryResponse(history: $history)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchHistoryResponseImpl &&
            const DeepCollectionEquality().equals(other._history, _history));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_history));

  /// Create a copy of SearchHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchHistoryResponseImplCopyWith<_$SearchHistoryResponseImpl>
      get copyWith => __$$SearchHistoryResponseImplCopyWithImpl<
          _$SearchHistoryResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchHistoryResponseImplToJson(
      this,
    );
  }
}

abstract class _SearchHistoryResponse implements SearchHistoryResponse {
  const factory _SearchHistoryResponse(
      {final List<SearchHistoryItem> history}) = _$SearchHistoryResponseImpl;

  factory _SearchHistoryResponse.fromJson(Map<String, dynamic> json) =
      _$SearchHistoryResponseImpl.fromJson;

  @override
  List<SearchHistoryItem> get history;

  /// Create a copy of SearchHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchHistoryResponseImplCopyWith<_$SearchHistoryResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SearchHistoryItem _$SearchHistoryItemFromJson(Map<String, dynamic> json) {
  return _SearchHistoryItem.fromJson(json);
}

/// @nodoc
mixin _$SearchHistoryItem {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  int get userId => throw _privateConstructorUsedError;
  String get query => throw _privateConstructorUsedError;
  @JsonKey(name: 'searched_at')
  String get searchedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  String? get deletedAt => throw _privateConstructorUsedError;

  /// Serializes this SearchHistoryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchHistoryItemCopyWith<SearchHistoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchHistoryItemCopyWith<$Res> {
  factory $SearchHistoryItemCopyWith(
          SearchHistoryItem value, $Res Function(SearchHistoryItem) then) =
      _$SearchHistoryItemCopyWithImpl<$Res, SearchHistoryItem>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'user_id') int userId,
      String query,
      @JsonKey(name: 'searched_at') String searchedAt,
      @JsonKey(name: 'deleted_at') String? deletedAt});
}

/// @nodoc
class _$SearchHistoryItemCopyWithImpl<$Res, $Val extends SearchHistoryItem>
    implements $SearchHistoryItemCopyWith<$Res> {
  _$SearchHistoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? query = null,
    Object? searchedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      searchedAt: null == searchedAt
          ? _value.searchedAt
          : searchedAt // ignore: cast_nullable_to_non_nullable
              as String,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchHistoryItemImplCopyWith<$Res>
    implements $SearchHistoryItemCopyWith<$Res> {
  factory _$$SearchHistoryItemImplCopyWith(_$SearchHistoryItemImpl value,
          $Res Function(_$SearchHistoryItemImpl) then) =
      __$$SearchHistoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'user_id') int userId,
      String query,
      @JsonKey(name: 'searched_at') String searchedAt,
      @JsonKey(name: 'deleted_at') String? deletedAt});
}

/// @nodoc
class __$$SearchHistoryItemImplCopyWithImpl<$Res>
    extends _$SearchHistoryItemCopyWithImpl<$Res, _$SearchHistoryItemImpl>
    implements _$$SearchHistoryItemImplCopyWith<$Res> {
  __$$SearchHistoryItemImplCopyWithImpl(_$SearchHistoryItemImpl _value,
      $Res Function(_$SearchHistoryItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? query = null,
    Object? searchedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(_$SearchHistoryItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      searchedAt: null == searchedAt
          ? _value.searchedAt
          : searchedAt // ignore: cast_nullable_to_non_nullable
              as String,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchHistoryItemImpl implements _SearchHistoryItem {
  const _$SearchHistoryItemImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.query,
      @JsonKey(name: 'searched_at') required this.searchedAt,
      @JsonKey(name: 'deleted_at') this.deletedAt});

  factory _$SearchHistoryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchHistoryItemImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'user_id')
  final int userId;
  @override
  final String query;
  @override
  @JsonKey(name: 'searched_at')
  final String searchedAt;
  @override
  @JsonKey(name: 'deleted_at')
  final String? deletedAt;

  @override
  String toString() {
    return 'SearchHistoryItem(id: $id, userId: $userId, query: $query, searchedAt: $searchedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchHistoryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.searchedAt, searchedAt) ||
                other.searchedAt == searchedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, query, searchedAt, deletedAt);

  /// Create a copy of SearchHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchHistoryItemImplCopyWith<_$SearchHistoryItemImpl> get copyWith =>
      __$$SearchHistoryItemImplCopyWithImpl<_$SearchHistoryItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchHistoryItemImplToJson(
      this,
    );
  }
}

abstract class _SearchHistoryItem implements SearchHistoryItem {
  const factory _SearchHistoryItem(
          {required final int id,
          @JsonKey(name: 'user_id') required final int userId,
          required final String query,
          @JsonKey(name: 'searched_at') required final String searchedAt,
          @JsonKey(name: 'deleted_at') final String? deletedAt}) =
      _$SearchHistoryItemImpl;

  factory _SearchHistoryItem.fromJson(Map<String, dynamic> json) =
      _$SearchHistoryItemImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'user_id')
  int get userId;
  @override
  String get query;
  @override
  @JsonKey(name: 'searched_at')
  String get searchedAt;
  @override
  @JsonKey(name: 'deleted_at')
  String? get deletedAt;

  /// Create a copy of SearchHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchHistoryItemImplCopyWith<_$SearchHistoryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

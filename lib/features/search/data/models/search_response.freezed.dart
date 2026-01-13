// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SearchResponse _$SearchResponseFromJson(Map<String, dynamic> json) {
  return _SearchResponse.fromJson(json);
}

/// @nodoc
mixin _$SearchResponse {
  bool get success => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_coordinates')
  bool get hasCoordinates => throw _privateConstructorUsedError;
  @JsonKey(name: 'province_detected')
  String? get provinceDetected => throw _privateConstructorUsedError;
  List<SearchBlock> get data => throw _privateConstructorUsedError;

  /// Serializes this SearchResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchResponseCopyWith<SearchResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchResponseCopyWith<$Res> {
  factory $SearchResponseCopyWith(
          SearchResponse value, $Res Function(SearchResponse) then) =
      _$SearchResponseCopyWithImpl<$Res, SearchResponse>;
  @useResult
  $Res call(
      {bool success,
      @JsonKey(name: 'has_coordinates') bool hasCoordinates,
      @JsonKey(name: 'province_detected') String? provinceDetected,
      List<SearchBlock> data});
}

/// @nodoc
class _$SearchResponseCopyWithImpl<$Res, $Val extends SearchResponse>
    implements $SearchResponseCopyWith<$Res> {
  _$SearchResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? hasCoordinates = null,
    Object? provinceDetected = freezed,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      hasCoordinates: null == hasCoordinates
          ? _value.hasCoordinates
          : hasCoordinates // ignore: cast_nullable_to_non_nullable
              as bool,
      provinceDetected: freezed == provinceDetected
          ? _value.provinceDetected
          : provinceDetected // ignore: cast_nullable_to_non_nullable
              as String?,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<SearchBlock>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchResponseImplCopyWith<$Res>
    implements $SearchResponseCopyWith<$Res> {
  factory _$$SearchResponseImplCopyWith(_$SearchResponseImpl value,
          $Res Function(_$SearchResponseImpl) then) =
      __$$SearchResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success,
      @JsonKey(name: 'has_coordinates') bool hasCoordinates,
      @JsonKey(name: 'province_detected') String? provinceDetected,
      List<SearchBlock> data});
}

/// @nodoc
class __$$SearchResponseImplCopyWithImpl<$Res>
    extends _$SearchResponseCopyWithImpl<$Res, _$SearchResponseImpl>
    implements _$$SearchResponseImplCopyWith<$Res> {
  __$$SearchResponseImplCopyWithImpl(
      _$SearchResponseImpl _value, $Res Function(_$SearchResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? hasCoordinates = null,
    Object? provinceDetected = freezed,
    Object? data = null,
  }) {
    return _then(_$SearchResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      hasCoordinates: null == hasCoordinates
          ? _value.hasCoordinates
          : hasCoordinates // ignore: cast_nullable_to_non_nullable
              as bool,
      provinceDetected: freezed == provinceDetected
          ? _value.provinceDetected
          : provinceDetected // ignore: cast_nullable_to_non_nullable
              as String?,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<SearchBlock>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchResponseImpl implements _SearchResponse {
  const _$SearchResponseImpl(
      {required this.success,
      @JsonKey(name: 'has_coordinates') required this.hasCoordinates,
      @JsonKey(name: 'province_detected') this.provinceDetected,
      final List<SearchBlock> data = const <SearchBlock>[]})
      : _data = data;

  factory _$SearchResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchResponseImplFromJson(json);

  @override
  final bool success;
  @override
  @JsonKey(name: 'has_coordinates')
  final bool hasCoordinates;
  @override
  @JsonKey(name: 'province_detected')
  final String? provinceDetected;
  final List<SearchBlock> _data;
  @override
  @JsonKey()
  List<SearchBlock> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'SearchResponse(success: $success, hasCoordinates: $hasCoordinates, provinceDetected: $provinceDetected, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.hasCoordinates, hasCoordinates) ||
                other.hasCoordinates == hasCoordinates) &&
            (identical(other.provinceDetected, provinceDetected) ||
                other.provinceDetected == provinceDetected) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, success, hasCoordinates,
      provinceDetected, const DeepCollectionEquality().hash(_data));

  /// Create a copy of SearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchResponseImplCopyWith<_$SearchResponseImpl> get copyWith =>
      __$$SearchResponseImplCopyWithImpl<_$SearchResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchResponseImplToJson(
      this,
    );
  }
}

abstract class _SearchResponse implements SearchResponse {
  const factory _SearchResponse(
      {required final bool success,
      @JsonKey(name: 'has_coordinates') required final bool hasCoordinates,
      @JsonKey(name: 'province_detected') final String? provinceDetected,
      final List<SearchBlock> data}) = _$SearchResponseImpl;

  factory _SearchResponse.fromJson(Map<String, dynamic> json) =
      _$SearchResponseImpl.fromJson;

  @override
  bool get success;
  @override
  @JsonKey(name: 'has_coordinates')
  bool get hasCoordinates;
  @override
  @JsonKey(name: 'province_detected')
  String? get provinceDetected;
  @override
  List<SearchBlock> get data;

  /// Create a copy of SearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchResponseImplCopyWith<_$SearchResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchBlock _$SearchBlockFromJson(Map<String, dynamic> json) {
  return _SearchBlock.fromJson(json);
}

/// @nodoc
mixin _$SearchBlock {
  SearchRestaurant get restaurant => throw _privateConstructorUsedError;
  List<SearchItem> get items => throw _privateConstructorUsedError;

  /// Serializes this SearchBlock to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchBlock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchBlockCopyWith<SearchBlock> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchBlockCopyWith<$Res> {
  factory $SearchBlockCopyWith(
          SearchBlock value, $Res Function(SearchBlock) then) =
      _$SearchBlockCopyWithImpl<$Res, SearchBlock>;
  @useResult
  $Res call({SearchRestaurant restaurant, List<SearchItem> items});

  $SearchRestaurantCopyWith<$Res> get restaurant;
}

/// @nodoc
class _$SearchBlockCopyWithImpl<$Res, $Val extends SearchBlock>
    implements $SearchBlockCopyWith<$Res> {
  _$SearchBlockCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchBlock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurant = null,
    Object? items = null,
  }) {
    return _then(_value.copyWith(
      restaurant: null == restaurant
          ? _value.restaurant
          : restaurant // ignore: cast_nullable_to_non_nullable
              as SearchRestaurant,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<SearchItem>,
    ) as $Val);
  }

  /// Create a copy of SearchBlock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SearchRestaurantCopyWith<$Res> get restaurant {
    return $SearchRestaurantCopyWith<$Res>(_value.restaurant, (value) {
      return _then(_value.copyWith(restaurant: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SearchBlockImplCopyWith<$Res>
    implements $SearchBlockCopyWith<$Res> {
  factory _$$SearchBlockImplCopyWith(
          _$SearchBlockImpl value, $Res Function(_$SearchBlockImpl) then) =
      __$$SearchBlockImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SearchRestaurant restaurant, List<SearchItem> items});

  @override
  $SearchRestaurantCopyWith<$Res> get restaurant;
}

/// @nodoc
class __$$SearchBlockImplCopyWithImpl<$Res>
    extends _$SearchBlockCopyWithImpl<$Res, _$SearchBlockImpl>
    implements _$$SearchBlockImplCopyWith<$Res> {
  __$$SearchBlockImplCopyWithImpl(
      _$SearchBlockImpl _value, $Res Function(_$SearchBlockImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchBlock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurant = null,
    Object? items = null,
  }) {
    return _then(_$SearchBlockImpl(
      restaurant: null == restaurant
          ? _value.restaurant
          : restaurant // ignore: cast_nullable_to_non_nullable
              as SearchRestaurant,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<SearchItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchBlockImpl implements _SearchBlock {
  const _$SearchBlockImpl(
      {required this.restaurant,
      final List<SearchItem> items = const <SearchItem>[]})
      : _items = items;

  factory _$SearchBlockImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchBlockImplFromJson(json);

  @override
  final SearchRestaurant restaurant;
  final List<SearchItem> _items;
  @override
  @JsonKey()
  List<SearchItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'SearchBlock(restaurant: $restaurant, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchBlockImpl &&
            (identical(other.restaurant, restaurant) ||
                other.restaurant == restaurant) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, restaurant, const DeepCollectionEquality().hash(_items));

  /// Create a copy of SearchBlock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchBlockImplCopyWith<_$SearchBlockImpl> get copyWith =>
      __$$SearchBlockImplCopyWithImpl<_$SearchBlockImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchBlockImplToJson(
      this,
    );
  }
}

abstract class _SearchBlock implements SearchBlock {
  const factory _SearchBlock(
      {required final SearchRestaurant restaurant,
      final List<SearchItem> items}) = _$SearchBlockImpl;

  factory _SearchBlock.fromJson(Map<String, dynamic> json) =
      _$SearchBlockImpl.fromJson;

  @override
  SearchRestaurant get restaurant;
  @override
  List<SearchItem> get items;

  /// Create a copy of SearchBlock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchBlockImplCopyWith<_$SearchBlockImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchRestaurant _$SearchRestaurantFromJson(Map<String, dynamic> json) {
  return _SearchRestaurant.fromJson(json);
}

/// @nodoc
mixin _$SearchRestaurant {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get logo => throw _privateConstructorUsedError;
  SearchRating? get rating => throw _privateConstructorUsedError;

  /// Serializes this SearchRestaurant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchRestaurant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchRestaurantCopyWith<SearchRestaurant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchRestaurantCopyWith<$Res> {
  factory $SearchRestaurantCopyWith(
          SearchRestaurant value, $Res Function(SearchRestaurant) then) =
      _$SearchRestaurantCopyWithImpl<$Res, SearchRestaurant>;
  @useResult
  $Res call({int id, String name, String? logo, SearchRating? rating});

  $SearchRatingCopyWith<$Res>? get rating;
}

/// @nodoc
class _$SearchRestaurantCopyWithImpl<$Res, $Val extends SearchRestaurant>
    implements $SearchRestaurantCopyWith<$Res> {
  _$SearchRestaurantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchRestaurant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? logo = freezed,
    Object? rating = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      logo: freezed == logo
          ? _value.logo
          : logo // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as SearchRating?,
    ) as $Val);
  }

  /// Create a copy of SearchRestaurant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SearchRatingCopyWith<$Res>? get rating {
    if (_value.rating == null) {
      return null;
    }

    return $SearchRatingCopyWith<$Res>(_value.rating!, (value) {
      return _then(_value.copyWith(rating: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SearchRestaurantImplCopyWith<$Res>
    implements $SearchRestaurantCopyWith<$Res> {
  factory _$$SearchRestaurantImplCopyWith(_$SearchRestaurantImpl value,
          $Res Function(_$SearchRestaurantImpl) then) =
      __$$SearchRestaurantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String? logo, SearchRating? rating});

  @override
  $SearchRatingCopyWith<$Res>? get rating;
}

/// @nodoc
class __$$SearchRestaurantImplCopyWithImpl<$Res>
    extends _$SearchRestaurantCopyWithImpl<$Res, _$SearchRestaurantImpl>
    implements _$$SearchRestaurantImplCopyWith<$Res> {
  __$$SearchRestaurantImplCopyWithImpl(_$SearchRestaurantImpl _value,
      $Res Function(_$SearchRestaurantImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchRestaurant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? logo = freezed,
    Object? rating = freezed,
  }) {
    return _then(_$SearchRestaurantImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      logo: freezed == logo
          ? _value.logo
          : logo // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as SearchRating?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchRestaurantImpl implements _SearchRestaurant {
  const _$SearchRestaurantImpl(
      {required this.id, required this.name, this.logo, this.rating});

  factory _$SearchRestaurantImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchRestaurantImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? logo;
  @override
  final SearchRating? rating;

  @override
  String toString() {
    return 'SearchRestaurant(id: $id, name: $name, logo: $logo, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchRestaurantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            (identical(other.rating, rating) || other.rating == rating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, logo, rating);

  /// Create a copy of SearchRestaurant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchRestaurantImplCopyWith<_$SearchRestaurantImpl> get copyWith =>
      __$$SearchRestaurantImplCopyWithImpl<_$SearchRestaurantImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchRestaurantImplToJson(
      this,
    );
  }
}

abstract class _SearchRestaurant implements SearchRestaurant {
  const factory _SearchRestaurant(
      {required final int id,
      required final String name,
      final String? logo,
      final SearchRating? rating}) = _$SearchRestaurantImpl;

  factory _SearchRestaurant.fromJson(Map<String, dynamic> json) =
      _$SearchRestaurantImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get logo;
  @override
  SearchRating? get rating;

  /// Create a copy of SearchRestaurant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchRestaurantImplCopyWith<_$SearchRestaurantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchRating _$SearchRatingFromJson(Map<String, dynamic> json) {
  return _SearchRating.fromJson(json);
}

/// @nodoc
mixin _$SearchRating {
  double? get avg => throw _privateConstructorUsedError;
  @JsonKey(name: 'count')
  int get count => throw _privateConstructorUsedError;

  /// Serializes this SearchRating to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchRating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchRatingCopyWith<SearchRating> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchRatingCopyWith<$Res> {
  factory $SearchRatingCopyWith(
          SearchRating value, $Res Function(SearchRating) then) =
      _$SearchRatingCopyWithImpl<$Res, SearchRating>;
  @useResult
  $Res call({double? avg, @JsonKey(name: 'count') int count});
}

/// @nodoc
class _$SearchRatingCopyWithImpl<$Res, $Val extends SearchRating>
    implements $SearchRatingCopyWith<$Res> {
  _$SearchRatingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchRating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avg = freezed,
    Object? count = null,
  }) {
    return _then(_value.copyWith(
      avg: freezed == avg
          ? _value.avg
          : avg // ignore: cast_nullable_to_non_nullable
              as double?,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchRatingImplCopyWith<$Res>
    implements $SearchRatingCopyWith<$Res> {
  factory _$$SearchRatingImplCopyWith(
          _$SearchRatingImpl value, $Res Function(_$SearchRatingImpl) then) =
      __$$SearchRatingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double? avg, @JsonKey(name: 'count') int count});
}

/// @nodoc
class __$$SearchRatingImplCopyWithImpl<$Res>
    extends _$SearchRatingCopyWithImpl<$Res, _$SearchRatingImpl>
    implements _$$SearchRatingImplCopyWith<$Res> {
  __$$SearchRatingImplCopyWithImpl(
      _$SearchRatingImpl _value, $Res Function(_$SearchRatingImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchRating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avg = freezed,
    Object? count = null,
  }) {
    return _then(_$SearchRatingImpl(
      avg: freezed == avg
          ? _value.avg
          : avg // ignore: cast_nullable_to_non_nullable
              as double?,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchRatingImpl implements _SearchRating {
  const _$SearchRatingImpl({this.avg, @JsonKey(name: 'count') this.count = 0});

  factory _$SearchRatingImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchRatingImplFromJson(json);

  @override
  final double? avg;
  @override
  @JsonKey(name: 'count')
  final int count;

  @override
  String toString() {
    return 'SearchRating(avg: $avg, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchRatingImpl &&
            (identical(other.avg, avg) || other.avg == avg) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, avg, count);

  /// Create a copy of SearchRating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchRatingImplCopyWith<_$SearchRatingImpl> get copyWith =>
      __$$SearchRatingImplCopyWithImpl<_$SearchRatingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchRatingImplToJson(
      this,
    );
  }
}

abstract class _SearchRating implements SearchRating {
  const factory _SearchRating(
      {final double? avg,
      @JsonKey(name: 'count') final int count}) = _$SearchRatingImpl;

  factory _SearchRating.fromJson(Map<String, dynamic> json) =
      _$SearchRatingImpl.fromJson;

  @override
  double? get avg;
  @override
  @JsonKey(name: 'count')
  int get count;

  /// Create a copy of SearchRating
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchRatingImplCopyWith<_$SearchRatingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchItem _$SearchItemFromJson(Map<String, dynamic> json) {
  return _SearchItem.fromJson(json);
}

/// @nodoc
mixin _$SearchItem {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'base_price')
  String get basePrice => throw _privateConstructorUsedError;
  SearchItemNames get names => throw _privateConstructorUsedError;
  @JsonKey(name: 'orders_count')
  int get ordersCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this SearchItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchItemCopyWith<SearchItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchItemCopyWith<$Res> {
  factory $SearchItemCopyWith(
          SearchItem value, $Res Function(SearchItem) then) =
      _$SearchItemCopyWithImpl<$Res, SearchItem>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'base_price') String basePrice,
      SearchItemNames names,
      @JsonKey(name: 'orders_count') int ordersCount,
      @JsonKey(name: 'image_url') String? imageUrl});

  $SearchItemNamesCopyWith<$Res> get names;
}

/// @nodoc
class _$SearchItemCopyWithImpl<$Res, $Val extends SearchItem>
    implements $SearchItemCopyWith<$Res> {
  _$SearchItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? basePrice = null,
    Object? names = null,
    Object? ordersCount = null,
    Object? imageUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      basePrice: null == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as String,
      names: null == names
          ? _value.names
          : names // ignore: cast_nullable_to_non_nullable
              as SearchItemNames,
      ordersCount: null == ordersCount
          ? _value.ordersCount
          : ordersCount // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of SearchItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SearchItemNamesCopyWith<$Res> get names {
    return $SearchItemNamesCopyWith<$Res>(_value.names, (value) {
      return _then(_value.copyWith(names: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SearchItemImplCopyWith<$Res>
    implements $SearchItemCopyWith<$Res> {
  factory _$$SearchItemImplCopyWith(
          _$SearchItemImpl value, $Res Function(_$SearchItemImpl) then) =
      __$$SearchItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'base_price') String basePrice,
      SearchItemNames names,
      @JsonKey(name: 'orders_count') int ordersCount,
      @JsonKey(name: 'image_url') String? imageUrl});

  @override
  $SearchItemNamesCopyWith<$Res> get names;
}

/// @nodoc
class __$$SearchItemImplCopyWithImpl<$Res>
    extends _$SearchItemCopyWithImpl<$Res, _$SearchItemImpl>
    implements _$$SearchItemImplCopyWith<$Res> {
  __$$SearchItemImplCopyWithImpl(
      _$SearchItemImpl _value, $Res Function(_$SearchItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? basePrice = null,
    Object? names = null,
    Object? ordersCount = null,
    Object? imageUrl = freezed,
  }) {
    return _then(_$SearchItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      basePrice: null == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as String,
      names: null == names
          ? _value.names
          : names // ignore: cast_nullable_to_non_nullable
              as SearchItemNames,
      ordersCount: null == ordersCount
          ? _value.ordersCount
          : ordersCount // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchItemImpl implements _SearchItem {
  const _$SearchItemImpl(
      {required this.id,
      @JsonKey(name: 'base_price') required this.basePrice,
      required this.names,
      @JsonKey(name: 'orders_count') this.ordersCount = 0,
      @JsonKey(name: 'image_url') this.imageUrl});

  factory _$SearchItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchItemImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'base_price')
  final String basePrice;
  @override
  final SearchItemNames names;
  @override
  @JsonKey(name: 'orders_count')
  final int ordersCount;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @override
  String toString() {
    return 'SearchItem(id: $id, basePrice: $basePrice, names: $names, ordersCount: $ordersCount, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
            (identical(other.names, names) || other.names == names) &&
            (identical(other.ordersCount, ordersCount) ||
                other.ordersCount == ordersCount) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, basePrice, names, ordersCount, imageUrl);

  /// Create a copy of SearchItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchItemImplCopyWith<_$SearchItemImpl> get copyWith =>
      __$$SearchItemImplCopyWithImpl<_$SearchItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchItemImplToJson(
      this,
    );
  }
}

abstract class _SearchItem implements SearchItem {
  const factory _SearchItem(
      {required final int id,
      @JsonKey(name: 'base_price') required final String basePrice,
      required final SearchItemNames names,
      @JsonKey(name: 'orders_count') final int ordersCount,
      @JsonKey(name: 'image_url') final String? imageUrl}) = _$SearchItemImpl;

  factory _SearchItem.fromJson(Map<String, dynamic> json) =
      _$SearchItemImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'base_price')
  String get basePrice;
  @override
  SearchItemNames get names;
  @override
  @JsonKey(name: 'orders_count')
  int get ordersCount;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;

  /// Create a copy of SearchItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchItemImplCopyWith<_$SearchItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchItemNames _$SearchItemNamesFromJson(Map<String, dynamic> json) {
  return _SearchItemNames.fromJson(json);
}

/// @nodoc
mixin _$SearchItemNames {
  String get ar => throw _privateConstructorUsedError;
  String get en => throw _privateConstructorUsedError;

  /// Serializes this SearchItemNames to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchItemNames
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchItemNamesCopyWith<SearchItemNames> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchItemNamesCopyWith<$Res> {
  factory $SearchItemNamesCopyWith(
          SearchItemNames value, $Res Function(SearchItemNames) then) =
      _$SearchItemNamesCopyWithImpl<$Res, SearchItemNames>;
  @useResult
  $Res call({String ar, String en});
}

/// @nodoc
class _$SearchItemNamesCopyWithImpl<$Res, $Val extends SearchItemNames>
    implements $SearchItemNamesCopyWith<$Res> {
  _$SearchItemNamesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchItemNames
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ar = null,
    Object? en = null,
  }) {
    return _then(_value.copyWith(
      ar: null == ar
          ? _value.ar
          : ar // ignore: cast_nullable_to_non_nullable
              as String,
      en: null == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchItemNamesImplCopyWith<$Res>
    implements $SearchItemNamesCopyWith<$Res> {
  factory _$$SearchItemNamesImplCopyWith(_$SearchItemNamesImpl value,
          $Res Function(_$SearchItemNamesImpl) then) =
      __$$SearchItemNamesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String ar, String en});
}

/// @nodoc
class __$$SearchItemNamesImplCopyWithImpl<$Res>
    extends _$SearchItemNamesCopyWithImpl<$Res, _$SearchItemNamesImpl>
    implements _$$SearchItemNamesImplCopyWith<$Res> {
  __$$SearchItemNamesImplCopyWithImpl(
      _$SearchItemNamesImpl _value, $Res Function(_$SearchItemNamesImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchItemNames
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ar = null,
    Object? en = null,
  }) {
    return _then(_$SearchItemNamesImpl(
      ar: null == ar
          ? _value.ar
          : ar // ignore: cast_nullable_to_non_nullable
              as String,
      en: null == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchItemNamesImpl implements _SearchItemNames {
  const _$SearchItemNamesImpl({this.ar = '', this.en = ''});

  factory _$SearchItemNamesImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchItemNamesImplFromJson(json);

  @override
  @JsonKey()
  final String ar;
  @override
  @JsonKey()
  final String en;

  @override
  String toString() {
    return 'SearchItemNames(ar: $ar, en: $en)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchItemNamesImpl &&
            (identical(other.ar, ar) || other.ar == ar) &&
            (identical(other.en, en) || other.en == en));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, ar, en);

  /// Create a copy of SearchItemNames
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchItemNamesImplCopyWith<_$SearchItemNamesImpl> get copyWith =>
      __$$SearchItemNamesImplCopyWithImpl<_$SearchItemNamesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchItemNamesImplToJson(
      this,
    );
  }
}

abstract class _SearchItemNames implements SearchItemNames {
  const factory _SearchItemNames({final String ar, final String en}) =
      _$SearchItemNamesImpl;

  factory _SearchItemNames.fromJson(Map<String, dynamic> json) =
      _$SearchItemNamesImpl.fromJson;

  @override
  String get ar;
  @override
  String get en;

  /// Create a copy of SearchItemNames
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchItemNamesImplCopyWith<_$SearchItemNamesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

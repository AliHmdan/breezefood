// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CartState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message) addedSuccess,
    required TResult Function(
            CartResponse cart, Set<int> updatingIds, String? toast)
        cartLoaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message)? addedSuccess,
    TResult? Function(CartResponse cart, Set<int> updatingIds, String? toast)?
        cartLoaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message)? addedSuccess,
    TResult Function(CartResponse cart, Set<int> updatingIds, String? toast)?
        cartLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_AddedSuccess value) addedSuccess,
    required TResult Function(_CartLoaded value) cartLoaded,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_AddedSuccess value)? addedSuccess,
    TResult? Function(_CartLoaded value)? cartLoaded,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_AddedSuccess value)? addedSuccess,
    TResult Function(_CartLoaded value)? cartLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartStateCopyWith<$Res> {
  factory $CartStateCopyWith(CartState value, $Res Function(CartState) then) =
      _$CartStateCopyWithImpl<$Res, CartState>;
}

/// @nodoc
class _$CartStateCopyWithImpl<$Res, $Val extends CartState>
    implements $CartStateCopyWith<$Res> {
  _$CartStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$CartStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'CartState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message) addedSuccess,
    required TResult Function(
            CartResponse cart, Set<int> updatingIds, String? toast)
        cartLoaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message)? addedSuccess,
    TResult? Function(CartResponse cart, Set<int> updatingIds, String? toast)?
        cartLoaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message)? addedSuccess,
    TResult Function(CartResponse cart, Set<int> updatingIds, String? toast)?
        cartLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_AddedSuccess value) addedSuccess,
    required TResult Function(_CartLoaded value) cartLoaded,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_AddedSuccess value)? addedSuccess,
    TResult? Function(_CartLoaded value)? cartLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_AddedSuccess value)? addedSuccess,
    TResult Function(_CartLoaded value)? cartLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements CartState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$CartStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'CartState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message) addedSuccess,
    required TResult Function(
            CartResponse cart, Set<int> updatingIds, String? toast)
        cartLoaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message)? addedSuccess,
    TResult? Function(CartResponse cart, Set<int> updatingIds, String? toast)?
        cartLoaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message)? addedSuccess,
    TResult Function(CartResponse cart, Set<int> updatingIds, String? toast)?
        cartLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_AddedSuccess value) addedSuccess,
    required TResult Function(_CartLoaded value) cartLoaded,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_AddedSuccess value)? addedSuccess,
    TResult? Function(_CartLoaded value)? cartLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_AddedSuccess value)? addedSuccess,
    TResult Function(_CartLoaded value)? cartLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements CartState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$AddedSuccessImplCopyWith<$Res> {
  factory _$$AddedSuccessImplCopyWith(
          _$AddedSuccessImpl value, $Res Function(_$AddedSuccessImpl) then) =
      __$$AddedSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$AddedSuccessImplCopyWithImpl<$Res>
    extends _$CartStateCopyWithImpl<$Res, _$AddedSuccessImpl>
    implements _$$AddedSuccessImplCopyWith<$Res> {
  __$$AddedSuccessImplCopyWithImpl(
      _$AddedSuccessImpl _value, $Res Function(_$AddedSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$AddedSuccessImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AddedSuccessImpl implements _AddedSuccess {
  const _$AddedSuccessImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'CartState.addedSuccess(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddedSuccessImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddedSuccessImplCopyWith<_$AddedSuccessImpl> get copyWith =>
      __$$AddedSuccessImplCopyWithImpl<_$AddedSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message) addedSuccess,
    required TResult Function(
            CartResponse cart, Set<int> updatingIds, String? toast)
        cartLoaded,
    required TResult Function(String message) error,
  }) {
    return addedSuccess(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message)? addedSuccess,
    TResult? Function(CartResponse cart, Set<int> updatingIds, String? toast)?
        cartLoaded,
    TResult? Function(String message)? error,
  }) {
    return addedSuccess?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message)? addedSuccess,
    TResult Function(CartResponse cart, Set<int> updatingIds, String? toast)?
        cartLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (addedSuccess != null) {
      return addedSuccess(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_AddedSuccess value) addedSuccess,
    required TResult Function(_CartLoaded value) cartLoaded,
    required TResult Function(_Error value) error,
  }) {
    return addedSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_AddedSuccess value)? addedSuccess,
    TResult? Function(_CartLoaded value)? cartLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return addedSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_AddedSuccess value)? addedSuccess,
    TResult Function(_CartLoaded value)? cartLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (addedSuccess != null) {
      return addedSuccess(this);
    }
    return orElse();
  }
}

abstract class _AddedSuccess implements CartState {
  const factory _AddedSuccess({required final String message}) =
      _$AddedSuccessImpl;

  String get message;

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddedSuccessImplCopyWith<_$AddedSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CartLoadedImplCopyWith<$Res> {
  factory _$$CartLoadedImplCopyWith(
          _$CartLoadedImpl value, $Res Function(_$CartLoadedImpl) then) =
      __$$CartLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CartResponse cart, Set<int> updatingIds, String? toast});
}

/// @nodoc
class __$$CartLoadedImplCopyWithImpl<$Res>
    extends _$CartStateCopyWithImpl<$Res, _$CartLoadedImpl>
    implements _$$CartLoadedImplCopyWith<$Res> {
  __$$CartLoadedImplCopyWithImpl(
      _$CartLoadedImpl _value, $Res Function(_$CartLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cart = null,
    Object? updatingIds = null,
    Object? toast = freezed,
  }) {
    return _then(_$CartLoadedImpl(
      cart: null == cart
          ? _value.cart
          : cart // ignore: cast_nullable_to_non_nullable
              as CartResponse,
      updatingIds: null == updatingIds
          ? _value._updatingIds
          : updatingIds // ignore: cast_nullable_to_non_nullable
              as Set<int>,
      toast: freezed == toast
          ? _value.toast
          : toast // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CartLoadedImpl implements _CartLoaded {
  const _$CartLoadedImpl(
      {required this.cart,
      final Set<int> updatingIds = const <int>{},
      this.toast})
      : _updatingIds = updatingIds;

  @override
  final CartResponse cart;
  final Set<int> _updatingIds;
  @override
  @JsonKey()
  Set<int> get updatingIds {
    if (_updatingIds is EqualUnmodifiableSetView) return _updatingIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_updatingIds);
  }

// ✅ includes delete/update qty
  @override
  final String? toast;

  @override
  String toString() {
    return 'CartState.cartLoaded(cart: $cart, updatingIds: $updatingIds, toast: $toast)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartLoadedImpl &&
            (identical(other.cart, cart) || other.cart == cart) &&
            const DeepCollectionEquality()
                .equals(other._updatingIds, _updatingIds) &&
            (identical(other.toast, toast) || other.toast == toast));
  }

  @override
  int get hashCode => Object.hash(runtimeType, cart,
      const DeepCollectionEquality().hash(_updatingIds), toast);

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartLoadedImplCopyWith<_$CartLoadedImpl> get copyWith =>
      __$$CartLoadedImplCopyWithImpl<_$CartLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message) addedSuccess,
    required TResult Function(
            CartResponse cart, Set<int> updatingIds, String? toast)
        cartLoaded,
    required TResult Function(String message) error,
  }) {
    return cartLoaded(cart, updatingIds, toast);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message)? addedSuccess,
    TResult? Function(CartResponse cart, Set<int> updatingIds, String? toast)?
        cartLoaded,
    TResult? Function(String message)? error,
  }) {
    return cartLoaded?.call(cart, updatingIds, toast);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message)? addedSuccess,
    TResult Function(CartResponse cart, Set<int> updatingIds, String? toast)?
        cartLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (cartLoaded != null) {
      return cartLoaded(cart, updatingIds, toast);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_AddedSuccess value) addedSuccess,
    required TResult Function(_CartLoaded value) cartLoaded,
    required TResult Function(_Error value) error,
  }) {
    return cartLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_AddedSuccess value)? addedSuccess,
    TResult? Function(_CartLoaded value)? cartLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return cartLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_AddedSuccess value)? addedSuccess,
    TResult Function(_CartLoaded value)? cartLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (cartLoaded != null) {
      return cartLoaded(this);
    }
    return orElse();
  }
}

abstract class _CartLoaded implements CartState {
  const factory _CartLoaded(
      {required final CartResponse cart,
      final Set<int> updatingIds,
      final String? toast}) = _$CartLoadedImpl;

  CartResponse get cart;
  Set<int> get updatingIds; // ✅ includes delete/update qty
  String? get toast;

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartLoadedImplCopyWith<_$CartLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$CartStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'CartState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String message) addedSuccess,
    required TResult Function(
            CartResponse cart, Set<int> updatingIds, String? toast)
        cartLoaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String message)? addedSuccess,
    TResult? Function(CartResponse cart, Set<int> updatingIds, String? toast)?
        cartLoaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String message)? addedSuccess,
    TResult Function(CartResponse cart, Set<int> updatingIds, String? toast)?
        cartLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_AddedSuccess value) addedSuccess,
    required TResult Function(_CartLoaded value) cartLoaded,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_AddedSuccess value)? addedSuccess,
    TResult? Function(_CartLoaded value)? cartLoaded,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_AddedSuccess value)? addedSuccess,
    TResult Function(_CartLoaded value)? cartLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements CartState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of CartState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

part of 'cart_cubit.dart';

@freezed
class CartState with _$CartState {
  const factory CartState.initial() = _Initial;
  const factory CartState.loading() = _Loading;

  const factory CartState.addedSuccess({required String message}) = _AddedSuccess;

  const factory CartState.cartLoaded({
    required CartResponse cart,
    @Default(<int>{}) Set<int> updatingIds, // ✅ includes delete/update qty
    String? toast,
  }) = _CartLoaded;

  const factory CartState.error(String message) = _Error;
}

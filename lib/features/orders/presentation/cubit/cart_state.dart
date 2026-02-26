part of 'cart_cubit.dart';

@freezed
class CartState with _$CartState {
  const factory CartState.initial() = _Initial;

  /// تستخدمها فقط لما ما عندك بيانات سابقة
  const factory CartState.loading() = _Loading;

  const factory CartState.error(String message) = _Error;
  const factory CartState.addingToCart() = _AddingToCart; // ✅ مهم
  /// عمليات add
  // const factory CartState.addingToCart() = _AddingToCart;
  const factory CartState.addedSuccess({required String message}) = _AddedSuccess;

  /// الحالة الأساسية اللي لازم تضل موجودة طول الوقت
  const factory CartState.cartLoaded({
    required CartResponse cart,
    required Set<int> updatingIds,
    String? toast,
    @Default(false) bool isRefreshing,
  }) = _CartLoaded;
}
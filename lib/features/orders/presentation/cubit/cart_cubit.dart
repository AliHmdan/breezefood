import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:breezefood/features/orders/model/add_to_cart_request.dart';
import 'package:breezefood/features/orders/data/repo/cart_repository.dart';
import 'package:breezefood/features/orders/model/cart_response.dart';

part 'cart_state.dart';
part 'cart_cubit.freezed.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository repo;
  CartCubit(this.repo) : super(const CartState.initial());

  Future<void> add(AddToCartRequest req) async {
    emit(const CartState.loading());

    final res = await repo.addToCart(req);

    if (!res.ok) {
      emit(CartState.error(res.message ?? "فشل إضافة المنتج للسلة"));
      return;
    }

    final data = (res.data as Map?)?.cast<String, dynamic>() ?? {};
    final msg = (data["message"]?.toString().trim().isNotEmpty ?? false)
        ? data["message"].toString()
        : "Added to cart";

    emit(CartState.addedSuccess(message: msg));
  }

  Future<void> loadCart() async {
    emit(const CartState.loading());

    final res = await repo.getCart();
    if (!res.ok) {
      emit(CartState.error(res.message ?? "فشل تحميل السلة"));
      return;
    }

    final map = (res.data as Map?)?.cast<String, dynamic>() ?? {};
    final cart = CartResponse.fromJson(map);

    emit(CartState.cartLoaded(cart: cart, updatingIds: <int>{}, toast: null));
  }

  // Helper: ensure we are in loaded state
  _CartLoaded? _loaded() => state is _CartLoaded ? state as _CartLoaded : null;

  void _emitLoadedPatch({
    required _CartLoaded st,
    CartResponse? cart,
    Set<int>? updatingIds,
    String? toast,
  }) {
    emit(
      st.copyWith(
        cart: cart ?? st.cart,
        updatingIds: updatingIds ?? st.updatingIds,
        toast: toast,
      ),
    );
  }

  // ===========================================================
  // ✅ Update Qty
  // - optimistic: update item qty + item total only (UI)
  // - DO NOT recompute totals (server is the source of truth)
  // - after success: reload cart
  // ===========================================================
  Future<void> updateQty({
    required int cartItemId,
    required int quantity,
  }) async {
    final st0 = _loaded();
    if (st0 == null) return;
    if (quantity < 1) return;

    final prevCart = st0.cart;

    final idx = prevCart.items.indexWhere((e) => e.id == cartItemId);
    if (idx == -1) return;

    final oldItem = prevCart.items[idx];
    final oldQty = oldItem.quantity;

    // ✅ Optimistic patch: just update qty + line total (for better UI)
    // extrasTotal in your API is already total extras for the item row.
    final optimisticTotal =
        (oldItem.unitPrice * quantity) + oldItem.extrasTotal;

    final optimisticItem = CartItem(
      id: oldItem.id,
      menuItemId: oldItem.menuItemId,
      nameAr: oldItem.nameAr,
      nameEn: oldItem.nameEn,
      quantity: quantity,
      withSpicy: oldItem.withSpicy,
      specialNotes: oldItem.specialNotes,
      priceBefore: oldItem.priceBefore,
      priceAfter: oldItem.priceAfter,
      discountPercent: oldItem.discountPercent,
      discountType: oldItem.discountType,
      extrasTotal: oldItem.extrasTotal,
      totalPrice: optimisticTotal,
      image: oldItem.image,
      deliveryTime: oldItem.deliveryTime,
      extras: oldItem.extras,
    );

    final newItems = [...prevCart.items];
    newItems[idx] = optimisticItem;

    // ✅ IMPORTANT: do NOT change totals (itemsTotalAfter/grandAfter)
    final optimisticCart = prevCart.copyWith(items: newItems);

    _emitLoadedPatch(
      st: st0,
      cart: optimisticCart,
      updatingIds: {...st0.updatingIds, cartItemId},
      toast: null,
    );

    final res = await repo.updateQty(
      cartItemId: cartItemId,
      quantity: quantity,
    );

    final st1 = _loaded();
    if (st1 == null) return;

    if (!res.ok) {
      // rollback just item list
      final rollbackItems = [...prevCart.items];
      rollbackItems[idx] = oldItem.copyWith(
        quantity: oldQty,
        totalPrice: oldItem.totalPrice,
      );

      _emitLoadedPatch(
        st: st1,
        cart: prevCart.copyWith(items: rollbackItems),
        updatingIds: {...st1.updatingIds}..remove(cartItemId),
        toast: res.message ?? "فشل تحديث الكمية",
      );
      return;
    }

    // remove updating flag
    _emitLoadedPatch(
      st: st1,
      updatingIds: {...st1.updatingIds}..remove(cartItemId),
      toast: null,
    );

    // ✅ reload from server to get exact pricing/discounts/grand_total
    await loadCart();
  }

  // ===========================================================
  // ✅ Remove Item
  // - optimistic: remove item row only
  // - DO NOT recompute totals
  // - after success: reload cart
  // ===========================================================
  Future<void> removeItem(int cartItemId) async {
    final st0 = _loaded();
    if (st0 == null) return;

    final prevCart = st0.cart;

    final idx = prevCart.items.indexWhere((e) => e.id == cartItemId);
    if (idx == -1) return;

    final removedItem = prevCart.items[idx];

    // optimistic remove from list only
    final newItems = [...prevCart.items]..removeAt(idx);
    final optimisticCart = prevCart.copyWith(items: newItems);

    _emitLoadedPatch(
      st: st0,
      cart: optimisticCart,
      updatingIds: {...st0.updatingIds, cartItemId},
      toast: null,
    );

    final res = await repo.removeItem(cartItemId: cartItemId);

    final st1 = _loaded();
    if (st1 == null) return;

    if (!res.ok) {
      // rollback
      final rollbackItems = [...optimisticCart.items]..insert(idx, removedItem);

      _emitLoadedPatch(
        st: st1,
        cart: prevCart.copyWith(items: rollbackItems),
        updatingIds: {...st1.updatingIds}..remove(cartItemId),
        toast: res.message ?? "فشل حذف العنصر",
      );
      return;
    }

    _emitLoadedPatch(
      st: st1,
      updatingIds: {...st1.updatingIds}..remove(cartItemId),
      toast: null,
    );

    // reload server totals
    await loadCart();
  }
}

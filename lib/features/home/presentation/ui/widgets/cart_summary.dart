class CartSummary {
  final int count;
  final double total;
  final bool hasCart;

  const CartSummary({
    required this.count,
    required this.total,
  }) : hasCart = count > 0;

  static const empty = CartSummary(count: 0, total: 0.0);

  /// Extract count + total from cart object (Map أو Model)
  static CartSummary from(dynamic cart) {
    if (cart == null) return empty;

    final count = _extractCount(cart);
    final total = _extractTotal(cart);

    return CartSummary(
      count: count,
      total: total,
    );
  }

  static double _extractTotal(dynamic cart) {
    // Map
    if (cart is Map) {
      const keys = [
        // new/common
        "grand_after",
        "grandAfter",
        "items_total_after",
        "itemsTotalAfter",

        // legacy/common
        "total",
        "total_price",
        "totalPrice",
        "grand_total",
        "grandTotal",
        "subtotal",
        "sub_total",
        "subTotal",
        "amount",
      ];

      for (final k in keys) {
        final n = _toNum(cart[k]);
        if (n != null) return n.toDouble();
      }
    }

    // Model
    final candidates = [
      () => (cart as dynamic).grandAfter,
      () => (cart as dynamic).itemsTotalAfter,
      () => (cart as dynamic).total,
      () => (cart as dynamic).totalPrice,
      () => (cart as dynamic).grandTotal,
      () => (cart as dynamic).subTotal,
    ];

    for (final get in candidates) {
      try {
        final n = _toNum(get());
        if (n != null) return n.toDouble();
      } catch (_) {}
    }

    return 0.0;
  }

  static int _extractCount(dynamic cart) {
    // Map
    if (cart is Map) {
      final items = cart["items"] ?? cart["data"] ?? cart["cart_items"];
      if (items is List) return items.length;

      final count = cart["count"] ?? cart["items_count"] ?? cart["itemsCount"];
      final n = _toNum(count);
      if (n != null) return n.toInt();
    }

    // Model
    try {
      final items = (cart as dynamic).items;
      if (items is List) return items.length;
    } catch (_) {}

    final candidates = [
      () => (cart as dynamic).count,
      () => (cart as dynamic).itemsCount,
    ];

    for (final get in candidates) {
      try {
        final n = _toNum(get());
        if (n != null) return n.toInt();
      } catch (_) {}
    }

    return 0;
  }

  static num? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;

    final s = v.toString().trim();
    if (s.isEmpty) return null;

    // يشيل أي رمز عملة أو فاصلة أو نص
    final cleaned = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    return num.tryParse(cleaned);
  }
}

import 'package:breezefood/features/orders/model/cart_response.dart';

class CartSummary {
  final int count;      // sum(quantity)
  final double total;   // grand total
  final bool hasCart;

  const CartSummary({
    required this.count,
    required this.total,
  }) : hasCart = count > 0;

  static const empty = CartSummary(count: 0, total: 0.0);

  static CartSummary from(dynamic cart) {
    if (cart == null) return empty;

    // ✅ 1) إذا Model CartResponse
    if (cart is CartResponse) {
      final c = _countFromCartResponse(cart);
      final t = _totalFromCartResponse(cart);
      return CartSummary(count: c, total: t);
    }

    // ✅ 2) إذا Map (لو رجعت لهالمود لاحقاً)
    if (cart is Map) {
      final c = _countFromMap(cart);
      final t = _totalFromMap(cart);
      return CartSummary(count: c, total: t);
    }

    // ✅ 3) أي شي غريب -> حاول dynamic بشكل آمن
    try {
      final c = _countFromDynamic(cart);
      final t = _totalFromDynamic(cart);
      return CartSummary(count: c, total: t);
    } catch (_) {
      return empty;
    }
  }

  // =========================
  // CartResponse (MODEL)
  // =========================
  static int _countFromCartResponse(CartResponse cart) {
    int sum = 0;

    for (final it in cart.items) {
      final q = (it.quantity <= 0) ? 1 : it.quantity;
      sum += q;
    }

    // إذا عندك appetizers بالـ model (حسب مشروعك)
    try {
      final apps = (cart as dynamic).appetizers;
      if (apps is List) {
        for (final a in apps) {
          final q = _toNum((a as dynamic).quantity) ?? 1;
          sum += q.toInt();
        }
      }
    } catch (_) {}

    return sum;
  }

  static double _totalFromCartResponse(CartResponse cart) {
    // ✅ الأفضل عندك (حسب optimistic patch): grandAfter
    try {
      final n = _toNum((cart as dynamic).grandAfter);
      if (n != null && n > 0) return n.toDouble();
    } catch (_) {}

    // ✅ fallback: itemsTotalAfter + deliveryAfter
    try {
      final itemsAfter = _toNum((cart as dynamic).itemsTotalAfter) ?? 0;
      final deliveryAfter = _toNum((cart as dynamic).deliveryAfter) ?? 0;
      final sum = itemsAfter + deliveryAfter;
      if (sum > 0) return sum.toDouble();
    } catch (_) {}

    // ✅ fallback: جمع totalPrice من العناصر
    double sum = 0;
    for (final it in cart.items) {
      final n = _toNum(it.totalPrice);
      if (n != null) sum += n.toDouble();
    }
    if (sum > 0) return sum;

    // ✅ fallback أخير: priceAfter * qty
    sum = 0;
    for (final it in cart.items) {
      final unit = _toNum(it.priceAfter) ?? _toNum(it.unitPrice) ?? 0;
      final q = (it.quantity <= 0) ? 1 : it.quantity;
      sum += unit.toDouble() * q;
    }
    return sum;
  }

  // =========================
  // MAP (API RAW)
  // =========================
  static int _countFromMap(Map cart) {
    int sum = 0;

    sum += _sumQtyFromList(cart["items"]);
    sum += _sumQtyFromList(cart["appetizers"]);

    if (sum > 0) return sum;

    final data = cart["data"];
    if (data is Map) {
      sum += _sumQtyFromList(data["items"]);
      sum += _sumQtyFromList(data["appetizers"]);
    }

    if (sum > 0) return sum;

    final n = _toNum(cart["count"] ?? cart["items_count"] ?? cart["itemsCount"]);
    return n?.toInt() ?? 0;
  }

  static double _totalFromMap(Map cart) {
    final n1 = _readMapNum(cart, ["order_pricing", "grand_total_after"]);
    if (n1 != null) return n1.toDouble();

    final n2 = _readMapNum(cart, ["order_pricing", "items_total_after"]);
    if (n2 != null) return n2.toDouble();

    double sum = 0;
    sum += _sumTotalsFromList(cart["items"]);
    sum += _sumTotalsFromList(cart["appetizers"]);
    return sum;
  }

  // =========================
  // dynamic fallback
  // =========================
  static int _countFromDynamic(dynamic cart) {
    int sum = 0;
    try {
      final items = (cart as dynamic).items;
      if (items is List) {
        for (final it in items) {
          final q = _toNum((it as dynamic).quantity) ?? 1;
          sum += q.toInt();
        }
      }
    } catch (_) {}
    return sum;
  }

  static double _totalFromDynamic(dynamic cart) {
    try {
      final n = _toNum((cart as dynamic).grandAfter);
      if (n != null && n > 0) return n.toDouble();
    } catch (_) {}

    try {
      final n = _toNum((cart as dynamic).total);
      if (n != null && n > 0) return n.toDouble();
    } catch (_) {}

    return 0.0;
  }

  // ================= Helpers =================
  static int _sumQtyFromList(dynamic list) {
    if (list is! List) return 0;
    int sum = 0;

    for (final it in list) {
      if (it is Map) {
        final q = _toNum(it["quantity"]) ?? 1;
        sum += q.toInt();
      } else {
        try {
          final q = _toNum((it as dynamic).quantity) ?? 1;
          sum += q.toInt();
        } catch (_) {
          sum += 1;
        }
      }
    }
    return sum;
  }

  static double _sumTotalsFromList(dynamic list) {
    if (list is! List) return 0.0;
    double sum = 0;

    for (final it in list) {
      if (it is Map) {
        final n = _toNum(it["total_price"] ?? it["price_after"] ?? it["priceAfter"]);
        if (n != null) sum += n.toDouble();
      } else {
        try {
          final n = _toNum((it as dynamic).totalPrice ??
              (it as dynamic).total_price ??
              (it as dynamic).priceAfter ??
              (it as dynamic).price_after);
          if (n != null) sum += n.toDouble();
        } catch (_) {}
      }
    }

    return sum;
  }

  static num? _readMapNum(Map m, List<String> path) {
    dynamic cur = m;
    for (final k in path) {
      if (cur is Map && cur.containsKey(k)) {
        cur = cur[k];
      } else {
        return null;
      }
    }
    return _toNum(cur);
  }

  static num? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    final cleaned = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    return num.tryParse(cleaned);
  }
}

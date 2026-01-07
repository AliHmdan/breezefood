import 'package:breezefood/core/services/translation_model.dart'
    show TranslationModel;

class CartResponse {
  final int orderId;
  final String orderStatus;

  final int restaurantId;
  final String restaurantName;
  final String restaurantLogo;
  final CartPrimaryAddress? primaryAddress;
  final List<CartUserAddress> addresses;
  final List<CartItem> items;

  // pricing
  final double itemsTotalBefore;
  final double itemsTotalAfter;
  final double itemsDiscount;

  final double deliveryBefore;
  final double deliveryAfter;
  final double deliveryDiscount;

  final double grandBefore;
  final double grandAfter;

  CartResponse({
    required this.primaryAddress,
    required this.addresses,
    required this.orderId,
    required this.orderStatus,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantLogo,
    required this.items,
    required this.itemsTotalBefore,
    required this.itemsTotalAfter,
    required this.itemsDiscount,
    required this.deliveryBefore,
    required this.deliveryAfter,
    required this.deliveryDiscount,
    required this.grandBefore,
    required this.grandAfter,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final primaryJson = (json["primary_address"] as Map?)
        ?.cast<String, dynamic>();
    final primary = primaryJson == null
        ? null
        : CartPrimaryAddress.fromJson(primaryJson);

    final addressesJson = (json["addresses"] as List? ?? const []);
    final addresses = addressesJson
        .where((e) => e is Map)
        .map(
          (e) => CartUserAddress.fromJson((e as Map).cast<String, dynamic>()),
        )
        .toList();
    final itemsJson = (json["items"] as List? ?? const []);
    final items = itemsJson
        .where((e) => e is Map)
        .map((e) => CartItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    final order = (json["order"] as Map?)?.cast<String, dynamic>() ?? {};
    final restaurant =
        (json["restaurant"] as Map?)?.cast<String, dynamic>() ?? {};
    final pricing =
        (json["order_pricing"] as Map?)?.cast<String, dynamic>() ?? {};

    return CartResponse(
      primaryAddress: primary,
      addresses: addresses,
      orderId: _toInt(order["id"]),
      orderStatus: (order["status"] ?? "").toString(),

      restaurantId: _toInt(restaurant["id"]),
      restaurantName: (restaurant["name"] ?? "My Cart").toString(),
      restaurantLogo: (restaurant["logo"] ?? "").toString(),

      items: items,

      itemsTotalBefore: _toDouble(pricing["items_total_before"]),
      itemsTotalAfter: _toDouble(pricing["items_total_after"]),
      itemsDiscount: _toDouble(pricing["items_discount"]),

      deliveryBefore: _toDouble(pricing["delivery_fee_before"]),
      deliveryAfter: _toDouble(pricing["delivery_fee_after"]),
      deliveryDiscount: _toDouble(pricing["delivery_discount"]),

      grandBefore: _toDouble(pricing["grand_total_before"]),
      grandAfter: _toDouble(pricing["grand_total_after"]),
    );
  }
  CartUserAddress? get defaultAddress {
    if (addresses.isEmpty) return null;
    return addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => addresses.first,
    );
  }

  // Convenience getters
  double get itemsTotal => itemsTotalAfter;
  double get deliveryFee => deliveryAfter;
  double get grandTotal => grandAfter;

  bool get hasAnyDiscount =>
      (itemsTotalBefore > itemsTotalAfter) || (deliveryBefore > deliveryAfter);

      CartResponse copyWith({
  int? orderId,
  String? orderStatus,
  int? restaurantId,
  String? restaurantName,
  String? restaurantLogo,
  List<CartItem>? items,
  double? itemsTotalBefore,
  double? itemsTotalAfter,
  double? itemsDiscount,
  double? deliveryBefore,
  double? deliveryAfter,
  double? deliveryDiscount,
  double? grandBefore,
  double? grandAfter,

  // ✅ لو عندك هالحقول (بعد التحديث اللي عملناه):
  CartPrimaryAddress? primaryAddress,
  List<CartUserAddress>? addresses,
}) {
  return CartResponse(
    orderId: orderId ?? this.orderId,
    orderStatus: orderStatus ?? this.orderStatus,
    restaurantId: restaurantId ?? this.restaurantId,
    restaurantName: restaurantName ?? this.restaurantName,
    restaurantLogo: restaurantLogo ?? this.restaurantLogo,
    items: items ?? this.items,
    itemsTotalBefore: itemsTotalBefore ?? this.itemsTotalBefore,
    itemsTotalAfter: itemsTotalAfter ?? this.itemsTotalAfter,
    itemsDiscount: itemsDiscount ?? this.itemsDiscount,
    deliveryBefore: deliveryBefore ?? this.deliveryBefore,
    deliveryAfter: deliveryAfter ?? this.deliveryAfter,
    deliveryDiscount: deliveryDiscount ?? this.deliveryDiscount,
    grandBefore: grandBefore ?? this.grandBefore,
    grandAfter: grandAfter ?? this.grandAfter,

    primaryAddress: primaryAddress ?? this.primaryAddress,
    addresses: addresses ?? this.addresses,
  );
}

}

class CartItem {
  final int id;
  final int menuItemId;

  final String nameAr;
  final String nameEn;

  final int quantity;
  final int withSpicy; // 0 / 1

  final double priceBefore;
  final double priceAfter;
  final int discountPercent;
  final String? discountType;

  final double extrasTotal;
  final double totalPrice;

  final String image;
  final int deliveryTime;

  final List<CartExtra> extras;

  CartItem({
    required this.id,
    required this.menuItemId,
    required this.nameAr,
    required this.nameEn,
    required this.quantity,
    required this.withSpicy,
    required this.priceBefore,
    required this.priceAfter,
    required this.discountPercent,
    required this.discountType,
    required this.extrasTotal,
    required this.totalPrice,
    required this.image,
    required this.deliveryTime,
    required this.extras,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final qty = _toInt(json["quantity"]);
    final before = _toDouble(json["price_before"]);
    final after = _toDouble(json["price_after"]);
    final unitPrice = after > 0 ? after : before;

    final extrasJson = (json["extras"] as List? ?? const []);
    final extras = extrasJson
        .where((e) => e is Map)
        .map((e) => CartExtra.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    final total = _toDouble(json["total_price"]);
    final safeTotal = total == 0
        ? (unitPrice * qty) + _toDouble(json["extras_total"])
        : total;

    return CartItem(
      id: _toInt(json["id"]),
      menuItemId: _toInt(json["menu_item_id"]),
      nameAr: (json["name_ar"] ?? "").toString(),
      nameEn: (json["name_en"] ?? "").toString(),
      quantity: qty,
      withSpicy: _toInt(json["with_Spicy"]),
      priceBefore: before,
      priceAfter: after > 0 ? after : before,
      discountPercent: _toInt(json["discount_percent"]),
      discountType: json["discount_type"]?.toString(),
      extrasTotal: _toDouble(json["extras_total"]),
      totalPrice: safeTotal,
      image: (json["image"] ?? "").toString(),
      deliveryTime: _toInt(json["delivery_time"]),
      extras: extras,
    );
  }

  // Helpers
  bool get isSpicy => withSpicy == 1;
  bool get hasDiscount => discountPercent > 0 || priceBefore > priceAfter;

  double get unitPrice => priceAfter > 0 ? priceAfter : priceBefore;
}

class CartExtra {
  final int id;
  final int extraId;
  final int quantity;
  final int withSpicy; // 0 / 1
  final double unitPrice;
  final double totalPrice;

  final TranslationModel? nameArObj;
  final TranslationModel? nameEnObj;

  CartExtra({
    required this.id,
    required this.extraId,
    required this.quantity,
    required this.withSpicy,
    required this.unitPrice,
    required this.totalPrice,
    this.nameArObj,
    this.nameEnObj,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory CartExtra.fromJson(Map<String, dynamic> json) {
    final ar = json["name_ar"];
    final en = json["name_en"];

    return CartExtra(
      id: _toInt(json["id"]),
      extraId: _toInt(json["extra_id"]),
      quantity: _toInt(json["quantity"]),
      withSpicy: _toInt(json["with_Spicy"]),
      unitPrice: _toDouble(json["unit_price"]),
      totalPrice: _toDouble(json["total_price"]),
      nameArObj: ar is Map
          ? TranslationModel.fromJson(ar.cast<String, dynamic>())
          : null,
      nameEnObj: en is Map
          ? TranslationModel.fromJson(en.cast<String, dynamic>())
          : null,
    );
  }

  bool get isSpicy => withSpicy == 1;
}

class CartPrimaryAddress {
  final String? address; // ممكن null حسب اللّوغ
  final double latitude;
  final double longitude;

  CartPrimaryAddress({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory CartPrimaryAddress.fromJson(Map<String, dynamic> json) {
    return CartPrimaryAddress(
      address: json["address"]?.toString(),
      latitude: _toDouble(json["latitude"]),
      longitude: _toDouble(json["longitude"]),
    );
  }
}

class CartUserAddress {
  final int id;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;

  CartUserAddress({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static bool _toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v == 1;
    final s = v.toString().toLowerCase();
    return s == "true" || s == "1";
  }

  factory CartUserAddress.fromJson(Map<String, dynamic> json) {
    return CartUserAddress(
      id: _toInt(json["id"]),
      address: (json["address"] ?? "").toString(),
      latitude: _toDouble(json["latitude"]),
      longitude: _toDouble(json["longitude"]),
      isDefault: _toBool(json["is_default"]),
    );
  }
}

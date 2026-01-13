class ActiveOrdersResponse {
  final List<OrderBundle> orders;

  ActiveOrdersResponse({required this.orders});

  factory ActiveOrdersResponse.fromJson(Map<String, dynamic> json) {
    final list = (json["orders"] as List? ?? const []);
    return ActiveOrdersResponse(
      orders: list
          .where((e) => e is Map)
          .map((e) => OrderBundle.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

class OrderBundle {
  final OrderInfo order;
  final OrderRestaurant restaurant;
  final List<OrderItem> items;

  OrderBundle({
    required this.order,
    required this.restaurant,
    required this.items,
  });

  factory OrderBundle.fromJson(Map<String, dynamic> json) {
    return OrderBundle(
      order: OrderInfo.fromJson((json["order"] as Map?)?.cast<String, dynamic>() ?? {}),
      restaurant: OrderRestaurant.fromJson((json["restaurant"] as Map?)?.cast<String, dynamic>() ?? {}),
      items: ((json["items"] as List?) ?? const [])
          .where((e) => e is Map)
          .map((e) => OrderItem.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

class OrderInfo {
  final int id;
  final String status;
  final double totalPrice;
  final double deliveryFee;
  final String paymentMethod;
  final String paymentStatus;
  final String? notes;
  final String createdAt;
  final int itemsCount;

  OrderInfo({
    required this.id,
    required this.status,
    required this.totalPrice,
    required this.deliveryFee,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.notes,
    required this.createdAt,
    required this.itemsCount,
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

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    return OrderInfo(
      id: _toInt(json["id"]),
      status: (json["status"] ?? "").toString(),
      totalPrice: _toDouble(json["total_price"]),
      deliveryFee: _toDouble(json["delivery_fee"]),
      paymentMethod: (json["payment_method"] ?? "").toString(),
      paymentStatus: (json["payment_status"] ?? "").toString(),
      notes: json["notes"]?.toString(),
      createdAt: (json["created_at"] ?? "").toString(),
      itemsCount: _toInt(json["items_count"]),
    );
  }
}

class OrderRestaurant {
  final int id;
  final String name;
  final String logo;

  OrderRestaurant({
    required this.id,
    required this.name,
    required this.logo,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory OrderRestaurant.fromJson(Map<String, dynamic> json) {
    return OrderRestaurant(
      id: _toInt(json["id"]),
      name: (json["name"] ?? "").toString(),
      logo: (json["logo"] ?? "").toString(),
    );
  }
}

class OrderItem {
  final int id;
  final int menuItemId;
  final String nameAr;
  final String nameEn;
  final int quantity;
  final double totalPrice;
  final String image;
  final int deliveryTime;

  OrderItem({
    required this.id,
    required this.menuItemId,
    required this.nameAr,
    required this.nameEn,
    required this.quantity,
    required this.totalPrice,
    required this.image,
    required this.deliveryTime,
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

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: _toInt(json["id"]),
      menuItemId: _toInt(json["menu_item_id"]),
      nameAr: (json["name_ar"] ?? "").toString(),
      nameEn: (json["name_en"] ?? "").toString(),
      quantity: _toInt(json["quantity"]),
      totalPrice: _toDouble(json["total_price"]),
      image: (json["image"] ?? "").toString(),
      deliveryTime: _toInt(json["delivery_time"]),
    );
  }

  String get title => nameAr.trim().isNotEmpty ? nameAr : nameEn;
}

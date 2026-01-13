class StoreOrderRequest {
  final int restaurantId;
  final String deliveryType;   // "pickup" | "delivery"
  final String paymentMethod;  // "cash"
  final String notes;
  final double deliveryFee;

  final OrderAddress address;
  final List<OrderItemRequest> items;
  final List<AppetizerRequest> appetizers;

  const StoreOrderRequest({
    required this.restaurantId,
    required this.deliveryType,
    required this.paymentMethod,
    this.notes = "",
    this.deliveryFee = 0,
    required this.address,
    required this.items,
    this.appetizers = const [],
  });

  Map<String, dynamic> toJson() => {
        "restaurant_id": restaurantId,
        "delivery_type": deliveryType,
        "payment_method": paymentMethod,
        "notes": notes,
        "delivery_fee": deliveryFee,
        "address": address.toJson(),
        "items": items.map((e) => e.toJson()).toList(),
        "appetizers": appetizers.map((e) => e.toJson()).toList(),
      };
}

class OrderAddress {
  final String text;
  final double latitude;
  final double longitude;

  const OrderAddress({
    required this.text,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        "text": text,
        "latitude": latitude,
        "longitude": longitude,
      };
}

class OrderItemRequest {
  final int menuItemId;
  final int quantity;
  final String specialNotes;
  final List<OrderExtraRequest> extras;

  const OrderItemRequest({
    required this.menuItemId,
    required this.quantity,
    this.specialNotes = "",
    this.extras = const [],
  });

  Map<String, dynamic> toJson() => {
        "menu_item_id": menuItemId,
        "quantity": quantity,
        "special_notes": specialNotes,
        "extras": extras.map((e) => e.toJson()).toList(),
      };
}

class OrderExtraRequest {
  final int extraId;
  final int quantity;

  const OrderExtraRequest({
    required this.extraId,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        "extra_id": extraId,
        "quantity": quantity,
      };
}

class AppetizerRequest {
  final int appetizerId;
  final int quantity;

  const AppetizerRequest({
    required this.appetizerId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        "appetizer_id": appetizerId,
        "quantity": quantity,
      };
}

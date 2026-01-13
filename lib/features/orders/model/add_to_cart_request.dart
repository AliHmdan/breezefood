class AddToCartExtraRequest {
  final int extraId;
  final int quantity;

  const AddToCartExtraRequest({required this.extraId, this.quantity = 1});

  Map<String, dynamic> toJson() => {"extra_id": extraId, "quantity": quantity};
}

class AddToCartRequest {
  final int restaurantId;
  final int menuItemId;
  final int quantity;
  final String specialNotes;
  final List<AddToCartExtraRequest> extras;

  /// ✅ new
  final bool withSpicy;

  const AddToCartRequest({
    required this.restaurantId,
    required this.menuItemId,
    required this.quantity,
    this.specialNotes = "",
    this.extras = const [],
    this.withSpicy = false,
  });

  Map<String, dynamic> toJson() => {
    "restaurant_id": restaurantId,
    "menu_item_id": menuItemId,
    "quantity": quantity,
    "special_notes": specialNotes,
    "with_Spicy": withSpicy ? 1 : 0, 
    "extras": extras.map((e) => e.toJson()).toList(),
  };
}

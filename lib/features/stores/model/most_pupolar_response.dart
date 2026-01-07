import 'package:breezefood/features/home/model/home_response.dart';

class MostPopularResponse {
  final List<MenuItemModel> items;
  MostPopularResponse({required this.items});

  factory MostPopularResponse.fromJson(Map<String, dynamic> json) {
    final raw = json["menu_items"];
    final list = (raw is List)
        ? raw.whereType<Map>().map((e) => _mapToMenuItemModel(e.cast<String, dynamic>())).toList()
        : <MenuItemModel>[];

    return MostPopularResponse(items: list);
  }

  static MenuItemModel _mapToMenuItemModel(Map<String, dynamic> j) {
    final primary = (j["primary_image"] is Map) ? (j["primary_image"] as Map).cast<String, dynamic>() : null;
    final rest = (j["restaurant"] is Map) ? (j["restaurant"] as Map).cast<String, dynamic>() : null;

    // base_price جاي String
    final price = double.tryParse((j["base_price"] ?? "0").toString()) ?? 0.0;

    return MenuItemModel(
      id: (j["id"] ?? 0) as int,
      nameAr: (j["name_ar"] ?? "") as String,
      nameEn: (j["name_en"] ?? "") as String,
      priceBefore: price,
      priceAfter: price,
      hasDiscount: false,
      discountType: null,
      discountValue: null,
      isFavorite: (j["is_favorite"] ?? false) as bool,
      primaryImage: primary == null ? null : PrimaryImageModel.fromJson(primary),
      restaurant: rest == null ? null : MenuItemRestaurant.fromJson(rest),
    );
  }
}

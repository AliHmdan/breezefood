class RestaurantDetailsResponse {
  final RestaurantGeneral general;
  final List<MenuCategorySection> restaurantMenuItems;

  RestaurantDetailsResponse({
    required this.general,
    required this.restaurantMenuItems,
  });

  factory RestaurantDetailsResponse.fromJson(Map<String, dynamic> json) {
    return RestaurantDetailsResponse(
      general: RestaurantGeneral.fromJson((json["general"] as Map).cast<String, dynamic>()),
      restaurantMenuItems: _parseSections(json["restaurant_menu_items"]),
    );
  }

  static List<MenuCategorySection> _parseSections(dynamic v) {
    if (v is! List) return <MenuCategorySection>[];
    return v
        .whereType<Map>()
        .map((e) => MenuCategorySection.fromJson(e.cast<String, dynamic>()))
        .toList();
  }
}

class RestaurantGeneral {
  final int id;
  final String name;
  final String? description;
  final String? logo;
  final String? cover;
  final String? address;
  final String? phone;
  final double avgRating;
  final int totalCompletedOrders;
  final int deliveryTime;
  final num deliveryCash;

  RestaurantGeneral({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    this.cover,
    this.address,
    this.phone,
    required this.avgRating,
    required this.totalCompletedOrders,
    required this.deliveryTime,
    required this.deliveryCash,
  });

  factory RestaurantGeneral.fromJson(Map<String, dynamic> json) {
    return RestaurantGeneral(
      id: (json["id"] ?? 0) as int,
      name: (json["name"] ?? "") as String,
      description: json["description"] as String?,
      logo: json["logo"] as String?,
      cover: json["cover"] as String?,
      address: json["address"] as String?,
      phone: json["phone"] as String?,
      avgRating: _toDouble(json["avg_rating"]),
      totalCompletedOrders: (json["total_completed_orders"] ?? 0) as int,
      deliveryTime: (json["delivery_time"] ?? 0) as int,
      deliveryCash: (json["delivery_cash"] ?? 0) as num,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class MenuCategory {
  final int id;
  final String nameAr;
  final String nameEn;

  MenuCategory({required this.id, required this.nameAr, required this.nameEn});

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
        id: (json["id"] ?? 0) as int,
        nameAr: (json["name_ar"] ?? "") as String,
        nameEn: (json["name_en"] ?? "") as String,
      );
}

class MenuItem {
  final int id;
  final double price;
  final String? image;
  final bool isFavorite;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;

  final List<MenuExtra> mealExtras; // ✅ جديد

  MenuItem({
    required this.id,
    required this.price,
    this.image,
    required this.isFavorite,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.mealExtras = const [], // ✅ default
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: (json["id"] ?? 0) as int,
        price: _toDouble(json["price"]),
        image: json["image"] as String?,
        isFavorite: (json["is_favorite"] ?? false) as bool,
        nameAr: (json["name_ar"] ?? "") as String,
        nameEn: (json["name_en"] ?? "") as String,
        descriptionAr: json["description_ar"] as String?,
        descriptionEn: json["description_en"] as String?,

        mealExtras: _parseExtras(json["extras"]), // ✅ جديد
      );

  static List<MenuExtra> _parseExtras(dynamic v) {
    if (v is! List) return <MenuExtra>[];
    return v
        .whereType<Map>()
        .map((e) => MenuExtra.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class MenuExtra {
  final int id;
  final double price;
  final String nameAr;
  final String nameEn;

  MenuExtra({
    required this.id,
    required this.price,
    required this.nameAr,
    required this.nameEn,
  });

  factory MenuExtra.fromJson(Map<String, dynamic> json) => MenuExtra(
        id: (json["id"] ?? 0) as int,
        price: _toDouble(json["price"]),
        nameAr: (json["name_ar"] ?? "") as String,
        nameEn: (json["name_en"] ?? "") as String,
      );

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class MenuCategorySection {
  final MenuCategory category;
  final List<MenuItem> items;

  MenuCategorySection({required this.category, required this.items});

  factory MenuCategorySection.fromJson(Map<String, dynamic> json) {
    final rawItems = json["items"];
    final items = (rawItems is List)
        ? rawItems
            .whereType<Map>()
            .map((e) => MenuItem.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <MenuItem>[];

    return MenuCategorySection(
      category: MenuCategory.fromJson((json["category"] as Map).cast<String, dynamic>()),
      items: items,
    );
  }
}

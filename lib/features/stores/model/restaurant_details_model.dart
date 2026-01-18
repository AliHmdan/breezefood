class RestaurantDetailsResponse {
  final RestaurantGeneral general;
  final List<MenuCategorySection> restaurantMenuItems;

  // ✅ هون
  final MyRating? myRating;

  RestaurantDetailsResponse({
    required this.general,
    required this.restaurantMenuItems,
    this.myRating,
  });

  factory RestaurantDetailsResponse.fromJson(Map<String, dynamic> json) {
    // ✅ جرّب أكتر من key لأن السيرفر مرات بيسميها بشكل مختلف
    final rawRating = json["rating"] ?? json["my_rating"] ?? json["myRating"];

    return RestaurantDetailsResponse(
      general: RestaurantGeneral.fromJson(
        (json["general"] as Map).cast<String, dynamic>(),
      ),
      restaurantMenuItems: _parseSections(json["restaurant_menu_items"]),
      myRating: (rawRating is Map) ? MyRating.fromJson(rawRating.cast<String, dynamic>()) : null,
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

  // ✅ هذا اللي جاي من السيرفر: "rating": {...}
  final MyRating? myRating;

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
    this.myRating,
  });

  factory RestaurantGeneral.fromJson(Map<String, dynamic> json) {
    final ratingJson = json["rating"];
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

      // ✅ parse rating object
      myRating: (ratingJson is Map)
          ? MyRating.fromJson(ratingJson.cast<String, dynamic>())
          : null,
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

  // السعر الأساسي
  final double price;

  // ✅ خصم
  final double priceBefore;
  final double priceAfter;
  final double discountPercent;
  final String? discountType;

  final String? image;
  final bool isFavorite;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;

  final List<MenuExtra> mealExtras;

  bool get hasDiscount =>
      (discountPercent > 0) ||
      (priceBefore > 0 && priceAfter > 0 && priceAfter < priceBefore);

  double get effectivePrice => (priceAfter > 0 ? priceAfter : price);

  MenuItem({
    required this.id,
    required this.price,
    required this.priceBefore,
    required this.priceAfter,
    required this.discountPercent,
    this.discountType,
    this.image,
    required this.isFavorite,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.mealExtras = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: (json["id"] ?? 0) as int,
        price: _toDouble(json["price"]),
        // ✅ من السيرفر
        priceBefore: _toDouble(json["price_before"]),
        priceAfter: _toDouble(json["price_after"]),
        discountPercent: _toDouble(json["discount_percent"]),
        discountType: json["discount_type"] as String?,
        image: json["image"] as String?,
        isFavorite: (json["is_favorite"] ?? false) as bool,
        nameAr: (json["name_ar"] ?? "") as String,
        nameEn: (json["name_en"] ?? "") as String,
        descriptionAr: json["description_ar"] as String?,
        descriptionEn: json["description_en"] as String?,
        mealExtras: _parseExtras(json["extras"]),
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
class MyRating {
  final int id;
  final double rating;
  final String? comment;

  MyRating({
    required this.id,
    required this.rating,
    this.comment,
  });

  factory MyRating.fromJson(Map<String, dynamic> json) => MyRating(
        id: (json["id"] ?? 0) as int,
        rating: _toDouble(json["rating"]),
        comment: json["comment"] as String?,
      );

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}


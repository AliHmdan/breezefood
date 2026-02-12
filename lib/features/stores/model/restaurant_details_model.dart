import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:easy_localization/easy_localization.dart';

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
      myRating: (rawRating is Map)
          ? MyRating.fromJson(rawRating.cast<String, dynamic>())
          : null,
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
  final DeliveryInfo? delivery;
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
    this.delivery,
    this.cover,
    this.address,
    this.phone,
    required this.avgRating,
    required this.totalCompletedOrders,
    required this.deliveryTime,
    required this.deliveryCash,
    this.myRating,
  });
  String? get logoUrl => AppImageUrl.toFull(logo);
  String? get coverUrl => AppImageUrl.toFull(cover);
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

      delivery: (json["delivery"] is Map)
          ? DeliveryInfo.fromJson(
              (json["delivery"] as Map).cast<String, dynamic>(),
            )
          : null,

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

class DeliveryInfo {
  final num baseFee;
  final num finalFee;

  const DeliveryInfo({required this.baseFee, required this.finalFee});

  static num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    final s = v.toString().trim();
    if (s.isEmpty) return 0;
    final cleaned = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    return num.tryParse(cleaned) ?? 0;
  }

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) => DeliveryInfo(
    baseFee: _toNum(json["base_fee"]),
    finalFee: _toNum(json["final_fee"]),
  );
}

class RestaurantModel {
  final int id;
  final String name;

  final String? logo;
  final String? coverImage;

  final double ratingAvg;
  final int ratingCount;

  final int? deliveryTime;

  final num deliveryBaseFee;

  final DeliveryInfo? delivery;

  RestaurantModel({
    required this.id,
    required this.name,
    this.logo,
    this.coverImage,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.deliveryTime,
    this.deliveryBaseFee = 0,
    this.delivery,
  });

  String? get logoUrl => AppImageUrl.toFull(logo);
  String? get coverUrl => AppImageUrl.toFull(coverImage);
  static num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    final s = v.toString().trim();
    if (s.isEmpty) return 0;
    final cleaned = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    return num.tryParse(cleaned) ?? 0;
  }

  factory RestaurantModel.fromJson(Map<String, dynamic> json) =>
      RestaurantModel(
        id: (json["id"] ?? 0) as int,
        name: (json["name"] ?? "") as String,
        logo: json["logo"] as String?,
        coverImage: json["cover_image"] as String?,
        ratingAvg: ((json["rating_avg"] ?? 0) as num).toDouble(),
        ratingCount: (json["rating_count"] ?? 0) as int,
        deliveryTime: (json["delivery_time"] as int?),
        deliveryBaseFee: _toNum(json["delivery_base_fee"]),
        delivery: (json["delivery"] is Map<String, dynamic>)
            ? DeliveryInfo.fromJson(json["delivery"] as Map<String, dynamic>)
            : null,
      );
}

class DeliveryDiscount {
  final String type; // fixed | percentage ...
  final num value;

  const DeliveryDiscount({required this.type, required this.value});

  factory DeliveryDiscount.fromJson(Map<String, dynamic> json) =>
      DeliveryDiscount(
        type: (json["type"] ?? "").toString(),
        value: json["value"] ?? 0,
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
    image: AppImageUrl.toFull(_parseImage(json["primary_image"] ?? json["image"])),

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

String? _parseImage(dynamic v) {
  if (v == null) return null;

  if (v is String) return v.trim().isEmpty ? null : v.trim();

  if (v is Map) {
    final m = v.cast<String, dynamic>();
    final url = m["image_url"] ?? m["url"] ?? m["path"];
    if (url is String) {
      final s = url.trim();
      return s.isEmpty ? null : s;
    }
  }

  return null;
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
    price: _toDouble(json["price"] ?? json["base_price"]),

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
      category: MenuCategory.fromJson(
        (json["category"] as Map).cast<String, dynamic>(),
      ),
      items: items,
    );
  }
}

class MyRating {
  final int id;
  final double rating;
  final String? comment;

  MyRating({required this.id, required this.rating, this.comment});

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

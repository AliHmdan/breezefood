import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:easy_localization/easy_localization.dart';

class RestaurantDetailsResponse {
  final RestaurantGeneral general;
  final List<MenuCategorySection> restaurantMenuItems;
  final List<MenuItem> mostPopular;

  final MyRating? myRating;

  RestaurantDetailsResponse({
    required this.general,
    required this.restaurantMenuItems,
    required this.mostPopular,
    this.myRating,
  });

  factory RestaurantDetailsResponse.fromJson(Map<String, dynamic> json) {
    final rawRating = json["rating"] ?? json["my_rating"] ?? json["myRating"];

    return RestaurantDetailsResponse(
      general: RestaurantGeneral.fromJson(_asMap(json["general"])),
      restaurantMenuItems: _parseSections(json["restaurant_menu_items"]),
      mostPopular: _parseMostPopular(json["most_popular"]),
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

  static List<MenuItem> _parseMostPopular(dynamic v) {
    if (v is! List) return <MenuItem>[];
    return v
        .whereType<Map>()
        .map((e) => MenuItem.fromJson(e.cast<String, dynamic>()))
        .toList();
  }
}

class ExtraGrouped {
  final int groupId;
  final String? nameAr;
  final String? nameEn;
  final List<MenuExtra> items;

  const ExtraGrouped({
    required this.groupId,
    required this.nameAr,
    required this.nameEn,
    required this.items,
  });

  factory ExtraGrouped.fromJson(Map<String, dynamic> json) {
    final rawItems = json["items"];
    final items = (rawItems is List)
        ? rawItems
            .whereType<Map>()
            .map((e) => MenuExtra.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <MenuExtra>[];

    return ExtraGrouped(
      groupId: _toInt(json["group_id"]),
      nameAr: json["name_ar"] as String?,
      nameEn: json["name_en"] as String?,
      items: items,
    );
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

  final bool isOpen;
  final double avgRating;

  final int reviewsCount;
  final int totalCompletedOrders;

  /// ✅ FIX: السيرفر بيرجعها أحياناً "20 - 35" (String)
  final String? deliveryTime;

  final num deliveryCash;

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
    required this.isOpen,
    required this.avgRating,
    required this.reviewsCount,
    required this.totalCompletedOrders,
    required this.deliveryTime,
    required this.deliveryCash,
    this.myRating,
  });

  factory RestaurantGeneral.fromJson(Map<String, dynamic> json) {
    bool _toBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v?.toString().toLowerCase().trim();
      return s == "true" || s == "1" || s == "yes";
    }

    return RestaurantGeneral(
      id: _toInt(json["id"]),
      name: (json["name"] ?? "").toString(),
      description: json["description"] as String?,
      logo: json["logo"] as String?,
      cover: json["cover"] as String?,
      address: json["address"] as String?,
      phone: json["phone"] as String?,
      isOpen: _toBool(json["is_open"]),
      avgRating: _toDouble(json["avg_rating"]),
      reviewsCount: _toInt(json["reviews_count"]),
      totalCompletedOrders: _toInt(json["total_completed_orders"]),
      deliveryTime: _toStringOrNull(json["delivery_time"]),
      deliveryCash: _toNum(json["delivery_cash"]),
      delivery: (json["delivery"] is Map)
          ? DeliveryInfo.fromJson(_asMap(json["delivery"]))
          : null,
      myRating: (json["rating"] is Map)
          ? MyRating.fromJson(_asMap(json["rating"]))
          : null,
    );
  }
}

class MenuCategory {
  final int id;
  final String nameAr;
  final String nameEn;

  MenuCategory({required this.id, required this.nameAr, required this.nameEn});

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
        id: _toInt(json["id"]),
        nameAr: (json["name_ar"] ?? "").toString(),
        nameEn: (json["name_en"] ?? "").toString(),
      );
}

class DeliveryInfo {
  final num baseFee;
  final num finalFee;

  const DeliveryInfo({required this.baseFee, required this.finalFee});

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

  /// ✅ FIX: خليها String? مثل تفاصيل المطعم
  final String? deliveryTime;

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

  factory RestaurantModel.fromJson(Map<String, dynamic> json) => RestaurantModel(
        id: _toInt(json["id"]),
        name: (json["name"] ?? "").toString(),
        logo: json["logo"] as String?,
        coverImage: json["cover_image"] as String?,
        ratingAvg: _toDouble(json["rating_avg"]),
        ratingCount: _toInt(json["rating_count"]),
        deliveryTime: _toStringOrNull(json["delivery_time"]),
        deliveryBaseFee: _toNum(json["delivery_base_fee"]),
        delivery: (json["delivery"] is Map<String, dynamic>)
            ? DeliveryInfo.fromJson(json["delivery"] as Map<String, dynamic>)
            : (json["delivery"] is Map)
                ? DeliveryInfo.fromJson(_asMap(json["delivery"]))
                : null,
      );
}

class DeliveryDiscount {
  final String type;
  final num value;

  const DeliveryDiscount({required this.type, required this.value});

  factory DeliveryDiscount.fromJson(Map<String, dynamic> json) =>
      DeliveryDiscount(
        type: (json["type"] ?? "").toString(),
        value: _toNum(json["value"]),
      );
}

class MenuItem {
  final int id;

  final double price;
  final List<ExtraGrouped> extrasGrouped;

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
    this.extrasGrouped = const [],
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
        id: _toInt(json["id"]),
        price: _toDouble(json["price"]),
        priceBefore: _toDouble(json["price_before"]),
        priceAfter: _toDouble(json["price_after"]),
        discountPercent: _toDouble(json["discount_percent"]),
        discountType: json["discount_type"] as String?,
        image: AppImageUrl.toFull(_parseImage(json["primary_image"] ?? json["image"])),
        isFavorite: _toBool(json["is_favorite"]),
        nameAr: (json["name_ar"] ?? "").toString(),
        nameEn: (json["name_en"] ?? "").toString(),
        descriptionAr: json["description_ar"] as String?,
        descriptionEn: json["description_en"] as String?,
        mealExtras: _parseExtras(json["extras"]),
        extrasGrouped: _parseExtrasGrouped(json["extras_grouped"]),
      );

  static List<ExtraGrouped> _parseExtrasGrouped(dynamic v) {
    if (v is! List) return <ExtraGrouped>[];
    return v
        .whereType<Map>()
        .map((e) => ExtraGrouped.fromJson(e.cast<String, dynamic>()))
        // ✅ إذا بدك تشيل الجروبات الفاضية:
        .where((g) => g.items.isNotEmpty)
        .toList();
  }

  static List<MenuExtra> _parseExtras(dynamic v) {
    if (v is! List) return <MenuExtra>[];
    return v
        .whereType<Map>()
        .map((e) => MenuExtra.fromJson(e.cast<String, dynamic>()))
        .toList();
  }
}

String? _parseImage(dynamic v) {
  if (v == null) return null;

  if (v is String) {
    final s = v.trim();
    return s.isEmpty ? null : s;
  }

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
        id: _toInt(json["id"]),
        price: _toDouble(json["price"] ?? json["base_price"]),
        nameAr: (json["name_ar"] ?? "").toString(),
        nameEn: (json["name_en"] ?? "").toString(),
      );
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
      category: MenuCategory.fromJson(_asMap(json["category"])),
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
        id: _toInt(json["id"]),
        rating: _toDouble(json["rating"]),
        comment: json["comment"] as String?,
      );
}

// ======================
// Helpers (Safe parsing)
// ======================

Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return v.cast<String, dynamic>();
  return <String, dynamic>{};
}

bool _toBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v?.toString().toLowerCase().trim();
  return s == "true" || s == "1" || s == "yes";
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString().trim()) ?? 0;
}

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  final s = v.toString().trim();
  if (s.isEmpty) return 0;
  return double.tryParse(s) ?? 0;
}

num _toNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  final s = v.toString().trim();
  if (s.isEmpty) return 0;
  final cleaned = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
  return num.tryParse(cleaned) ?? 0;
}

String? _toStringOrNull(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

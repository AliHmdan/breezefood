import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart'
    show OrderInfo;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomeResponse {
  final List<HomeRestaurantModel> nearbyRestaurants;
  final List<HomeRestaurantModel> breakfastRestaurants;
  final List<HomeRestaurantModel> sweets;
  final List<HomeRestaurantModel> supermarkets;
  final List<HomeRestaurantModel> allRestaurants;

  final List<RestaurantDiscountModel> discounts;
  final List<RestaurantDiscountModel> discountDelivery;

  final List<StoryWrapperModel> stories;

  final OrderInfo? haveOrder;
  final bool hasCoordinates;
  final String? avatar;
  final String? provinceDetected;

  // رسائل السيرفر (اختياري)
  final String? messageAr;
  final String? messageEn;

  HomeResponse({
    this.messageAr,
    this.messageEn,
    required this.nearbyRestaurants,
    required this.breakfastRestaurants,
    required this.sweets,
    required this.supermarkets,
    required this.allRestaurants,
    required this.discounts,
    required this.discountDelivery,
    required this.stories,
    required this.haveOrder,
    required this.hasCoordinates,
    required this.avatar,
    required this.provinceDetected,
  });

  // ========= Helpers =========
  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static bool _toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().toLowerCase().trim();
    return s == "true" || s == "1" || s == "yes";
  }

  static String _toStringSafe(dynamic v) => (v == null) ? "" : v.toString();

  static Map<String, dynamic>? _toMap(dynamic v) {
    if (v is Map) return v.cast<String, dynamic>();
    return null;
  }

  static List<T> _list<T>(
    Map<String, dynamic> json,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final v = json[key];
    if (v is List) {
      return v
          .where((e) => e is Map)
          .map((e) => fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    }
    return <T>[];
  }

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    final haveOrderMap = _toMap(json["have_order"]);

    return HomeResponse(
      messageAr: json["message_ar"]?.toString(),
      messageEn: json["message_en"]?.toString(),

      nearbyRestaurants: _list(
        json,
        "nearby_restaurants",
        (e) => HomeRestaurantModel.fromJson(e),
      ),
      breakfastRestaurants: _list(
        json,
        "breakfast_restaurants",
        (e) => HomeRestaurantModel.fromJson(e),
      ),
      sweets: _list(json, "sweets", (e) => HomeRestaurantModel.fromJson(e)),
      supermarkets: _list(
        json,
        "supermarkets",
        (e) => HomeRestaurantModel.fromJson(e),
      ),
      allRestaurants: _list(
        json,
        "all_restaurants",
        (e) => HomeRestaurantModel.fromJson(e),
      ),

      stories: _list(json, "stories", (e) => StoryWrapperModel.fromJson(e)),

      discounts: _list(
        json,
        "discounts",
        (e) => RestaurantDiscountModel.fromJson(e),
      ),
      discountDelivery: _list(
        json,
        "discountdelevery",
        (e) => RestaurantDiscountModel.fromJson(e),
      ),

      hasCoordinates: _toBool(json["has_coordinates"]),
      avatar: (json["avatar"] == null) ? null : _toStringSafe(json["avatar"]),
      provinceDetected: json["province_detected"] as String?,
      haveOrder: haveOrderMap == null ? null : OrderInfo.fromJson(haveOrderMap),
    );
  }

  String? localizedEmptyMessage(BuildContext context) {
    final code = context.locale.languageCode; // ar / en
    final msg = (code == 'ar') ? messageAr : messageEn;
    final v = msg?.trim();
    if (v == null || v.isEmpty) return null;
    return v;
  }
}

// =================== Restaurants ===================

class HomeRestaurantModel {
  final int id;
  final String name;

  final String? logo;
  final String? coverImage;

  final double ratingAvg;
  final int ratingCount;

  final int? deliveryTime;

  final num deliveryBaseFee;

  final DeliveryPreview? delivery;

  final bool isOpen;

  HomeRestaurantModel({
    required this.id,
    required this.name,
    this.logo,
    this.coverImage,
    required this.ratingAvg,
    required this.ratingCount,
    this.deliveryTime,
    required this.deliveryBaseFee,
    required this.delivery,
    required this.isOpen,
  });

  String? get logoUrl => AppImageUrl.toFull(logo);
  String? get coverUrl => AppImageUrl.toFull(coverImage);

  num? get deliveryFinalFee {
    final f = delivery?.finalFee;
    if (f != null && f > 0) return f;
    if (deliveryBaseFee > 0) return deliveryBaseFee;
    return null;
  }

  factory HomeRestaurantModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? m(dynamic v) =>
        (v is Map) ? v.cast<String, dynamic>() : null;

    final deliveryMap = m(json["delivery"]);

    return HomeRestaurantModel(
      id: HomeResponse._toInt(json["id"]),
      name: HomeResponse._toStringSafe(json["name"]),
      logo: json["logo"] as String?,
      coverImage: json["cover_image"] as String?,
      ratingAvg: HomeResponse._toDouble(json["rating_avg"]),
      ratingCount: HomeResponse._toInt(json["rating_count"]),
      deliveryTime: json["delivery_time"] == null
          ? null
          : HomeResponse._toInt(json["delivery_time"]),

      deliveryBaseFee: (json["delivery_base_fee"] == null)
          ? 0
          : HomeResponse._toDouble(json["delivery_base_fee"]),

      delivery: deliveryMap == null
          ? null
          : DeliveryPreview.fromJson(deliveryMap),

      /// ✅ أهم سطر: هندلة is_open مهما كان نوعه (bool / 0-1 / "true")
      isOpen: HomeResponse._toBool(json["is_open"]),
    );
  }
}

class DeliveryPreview {
  final num baseFee;
  final num finalFee;

  DeliveryPreview({required this.baseFee, required this.finalFee});

  factory DeliveryPreview.fromJson(Map<String, dynamic> json) {
    return DeliveryPreview(
      baseFee: HomeResponse._toDouble(json["base_fee"]),
      finalFee: HomeResponse._toDouble(json["final_fee"]),
    );
  }
}

class DeliveryDiscountPreview {
  final String? type; // fixed | percentage | null
  final double value;

  DeliveryDiscountPreview({required this.type, required this.value});

  factory DeliveryDiscountPreview.fromJson(Map<String, dynamic> json) =>
      DeliveryDiscountPreview(
        type: json["type"]?.toString(),
        value: HomeResponse._toDouble(json["value"]),
      );
}

// =================== Stories ===================

class StoryWrapperModel {
  final StoryModel storyData;
  final double rating;

  StoryWrapperModel({required this.storyData, required this.rating});

  factory StoryWrapperModel.fromJson(Map<String, dynamic> json) {
    final storyMap =
        HomeResponse._toMap(json["story_data"]) ?? <String, dynamic>{};
    return StoryWrapperModel(
      storyData: StoryModel.fromJson(storyMap),
      rating: HomeResponse._toDouble(json["rating"]),
    );
  }
}

class StoryModel {
  final int id;
  final int restaurantId;
  final String title;
  final String? description;
  final String? image;

  // باللوج ما كان واضح status/start/end دائماً، خليتهم optional
  final String? status;
  final String? startAt;
  final String? endAt;

  final StoryRestaurantMini? restaurant;

  StoryModel({
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.description,
    required this.image,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.restaurant,
  });

  String? get imageUrl => AppImageUrl.toFull(image);

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final restMap = HomeResponse._toMap(json["restaurant"]);
    return StoryModel(
      id: HomeResponse._toInt(json["id"]),
      restaurantId: HomeResponse._toInt(json["restaurant_id"]),
      title: HomeResponse._toStringSafe(json["title"]),
      description: json["description"] as String?,
      image: json["image"] as String?,
      status: json["status"]?.toString(),
      startAt: json["start_at"]?.toString(),
      endAt: json["end_at"]?.toString(),
      restaurant: restMap == null
          ? null
          : StoryRestaurantMini.fromJson(restMap),
    );
  }
}

class StoryRestaurantMini {
  final int id;
  final String name;
  final double ratingAvg; // ✅ from log
  final int ratingCount; // ✅ from log

  StoryRestaurantMini({
    required this.id,
    required this.name,
    required this.ratingAvg,
    required this.ratingCount,
  });

  factory StoryRestaurantMini.fromJson(Map<String, dynamic> json) {
    return StoryRestaurantMini(
      id: HomeResponse._toInt(json["id"]),
      name: HomeResponse._toStringSafe(json["name"]),
      ratingAvg: HomeResponse._toDouble(json["rating_avg"]),
      ratingCount: HomeResponse._toInt(json["rating_count"]),
    );
  }
}

// =================== Discounts ===================

class RestaurantDiscountModel {
  final int restaurantId;
  final String restaurantName;
  final String? logo;
  final bool isOpen;

  final double ratingAvg;
  final int ratingCount;

  final DiscountInfo? foodDiscount;
  final DeliveryDiscountInfo? deliveryDiscount;

  final double? deliveryBaseFee;
  final double? deliveryFinalFee;

  RestaurantDiscountModel({
    required this.isOpen,
    required this.restaurantId,
    required this.restaurantName,
    required this.logo,
    required this.ratingAvg,
    required this.ratingCount,
    required this.foodDiscount,
    required this.deliveryDiscount,
    this.deliveryBaseFee,
    this.deliveryFinalFee,
  });

  String? get logoSafe {
    final v = (logo ?? "").trim();
    if (v.isEmpty) return null;
    if (v.contains(r":\")) return null;
    return v;
  }

  factory RestaurantDiscountModel.fromJson(Map<String, dynamic> json) {
    int i(dynamic v) => (v is num) ? v.toInt() : int.tryParse("$v") ?? 0;
    double d(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse("$v") ?? 0.0;

    Map<String, dynamic>? m(dynamic v) =>
        (v is Map) ? v.cast<String, dynamic>() : null;

    final foodMap = m(json["food_discount"]);
    final delMap = m(json["delivery_discount"]);
    final deliveryMap = m(json["delivery"]);

    return RestaurantDiscountModel(
      restaurantId: i(json["restaurant_id"]),
      restaurantName: (json["restaurant_name"] ?? "").toString(),
      logo: json["logo"]?.toString(),
      isOpen: HomeResponse._toBool(json["is_open"]),
      ratingAvg: d(json["rating_avg"]),
      ratingCount: i(json["rating_count"]),
      foodDiscount: foodMap == null ? null : DiscountInfo.fromJson(foodMap),
      deliveryDiscount: delMap == null
          ? null
          : DeliveryDiscountInfo.fromJson(delMap),
      deliveryBaseFee: deliveryMap != null ? d(deliveryMap["base_fee"]) : null,
      deliveryFinalFee: deliveryMap != null
          ? d(deliveryMap["final_fee"])
          : null,
    );
  }
}

extension DiscountOpenX on RestaurantDiscountModel {
  String openLabel(BuildContext context) =>
      isOpen ? "restaurant.open".tr() : "restaurant.closed".tr();
}

class DiscountInfo {
  final String discountType; // fixed | percentage
  final double discountValue;

  DiscountInfo({required this.discountType, required this.discountValue});

  factory DiscountInfo.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse("$v") ?? 0.0;

    return DiscountInfo(
      discountType: (json["discount_type"] ?? "").toString(),
      discountValue: d(json["discount_value"]),
    );
  }
}

class DeliveryDiscountInfo {
  final String discountType; // fixed | percentage
  final double discountValue;
  final DeliveryFeeModel? delivery;

  DeliveryDiscountInfo({
    required this.discountType,
    required this.discountValue,
    required this.delivery,
  });

  factory DeliveryDiscountInfo.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse("$v") ?? 0.0;

    final deliveryJson = json["delivery"];
    final delivery = (deliveryJson is Map)
        ? DeliveryFeeModel.fromJson(deliveryJson.cast<String, dynamic>())
        : null;

    return DeliveryDiscountInfo(
      discountType: (json["discount_type"] ?? "").toString(),
      discountValue: d(json["discount_value"]),
      delivery: delivery,
    );
  }
}

class DeliveryFeeModel {
  final double baseFee;
  final double finalFee;

  DeliveryFeeModel({required this.baseFee, required this.finalFee});

  factory DeliveryFeeModel.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse("$v") ?? 0.0;

    return DeliveryFeeModel(
      baseFee: d(json["base_fee"]),
      finalFee: d(json["final_fee"]),
    );
  }
}

// =================== UI helpers ===================

extension RestaurantOpenX on HomeRestaurantModel {
  String openLabel(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    return isOpen ? (isAr ? "مفتوح" : "Open") : (isAr ? "مغلق" : "Closed");
  }
}

class MenuItemModel {
  final int id;
  final String nameAr;
  final String nameEn;

  final double priceBefore;
  final double priceAfter;

  final bool hasDiscount;
  final String? discountType;
  final double? discountValue;

  final bool isFavorite;
  final PrimaryImageModel? primaryImage;
  final MenuItemRestaurant? restaurant;

  MenuItemModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.priceBefore,
    required this.priceAfter,
    required this.hasDiscount,
    this.discountType,
    this.discountValue,
    required this.isFavorite,
    this.primaryImage,
    this.restaurant,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    final base = HomeResponse._toDouble(json["base_price"]);
    final beforeRaw = json["price_before"];
    final afterRaw = json["price_after"];

    final priceBefore = (beforeRaw == null)
        ? base
        : HomeResponse._toDouble(beforeRaw);
    final priceAfter = (afterRaw == null)
        ? base
        : HomeResponse._toDouble(afterRaw);

    final discountRaw = json["discount_value"];
    final discountValue =
        (discountRaw == null || discountRaw.toString().trim().isEmpty)
        ? null
        : HomeResponse._toDouble(discountRaw);

    final hasOffer = json.containsKey("has_offer")
        ? HomeResponse._toBool(json["has_offer"])
        : false;

    final hasDiscountKey = json.containsKey("has_discount")
        ? HomeResponse._toBool(json["has_discount"])
        : false;

    final hasDiscount =
        hasDiscountKey ||
        hasOffer ||
        (discountValue != null && discountValue > 0) ||
        (priceAfter < priceBefore);

    final primaryMap = HomeResponse._toMap(json["primary_image"]);
    final restMap = HomeResponse._toMap(json["restaurant"]);

    return MenuItemModel(
      id: HomeResponse._toInt(json["id"]),
      nameAr: HomeResponse._toStringSafe(json["name_ar"]),
      nameEn: HomeResponse._toStringSafe(json["name_en"]),
      priceBefore: priceBefore,
      priceAfter: priceAfter,
      hasDiscount: hasDiscount,
      discountType: json["discount_type"] as String?,
      discountValue: discountValue,
      isFavorite: HomeResponse._toBool(json["is_favorite"]),
      primaryImage: primaryMap == null
          ? null
          : PrimaryImageModel.fromJson(primaryMap),
      restaurant: restMap == null ? null : MenuItemRestaurant.fromJson(restMap),
    );
  }
}

class PrimaryImageModel {
  final String? imageUrl;
  PrimaryImageModel({required this.imageUrl});

  factory PrimaryImageModel.fromJson(Map<String, dynamic> json) =>
      PrimaryImageModel(
        imageUrl: AppImageUrl.toFull(json["image_url"].toString()),
      );
}

class MenuItemRestaurant {
  final int id;
  final String name;
  final String? logo;
  final double ratingAvg;
  final int ratingCount;

  MenuItemRestaurant({
    required this.id,
    required this.name,
    this.logo,
    required this.ratingAvg,
    required this.ratingCount,
  });

  factory MenuItemRestaurant.fromJson(Map<String, dynamic> json) =>
      MenuItemRestaurant(
        id: HomeResponse._toInt(json["id"]),
        name: HomeResponse._toStringSafe(json["name"]),
        logo: json["logo"] as String?,
        ratingAvg: HomeResponse._toDouble(json["rating_avg"]),
        ratingCount: HomeResponse._toInt(json["rating_count"]),
      );
}

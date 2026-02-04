import 'package:breezefood/features/orders/model/active_orders_response.dart'
    show OrderInfo;

class HomeResponse {
  final List<AdModel> ads;
  final List<HomeRestaurantModel> closerToYou;
  final List<HomeRestaurantModel> nearbyRestaurants;
  final List<HomeRestaurantModel> supermarkets;

  // ✅ ممكن يكون مش موجود بالريسبونس الجديد
  final List<MenuItemModel> mostPopular;

  // ✅ تغيرت
  final List<RestaurantDiscountModel> discounts;
  final List<RestaurantDiscountModel> discountDelivery;

  // ✅ قصص
  final List<StoryWrapperModel> stories;

  final OrderInfo? haveOrder;

  final bool hasCoordinates;
  final String? avatar;
  final String? provinceDetected;

  HomeResponse({
    required this.ads,
    required this.closerToYou,
    required this.nearbyRestaurants,
    required this.supermarkets,
    required this.mostPopular,
    required this.discounts,
    required this.discountDelivery,
    required this.stories,
    required this.hasCoordinates,
    required this.avatar,
    required this.provinceDetected,
    required this.haveOrder,
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
      ads: _list(json, "ads", (e) => AdModel.fromJson(e)),
      closerToYou: _list(
        json,
        "closer_to_you",
        (e) => HomeRestaurantModel.fromJson(e),
      ),
      nearbyRestaurants: _list(
        json,
        "nearby_restaurants",
        (e) => HomeRestaurantModel.fromJson(e),
      ),
      supermarkets: _list(
        json,
        "supermarkets",
        (e) => HomeRestaurantModel.fromJson(e),
      ),

      // ✅ الجديد ممكن ما يرجع most_popular
      mostPopular: _list(
        json,
        "most_popular",
        (e) => MenuItemModel.fromJson(e),
      ),

      // ✅ discounts صار Restaurants
     discounts: _list(json, "discounts", (e) => RestaurantDiscountModel.fromJson(e)),

      // ✅ discountdelevery
   discountDelivery: _list(
        json,
        "discountdelevery",
        (e) => RestaurantDiscountModel.fromJson(e),
      ),

      // ✅ stories wrapper
      stories: _list(json, "stories", (e) => StoryWrapperModel.fromJson(e)),

      hasCoordinates: _toBool(json["has_coordinates"]),
      avatar: (json["avatar"] == null) ? null : _toStringSafe(json["avatar"]),
      provinceDetected: json["province_detected"] as String?,
      haveOrder: haveOrderMap == null ? null : OrderInfo.fromJson(haveOrderMap),
    );
  }
}

// =================== URL Helper ===================
class Urls {
  static const host = "https://breezefood.cloud/";
  static String? abs(String? raw) {
    final v = raw?.trim();
    if (v == null || v.isEmpty) return null;
    if (v.startsWith("http://") || v.startsWith("https://")) return v;
    final cleaned = v.startsWith("/") ? v.substring(1) : v;
    return "$host$cleaned";
  }
}

// =================== Discounts ===================

class DiscountRestaurantModel {
  final int? restaurantId;
  final String? restaurantName;
  final String? logo;
  final String? discountType;
  final double? discountValue;

  DiscountRestaurantModel({
    this.restaurantId,
    this.restaurantName,
    this.logo,
    this.discountType,
    this.discountValue,
  });

  factory DiscountRestaurantModel.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) => (v is num) ? v.toDouble() : double.tryParse("$v") ?? 0.0;
    int i(dynamic v) => (v is num) ? v.toInt() : int.tryParse("$v") ?? 0;

    return DiscountRestaurantModel(
      restaurantId: i(json["restaurant_id"]),
      restaurantName: json["restaurant_name"]?.toString(),
      logo: json["logo"]?.toString(),
      discountType: json["discount_type"]?.toString(),
      discountValue: d(json["discount_value"]),
    );
  }
}


class DeliveryDiscountModel {
  final int restaurantId;
  final String restaurantName;
  final String? logo;
  final String discountType; // fixed | percentage
  final double discountValue;
  final DeliveryFeeModel? delivery;

  DeliveryDiscountModel({
    required this.restaurantId,
    required this.restaurantName,
    required this.logo,
    required this.discountType,
    required this.discountValue,
    required this.delivery,
  });

  factory DeliveryDiscountModel.fromJson(Map<String, dynamic> json) {
    int i(dynamic v) => (v is num) ? v.toInt() : int.tryParse("$v") ?? 0;
    double d(dynamic v) => (v is num) ? v.toDouble() : double.tryParse("$v") ?? 0.0;

    return DeliveryDiscountModel(
      restaurantId: i(json["restaurant_id"]),
      restaurantName: (json["restaurant_name"] ?? "").toString(),
      logo: json["logo"]?.toString(),
      discountType: (json["discount_type"] ?? "").toString(),
      discountValue: d(json["discount_value"]),
      delivery: (json["delivery"] is Map)
          ? DeliveryFeeModel.fromJson((json["delivery"] as Map).cast<String, dynamic>())
          : null,
    );
  }
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
  final String status;
  final String? startAt;
  final String? endAt;

  // ✅ نخلي restaurant خفيف (id/name/logo فقط) حتى ما تحمل menu_items
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

  String? get imageUrl => Urls.abs(image);

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final restMap = HomeResponse._toMap(json["restaurant"]);
    return StoryModel(
      id: HomeResponse._toInt(json["id"]),
      restaurantId: HomeResponse._toInt(json["restaurant_id"]),
      title: HomeResponse._toStringSafe(json["title"]),
      description: json["description"] as String?,
      image: json["image"] as String?,
      status: HomeResponse._toStringSafe(json["status"]),
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

  StoryRestaurantMini({required this.id, required this.name});

  factory StoryRestaurantMini.fromJson(Map<String, dynamic> json) {
    return StoryRestaurantMini(
      id: HomeResponse._toInt(json["id"]),
      name: HomeResponse._toStringSafe(json["name"]),
    );
  }
}

// =================== Existing Models (keep yours) ===================

class AdModel {
  final int id;
  final String type;
  final String title;
  final String? description;
  final String? image;
  final String? url;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int priority;

  AdModel({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.image,
    this.url,
    this.status,
    this.startDate,
    this.endDate,
    required this.priority,
  });

  String? get fullImageUrl => Urls.abs(image);

  factory AdModel.fromJson(Map<String, dynamic> json) => AdModel(
    id: HomeResponse._toInt(json["id"]),
    type: HomeResponse._toStringSafe(json["type"]),
    title: HomeResponse._toStringSafe(json["title"]),
    description: json["description"] as String?,
    image: json["image"] as String?,
    url: json["url"] as String?,
    status: json["status"] as String?,
    startDate: json["start_date"] == null
        ? null
        : DateTime.tryParse(json["start_date"].toString()),
    endDate: json["end_date"] == null
        ? null
        : DateTime.tryParse(json["end_date"].toString()),
    priority: HomeResponse._toInt(json["priority"]),
  );
}

class HomeRestaurantModel {
  final int id;
  final String name;

  final String? logo;
  final String? coverImage;

  final double ratingAvg;
  final int ratingCount;

  final int? deliveryTime;

  /// ✅ موجود بالـ /home و /super-markets/all
  final num deliveryBaseFee;

  /// ✅ موجود بالـ /home فقط
  final DeliveryPreview? delivery;

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
  });

  String? get logoUrl => Urls.abs(logo);
  String? get coverUrl => Urls.abs(coverImage);

  /// ✅ أهم Getter: السعر النهائي للعرض
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

      /// ✅ هذا هو المهم
      deliveryBaseFee: (json["delivery_base_fee"] == null)
          ? 0
          : HomeResponse._toDouble(json["delivery_base_fee"]),

      /// ✅ /home
      delivery: deliveryMap == null ? null : DeliveryPreview.fromJson(deliveryMap),
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

    final hasDiscount = (json.containsKey("has_discount"))
        ? HomeResponse._toBool(json["has_discount"])
        : (discountValue != null && discountValue > 0) ||
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
  final String imageUrl;
  PrimaryImageModel({required this.imageUrl});

  static String absUrl(String? path) {
    final p = (path ?? "").trim();
    if (p.isEmpty) return "";
    if (p.startsWith("http")) return p;
    if (p.startsWith("/")) return "https://breezefood.cloud$p";
    return "https://breezefood.cloud/$p";
  }

  factory PrimaryImageModel.fromJson(Map<String, dynamic> json) =>
      PrimaryImageModel(imageUrl: absUrl(json["image_url"]?.toString()));
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
class RestaurantDiscountModel {
  final int restaurantId;
  final String restaurantName;
  final String? logo;

  final double ratingAvg;
  final int ratingCount;

  final DiscountInfo? foodDiscount;
  final DeliveryDiscountInfo? deliveryDiscount;

  RestaurantDiscountModel({
    required this.restaurantId,
    required this.restaurantName,
    required this.logo,
    required this.ratingAvg,
    required this.ratingCount,
    required this.foodDiscount,
    required this.deliveryDiscount,
  });

  // ✅ لوغو صالح للعرض: إذا جاي مسار ويندوز اعتبره null
  String? get logoSafe {
    final v = (logo ?? "").trim();
    if (v.isEmpty) return null;
    if (v.contains(r":\")) return null; // مثل C:\xampp\tmp\...
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

    return RestaurantDiscountModel(
      restaurantId: i(json["restaurant_id"]),
      restaurantName: (json["restaurant_name"] ?? "").toString(),
      logo: json["logo"]?.toString(),
      ratingAvg: d(json["rating_avg"]),
      ratingCount: i(json["rating_count"]),
      foodDiscount: foodMap == null ? null : DiscountInfo.fromJson(foodMap),
      deliveryDiscount: delMap == null ? null : DeliveryDiscountInfo.fromJson(delMap),
    );
  }
}


class DiscountInfo {
  final String discountType; // fixed | percentage
  final double discountValue;

  DiscountInfo({required this.discountType, required this.discountValue});

  factory DiscountInfo.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) => (v is num) ? v.toDouble() : double.tryParse("$v") ?? 0.0;

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
    double d(dynamic v) => (v is num) ? v.toDouble() : double.tryParse("$v") ?? 0.0;

    final deliveryJson = json["delivery"];
    final delivery =
        (deliveryJson is Map) ? DeliveryFeeModel.fromJson(deliveryJson.cast<String, dynamic>()) : null;

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
    double d(dynamic v) => (v is num) ? v.toDouble() : double.tryParse("$v") ?? 0.0;

    return DeliveryFeeModel(
      baseFee: d(json["base_fee"]),
      finalFee: d(json["final_fee"]),
    );
  }
}

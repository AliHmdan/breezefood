class HomeResponse {
  final List<AdModel> ads;
  final List<RestaurantModel> closerToYou;
  final List<RestaurantModel> nearbyRestaurants;
  final List<RestaurantModel> supermarkets; // ✅
  final List<MenuItemModel> mostPopular;
  final List<MenuItemModel> discounts; // ✅
  final List<StoryWrapperModel> stories;

  final bool hasCoordinates; // ✅ اختياري
  final String? provinceDetected; // ✅ اختياري

  HomeResponse({
    required this.ads,
    required this.closerToYou,
    required this.nearbyRestaurants,
    required this.supermarkets,
    required this.mostPopular,
    required this.discounts,
    required this.stories,
    required this.hasCoordinates,
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

  static String _toStringSafe(dynamic v) {
    if (v == null) return "";
    return v.toString();
  }

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
    return HomeResponse(
      ads: _list(json, "ads", (e) => AdModel.fromJson(e)),
      closerToYou: _list(json, "closer_to_you", (e) => RestaurantModel.fromJson(e)),
      nearbyRestaurants: _list(json, "nearby_restaurants", (e) => RestaurantModel.fromJson(e)),
      supermarkets: _list(json, "supermarkets", (e) => RestaurantModel.fromJson(e)), // ✅
      mostPopular: _list(json, "most_popular", (e) => MenuItemModel.fromJson(e)),
      discounts: _list(json, "discounts", (e) => MenuItemModel.fromJson(e)), // ✅
      stories: _list(json, "stories", (e) => StoryWrapperModel.fromJson(e)),
      hasCoordinates: _toBool(json["has_coordinates"]),
      provinceDetected: json["province_detected"] as String?,
    );
  }
}

class AdModel {
  final int id;
  final String type; // image / video ...
  final String title;
  final String? description;
  final String? image; // path from api
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

  String? get fullImageUrl {
    final p = image?.trim();
    if (p == null || p.isEmpty) return null;
    if (p.startsWith('http')) return p;
    return 'https://breezefood.cloud$p';
  }

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


class RestaurantModel {
  final int id;
  final String name;
  final String? logo;
  final String? coverImage;
  final double ratingAvg;
  final int ratingCount;
  final int? deliveryTime;

  RestaurantModel({
    required this.id,
    required this.name,
    this.logo,
    this.coverImage,
    required this.ratingAvg,
    required this.ratingCount,
    this.deliveryTime,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) => RestaurantModel(
        id: HomeResponse._toInt(json["id"]),
        name: HomeResponse._toStringSafe(json["name"]),
        logo: json["logo"] as String?,
        coverImage: json["cover_image"] as String?,
        ratingAvg: HomeResponse._toDouble(json["rating_avg"]),
        ratingCount: HomeResponse._toInt(json["rating_count"]),
        deliveryTime: json["delivery_time"] == null ? null : HomeResponse._toInt(json["delivery_time"]),
      );
}

class MenuItemModel {
  final int id;
  final String nameAr;
  final String nameEn;

  final double priceBefore;
  final double priceAfter;

  final bool hasDiscount;
  final String? discountType; // fixed / percent
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
    final discountRaw = json["discount_value"];
    final discountParsed = (discountRaw == null || discountRaw.toString().trim().isEmpty)
        ? null
        : HomeResponse._toDouble(discountRaw);

    final primaryMap = HomeResponse._toMap(json["primary_image"]);
    final restMap = HomeResponse._toMap(json["restaurant"]);

    return MenuItemModel(
      id: HomeResponse._toInt(json["id"]),
      nameAr: HomeResponse._toStringSafe(json["name_ar"]),
      nameEn: HomeResponse._toStringSafe(json["name_en"]),
      priceBefore: HomeResponse._toDouble(json["price_before"]),
      priceAfter: HomeResponse._toDouble(json["price_after"]),
      hasDiscount: HomeResponse._toBool(json["has_discount"]),
      discountType: json["discount_type"] as String?,
      discountValue: discountParsed,
      isFavorite: HomeResponse._toBool(json["is_favorite"]),
      primaryImage: primaryMap == null ? null : PrimaryImageModel.fromJson(primaryMap),
      restaurant: restMap == null ? null : MenuItemRestaurant.fromJson(restMap),
    );
  }
}

class PrimaryImageModel {
  final String imageUrl;
  PrimaryImageModel({required this.imageUrl});

  factory PrimaryImageModel.fromJson(Map<String, dynamic> json) =>
      PrimaryImageModel(imageUrl: HomeResponse._toStringSafe(json["image_url"]));
}

class MenuItemRestaurant {
  final int id;
  final String name;
  final String? logo;
  MenuItemRestaurant({required this.id, required this.name, this.logo});

  factory MenuItemRestaurant.fromJson(Map<String, dynamic> json) =>
      MenuItemRestaurant(
        id: HomeResponse._toInt(json["id"]),
        name: HomeResponse._toStringSafe(json["name"]),
        logo: json["logo"] as String?,
      );
}

class StoryWrapperModel {
  final StoryModel storyData;
  final double rating;

  StoryWrapperModel({required this.storyData, required this.rating});

  factory StoryWrapperModel.fromJson(Map<String, dynamic> json) {
    final storyMap = HomeResponse._toMap(json["story_data"]) ?? <String, dynamic>{};
    return StoryWrapperModel(
      storyData: StoryModel.fromJson(storyMap),
      rating: HomeResponse._toDouble(json["rating"]),
    );
  }
}

class StoryModel {
  final int id;
  final String title;
  final String? image;
  final int restaurantId;

  StoryModel({
    required this.id,
    required this.title,
    required this.image,
    required this.restaurantId,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) => StoryModel(
        id: HomeResponse._toInt(json["id"]),
        title: HomeResponse._toStringSafe(json["title"]),
        image: json["image"] as String?,
        restaurantId: HomeResponse._toInt(json["restaurant_id"]),
      );
}

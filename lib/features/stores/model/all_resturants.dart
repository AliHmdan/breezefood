class AllRestaurantsResponse {
  final List<RestaurantModel> restaurants;

  AllRestaurantsResponse({required this.restaurants});

  factory AllRestaurantsResponse.fromJson(Map<String, dynamic> json) {
    final v = json["restaurants"];
    final list = (v is List)
        ? v
            .map((e) => RestaurantModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <RestaurantModel>[];

    return AllRestaurantsResponse(restaurants: list);
  }
}

class RestaurantModel {
  final int id;
  final String name;
  final String? logo;
  final String? coverImage;
  final double ratingAvg;
  final int ratingCount;

  /// ✅ لأنه بيجي "20 - 30"
  final String? deliveryTime;

  /// ✅ جديد
  final num deliveryBaseFee;

  /// (اختياري) كمان عندك
  final bool isOpen;

  RestaurantModel({
    required this.id,
    required this.name,
    this.logo,
    this.coverImage,
    required this.ratingAvg,
    required this.ratingCount,
    required this.deliveryBaseFee,
    required this.deliveryTime,
    required this.isOpen,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) => RestaurantModel(
        id: _toInt(json["id"]),
        name: (json["name"] ?? "") as String,
        logo: json["logo"] as String?,
        coverImage: json["cover_image"] as String?,
        ratingAvg: _toDouble(json["rating_avg"]),
        ratingCount: _toInt(json["rating_count"]),
        deliveryBaseFee: _toNum(json["delivery_base_fee"]),

        // ✅ اقرأ الصح
        deliveryTime: json["delivery_time_minutes"]?.toString() ??
            json["delivery_time"]?.toString(),

        isOpen: _toBool(json["is_open"]),
      );

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v?.toString().toLowerCase();
    return s == "true" || s == "1";
  }
}


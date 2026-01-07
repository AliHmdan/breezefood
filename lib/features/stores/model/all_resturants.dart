class AllRestaurantsResponse {
  final List<RestaurantModel> restaurants;

  AllRestaurantsResponse({required this.restaurants});

  factory AllRestaurantsResponse.fromJson(Map<String, dynamic> json) {
    final v = json["restaurants"];
    final list = (v is List)
        ? v.whereType<Map>().map((e) => RestaurantModel.fromJson(e.cast<String, dynamic>())).toList()
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
        id: (json["id"] ?? 0) as int,
        name: (json["name"] ?? "") as String,
        logo: json["logo"] as String?,
        coverImage: json["cover_image"] as String?,
        ratingAvg: _toDouble(json["rating_avg"]),
        ratingCount: (json["rating_count"] ?? 0) as int,
        deliveryTime: json["delivery_time"] as int?,
      );

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

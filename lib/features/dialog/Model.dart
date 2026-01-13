class RateModel {
  final int id;
  final int restaurantId;
  final int rate;
  final String? comment;

  RateModel({
    required this.id,
    required this.restaurantId,
    required this.rate,
    this.comment,
  });

  factory RateModel.fromJson(Map<String, dynamic> json) {
    return RateModel(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      rate: json['rate'],
      comment: json['comment'],
    );
  }
}

import 'package:breezefood/features/rating/RestaurantRatingModel.dart';
import 'package:flutter/material.dart';

class RatingStore extends ChangeNotifier {
  final Map<int, RestaurantRating> _ratings = {};

  RestaurantRating? getRating(int restaurantId) {
    return _ratings[restaurantId];
  }

  void setRating(int restaurantId, double rating, String comment) {
    _ratings[restaurantId] = RestaurantRating(
      rating: rating,
      comment: comment,
    );
    notifyListeners();
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

class RatingCubit extends Cubit<Map<int, double>> {
  RatingCubit() : super({});

  /// 🔹 حفظ / تحديث التقييم (UI Only)
  void setRating(int restaurantId, double rating) {
    final updated = Map<int, double>.from(state);
    updated[restaurantId] = rating;
    emit(updated);
  }

  /// 🔹 جلب التقييم الحالي
  double getRating(int restaurantId) {
    return state[restaurantId] ?? 0.0;
  }
}

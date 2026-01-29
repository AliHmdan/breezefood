import 'package:breezefood/features/ratings/data/repo/reviews_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'rating_submit_state.dart';
part 'rating_submit_cubit.freezed.dart';

class RatingSubmitCubit extends Cubit<RatingSubmitState> {
  final ReviewsRepository repo;
  RatingSubmitCubit(this.repo) : super(const RatingSubmitState.initial());

  Future<void> submitRestaurantRate({
    required int restaurantId,
    required double rating,
  }) async {
    emit(const RatingSubmitState.loading());

    final res = await repo.rateRestaurant(
      restaurantId: restaurantId,
      rating: rating,
    );

    if (!res.ok) {
      emit(RatingSubmitState.error(res.message ?? "rate_failed"));
      return;
    }

    emit(const RatingSubmitState.success());
  }

  Future<void> deleteRestaurantRate({required int reviewId}) async {
    emit(const RatingSubmitState.loading());

    final res = await repo.deleteReview(reviewId: reviewId);

    if (!res.ok) {
      emit(RatingSubmitState.error(res.message ?? "delete_failed"));
      return;
    }

    emit(const RatingSubmitState.deleteSuccess());
  }
}

import 'package:dio/dio.dart';
import 'package:breezefood/core/network/api_result.dart';
import 'package:breezefood/core/network/api_result.dart' show AppResponseHandler;
import 'package:breezefood/features/ratings/data/api/reviews_api_service.dart';

class ReviewsRepository {
  final ReviewsApiService api;
  ReviewsRepository(this.api);

  Future<AppResponse> rateRestaurant({
    required int restaurantId,
    required double rating,
  }) async {
    try {
      final res = await api.postReview({
        "reviewee_type": "restaurant",
        "reviewee_id": restaurantId,
        "rating": rating,
      });
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "rate_failed");
    }
  }

  // ✅ delete by review id
  Future<AppResponse> deleteReview({required int reviewId}) async {
    try {
      final res = await api.deleteReview({"id": reviewId});
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "delete_failed");
    }
  }
}

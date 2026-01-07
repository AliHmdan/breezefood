import 'package:dio/dio.dart';
import 'package:breezefood/core/network/api_result.dart';
import 'package:breezefood/core/network/api_result.dart' show AppResponseHandler;
import 'package:breezefood/features/stores/data/api/restaurant_details_api_service.dart';

class RestaurantDetailsRepository {
  final RestaurantDetailsApiService api;
  RestaurantDetailsRepository(this.api);

  Future<AppResponse> getDetails(int restaurantId) async {
    try {
      final res = await api.getRestaurantDetails({"restaurant_id": restaurantId});
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل تفاصيل المطعم");
    }
  }
}

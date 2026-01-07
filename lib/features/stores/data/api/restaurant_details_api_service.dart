import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'restaurant_details_api_service.g.dart';

@RestApi()
abstract class RestaurantDetailsApiService {
  factory RestaurantDetailsApiService(Dio dio, {String? baseUrl}) =
      _RestaurantDetailsApiService;

  @POST("/restaurant-details")
  Future<HttpResponse<dynamic>> getRestaurantDetails(
    @Body() Map<String, dynamic> body,
  );
}

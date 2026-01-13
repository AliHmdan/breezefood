import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'most_popular_api_service.g.dart';

@RestApi()
abstract class MostPopularApiService {
  factory MostPopularApiService(Dio dio, {String? baseUrl}) =
      _MostPopularApiService;
  @GET("/most-popular")
  Future<HttpResponse<dynamic>> getMostPopular(
    @Query("restaurant_id") int restaurantId,
  );
}

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'reviews_api_service.g.dart';

@RestApi()
abstract class ReviewsApiService {
  factory ReviewsApiService(Dio dio, {String? baseUrl}) = _ReviewsApiService;

  @POST("/reviews")
  Future<HttpResponse<dynamic>> postReview(@Body() Map<String, dynamic> body);

  // ✅ حذف Review by id (مثل مثالك)
  @DELETE("/reviews")
  Future<HttpResponse<dynamic>> deleteReview(@Body() Map<String, dynamic> body);
}

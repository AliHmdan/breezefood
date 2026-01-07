import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'super_market_api_service.g.dart';

@RestApi()
abstract class SuperMarketApiService {
  factory SuperMarketApiService(Dio dio, {String? baseUrl}) = _SuperMarketApiService;

  @GET("/super-markets/all")
  Future<HttpResponse<dynamic>> getMarkets();

  @POST("/super-markets/categories")
  Future<HttpResponse<dynamic>> getCategories(@Body() Map<String, dynamic> body);

  @POST("/super-markets/categories/items")
  Future<HttpResponse<dynamic>> getCategoryItems(@Body() Map<String, dynamic> body);
}

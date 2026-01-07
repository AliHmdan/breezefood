import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'stores_api_service.g.dart';

@RestApi()
abstract class StoresApiService {
  factory StoresApiService(Dio dio, {String? baseUrl}) = _StoresApiService;

  @GET("/all-restaurants")
  Future<HttpResponse<dynamic>> getAllRestaurants();
}

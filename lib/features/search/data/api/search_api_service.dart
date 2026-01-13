import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'search_api_service.g.dart';

@RestApi()
abstract class SearchApiService {
  factory SearchApiService(Dio dio, {String? baseUrl}) = _SearchApiService;

  @POST("/search")
  Future<HttpResponse<dynamic>> search(@Body() Map<String, dynamic> body);

  @GET("/history-search")
  Future<HttpResponse<dynamic>> history();
}

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'favorites_api_service.g.dart';

@RestApi()
abstract class FavoritesApiService {
  factory FavoritesApiService(Dio dio, {String? baseUrl}) =
      _FavoritesApiService;

  @GET("/favorites")
  Future<HttpResponse<dynamic>> getFavorites();

  @POST("/favorites/toggle")
  Future<HttpResponse<dynamic>> toggleFavorite(
    @Body() Map<String, dynamic> body,
  );
}

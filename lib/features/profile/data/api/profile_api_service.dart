import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'profile_api_service.g.dart';

@RestApi()
abstract class ProfileApiService {
  factory ProfileApiService(Dio dio, {String? baseUrl}) = _ProfileApiService;

  @GET("/me")
  Future<HttpResponse<dynamic>> me();

  @GET("/avatars")
  Future<HttpResponse<dynamic>> avatars();

  // ✅ JSON
  @POST("/updateProfile")
  Future<HttpResponse<dynamic>> updateProfile(
    @Body() Map<String, dynamic> body,
  );
}

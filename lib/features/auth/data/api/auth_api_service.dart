import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String? baseUrl}) = _AuthApiService;

  @POST("/login")
  Future<HttpResponse<dynamic>> login(@Body() Map<String, dynamic> body);

  @POST("/verify-phone")
  Future<HttpResponse<dynamic>> verifyPhone(@Body() Map<String, dynamic> body);
  @POST("/logout")
  Future<HttpResponse<dynamic>> logout();
  @POST("/resend-code")
  Future<HttpResponse<dynamic>> resendCode(@Body() Map<String, dynamic> body);

  @POST("/updateProfile")
  Future<HttpResponse<dynamic>> updateProfile(
    @Body() Map<String, dynamic> body,
  );

  @POST("/update_address")
  Future<HttpResponse<dynamic>> addAddress(@Body() Map<String, dynamic> body);
}

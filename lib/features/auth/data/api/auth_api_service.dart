import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String? baseUrl}) = _AuthApiService;

  // POST /login  {phone, referral_code}
  @POST("/login")
  Future<HttpResponse<dynamic>> login(
    @Body() Map<String, dynamic> body,
  );

  // POST /verify-phone {phone, code} => يرجع token + user
  @POST("/verify-phone")
  Future<HttpResponse<dynamic>> verifyPhone(
    @Body() Map<String, dynamic> body,
  );
  @POST("/logout")
  Future<HttpResponse<dynamic>> logout();
  // POST /resend-code {phone}
  @POST("/resend-code")
  Future<HttpResponse<dynamic>> resendCode(
    @Body() Map<String, dynamic> body,
  );

  // POST /updateProfile {first_name,last_name} (Auth Bearer required)
  @POST("/updateProfile")
  Future<HttpResponse<dynamic>> updateProfile(
    @Body() Map<String, dynamic> body,
  );

  // POST /profile/addresses {label,address,latitude,longitude,is_default}
  @POST("/profile/addresses")
  Future<HttpResponse<dynamic>> addAddress(
    @Body() Map<String, dynamic> body,
  );
}

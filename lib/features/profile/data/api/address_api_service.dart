import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'address_api_service.g.dart';

@RestApi()
abstract class AddressApiService {
  factory AddressApiService(Dio dio, {String? baseUrl}) = _AddressApiService;

  // إذا عندك endpoint لعرض العناوين (شائع):
  @GET("/profile/location")
  Future<HttpResponse<dynamic>> getAddresses();

  @POST("/update_address")
  Future<HttpResponse<dynamic>> addAddress(
    @Body() Map<String, dynamic> body,
  );

  @DELETE("/profile/addresses")
  Future<HttpResponse<dynamic>> deleteAddress(
    @Body() Map<String, dynamic> body, // {"id":1}
  );
}

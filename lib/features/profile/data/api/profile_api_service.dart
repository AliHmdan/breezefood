import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'profile_api_service.g.dart';

@RestApi()
abstract class ProfileApiService {
  factory ProfileApiService(Dio dio, {String? baseUrl}) = _ProfileApiService;

  @GET("/me")
  Future<HttpResponse<dynamic>> me();

  @POST("/updateProfile")
  @MultiPart()
  Future<HttpResponse<dynamic>> updateProfile({
    @Part(name: "first_name") required String firstName,
    @Part(name: "last_name") required String lastName,
    // إذا لاحقاً بدك صورة:
    // @Part(name: "profile_image") File? image,
  });
}

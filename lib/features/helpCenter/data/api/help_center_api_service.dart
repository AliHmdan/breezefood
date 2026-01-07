import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'help_center_api_service.g.dart';

@RestApi()
abstract class HelpCenterApiService {
  factory HelpCenterApiService(Dio dio, {String? baseUrl}) =
      _HelpCenterApiService;

  @GET("/help-center/thread")
  Future<HttpResponse<dynamic>> getThread();

  @POST("/help-center/messages")
  Future<HttpResponse<dynamic>> sendMessage(@Body() Map<String, dynamic> body);
}

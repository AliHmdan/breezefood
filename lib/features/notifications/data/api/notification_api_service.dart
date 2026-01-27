import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'notification_api_service.g.dart';

@RestApi()
abstract class NotificationApiService {
  factory NotificationApiService(Dio dio, {String? baseUrl}) =
      _NotificationApiService;

  @GET("/notifications")
  Future<HttpResponse<dynamic>> getNotifications();

  // حسب اللي عندك بالـ Postman: GET
  @GET("/notifications/read-all")
  Future<HttpResponse<dynamic>> readAll();
}

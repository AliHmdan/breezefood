import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'orders_api_service.g.dart';

@RestApi()
abstract class OrdersApiService {
  factory OrdersApiService(Dio dio, {String? baseUrl}) = _OrdersApiService;

  @POST("/orders/store")
  Future<HttpResponse<dynamic>> storeOrder(
    @Body() Map<String, dynamic> body,
  );
    @POST("/activeOrders")
  Future<HttpResponse<dynamic>> activeOrders();

  @POST("/ordersHistory")
  Future<HttpResponse<dynamic>> ordersHistory();
}

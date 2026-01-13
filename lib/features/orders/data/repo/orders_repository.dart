import 'package:dio/dio.dart';
import 'package:breezefood/core/network/api_result.dart';
import 'package:breezefood/core/network/api_result.dart' show AppResponseHandler;

import 'package:breezefood/features/orders/data/api/orders_api_service.dart';
import 'package:breezefood/features/orders/model/store_order_request.dart';

class OrdersRepository {
  final OrdersApiService api;
  OrdersRepository(this.api);

  Future<AppResponse> storeOrder(StoreOrderRequest req) async {
    try {
      final res = await api.storeOrder(req.toJson());
      return AppResponse.ok(
        message: (res.data is Map) ? (res.data["message"]?.toString()) : null,
        data: res.data,
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل إنشاء الطلب");
    }
  } Future<AppResponse> getActiveOrders() async {
    try {
      final res = await api.activeOrders();
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل الطلبات الحالية");
    }
  }

  Future<AppResponse> getOrdersHistory() async {
    try {
      final res = await api.ordersHistory();
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل سجل الطلبات");
    }
  }
}

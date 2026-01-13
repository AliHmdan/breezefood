import 'active_orders_response.dart';

class OrdersHistoryResponse {
  final List<OrderBundle> orders;

  OrdersHistoryResponse({required this.orders});

  factory OrdersHistoryResponse.fromJson(Map<String, dynamic> json) {
    final list = (json["orders"] as List? ?? const []);
    return OrdersHistoryResponse(
      orders: list
          .where((e) => e is Map)
          .map((e) => OrderBundle.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

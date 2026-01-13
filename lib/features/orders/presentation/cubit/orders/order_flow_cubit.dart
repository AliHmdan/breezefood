import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:breezefood/features/orders/data/repo/orders_repository.dart';
import 'package:breezefood/features/orders/model/store_order_request.dart';

part 'order_flow_state.dart';
part 'order_flow_cubit.freezed.dart';

class OrderFlowCubit extends Cubit<OrderFlowState> {
  final OrdersRepository repo;
  OrderFlowCubit(this.repo) : super(const OrderFlowState.initial());

  Future<void> store(StoreOrderRequest req) async {
    emit(const OrderFlowState.loading());

    final res = await repo.storeOrder(req);

    if (!res.ok) {
      emit(OrderFlowState.error(res.message ?? "فشل إنشاء الطلب"));
      return;
    }

    // ✅ السيرفر عندك بيرجع غالباً:
    // { "order_id": 43, "status": "pending", "pricing": {...} }
    final raw = res.data;

    if (raw is! Map) {
      emit(const OrderFlowState.error("صيغة رد السيرفر غير متوقعة"));
      return;
    }

    final data = raw.cast<String, dynamic>();

    final orderId = _toInt(data['order_id']) ?? _toInt(data['orderId']) ?? 0;
    final status = (data['status'] ?? '').toString();
    final pricing = (data['pricing'] is Map)
        ? (data['pricing'] as Map).cast<String, dynamic>()
        : null;

    if (orderId <= 0 || status.trim().isEmpty) {
      emit(const OrderFlowState.error("الرد ناقص (order_id/status)"));
      return;
    }

    emit(OrderFlowState.success(
      orderId: orderId,
      status: status,
      pricing: pricing,
      raw: data, // احتفظنا بالخام إذا احتجته
    ));
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  void reset() => emit(const OrderFlowState.initial());
}

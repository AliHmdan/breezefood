import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:breezefood/features/orders/data/repo/orders_repository.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart';
import 'package:breezefood/features/orders/model/orders_history_response.dart';

part 'orders_state.dart';
part 'orders_cubit.freezed.dart';
class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository repo;
  OrdersCubit(this.repo) : super(const OrdersState.initial());

  // ✅ caches حتى ما تفضى الشاشة لما تتغير حالة التبويب الآخر
  List<OrderBundle> _activeCache = const [];
  List<OrderBundle> _historyCache = const [];

  List<OrderBundle> get activeCache => _activeCache;
  List<OrderBundle> get historyCache => _historyCache;

  Future<void> loadActive() async {
    emit(const OrdersState.loadingActive());

    final res = await repo.getActiveOrders();
    if (!res.ok) {
      emit(OrdersState.errorActive(res.message ?? "خطأ"));
      return;
    }

    final map = (res.data as Map?)?.cast<String, dynamic>() ?? {};
    final parsed = ActiveOrdersResponse.fromJson(map);

    _activeCache = parsed.orders; // ✅ خزّن
    emit(OrdersState.activeLoaded(_activeCache));
  }

  Future<void> loadHistory() async {
    emit(const OrdersState.loadingHistory());

    final res = await repo.getOrdersHistory();
    if (!res.ok) {
      emit(OrdersState.errorHistory(res.message ?? "خطأ"));
      return;
    }

    final map = (res.data as Map?)?.cast<String, dynamic>() ?? {};
    // ✅ ملاحظة: إذا history نفس شكل active (orders[]) استخدم ActiveOrdersResponse
    final parsed = ActiveOrdersResponse.fromJson(map);

    _historyCache = parsed.orders; // ✅ خزّن
    emit(OrdersState.historyLoaded(_historyCache));
  }
}

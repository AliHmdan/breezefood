import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:breezefood/features/orders/data/repo/orders_repository.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart';

part 'orders_details_cubit.freezed.dart';

@freezed
class OrdersDetailsState with _$OrdersDetailsState {
  const factory OrdersDetailsState.idle() = _Idle;
  const factory OrdersDetailsState.loading() = _Loading;
  const factory OrdersDetailsState.success(OrderDetailsResponse details) =
      _Success;
  const factory OrdersDetailsState.error(String message) = _Error;
}

class OrdersDetailsCubit extends Cubit<OrdersDetailsState> {
  final OrdersRepository repo;
  OrdersDetailsCubit(this.repo) : super(const OrdersDetailsState.idle());

  Future<void> load(int orderId) async {
    emit(const OrdersDetailsState.loading());

    final res = await repo.getMyOrderDetails(orderId);
    if (!res.ok) {
      emit(OrdersDetailsState.error(res.message ?? "common.failed"));
      return;
    }

    final map = (res.data as Map?)?.cast<String, dynamic>() ?? {};

    // ✅ الصح: نفس نوع الـ state
    final details = OrderDetailsResponse.fromJson(map);

    emit(OrdersDetailsState.success(details));
  }
}

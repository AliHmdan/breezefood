import 'dart:async';

import 'package:breezefood/features/orders/model/order_tracking_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:breezefood/features/orders/data/repo/orders_repository.dart';

part 'orders_tracking_state.freezed.dart';

@freezed
class OrdersTrackingState with _$OrdersTrackingState {
  const factory OrdersTrackingState.initial() = _Initial;
  const factory OrdersTrackingState.loading() = _Loading;
  const factory OrdersTrackingState.tracking({
    required bool tracking,
    required LatLng driverLatLng,
    required int updatedAt,
  }) = _Tracking;
  const factory OrdersTrackingState.error(String message) = _Error;
}

class OrdersTrackingCubit extends Cubit<OrdersTrackingState> {
  final OrdersRepository repo;
  OrdersTrackingCubit(this.repo) : super(const OrdersTrackingState.initial());

  Timer? _timer;
  int? _orderId;

  Future<void> start(int orderId, {Duration interval = const Duration(seconds: 5)}) async {
    _orderId = orderId;
    emit(const OrdersTrackingState.loading());

    await _tick(); // first call immediately

    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _tick());
  }

  Future<void> _tick() async {
    final id = _orderId;
    if (id == null) return;

    final res = await repo.getDriverLocation(id);
    if (!res.ok) {
      emit(OrdersTrackingState.error(res.message ?? "خطأ تتبع"));
      return;
    }

    final map = (res.data as Map?)?.cast<String, dynamic>() ?? {};
    final parsed = DriverTrackingResponse.fromJson(map);

    emit(
      OrdersTrackingState.tracking(
        tracking: parsed.tracking,
        driverLatLng: parsed.latLng,
        updatedAt: parsed.updatedAt,
      ),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    stop();
    return super.close();
  }
}

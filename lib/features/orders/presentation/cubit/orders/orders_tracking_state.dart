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

  // ✅ token لمنع أي tick قديم يكمل بعد stop/start
  int _runToken = 0;
  bool get _isRunning => _timer != null && _orderId != null;

  Future<void> start(
    int orderId, {
    Duration interval = const Duration(seconds: 5),
  }) async {
    // ✅ إذا نفس الطلب شغال، ما في داعي تعيد تشغيل
    if (_isRunning && _orderId == orderId) return;

    stop(); // ✅ أوقف أي جلسة سابقة
    _orderId = orderId;
    _runToken++; // ✅ جلسة جديدة

    emit(const OrdersTrackingState.loading());

    final token = _runToken;

    // ✅ أول ضربة مباشرة
    await _tick(token);

    // ✅ إذا توقفنا خلال await، لا تكمّل
    if (token != _runToken || _orderId == null) return;

    _timer = Timer.periodic(interval, (_) => _tick(_runToken));
  }

  Future<void> _tick(int token) async {
    final id = _orderId;
    if (id == null) return;

    try {
      final res = await repo.getDriverLocation(id);

      // ✅ إذا صار stop/start أثناء await
      if (token != _runToken || _orderId == null) return;

      if (!res.ok) {
        final msg = (res.message ?? "خطأ تتبع").toString();

        // ✅ إذا السيرفر عم يرجّع "order not found" أو 404 — وقف التتبع
        final lower = msg.toLowerCase();
        if (lower.contains("no query results") ||
            lower.contains("not found") ||
            lower.contains("404")) {
          stop();
          return;
        }

        emit(OrdersTrackingState.error(msg));
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
    } catch (e) {
      // ✅ حماية إضافية لأي استثناءات Dio/Parsing
      if (token != _runToken || _orderId == null) return;
      emit(const OrdersTrackingState.error("خطأ تتبع"));
    }
  }

  void stop() {
    _runToken++; // ✅ يبطل أي tick قديم
    _orderId = null; // ✅ هذا اللي كان ناقصك
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    stop();
    return super.close();
  }
}

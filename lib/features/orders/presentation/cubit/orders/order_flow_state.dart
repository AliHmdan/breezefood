part of 'order_flow_cubit.dart';

@freezed
class OrderFlowState with _$OrderFlowState {
  const factory OrderFlowState.initial() = _Initial;
  const factory OrderFlowState.loading() = _Loading;

  const factory OrderFlowState.success({
    required int orderId,
    required String status,
    Map<String, dynamic>? pricing,
    Map<String, dynamic>? raw,
  }) = _Success;

  const factory OrderFlowState.error(String message) = _Error;
}

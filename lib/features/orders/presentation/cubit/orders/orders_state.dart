part of 'orders_cubit.dart';

@freezed
class OrdersState with _$OrdersState {
  const factory OrdersState.initial() = _Initial;

  const factory OrdersState.loadingActive() = _LoadingActive;
  const factory OrdersState.activeLoaded(List<OrderBundle> orders) = _ActiveLoaded;
  const factory OrdersState.errorActive(String message) = _ErrorActive;

  const factory OrdersState.loadingHistory() = _LoadingHistory;
  const factory OrdersState.historyLoaded(List<OrderBundle> orders) = _HistoryLoaded;
  const factory OrdersState.errorHistory(String message) = _ErrorHistory;
}

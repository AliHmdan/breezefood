part of 'stores_cubit.dart';

@freezed
class StoresState with _$StoresState {
  const factory StoresState.initial() = _Initial;
  const factory StoresState.loading() = _Loading;
  const factory StoresState.error(String message) = _Error;
  const factory StoresState.loaded(List<RestaurantModel> restaurants) = _Loaded;
}

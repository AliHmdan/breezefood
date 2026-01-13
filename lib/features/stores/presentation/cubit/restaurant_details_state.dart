part of 'restaurant_details_cubit.dart';

@freezed
class RestaurantDetailsState with _$RestaurantDetailsState {
  const factory RestaurantDetailsState.initial() = _Initial;
  const factory RestaurantDetailsState.loading() = _Loading;
  const factory RestaurantDetailsState.error(String message) = _Error;
  const factory RestaurantDetailsState.loaded(RestaurantDetailsResponse data) = _Loaded;
}

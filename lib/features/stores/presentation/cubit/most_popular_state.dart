part of 'most_popular_cubit.dart';

@freezed
class MostPopularState with _$MostPopularState {
  const factory MostPopularState.initial() = _Initial;
  const factory MostPopularState.loading() = _Loading;
  const factory MostPopularState.error(String message) = _Error;
  const factory MostPopularState.loaded(List<MenuItemModel> items) = _Loaded;
}

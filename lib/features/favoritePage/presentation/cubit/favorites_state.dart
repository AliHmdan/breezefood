part of 'favorites_cubit.dart';

@freezed
class FavoritesState with _$FavoritesState {
  const factory FavoritesState.initial() = _Initial;
  const factory FavoritesState.loading() = _Loading;
  const factory FavoritesState.error(String message) = _Error;
  const factory FavoritesState.loaded(List<FavoriteItem> items) = _Loaded;
}

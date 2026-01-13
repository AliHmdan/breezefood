import 'package:breezefood/core/network/api_result.dart';
import 'package:breezefood/features/favoritePage/data/model/favorites_response.dart';
import 'package:breezefood/features/favoritePage/data/repo/favorites_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorites_state.dart';
part 'favorites_cubit.freezed.dart';
class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository repo;
  FavoritesCubit(this.repo) : super(const FavoritesState.initial());

  Future<AppResponse> toggle(int menuItemId) async {
    return await repo.toggleFavorite(menuItemId);
  }

  Future<void> load() async {
    emit(const FavoritesState.loading());

    final res = await repo.getFavorites();
    if (!res.ok) {
      emit(FavoritesState.error(res.message ?? "خطأ"));
      return;
    }

    try {
      final parsed = FavoritesResponse.fromJson((res.data as Map).cast<String, dynamic>());
      emit(FavoritesState.loaded(parsed.myFavorites));
    } catch (_) {
      emit(const FavoritesState.error("فشل قراءة بيانات المفضلة"));
    }
  }

  Future<void> loadSilent() async {
    final res = await repo.getFavorites();
    if (!res.ok) {
      return;
    }

    try {
      final parsed = FavoritesResponse.fromJson((res.data as Map).cast<String, dynamic>());
      emit(FavoritesState.loaded(parsed.myFavorites));
    } catch (_) {
    }
  }

  Future<void> remove(FavoriteItem item) async {
    final current = state.maybeWhen(
      loaded: (items) => items,
      orElse: () => <FavoriteItem>[],
    );

    emit(FavoritesState.loaded(current.where((e) => e.id != item.id).toList()));

    final res = await repo.toggleFavorite(item.id);

    if (!res.ok) {
      emit(FavoritesState.loaded(current));
      emit(FavoritesState.error(res.message ?? "فشل حذف العنصر"));
    }
  }
}

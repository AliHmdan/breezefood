import 'package:breezefood/features/stores/data/repo/super_market_repo.dart'
    show SuperMarketRepo;
import 'package:breezefood/features/stores/model/market_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MarketDetailsState {
  final bool loading;
  final String? error;
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final List<MarketItemModel> items;
  final bool loadingItems;

  const MarketDetailsState({
    required this.loading,
    required this.categories,
    required this.selectedCategoryId,
    required this.items,
    required this.loadingItems,
    this.error,
  });

  factory MarketDetailsState.initial() => const MarketDetailsState(
    loading: true,
    categories: [],
    selectedCategoryId: null,
    items: [],
    loadingItems: false,
  );

  MarketDetailsState copyWith({
    bool? loading,
    String? error,
    List<CategoryModel>? categories,
    int? selectedCategoryId,
    List<MarketItemModel>? items,
    bool? loadingItems,
  }) {
    return MarketDetailsState(
      loading: loading ?? this.loading,
      error: error,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      items: items ?? this.items,
      loadingItems: loadingItems ?? this.loadingItems,
    );
  }
}

class MarketDetailsCubit extends Cubit<MarketDetailsState> {
  final SuperMarketRepo repo;
  final int marketId;

  MarketDetailsCubit({required this.repo, required this.marketId})
    : super(MarketDetailsState.initial());
  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final cats = await repo.getCategories(marketId: marketId);
      final firstId = cats.isNotEmpty ? cats.first.id : null;

      emit(
        state.copyWith(
          loading: false,
          categories: cats,
          selectedCategoryId: firstId,
        ),
      );

      if (firstId != null) {
        await selectCategory(firstId);
      }
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> selectCategory(int categoryId) async {
    emit(
      state.copyWith(
        selectedCategoryId: categoryId,
        loadingItems: true,
        error: null,
      ),
    );
    try {
      final items = await repo.getItems(
        marketId: marketId,
        categoryId: categoryId,
      );
      emit(state.copyWith(items: items, loadingItems: false));
    } catch (e) {
      emit(state.copyWith(loadingItems: false, error: e.toString()));
    }
  }
}

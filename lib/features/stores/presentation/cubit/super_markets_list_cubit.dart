import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:breezefood/features/stores/data/repo/super_market_repo.dart';
import 'package:breezefood/features/stores/model/market_models.dart';

sealed class SuperMarketsListState {}
class SuperMarketsListInitial extends SuperMarketsListState {}
class SuperMarketsListLoading extends SuperMarketsListState {}
class SuperMarketsListError extends SuperMarketsListState {
  final String msg;
  SuperMarketsListError(this.msg);
}
class SuperMarketsListLoaded extends SuperMarketsListState {
  final List<MarketModel> markets;
  SuperMarketsListLoaded(this.markets);
}

class SuperMarketsListCubit extends Cubit<SuperMarketsListState> {
  final SuperMarketRepo repo;
  SuperMarketsListCubit(this.repo) : super(SuperMarketsListInitial());

  Future<void> load() async {
    emit(SuperMarketsListLoading());
    try {
      final markets = await repo.getMarkets(); // ✅ GET /super-markets/all
      emit(SuperMarketsListLoaded(markets));
    } catch (e) {
      emit(SuperMarketsListError(e.toString()));
    }
  }
}

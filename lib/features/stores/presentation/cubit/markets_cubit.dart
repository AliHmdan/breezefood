import 'package:breezefood/features/stores/data/repo/super_market_repo.dart';
import 'package:breezefood/features/stores/model/market_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class MarketsState {}

class MarketsInitial extends MarketsState {}

class MarketsLoading extends MarketsState {}

class MarketsError extends MarketsState {
  final String msg;
  MarketsError(this.msg);
}

class MarketsLoaded extends MarketsState {
  final List<MarketModel> markets;
  MarketsLoaded(this.markets);
}

class MarketsCubit extends Cubit<MarketsState> {
  final SuperMarketRepo repo;
  MarketsCubit(this.repo) : super(MarketsInitial());

  Future<void> load() async {
    emit(MarketsLoading());
    try {
      final markets = await repo.getMarkets(); // List<MarketModel>
      emit(MarketsLoaded(markets));
    } catch (e) {
      emit(MarketsError(e.toString()));
    }
  }
}

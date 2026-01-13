import 'package:breezefood/features/stores/data/api/super_market_api_service.dart';
import 'package:breezefood/features/stores/model/market_models.dart';

class SuperMarketRepo {
  final SuperMarketApiService api;
  SuperMarketRepo(this.api);

  Future<List<MarketModel>> getMarkets() async {
    final res = await api.getMarkets();
    final data = res.data as Map<String, dynamic>;
    final list = (data['markets'] as List? ?? []);
    return list.map((e) => MarketModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CategoryModel>> getCategories({required int marketId}) async {
    final res = await api.getCategories({"supermarket_id": marketId});
    final data = res.data as Map<String, dynamic>;
    final list = (data['categories'] as List? ?? []);
    return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MarketItemModel>> getItems({
    required int marketId,
    required int categoryId,
  }) async {
    final res = await api.getCategoryItems({
      "supermarketId": marketId,
      "categoryId": categoryId,
    });
    final data = res.data as Map<String, dynamic>;
    final list = (data['items'] as List? ?? []);
    return list.map((e) => MarketItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

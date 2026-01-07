import 'package:dio/dio.dart';
import 'package:breezefood/core/network/api_result.dart';
import 'package:breezefood/core/network/api_result.dart' show AppResponseHandler;
import 'package:breezefood/features/stores/data/api/most_popular_api_service.dart';

class MostPopularRepository {
  final MostPopularApiService api;
  MostPopularRepository(this.api);

  Future<AppResponse> getMostPopular(int restaurantId) async {
    try {
      final res = await api.getMostPopular(restaurantId);
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل الأكثر شعبية");
    }
  }
}

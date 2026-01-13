import 'package:breezefood/features/stores/data/api/stores_api_service.dart';
import 'package:dio/dio.dart';
import 'package:breezefood/core/network/api_result.dart';
import 'package:breezefood/core/network/api_result.dart' show AppResponseHandler;

class StoresRepository {
  final StoresApiService api;
  StoresRepository(this.api);

  Future<AppResponse> getAllRestaurants() async {
    try {
      final res = await api.getAllRestaurants();
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل المطاعم");
    }
  }
}

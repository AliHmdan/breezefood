import 'package:dio/dio.dart';
import 'package:breezefood/core/network/api_result.dart';
import 'package:breezefood/core/network/api_result.dart' show AppResponseHandler; // حسب مكانك
import 'package:breezefood/features/home/data/api/home_api_service.dart';

class HomeRepository {
  final HomeApiService api;
  HomeRepository(this.api);

  Future<AppResponse> getHome() async {
    try {
      final res = await api.getHome();
      // res.data هو Map
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل بيانات الصفحة الرئيسية");
    }
  }
}

import 'package:dio/dio.dart';
import 'package:breezefood/core/network/api_result.dart';
import 'package:breezefood/core/network/api_result.dart' show AppResponseHandler;
import 'package:breezefood/features/terms/data/api/terms_api_service.dart';

class TermsRepository {
  final TermsApiService api;
  TermsRepository(this.api);

  Future<AppResponse> getTerms() async {
    try {
      final res = await api.getTerms();
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل الشروط والأحكام");
    }
  }
}

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'terms_api_service.g.dart';

@RestApi()
abstract class TermsApiService {
  factory TermsApiService(Dio dio, {String? baseUrl}) = _TermsApiService;

  @GET("/term")
  Future<HttpResponse<dynamic>> getTerms();
}

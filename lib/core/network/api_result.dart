import 'package:dio/dio.dart';

class AppResponse {
  final bool ok;
  final dynamic data;
  final String? message;

  AppResponse({required this.ok, this.data, this.message});

  bool get isOk => ok; 

  factory AppResponse.ok({dynamic data, String? message}) {
    return AppResponse(ok: true, data: data, message: message);
  }

  factory AppResponse.fail({String? message}) {
    return AppResponse(ok: false, message: message);
  }
}

class AppResponseHandler {
  static AppResponse handle(Response res) {
    final json = res.data;

    return AppResponse(
      ok:
          res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300,

      data: json["data"],
      message: json["message"],
    );
  }

  static AppResponse handleError(DioException e) {
    try {
      final json = e.response?.data;

      return AppResponse(
        ok: false,
        message: json?["message"] ?? "تعذر الاتصال بالخادم",
      );
    } catch (_) {
      return AppResponse(ok: false, message: "خطأ غير متوقع");
    }
  }
}

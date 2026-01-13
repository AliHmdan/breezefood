import 'package:dio/dio.dart';
import 'dart:developer';
import 'api_error_model.dart';

class ErrorHandler implements Exception {
  late final ApiErrorModel apiErrorModel;

  ErrorHandler(DioException error) {
    apiErrorModel = _parseError(error);
  }

  static ApiErrorModel _parseError(DioException error) {
    log('❌ DioException caught: ${error.type}');
    if (error.response != null) {
      log('📩 Response: ${error.response}');
      final message = extractServerMessage(error.response?.data);
      return ApiErrorModel(
        code: error.response?.statusCode ?? -1,
        message: message,
      );
    }

    // no response from server
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiErrorModel(code: -1, message: "⏱️ انتهت مهلة الاتصال بالخادم.");
      case DioExceptionType.receiveTimeout:
        return ApiErrorModel(code: -1, message: "📡 انتهت مهلة استلام البيانات.");
      case DioExceptionType.badCertificate:
        return ApiErrorModel(code: -1, message: "❗ خطأ في شهادة الاتصال (SSL).");
      case DioExceptionType.badResponse:
        return ApiErrorModel(code: -1, message: "⚠️ استجابة غير صالحة من الخادم.");
      case DioExceptionType.connectionError:
        log('🌐 Connection error: ${error.message}');
        return ApiErrorModel(code: -1, message: "🚫 لا يمكن الوصول إلى الخادم.");
      case DioExceptionType.unknown:
        log('💥 Unknown Dio error: ${error.message}');
        return ApiErrorModel(code: -1, message: "حدث خطأ غير متوقع أثناء الاتصال.");
      default:
        return ApiErrorModel(code: -1, message: "حدث خطأ غير متوقع.");
    }
  }

  static String extractServerMessage(dynamic data) {
    if (data == null) return "فشل الاتصال بالخادم. حاول لاحقًا.";

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();
      if (data['errors'] != null && data['errors'] is Map<String, dynamic>) {
        final first = (data['errors'] as Map<String, dynamic>).values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        return first.toString();
      }
    }
    return "فشل الاتصال بالخادم. حاول لاحقًا.";
  }

  static String handle(dynamic error) {
    if (error is DioException) {
      return ErrorHandler(error).apiErrorModel.message;
    }
    return "حدث خطأ غير متوقع.";
  }
}

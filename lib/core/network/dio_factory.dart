import 'dart:developer';
import 'dart:io';
import 'package:breezefood/core/component/dialogs.dart';
import 'package:breezefood/core/router/navigation.dart';
import 'package:breezefood/core/router/navigation_key.dart';
import 'package:breezefood/core/services/shared_perfrences_key.dart';
import 'package:breezefood/features/auth/presentation/login_page.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioFactory {
  DioFactory._();

  static Dio? _dio;

  static const _timeout = Duration(seconds: 30);
  static const _baseUrl = "https://breezefood.cloud/api";

  static Dio getDio() {
    _dio ??= _createConfiguredDio();
    return _dio!;
  }

  static Dio _createConfiguredDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
        headers: {"Accept": "application/json"},
      ),
    );

    final adapter = dio.httpClientAdapter as IOHttpClientAdapter;

    adapter.createHttpClient = () {
      final client = HttpClient();

      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      // تحسين ثبات الاتصال
      client.maxConnectionsPerHost = 10;
      client.idleTimeout = const Duration(seconds: 10);
      client.connectionTimeout = const Duration(seconds: 30);

      return client;
    };

    // ===================================================

    dio.interceptors.addAll([_AuthInterceptor(), _LoggingInterceptor()]);

    return dio;
  }

  static void setToken(String token) {
    _dio?.options.headers["Authorization"] = "Bearer $token";
  }

  static void clearToken() {
    _dio?.options.headers.remove("Authorization");
  }

  static void reset() {
    _dio = null;
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await AuthStorageHelper.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers["Authorization"] = "Bearer $token";
      }
    } catch (e) {
      log("⚠️ AuthInterceptor Error: $e");
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path; // مثال: /auth/login

    final isAuthEndpoint =
        path.contains("/auth/login") ||
        path.contains("/auth/register") ||
        path.contains("/auth/verify") ||
        path.contains("/auth");

    final hasAuthHeader =
        (err.requestOptions.headers["Authorization"] as String?)?.isNotEmpty ==
        true;

    if (status == 401 && !isAuthEndpoint && hasAuthHeader) {
      await _handleSessionExpired();
      return;
    }

    handler.next(err);
  }
}

Future<void> _handleSessionExpired() async {
  final ctx = NavigationKey.navigatorKey.currentContext;

  if (ctx == null) return;

  await AuthStorageHelper.removeToken();
  DioFactory.clearToken();

  await AppDialog.showErrorDialog(
    "انتهت الجلسة",
    "انتهت صلاحية الجلسة. الرجاء تسجيل الدخول مجدداً.",
  );

  await toRemove(const Login());
}

// =======================================================
// ================= LOGGING INTERCEPTOR =================
// =======================================================

class _LoggingInterceptor extends PrettyDioLogger {
  _LoggingInterceptor()
    : super(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
        maxWidth: 120,
        logPrint: (obj) {
          final msg = obj.toString();
          if (msg.contains("DioError") ||
              msg.contains("Exception") ||
              msg.contains("Error")) {
            log(msg, name: "❌ DIO");
          } else if (msg.contains("-->")) {
            log(msg, name: "➡️ REQUEST");
          } else if (msg.contains("<--")) {
            log(msg, name: "⬅️ RESPONSE");
          } else {
            log(msg, name: "🌐 DIO");
          }
        },
      );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

import 'package:breezefood/features/notifications/data/api/notification_api_service.dart';
import 'package:dio/dio.dart';
import 'package:breezefood/core/network/api_result.dart';

class NotificationRepository {
  final NotificationApiService api;
  NotificationRepository(this.api);

  Future<AppResponse> getNotifications() async {
    try {
      final res = await api.getNotifications();
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل الإشعارات");
    }
  }

  Future<AppResponse> readAll() async {
    try {
      final res = await api.readAll();
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل جعل الإشعارات مقروءة");
    }
  }
}

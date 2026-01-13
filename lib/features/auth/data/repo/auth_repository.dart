import 'package:dio/dio.dart';
import 'package:breezefood/core/network/dio_factory.dart';
import 'package:breezefood/core/services/shared_perfrences_key.dart';
import 'package:breezefood/features/auth/data/api/auth_api_service.dart';
import 'package:breezefood/core/network/api_result.dart';

class AuthRepository {
  final AuthApiService api;
  AuthRepository(this.api);

  Future<AppResponse> logout() async {
    try {
      final res = await api.logout();

      await AuthStorageHelper.removeToken();
      await AuthStorageHelper.removeUserRole();
      await AuthStorageHelper.removeUserLocation();
      await AuthStorageHelper.clearGuestMode();

      DioFactory.clearToken();

      return AppResponse.ok(
        message: res.data["message"] ?? "Logged out successfully",
        data: res.data,
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تسجيل الخروج");
    }
  }

  /// 1) login -> يرسل كود (بدون token)
  Future<AppResponse> login({
    required String phone,
    String referralCode = "",
  }) async {
    try {
      final res = await api.login({
        "phone": phone,
        "referral_code": referralCode,
      });

      return AppResponse.ok(
        message: res.data["message"] ?? "تم إرسال رمز التحقق",
        data: res.data,
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل إرسال رمز التحقق");
    }
  }

  /// 2) verify-phone -> يرجع token + user
  /// ✅ هنا بنبعت token (Firebase device token) باسم "token"
  Future<AppResponse> verifyPhone({
    required String phone,
    required String code,
    String? firebaseToken, // ✅ هذا هو FCM token
  }) async {
    try {
      final body = <String, dynamic>{
        "phone": phone,
        "code": code,
      };

      // ✅ ينرسل بالفيرفاي وباسم token
      if (firebaseToken != null && firebaseToken.trim().isNotEmpty) {
        body["token"] = firebaseToken.trim();
      }

      final res = await api.verifyPhone(body);

      final token = res.data["token"]?.toString();
      if (token == null || token.isEmpty) {
        return AppResponse.fail(message: "لم يتم استلام رمز الدخول");
      }

      // ✅ save token + set token
      await AuthStorageHelper.saveToken(token);
      DioFactory.setToken(token);

      final user = (res.data["user"] as Map?)?.cast<String, dynamic>();

      // ✅ خزّن الموقع إذا موجود
      final lat = user?["latitude"]?.toString();
      final lon = user?["longitude"]?.toString();
      if (lat != null && lat.isNotEmpty && lon != null && lon.isNotEmpty) {
        await AuthStorageHelper.saveUserLocation(lat: lat, lon: lon);
      }

      // ✅ role/type
      final role = user?["type"]?.toString();
      if (role != null && role.isNotEmpty) {
        await AuthStorageHelper.saveUserRole(role);
      }

      return AppResponse.ok(
        message: res.data["message"] ?? "تم تسجيل الدخول",
        data: res.data,
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "رمز التحقق غير صحيح");
    }
  }

  Future<AppResponse> resendCode({required String phone}) async {
    try {
      final res = await api.resendCode({"phone": phone});
      return AppResponse.ok(
        message: res.data["message"] ?? "تم إرسال الرمز",
        data: res.data,
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل إعادة إرسال الرمز");
    }
  }

  Future<AppResponse> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    try {
      final res = await api.updateProfile({
        "first_name": firstName,
        "last_name": lastName,
      });

      return AppResponse.ok(
        message: res.data["message"] ?? "تم تحديث الحساب",
        data: res.data,
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحديث الحساب");
    }
  }

  Future<AppResponse> addAddress({
    required String address,
    required double latitude,
    required double longitude,
    bool isDefault = true,
  }) async {
    try {
      final res = await api.addAddress({
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "is_default": isDefault,
      });

      await AuthStorageHelper.saveUserLocation(
        lat: latitude.toString(),
        lon: longitude.toString(),
      );

      return AppResponse.ok(
        message: res.data["message"] ?? "تمت إضافة العنوان",
        data: res.data,
      );
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل إضافة العنوان");
    }
  }
}

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

  Future<AppResponse> verifyPhone({
    required String phone,
    required String code,
    String? firebaseToken,
  }) async {
    try {
      final body = <String, dynamic>{"phone": phone, "code": code};

      if (firebaseToken != null && firebaseToken.trim().isNotEmpty) {
        body["token"] = firebaseToken.trim();
      }

      // ✅ لوج
      // ignore: avoid_print
      print("🛰️ verify-phone body: $body");

      final res = await api.verifyPhone(body);

      final token = res.data["token"]?.toString();
      if (token == null || token.isEmpty) {
        return AppResponse.fail(message: "لم يتم استلام رمز الدخول");
      }

      await AuthStorageHelper.saveToken(token);
      DioFactory.setToken(token);

      final user = (res.data["user"] as Map?)?.cast<String, dynamic>();

      final lat = user?["latitude"];
      final lon = user?["longitude"];
      if (lat != null && lon != null) {
        await AuthStorageHelper.saveUserLocation(
          lat: (lat as num).toDouble(),
          lon: (lon as num).toDouble(),
          // text اختياري… إذا عندك address من API حطه هون
        );
      }

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
    String? profileImagePath,
  }) async {
    try {
      final body = <String, dynamic>{
        "first_name": firstName,
        "last_name": lastName,
      };

      if (profileImagePath != null && profileImagePath.trim().isNotEmpty) {
        body["profile_image"] = profileImagePath.trim();
      }

      final res = await api.updateProfile(body);
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحديث المعلومات");
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
        text: address,
        lat: latitude,
        lon: longitude,
      );

      // كمان خلي cart default نفسو
      await AuthStorageHelper.saveCartLocation(
        text: address,
        lat: latitude,
        lon: longitude,
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

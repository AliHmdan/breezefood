import 'package:dio/dio.dart';
import 'package:breezefood/core/network/api_result.dart';
import 'package:breezefood/core/network/api_result.dart' show AppResponseHandler;
import 'package:breezefood/features/profile/data/api/profile_api_service.dart';
import 'package:breezefood/features/profile/data/api/address_api_service.dart';

class ProfileRepository {
  final ProfileApiService profileApi;
  final AddressApiService addressApi;

  ProfileRepository(this.profileApi, this.addressApi);

  Future<AppResponse> me() async {
    try {
      final res = await profileApi.me();
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل بيانات الحساب");
    }
  }

  Future<AppResponse> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    try {
      final res = await profileApi.updateProfile(
        firstName: firstName,
        lastName: lastName,
      );
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحديث الحساب");
    }
  }

  Future<AppResponse> getAddresses() async {
    try {
      final res = await addressApi.getAddresses();
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل تحميل العناوين");
    }
  }

  Future<AppResponse> addAddress({
    required String address,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    try {
      final res = await addressApi.addAddress({
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "is_default": isDefault,
      });
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل إضافة العنوان");
    }
  }

  Future<AppResponse> deleteAddress(int id) async {
    try {
      final res = await addressApi.deleteAddress({"id": id});
      return AppResponse.ok(data: res.data);
    } on DioException catch (e) {
      return AppResponseHandler.handleError(e);
    } catch (_) {
      return AppResponse.fail(message: "فشل حذف العنوان");
    }
  }
}

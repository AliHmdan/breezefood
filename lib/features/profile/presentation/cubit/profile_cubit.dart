import 'package:breezefood/features/profile/data/model/address_model.dart';
import 'package:breezefood/features/profile/data/model/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:breezefood/features/profile/data/repo/profile_repository.dart';

part 'profile_state.dart';
part 'profile_cubit.freezed.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repo;
  ProfileCubit(this.repo) : super(const ProfileState.initial());

  Future<void> load() async {
    emit(const ProfileState.loading());

    final meRes = await repo.me();
    if (!meRes.ok) {
      emit(ProfileState.error(meRes.message ?? "خطأ"));
      return;
    }

    try {
      // ✅ meRes.data ممكن يكون:
      // 1) { "status":"success", "data": {...} }
      // 2) { ...user fields مباشرة... }
      final raw = meRes.data;

      if (raw is! Map) {
        emit(const ProfileState.error("فشل قراءة بيانات الحساب"));
        return;
      }

      final root = raw.cast<String, dynamic>();

      // ✅ إذا فيه data خدها، إذا لا اعتبر root هو user
      final dynamic inner = root["data"];
      final Map<String, dynamic> data = (inner is Map)
          ? inner.cast<String, dynamic>()
          : root;

      final user = UserModel.fromJson(data);

      // ✅ addresses: أحياناً تكون ضمن /me وأحياناً لا
      final List<AddressModel> addresses = [];
      final rawAddresses = data["addresses"];
      if (rawAddresses is List) {
        for (final e in rawAddresses) {
          if (e is Map) {
            addresses.add(AddressModel.fromJson(e.cast<String, dynamic>()));
          }
        }
      }

      emit(ProfileState.loaded(user: user, addresses: addresses));
    } catch (_) {
      emit(const ProfileState.error("فشل قراءة بيانات الحساب"));
    }
  }

  Future<void> refreshAddresses() async {
    final current = state;
    if (current is! _Loaded) return;

    final res = await repo.getAddresses();
    if (!res.ok) {
      emit(ProfileState.error(res.message ?? "فشل تحميل العناوين"));
      emit(current); // رجّع الحالة السابقة
      return;
    }

    try {
      final raw = res.data;

      // ممكن يرجع List مباشرة أو Map
      List? listRaw;

      if (raw is List) {
        listRaw = raw;
      } else if (raw is Map) {
        final root = raw.cast<String, dynamic>();
        final d = root["data"];
        final a = root["addresses"];

        if (a is List) listRaw = a;
        if (listRaw == null && d is List) listRaw = d;

        // بعض الـ APIs ترجع {data: {addresses:[...]}}
        if (listRaw == null && d is Map) {
          final dd = d.cast<String, dynamic>();
          final dda = dd["addresses"];
          if (dda is List) listRaw = dda;
        }
      }

      final list = <AddressModel>[];
      if (listRaw != null) {
        for (final e in listRaw) {
          if (e is Map)
            list.add(AddressModel.fromJson(e.cast<String, dynamic>()));
        }
      }

      emit(current.copyWith(addresses: list));
    } catch (_) {
      // لا تكسر الشاشة
    }
  }

  Future<void> saveProfile({
    required String firstName,
    required String lastName,
  }) async {
    final current = state;
    if (current is! _Loaded) return;

    emit(current.copyWith(isSaving: true, message: null));

    final res = await repo.updateProfile(
      firstName: firstName,
      lastName: lastName,
    );

    if (!res.ok) {
      emit(
        current.copyWith(
          isSaving: false,
          message: res.message ?? "فشل التحديث",
        ),
      );
      return;
    }

    try {
      final raw = res.data;

      if (raw is Map) {
        final root = raw.cast<String, dynamic>();

        // ✅ updateProfile أحياناً يرجع data وأحياناً user مباشر
        final inner = root["data"];
        final Map<String, dynamic> data = (inner is Map)
            ? inner.cast<String, dynamic>()
            : root;

        final updatedUser = UserModel.fromJson(data);

        emit(
          current.copyWith(
            user: updatedUser,
            isSaving: false,
            message: "Saved",
          ),
        );
      } else {
        emit(current.copyWith(isSaving: false, message: "Saved"));
      }
    } catch (_) {
      emit(current.copyWith(isSaving: false, message: "Saved"));
    }
  }

  Future<void> addAddress({
    required String address,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    final current = state;
    if (current is! _Loaded) return;

    emit(current.copyWith(isSaving: true, message: null));

    final res = await repo.addAddress(
      address: address,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );

    if (!res.ok) {
      emit(
        current.copyWith(
          isSaving: false,
          message: res.message ?? "فشل إضافة العنوان",
        ),
      );
      return;
    }

    emit(current.copyWith(isSaving: false, message: "Address added"));
    await refreshAddresses();
  }

  Future<void> deleteAddress(int id) async {
    final current = state;
    if (current is! _Loaded) return;

    emit(current.copyWith(isSaving: true, message: null));

    final res = await repo.deleteAddress(id);
    if (!res.ok) {
      emit(
        current.copyWith(
          isSaving: false,
          message: res.message ?? "فشل حذف العنوان",
        ),
      );
      return;
    }

    emit(current.copyWith(isSaving: false, message: "Deleted"));
    await refreshAddresses();
  }
}

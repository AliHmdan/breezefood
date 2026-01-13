import 'package:breezefood/features/auth/data/api/auth_api_service.dart';
import 'package:breezefood/features/auth/data/repo/auth_repository.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:breezefood/features/home/data/repo/home_repository.dart';

part 'home_state.dart';
part 'home_cubit.freezed.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repo;
  final AuthRepository authRepo;
  HomeCubit(this.repo, this.authRepo) : super(const HomeState.initial());
  Future<void> updateUserLocation({
    required String address,
    required double lat,
    required double lon,
  }) async {
    final res = await authRepo.addAddress(
      address: address,
      latitude: lat,
      longitude: lon,
      isDefault: true,
    );

    if (!res.ok) {
      return;
    }

    await load();
  }

  Future<void> load() async {
    emit(const HomeState.loading());

    final res = await repo.getHome();
    if (!res.ok) {
      emit(HomeState.error(res.message ?? "خطأ"));
      return;
    }

    try {
      final parsed = HomeResponse.fromJson(
        (res.data as Map).cast<String, dynamic>(),
      );
      emit(HomeState.loaded(parsed));
    } catch (e) {
      emit(const HomeState.error("فشل قراءة بيانات الصفحة الرئيسية"));
    }
  }
}

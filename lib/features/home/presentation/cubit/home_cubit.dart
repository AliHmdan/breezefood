import 'package:breezefood/features/home/model/home_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:breezefood/features/home/data/repo/home_repository.dart';

part 'home_state.dart';
part 'home_cubit.freezed.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repo;
  HomeCubit(this.repo) : super(const HomeState.initial());

  Future<void> load() async {
    emit(const HomeState.loading());

    final res = await repo.getHome();
    if (!res.ok) {
      emit(HomeState.error(res.message ?? "خطأ"));
      return;
    }

    try {
      final parsed = HomeResponse.fromJson((res.data as Map).cast<String, dynamic>());
      emit(HomeState.loaded(parsed));
    } catch (e) {
      emit(const HomeState.error("فشل قراءة بيانات الصفحة الرئيسية"));
    }
  }
}

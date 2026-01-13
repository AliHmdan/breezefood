import 'package:breezefood/features/stores/data/repo/stores_repo.dart';
import 'package:breezefood/features/stores/model/all_resturants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stores_state.dart';
part 'stores_cubit.freezed.dart';

class StoresCubit extends Cubit<StoresState> {
  final StoresRepository repo;
  StoresCubit(this.repo) : super(const StoresState.initial());

  Future<void> loadRestaurants() async {
    emit(const StoresState.loading());

    final res = await repo.getAllRestaurants();
    if (!res.ok) {
      emit(StoresState.error(res.message ?? "خطأ"));
      return;
    }

    try {
      final parsed = AllRestaurantsResponse.fromJson((res.data as Map).cast<String, dynamic>());
      emit(StoresState.loaded(parsed.restaurants));
    } catch (_) {
      emit(const StoresState.error("فشل قراءة بيانات المطاعم"));
    }
  }
}

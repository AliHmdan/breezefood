import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:breezefood/features/stores/data/repo/restaurant_details_repo.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';

part 'restaurant_details_state.dart';
part 'restaurant_details_cubit.freezed.dart';

class RestaurantDetailsCubit extends Cubit<RestaurantDetailsState> {
  final RestaurantDetailsRepository repo;
  RestaurantDetailsCubit(this.repo) : super(const RestaurantDetailsState.initial());

  Future<void> load(int id) async {
    emit(const RestaurantDetailsState.loading());

    final res = await repo.getDetails(id);
    if (!res.ok) {
      emit(RestaurantDetailsState.error(res.message ?? "خطأ"));
      return;
    }

    try {
      final parsed = RestaurantDetailsResponse.fromJson(
        (res.data as Map).cast<String, dynamic>(),
      );
      emit(RestaurantDetailsState.loaded(parsed));
    } catch (_) {
      emit(const RestaurantDetailsState.error("فشل قراءة تفاصيل المطعم"));
    }
  }
}

import 'package:breezefood/features/stores/model/most_pupolar_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:breezefood/core/network/api_result.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/stores/data/repo/most_popular_repo.dart';

part 'most_popular_state.dart';
part 'most_popular_cubit.freezed.dart';

class MostPopularCubit extends Cubit<MostPopularState> {
  final MostPopularRepository repo;
  MostPopularCubit(this.repo) : super(const MostPopularState.initial());

  Future<void> load(int restaurantId) async {
    emit(const MostPopularState.loading());

    final res = await repo.getMostPopular(restaurantId);
    if (!res.ok) {
      emit(MostPopularState.error(res.message ?? "خطأ"));
      return;
    }

    try {
      final parsed = MostPopularResponse.fromJson((res.data as Map).cast<String, dynamic>());
      emit(MostPopularState.loaded(parsed.items));
    } catch (_) {
      emit(const MostPopularState.error("فشل قراءة الأكثر شعبية"));
    }
  }
}

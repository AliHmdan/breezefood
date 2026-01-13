import 'package:bloc/bloc.dart';
import 'package:breezefood/features/dialog/Cubit/RateState.dart';
import 'package:breezefood/features/dialog/RateApiService.dart';


class RateCubit extends Cubit<RateState> {
  final RateApiService api;

  RateCubit(this.api) : super(RateState());

  void selectRate(int value) {
    emit(state.copyWith(selectedRate: value));
  }

  Future<void> submitRate(int restaurantId) async {
    emit(state.copyWith(isLoading: true));

    final result = await api.createRate(
      restaurantId: restaurantId,
      rate: state.selectedRate,
    );

    emit(state.copyWith(
      isLoading: false,
      rateModel: result,
    ));
  }

  Future<void> updateRate() async {
    if (state.rateModel == null) return;

    emit(state.copyWith(isLoading: true));

    final result = await api.updateRate(
      rateId: state.rateModel!.id,
      rate: state.selectedRate,
    );

    emit(state.copyWith(
      isLoading: false,
      rateModel: result,
    ));
  }

  Future<void> deleteRate() async {
    if (state.rateModel == null) return;

    emit(state.copyWith(isLoading: true));
    await api.deleteRate(state.rateModel!.id);

    emit(RateState());
  }
}

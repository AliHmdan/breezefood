
import 'package:breezefood/features/dialog/Model.dart';

class RateState {
  final int selectedRate;
  final bool isLoading;
  final RateModel? rateModel;

  RateState({
    this.selectedRate = 0,
    this.isLoading = false,
    this.rateModel,
  });

  RateState copyWith({
    int? selectedRate,
    bool? isLoading,
    RateModel? rateModel,
  }) {
    return RateState(
      selectedRate: selectedRate ?? this.selectedRate,
      isLoading: isLoading ?? this.isLoading,
      rateModel: rateModel ?? this.rateModel,
    );
  }
}

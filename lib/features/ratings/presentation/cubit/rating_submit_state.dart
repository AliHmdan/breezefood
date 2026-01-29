part of 'rating_submit_cubit.dart';

@freezed
class RatingSubmitState with _$RatingSubmitState {
  const factory RatingSubmitState.initial() = _Initial;
  const factory RatingSubmitState.loading() = _Loading;
  const factory RatingSubmitState.success() = _Success;
  const factory RatingSubmitState.deleteSuccess() = _DeleteSuccess;
  const factory RatingSubmitState.error(String message) = _Error;
}

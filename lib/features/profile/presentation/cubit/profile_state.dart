part of 'profile_cubit.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = _Loading;
  const factory ProfileState.error(String message) = _Error;

  const factory ProfileState.loaded({
    required UserModel user,
    required List<AddressModel> addresses,
    @Default(false) bool isSaving,
    String? message,
  }) = _Loaded;
}

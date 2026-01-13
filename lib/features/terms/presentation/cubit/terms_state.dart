part of 'terms_cubit.dart';

@freezed
class TermsState with _$TermsState {
  const factory TermsState.initial() = _Initial;
  const factory TermsState.loading() = _Loading;
  const factory TermsState.error(String message) = _Error;
  const factory TermsState.loaded(TermsResponse data) = _Loaded;
}

import 'package:breezefood/features/search/data/models/search_response.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_state.freezed.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    @Default(false) bool loading,
    String? error,
    String? provinceDetected,
    @Default(<String>[]) List<String> history,
    @Default(<SearchBlock>[]) List<SearchBlock> results,
  }) = _SearchState;
}

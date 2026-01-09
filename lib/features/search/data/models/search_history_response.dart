import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_history_response.freezed.dart';
part 'search_history_response.g.dart';

@freezed
class SearchHistoryResponse with _$SearchHistoryResponse {
  const factory SearchHistoryResponse({
    @Default(<SearchHistoryItem>[]) List<SearchHistoryItem> history,
  }) = _SearchHistoryResponse;

  factory SearchHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryResponseFromJson(json);
}

@freezed
class SearchHistoryItem with _$SearchHistoryItem {
  const factory SearchHistoryItem({
    required int id,
    @JsonKey(name: 'user_id') required int userId,
    required String query,
    @JsonKey(name: 'searched_at') required String searchedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
  }) = _SearchHistoryItem;

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryItemFromJson(json);
}

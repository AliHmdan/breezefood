import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_response.freezed.dart';
part 'search_response.g.dart';

@freezed
class SearchResponse with _$SearchResponse {
  const factory SearchResponse({
    required bool success,
    @JsonKey(name: 'has_coordinates') required bool hasCoordinates,
    @JsonKey(name: 'province_detected') String? provinceDetected,
    @Default(<SearchBlock>[]) List<SearchBlock> data,
  }) = _SearchResponse;

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);
}

@freezed
class SearchBlock with _$SearchBlock {
  const factory SearchBlock({
    required SearchRestaurant restaurant,
    @Default(<SearchItem>[]) List<SearchItem> items,
  }) = _SearchBlock;

  factory SearchBlock.fromJson(Map<String, dynamic> json) =>
      _$SearchBlockFromJson(json);
}

@freezed
class SearchRestaurant with _$SearchRestaurant {
  const factory SearchRestaurant({
    required int id,
    required String name,
    String? logo,
    SearchRating? rating,
  }) = _SearchRestaurant;

  factory SearchRestaurant.fromJson(Map<String, dynamic> json) =>
      _$SearchRestaurantFromJson(json);
}

@freezed
class SearchRating with _$SearchRating {
  const factory SearchRating({
    double? avg,
    @JsonKey(name: 'count') @Default(0) int count,
  }) = _SearchRating;

  factory SearchRating.fromJson(Map<String, dynamic> json) =>
      _$SearchRatingFromJson(json);
}

@freezed
class SearchItem with _$SearchItem {
  const factory SearchItem({
    required int id,
    @JsonKey(name: 'base_price') required String basePrice,
    required SearchItemNames names,
    @JsonKey(name: 'orders_count') @Default(0) int ordersCount,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _SearchItem;

  factory SearchItem.fromJson(Map<String, dynamic> json) =>
      _$SearchItemFromJson(json);
}

@freezed
class SearchItemNames with _$SearchItemNames {
  const factory SearchItemNames({
    @Default('') String ar,
    @Default('') String en,
  }) = _SearchItemNames;

  factory SearchItemNames.fromJson(Map<String, dynamic> json) =>
      _$SearchItemNamesFromJson(json);
}

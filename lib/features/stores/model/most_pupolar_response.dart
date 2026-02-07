import 'package:breezefood/features/home/model/home_response.dart';

class MostPopularResponse {
  final List<MenuItemModel> items;
  MostPopularResponse({required this.items});

  factory MostPopularResponse.fromJson(Map<String, dynamic> json) {
    final raw = json["menu_items"];

    final list = (raw is List)
        ? raw
            .whereType<Map>()
            .map((e) => MenuItemModel.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <MenuItemModel>[];

    return MostPopularResponse(items: list);
  }
}

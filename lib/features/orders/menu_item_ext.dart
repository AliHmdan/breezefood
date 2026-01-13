// menu_item_extensions.dart
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';

extension MenuItemModelX on MenuItemModel {
  double get currentPrice => (priceAfter > 0 ? priceAfter : priceBefore);
  double get beforePrice => priceBefore;
  String get title => nameAr.isNotEmpty ? nameAr : nameEn;
  String get imageUrlOrEmpty => primaryImage?.imageUrl ?? "";
}

extension MenuItemX on MenuItem {
  double get currentPrice => (price ?? 0).toDouble();
  double get beforePrice => (price ?? 0).toDouble();
  String get title => nameAr.isNotEmpty ? nameAr : nameEn;
  String get imageUrlOrEmpty => image ?? ""; // 🔴 مهم
}

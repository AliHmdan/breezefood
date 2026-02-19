import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:flutter/material.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';

class RestaurantDetailsMapper {
  static String imageUrl(String? raw) {
    if (raw == null) return "";
    var v = raw.trim();
    if (v.isEmpty) return "";

    if (v.startsWith("C:/") || v.startsWith("C:\\") || v.contains("xampp/tmp")) {
      return "";
    }

    if (v.startsWith("http://") || v.startsWith("https://")) {
      return v;
    }

    if (!v.startsWith("/")) v = "/$v";
    v = v.replaceAll(RegExp(r'/{2,}'), '/');

    if (!v.startsWith("/uploads/")) {
      v = "/uploads$v";
      v = v.replaceAll(RegExp(r'/{2,}'), '/');
    }

    return UrlHelper.toFullUrl(v) ?? "";
  }

  static String pickSingleLangFromMixed(String s, BuildContext context) {
    final v = s.trim();
    if (v.isEmpty) return "";

    final separators = ['|', '/', '\n', ' - ', ' — ', ' – '];
    for (final sep in separators) {
      if (v.contains(sep)) {
        final parts = v
            .split(sep)
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (parts.length >= 2) {
          return context.isAr ? parts.first : parts[1];
        }
      }
    }
    return v;
  }

  static MenuItemModel mapMenuItemToHomeModel({
    required MenuItem it,
    required String imageUrl,
  }) {
    return MenuItemModel(
      id: it.id,
      nameAr: it.nameAr,
      nameEn: it.nameEn,
      priceBefore: (it.priceBefore > 0 ? it.priceBefore : it.price),
      priceAfter: it.effectivePrice,
      hasDiscount: it.hasDiscount,
      discountType: it.discountType,
      discountValue: it.discountPercent,
      isFavorite: it.isFavorite,
      primaryImage: imageUrl.isEmpty
          ? null
          : PrimaryImageModel(
              imageUrl: imageUrl,
            ),
      restaurant: null,
    );
  }
}

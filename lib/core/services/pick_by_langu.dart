import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

extension LangPick on BuildContext {
  bool get isAr => locale.languageCode == 'ar';

  String pick({
    required String ar,
    required String en,
    String? fallback,
  }) {
    final v = isAr ? ar : en;
    if (v.trim().isNotEmpty) return v;
    return (fallback ?? (isAr ? en : ar)).trim().isNotEmpty
        ? (fallback ?? (isAr ? en : ar))
        : "";
  }
}

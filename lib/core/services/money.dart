import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

extension MoneyFormatter on BuildContext {
  String money(num value, {int decimals = 0}) {
    final isAr = locale.languageCode == "ar";

    final formatted = NumberFormat.decimalPattern().format(
      decimals == 0 ? value.round() : value,
    );

    // عربي: ل.س  | إنكليزي: SP
    return isAr ? "$formatted ل.س" : "$formatted SP";
  }
}
extension MoneyStringFormatter on String {
  /// "1200.00" -> context.money(1200)
  String money(BuildContext context, {int decimals = 0}) {
    final cleaned = replaceAll(RegExp(r'[^0-9\.\-]'), '');
    final value = num.tryParse(cleaned);

    if (value == null) return this; // fallback آمن
    return context.money(value, decimals: decimals);
  }
}

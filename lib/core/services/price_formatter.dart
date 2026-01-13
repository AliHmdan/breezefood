import 'package:intl/intl.dart';

extension PriceStringFormatting on String {
  static final NumberFormat _formatter = NumberFormat.decimalPattern();
  String get priceWithSuffix {
    final value = num.tryParse(this);
    if (value == null) return this;
    return "${_formatter.format(value)} ل.س";
  }
}

extension PriceFormatting on num {
  /// 9000 -> 9,000 ل.س
  String get priceWithSuffix {
    final formatter = NumberFormat('#,###', 'en_US');
    return '${formatter.format(this)} ل.س';
  }

  /// 9000 -> 9,000 (بدون عملة)
  String get priceFormatted {
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(this);
  }
}

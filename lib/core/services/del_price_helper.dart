import 'package:easy_localization/easy_localization.dart';

// ✅ نوع الهوم
import 'package:breezefood/features/home/model/home_response.dart' as home;

// ✅ نوع الستوردز / الديتيلز
import 'package:breezefood/features/stores/model/restaurant_details_model.dart'
    as store;

/// Helper واحد يشتغل مع:
/// - home.HomeRestaurantModel
/// - store.RestaurantModel
String deliveryFeeText(Object r) {
  num? fee;

  // ===================== HOME MODEL =====================
  if (r is home.HomeRestaurantModel) {
    // الأفضل: delivery.final_fee (إذا موجود)
    final finalFee = r.delivery?.finalFee;
    if (finalFee != null && finalFee > 0) {
      fee = finalFee;
    } else if (r.deliveryBaseFee > 0) {
      fee = r.deliveryBaseFee;
    } else {
      fee = null;
    }
  }

  // ===================== STORES MODEL =====================
  else if (r is store.RestaurantModel) {
    // ⚠️ هون لازم يكون عند RestaurantModel حقول مشابهة:
    // delivery?.finalFee و deliveryBaseFee
    final finalFee = r.delivery?.finalFee;
    if (finalFee != null && finalFee > 0) {
      fee = finalFee;
    } else if ((r.deliveryBaseFee ?? 0) > 0) {
      fee = r.deliveryBaseFee!;
    } else {
      fee = null;
    }
  }

  // ===================== UNKNOWN =====================
  else {
    fee = null;
  }

  if (fee == null || fee <= 0) {
    return "common.dash".tr(); // "--"
  }

  // صياغة لطيفة (بدون كسور)
  final feeStr = (fee is int) ? fee.toString() : fee.toStringAsFixed(0);

  return "stores.delivery_fee_short".tr(
    namedArgs: {"fee": feeStr},
  );
}

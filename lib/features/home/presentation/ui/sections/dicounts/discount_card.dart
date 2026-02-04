import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Discount extends StatelessWidget {
  final String imagePath;
  final String subtitle;
  final dynamic
  price; // main price (meal price OR delivery final fee حسب استخدامك)
  final String discount;

  // ✅ Delivery prices (optional)
  final dynamic deliveryOldPrice; // base_fee
  final dynamic deliveryNewPrice; // final_fee
  final bool showDeliveryPrices;

  // ✅ Discount type badges (optional)
  final bool hasFoodDiscount;
  final bool hasDeliveryDiscount;

  final double rating;
  final int ratingCount;

  final void Function()? onTap;

  const Discount({
    super.key,
    required this.imagePath,
    required this.subtitle,
    required this.price,
    required this.discount,
    required this.rating,
    this.ratingCount = 0,
    this.onTap,

    this.deliveryOldPrice,
    this.deliveryNewPrice,
    this.showDeliveryPrices = false,

    this.hasFoodDiscount = false,
    this.hasDeliveryDiscount = false,
  });

  bool _hasDeliveryPrices() {
    final a = deliveryOldPrice;
    final b = deliveryNewPrice;
    final hasA = a != null && (a is num ? a > 0 : true);
    final hasB = b != null && (b is num ? b > 0 : true);
    return hasA || hasB;
  }

  String _badgeText() {
    final f = hasFoodDiscount;
    final d = hasDeliveryDiscount;
    if (f && d) return "BOTH";
    if (f) return "FOOD";
    if (d) return "DELIVERY";
    return "";
  }

  Color _badgeColor() {
    final f = hasFoodDiscount;
    final d = hasDeliveryDiscount;
    if (f && d) return Colors.purple;
    if (f) return Colors.green;
    if (d) return Colors.blue;
    return Colors.transparent;
  }

  Widget _buildImage(String url, {required double height}) {
    final u = url.trim();
    if (u.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey.shade800,
        alignment: Alignment.center,
        child: Icon(Icons.store, color: AppColor.white, size: 30.sp),
      );
    }

    return Image.network(
      u,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (c, child, progress) {
        if (progress == null) return child;
        return Container(
          height: height,
          color: Colors.black.withOpacity(0.15),
          alignment: Alignment.center,
          child: SizedBox(
            width: 22.w,
            height: 22.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        height: height,
        color: Colors.grey.shade800,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported,
          color: AppColor.white,
          size: 30.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ratingText = (rating <= 0)
        ? "no_ratings_yet".tr()
        : rating.toStringAsFixed(1);

    final showDelPrices = showDeliveryPrices && _hasDeliveryPrices();
    final badge = _badgeText();

    // ✅ أهم جزء: إذا في delivery prices قلّل ارتفاع الصورة + المسافات
    final imageH = showDelPrices ? 92.h : 100.h;
    final gapH = showDelPrices ? 4.h : 6.h;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
         borderRadius: BorderRadius.circular(5.r),
        child: SizedBox(
          width: 160.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5.r),
                    child: _buildImage(imagePath, height: imageH),
                  ),
      
                  // ✅ rating chip
                  PositionedDirectional(
                    top: 6,
                    end: 6,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.30),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 12.sp),
                          SizedBox(width: 3.w),
                          Text(
                            ratingText,
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      
                  // ✅ overlay name
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.75),
                            Colors.black.withOpacity(0.45),
                            Colors.black.withOpacity(0.15),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.35, 0.65, 1.0],
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
      
                  // ✅ discount chip
                  if (discount.trim().isNotEmpty)
                    PositionedDirectional(
                      bottom: 0,
                      start: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadiusDirectional.only(
                            topEnd: Radius.circular(20.r),
                            bottomEnd: Radius.circular(20.r),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              discount,
                              style: TextStyle(
                                color: AppColor.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            SvgPicture.asset(
                              "assets/icons/nspah.svg",
                              width: 18.w,
                              height: 18.h,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      
              SizedBox(height: gapH),
      
              // "assets/icons/motor.svg",
              if (showDelPrices)
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 2.w, top: 2.h),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        color: Colors.white,
                        "assets/icons/motor.svg",
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (deliveryOldPrice != null) ...[
                                Text(
                                  context.syp(deliveryOldPrice, decimals: 0),
                                  style: TextStyle(
                                    color: AppColor.LightActive,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                              ],
                              if (deliveryNewPrice != null)
                                Text(
                                  context.syp(deliveryNewPrice, decimals: 0),
                                  style: TextStyle(
                                    color: AppColor.red,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

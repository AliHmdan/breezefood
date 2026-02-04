import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/sections/dicounts/discount_card.dart';
import 'package:breezefood/features/home/presentation/ui/sections/most_popular.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class DiscountHome extends StatelessWidget {
  final List<RestaurantDiscountModel> discounts;

  const DiscountHome({super.key, required this.discounts});

  String _discountText(RestaurantDiscountModel d) {
    final food = d.foodDiscount;
    if (food != null) {
      final type = food.discountType.toLowerCase();
      final v = food.discountValue;
      if (v <= 0) return "";
      if (type.contains('percent')) return "${v.toStringAsFixed(0)}%";
      return v.toStringAsFixed(0);
    }

    final del = d.deliveryDiscount;
    if (del != null) {
      final type = del.discountType.toLowerCase();
      final v = del.discountValue;
      if (v <= 0) return "";
      if (type.contains('percent')) return "${v.toStringAsFixed(0)}%";
      return v.toStringAsFixed(0);
    }

    return "";
  }

  String _logoUrl(RestaurantDiscountModel d) =>
      UrlHelper.toFullUrl(d.logoSafe) ?? "";

  @override
  Widget build(BuildContext context) {
    if (discounts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomTitleSection(
            title: "Discounts",
            all: "All",
            icon: Icons.arrow_forward_ios_outlined,
            ontap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      DiscountRestaurantsGridPage(discounts: discounts),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 8, right: 0.2),
          child: SizedBox(
            height: 130.h,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / 2.2;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: discounts.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final d = discounts[index];
                    final base = d.deliveryDiscount?.delivery?.baseFee;
                    final fin = d.deliveryDiscount?.delivery?.finalFee;
                    return Container(
                      width: itemWidth,
                      margin: EdgeInsetsDirectional.only(end: 10.w),
                      child: Discount(
                        onTap: () =>
                            openRestaurantById(context, d.restaurantId),
                        imagePath: _logoUrl(d),
                        subtitle: d.restaurantName,
                        price: 0,
                        discount: _discountText(d),
                        rating: d.ratingAvg,
                        ratingCount: d.ratingCount,

                        // ✅ badges
                        hasFoodDiscount: d.foodDiscount != null,
                        hasDeliveryDiscount: d.deliveryDiscount != null,

                        // ✅ show delivery prices إذا موجودة
                        showDeliveryPrices: true,
                        deliveryOldPrice: base,
                        deliveryNewPrice: fin,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class DiscountRestaurantsGridPage extends StatelessWidget {
  final List<RestaurantDiscountModel> discounts;

  const DiscountRestaurantsGridPage({super.key, required this.discounts});

  int _getCrossAxisCount(double width) {
    if (width < 600) return 2;
    if (width < 1000) return 3;
    return 4;
  }

  String _logoUrl(RestaurantDiscountModel d) =>
      UrlHelper.toFullUrl(d.logoSafe) ?? "";

  String _discountText(RestaurantDiscountModel d) {
    final food = d.foodDiscount;
    if (food != null) {
      final type = (food.discountType ?? "").toLowerCase();
      final v = food.discountValue ?? 0;
      if (v <= 0) return "";
      if (type.contains('percent')) return "${v.toStringAsFixed(0)}%";
      return v.toStringAsFixed(0);
    }

    final del = d.deliveryDiscount;
    if (del != null) {
      final type = (del.discountType ?? "").toLowerCase();
      final v = del.discountValue ?? 0;
      if (v <= 0) return "";
      if (type.contains('percent')) return "${v.toStringAsFixed(0)}%";
      return v.toStringAsFixed(0);
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomAppbarProfile(
            title: "Discounts",
            icon: Icons.arrow_back_ios,
            ontap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

            return GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 10.w,

                // ✅ أطول شوي = مسافة كافية للـ name + badge
                childAspectRatio: 0.92,
              ),
              itemCount: discounts.length,
              itemBuilder: (context, index) {
                final d = discounts[index];
                final discount = _discountText(d);

                return InkWell(
                  onTap: () => openRestaurantById(context, d.restaurantId),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.black,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),

                    // ✅ ديناميك: نتحكم بحجم الصورة حسب ارتفاع التايل
                    child: LayoutBuilder(
                      builder: (context, tile) {
                        final tileH = tile.maxHeight;

                        // الصورة ~60% من ارتفاع الكرت وبحد أقصى 120.h
                        final imageH = math.min(120.h, tileH * 0.60);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.r),
                              ),
                              child: Image.network(
                                _logoUrl(d),
                                height: imageH,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: imageH,
                                  color: Colors.grey.shade800,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.store,
                                    color: Colors.white70,
                                    size: 30.sp,
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(10.w),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.restaurantName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                        fontFamily:
                                            Localizations.localeOf(
                                                  context,
                                                ).languageCode ==
                                                'ar'
                                            ? 'Cairo'
                                            : 'Inter',
                                      ),
                                    ),

                                    const Spacer(),

                                    if (discount.trim().isNotEmpty)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.55),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.10,
                                            ),
                                          ),
                                        ),

                                        // ✅ هون كان يصير overflow: خليه يكمّش نفسه
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            discount,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w800,
                                              fontFamily:
                                                  Localizations.localeOf(
                                                        context,
                                                      ).languageCode ==
                                                      'ar'
                                                  ? 'Cairo'
                                                  : 'Inter',
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

Future<void> openRestaurantById(BuildContext context, int restaurantId) async {
  if (restaurantId == 0) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ResturantDetails(restaurant_id: restaurantId),
    ),
  );
}

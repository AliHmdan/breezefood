import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'rd_tabs_bar.dart';

class RDStickyInfoTabsSliver extends StatelessWidget {
  const RDStickyInfoTabsSliver({
    super.key,
    required this.deliveryTimeText,
    required this.deliveryBaseText,
    required this.deliveryFinalText,
    required this.showTwoPrices,
    required this.categories,
    required this.activeIndex,
    required this.onTapCategory,
    required this.divider,
    required this.roundedTop,

    // ✅ rating tap (بدك تحافظ عليها)
    required this.avgRatingText,
    required this.reviewsCountText,
    required this.onRateTap,
  });

  final String deliveryTimeText;
  final String deliveryBaseText;
  final String deliveryFinalText;
  final bool showTwoPrices;
  final bool roundedTop;

  final List<String> categories;
  final int activeIndex;
  final ValueChanged<int> onTapCategory;
  final Widget divider;

  final String avgRatingText;
  final String reviewsCountText;
  final VoidCallback onRateTap;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _RDStickyDelegate(
        roundedTop: roundedTop,
        child: Transform.translate(
          offset: Offset(0, roundedTop ? 0 : 0),
          child: Material(
            clipBehavior: Clip.antiAlias,
            borderRadius: roundedTop
                ? BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  )
                : BorderRadius.zero,
            child: Container(
              color: roundedTop ? AppColor.Dark : AppColor.Dark,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.Dark,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onRateTap,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    avgRatingText,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: context.isAr
                                          ? 'Cairo'
                                          : 'Inter',
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    "($reviewsCountText)",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.65),
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: context.isAr
                                          ? 'Cairo'
                                          : 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          divider,

                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_shipping_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(height: 4.h),
                                if (showTwoPrices) ...[
                                  Text(
                                    deliveryBaseText,
                                    style: TextStyle(
                                      color: AppColor.LightActive,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: context.isAr
                                          ? 'Cairo'
                                          : 'Inter',
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    deliveryFinalText,
                                    style: TextStyle(
                                      color: AppColor.red,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: context.isAr
                                          ? 'Cairo'
                                          : 'Inter',
                                    ),
                                  ),
                                ] else
                                  Text(
                                    deliveryFinalText,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: context.isAr
                                          ? 'Cairo'
                                          : 'Inter',
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          divider,

                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  deliveryTimeText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: context.isAr
                                        ? 'Cairo'
                                        : 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===== Tabs =====
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: RDTabsBar(
                      categories: categories,
                      activeIndex: activeIndex,
                      onTap: onTapCategory,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RDStickyDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool roundedTop;

  _RDStickyDelegate({required this.child, required this.roundedTop});

  @override
  bool shouldRebuild(covariant _RDStickyDelegate old) {
    return old.roundedTop != roundedTop || old.child != child;
  }

  @override
  double get minExtent => 130.h;

  @override
  double get maxExtent => 130.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }
}

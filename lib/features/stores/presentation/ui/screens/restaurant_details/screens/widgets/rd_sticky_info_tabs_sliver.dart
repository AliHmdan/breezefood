import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'rd_tabs_bar.dart';

class RDStickyInfoTabsSliver extends StatelessWidget {
  const RDStickyInfoTabsSliver({
    super.key,
    required this.description,
    required this.deliveryTimeText,
    required this.deliveryBaseText,
    required this.deliveryFinalText,
    required this.showTwoPrices,
    required this.categories,
    required this.activeIndex,
    required this.onTapCategory,
    required this.divider,
    required this.tabsController,
    required this.tabKeys,
  });

  final String description;

  final String deliveryTimeText;
  final String deliveryBaseText;
  final String deliveryFinalText;
  final bool showTwoPrices;

  final List<String> categories;
  final int activeIndex;
  final ValueChanged<int> onTapCategory;
  final Widget divider;
  final ScrollController tabsController;
  final List<GlobalKey> tabKeys;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        child: Container(
          color: AppColor.Dark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/icons/motor.png",
                          width: 40.w,
                          height: 40.w,
                        ),
                        SizedBox(width: 6.w),
                        if (showTwoPrices) ...[
                          Text(
                            deliveryBaseText,
                            style: TextStyle(
                              color: AppColor.LightActive,
                              decoration: TextDecoration.lineThrough,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              fontFamily: context.isAr ? 'Cairo' : 'Inter',
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            deliveryFinalText,
                            style: TextStyle(
                              color: AppColor.red,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w900,
                              fontFamily: context.isAr ? 'Cairo' : 'Inter',
                            ),
                          ),
                        ] else ...[
                          Text(
                            deliveryFinalText,
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w900,
                              fontFamily: context.isAr ? 'Cairo' : 'Inter',
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(width: 45.w),
                    divider,
                    const Spacer(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/icons/time.png",
                          width: 40.w,
                          height: 40.w,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          deliveryTimeText,
                          style: TextStyle(
                            color: AppColor.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w900,
                            fontFamily: context.isAr ? 'Cairo' : 'Inter',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 15.w),
                    const Spacer(),
                  ],
                ),
              ),

              RDTabsBar(
                categories: categories,
                activeIndex: activeIndex,
                onTap: onTapCategory,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StickyHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 140.h;

  @override
  double get maxExtent => 140.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

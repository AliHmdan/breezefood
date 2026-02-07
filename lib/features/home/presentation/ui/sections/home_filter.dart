import 'package:breezefood/core/component/color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeFilters extends StatelessWidget {
  final void Function(String id) onFilterTap;
  const HomeFilters({super.key, required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    final items = <_HomeFilterItem>[
      _HomeFilterItem(id: "closer", titleKey: "home.filters.closer"),
      _HomeFilterItem(id: "breakfast", titleKey: "home.filters.breakfast"),
      _HomeFilterItem(id: "stores", titleKey: "home.filters.stores"),
      _HomeFilterItem(id: "discounts", titleKey: "home.filters.discounts"),
      _HomeFilterItem(id: "delivery", titleKey: "home.filters.delivery"),
      _HomeFilterItem(id: "supermarket", titleKey: "home.filters.supermarket"),
      _HomeFilterItem(id: "open", titleKey: "home.filters.open"),
    ];

    return SizedBox(
      height: 54.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final it = items[index];
          return GestureDetector(
            onTap: () => onFilterTap(it.id),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Center(
                child: Text(
                  it.titleKey.tr(),
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeFilterItem {
  final String id;
  final String titleKey;
  _HomeFilterItem({required this.id, required this.titleKey});
}

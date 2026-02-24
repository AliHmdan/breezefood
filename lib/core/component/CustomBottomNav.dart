import 'dart:ui';
import 'package:breezefood/core/component/color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavBreeze extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const BottomNavBreeze({super.key, required this.currentIndex, required this.onChanged});

  static const double _barHeight = 60;

  static const List<String> _svgIcons = [
    'assets/icons/home-linear.svg',
    'assets/icons/stores.svg',
    'assets/icons/favorite.svg',
    'assets/icons/ordernav.svg',
    'assets/icons/profile.svg',
  ];

  static const List<String> _labelKeys = ["nav.home", "nav.stores", "nav.favorites", "nav.orders", "nav.Profile"];

  Widget _icon(String path, {required bool selected, double size = 22}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      // colorFilter: ColorFilter.mode(selected ? AppColor.white : AppColor.gry.withOpacity(0.8), BlendMode.srcIn),
      colorFilter: ColorFilter.mode(selected ? AppColor.white : AppColor.gryForNavBar.withOpacity(0.8), BlendMode.srcIn),
    );
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      top: false,
      child: Container(
        height: 60.h, // 👈 ارتفاع متوازن
        decoration: BoxDecoration(
          // color: Colors.white.withOpacity(0.08),
          color: AppColor.Dark,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_svgIcons.length, (index) {
            final isSelected = currentIndex == index;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(index),
                child: SizedBox(
                  // width: 78.w, // 👈 عرض ثابت = ما في رجفة
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    // padding: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColor.primaryColor : Colors.transparent,
                      borderRadius: BorderRadiusDirectional.only(
                        bottomStart: Radius.circular(index == 0 ? 0 : 12.r),
                        bottomEnd: Radius.circular(index == 4 ? 0 : 12.r),
                        topEnd: Radius.circular(index == 4 ? 0 : 12.r),
                        topStart: Radius.circular(index == 0 ? 0 : 12.r),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _icon(_svgIcons[index], selected: isSelected, size: index == 4 ? 18.sp : 22.sp),

                        // 👇 أنيميشن ظهور/اختفاء النص
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isSelected ? 1 : 0,
                            child: isSelected
                                ? Padding(
                                    padding: EdgeInsets.only(top: 4.h),
                                    child: Text(
                                      _labelKeys[index].tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColor.white,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: Localizations.localeOf(context).languageCode == 'ar' ? 'Cairo' : 'Inter',
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

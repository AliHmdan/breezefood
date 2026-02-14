import 'dart:ui';
import 'package:breezefood/core/component/color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavBreeze extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const BottomNavBreeze({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  static const double _barHeight = 60;

  static const List<String> _svgIcons = [
    'assets/icons/home-linear.svg',
    'assets/icons/stores.svg',
    'assets/icons/favorite.svg',
    'assets/icons/ordernav.svg',
  ];

  static const List<String> _labelKeys = [
    "nav.home",
    "nav.stores",
    "nav.favorites",
    "nav.orders",
  ];

  Widget _icon(String path, {required bool selected, double size = 22}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        selected ? AppColor.white : AppColor.gry.withOpacity(0.8),
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxLabelWidth = 72.w; // عدّلها إذا بدك، بس هي غالباً ممتازة

    return SafeArea(
      top: false,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: _barHeight,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_svgIcons.length, (index) {
                final isSelected = currentIndex == index;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(index),
                  child: SizedBox(
                    width: 95.w, // ✅ عرض ثابت = لا رجفة
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      height: 40.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w, // ✅ ثابت
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _icon(
                            _svgIcons[index],
                            selected: isSelected,
                            size: 22.sp,
                          ),

                          // ✅ الأنيميشن صار داخلي فقط
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.centerLeft,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: isSelected ? 1 : 0,
                              child: isSelected
                                  ? Padding(
                                      padding: EdgeInsets.only(left: 4.w),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: maxLabelWidth,
                                        ),
                                        child: Text(
                                          _labelKeys[index].tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: "Manrope",
                                          ),
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
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

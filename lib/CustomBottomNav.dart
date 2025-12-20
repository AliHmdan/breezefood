// bottom_nav_breeze.dart
import 'dart:ui';
import 'package:breezefood/component/color.dart';
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

  static const List<String> _labels = ["Home", "Stores", "Favorites", "Orders"];

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
                  child: ConstrainedBox(constraints: BoxConstraints(
    minWidth: 50.w,
    maxWidth: 150.w, // حد أقصى للكرد لمنع الانفجار
  ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      // width: isSelected ? 113.w : 50.w,
                      height: 40.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 12.w : 0,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // مهم ليتبع المحتوى
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _icon(
                            _svgIcons[index],
                            selected: isSelected,
                            size: 22.sp,
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: isSelected
                                ? Padding(
                                    key: ValueKey(index),
                                    padding: EdgeInsets.only(left: 4.w),
                                    child: Flexible(
                                      child: Text(
                                        _labels[index],
                                        maxLines: 1,
                                        softWrap: false,
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

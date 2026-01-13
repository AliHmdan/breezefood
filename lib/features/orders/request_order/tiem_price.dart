import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';


class TiemPrice extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? svgPath;
  const TiemPrice({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.svgPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3),
      width: 90.w,
      height: 28.h,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, color: AppColor.Dark, size: 16.sp)
          else if (svgPath != null)
            SvgPicture.asset(
              svgPath!,
              width: 20.w,
              height: 20.h,
              color: AppColor.Dark,
            ),

          Row(
            children: [
              CustomSubTitle(
                subtitle: title,
                color: AppColor.Dark,
                fontsize: 11.sp,
              ),
              CustomSubTitle(
                subtitle: subtitle,
                color: AppColor.Dark,
                fontsize: 12.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

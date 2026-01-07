import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';


class LocationChip extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback? onTap; // دالة عند الضغط

  const LocationChip({
    super.key,
    required this.text,
    required this.iconPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft, // <-- يضعه في البداية
      child: InkWell(
        borderRadius: BorderRadius.circular(30.r), 
        onTap: onTap, // عند الضغط
        child: Container(
          margin: EdgeInsets.only( top: 12.h), // مسافة من الأعلى واليسار
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColor.black, 
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // دائرة بيضاء للأيقونة
              Container(
                width: 28.w,
                height: 28.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.white,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: 16.w,
                    height: 16.h,
                    color: AppColor.black,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              // النص

              CustomSubTitle(subtitle: text, color: AppColor.white, fontsize: 12.sp)
            ],
          ),
        ),
      ),
    );
  }
}

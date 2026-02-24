import 'dart:ui';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClosedOverlay extends StatelessWidget {
  ClosedOverlay({super.key, required this.opensAtLabel});
  String opensAtLabel;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45), // رمادي/أسود شفاف
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),

                child: CustomSubTitle(subtitle: "restaurant.closed".tr(), color: Colors.white, fontsize: 13.sp),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 6.h,

            end: 18.w,
            child: Center(
              child: CustomSubTitle(subtitle: opensAtLabel, color: AppColor.red, fontsize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }
}

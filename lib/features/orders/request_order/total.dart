import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget Total(String title, num value, {bool isTotal = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomSubTitle(
          subtitle: title,
          color: AppColor.gry,
          fontsize: isTotal ? 16.sp : 14.sp,
        ),
        Builder(
          builder: (context) => CustomSubTitle(
            subtitle: context.syp(value),
            color: AppColor.gry,
            fontsize: isTotal ? 16.sp : 14.sp,
          ),
        ),
      ],
    ),
  );
}

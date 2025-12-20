import 'package:breezefood/component/color.dart' show AppColor;
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TitleLocation extends StatelessWidget {
  const TitleLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(

      decoration: BoxDecoration(
        color: AppColor.black,
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: ListTile(
        leading: Icon(
          Icons.location_on,
          color: AppColor.white,
          size: 14.sp,
        ),
        title: CustomSubTitle(
          subtitle:
          "8943 Poplar Ave, Fontana, CA",
          color: AppColor.white,
          fontsize: 12.sp,
        ),
        trailing:Icon(
          Icons.arrow_forward_ios,
          color: AppColor.white,
          size: 12.sp,
        ),
      ),
    );
  }
}

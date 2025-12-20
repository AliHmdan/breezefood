
import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CouponCard extends StatelessWidget {
  final String code;
  final bool applied;

  const CouponCard({super.key, required this.code, this.applied = true});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(

      // options: RectDottedBorderOptions(
      //   color: Colors.white, // ✅ إذا عندك AppColor، غيرها إلى AppColor.white
      //   strokeWidth: 1.5,
      //   dashPattern: const [6, 4],
      // ),


      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            // أيقونة

            Image.asset("assets/icons/Discount.png",width: 32.w,       // set size
                  height: 32.h,
            fit: BoxFit.contain,),
            SizedBox(width: 8.w),

            // كود الخصم
            Expanded(
              child: CustomSubTitle(
                subtitle: code,
                color: AppColor.white,
                fontsize: 14.sp,
              ),
            ),
            // زر Applied
            if (applied)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check, color: AppColor.white, size: 20.sp),
                    SizedBox(width: 4.w),
                    Text(
                      "Applied",
                      style: TextStyle(
                        color: AppColor.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

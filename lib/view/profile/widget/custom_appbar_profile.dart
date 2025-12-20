import 'package:breezefood/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppbarProfile extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final void Function() ontap;
  const CustomAppbarProfile({
    super.key,
    this.icon,
    this.subtitle,
     this.title,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// الأيقونة داخل دائرة
        if (icon != null)
          GestureDetector(
            onTap: ontap,
            child: Container(
              padding: EdgeInsets.all(4), // يحدد حجم الدائرة الداخلية
              decoration: BoxDecoration(
                color: AppColor.black, // لون الخلفية
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.LightActive, // لون الـ border
                  width: 2, // سماكة الـ border
                ),
              ),
              child: Center(
                // 👈 يضمن أن الأيقونة في الوسط تماماً
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(icon, color: AppColor.white, size: 16.sp),
                ),
              ),
            ),
          ),
        Spacer(),

        /// العنوان دايماً يظهر
         if (title != null)
        Text(
          "$title",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColor.white,
          ),
        ),

        Spacer(),
      ],
    );
  }
}

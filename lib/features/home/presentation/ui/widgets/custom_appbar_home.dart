import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_title.dart';
import 'package:breezefood/features/notification/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class CustomAppbarHome extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? image;
  final IconData? icon;

  /// ✅ كبسة صورة البروفايل
  final VoidCallback? onProfileTap;

  /// ✅ كبسة قسم الموقع (العنوان + السطر التاني)
  final VoidCallback? onLocationTap;

  const CustomAppbarHome({
    super.key,
    required this.title,
    this.subtitle,
    this.image,
    this.icon,
    this.onProfileTap,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ✅ صورة البروفايل: تفتح الإعدادات فقط
        InkWell(
          onTap: onProfileTap,
          child: CircleAvatar(
            radius: 20.r,
            child: ClipOval(
              child: Image.asset(
                'assets/images/01.jpg',
                width: 40.w,
                height: 40.h,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // ✅ النص والموقع: يفتح اختيار الموقع فقط
        Expanded(
          child: InkWell(
            onTap: onLocationTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomTitle(title: title, color: AppColor.white),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (image != null)
                        SvgPicture.asset(
                          image!,
                          color: AppColor.LightActive,
                          width: 20,
                          height: 20,
                        ),
                      SizedBox(width: image != null ? 4 : 0),
                      if (subtitle != null)
                        CustomSubTitle(
                          subtitle: "$subtitle",
                          color: AppColor.LightActive,
                          fontsize: 12.sp,
                        ),
                      if (icon != null)
                        Icon(
                          icon,
                          color: AppColor.LightActive,
                          size: 24.sp,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // ✅ الإشعارات: تبقى مثل ما هي
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
          },
          child: Container(
            width: 35.w,
            height: 35.h,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.LightActive, width: 2),
            ),
            child: SvgPicture.asset(
              'assets/icons/notification.svg',
              color: Colors.white,
              width: 20,
              height: 20,
            ),
          ),
        ),
      ],
    );
  }
}

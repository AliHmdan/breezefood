import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:breezefood/view/MainShell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

// دالة مستقلة لعرض الديالوج
void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColor.Dark,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                "assets/icons/logout.svg",
                width: 35.sp,
                height: 35.sp,
                colorFilter: const ColorFilter.mode(
                  AppColor.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 12),

              CustomSubTitle(
                subtitle: "Do you want logout?",
                color: AppColor.white,
                fontsize: 14.sp,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40.w,
                        vertical: 25.h,
                      ),
                      backgroundColor: AppColor.black,
                      foregroundColor: AppColor.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainShell()),
                      ); // إغلاق الديالوج
                      // كود تسجيل الخروج
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: CustomSubTitle(
                            subtitle: "Logged out successfully",
                            color: AppColor.white,
                            fontsize: 12.sp,
                          ),

                          backgroundColor: AppColor.primaryColor,
                        ),
                      );
                    },
                    child: CustomSubTitle(
                      subtitle: "Yes",
                      color: AppColor.white,
                      fontsize: 14.sp,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40.w,
                        vertical: 25.h,
                      ),
                      backgroundColor: AppColor.primaryColor,
                      foregroundColor: AppColor.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // إلغاء
                    },
                    child: CustomSubTitle(
                      subtitle: "Cancel",
                      color: AppColor.white,
                      fontsize: 14.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

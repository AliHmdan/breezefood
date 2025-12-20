
import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/terms/terms.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:breezefood/view/helpCenter/help_center.dart';
import 'package:breezefood/view/profile/dialog_logout.dart';
import 'package:breezefood/view/profile/info_profile.dart';
import 'package:breezefood/view/profile/language.dart';
import 'package:breezefood/view/profile/widget/custom_appbar_profile.dart';
import 'package:breezefood/view/profile/widget/listtile_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h), // ارتفاع متجاوب
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: CustomAppbarProfile(
            title: "Profile",
            icon: Icons.arrow_back_ios,
            ontap: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Column(
            children: [
              // صورة البروفايل + الاسم
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60.r,
                      backgroundImage: const AssetImage(
                        "assets/images/profile.jpg",
                      ),
                    ),
                    SizedBox(height: 12.h),
                    CustomSubTitle(
                      subtitle: "Ibrahim Ahamd",
                      color: AppColor.white,
                      fontsize: 16.sp,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // القائمة الأولى
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11.r),
                  color: AppColor.black,
                ),
                child: Column(
                  children: [
                    ListtileProfile(
                      iconData: Icons.person_outline,
                      title: "Personal info",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InfoProfile(),
                          ),
                        );
                      },
                    ),
                    ListtileProfile(
                      title: "Addresses",
                      svgPath: "assets/icons/location-line.svg",
                    ),
                    ListtileProfile(
                      svgPath: "assets/icons/language.svg",
                      title: "Language",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Language(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // القائمة الثانية
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11.r),
                  color: AppColor.black,
                ),
                child: Column(
                  children: [
                    ListtileProfile(
                      svgPath: "assets/icons/chate.svg",
                      title: "Help center",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HelpCenter()),
                        );
                      },
                    ),
                    ListtileProfile(
                      svgPath: "assets/icons/question.svg",
                      title: "Terms & Conditions",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Terms()),
                        );
                      },
                    ),
                    // ListtileProfile(
                    //   svgPath: "assets/icons/share.svg",
                    //   title: "Share app",
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => ShareAppScreen(),
                    //       ),
                    //     );
                    //   },
                    // ),
                    ListtileProfile(
                      svgPath: "assets/icons/logout.svg",
                      title: "Logout",
                      onTap: () {
                        showLogoutDialog(context); // ✅ استدعاء الدالة هنا
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

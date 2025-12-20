
import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:breezefood/view/profile/widget/custom_appbar_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class Terms extends StatefulWidget {
  const Terms({super.key});

  @override
  State<Terms> createState() => _TermsState();
}

class _TermsState extends State<Terms> {
  final List<String> items = [
    "Lorem ipsum dolor sit amet consectetur. Placerat hendrerit justo ultricies etiam. Mauris proin praesent ultrices ultrices maecenas quam. Egestas eu massa sit blandit massa sed et.",
    "Lorem ipsum dolor sit amet consectetur. Placerat hendrerit justo ultricies etiam.",
    "Lorem ipsum dolor sit amet consectetur. Placerat hendrerit justo ultricies etiam. Mauris proin praesent ultrices ultrices maecenas quam. Egestas eu massa sit blandit massa sed et.",
    "Lorem ipsum dolor sit amet consectetur. Placerat hendrerit justo ultricies etiam. Mauris proin praesent ultrices ultrices maecenas quam. Egestas eu massa sit blandit massa sed et.",
  ];

  late List<bool> _expandedList;

  @override
  void initState() {
    super.initState();
    _expandedList = List.filled(items.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h), // ارتفاع متجاوب
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: CustomAppbarProfile(
            // title: "Profile",
            icon: Icons.arrow_back_ios,
            ontap: () => Navigator.pop(context),
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 6.h), 
            decoration: BoxDecoration(
              color: AppColor.black,
              borderRadius: BorderRadius.circular(11.r), 
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: AppColor.black,
              ),
              child: ExpansionTile(
                collapsedIconColor: AppColor.gry,
                iconColor: AppColor.white,
                trailing: Icon(
                  _expandedList[index]
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 20.sp, 
                  color: AppColor.white,
                ),
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expandedList[index] = expanded;
                  });
                },
                title: CustomSubTitle(
                  subtitle: "${index + 1}. Lorem ipsum dolor sit amet",
                  color: AppColor.white,
                  fontsize: 14.sp,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w, 
                      vertical: 8.h,   
                    ),
                    child: CustomSubTitle(
                      subtitle: items[index],
                      color: AppColor.gry,
                      fontsize: 14.sp, 
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

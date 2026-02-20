import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotesField extends StatelessWidget {
  final TextEditingController controller;

  const NotesField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomSubTitle(
          subtitle: "cart.item_notes_optional".tr(),
          color: AppColor.white,
          fontsize: 14.sp,
        ),
        SizedBox(height: 16.h),
        TextField(
          controller: controller,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "cart.item_notes_hint".tr(),
            hintStyle: TextStyle(color: Colors.white54, fontSize: 12.sp),
            filled: true,
            fillColor: Colors.white10,
            contentPadding: EdgeInsets.symmetric(
              vertical: 28.h,
              horizontal: 12.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
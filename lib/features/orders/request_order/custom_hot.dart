import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomHot extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomHot({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: AppColor.primaryColor,
                        value: value,
                        onChanged: (val) => onChanged(val ?? false),
                      ),
                      Expanded(
                        child: CustomSubTitle(
                          subtitle: "Hot",
                          color: AppColor.white,
                          fontsize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

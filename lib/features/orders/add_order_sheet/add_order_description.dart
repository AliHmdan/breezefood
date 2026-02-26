import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddOrderDescription extends StatelessWidget {
  final String description;
  final double maxWidth;

  const AddOrderDescription({
    super.key,
    required this.description,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxWidth,
      child: CustomSubTitle(
        subtitle: description.isEmpty ? "Empty" : description,
        color: AppColor.white,
        fontsize: 14.sp,
      ),
    );
  }
}
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddOrderTitlePrice extends StatelessWidget {
  final String title;
  final double price;
  final double oldPrice;
  final bool hasDiscount;

  const AddOrderTitlePrice({
    super.key,
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.hasDiscount,
  });

  @override
  Widget build(BuildContext context) {
    return
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          CustomSubTitle(
            subtitle: title.isEmpty ? "Empty" : title,
            color: AppColor.white,
            fontsize: 22.sp,

          ),

          SizedBox(height: 8.h),

          Row(
            children: [
              if (hasDiscount) ...[
                Text(
                  context.money(oldPrice),
                  style: TextStyle(
                    color: AppColor.gry,
                    fontSize: 14.sp,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Text(
                context.money(price),
                style: TextStyle(
                  color: hasDiscount ? AppColor.red : AppColor.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      );
  }
}
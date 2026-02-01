import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/money.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QtyCounter extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  final num? pricePerItem; 
  final int moneyDecimals; 

  const QtyCounter({
    super.key,
    required this.value,
    required this.onChanged,
    this.pricePerItem,
    this.moneyDecimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    final totalNum = (pricePerItem == null) ? null : (value * pricePerItem!);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColor.black,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: value > 1 ? () => onChanged(value - 1) : null,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 16,
                  child: Icon(Icons.remove, color: Colors.black, size: 18.sp),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "$value",
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 12.w),
              InkWell(
                onTap: () => onChanged(value + 1),
                child: CircleAvatar(
                  backgroundColor: AppColor.primaryColor,
                  radius: 16,
                  child: Icon(Icons.add, color: Colors.white, size: 18.sp),
                ),
              ),
            ],
          ),
        ),

        if (totalNum != null) ...[
          SizedBox(width: 12.w),
          Text(
            context.money(totalNum, decimals: moneyDecimals), // ✅ هنا الصح
            style: TextStyle(
              color: AppColor.yellow,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

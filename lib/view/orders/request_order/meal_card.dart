import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'counter_request.dart';

class MealCard extends StatelessWidget {
  final String image;
  final String name;
  final String size;
  final double price;
  final bool showCounter; // إظهار/إخفاء العداد

  const MealCard({
    super.key,
    required this.image,
    required this.name,
    required this.size,
    required this.price,
    this.showCounter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 1, right: 10),
      decoration: BoxDecoration(
        color: AppColor.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // صورة الوجبة
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0),
              bottomLeft: Radius.circular(0),
              topRight: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            child: Image.asset(
              image,
              width: 100.w,
              height: 105.h,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          // تفاصيل الوجبة + (اختياري) العداد
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSubTitle(
                  subtitle: name,
                  color: AppColor.white,
                  fontsize: 14.sp,
                ),
                const SizedBox(height: 4),

                // السايز
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Size : ",
                        style: TextStyle(
                          color: AppColor.gry,
                          fontSize: 16.sp,
                        ),
                      ),
                      TextSpan(
                        text: " $size",
                        style: TextStyle(
                          color: AppColor.gry,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // السعر
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Price : ",
                        style: TextStyle(
                          color: AppColor.gry,
                          fontSize: 16.sp,
                        ),
                      ),
                      TextSpan(
                        text: "${price.toStringAsFixed(2)}\$ ",
                        style: TextStyle(
                          color: AppColor.yellow,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // العداد (اختياري)
                
              ],
            ),
          ),
          if (showCounter) ...[
                  const SizedBox(height: 6),
                  const CounterRequest(),
                ],
        ],
      ),
    );
  }
}

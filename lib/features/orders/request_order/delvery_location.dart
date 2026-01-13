import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class DeliveryLocationCard extends StatelessWidget {
  const DeliveryLocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child:
          // صورة الخريطة
          ClipRRect(
            borderRadius: BorderRadius.circular(
            11.r
            ),
            child: Image.asset(
              "assets/images/Map.jpg", // ضع صورة الخريطة هنا
              width: double.infinity,
              height: 150.h,
              fit: BoxFit.cover,
            ),
          ),

    );
  }
}

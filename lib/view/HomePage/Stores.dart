import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/orders/add_order.dart';
import 'package:breezefood/view/resturant_details.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Stores extends StatelessWidget {
  Stores({super.key});

  // 🔥 بيانات ثابتة فقط
  final List<Map<String, String>> items = [
    {
      "image": "assets/images/004.jpg",
      "title": "Burger King",
      "subtitle": "Hot & Fresh Meals",
      "label": "",
      "link": "",
    },
    {
      "image": "assets/images/003.jpg",
      "title": "Pizza Hut",
      "subtitle": "Delicious Pizzas",
      "label": "",
      "link": "",
    },
  ];

  final double height = 160.h;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: height,
        width: 361.w,
        child: CarouselSlider.builder(
          options: CarouselOptions(
            height: height,
            autoPlay: true,
            enlargeCenterPage: true,
          ),
          itemCount: items.length,
          itemBuilder: (context, index, realIndex) {
            final item = items[index];

            return Stack(
              alignment: Alignment.center,
              children: [
                // خلفية الصورة
                Container(
                  height: height,
                  width: 361.w,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(item["image"]!),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),

                // طبقة شفافة
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),

                Positioned(
                  left: 0,
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["subtitle"]!,
                          style: TextStyle(
                            color: AppColor.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 3.h),

                        Text(
                          item["title"]!,
                          style: TextStyle(
                            color: AppColor.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 1.h),

                        Text(
                          item["label"]!,
                          style: TextStyle(
                            color: AppColor.gry,
                            fontSize: 11.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 2.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ResturantDetails(),
                              ),
                            );
                          },
                          child: Text(
                            "Order Now",
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

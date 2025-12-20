// breezefood/lib/view/orders/request_order/counter.dart
import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:breezefood/view/orders/add_new_meal.dart';
import 'package:breezefood/view/profile/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 1;
  double pricePerItem = 5.0; // افترضنا قيمة للسعر
  
  @override
  Widget build(BuildContext context) {
    // 💡 تم إضافة Padding خارجي لحل مشكلة تجاوز العرض (RenderFlex Overflow) السابقة
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row( 
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // صندوق العداد (حجم ثابت)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColor.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // 1. زر ناقص (Minus Button)
                // 💡 الحل: تغليف الـ InkWell بـ Material لتوفير السياق المطلوب
                Material( 
                  color: Colors.transparent, // مهم أن تكون شفافة
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (count > 1) count--; 
                      });
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: Icon(
                        Icons.remove,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // العدد
                CustomSubTitle(subtitle: "$count", color: AppColor.white, fontsize: 18.sp),
                const SizedBox(width: 10),
                // 2. زر زائد (Add Button)
                // 💡 الحل: تغليف الـ InkWell بـ Material لتوفير السياق المطلوب
                Material( 
                  color: Colors.transparent, // مهم أن تكون شفافة
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        count++;
                      });
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.cyan,
                      radius: 16,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // زر ADD (مغلف بـ Expanded ويأخذ المساحة المتبقية بمرونة)
          Expanded(
            child: CustomButton(
              title: "ADD ${(count * pricePerItem).toStringAsFixed(2)}\$",
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const AddNewMeal(), // محاكاة التنقل
                    ),
                  );
                
              },
            ),
          ),
        ],
      ),
    );
  }
}
// breezefood/lib/view/orders/request_order/custom_hot.dart
import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomHot extends StatefulWidget {
  const CustomHot({super.key});

  @override
  State<CustomHot> createState() => _CustomHotState();
}
// breezefood/lib/view/orders/request_order/custom_hot.dart (تطبيق التعديل على كلا الجزأين)
// ... (الجزء العلوي من الملف)

class _CustomHotState extends State<CustomHot> {
  String? _selectedAddon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // الخيار الأول
        Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded( 
                // 💡 الحل: نغلف الـ Row الداخلي بـ Material
              child:  Material(
                  color: Colors.transparent, // للحفاظ على الخلفية
                  child: Row( // 👈 هذا هو الـ Row الذي يحتاج إلى Material
                    children: [
                      Checkbox(
                        // ... خصائص Checkbox
                        value: _selectedAddon == "Hot",
                        onChanged: (val) {
                          setState(() {
                            _selectedAddon = val! ? "Hot" : null;
                          });
                        },
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
              CustomSubTitle(
                subtitle: "2.00\$",
                color: AppColor.yellow,
                fontsize: 14.sp,
              ),
            ],
          ),
        ),

        // الخيار الثاني (ينطبق عليه نفس التعديل)

      ],
    );
  }
}
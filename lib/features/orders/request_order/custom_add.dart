import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAdd extends StatefulWidget {
  const CustomAdd({super.key});

  @override
  State<CustomAdd> createState() => _CustomAddState();
}

class _CustomAddState extends State<CustomAdd> {
  String? _selectedAddon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ العنصر الأول
        Padding(
          padding: EdgeInsets.symmetric(vertical: 3.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 💡 الحل: نغلف الجزء الأيسر بـ Expanded متبوعاً بـ Material
              Expanded(
                child: Material( // 👈 تم إضافة Material هنا
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        activeColor: AppColor.primaryColor,
                        side: BorderSide(
                          color: AppColor.white,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        value: _selectedAddon == "chips",
                        onChanged: (val) {
                          setState(() {
                            _selectedAddon = val! ? "chips" : null;
                          });
                        },
                      ),
                      // 💡 ونغلف العنوان بـ Expanded ليتكيف مع المساحة المتبقية
                      Expanded(
                        child: CustomSubTitle(
                          subtitle: "Regular chips",
                          color: AppColor.white,
                          fontsize: 14.sp,
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

        // ✅ العنصر الثاني
        Padding(
          padding: EdgeInsets.symmetric(vertical: 3.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 💡 الحل: نغلف الجزء الأيسر بـ Expanded متبوعاً بـ Material
              Expanded(
                child: Material( // 👈 تم إضافة Material هنا
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        activeColor: AppColor.primaryColor,
                        side: BorderSide(
                          color: AppColor.white,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        value: _selectedAddon == "rice",
                        onChanged: (val) {
                          setState(() {
                            _selectedAddon = val! ? "rice" : null;
                          });
                        },
                      ),
                      // 💡 ونغلف العنوان بـ Expanded
                      Expanded(
                        child: CustomSubTitle(
                          subtitle: "Spicy Rice",
                          color: AppColor.white,
                          fontsize: 14.sp,
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
      ],
    );
  }
}
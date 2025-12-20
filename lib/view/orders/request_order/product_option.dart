
import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:breezefood/view/orders/request_order/counter_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ProudectOption extends StatefulWidget {
  const ProudectOption({super.key});

  @override
  State<ProudectOption> createState() => _ProudectOptionState();
}

class _ProudectOptionState extends State<ProudectOption> {
  String? _selectedAddon;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  activeColor: AppColor.primaryColor,

                  checkColor: AppColor.white,
                  // لون علامة الصح
                  side:  BorderSide(             // 👈 هنا تحدد لون وسمك الـ border
                    color: AppColor.white,
                    width: 2,

                  ),
                  shape: RoundedRectangleBorder(      // 👈 هنا تضبط الـ border radius
                    borderRadius: BorderRadius.circular(6), // غير القيمة حسب رغبتك
                  ),
                  value: _selectedAddon == "chips",
                  onChanged: (val) {
                    setState(() {
                      _selectedAddon = val! ? "chips" : null;
                    });
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSubTitle(
                      subtitle: "Coca Cola",
                      color: AppColor.white,
                      fontsize: 14.sp,
                    ),
                    CustomSubTitle(
                      subtitle: "2.00\$",
                      color: AppColor.yellow,
                      fontsize: 14.sp,
                    ),
                  ],
                ),

              ],
            ),
            CounterRequest()

          ],
        ),
        SizedBox(height: 10.h,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  activeColor: AppColor.primaryColor,
                  checkColor: AppColor.white,           // لون علامة الصح
                  side:  BorderSide(             // 👈 هنا تحدد لون وسمك الـ border
                    color: AppColor.white,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(      // 👈 هنا تضبط الـ border radius
                    borderRadius: BorderRadius.circular(6), // غير القيمة حسب رغبتك
                  ),
                  value: _selectedAddon == "rice",
                  onChanged: (val) {
                    setState(() {
                      _selectedAddon = val! ? "rice" : null;
                    });
                  },
                ),
                Column(
                  children: [
                    CustomSubTitle(
                      subtitle: "Fanta",
                      color: AppColor.white,
                      fontsize: 14.sp,
                    ),
                    CustomSubTitle(
                      subtitle: "2.00\$",
                      color: AppColor.yellow,
                      fontsize: 14.sp,
                    ),
                  ],
                ),
              ],
            ),

            CounterRequest()
          ],
        ),
      ],
    );
  }
}

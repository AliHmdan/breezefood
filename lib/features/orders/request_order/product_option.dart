import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/request_order/counter_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProudectOption extends StatefulWidget {
  const ProudectOption({super.key});

  @override
  State<ProudectOption> createState() => _ProudectOptionState();
}

class _ProudectOptionState extends State<ProudectOption> {
  String? _selectedAddon;

  // ✅ كمية لكل إضافة
  int cocaQty = 1;
  int fantaQty = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ================= Coca Cola =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  activeColor: AppColor.primaryColor,
                  checkColor: AppColor.white,
                  side: BorderSide(color: AppColor.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  value: _selectedAddon == "coca",
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedAddon = "coca";
                        if (cocaQty < 1) cocaQty = 1;
                      } else {
                        _selectedAddon = null;
                      }
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

            // ✅ لازم initial
            // ✅ وإذا مو مختارة خليها disabled بصرياً (اختياري)
            IgnorePointer(
              ignoring: _selectedAddon != "coca",
              child: Opacity(
                opacity: _selectedAddon == "coca" ? 1 : 0.35,
                child: CounterRequest(
                  value: cocaQty,
                  onChanged: (v) => setState(() => cocaQty = v),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 10.h),

        // ================= Fanta =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  activeColor: AppColor.primaryColor,
                  checkColor: AppColor.white,
                  side: BorderSide(color: AppColor.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  value: _selectedAddon == "fanta",
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedAddon = "fanta";
                        if (fantaQty < 1) fantaQty = 1;
                      } else {
                        _selectedAddon = null;
                      }
                    });
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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

            // ✅ لازم initial
            IgnorePointer(
              ignoring: _selectedAddon != "fanta",
              child: Opacity(
                opacity: _selectedAddon == "fanta" ? 1 : 0.35,
                child: CounterRequest(
                  value: fantaQty,
                  onChanged: (v) => setState(() => fantaQty = v),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

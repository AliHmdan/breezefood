
import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CounterRequest extends StatefulWidget {
  const CounterRequest({super.key});

  @override
  State<CounterRequest> createState() => _CounterRequestState();
}

class _CounterRequestState extends State<CounterRequest> {
  int count = 5;
  @override
  Widget build(BuildContext context) {
    return
      Container(
        decoration: BoxDecoration(
          color: AppColor.Dark,
              borderRadius: BorderRadius.circular(15)
        ),
        child: Row(
          children: [
            // زر زيادة
            InkWell(
              onTap: () {
                setState(() {
                  count++;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration:  BoxDecoration(
                  color: AppColor.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: AppColor.white, size: 22.sp),
              ),
            ),

            const SizedBox(width: 5),

            // الرقم داخل صندوق متكيّف وثابت
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 30.w, // أقل عرض ثابت للرقم (يكفي لخانة أو خانتين)
              ),
              child: Center(
                child: CustomSubTitle(
                  subtitle: "$count",
                  color: AppColor.white,
                  fontsize: 18.sp,
                ),
              ),
            ),

            const SizedBox(width: 5),

            // زر إنقاص
            InkWell(
              onTap: () {
                if (count > 0) {
                  setState(() {
                    count--;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColor.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.remove, color: AppColor.black, size: 22.sp),
              ),
            ),
          ],
        ),
      );

  }
}

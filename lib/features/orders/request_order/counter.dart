import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/features/home/model/home_response.dart'; // MenuItemModel
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/add_new_meal.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Counter extends StatefulWidget {
  final List<MenuItemModel> favoriteItems;

  final MenuItemModel? orderAgainItem;

  final double pricePerItem;

  const Counter({
    super.key,
    required this.favoriteItems,
    this.orderAgainItem,
    this.pricePerItem = 5.0,
  });

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 1;

  @override
  Widget build(BuildContext context) {
    final total = (count * widget.pricePerItem).toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // صندوق العداد
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColor.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Minus
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (count > 1) count--;
                      });
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: Icon(Icons.remove, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                CustomSubTitle(
                  subtitle: "$count",
                  color: AppColor.white,
                  fontsize: 18.sp,
                ),

                const SizedBox(width: 10),

                // Add
                Material(
                  color: Colors.transparent,
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

          // زر ADD
          Expanded(
            child: CustomButton(
              title: "ADD $total\$",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddNewMeal(
                      orderAgainItem: widget.orderAgainItem,
                      favoriteItems: widget.favoriteItems,
                    ),
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

class QtyCounter extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  final num? pricePerItem; // ✅ num بدل double?
  final int moneyDecimals; // ✅ اختياري

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

import 'package:breezefood/core/component/color.dart';
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

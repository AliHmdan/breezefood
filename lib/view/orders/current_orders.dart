// 📁 File: current_orders.dart (Standalone Mock)

import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// --- نموذج البيانات الوهمي (Mock Model) ---
class CurrentOrderItem {
  final String id;
  final String restaurantName;
  final String itemName;
  final int itemQuantity;
  final double totalPrice;
  final String itemImage;
  final String createdAt;
  final String status;

  const CurrentOrderItem({
    required this.id,
    required this.restaurantName,
    required this.itemName,
    required this.itemQuantity,
    required this.totalPrice,
    required this.itemImage,
    required this.createdAt,
    required this.status,
  });
}

// --- بيانات وهمية ثابتة ---
final List<CurrentOrderItem> _mockCurrentOrders = const [
  CurrentOrderItem(
    id: "101",
    restaurantName: "مطعم الشيف السريع",
    itemName: "شاورما دجاج إكسترا",
    itemQuantity: 2,
    totalPrice: 20000,
    itemImage: "assets/images/current_1.jpg",
    createdAt: "2025-11-26T10:00:00",
    status: "في الطريق",
  ),
  CurrentOrderItem(
    id: "102",
    restaurantName: "بيتزا ماريو",
    itemName: "بيتزا خضار حجم عائلي",
    itemQuantity: 1,
    totalPrice: 15000,
    itemImage: "assets/images/current_2.jpg",
    createdAt: "2025-11-26T10:15:00",
    status: "تحضير",
  ),
];

class CurrentOrders extends StatefulWidget {
  const CurrentOrders({super.key});

  @override
  State<CurrentOrders> createState() => _CurrentOrdersState();
}

class _CurrentOrdersState extends State<CurrentOrders> {
  List<CurrentOrderItem> _currentOrders = _mockCurrentOrders;

  @override
  void initState() {
    super.initState();
    // 🗑️ تم إزالة استدعاء cubit.loadCurrentOrders(token);
  }

  // 🖱️ دالة تحديث وهمية
  Future<void> _refreshOrders() async {
    // محاكاة تحميل البيانات
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        _currentOrders = List.from(_mockCurrentOrders);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تحديث الطلبات الحالية (Mock)")),
      );
    }
  }

  Widget _buildOrderCard(CurrentOrderItem order) {
    return 
    Container(
      height: 110.h,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColor.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              // 💡 استخدام Image.asset للبيانات الوهمية
              child: Image.asset(
                order.itemImage,
                width: 80.w,
                height: 80.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  "assets/images/003.jpg", // Fallback Image
                  width: 80.w,
                  height: 80.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSubTitle(
                  subtitle: order.restaurantName,
                  color: AppColor.white,
                  fontsize: 14.sp,
                ),
                const SizedBox(height: 4),
                CustomSubTitle(
                  subtitle: "${order.itemName} (${order.itemQuantity} قطع)",
                  color: AppColor.white,
                  fontsize: 10.sp,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Total: ",
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 14.sp,
                              fontFamily: "Manrope",
                            ),
                          ),
                          TextSpan(
                            text: "${order.totalPrice.toStringAsFixed(0)} ل.س",
                            style: TextStyle(
                              color: AppColor.yellow,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Manrope",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomSubTitle(
                        // 💡 عرض حالة الطلب
                        subtitle: order.status, 
                        color: AppColor.green,
                        fontsize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentOrders.isEmpty) {
      return const Center(
        child: Text(
          "لا توجد طلبات حالية",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshOrders,
      child: ListView.builder(
        itemCount: _currentOrders.length,
        itemBuilder: (context, index) => _buildOrderCard(_currentOrders[index]),
      ),
    );
  }
}
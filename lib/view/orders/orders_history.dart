// 📁 File: orders_history.dart (Standalone Mock)

import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';


// --- نموذج البيانات الوهمي (Mock Model) ---
class OrdersHistoryItem {
  final String id;
  final String restaurantName;
  final String status;
  final double totalPrice;
  final String restaurantLogo;

  const OrdersHistoryItem({
    required this.id,
    required this.restaurantName,
    required this.status,
    required this.totalPrice,
    required this.restaurantLogo,
  });
}

// --- بيانات وهمية ثابتة ---
final List<OrdersHistoryItem> _mockOrdersHistory = const [
  OrdersHistoryItem(
    id: "901",
    restaurantName: "مطعم الطيبات",
    status: "Delivered",
    totalPrice: 35000.0,
    restaurantLogo: "assets/images/history_1.jpg",
  ),
  OrdersHistoryItem(
    id: "902",
    restaurantName: "حلويات القلعة",
    status: "Cancelled",
    totalPrice: 12000.0,
    restaurantLogo: "assets/images/history_2.jpg",
  ),
  OrdersHistoryItem(
    id: "903",
    restaurantName: "برغر كينغ",
    status: "Delivered",
    totalPrice: 28000.0,
    restaurantLogo: "assets/images/history_3.jpg",
  ),
];

class OrdersHistory extends StatefulWidget {
  const OrdersHistory({super.key});

  @override
  State<OrdersHistory> createState() => _OrdersHistoryState();
}

class _OrdersHistoryState extends State<OrdersHistory> {
  List<OrdersHistoryItem> _historyOrders = _mockOrdersHistory;

  @override
  void initState() {
    super.initState();
    // 🗑️ تم إزالة استدعاء cubit.loadOrdersHistory();
  }

  // 🖱️ دالة تحديث وهمية
  Future<void> _refreshedOrders() async {
    // محاكاة تحميل البيانات
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        _historyOrders = List.from(_mockOrdersHistory);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تحديث سجل الطلبات (Mock)")),
      );
    }
  }

  Widget _buildOrderCard(OrdersHistoryItem item) {
    final statusColor = item.status == "Delivered" ? Colors.green : AppColor.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            CustomSlidableAction(
              onPressed: (context) => _refreshedOrders(),
              backgroundColor: AppColor.black,
              borderRadius: BorderRadius.circular(15.r),
              child: Center(
                child: SvgPicture.asset(
                  "assets/icons/refresh.svg",
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  width: 30.w,
                  height: 30.h,
                ),
              ),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            padding: const EdgeInsets.only(left: 1, right: 10,top: 4),
            decoration: BoxDecoration(
              color: AppColor.black,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    // 💡 استخدام Image.asset للبيانات الوهمية
                    child: Image.asset(
                      item.restaurantLogo,
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
                        subtitle: item.restaurantName,
                        color: AppColor.white,
                        fontsize: 14.sp,
                      ),
                      const SizedBox(height: 4),
                      CustomSubTitle(
                        subtitle: item.status,
                        color: statusColor,
                        fontsize: 12.sp,
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Price : ",
                              style: TextStyle(
                                color: AppColor.white,
                                fontFamily: "Manrope",
                                fontSize: 12.sp,
                              ),
                            ),
                            TextSpan(
                              text: "${item.totalPrice.toStringAsFixed(0)} ل.س",
                              style: TextStyle(
                                color: AppColor.yellow,
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_historyOrders.isEmpty) {
      return const Center(
        child: Text(
          "لا توجد طلبات سابقة",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refreshedOrders,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          for (final order in _historyOrders) _buildOrderCard(order),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
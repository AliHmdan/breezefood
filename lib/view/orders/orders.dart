// 📁 File: orders_standalone.dart (بدون ربط بالباك إند)

import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_appbar_home.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:breezefood/view/orders/current_orders.dart';
import 'package:breezefood/view/orders/orders_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; 


// *************************************************************
// 📝 محتوى التبويبة الأولى: الطلبات الحالية (MOCK)
// *************************************************************

final List<Map<String, dynamic>> _mockCurrentOrders = const [
  {
    'id': '101',
    'restaurantName': 'مطعم الشيف السريع',
    'itemName': 'شاورما دجاج (2 قطع)',
    'totalPrice': 20000.0,
    'status': 'في الطريق',
    'image': 'assets/images/current_1.jpg', // تأكد من وجود المسار في الـ assets
  },
  {
    'id': '102',
    'restaurantName': 'بيتزا ماريو',
    'itemName': 'بيتزا خضار (1 قطعة)',
    'totalPrice': 15000.0,
    'status': 'تحضير',
    'image': 'assets/images/current_2.jpg',
  },
];

// *************************************************************
// 📝 محتوى التبويبة الثانية: سجل الطلبات (MOCK)
// *************************************************************

final List<Map<String, dynamic>> _mockHistoryOrders = const [
  {
    'id': '901',
    'restaurantName': 'مطعم الطيبات',
    'status': 'Delivered',
    'totalPrice': 35000.0,
    'logo': 'assets/images/history_1.jpg',
  },
  {
    'id': '902',
    'restaurantName': 'حلويات القلعة',
    'status': 'Cancelled',
    'totalPrice': 12000.0,
    'logo': 'assets/images/history_2.jpg',
  },
];

// *************************************************************
// 🏠 الـ Widget الرئيسية: Orders (Standalone)
// *************************************************************

class Orders extends StatefulWidget {
 const Orders({super.key});

 @override
 State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> with SingleTickerProviderStateMixin {
 late TabController _tabController;

 @override
 void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });
 }

 @override
 void dispose() {
  _tabController.dispose();
  super.dispose();
 }

 @override
 Widget build(BuildContext context) {
  return Scaffold(
   backgroundColor: AppColor.Dark,
   body: SafeArea(
        child: Padding(
     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
     child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       const CustomAppbarHome(title: "Orders"),
       SizedBox(height: 20.h),

       // 🔥 Animated TabBar Buttons
       Row(
        children: List.generate(2, (index) {
         final isSelected = _tabController.index == index;
         final titles = ["Current orders", "Orders history"];

         return Expanded(
          child: GestureDetector(
           onTap: () {
            _tabController.animateTo(index);
            setState(() {});
           },
           child: Center(
            child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
              CustomSubTitle(
               subtitle: titles[index],
               color: isSelected ? AppColor.primaryColor : AppColor.white,
               fontsize: 14.sp,
              ),
              AnimatedContainer(
               duration: const Duration(milliseconds: 300),
               curve: Curves.easeInOut,
               margin: EdgeInsets.only(top: 4.h),
               height: 3,
               width: isSelected ? 130.w : 0,
               constraints: const BoxConstraints(
                minWidth: 0,
                maxWidth: double.infinity,
               ),
               decoration: BoxDecoration(
                color: isSelected
                  ? AppColor.primaryColor
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(2.r),
               ),
              ),
             ],
            ),
           ),
          ),
         );
        }),
       ),

       SizedBox(height: 10.h),

       // محتوى التبويبات (Mocked Content)
       Expanded(
        child: TabBarView(
         controller: _tabController,
         children: const [
          CurrentOrders(),
          OrdersHistory(),
         ],
        ),
       ),
      ],
     ),
    ),
   ),
   // bottomNavigationBar: CustomBottomNav(currentIndex: 3),
  );
 }
}
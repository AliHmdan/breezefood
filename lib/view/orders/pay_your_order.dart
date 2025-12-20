
import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/orders/payment_method.dart';
import 'package:breezefood/view/orders/request_order/meal_card.dart';
import 'package:breezefood/view/orders/request_order/total.dart';
import 'package:breezefood/view/profile/widget/custom_appbar_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // لإدارة المقاسات


class OrderItem {
 final String image;
 final String title;
 final String size;
 final double price;
 final int qty;

 const OrderItem({
  required this.image,
  required this.title,
  required this.size,
  required this.price,
  this.qty = 1,
 });

 double get total => price * qty;
}

class PayYourOrder extends StatefulWidget {
 const PayYourOrder({super.key});

 @override
 State<PayYourOrder> createState() => _PayYourOrderState();
}

class _PayYourOrderState extends State<PayYourOrder> {
 // 💎 بيانات وهمية (Mock Data) تحاكي ما سيأتي من الباك إند
 final List<OrderItem> _items = const [
  OrderItem(
   image: 'assets/images/shesh.jpg',
   title: 'Chicken shish',
   size: 'M',
   price: 5.00,
   qty: 1,
  ),
  OrderItem(
   image: 'assets/images/shesh.jpg',
   title: 'Pepsi',
   size: 'L',
   price: 2.50,
   qty: 2,
  ),
 ];

 // 💰 ملخص الطلب - بيانات وهمية
 double subTotal = 10.00; // الإجمالي الفرعي
 double delivery = 2.00; // رسوم التوصيل
 double coupon = -1.00; // الخصم

 // 💳 طرق الدفع - بيانات وهمية
 final methods = const [
  PaymentMethod(
   id: 'cash',
   title: 'Cash',
   imageAsset: 'assets/images/cash.png',
  ),
  PaymentMethod(
   id: 'visa',
   title: 'Visa card',
   imageAsset: 'assets/images/visa.png',
  ),
  PaymentMethod(
   id: 'master',
   title: 'Master card',
   imageAsset: 'assets/images/master.png',
  ),
 ];


 @override
 void initState() {
  super.initState();
  // مثال: حساب الإجمالي الفرعي من قائمة الـ _items
  subTotal = _items.fold(0.0, (sum, item) => sum + item.total);
 }

 @override
 Widget build(BuildContext context) {
  // 🧮 حساب الإجمالي النهائي
  final double total = subTotal + delivery + coupon;

  return Scaffold(
   backgroundColor: AppColor.Dark,
   // Appbar
   appBar: PreferredSize(
    preferredSize: Size.fromHeight(60.h),
    child: Padding(
     padding: const EdgeInsets.symmetric(horizontal: 16),
     child: CustomAppbarProfile(
      title: "Shawarma King",
      icon: Icons.arrow_back_ios,
      ontap: () => Navigator.pop(context), // 👈 انتقال أمامي (Frontend)
     ),
    ),
   ),
   // Body
   body: SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    child: Padding(
     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
     child: Column(
      children: [

       // 🍔 عرض قائمة الوجبات
       ..._items.map((item) => Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: MealCard(
         image: item.image,
         name: item.title,
         size: item.size,
         price: item.price,
         showCounter: false,
        ),
       )).toList(),

       const SizedBox(height: 8),

       // 🧾 ملخص الطلب
       Container(
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 10.w),
        decoration: BoxDecoration(
         color: AppColor.black,
         borderRadius: BorderRadius.circular(11.r),
        ),
        child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
          Total("Sub total", subTotal),
          Total("Delivery", delivery),
          Total("Coupon", coupon),
          const Divider(color: Colors.white30),
          Total("Total", total, isTotal: true),
         ],
        ),
       ),

       // 💳 قسم الدفع وزر الطلب
       PaymentMethodSection(
        amountText: '${total.toStringAsFixed(2)}\$',
        methods: methods,
        initialSelectedId: 'cash',
        onChanged: (id) {
         // منطق الواجهة الأمامية (Frontend) فقط:
         print("Selected method changed to: $id");
        },
        onOrder: () {
         // 🚨 هذه النقطة التي كانت سترسل البيانات إلى الباك إند
         // حالياً هي فقط انتقال أمامي (Frontend) لصفحة النجاح
        //  Navigator.of(context).pushNamed(AppRoute.success);
        },
       ),
      ],
     ),
    ),
   ),
  );
 }
}

import 'package:breezefood/component/color.dart' show AppColor;
import 'package:breezefood/view/HomePage/most_popular.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:breezefood/view/orders/OrderTrakingMap.dart';
import 'package:breezefood/view/orders/payment_method.dart';
import 'package:breezefood/view/orders/request_order/custom_pill_input.dart';
import 'package:breezefood/view/orders/request_order/delvery_location.dart';
import 'package:breezefood/view/orders/request_order/meal_card.dart';
import 'package:breezefood/view/orders/request_order/product_option.dart';
import 'package:breezefood/view/orders/request_order/title_location.dart';
import 'package:breezefood/view/orders/request_order/total.dart';
import 'package:breezefood/view/profile/widget/custom_appbar_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ✅ تم تحويل الـ StatefulWidget إلى StatelessWidget لتبسيط الكود
class RequestOrder extends StatelessWidget {
  const RequestOrder({super.key});

  // 📦 بيانات وهمية (Mock Data) ثابتة للـ UI:
  final List<PaymentMethod> mockMethods = const [
    PaymentMethod(
      id: 'cash',
      title: 'Cash',
      imageAsset: 'assets/images/cash.png',
      imageWidth: 36,
      imageHeight: 24,
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

  final double subTotal = 30.00;
  final double delivery = 2.00;
  final double coupon = -4.99; // قيمة ثابتة

  @override
  Widget build(BuildContext context) {
    // 🧮 الحسابات أصبحت ثابتة (ليست ديناميكية من الـ State)
    final double total = subTotal + delivery + coupon;

    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomAppbarProfile(
            title: "Shawarma King",
            icon: Icons.arrow_back_ios,
            ontap: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: Column(
            children: [
              const MealCard(
                image: 'assets/images/003.jpg',
                name: 'Chicken shish',
                size: 'M',
                price: 5.00,
                showCounter: true,
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.add, color: AppColor.primaryColor, size: 20.sp),
                  CustomSubTitle(
                    subtitle: "Add",
                    color: AppColor.primaryColor,
                    fontsize: 14.sp,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColor.black,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSubTitle(
                      subtitle: "Want a ?",
                      color: AppColor.white,
                      fontsize: 16,
                    ),
                    SizedBox(height: 5),
                    ProudectOption(),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ✅ إجمالي الطلب (يعتمد الآن على المتغيرات الثابتة في هذا الودجت)
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

              const SizedBox(height: 10),

              const CustomTitleSection(title: "Delivery to"),
              const TitleLocation(),
              const SizedBox(height: 10),
              const DeliveryLocationCard(),

              const SizedBox(height: 10),

              Row(
                children: [
                  CustomPillInput(
                    hint: 'Floor number',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    width: 130.w,
                  ),
                  SizedBox(width: 10.w),
                  CustomPillInput(
                    hint: 'Door number',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    width: 130.w,
                  ),
                ],
              ),

              // --- قسم الدفع ---
              PaymentMethodSection(
                amountText: '${total.toStringAsFixed(2)}\$',
                methods: mockMethods, // ✅ استخدام البيانات الوهمية
                initialSelectedId: 'cash',
                onChanged: (id) {
                  // هذا الـ onChanged سيبقى فارغاً أو يُنفذ عملية ثابتة
                  debugPrint('Payment method selected: $id');
                },
                onOrder: () {
                  // 📞 الانتقال إلى شاشة النجاح
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return OrderTrackingScreen();
                  },));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
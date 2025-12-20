// presentation/widgets/home/discount_standalone.dart

import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/discount_grid_Page.dart';
import 'package:breezefood/view/HomePage/most_popular.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:breezefood/view/orders/add_order.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart'; // نحتاج هذه الحزمة لـ SvgPicture

// *************************************************************
// ⚠️ تعريفات وهمية (Mocked Dependencies)
// *************************************************************

// محاكاة لدالة عرض الـ Dialog (تم استخلاصها سابقاً)


// محاكاة لدالة عرض تقييم المطعم
void showRatingPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: const Color(0xFF2F2F2F),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "What is your rate?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < 4 ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 35.sp,
                  ),
                ),
              ),

              SizedBox(height: 15.h),
              Text(
                "Please share your rate about the restaurant",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13.sp),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      );
    },
  );
}

// Mock Data لتمثيل الخصم (بديل لـ DiscountModel)
class MockDiscountModel {
  final String itemName;
  final String restaurantName;
  final String imagePath;
  final double discountValue;

  const MockDiscountModel({
    required this.itemName,
    required this.restaurantName,
    required this.imagePath,
    required this.discountValue,
  });
}

// *************************************************************
// 🧩 الـ Widget المكونة: Discount
// *************************************************************

class Discount extends StatefulWidget {
  final String imagePath;
  // final String title; // اسم الوجبة
  final String subtitle; // اسم المطعم
  final String price; // السعر الجديد (أو قيمة غير مستخدمة)
  final String discount; // قيمة الخصم المعروضة
  final VoidCallback onFavoriteToggle;
  final void Function()? onTap;

  // 💡 لتبسيط الـ UI الثابت، نستخدم isFavorite كقيمة ابتدائية فقط
  final bool initialIsFavorite;

  Discount({
    Key? key,
    required this.imagePath,
    // required this.title,
    required this.subtitle,
    required this.price,
    required this.discount,
    required this.onFavoriteToggle,
    this.initialIsFavorite = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<Discount> createState() => _DiscountState();
}

class _DiscountState extends State<Discount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // 🗑️ تم إزالة استخدام _scaleAnimation لتبسيط الكود، يمكن إبقاؤها
  // late Animation<double> _scaleAnimation;

  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  // 🗑️ تم حذف منطق بناء المسار من AppLink وتبسيط بناء الصورة
  Widget buildImage(String path, {double? height}) {
    // 💡 في وضع الـ Mock، نفترض أن المسارات هي Assets
    return Image.asset(
      path,
      height: height,
      width: double.infinity,
      cacheWidth: 600,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: Colors.grey.shade800,
        child: Center(
          child: Icon(Icons.fastfood, color: AppColor.white, size: 30.sp),
        ),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onFavoriteToggle();
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        // تم تحديد العرض بشكل ثابت ليتناسب مع الـ ListView في DiscountHome
        width: 160.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ الصورة + المفضلة + الخصم
            Stack(
              children: [
                Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.r),
                    child: buildImage(widget.imagePath, height: 100.h),
                  ),
                ),

                // ⭐⭐⭐ التقييم فوق الصورة
                Positioned(
                  top: 6,
                  left: 6,
                  child: GestureDetector(
                    onTap: () {
                      showRatingPopup(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 12.sp),
                          SizedBox(width: 4.w),
                          CustomSubTitle(
                            subtitle: "4.9",
                            color: AppColor.white,
                            fontsize: 12.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 🍽️ اسم المطعم (Subtitle) في الوسط مع تدرج لوني
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: CustomSubTitle(
                          subtitle: widget.subtitle,
                          color: AppColor.white,
                          fontsize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ),

                // 🔖 الخصم
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.r),
                        bottomRight: Radius.circular(20.r),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomSubTitle(
                          subtitle: widget.discount,
                          color: AppColor.white,
                          fontsize: 14,
                        ),

                        SizedBox(width: 4.w),
                        SvgPicture.asset(
                          "assets/icons/nspah.svg", // ضع مسار SVG الصحيح
                          width: 22.w,
                          height: 22.h,
                          color: Colors.white, // إذا أردت أن يكون بلون أبيض
                        ),
                        // 🗑️ تم حذف استخدام الـ Svg.asset (نحتاج الحزمة أو نستبدلها بـ Text)
                        // سنستخدم أيقونة لتبسيط الأمر
                        // const Icon(Icons.local_offer, color: AppColor.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 🏷️ اسم الوجبة (Title) تحت الصورة
            // Padding(
            //   padding: EdgeInsets.only(top: 4.h, left: 2.w),
            //   child: Text(
            //     widget.title,
            //     style: TextStyle(
            //       color: AppColor.white, // يفترض أن الخلفية داكنة
            //       fontSize: 14.sp,
            //       fontWeight: FontWeight.w600,
            //     ),
            //     maxLines: 1,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

// *************************************************************
// 🏠 الـ Widget الرئيسية: DiscountHome
// *************************************************************

class DiscountHome extends StatelessWidget {
  // 📝 بيانات ثابتة (Mock Data)
  final List<MockDiscountModel> _mockDiscounts = const [
    MockDiscountModel(
      itemName: 'Big Chicken Combo',
      restaurantName: 'KFC Express',
      imagePath: 'assets/images/004.jpg',
      discountValue: 20,
    ),
    MockDiscountModel(
      itemName: 'Double Burger Meal',
      restaurantName: 'Burger Palace',
      imagePath: 'assets/images/pourple.jpg',
      discountValue: 30,
    ),
    MockDiscountModel(
      itemName: 'Italian Pasta Offer',
      restaurantName: 'Pasta House',
      imagePath: 'assets/images/003.jpg',
      discountValue: 15,
    ),
    MockDiscountModel(
      itemName: 'Fish & Chips',
      restaurantName: 'Seafood Spot',
      imagePath: 'assets/images/004.jpg',
      discountValue: 25,
    ),
    MockDiscountModel(
      itemName: 'Vegan Power Bowl',
      restaurantName: 'Green Eats',
      imagePath: 'assets/images/002.jpg',
      discountValue: 10,
    ),
  ];

  // 🗑️ تم استبدال List<home_model.DiscountModel>? discounts;
  final List<MockDiscountModel>? discounts;

  const DiscountHome({super.key, this.discounts});

  @override
  Widget build(BuildContext context) {
    final items = discounts ?? _mockDiscounts;

    // 💡 لإظهار 5 عناصر ثابتة في وضع الـ Mock
    final itemCount = items.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomTitleSection(
            title: "Discounts",
            all: "All",
            icon: Icons.arrow_forward_ios_outlined,
            ontap: () {
              Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const DiscountGridPage(), // محاكاة التنقل
                    ),
                  );
              // 🖱️ محاكاة الانتقال إلى صفحة الخصومات
              
            },
          ),
        ),

        RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 8, right: 0.2),
            child: SizedBox(
              height: 100
                  .h, // تم تعديل الارتفاع ليتناسب مع البطاقة (100h + Padding)
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // عرض العنصر الواحد بناءً على عرض الشاشة المتاح
                  final itemWidth = constraints.maxWidth / 2.2;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: itemCount,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        width: itemWidth,
                        margin: EdgeInsets.only(right: 10.w),
                        child: GestureDetector(
                          onTap: () {
                            // 🖱️ محاكاة فتح الـ Dialog لطلب الوجبة
                            // showAddOrderDialog(
                            //   context,
                            //   title: item.itemName,
                            //   price:
                            //       "5.00\$", // قيمة ثابتة لعدم وجود السعر الأصلي في الـ Mock
                            //   oldPrice: "7.00\$",
                            //   imagePath: item.imagePath,
                            // );
                          },
                          // 📌 استخدام ويدجت Discount المستخلصة
                          child: Discount(
                            imagePath: item.imagePath,
                            // title: item.itemName,
                            subtitle: item.restaurantName,
                            price: "10.00", // قيمة وهمية
                            onFavoriteToggle: () {
                              // 🖱️ محاكاة التفاعل مع زر المفضلة
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Mock Action: Toggled favorite for ${item.itemName}',
                                  ),
                                ),
                              );
                            },
                            // عرض قيمة الخصم المئوية
                            discount: "${item.discountValue.toInt()}",
                            // 💡 لا نمرر onTap هنا لأنه تم تمريره في GestureDetector الخارجي
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

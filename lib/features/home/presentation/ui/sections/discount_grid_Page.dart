import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/discount.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// *************************************************************
// 🧱 البيانات الوهمية (Mock Data) لتحل محل بيانات الـ Cubit
// *************************************************************

// يمكنك استخدام تعريفات MockDiscountItem التي كانت لديك مسبقاً
class MockDiscountItem {
  final String image;
  final String nameAr; 
  final String restaurantName; 
  final double price;
  final int discountValue;

  const MockDiscountItem({
    required this.image,
    required this.nameAr,
    required this.restaurantName,
    required this.price,
    required this.discountValue,
  });
}

const List<MockDiscountItem> mockDiscounts = [
  MockDiscountItem(
    image: 'assets/images/shesh.jpg',
    nameAr: 'وجبة البرجر الثلاثي',
    restaurantName: 'مطعم الأهل',
    price: 15000.0,
    discountValue: 20,
  ),
  MockDiscountItem(
    image: 'assets/images/shesh.jpg',
    nameAr: 'بيتزا سوبريم',
    restaurantName: 'مطعم الإيطالي',
    price: 22000.0,
    discountValue: 15,
  ),
  MockDiscountItem(
    image: 'assets/images/shesh.jpg',
    nameAr: 'طبق دجاج مشوي',
    restaurantName: 'مطعم المشاوي',
    price: 18000.0,
    discountValue: 25,
  ),
  MockDiscountItem(
    image: 'assets/images/shesh.jpg',
    nameAr: 'صندوق السوشي',
    restaurantName: 'مطعم السوشي',
    price: 35000.0,
    discountValue: 10,
  ),
  // أضف المزيد من العناصر للاختبار
  MockDiscountItem(
    image: 'assets/images/shesh.jpg',
    nameAr: 'باستا الفريدو',
    restaurantName: 'مطعم السعادة',
    price: 12000.0,
    discountValue: 12,
  ),
];


class DiscountGridPage extends StatelessWidget {
  const DiscountGridPage({super.key}); // تم تعديل التعريف ليكون Const

  // دالة تحديد عدد الأعمدة بناءً على عرض الشاشة
  int _getCrossAxisCount(double width) {
    if (width < 600) return 2;
    if (width < 1000) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    // 💡 تم إزالة BlocProvider بالكامل
    
    // استخدم قائمة البيانات الوهمية
    final list = mockDiscounts;

    return Scaffold(
      backgroundColor: AppColor.Dark, // لون الخلفية الداكن
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomAppbarProfile(
            title: "Discount",
            icon: Icons.arrow_back_ios,
            ontap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          // 💡 تم الإبقاء على نفس الـ Padding الخارجي
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: LayoutBuilder( // الاحتفاظ بالـ LayoutBuilder لتنسيق الشاشة
            builder: (context, constraints) {
              final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

              return Container(
                width: double.infinity,
                height: double.infinity,

                child: Padding(
                  // 💡 الـ Padding الداخلي للحاوية
                  padding: const EdgeInsets.all(8.0), 
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      // 💡 قيم المسافات ونسبة العرض للارتفاع المحفوظة
                      mainAxisSpacing: 5.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 0.79,
                    ),
                    itemCount: list.length, // استخدام عدد العناصر الوهمية
                    itemBuilder: (context, index) {
                      final item = list[index];
                      // 💡 استخدام Discount Widget مع بيانات وهمية
                      return Discount( 
                        imagePath: item.image,
                        title: item.nameAr,
                        subtitle: item.restaurantName,
                        price: "${item.price.toStringAsFixed(0)} ل.س",
                        discount: item.discountValue.toString(),
                        onFavoriteToggle: () {},
                        onTap: () {},
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/discount.dart';
import 'package:breezefood/view/HomePage/widgets/discount_delevry.dart';
import 'package:breezefood/view/profile/widget/custom_appbar_profile.dart';
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
  final double oldPrice;
  final double newPrice;

  const MockDiscountItem({
    required this.image,
    required this.nameAr,
    required this.restaurantName,
    required this.oldPrice,
    required this.newPrice,
  });
}


const List<MockDiscountItem> mockDiscounts = [
  MockDiscountItem(
    image: 'assets/images/shesh.jpg',
    nameAr: 'وجبة البرجر الثلاثي',
    restaurantName: 'مطعم الأهل',
    oldPrice: 15000.0,
    newPrice: 12000.0,
  ),
  MockDiscountItem(
    image: 'assets/images/shesh.jpg',
    nameAr: 'بيتزا سوبريم',
    restaurantName: 'مطعم الإيطالي',
    oldPrice: 22000.0,
    newPrice: 18000.0,
  ),
  MockDiscountItem(
    image: 'assets/images/shesh.jpg',
    nameAr: 'طبق دجاج مشوي',
    restaurantName: 'مطعم المشاوي',
    oldPrice: 18000.0,
    newPrice: 14000.0,
  ),
  MockDiscountItem(
    image: 'assets/images/shesh.jpg',
    nameAr: 'صندوق السوشي',
    restaurantName: 'مطعم السوشي',
    oldPrice: 35000.0,
    newPrice: 29900.0,
  ),
  MockDiscountItem(
    image: 'assets/images/shesh.jpg',
    nameAr: 'باستا الفريدو',
    restaurantName: 'مطعم السعادة',
    oldPrice: 12000.0,
    newPrice: 10000.0,
  ),
];


class DiscountDelevryGridPageGridPage extends StatelessWidget {
  const DiscountDelevryGridPageGridPage({super.key});

  int _getCrossAxisCount(double width) {
    if (width < 600) return 2;
    if (width < 1000) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final list = mockDiscounts;

    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomAppbarProfile(
            title: "Discount Delevery",
            icon: Icons.arrow_back_ios,
            ontap: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body:
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child:
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 1,
                  childAspectRatio: 1.5,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];

                  return
                    DiscountDelevry(
                    imagePath: item.image,
                    title: item.nameAr,

                    oldPrice: "${item.oldPrice.toStringAsFixed(0)} ل.س",
                    newPrice: "${item.newPrice.toStringAsFixed(0)} ل.س",
                    onTap: () {}, onFavoriteToggle: () {  },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}


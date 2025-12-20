
import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/discount_home.dart';
import 'package:breezefood/view/HomePage/most_popular.dart' hide showAddOrderDialog;
import 'package:breezefood/view/orders/add_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class HorizontalProductsSection extends StatelessWidget {
  final int itemCount;
  final String imagePath;
  final String title;
  final String price;
  final String oldPrice;

  const HorizontalProductsSection({
    super.key,
    this.itemCount = 5,
    this.imagePath = 'assets/images/shesh.jpg',
    this.title = 'Chicken',
    this.price = '5.00\$',
    this.oldPrice = '5.00\$',
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      height: 140.h,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        physics: itemCount <= 2
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: isRTL ? 0 : 16.w,   // ✅ إنجليزي
          right: isRTL ? 16.w : 0,  // ✅ عربي
        ),
        itemBuilder: (context, index) {
          return Container(
            width: 160.w,
            margin: EdgeInsets.only(
              right: !isRTL && index != itemCount - 1 ? 10.w : 0,
              left: isRTL && index != itemCount - 1 ? 10.w : 0,
            ),
            child: GestureDetector(
              onTap: () {
                showAddOrderDialog(
                  context,
                  title: title,
                  price: price,
                  oldPrice: oldPrice,
                  imagePath: imagePath,
                );
              },
              child: PopularItemCard(
                isFavorite: true,
                imagePath: imagePath,
                title: title,
                price: price,
                oldPrice: oldPrice,
                onFavoriteToggle: () {},
              ),
            ),
          );
        },
      ),
    );

  }
}

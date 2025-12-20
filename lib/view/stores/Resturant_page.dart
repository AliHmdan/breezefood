import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/orders/add_new_meal.dart';
import 'package:breezefood/view/profile/widget/custom_appbar_profile.dart';
import 'package:breezefood/view/resturant_details.dart';
import 'package:breezefood/view/superMarket/super_market_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResturantPage extends StatelessWidget {
  const ResturantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = const [
      MarketItem(
        title: 'Shech',
        image: 'assets/images/shesh.jpg',
        isAsset: true,
      ),
      MarketItem(
        title: 'pourple',
        image: 'assets/images/pourple.jpg',
        isAsset: true,
      ),
      MarketItem(
        title: 'Shech',
        image: 'assets/images/pourple.jpg',
        isAsset: true,
      ),
      MarketItem(
        title: 'pourple',
        image: 'assets/images/shesh.jpg',
        isAsset: true,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColor.Dark , // AppColor.Dark مثلاً
        appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h), // ارتفاع الـ AppBar
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomAppbarProfile(
            title: "Resturant",
            icon: Icons.arrow_back_ios,
            ontap: () {
           Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: MarketGrid(
        items: products,
        onItemTap: (i, item) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return  ResturantDetails();
          },));
        },
      ),
    );
  }
}

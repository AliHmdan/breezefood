import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/profile/widget/custom_appbar_profile.dart';
import 'package:breezefood/view/superMarket/super_market_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = const [
      MarketItem(
        title: 'Bread',
        image: 'assets/images/bread.png',
        isAsset: true,
      ),
      MarketItem(
        title: 'Bread',
        image: 'assets/images/mealk.png',
        isAsset: true,
      ),
      MarketItem(
        title: 'Bread',
        image: 'assets/images/bread.png',
        isAsset: true,
      ),
      MarketItem(
        title: 'Bread',
        image: 'assets/images/mealk.png',
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
            title: "Market",
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
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          //   return  StoreDetailsBloc(restaurantId: 1, categories: ['burger','shawarma'],);
          // },));
        },
      ),
    );
  }
}

import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/Stores.dart';
import 'package:breezefood/view/HomePage/closerToYou.dart';
import 'package:breezefood/view/HomePage/discount_home.dart';
import 'package:breezefood/view/HomePage/open_now.dart';
import 'package:breezefood/view/HomePage/page_ads.dart';
import 'package:breezefood/view/HomePage/supermarketslider.dart';
import 'package:breezefood/view/HomePage/widgets/appAnimatedBackground.dart';
import 'package:breezefood/view/HomePage/widgets/appbar_home.dart';
import 'package:breezefood/view/HomePage/home_filters.dart';
import 'package:breezefood/view/HomePage/most_popular.dart';
import 'package:breezefood/view/HomePage/widgets/custom_button_order.dart';
import 'package:breezefood/view/HomePage/widgets/discountOnDelivery.dart';

import 'package:breezefood/view/orders/pay_your_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scrollController = ScrollController();

  final _popularKey = GlobalKey();
  final _closerKey = GlobalKey();
  final _storesKey = GlobalKey();
  final _discountsKey = GlobalKey();
  final _deliveryKey = GlobalKey();
  final _supermarketKey = GlobalKey();
  final _openNowKey = GlobalKey();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Mock loading (استبدله لاحقًا بـ API)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ---------- منطق التمرير ----------
  Future<void> _scrollTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;

    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      alignment: 0.05,
      curve: Curves.easeInOut,
    );
  }

  void _onFilterTap(String id) {
    switch (id) {

      case "closer":
        _scrollTo(_closerKey);
        break;
      case "stores":
        _scrollTo(_storesKey);
        break;
      case "discounts":
        _scrollTo(_discountsKey);
        break;
      case "delivery":
        _scrollTo(_deliveryKey);
        break;
      case "supermarket":
        _scrollTo(_supermarketKey);
        break;
      case "open":
        _scrollTo(_openNowKey);
        break;
    }
  }

  // ---------- Shimmer Widget ----------
  Widget _shimmerBox({
    required double height,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10),
  }) {
    return Padding(
      padding: padding,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade700,
        highlightColor: Colors.grey.shade500,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,

      // زر الطلب ثابت
      body: Stack(
        children: [
          SafeArea(child: _buildContent()),

          Positioned(
            left: 0,
            right: 0,
            bottom: 85,
            child: Center(
              child: CustomButtonOrder(
                title: "Your order",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PayYourOrder(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- محتوى الصفحة ----------
  Widget _buildContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          const AppbarHome(),

          HomeFilters(onFilterTap: _onFilterTap),

          // ---------- Ads ----------
          _isLoading
              ? _shimmerBox(
            height: 100.h,
            padding: const EdgeInsets.all(10),
          )
              : GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReferralAdPage(adId: 1),
                ),
              );
            },
            child: const Animated(ad: null),
          ),

          const SizedBox(height: 10),

          // ---------- Most Popular ----------
          // Container(key: _popularKey),
          // _isLoading
          //     ? _shimmerBox(height: 178.h)
          //     :  MostPopular(popular: null),
          // const SizedBox(height: 12),
          Container(key: _closerKey),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: CustomTitleSection(title: "Closer to you"),
          ),
          // SizedBox(height: 10,),
          const SizedBox(height: 10),
          _isLoading ? _shimmerBox(height: 178.h): CloserToYou(),

          const SizedBox(height: 12),

          // ---------- Stores ----------
          Container(key: _storesKey),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: CustomTitleSection(title: "Stores"),
          ),
          const SizedBox(height: 10),
          _isLoading ? _shimmerBox(height: 178.h) : Stores(),

          const SizedBox(height: 12),

          // ---------- Discounts ----------
          Container(key: _discountsKey),
          _isLoading ? _shimmerBox(height: 178.h) : DiscountHome(),

          const SizedBox(height: 12),

          // ---------- Delivery Discounts ----------
          Container(key: _deliveryKey),
          _isLoading ? _shimmerBox(height: 120.h) : DiscountDelvery(),
          const SizedBox(height: 12),
          Container(key: _supermarketKey),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: CustomTitleSection(title: "Super Market"),
          ),
          const SizedBox(height: 10),
          Supermarketslider(),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: const CustomTitleSection(title: "Open Now"),
          ),
          const SizedBox(height: 10),
          // ---------- Open Now ----------
          Container(key: _openNowKey),
          _isLoading ? _shimmerBox(height: 320.h) : const OpenNow(),


        ],
      ),
    );
  }
}

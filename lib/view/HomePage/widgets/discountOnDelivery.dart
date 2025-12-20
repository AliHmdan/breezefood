import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../discount_delevry_grid_page.dart';
import '../discount_grid_Page.dart';
import '../discount_home.dart';
import '../most_popular.dart';

// ------------------------------------------------------------
// 🧩 DiscountPriceCard Widget — سعر قديم + سعر جديد
// ------------------------------------------------------------

class DiscountPriceCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String oldPrice;
  final String newPrice;
  final bool initialIsFavorite;
  final VoidCallback onFavoriteToggle;
  final void Function()? onTap;

  const DiscountPriceCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.oldPrice,
    required this.newPrice,
    required this.onFavoriteToggle,
    this.initialIsFavorite = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<DiscountPriceCard> createState() => _DiscountPriceCardState();
}

class _DiscountPriceCardState extends State<DiscountPriceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late bool _isFavorite;
  double _rating = 4.9;
  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  Widget buildImage(String path, {double? height}) {
    return Image.asset(
      path,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: Colors.grey.shade200,
        child: Center(
          child: Icon(Icons.fastfood, color: Colors.black54, size: 24.sp),
        ),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
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
    return
      GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 100.h,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: buildImage(widget.imagePath, height: 100.h),
                    ),
                  ),

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
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6.h,
                    right: 6.w,
                    child: GestureDetector(onTap: () async{
                      final result = await showRatingDialog(context, _rating);
                      if (result != null) {
                        setState(() {
                          _rating = result;
                        });
                      }                    },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 12.sp),
                            SizedBox(width: 4.w),
                            Text(
                              _rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20.r),
                          bottomRight: Radius.circular(20.r),
                        ),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset("assets/icons/motor.svg",color: AppColor.white,width: 15,height: 15,),
                          SizedBox(width: 2,),

                          Text(
                            "${widget.oldPrice}\$",
                            style: TextStyle(
                              color: AppColor.LightActive,
                              decoration: TextDecoration.lineThrough,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "${widget.newPrice}\$",
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      );
  }
}

//////////////////////////////////////////////////////////////////////
//          DiscountDelivery — إصلاح وربط DiscountPriceCard
//////////////////////////////////////////////////////////////////////

class DiscountDelvery extends StatelessWidget {
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

  final List<MockDiscountModel>? discounts;

  const DiscountDelvery({super.key, this.discounts});

  @override
  Widget build(BuildContext context) {
    final items = discounts ?? _mockDiscounts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomTitleSection(
            title: "Discounts Delivery",
            all: "All",
            icon: Icons.arrow_forward_ios_outlined,
            ontap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const DiscountDelevryGridPageGridPage()),
              );
            },
          ),
        ),
        const SizedBox(height: 5),
        RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 8),
            child: SizedBox(
              height: 110.h,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / 2.2;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Container(
                        width: itemWidth,
                        margin: EdgeInsets.only(right: 10.w),
                        child: GestureDetector(
                          onTap: () {},
                          child: DiscountPriceCard(
                            imagePath: item.imagePath,
                            title: item.restaurantName,
                            oldPrice: "10.00",
                            newPrice: "7.00",
                            onFavoriteToggle: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Favorite toggled: ${item.itemName}',
                                  ),
                                ),
                              );
                            },
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

//////////////////////////////////////////////////////////////////////
//                  MODEL MOCK DATA
//////////////////////////////////////////////////////////////////////

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
Future<double?> showRatingDialog(
    BuildContext context,
    double currentRating,
    ) {
  double selectedRating = currentRating;

  return showDialog<double>(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ❌ Close
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
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                "Please share your rate about the restaurant",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.sp,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20.h),

              // ⭐ Rating Bar
              RatingBar.builder(
                initialRating: currentRating,
                minRating: 1,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 32.sp,
                unratedColor: Colors.white30,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.w),
                itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  selectedRating = rating;
                },
              ),

              SizedBox(height: 20.h),

              // ✅ Submit
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, selectedRating);
                },
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// presentation/widgets/home/open_now_standalone.dart

import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

//////////////////////////////////////////////////////////////
// Mock Model
//////////////////////////////////////////////////////////////

class MockRestaurant {
  final int id;
  final String imageUrl;
  final String name;
  final double rating;
  final String orders;
  final String price;
  final bool isClosed;
  final String? closedText;

  const MockRestaurant({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.rating,
    required this.orders,
    required this.price,
    this.isClosed = false,
    this.closedText,
  });
}

//////////////////////////////////////////////////////////////
// Restaurant Card
//////////////////////////////////////////////////////////////

class RestaurantCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final double rating;
  final String orders;
  final String price;
  final bool isClosed;
  final String? closedText;

  const RestaurantCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.rating,
    required this.orders,
    required this.price,
    this.isClosed = false,
    this.closedText,
  });

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating; // ✅ مصدر واحد للتقييم
  }

  Widget _buildImage(String path) {
    return Image.asset(
      path,
      height: 112.h,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 112.h,
        color: Colors.grey.shade800,
        child: Center(
          child: Icon(Icons.restaurant, color: AppColor.white, size: 40.sp),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.r),
      child: Stack(
        children: [
          ColorFiltered(
            colorFilter: widget.isClosed
                ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                : const ColorFilter.mode(
              Colors.transparent,
              BlendMode.multiply,
            ),
            child: _buildImage(widget.imageUrl),
          ),

          Container(
            height: 112.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.25),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ⭐ Rating
                      GestureDetector(
                        onTap: () async {
                          final result =
                          await showRatingDialog(context, _rating);
                          if (result != null) {
                            setState(() {
                              _rating = result;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 14),
                              SizedBox(width: 4.w),
                              Text(
                                _rating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              const Text("|",
                                  style: TextStyle(color: Colors.white54)),
                              SizedBox(width: 6.w),
                              CustomSubTitle(
                                subtitle: widget.orders,
                                color: AppColor.white,
                                fontsize: 12.sp,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ⏱ Time
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            // const Icon(Icons.access_time,
                            //     color: Colors.white, size: 14),
                            SizedBox(width: 4.w),
                            Text(
                              widget.price,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Bottom Text
                  Padding(
                    padding: EdgeInsets.only(bottom: 18.h),
                    child: Column(
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black.withOpacity(0.7),
                              )
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (widget.isClosed && widget.closedText != null)
                          Text(
                            widget.closedText!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// Open Now List
//////////////////////////////////////////////////////////////

class OpenNow extends StatelessWidget {
  const OpenNow({super.key});

  final List<MockRestaurant> _mockRestaurants = const [
    MockRestaurant(
      id: 1,
      imageUrl: 'assets/images/004.jpg',
      name: 'Mega Burger Spot',
      rating: 4.8,
      orders: '1.2K Orders',
      price: '20 \$',
    ),
    MockRestaurant(
      id: 2,
      imageUrl: 'assets/images/pourple.jpg',
      name: 'Pizza Hub',
      rating: 4.6,
      orders: '900 Orders',
      price: '20 \$',
    ),
    MockRestaurant(
      id: 3,
      imageUrl: 'assets/images/pourple.jpg',
      name: 'Pizza Hub',
      rating: 4.6,
      orders: '900 Orders',
      price: '20 \$',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: _mockRestaurants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = _mockRestaurants[index];
        return RestaurantCard(
          imageUrl: r.imageUrl,
          name: r.name,
          rating: r.rating,
          orders: r.orders,
          price: r.price,
          isClosed: r.isClosed,
          closedText: r.closedText,
        );
      },
    );
  }
}

//////////////////////////////////////////////////////////////
// Rating Dialog (flutter_rating_bar)
//////////////////////////////////////////////////////////////

Future<double?> showRatingDialog(
    BuildContext context,
    double currentRating,
    ) {
  double selectedRating = currentRating;

  return showDialog<double>(
    context: context,
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
                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              RatingBar.builder(
                initialRating: currentRating,
                minRating: 1,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 32.sp,
                unratedColor: Colors.white30,
                itemBuilder: (_, __) =>
                const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) => selectedRating = rating,
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, selectedRating),
                  child: CustomSubTitle(subtitle: "Submit", color: AppColor.white, fontsize: 14.sp)
                // const Text("Submit",),
              ),
            ],
          ),
        ),
      );
    },
  );
}

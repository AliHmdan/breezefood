// 📁 File: presentation/widgets/home/open_now_standalone.dart

import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/most_popular.dart';
import 'package:flutter/material.dart';
// تأكد من إضافة حزمة flutter_screenutil في pubspec.yaml
import 'package:flutter_screenutil/flutter_screenutil.dart';
// تأكد من إضافة حزمة flutter_rating_bar في pubspec.yaml
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


// Mock Data لتمثيل بيانات المطعم (بديل لـ RestaurantModel و Restaurant)
class MockRestaurant {
  final int id;
  final String imageUrl;
  final String name;
  final double rating;
  final String orders;
  final String time;
  final bool isClosed;
  final String? closedText;

  const MockRestaurant({
    required this.id,
    required this.imageUrl,
    required this.name,
    this.rating = 0.0,
    this.orders = '',
    this.time = '',
    this.isClosed = false,
    this.closedText,
  });
}

// *************************************************************
// 🧩 الـ Widget المكونة: RestaurantCard
// *************************************************************

class RestaurantCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double rating;
  final String orders;
  final String time;
  final bool isClosed;
  final String? closedText;

  const RestaurantCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.rating,
    required this.orders,
    required this.time,
    this.isClosed = false,
    this.closedText,
  });

  Widget _buildImage(String path) {
    return Image.asset(
      path,
      height: 110.h,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
        Container(
          height: 110.h, 
          color: Colors.grey.shade800,
          child: Center(child: Icon(Icons.restaurant, color: AppColor.white, size: 40.sp,)),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r), // تم تخفيض Radius قليلاً ليكون شكل البطاقة أكثر شيوعاً
      child: Stack(
        children: [
          // 1. الخلفية (ملونة أو أبيض وأسود إذا مغلق)
          ColorFiltered(
            colorFilter: isClosed
                ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                : const ColorFilter.mode(
                    Colors.transparent,
                    BlendMode.multiply,
                  ),
            child: _buildImage(imageUrl),
          ),

          // 2. التدرج العلوي والأسفل لتوضيح النص
          Container(
            height: 110.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 3. المحتوى
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // الصف العلوي (تقييم يسار + وقت يمين)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // تقييم + عدد الطلبات
                        Container(
                           padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                           decoration: BoxDecoration(
                             color: Colors.black.withOpacity(0.4),
                             borderRadius: BorderRadius.circular(15.r),
                           ),
                           child: Row(
                             children: [
                               // ⚠️ يجب استخدام FlutterRatingBar
                               RatingBarIndicator( 
                                 rating: rating,
                                 itemBuilder: (context, index) =>
                                     const Icon(Icons.star, color: Colors.yellow),
                                 itemCount: 1, 
                                 itemSize: 14.sp,
                                 direction: Axis.horizontal,
                               ),
                               SizedBox(width: 4.w),
                               Text(
                                 rating.toStringAsFixed(1), // تنسيق التقييم
                                 style: TextStyle(
                                   color: AppColor.white,
                                   fontSize: 12.sp,
                                 ),
                               ),
                               SizedBox(width: 4.w),
                               const Text(
                                 "|",
                                 style: TextStyle(color: Colors.white54),
                               ),
                               SizedBox(width: 4.w),
                               Text(
                                 orders,
                                 style: TextStyle(
                                   color: AppColor.white,
                                   fontSize: 12.sp,
                                 ),
                               ),
                             ],
                           ),
                         ),


                        // الوقت
                        Container(
                           padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                           decoration: BoxDecoration(
                             color: Colors.black.withOpacity(0.4),
                             borderRadius: BorderRadius.circular(15.r),
                           ),
                           child: Row(
                             children: [
                               const Icon(
                                 Icons.access_time,
                                 color: Colors.white,
                                 size: 14,
                               ),
                               SizedBox(width: 4.w),
                               Text(
                                 time,
                                 style: const TextStyle(
                                   color: Colors.white,
                                   fontSize: 12,
                                 ),
                               ),
                             ],
                           ),
                         ),
                      ],
                    ),
                  ),

                  // اسم المطعم + نص إضافي إذا مغلق
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Column(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isClosed && closedText != null)
                          Text(
                            closedText!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
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


// *************************************************************
// 🏠 الـ Widget الرئيسية: OpenNow
// *************************************************************

class OpenNow extends StatelessWidget {
  // 📝 بيانات ثابتة (Mock Data)
  final List<MockRestaurant> _mockRestaurants = const [
    MockRestaurant(
      id: 101,
      imageUrl: 'assets/images/burger_mock_bg.jpg', 
      name: 'Mega Burger Spot',
      rating: 4.8,
      orders: '1.2K Orders',
      time: '15 Min',
    ),
    MockRestaurant(
      id: 102,
      imageUrl: 'assets/images/sushi_mock_bg.jpg',
      name: 'Taste of Tokyo',
      rating: 4.5,
      orders: '500 Orders',
      time: '30 Min',
    ),
    MockRestaurant(
      id: 103,
      imageUrl: 'assets/images/pizza_mock_bg.jpg',
      name: 'Pizza Hub',
      rating: 4.9,
      orders: '2.5K Orders',
      time: '20 Min',
    ),
    MockRestaurant(
      id: 104,
      imageUrl: 'assets/images/coffee_mock_bg.jpg',
      name: 'Coffee & Bites',
      rating: 4.1,
      orders: '800 Orders',
      time: '10 Min',
      isClosed: true, // مثال لمطعم مغلق
      closedText: 'Closed until 9:00 AM',
    ),
  ];

  // 🗑️ تم استبدال List<home_model.RestaurantModel>? nearbyRestaurants;
  final List<MockRestaurant>? nearbyRestaurants;

  const OpenNow({super.key, this.nearbyRestaurants});

  // 💡 دالة مساعدة لإنشاء الـ Displayed Items
  List<MockRestaurant> _buildDisplayedRestaurants() {
    final List<MockRestaurant> sourceList = nearbyRestaurants ?? _mockRestaurants;
    
    // 💡 محاكاة تحويل البيانات
    return sourceList.map((r) {
      final timeDisplay = (r.time.isEmpty && r.orders.isNotEmpty) 
          ? '${r.orders.split(' ')[0]} items' 
          : (r.time.isEmpty ? '20M' : r.time);
          
      return MockRestaurant(
        id: r.id,
        imageUrl: r.imageUrl, 
        name: r.name,
        rating: r.rating,
        orders: r.orders,
        time: timeDisplay,
        isClosed: r.isClosed,
        closedText: r.closedText,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<MockRestaurant> restaurants = _buildDisplayedRestaurants();

    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomTitleSection(title: "Open Now"),
          const SizedBox(height: 10),
          RepaintBoundary(
            child: Container(
              height: 320.h, 
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              decoration: BoxDecoration(
                color: AppColor.LightActive,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                primary: false, 
                shrinkWrap: true, 
                physics: const BouncingScrollPhysics(),
                cacheExtent: 600,
                itemCount: restaurants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final r = restaurants[index];
                  return GestureDetector(
                    onTap: () {
                      // 🖱️ محاكاة الانتقال إلى صفحة المطعم
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Mock Action: Navigating to ${r.name} store details.')),
                      );
                      // Navigator.of(context).pushNamed(AppRoute.stores_nav_tab); // تم التعليق عليه لأنه غير مُعرّف هنا
                    },
                    child: RestaurantCard(
                      imageUrl: r.imageUrl,
                      name: r.name,
                      rating: r.rating,
                      orders: r.orders,
                      time: r.time,
                      isClosed: r.isClosed,
                      closedText: r.closedText,
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
}
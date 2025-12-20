// 📁 File: presentation/screens/stores_nav_tab_standalone.dart

import 'package:breezefood/component/color.dart';
import 'package:breezefood/view/HomePage/widgets/custom_appbar_home.dart';
import 'package:breezefood/view/HomePage/widgets/custom_search.dart';
import 'package:breezefood/view/HomePage/widgets/custom_sub_title.dart';
import 'package:breezefood/view/stores/Resturant_page.dart';
import 'package:breezefood/view/stores/market_page.dart';
import 'package:breezefood/view/stores/widget/location_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ⚠️ نحتاج هذه الحزمة لـ RatingBarIndicator في RestaurantCard
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

// *************************************************************
// 🧩 الـ Widget المكونة: RestaurantCard (تم نقلها من OpenNow Standalone)
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
    // نفترض أن جميع المسارات هي Assets لتبسيط الـ Mock
    return Image.asset(
      path,
      height: 110.h,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 110.h,
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
      // تم تغيير الـ Radius إلى 20.r ليتناسب مع تصميم القائمة
      borderRadius: BorderRadius.circular(20.r),
      child: Stack(
        children: [
          // 1. الخلفية
          ColorFiltered(
            colorFilter: isClosed
                ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                : const ColorFilter.mode(
                    Colors.transparent,
                    BlendMode.multiply,
                  ),
            child: _buildImage(imageUrl),
          ),

          // 2. التدرج
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
                  // الصف العلوي (تقييم + وقت)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // تقييم + عدد الطلبات
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Row(
                            children: [
                              // استخدام RatingBarIndicator
                              RatingBarIndicator(
                                rating: rating,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                itemCount: 1,
                                itemSize: 14.sp,
                                direction: Axis.horizontal,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                rating.toStringAsFixed(1),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
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

// 🧩 Mock Model (بديل لـ uiModel.Restaurant)
class MockStore {
  final int id;
  final String imageUrl;
  final String name;
  final double rating;
  final String orders;
  final String time;
  final bool isClosed;
  final String? closedText;

  const MockStore({
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
// 📝 قائمة المتاجر (Stores Tab List)
// *************************************************************

class _StoresTabList extends StatefulWidget {
  final List<MockStore> items;
  final void Function(BuildContext context, MockStore r)? onItemTap;

  const _StoresTabList({super.key, required this.items, this.onItemTap});

  @override
  State<_StoresTabList> createState() => _StoresTabListState();
}

class _StoresTabListState extends State<_StoresTabList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 💡 تم إزالة تعريف الـ Function Mock واستبداله بـ RestaurantCard الحقيقي
    return ScrollConfiguration(
      behavior: const _NoGlowBehavior(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
        physics: const ClampingScrollPhysics(),
        itemCount: widget.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final r = widget.items[index];
          return GestureDetector(
            onTap: () {
              if (widget.onItemTap != null) {
                widget.onItemTap!(context, r);
              } else {
                // 🖱️ محاكاة الانتقال إلى صفحة تفاصيل المطعم
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Mock Action: Navigating to ${r.name} details (Store)',
                    ),
                  ),
                );
              }
            },
            // 🚀 استخدام RestaurantCard الذي تم تعريفه الآن
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
    );
  }
}

class _NoGlowBehavior extends ScrollBehavior {
  const _NoGlowBehavior();
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

// *************************************************************
// 🏠 الـ Widget الرئيسية المجردة: StoresNavTab
// *************************************************************

class StoresNavTab extends StatefulWidget {
  const StoresNavTab({super.key});

  @override
  State<StoresNavTab> createState() => _StoresNavTabState();
}

class _StoresNavTabState extends State<StoresNavTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // 📝 بيانات ثابتة (Mock Data) للتبويبات
  late final List<MockStore> _restaurantItems;
  late final List<MockStore> _supermarketItems;
  final List<String> _titles = const ["Restaurant", "Super Market"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _titles.length, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });

    // 📝 Mock Data للمطاعم
    _restaurantItems = const [
      MockStore(
        id: 101,
        imageUrl: "assets/images/002.jpg", // يجب أن يكون المسار صالحاً
        name: "Fast Burger Palace",
        rating: 4.8,
        orders: "2.1K Orders",
        time: "20M",
      ),
      MockStore(
        id: 102,
        imageUrl: "assets/images/004.jpg",
        name: "Japan Express",
        rating: 4.5,
        orders: "800 Orders",
        time: "35M",
      ),
      MockStore(
        id: 103,
        imageUrl: "assets/images/003.jpg",
        name: "Italian Oven",
        rating: 4.9,
        orders: "3K Orders",
        time: "25M",
      ),
      MockStore(
        id: 104,
        imageUrl: "assets/images/002.jpg",
        name: "Cafe Corner (Closed)",
        rating: 4.1,
        orders: "1.2K Orders",
        time: "10M",
        isClosed: true,
        closedText: 'Closed Now',
      ),
    ];

    // 📝 Mock Data للسوبرماركت
    _supermarketItems = const [
      MockStore(
        id: 201,
        imageUrl: "assets/images/004.jpg", // استخدام مسار افتراضي
        name: "Fresh Market",
        rating: 4.6,
        orders: "1K+ Orders",
        time: "30M",
      ),
      MockStore(
        id: 202,
        imageUrl: "assets/images/003.jpg",
        name: "Giant Hyper",
        rating: 4.2,
        orders: "500 Orders",
        time: "45M",
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              const CustomAppbarHome(title: "Stores"),

              // 💡 أزرار التبويبات (Tabs)
              Row(
                children: List.generate(_titles.length, (index) {
                  final bool isSelected = _tabController.index == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _tabController.animateTo(
                        index,
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeInOutCubic,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomSubTitle(
                              subtitle: _titles[index],
                              color: isSelected
                                  ? AppColor.primaryColor
                                  : AppColor.white,
                              fontsize: 14.sp,
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeInOut,
                              margin: EdgeInsets.only(top: 4.h),
                              height: 3,
                              width: isSelected ? 130.w : 0,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColor.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: 24.h),

              // 🔍 شريط البحث
              CustomSearch(
                hint: 'Search',
                readOnly: true,
                onTap: () {
                  // 🖱️ محاكاة الانتقال إلى صفحة البحث
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mock Action: Navigating to Search Page'),
                    ),
                  );
                },
                boxicon: "assets/icons/boxsearch.svg",
              ),

              SizedBox(height: 10.h),

              // 📄 محتوى التبويبات
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: Container(

                    child: TabBarView(
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // 1. تبويب المطاعم (بيانات ثابتة)
                        _StoresTabList(
                          key: const PageStorageKey('tab_restaurants'),
                          items: _restaurantItems, // Mock Data
                          onItemTap: (ctx, r) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ResturantPage(), // محاكاة التنقل
                              ),
                            );
                            
                          },
                        ),

                        // 2. تبويب السوبرماركت (بيانات ثابتة)
                        _StoresTabList(
                          key: const PageStorageKey('tab_supermarkets'),
                          items: _supermarketItems, // Mock Data
                          onItemTap: (ctx, r) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const MarketPage(), // محاكاة التنقل
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

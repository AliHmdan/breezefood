import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/favoritePage/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_appbar_home.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/stores/model/all_resturants.dart'
    show RestaurantModel;
import 'package:breezefood/features/stores/presentation/cubit/stores_cubit.dart';
import 'package:breezefood/features/stores/presentation/cubit/super_markets_list_cubit.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:breezefood/features/super_market/market_page_price.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
    final url = (UrlHelper.toFullUrl(path) ?? "").trim();

    if (url.isEmpty) {
      return Container(
        height: 110.h,
        color: Colors.grey.shade800,
        child: Center(
          child: Icon(Icons.restaurant, color: AppColor.white, size: 40.sp),
        ),
      );
    }

    return Image.network(
      url,
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
  final List<String> _titles = const ["Restaurant", "Super Market"];

  late final StoresCubit cubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _titles.length, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });

    cubit = getIt<StoresCubit>();
    superMarketsCubit = getIt<SuperMarketsListCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.loadRestaurants();
      superMarketsCubit.load(); // ✅ تحميل أسواق
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    cubit.close();
    superMarketsCubit.close(); // ✅ مهم لأنه factory
    super.dispose();
  }

  String _timeText(RestaurantModel r) {
    final t = r.deliveryTime ?? 0;
    return t == 0 ? "--" : "${t}M";
  }

  String _ordersText(RestaurantModel r) {
    final c = r.ratingCount;
    if (c <= 0) return "0 Orders";
    return "$c Orders";
  }

  String? _restaurantImage(RestaurantModel r) {
    final p = r.coverImage?.trim();
    final l = r.logo?.trim();
    final picked = (p != null && p.isNotEmpty) ? p : l;
    return UrlHelper.toFullUrl(picked);
  }

  late final SuperMarketsListCubit superMarketsCubit;
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

              // Tabs
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
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: TabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      BlocBuilder<StoresCubit, StoresState>(
                        bloc: cubit,
                        builder: (context, state) {
                          return state.when(
                            initial: () => const SizedBox.shrink(),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (msg) => Center(
                              child: Text(
                                msg,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            loaded: (restaurants) {
                              if (restaurants.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "لا يوجد مطاعم",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                );
                              }

                              return ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 5,
                                ),
                                itemCount: restaurants.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, i) {
                                  final r = restaurants[i];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider(
                                            create: (context) =>
                                                getIt<FavoritesCubit>(),
                                            child: ResturantDetails(
                                              restaurant_id: r.id,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: RestaurantCard(
                                      imageUrl: _restaurantImage(r) ?? "",
                                      name: r.name,
                                      rating: r.ratingAvg,
                                      orders: _ordersText(r),
                                      time: _timeText(r),
                                      isClosed: false,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      BlocBuilder<SuperMarketsListCubit, SuperMarketsListState>(
                        bloc: superMarketsCubit,
                        builder: (context, state) {
                          if (state is SuperMarketsListLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (state is SuperMarketsListError) {
                            return Center(
                              child: Text(
                                state.msg,
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }
                          if (state is SuperMarketsListLoaded) {
                            if (state.markets.isEmpty) {
                              return const Center(
                                child: Text(
                                  "لا يوجد سوبرماركت",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              );
                            }

                            return ScrollConfiguration(
                              behavior: const _NoGlowBehavior(),
                              child: ListView.separated(
                                key: const PageStorageKey('tab_supermarkets'),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 5,
                                ),
                                physics: const ClampingScrollPhysics(),
                                itemCount: state.markets.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final m = state.markets[index];

                                  final img =
                                      (m.logo != null &&
                                          m.logo!.trim().isNotEmpty)
                                      ? UrlHelper.toFullUrl(m.logo) ?? ""
                                      : "";

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => MarketPagePrice(
                                            marketId: m.id,
                                            title: m.name,
                                          ),
                                        ),
                                      );
                                    },
                                    child: RestaurantCard(
                                      imageUrl: img,
                                      name: m.name,
                                      rating:
                                          0.0, // API عندك rating_avg موجود بس أنت ما حطيته بالموديل
                                      orders: "0 Orders", // نفس الشي
                                      time:
                                          "--", // delivery_time موجود إذا بدك نضيفه للموديل
                                      isClosed: false,
                                    ),
                                  );
                                },
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ],
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

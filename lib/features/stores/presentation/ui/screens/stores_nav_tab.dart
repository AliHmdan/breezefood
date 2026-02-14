import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:breezefood/features/stores/model/all_resturants.dart'
    show RestaurantModel;
import 'package:breezefood/features/stores/presentation/cubit/stores_cubit.dart';
import 'package:breezefood/features/stores/presentation/cubit/super_markets_list_cubit.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:breezefood/features/super_market/categories_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';

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
      return Image.asset(
        "assets/images/meal_breeze.jpeg",
        height: 110.h,
        width: double.infinity,
        fit: BoxFit.cover,
      );

    }

    return AppNetworkImage(
      path: url, // أو imageUrl إذا هو المتغير عندك
      height: 110.h,
      width: double.infinity,
      fit: BoxFit.cover,
    );

  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w,),
      child: Container(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔹 IMAGE
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16.r),
              ),
              child: Stack(
                children: [
                  ColorFiltered(
                    colorFilter: isClosed
                        ? const ColorFilter.mode(
                      Colors.grey,
                      BlendMode.saturation,
                    )
                        : const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.multiply,
                    ),
                    child: AppNetworkImage(
                      path: imageUrl,
                      height: 170.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  /// Top overlay info
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    right: 12.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        /// Rating
                        _iosBadge(
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 14),
                              SizedBox(width: 4.w),
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                orders,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Delivery
                        _iosBadge(
                          child: Row(
                            children: [
                              const Icon(Icons.delivery_dining,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 4.w),
                              Text(
                                time,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// 🔹 BOTTOM CONTENT
            Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (isClosed && closedText != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      closedText!,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],

                  SizedBox(height: 4.h),

                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/motor.svg",
                        height: 18.h,
                        color: Colors.white70,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "stores.mock_navigate".tr(namedArgs: {"name": r.name}),
                    ),
                  ),
                );
              }
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

class StoresNavTab extends StatefulWidget {
  const StoresNavTab({super.key});

  @override
  State<StoresNavTab> createState() => _StoresNavTabState();
}

class _StoresNavTabState extends State<StoresNavTab>
    with SingleTickerProviderStateMixin {
  String _deliveryFeeText(RestaurantModel r) {
  final fee = r.deliveryBaseFee;
  if (fee <= 0) return "common.dash".tr();

  return "stores.delivery_fee_short".tr(
    namedArgs: {"fee": fee.toStringAsFixed(0)},
  );
}


  late final TabController _tabController;
  final List<String> _titlesKeys = const [
    "stores.tabs.restaurants",
    "stores.tabs.supermarkets",
  ];

  late final StoresCubit cubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _titlesKeys.length, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });

    cubit = getIt<StoresCubit>();
    superMarketsCubit = getIt<SuperMarketsListCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.loadRestaurants();
      superMarketsCubit.load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    cubit.close();
    superMarketsCubit.close();
    super.dispose();
  }

  String _timeText(RestaurantModel r) {
    final t = r.deliveryTime ?? 0;
    if (t <= 0) return "common.dash".tr();
    return "common.minutes_short".tr(namedArgs: {"min": t.toString()});
  }

  String _ordersText(RestaurantModel r) {
    final c = r.ratingCount;
    return "stores.orders_count".tr(namedArgs: {"count": c.toString()});
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
      body: Column(
        children: [
          CustomAppbarProfile(ontap: () {}, title: "stores.title".tr()),

          // Tabs
          Row(
            children: List.generate(_titlesKeys.length, (index) {
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
                          subtitle: _titlesKeys[index].tr(),
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
                      return RefreshIndicator(
                        onRefresh: () async => cubit.loadRestaurants(),
                        child: state.when(
                          initial: () => ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [SizedBox(height: 200)],
                          ),
                          loading: () => ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 200),
                              Center(child: CircularProgressIndicator()),
                            ],
                          ),
                          error: (msg) => ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 200.h),
                              Center(
                                child: Text(
                                  msg,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                          loaded: (restaurants) {
                            if (restaurants.isEmpty) {
                              return ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(height: 200.h),
                                  Center(
                                    child: Text(
                                      "stores.empty_restaurants".tr(),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 5,
                              ),
                              physics: const AlwaysScrollableScrollPhysics(),
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
                                    context.read<CartCubit>().loadCart();
                                  },
                                  child: RestaurantCard(
                                    imageUrl: _restaurantImage(r) ?? "",
                                    name: r.name,
                                    rating: r.ratingAvg,
                                    orders: _ordersText(r),
                                  time: _deliveryFeeText(r),

                                    isClosed: false,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),

                  BlocBuilder<SuperMarketsListCubit, SuperMarketsListState>(
                    bloc: superMarketsCubit,
                    builder: (context, state) {
                      return RefreshIndicator(
                        onRefresh: () async => superMarketsCubit.load(),
                        child: () {
                          if (state is SuperMarketsListLoading) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 200),
                                Center(child: CircularProgressIndicator()),
                              ],
                            );
                          }

                          if (state is SuperMarketsListError) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: 200.h),
                                Center(
                                  child: Text(
                                    state.msg,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          }

                          if (state is SuperMarketsListLoaded) {
                            if (state.markets.isEmpty) {
                              return ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(height: 200.h),
                                  Center(
                                    child: Text(
                                      "stores.empty_supermarkets".tr(),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
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
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: state.markets.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final m = state.markets[index];

                                  final img =
                                      (m.logo != null &&
                                          m.logo!.trim().isNotEmpty)
                                      ? (UrlHelper.toFullUrl(m.logo) ?? "")
                                      : "";

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              MarketCategoriesScreen(
                                                marketId: m.id,
                                                title: m.name,
                                              ),
                                        ),
                                      );
                                    },
                                    child: RestaurantCard(
                                      imageUrl: img,
                                      name: m.name,
                                      rating: 0.0,
                                      orders: "stores.orders_count".tr(
                                        namedArgs: {"count": "0"},
                                      ),
                                      time: "stores.delivery_fee_short".tr(
                                        namedArgs: {
                                          "fee": m.deliveryBaseFee.toString(),
                                        },
                                      ),
                                      isClosed: false,
                                    ),
                                  );
                                },
                              ),
                            );
                          }

                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [SizedBox(height: 200)],
                          );
                        }(),
                      );
                    },
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
Widget _iosBadge({required Widget child}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.45),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(
        color: Colors.white.withOpacity(0.08),
      ),
    ),
    child: child,
  );
}

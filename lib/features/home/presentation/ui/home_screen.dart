import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/have_order.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/home_scroll_controller.dart';
import 'package:breezefood/features/home/presentation/ui/sections/Stores.dart';
import 'package:breezefood/features/home/presentation/ui/sections/breakfast_restaurants.dart';
import 'package:breezefood/features/home/presentation/ui/sections/closer_to_you.dart';
import 'package:breezefood/features/home/presentation/ui/sections/dicounts/discounts_delivery/discount_delivery_home.dart';
import 'package:breezefood/features/home/presentation/ui/sections/dicounts/discounts_meals/discount_home.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/home_tabs_bar.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/most_popular.dart';
import 'package:breezefood/features/home/presentation/ui/sections/open_now.dart';
import 'package:breezefood/features/home/presentation/ui/sections/supermarketslider.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/appbar_home.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/cart_summary_model.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_button_order.dart';
import 'package:breezefood/features/orders/cart/request_order_screen.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart' show OrderInfo;
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';
import 'package:breezefood/features/ratings/presentation/cubit/rating_submit_cubit.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/restaurant_details/screens/restaurant_details_screen.dart';
import 'package:breezefood/features/super_market/market_page_price.dart';
import 'package:breezefood/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with RouteAware {
  late final HomeCubit cubit;

  bool _subscribed = false;

  // ✅ Controller تبع السكرول + tabs sync
  late final HomeScrollController homeScroll = HomeScrollController(debugEnabled: kDebugMode)..init();

  @override
  void initState() {
    super.initState();
    cubit = context.read<HomeCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await cubit.sendMyLocationOnce();
      if (!mounted) return;

      final isLoadedOrLoading = cubit.state.maybeWhen(loading: () => true, loaded: (_) => true, orElse: () => false);
      if (!isLoadedOrLoading) {
        await cubit.load();
      }

      if (mounted) {
        try {
          context.read<CartCubit>().loadCart();
        } catch (_) {}
      }

      // ✅ أول قياس offsets بعد أول frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        homeScroll.activeIndex.value = homeScroll.activeIndex.value;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subscribed) return;

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
      _subscribed = true;
    }
  }

  @override
  void dispose() {
    if (_subscribed) routeObserver.unsubscribe(this);
    homeScroll.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    context.read<CartCubit>().loadCart();
  }

  // ===== Helpers =====
  int _extractId(dynamic x) {
    if (x == null) return 0;

    if (x is Map) {
      final v = x["id"] ?? x["restaurant_id"] ?? x["market_id"];
      return int.tryParse(v.toString()) ?? 0;
    }

    try {
      final v = (x as dynamic).id;
      return int.tryParse(v.toString()) ?? 0;
    } catch (_) {}

    try {
      final v = (x as dynamic).restaurantId;
      return int.tryParse(v.toString()) ?? 0;
    } catch (_) {}

    return 0;
  }

  String _extractTitle(dynamic x) {
    if (x == null) return "";
    if (x is Map) return (x["name"] ?? x["title"] ?? "").toString();

    try {
      return ((x as dynamic).name ?? "").toString();
    } catch (_) {}

    return "";
  }

  Future<void> _refreshHomeAndCart() async {
    if (!mounted) return;
    await Future.wait([
      cubit.load(),
      Future(() {
        try {
          return context.read<CartCubit>().loadCart();
        } catch (_) {
          return Future.value();
        }
      }),
    ]);

    // ✅ بعد الريفرش بيصير أحجام تتغير
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
    });
  }

  Future<void> _openRestaurant(dynamic r) async {
    final id = _extractId(r);
    if (id == 0) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CartCubit>()),
            BlocProvider(create: (_) => getIt<RatingSubmitCubit>()),
            BlocProvider(create: (_) => getIt<FavoritesCubit>()),
          ],
          child: ResturantDetails(restaurant_id: id),
        ),
      ),
    );

    context.read<CartCubit>().loadCart();
  }

  Future<void> _openMarket(dynamic m) async {
    final id = _extractId(m);
    if (id == 0) return;

    final title = _extractTitle(m).trim();
    final homeData = cubit.state.maybeWhen(loaded: (d) => d, orElse: () => null);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MarketPagePrice(marketId: id, title: title.isEmpty ? "Market" : title, haveOrder: homeData?.haveOrder),
      ),
    );

    context.read<CartCubit>().loadCart();
  }

  Widget _shimmerBox({required double height, EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10)}) {
    return Padding(
      padding: padding,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade800,
        highlightColor: Colors.grey.shade600,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
        ),
      ),
    );
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: cubit,
      builder: (context, state) {
        final loading = state.maybeWhen(loading: () => true, orElse: () => false);

        final homeData = state.maybeWhen(loaded: (data) => data, orElse: () => null);
        final haveOrder = homeData?.haveOrder;
        final showBottom = haveOrder != null;

        final sections = <_HomeSectionDef>[
          _HomeSectionDef(
            id: "stores",
            title: "Story",
            builder: () => loading
                ? _shimmerBox(height: 178.h)
                : state.maybeWhen(
                    loaded: (data) => Padding(
                      padding: EdgeInsetsDirectional.only(top: 16.h),
                      child: StoriesSlider(stories: data.stories, onTap: (story) {}),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
          ),
          _HomeSectionDef(
            id: "closer",
            title: "home.closer_to_you".tr(),
            builder: () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomTitleSection(title: "home.closer_to_you".tr()),
                ),
                SizedBox(height: 10.h),
                loading
                    ? _shimmerBox(height: 178.h)
                    : state.maybeWhen(
                        loaded: (data) => CloserToYou(restaurants: data.closerToYou),
                        orElse: () => const SizedBox.shrink(),
                      ),
              ],
            ),
          ),
        ];

        // Breakfast (اختياري)
        final breakfastList = homeData?.breakfastRestaurants ?? const [];
        if (breakfastList.isNotEmpty) {
          sections.add(
            _HomeSectionDef(
              id: "breakfast",
              title: "home.breakfast_restaurants".tr(),
              builder: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: CustomTitleSection(title: "home.breakfast_restaurants".tr()),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: BreakfastRestaurantsSection(restaurants: breakfastList),
                  ),
                ],
              ),
            ),
          );
        }

        // Discounts
        sections.addAll([
          _HomeSectionDef(
            id: "discounts",
            title: "Discounts",
            builder: () => loading
                ? _shimmerBox(height: 130.h)
                : state.maybeWhen(
                    loaded: (data) => DiscountHome(discounts: data.discounts),
                    orElse: () => const SizedBox.shrink(),
                  ),
          ),
          _HomeSectionDef(
            id: "delivery",
            title: "Delivery",
            builder: () => loading
                ? _shimmerBox(height: 120.h)
                : state.maybeWhen(
                    loaded: (data) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: DiscountDeliveryHome(discountDelivery: data.discountDelivery),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
          ),
          _HomeSectionDef(
            id: "supermarket",
            title: "home.super_market".tr(),
            builder: () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomTitleSection(title: "home.super_market".tr()),
                ),
                SizedBox(height: 10.h),
                state.maybeWhen(
                  loaded: (data) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Supermarketslider(restaurants: data.supermarkets, onTap: _openMarket, onRateSuccess: () => cubit.load()),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          _HomeSectionDef(
            id: "open",
            title: "home.open_now".tr(),
            builder: () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CustomTitleSection(title: "home.open_now".tr()),
                ),
                SizedBox(height: 10.h),
                loading
                    ? _shimmerBox(height: 320.h)
                    : state.maybeWhen(
                        loaded: (data) => OpenNow(restaurants: data.nearbyRestaurants, onTap: _openRestaurant),
                        orElse: () => const SizedBox.shrink(),
                      ),
              ],
            ),
          ),
        ]);

        homeScroll.setKeysCount(sections.length);

        final tabTitles = sections.map((s) => s.title).toList();

        final safeActive = homeScroll.activeIndex.value.clamp(0, (tabTitles.isEmpty ? 0 : tabTitles.length - 1));

        if (safeActive != homeScroll.activeIndex.value) {
          homeScroll.activeIndex.value = safeActive;
        }
        if (tabTitles.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return Scaffold(
          backgroundColor: AppColor.Dark,
          body: Stack(
            children: [
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: _refreshHomeAndCart,
                  child: CustomScrollView(
                    controller: homeScroll.controller,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            AppbarHome(home: homeData, homeCubit: cubit),

                            SizedBox(height: 12.h),
                          ],
                        ),
                      ),

                      ///
                      ///here story and slider choose bar
                      ///
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickyTabsHeader(
                          height: 55.h,
                          child: SizedBox.expand(
                            child: Container(
                              key: homeScroll.tabsKey,
                              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 7.h),
                              child: ValueListenableBuilder<int>(
                                valueListenable: homeScroll.activeIndex,
                                builder: (_, active, __) {
                                  return HomeTabsBar(titles: tabTitles, activeIndex: active, onTap: (i) => homeScroll.scrollToSection(i));
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ===== Sections =====
                      SliverToBoxAdapter(
                        child: Column(
                          children: List.generate(sections.length, (i) {
                            return Column(
                              children: [
                                SizedBox(key: homeScroll.sectionKeys[i], height: 1), // ✅ فقط هون
                                sections[i].builder(),
                                SizedBox(height: 14.h),
                              ],
                            );
                          }),
                        ),
                      ),

                      SliverToBoxAdapter(child: SizedBox(height: showBottom ? 90.h : 24.h)),
                    ],
                  ),
                ),
              ),
              // ===== Bottom action (Cart / Order) =====
              if (showBottom)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16 + MediaQuery.of(context).padding.bottom,
                  child: BlocBuilder<HomeCubit, HomeState>(
                    bloc: cubit,
                    builder: (context, st) {
                      final haveOrder = st.maybeWhen(loaded: (d) => d.haveOrder, orElse: () => null);
                      if (haveOrder == null) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _HomeBottomAction(homeCubit: cubit, haveOrder: haveOrder),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeBottomAction extends StatelessWidget {
  final HomeCubit homeCubit;
  final OrderInfo haveOrder;

  const _HomeBottomAction({required this.homeCubit, required this.haveOrder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, st) {
        bool loading = false;
        CartSummary summary = CartSummary.empty;

        st.maybeWhen(loading: () => loading = true, cartLoaded: (cart, __, ___) => summary = CartSummary.from(cart), orElse: () {});

        if (summary.hasCart || loading) {
          final title = loading
              ? "cart.view_cart_loading".tr()
              : "${'cart.view_cart'.tr()} • ${summary.count} • ${context.money(summary.total, decimals: 0)}";

          return CustomButton(
            title: title,
            onPressed: loading
                ? null
                : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: context.read<CartCubit>()),
                            BlocProvider(create: (_) => getIt<OrderFlowCubit>()),
                          ],
                          child: const RequestOrderScreen(),
                        ),
                      ),
                    );

                    if (context.mounted) {
                      context.read<CartCubit>().loadCart();
                      homeCubit.load();
                    }
                  },
          );
        }

        return CustomButtonOrder(
          title: "home.your_order".tr(),
          onPressed: () {
            openHaveOrderTracking(context, haveOrder.id);
            if (context.mounted) {
              homeCubit.load();
              context.read<CartCubit>().loadCart();
            }
          },
        );
      },
    );
  }
}

class _StickyTabsHeader extends SliverPersistentHeaderDelegate {
  _StickyTabsHeader({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: Container(
        color: AppColor.Dark,
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTabsHeader oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

class _HomeSectionDef {
  final String id; // للـ filters mapping
  final String title; // للـ tabs
  final Widget Function() builder;

  _HomeSectionDef({required this.id, required this.title, required this.builder});
}

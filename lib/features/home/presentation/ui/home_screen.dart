import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/have_order.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/sections/Stores.dart';
import 'package:breezefood/features/home/presentation/ui/sections/breakfast_restaurants.dart'; // ✅ NEW
import 'package:breezefood/features/home/presentation/ui/sections/closer_to_you.dart';
import 'package:breezefood/features/home/presentation/ui/sections/dicounts/discounts_delivery/discount_delivery_home.dart';
import 'package:breezefood/features/home/presentation/ui/sections/dicounts/discounts_meals/discount_home.dart';
import 'package:breezefood/features/home/presentation/ui/sections/home_empty.dart';
import 'package:breezefood/features/home/presentation/ui/sections/home_filter.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/most_popular.dart';
import 'package:breezefood/features/home/presentation/ui/sections/open_now.dart';
import 'package:breezefood/features/home/presentation/ui/sections/page_ads.dart';
import 'package:breezefood/features/home/presentation/ui/sections/supermarketslider.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/app_animated_background.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/appbar_home.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/cart_summary_model.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_button_order.dart';
import 'package:breezefood/features/orders/cart/request_order_screen.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart'
    show OrderInfo;
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';
import 'package:breezefood/features/ratings/presentation/cubit/rating_submit_cubit.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:breezefood/features/super_market/market_page_price.dart';
import 'package:breezefood/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with RouteAware {
  final _scrollController = ScrollController();

  final _closerKey = GlobalKey();
  final _breakfastKey = GlobalKey(); // ✅ NEW
  final _storesKey = GlobalKey();
  final _discountsKey = GlobalKey();
  final _deliveryKey = GlobalKey();
  final _supermarketKey = GlobalKey();
  final _openNowKey = GlobalKey();

  late final HomeCubit cubit;
  bool _subscribed = false;

  @override
  void initState() {
    super.initState();
    cubit = context.read<HomeCubit>(); // ✅

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await cubit.sendMyLocationOnce();
      if (mounted) {
        final isLoadedOrLoading = cubit.state.maybeWhen(
          loading: () => true,
          loaded: (_) => true,
          orElse: () => false,
        );
        if (!isLoadedOrLoading) {
          await cubit.load();
        }
      }

      if (mounted) context.read<CartCubit>().loadCart();
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _refreshHomeAndCart();
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
    await Future.wait([cubit.load(), context.read<CartCubit>().loadCart()]);
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

    await _refreshHomeAndCart();
  }

  Future<void> _openMarket(dynamic m) async {
    final id = _extractId(m);
    if (id == 0) return;

    final title = _extractTitle(m).trim();
    final homeData = cubit.state.maybeWhen(
      loaded: (d) => d,
      orElse: () => null,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MarketPagePrice(
          marketId: id,
          title: title.isEmpty ? "Market" : title,
          haveOrder: homeData?.haveOrder,
        ),
      ),
    );

    await _refreshHomeAndCart();
  }

  Widget _anchor(GlobalKey key) => SizedBox(key: key, height: 1);

  Future<void> _scrollTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;

    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 520),
      alignment: 0.06,
      curve: Curves.easeInOutCubic,
    );
  }

  void _onFilterTap(String id) {
    switch (id) {
      case "closer":
        _scrollTo(_closerKey);
        break;
      case "breakfast": // ✅ NEW
        _scrollTo(_breakfastKey);
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

  Widget _shimmerBox({
    required double height,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10),
  }) {
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

  Widget _buildAds(HomeState state, bool loading) {
    if (loading) {
      return _shimmerBox(height: 100.h, padding: const EdgeInsets.all(10));
    }

    return state.maybeWhen(
      loaded: (data) {
        final ads = data.ads;
        if (ads.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 100.h,
          child: PageView.builder(
            itemCount: ads.length,
            controller: PageController(viewportFraction: 0.92),
            itemBuilder: (context, index) {
              final ad = ads[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReferralAdPage(ad: ad)),
                  );
                },
                child: AdBanner(ad: ad),
              );
            },
          ),
        );
      },
      error: (msg) => Padding(
        padding: const EdgeInsets.all(10),
        child: Text(msg, style: const TextStyle(color: Colors.red)),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: cubit,
      builder: (context, state) {
        final loading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        final homeData = state.maybeWhen(
          loaded: (data) => data,
          orElse: () => null,
        );

        final haveOrder = homeData?.haveOrder;
        final showBottom = haveOrder != null;

        // ✅ Empty area condition (محسوب مع الفطور)
        final noNearby = homeData?.nearbyRestaurants.isEmpty ?? false;
        final noCloser = homeData?.closerToYou.isEmpty ?? false;
        final noBreakfast = homeData?.breakfastRestaurants.isEmpty ?? false;
        final isEmptyArea =
            homeData != null && noNearby && noCloser && noBreakfast;
        final lang = context.locale.languageCode;
        final msg = (lang == 'ar')
            ? (homeData?.messageAr?.trim() ?? "")
            : (homeData?.messageEn?.trim() ?? "");
        return
          Scaffold(
          backgroundColor: AppColor.Dark,
          body: Stack(
            children: [
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: _refreshHomeAndCart,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child:Column(
                    children: [

                      /// 1️⃣ AppBar
                      AppbarHome(home: homeData, homeCubit: cubit),
                    SizedBox(height: 12.h),

                    /// 2️⃣ Search
                    // HomeSearch(
                    //   onTap: _onSearchTap,
                    // ),
                    SizedBox(height: 12.h),

                    /// 3️⃣ Filters
                    if (!(!loading && isEmptyArea))
              HomeFilters(onFilterTap: _onFilterTap),

              SizedBox(height: 14.h),

              /// 🔹 Ads (Commented — enable if needed later)
              /*
  _buildAds(state, loading),
  SizedBox(height: 12.h),
  */

              /// 4️⃣ Stores (Stories)
              _anchor(_storesKey),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: CustomTitleSection(title: "story".tr()),
              // ),
              SizedBox(height: 10.h),
              loading
                  ? _shimmerBox(height: 178.h)
                  : state.maybeWhen(
                loaded: (data) => StoriesSlider(
                  stories: data.stories,
                  onTap: (story) {},
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              SizedBox(height: 14.h),

              /// 5️⃣ Closer To You
              _anchor(_closerKey),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomTitleSection(
                  title: "home.closer_to_you".tr(),
                ),
              ),
              SizedBox(height: 10.h),
              loading
                  ? _shimmerBox(height: 178.h)
                  : state.maybeWhen(
                loaded: (data) => CloserToYou(
                  restaurants: data.closerToYou,
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              SizedBox(height: 14.h),

              /// 6️⃣ Breakfast Section
              _anchor(_breakfastKey),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomTitleSection(
                  title: "home.breakfast_restaurants".tr(),
                ),
              ),
              SizedBox(height: 10.h),
              loading
                  ? _shimmerBox(height: 178.h)
                  : state.maybeWhen(
                loaded: (data) => BreakfastRestaurantsSection(
                  restaurants: data.breakfastRestaurants,
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              SizedBox(height: 14.h),

              /// 7️⃣ Discount
              _anchor(_discountsKey),
              loading
                  ? _shimmerBox(height: 130.h)
                  : state.maybeWhen(
                loaded: (data) =>
                    DiscountHome(discounts: data.discounts),
                orElse: () => const SizedBox.shrink(),
              ),
              SizedBox(height: 14.h),

              /// 8️⃣ Discount Delivery
              _anchor(_deliveryKey),
              loading
                  ? _shimmerBox(height: 120.h)
                  : state.maybeWhen(
                loaded: (data) => DiscountDeliveryHome(
                  discountDelivery: data.discountDelivery,
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              SizedBox(height: 14.h),

              /// 9️⃣ Supermarket
              _anchor(_supermarketKey),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomTitleSection(
                  title: "home.super_market".tr(),
                ),
              ),
              SizedBox(height: 10.h),
              state.maybeWhen(
                loaded: (data) => Supermarketslider(
                  restaurants: data.supermarkets,
                  onTap: _openMarket,
                  onRateSuccess: () => cubit.load(),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              SizedBox(height: 14.h),

              /// 🔟 Open Now
              _anchor(_openNowKey),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: CustomTitleSection(
                  title: "home.open_now".tr(),
                ),
              ),
              SizedBox(height: 10.h),
              loading
                  ? _shimmerBox(height: 320.h)
                  : state.maybeWhen(
                loaded: (data) => OpenNow(
                  restaurants: data.nearbyRestaurants,
                  onTap: _openRestaurant,
                ),
                orElse: () => const SizedBox.shrink(),
              ),

              SizedBox(height: showBottom ? 90.h : 24.h),
            ],

          )),
                ),
              ),

              // Bottom action
              if (showBottom)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16 + MediaQuery.of(context).padding.bottom,
                  child: BlocBuilder<HomeCubit, HomeState>(
                    bloc: cubit,
                    builder: (context, st) {
                      final haveOrder = st.maybeWhen(
                        loaded: (d) => d.haveOrder,
                        orElse: () => null,
                      );
                      if (haveOrder == null) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _HomeBottomAction(
                          homeCubit: cubit,
                          haveOrder: haveOrder,
                        ),
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

        st.maybeWhen(
          loading: () => loading = true,
          cartLoaded: (cart, __, ___) => summary = CartSummary.from(cart),
          orElse: () {},
        );

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
                            BlocProvider.value(
                              value: context.read<CartCubit>(),
                            ),
                            BlocProvider(
                              create: (_) => getIt<OrderFlowCubit>(),
                            ),
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

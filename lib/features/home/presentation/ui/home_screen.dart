import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/have_order.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/sections/Stores.dart';
import 'package:breezefood/features/home/presentation/ui/sections/closer_to_you.dart';
import 'package:breezefood/features/home/presentation/ui/sections/discount_home.dart';
import 'package:breezefood/features/home/presentation/ui/sections/home_filters.dart';
import 'package:breezefood/features/home/presentation/ui/sections/most_popular.dart';
import 'package:breezefood/features/home/presentation/ui/sections/open_now.dart';
import 'package:breezefood/features/home/presentation/ui/sections/page_ads.dart';
import 'package:breezefood/features/home/presentation/ui/sections/supermarketslider.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/app_animated_background.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/appbar_home.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/cart_summary_model.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_button_order.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/discount_on_delivery.dart';
import 'package:breezefood/features/orders/pay_your_order.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';
import 'package:breezefood/features/ratings/presentation/cubit/rating_submit_cubit.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:breezefood/features/super_market/market_page_price.dart';
import 'package:breezefood/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart'
    show OrderInfo;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with RouteAware {
  final _scrollController = ScrollController();
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

    if (x is Map) {
      return (x["name"] ?? x["title"] ?? "").toString();
    }

    try {
      return ((x as dynamic).name ?? "").toString();
    } catch (_) {}

    return "";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    _scrollController.dispose();
    cubit.close();
    super.dispose();
  }

  @override
  void didPopNext() {
    _refreshHomeAndCart();
  }

  Future<void> _refreshHomeAndCart() async {
    if (!mounted) return;

    await Future.wait([
      this.cubit.load(),
      context.read<CartCubit>().loadCart(),
    ]);
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

    await _refreshHomeAndCart(); // ✅ لما ترجع
  }

  Future<void> _openMarket(dynamic m) async {
    final id = _extractId(m);
    if (id == 0) return;

    final title = _extractTitle(m).trim();
    final homeData = (cubit.state).maybeWhen(
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

    await _refreshHomeAndCart(); // ✅ لما ترجع
  }

  final _closerKey = GlobalKey();
  final _storesKey = GlobalKey();
  final _discountsKey = GlobalKey();
  final _deliveryKey = GlobalKey();
  final _supermarketKey = GlobalKey();
  final _openNowKey = GlobalKey();

  late final HomeCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = getIt<HomeCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await cubit.sendMyLocationOnce();
      await cubit.load();
      context.read<CartCubit>().loadCart(); // ✅
    });
  }

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

        return Scaffold(
          backgroundColor: AppColor.Dark,
          body: Stack(
            children: [
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: _refreshHomeAndCart,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        AppbarHome(home: homeData, homeCubit: cubit),
                        HomeFilters(onFilterTap: _onFilterTap),
                        loading
                            ? _shimmerBox(
                                height: 100.h,
                                padding: const EdgeInsets.all(10),
                              )
                            : state.maybeWhen(
                                loaded: (data) {
                                  final ads = data.ads;
                                  if (ads.isEmpty)
                                    return const SizedBox.shrink();

                                  return SizedBox(
                                    height: 100.h,
                                    child: PageView.builder(
                                      itemCount: ads.length,
                                      controller: PageController(
                                        viewportFraction: 0.92,
                                      ),
                                      itemBuilder: (context, index) {
                                        final ad = ads[index];

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ReferralAdPage(ad: ad),
                                              ),
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
                                  child: Text(
                                    msg,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                                orElse: () => const SizedBox.shrink(),
                              ),

                        const SizedBox(height: 10),

                        Container(key: _closerKey),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: CustomTitleSection(
                            title: "home.closer_to_you".tr(),
                          ),
                        ),
                        const SizedBox(height: 10),

                        loading
                            ? _shimmerBox(height: 178.h)
                            : state.maybeWhen(
                                loaded: (data) =>
                                    CloserToYou(restaurants: data.closerToYou),
                                orElse: () => const SizedBox.shrink(),
                              ),

                        const SizedBox(height: 12),

                        Container(key: _storesKey),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: CustomTitleSection(title: "home.stores".tr()),
                        ),
                        const SizedBox(height: 10),

                        loading
                            ? _shimmerBox(height: 178.h)
                            : state.maybeWhen(
                                loaded: (data) =>
                                    Stores(restaurants: data.nearbyRestaurants),
                                orElse: () => const SizedBox.shrink(),
                              ),

                        const SizedBox(height: 12),

                        Container(key: _discountsKey),
                        loading
                            ? _shimmerBox(height: 130.h)
                            : state.maybeWhen(
                                loaded: (data) =>
                                    DiscountHome(mostPopular: data.discounts),
                                orElse: () => const SizedBox.shrink(),
                              ),

                        const SizedBox(height: 12),

                        Container(key: _deliveryKey),
                        loading
                            ? _shimmerBox(height: 120.h)
                            : state.maybeWhen(
                                loaded: (data) =>
                                    DiscountDelvery(discounts: data.discounts),
                                orElse: () => const SizedBox.shrink(),
                              ),

                        const SizedBox(height: 8),

                        Container(key: _supermarketKey),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: CustomTitleSection(
                            title: "home.super_market".tr(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        state.maybeWhen(
                          loaded: (data) => Supermarketslider(
                            restaurants: data.supermarkets,
                            onTap: (m) => _openMarket(m),
                            onRateSuccess: () => cubit.load(), // ✅ refresh
                          ),

                          orElse: () => const SizedBox.shrink(),
                        ),

                        const SizedBox(height: 12),

                        Container(key: _openNowKey),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: CustomTitleSection(
                            title: "home.open_now".tr(),
                          ),
                        ),
                        const SizedBox(height: 10),

                        loading
                            ? _shimmerBox(height: 320.h)
                            : state.maybeWhen(
                                loaded: (data) => OpenNow(
                                  restaurants: data.nearbyRestaurants,
                                  onTap: _openRestaurant,
                                ),

                                orElse: () => const SizedBox.shrink(),
                              ),

                        // ✅ مساحة حتى ما يغطي الزر السفلي المحتوى
                        SizedBox(height: showBottom ? 80.h : 20.h),
                      ],
                    ),
                  ),
                ),
              ),

              if (showBottom)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 85,
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
          cartLoaded: (cart, __, ___) {
            summary = CartSummary.from(cart);
          },
          orElse: () {},
        );

        // ✅ إذا في سلة -> View Cart
        if (summary.hasCart || loading) {
          // إذا loading وما في summary بعد، خلّي الزر موجود بس disabled
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

        // ✅ ما في سلة -> Your Order
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

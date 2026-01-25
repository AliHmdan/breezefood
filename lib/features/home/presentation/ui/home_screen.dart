import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/features/favoritePage/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/sections/Stores.dart';
import 'package:breezefood/features/home/presentation/ui/sections/closerToYou.dart';
import 'package:breezefood/features/home/presentation/ui/sections/discount_home.dart';
import 'package:breezefood/features/home/presentation/ui/sections/home_filters.dart';
import 'package:breezefood/features/home/presentation/ui/sections/most_popular.dart';
import 'package:breezefood/features/home/presentation/ui/sections/open_now.dart';
import 'package:breezefood/features/home/presentation/ui/sections/page_ads.dart';
import 'package:breezefood/features/home/presentation/ui/sections/supermarketslider.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/appAnimatedBackground.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/appbar_home.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_button_order.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/discount_on_delivery.dart';
import 'package:breezefood/features/orders/current_orders.dart';
import 'package:breezefood/features/orders/pay_your_order.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_button.dart';
import 'package:breezefood/features/reviews/presentation/cubit/rating_submit_cubit.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:breezefood/features/super_market/categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_cubit.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart'
    show OrderInfo;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

  void _openRestaurant(dynamic r) {
    final id = _extractId(r);
    if (id == 0) return;

    Navigator.push(
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
  }

  void _openMarket(dynamic m) {
    final id = _extractId(m);
    if (id == 0) return;

    final title = _extractTitle(m).trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MarketCategoriesScreen(
          marketId: id,
          title: title.isEmpty ? "Market" : title,
        ),
      ),
    );
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
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    cubit.close();
    super.dispose();
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
        final status = (haveOrder?.status ?? "").toLowerCase().trim();

        final showBottom = haveOrder != null && status.isNotEmpty;
        final isCart = status == "cart";

        return Scaffold(
          backgroundColor: AppColor.Dark,
          body: Stack(
            children: [
              SafeArea(
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
                                if (ads.isEmpty) return const SizedBox.shrink();

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
                        child: CustomTitleSection(title: "home.open_now".tr()),
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

              // ✅ نفس مكان زر Your Order السابق
              if (showBottom)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 85,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: isCart
                        ? _BottomViewCartButton(homeCubit: cubit)
                        : _BottomYourOrderButton(
                            order: haveOrder!,
                            homeCubit: cubit,
                          ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ===============================
// Bottom: View Cart (when have_order.status == cart)
// ===============================
class _BottomViewCartButton extends StatelessWidget {
  final HomeCubit homeCubit;
  const _BottomViewCartButton({required this.homeCubit});

  double _extractCartTotal(dynamic cart) {
    if (cart == null) return 0.0;

    if (cart is Map) {
      final keys = [
        "total",
        "total_price",
        "totalPrice",
        "grand_total",
        "grandTotal",
        "subtotal",
        "sub_total",
        "subTotal",
        "amount",
      ];
      for (final k in keys) {
        final n = _toNum(cart[k]);
        if (n != null) return n.toDouble();
      }
    }

    try {
      final n = _toNum((cart as dynamic).total);
      if (n != null) return n.toDouble();
    } catch (_) {}
    try {
      final n = _toNum((cart as dynamic).totalPrice);
      if (n != null) return n.toDouble();
    } catch (_) {}
    try {
      final n = _toNum((cart as dynamic).grandTotal);
      if (n != null) return n.toDouble();
    } catch (_) {}
    try {
      final n = _toNum((cart as dynamic).subTotal);
      if (n != null) return n.toDouble();
    } catch (_) {}

    return 0.0;
  }

  int _extractCartCount(dynamic cart) {
    if (cart == null) return 0;

    if (cart is Map) {
      final items = cart["items"] ?? cart["data"] ?? cart["cart_items"];
      if (items is List) return items.length;

      final count = cart["count"] ?? cart["items_count"] ?? cart["itemsCount"];
      final n = _toNum(count);
      if (n != null) return n.toInt();
    }

    try {
      final items = (cart as dynamic).items;
      if (items is List) return items.length;
    } catch (_) {}
    try {
      final n = _toNum((cart as dynamic).count);
      if (n != null) return n.toInt();
    } catch (_) {}
    try {
      final n = _toNum((cart as dynamic).itemsCount);
      if (n != null) return n.toInt();
    } catch (_) {}

    return 0;
  }

  num? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, st) {
        double total = 0.0;
        int count = 0;
        bool loading = false;

        st.maybeWhen(
          loading: () => loading = true,
          cartLoaded: (cart, __, ___) {
            total = _extractCartTotal(cart);
            count = _extractCartCount(cart);
          },
          orElse: () {},
        );

        if (count <= 0 && !loading) return const SizedBox.shrink();

        return CustomButton(
          title: loading
              ? "cart.view_cart_loading".tr()
              : "${'cart.view_cart'.tr()} • $count • ${context.money(total, decimals: 0)}",

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
      },
    );
  }
}

class _BottomYourOrderButton extends StatelessWidget {
  final OrderInfo order;
  final HomeCubit homeCubit;
  const _BottomYourOrderButton({required this.order, required this.homeCubit});

  @override
  Widget build(BuildContext context) {
    return CustomButtonOrder(
      title: "home.your_order".tr(),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => getIt<OrdersCubit>()..loadActive(),
              child: const CurrentOrders(),
            ),
          ),
        );

        if (context.mounted) {
          homeCubit.load(); // ✅ يرجع يحدث have_order
          context.read<CartCubit>().loadCart();
        }
      },
    );
  }
}

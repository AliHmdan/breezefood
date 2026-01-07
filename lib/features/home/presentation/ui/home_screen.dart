import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
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
import 'package:breezefood/features/orders/pay_your_order.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scrollController = ScrollController();

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
    WidgetsBinding.instance.addPostFrameCallback((_) => cubit.load());
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

        return Scaffold(
          backgroundColor: AppColor.Dark,
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      const AppbarHome(),
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
                        padding: EdgeInsets.symmetric(horizontal: 10),
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
                        padding: EdgeInsets.symmetric(horizontal: 10),
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

                      // ---------------- Discounts ----------------
                      Container(key: _discountsKey),
                      loading
                          ? _shimmerBox(height: 130.h)
                          : state.maybeWhen(
                              loaded: (data) =>
                                  DiscountHome(mostPopular: data.discounts),
                              orElse: () => const SizedBox.shrink(),
                            ),

                      const SizedBox(height: 12),

                      // ---------------- Delivery Discounts ----------------
                      // ---------------- Delivery Discounts ----------------
                      Container(key: _deliveryKey),
                      loading
                          ? _shimmerBox(height: 120.h)
                          : state.maybeWhen(
                              loaded: (data) => DiscountDelvery(
                                discounts: data.discounts, // ✅ من HomeResponse
                              ),
                              orElse: () => const SizedBox.shrink(),
                            ),

                      const SizedBox(height: 12),

                      // ---------------- Super Market ----------------
                      Container(key: _supermarketKey),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: CustomTitleSection(
                          title: "home.super_market".tr(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      state.maybeWhen(
                        loaded: (data) =>
                            Supermarketslider(restaurants: data.supermarkets),
                        orElse: () => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 12),

                      // ---------------- Open Now ----------------
                      Container(key: _openNowKey),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: CustomTitleSection(title: "home.open_now".tr()),
                      ),
                      const SizedBox(height: 10),

                      loading
                          ? _shimmerBox(height: 320.h)
                          : state.maybeWhen(
                              loaded: (data) =>
                                  OpenNow(restaurants: data.nearbyRestaurants),
                              orElse: () => const SizedBox.shrink(),
                            ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),

              // زر الطلب ثابت
              Positioned(
                left: 0,
                right: 0,
                bottom: 85,
                child: Center(
                  child: CustomButtonOrder(
                    title: "home.your_order".tr(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (_) => getIt<CartCubit>()..loadCart(),
                              ),
                              BlocProvider(
                                create: (_) => getIt<OrderFlowCubit>(),
                              ),
                            ],
                            child: RequestOrderScreen(
                            ),
                          ),
                        ),
                      );
                    },
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

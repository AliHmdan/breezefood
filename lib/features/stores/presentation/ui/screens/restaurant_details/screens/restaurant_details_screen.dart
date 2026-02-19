import 'package:breezefood/android_swipe_back.dart';
import 'package:breezefood/core/component/app_image.dart';
import 'package:breezefood/core/component/bottom_cart_action.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/orders/cart/request_order_screen.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/ratings/presentation/cubit/rating_submit_cubit.dart';
import 'package:breezefood/features/ratings/presentation/ui/rate_dialog.dart';
import 'package:breezefood/features/search/presentation/ui/search_screen.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/cubit/restaurant_details_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controller/restaurant_details_controller.dart';
import '../controller/restaurant_details_mapper.dart';
import 'widgets/rd_header_sliver.dart';
import 'widgets/rd_sticky_info_tabs_sliver.dart';
import 'widgets/rd_sections_sliver_list.dart';

class ResturantDetails extends StatefulWidget {
  final int restaurant_id;
  final int? initialMenuItemId;

  const ResturantDetails({
    super.key,
    required this.restaurant_id,
    this.initialMenuItemId,
  });

  @override
  State<ResturantDetails> createState() => _ResturantDetailsState();
}

class _ResturantDetailsState extends State<ResturantDetails> {
  final GlobalKey _stickyKey = GlobalKey(); // ✅ NEW
  late final RestaurantDetailsScrollController scrollCtl =
      RestaurantDetailsScrollController()..init();

  late final RestaurantDetailsCubit cubit;

  final ScrollController _tabsController = ScrollController();
  final List<GlobalKey> _tabKeys = [];

  bool _isRestaurantOpen = true;

  bool _headerReady = false;
  String _headerUrl = "";
  final Set<String> _preloadedImages = {};

  VoidCallback? _activeIdxListener;

  void _scrollTabToActive(int index) {
    if (!_tabsController.hasClients) return;
    if (index < 0 || index >= _tabKeys.length) return;

    final ctx = _tabKeys[index].currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;

    final tabGlobalX = box.localToGlobal(Offset.zero).dx;
    final tabWidth = box.size.width;

    final screenWidth = MediaQuery.of(ctx).size.width;
    final desiredCenterX = screenWidth * 0.5;
    final currentCenterX = tabGlobalX + tabWidth * 0.5;

    final delta = currentCenterX - desiredCenterX;

    final target = (_tabsController.offset + delta).clamp(
      _tabsController.position.minScrollExtent,
      _tabsController.position.maxScrollExtent,
    );

    _tabsController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _precacheImage(String url) async {
    if (url.isEmpty) return;
    if (_preloadedImages.contains(url)) return;

    try {
      await precacheImage(
        CachedNetworkImageProvider(url, cacheManager: AppCacheManager.instance),
        context,
      );
      _preloadedImages.add(url);
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    cubit = getIt<RestaurantDetailsCubit>();

    _activeIdxListener = () {
      final idx = scrollCtl.activeIndex.value;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scrollTabToActive(idx);
      });
    };
    scrollCtl.activeIndex.addListener(_activeIdxListener!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.load(widget.restaurant_id);

      // ✅ ما تكسر التطبيق إذا CartCubit مش جاهز/مغلق
      try {
        context.read<CartCubit>().loadCart();
      } catch (_) {}

      scrollCtl.attachInner();
    });
  }

  @override
  void dispose() {
    final listener = _activeIdxListener;
    if (listener != null) {
      scrollCtl.activeIndex.removeListener(listener);
    }

    scrollCtl.dispose();
    _tabsController.dispose();

    // ⚠️ لا تسكر cubit إذا جاي من getIt Singleton/LazySingleton
    // cubit.close();

    super.dispose();
  }

  Widget _divider() {
    return Container(
      width: 0.5,
      height: 25.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: AppColor.LightActive,
    );
  }

  Widget _loadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _errorView(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColor.red, size: 42.sp),
            SizedBox(height: 10.h),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: () => cubit.load(widget.restaurant_id),
                child: Text("common.retry".tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, RestaurantDetailsResponse data) {
    // ✅ most popular
    final mostPopularItems = data.mostPopular;

    String headerImageUrl = "";
    String restaurantName = "";
    String description = "";
    String reviewsCountText = "0";

    String deliveryTime = "--";
    String deliveryBase = "--";
    String deliveryFinal = "--";

    String avgRatingText = "0.0";

    int? myReviewId;
    double myUserRating = 0.0;

    List<String> categories = [];
    List<List<MenuItem>> itemsByCategory = [];
    List<MenuItem> discountedItems = [];

    final g = data.general;

    restaurantName = g.name;

    final newIsOpen = g.isOpen;
    if (_isRestaurantOpen != newIsOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _isRestaurantOpen = newIsOpen);
      });
    }

    description = RestaurantDetailsMapper.pickSingleLangFromMixed(
      g.description ?? "",
      context,
    );

    headerImageUrl = RestaurantDetailsMapper.imageUrl(g.cover ?? g.logo);

    if (_headerUrl != headerImageUrl) {
      _headerUrl = headerImageUrl;
      _headerReady = false;

      _precacheImage(_headerUrl).then((_) {
        if (mounted) setState(() => _headerReady = true);
      });
    }

    reviewsCountText = "${g.reviewsCount}";

    final dt = (g.deliveryTime ?? "").trim();
    deliveryTime = dt.isEmpty ? "--" : dt;

    final del = g.delivery;
    if (del != null) {
      deliveryBase = context.money(del.baseFee, decimals: 0);
      deliveryFinal = context.money(del.finalFee, decimals: 0);
    } else {
      deliveryBase = context.money(g.deliveryCash, decimals: 0);
      deliveryFinal = context.money(g.deliveryCash, decimals: 0);
    }

    final avg = (g.avgRating > 0) ? g.avgRating : 0.0;
    avgRatingText = avg > 0 ? avg.toStringAsFixed(1) : "0.0";

    myReviewId = data.myRating?.id;
    myUserRating = data.myRating?.rating ?? 0.0;

    final sections = data.restaurantMenuItems;
    final hasMostPopular = mostPopularItems.isNotEmpty;

    // ✅ discounted
    final allItems = sections.expand((s) => s.items).toList();
    discountedItems = allItems.where((x) => x.hasDiscount).toList()
      ..sort((a, b) => b.discountPercent.compareTo(a.discountPercent));

    final hasDiscountSection = discountedItems.isNotEmpty;

    // ✅ keys count = (discount?) + (mostPopular?) + عدد الأقسام
    final totalCount =
        sections.length +
        (hasMostPopular ? 1 : 0) +
        (hasDiscountSection ? 1 : 0);

    scrollCtl.setCategoryKeys(totalCount);

    // ✅ keys للـ tabs (نفس العدد تماماً)
    if (_tabKeys.length != totalCount) {
      _tabKeys
        ..clear()
        ..addAll(List.generate(totalCount, (_) => GlobalKey()));
    }

    // ✅ titles تبع منيو الأقسام
    final menuCats = sections.map((e) {
      return context.pick(ar: e.category.nameAr, en: e.category.nameEn);
    }).toList();

    // ✅ categories صار فيها: Discount ثم MostPopular ثم باقي الأقسام
    categories = [
      if (hasDiscountSection) context.pick(ar: "الخصومات", en: "Discounts"),
      if (hasMostPopular) context.pick(ar: "الأكثر طلباً", en: "Most Popular"),
      ...menuCats,
    ];

    // ✅ itemsByCategory لازم يطابق categories 1:1
    itemsByCategory = [
      if (hasDiscountSection) discountedItems,
      if (hasMostPopular) mostPopularItems,
      ...sections.map((e) => e.items),
    ];

    discountedItems = allItems.where((x) => x.hasDiscount).toList()
      ..sort((a, b) => b.discountPercent.compareTo(a.discountPercent));

    // precache few images
    for (final section in sections) {
      for (final item in section.items.take(4)) {
        final img = RestaurantDetailsMapper.imageUrl(item.image);
        _precacheImage(img);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      scrollCtl.attachInner();
      scrollCtl.recalcOffsets();
    });

    final showTwoPrices = deliveryBase != deliveryFinal;

    return Stack(
      children: [
        NestedScrollView(
          key: scrollCtl.nestedKey,
          controller: scrollCtl.outer,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: RDHeaderSliver(
                  headerImageUrl: headerImageUrl,
                  headerReady: _headerReady,
                  restaurantName: restaurantName,
                  avgRatingText: avgRatingText,
                  reviewsCountText: reviewsCountText,
                  onBack: () => Navigator.pop(context),
                  onSearch: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            Search(restaurantId: widget.restaurant_id),
                      ),
                    );
                  },
                  onRateTap: () async {
                    final reviewId = myReviewId;
                    final hasMyRating = (reviewId ?? 0) > 0 && myUserRating > 0;

                    final res = await showRateDialog(
                      context,
                      currentRating: hasMyRating ? myUserRating : 3.0,
                      reviewId: hasMyRating ? reviewId : null,
                    );
                    if (res == null) return;

                    final submitCubit = context.read<RatingSubmitCubit>();
                    EasyLoading.show(status: "common.sending".tr());

                    if (res.delete) {
                      if ((reviewId ?? 0) == 0) {
                        EasyLoading.showError(
                          "reviews.no_review_to_delete".tr(),
                        );
                        return;
                      }

                      await submitCubit.deleteRestaurantRate(
                        reviewId: reviewId!,
                      );
                      if (!mounted) return;

                      submitCubit.state.maybeWhen(
                        deleteSuccess: () async {
                          EasyLoading.showSuccess(
                            "reviews.delete_success".tr(),
                          );
                          await cubit.load(widget.restaurant_id);
                        },
                        error: (msg) => EasyLoading.showError(msg.tr()),
                        orElse: () => EasyLoading.dismiss(),
                      );
                      return;
                    }

                    if (res.rating == null) {
                      EasyLoading.dismiss();
                      return;
                    }

                    await submitCubit.submitRestaurantRate(
                      restaurantId: widget.restaurant_id,
                      rating: res.rating!,
                    );

                    if (!mounted) return;

                    submitCubit.state.maybeWhen(
                      success: () async {
                        EasyLoading.showSuccess("reviews.rate_success".tr());
                        await cubit.load(widget.restaurant_id);
                      },
                      error: (msg) => EasyLoading.showError(msg.tr()),
                      orElse: () => EasyLoading.dismiss(),
                    );
                  },
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: scrollCtl.activeIndex,
                builder: (_, activeIdx, __) {
                  return RDStickyInfoTabsSliver(
                    tabsController: _tabsController,
                    tabKeys: _tabKeys,
                    onTapCategory: (i) {
                      if (scrollCtl.activeIndex.value != i) {
                        scrollCtl.activeIndex.value = i;
                      }
                      scrollCtl.scrollToCategory(i);
                    },
                    divider: _divider(),
                    description: description,
                    deliveryTimeText: deliveryTime,
                    deliveryBaseText: deliveryBase,
                    deliveryFinalText: deliveryFinal,
                    showTwoPrices: showTwoPrices,
                    categories: categories,
                    activeIndex: activeIdx,
                  );
                },
              ),
            ];
          },
          body: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => scrollCtl.attachInner(),
              );

              return RDSectionsSliverList(
                restaurantId: widget.restaurant_id,
                isRestaurantOpen: _isRestaurantOpen,
                categories: categories,
                itemsByCategory: itemsByCategory,
                categoryKeys: scrollCtl.categoryKeys,
                imageUrl: RestaurantDetailsMapper.imageUrl,
                onContentSizeMayChange: () {
                  scrollCtl.attachInner();
                  scrollCtl.recalcOffsets();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => getIt<RatingSubmitCubit>())],
      child: AndroidSwipeBack(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          bottomNavigationBar: SafeArea(
            child: BottomCartAction(
              haveOrder: null,
              usePrimaryButton: true,
              showCountAndTotal: true,
              onViewCart: () async {
                if (!_isRestaurantOpen) {
                  EasyLoading.showInfo(
                    "restaurant.closed_cannot_checkout".tr(),
                  );
                  return;
                }

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
                  try {
                    context.read<CartCubit>().loadCart();
                  } catch (_) {}
                }
              },
            ),
          ),
          body: BlocBuilder<RestaurantDetailsCubit, RestaurantDetailsState>(
            bloc: cubit,
            builder: (context, state) {
              return state.when(
                initial: _loadingView,
                loading: _loadingView,
                error: _errorView,
                loaded: (data) => _buildLoaded(context, data),
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'package:breezefood/android_swipe_back.dart';
import 'package:breezefood/core/component/bottom_cart_action.dart';
import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/sections/discout_meal_section.dart';
import 'package:breezefood/features/home/presentation/ui/sections/most_popular.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_arrow.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_search.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/add_order.dart';
import 'package:breezefood/features/orders/cart/request_order_screen.dart';
import 'package:breezefood/features/orders/presentation/cubit/cart_cubit.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/order_flow_cubit.dart';
import 'package:breezefood/features/orders/request_order/tiem_price.dart';
import 'package:breezefood/features/ratings/presentation/cubit/rating_submit_cubit.dart';
import 'package:breezefood/features/ratings/presentation/ui/rate_dialog.dart';
import 'package:breezefood/features/search/presentation/ui/search_screen.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/cubit/most_popular_cubit.dart';
import 'package:breezefood/features/stores/presentation/cubit/restaurant_details_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  int selectedCategoryIndex = 0;
  bool _openedInitial = false;

  late final ScrollController _scrollController = ScrollController();
  late final RestaurantDetailsCubit cubit;
  late final MostPopularCubit mostPopularCubit;

  final List<GlobalKey> _categoryKeys = [];
  final List<double> _categoryOffsets = [];
  int _activeCategoryIndex = 0;

  @override
  void initState() {
    super.initState();

    cubit = getIt<RestaurantDetailsCubit>();
    mostPopularCubit = getIt<MostPopularCubit>();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.load(widget.restaurant_id);
      mostPopularCubit.load(widget.restaurant_id);
      context.read<CartCubit>().loadCart();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    cubit.close();
    mostPopularCubit.close();
    super.dispose();
  }

  void _calculateCategoryOffsets() {
    _categoryOffsets.clear();
    for (final key in _categoryKeys) {
      final ctx = key.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox;
      final offset = box.localToGlobal(Offset.zero).dy;
      _categoryOffsets.add(offset);
    }
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    for (int i = 0; i < _categoryOffsets.length; i++) {
      final current = _categoryOffsets[i];
      final next = i + 1 < _categoryOffsets.length
          ? _categoryOffsets[i + 1]
          : double.infinity;

      if (scrollOffset >= current - 120 && scrollOffset < next - 120) {
        if (_activeCategoryIndex != i) {
          setState(() {
            _activeCategoryIndex = i;
            selectedCategoryIndex = i;
          });
        }
        break;
      }
    }
  }

  String _fullImageUrl(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return "";

    // 🚫 ignore local server temp paths
    if (v.startsWith("C:/") ||
        v.startsWith("C:\\") ||
        v.contains("xampp/tmp")) {
      return "";
    }

    return UrlHelper.toFullUrl(v) ?? "";
  }

  String _pickSingleLangFromMixed(String s, BuildContext context) {
    final v = s.trim();
    if (v.isEmpty) return "";

    final separators = ['|', '/', '\n', ' - ', ' — ', ' – '];
    for (final sep in separators) {
      if (v.contains(sep)) {
        final parts = v
            .split(sep)
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (parts.length >= 2) {
          return context.isAr ? parts.first : parts[1];
        }
      }
    }
    return v;
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
              haveOrder: null, // أو إذا عندك haveOrder مرّره
              usePrimaryButton: true,
              showCountAndTotal: true,
              onViewCart: () async {
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
                if (context.mounted) context.read<CartCubit>().loadCart();
              },
            ),
          ),

          body: BlocBuilder<RestaurantDetailsCubit, RestaurantDetailsState>(
            bloc: cubit,
            builder: (context, state) {
              String headerImageUrl = "";
              String restaurantName = "";
              String description = "";
              String deliveryTime = "--";
              String deliveryCash = "--";
              String ratingText = "0.0";
              String ordersText = "0";

              List<String> categories = [];
              List<List<MenuItem>> itemsByCategory = [];
              List<MenuItem> discountedItems = [];

              String avgRatingText = "0.0"; // ✅ هذا للعرض برا
              double avgRatingValue = 0.0; // ✅ رقمياً
              int? myReviewId; // ✅ إذا موجود => عندي تقييم
              double myUserRating = 0.0; // ✅ تقييمي أنا

              state.maybeWhen(
                loaded: (data) {
                  final g = data.general;

                  avgRatingValue = (g.avgRating > 0) ? g.avgRating : 0.0;
                  avgRatingText = avgRatingValue > 0
                      ? avgRatingValue.toStringAsFixed(1)
                      : "0.0";

                  restaurantName = _pickSingleLangFromMixed(g.name, context);
                  description = _pickSingleLangFromMixed(
                    g.description ?? "",
                    context,
                  );

                  headerImageUrl = _fullImageUrl(
                    (g.cover ?? g.logo ?? "").toString(),
                  );

                  if (g.deliveryTime > 0) {
                    deliveryTime = "${g.deliveryTime}";
                  }

                  deliveryCash = context.money(g.deliveryCash, decimals: 0);

                  if (g.avgRating > 0) {
                    ratingText = g.avgRating.toStringAsFixed(1);
                  }

                  if (g.totalCompletedOrders > 0) {
                    ordersText = "${g.totalCompletedOrders}";
                  }

                  final sections = data.restaurantMenuItems;

                  if (_categoryKeys.length != sections.length) {
                    _categoryKeys.clear();
                    _categoryKeys.addAll(
                      List.generate(sections.length, (_) => GlobalKey()),
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _calculateCategoryOffsets();
                    });
                  }

                  categories = sections.map((e) {
                    return context.pick(
                      ar: e.category.nameAr,
                      en: e.category.nameEn,
                    );
                  }).toList();

                  itemsByCategory = sections.map((e) => e.items).toList();

                  final allItems = sections.expand((s) => s.items).toList();

                  discountedItems =
                      allItems.where((x) => x.hasDiscount).toList()..sort(
                        (a, b) =>
                            b.discountPercent.compareTo(a.discountPercent),
                      );

                  myReviewId = data.myRating?.id;
                  myUserRating = data.myRating?.rating ?? 0.0;
                },
                orElse: () {},
              );

              return NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context,
                      ),
                      sliver: SliverAppBar(
                        expandedHeight: 240.h,
                        pinned: true,
                        automaticallyImplyLeading: false,
                        toolbarHeight: 0,
                        collapsedHeight: 0,
                        backgroundColor: AppColor.Dark,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              headerImageUrl.isEmpty
                                  ? Image.asset(
                                      "assets/images/shawarma_box.png",
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      headerImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        "assets/images/shawarma_box.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                              PositionedDirectional(
                                top: MediaQuery.of(context).padding.top + 12,
                                start: 12,
                                child: CustomArrow(
                                  color: AppColor.white,
                                  background: AppColor.black,
                                  colorborder: AppColor.grye,
                                  onTap: () => Navigator.pop(context),
                                ),
                              ),

                              Center(
                                child: Text(
                                  restaurantName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: context.isAr
                                        ? 'Cairo'
                                        : 'Inter',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyHeaderDelegate(
                        child: Container(
                          color: AppColor.Dark,
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 5,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TiemPrice(
                                      icon: Icons.alarm,
                                      title: deliveryTime,
                                      subtitle: "min",
                                    ),
                                    TiemPrice(
                                      title: deliveryCash,
                                      subtitle: "",
                                      svgPath: "assets/icons/motor.svg",
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => Search(
                                          restaurantId: widget.restaurant_id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const AbsorbPointer(
                                    child: CustomSearch(hint: "Search"),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () async {
                                    final reviewId = myReviewId;
                                    final hasMyRating =
                                        (reviewId ?? 0) > 0 && myUserRating > 0;

                                    // ✅ إذا عنده تقييم: اعرض تقييمه (readonly) + حذف فقط
                                    // ✅ إذا ما عنده: اعرض RatingBar editable + submit فقط
                                    final res = await showRateDialog(
                                      context,
                                      currentRating: hasMyRating
                                          ? myUserRating
                                          : 3.0,
                                      reviewId: hasMyRating ? reviewId : null,
                                    );

                                    if (res == null) return;

                                    final submitCubit = context
                                        .read<RatingSubmitCubit>();
                                    EasyLoading.show(
                                      status: "common.sending".tr(),
                                    );

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

                                      // ✅ انتظر state النهائي بشكل صحيح
                                      if (!mounted) return;

                                      submitCubit.state.maybeWhen(
                                        deleteSuccess: () async {
                                          EasyLoading.showSuccess(
                                            "reviews.delete_success".tr(),
                                          );
                                          await cubit.load(
                                            widget.restaurant_id,
                                          ); // ✅ refresh details
                                        },
                                        error: (msg) =>
                                            EasyLoading.showError(msg.tr()),
                                        orElse: () => EasyLoading.dismiss(),
                                      );

                                      return;
                                    }

                                    // ✅ submit (فقط إذا ما عنده تقييم سابق)
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
                                        EasyLoading.showSuccess(
                                          "reviews.rate_success".tr(),
                                        );
                                        await cubit.load(
                                          widget.restaurant_id,
                                        ); // ✅ refresh details
                                      },
                                      error: (msg) =>
                                          EasyLoading.showError(msg.tr()),
                                      orElse: () => EasyLoading.dismiss(),
                                    );
                                  },

                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CustomSubTitle(
                                          subtitle: description,
                                          color: AppColor.gry,
                                          fontsize: 8,
                                        ),
                                      ),
                                      _divider(),
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        avgRatingText, // ✅ AVG فقط
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),

                                      _divider(),
                                      CustomSubTitle(
                                        subtitle: ordersText,
                                        color: AppColor.white,
                                        fontsize: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 35.h,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                  ),
                                  itemCount: categories.length,
                                  itemBuilder: (context, index) {
                                    final isSelected =
                                        selectedCategoryIndex == index;
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          final keyContext =
                                              _categoryKeys[index]
                                                  .currentContext;
                                          if (keyContext != null) {
                                            Scrollable.ensureVisible(
                                              keyContext,
                                              duration: const Duration(
                                                milliseconds: 400,
                                              ),
                                              curve: Curves.easeInOut,
                                            );
                                          }
                                          setState(() {
                                            selectedCategoryIndex = index;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            color: isSelected
                                                ? AppColor.primaryColor
                                                : AppColor.black,
                                          ),
                                          child: CustomSubTitle(
                                            subtitle: categories[index],
                                            color: isSelected
                                                ? AppColor.white
                                                : AppColor.LightActive,
                                            fontsize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: Builder(
                  builder: (context) {
                    return CustomScrollView(
                      slivers: [
                        SliverOverlapInjector(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                context,
                              ),
                        ),

                        if (discountedItems.isNotEmpty)
                          SliverToBoxAdapter(
                            child: DiscountMealSection(
                              items: discountedItems,
                              fullImageUrl: _fullImageUrl,
                              onTap: (it) async {
                                final title = context.pick(
                                  ar: it.nameAr,
                                  en: it.nameEn,
                                );
                                final desc = context.pick(
                                  ar: it.descriptionAr ?? "",
                                  en: it.descriptionEn ?? "",
                                );
                                final img = _fullImageUrl(it.image ?? "");

                                await showAddOrderDialog(
                                  context,
                                  restaurantId: widget.restaurant_id,
                                  menuItemId: it.id,
                                  title: title,
                                  price: it.effectivePrice,
                                  oldPrice: (it.priceBefore > 0
                                      ? it.priceBefore
                                      : it.price),
                                  imagePathOrUrl: img.isNotEmpty
                                      ? img
                                      : "assets/images/shawarma_box.png",
                                  description: desc,
                                  extraMeals: it.mealExtras,
                                );

                                if (context.mounted) {
                                  context.read<CartCubit>().loadCart();
                                }
                              },
                            ),
                          ),

                        /// Most Popular
                        SliverToBoxAdapter(
                          child:
                              BlocBuilder<MostPopularCubit, MostPopularState>(
                                bloc: mostPopularCubit,
                                builder: (context, mpState) {
                                  return mpState.maybeWhen(
                                    loading: () => const Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    error: (msg) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      child: CustomSubTitle(
                                        subtitle: msg,
                                        color: AppColor.red,
                                        fontsize: 12,
                                      ),
                                    ),
                                    loaded: (items) {
                                      if (items.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: MostPopularSection(items: items),
                                      );
                                    },
                                    orElse: () => const SizedBox.shrink(),
                                  );
                                },
                              ),
                        ),

                        /// Menu Sections
                        SliverToBoxAdapter(
                          child: Column(
                            children: List.generate(categories.length, (index) {
                              final category = categories[index];
                              final items = itemsByCategory[index];

                              return Column(
                                key: _categoryKeys[index],
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: CustomTitleSection(title: category),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 140.h,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsetsDirectional.only(
                                        start: 16,
                                      ),
                                      itemCount: items.length,
                                      itemBuilder: (context, i) {
                                        final it = items[i];
                                        final imageUrl = _fullImageUrl(
                                          it.image ?? "",
                                        );
                                        final price = it.effectivePrice;

                                        final mapped = MenuItemModel(
                                          id: it.id,
                                          nameAr: it.nameAr,
                                          nameEn: it.nameEn,
                                          priceBefore: (it.priceBefore > 0
                                              ? it.priceBefore
                                              : it.price),
                                          priceAfter: it.effectivePrice,
                                          hasDiscount: it.hasDiscount,
                                          discountType: it.discountType,
                                          discountValue: it.discountPercent,
                                          isFavorite: it.isFavorite,
                                          primaryImage: imageUrl.isEmpty
                                              ? null
                                              : PrimaryImageModel(
                                                  imageUrl: imageUrl,
                                                ),
                                          restaurant: null,
                                        );

                                        return GestureDetector(
                                          onTap: () async {
                                            await showAddOrderDialog(
                                              context,
                                              restaurantId:
                                                  widget.restaurant_id,
                                              menuItemId: it.id,
                                              title: context.pick(
                                                ar: it.nameAr,
                                                en: it.nameEn,
                                              ),
                                              price: price,
                                              oldPrice: (it.priceBefore > 0
                                                  ? it.priceBefore
                                                  : it.price),
                                              imagePathOrUrl:
                                                  imageUrl.isNotEmpty
                                                  ? imageUrl
                                                  : "assets/images/shawarma_box.png",
                                              description: context.pick(
                                                ar: it.descriptionAr ?? "",
                                                en: it.descriptionEn ?? "",
                                              ),
                                              extraMeals: it.mealExtras,
                                            );

                                            if (mounted) {
                                              context
                                                  .read<CartCubit>()
                                                  .loadCart();
                                            }
                                          },
                                          child: Container(
                                            width: 170.w,
                                            margin: EdgeInsetsDirectional.only(
                                              end: i == items.length - 1
                                                  ? 0
                                                  : 8.w,
                                            ),
                                            child: PopularItemCard(
                                              item: mapped,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              );
                            }),
                          ),
                        ),

                        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget _divider() {
    return Container(
      width: 0.5,
      height: 20.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: AppColor.LightActive,
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 190.h;

  @override
  double get maxExtent => 190.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate old) {
    return old.child != child;
  }
}

class DiscountItemCard extends StatelessWidget {
  final MenuItem item;
  final String imageUrl;

  const DiscountItemCard({
    super.key,
    required this.item,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final title = context.pick(ar: item.nameAr, en: item.nameEn);
    final before = item.priceBefore > 0 ? item.priceBefore : item.price;
    final after = item.effectivePrice;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11.r),
        color: AppColor.black,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= IMAGE =================
          Stack(
            children: [
              SizedBox(
                height: 85.h,
                width: double.infinity,
                child: imageUrl.isEmpty
                    ? _fallback()
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(),
                      ),
              ),

              // overlay (نفس MostPopular)
              // Positioned.fill(
              //   child: Container(color: Colors.black.withOpacity(0.25)),
              // ),

              // discount badge
              PositionedDirectional(
                bottom: 0,
                start: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadiusDirectional.only(
                      topEnd: Radius.circular(20.r),
                      bottomEnd: Radius.circular(20.r),
                    ),
                  ),
                  child: CustomSubTitle(
                    subtitle: "-${item.discountPercent.toStringAsFixed(0)}%",
                    color: AppColor.white,
                    fontsize: 11.sp,
                  ),
                ),
              ),
            ],
          ),

          // ================= TEXT =================
          Container(
            height: 55.h,
            padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 6.h),
            color: AppColor.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily:
                        Localizations.localeOf(context).languageCode == 'ar'
                        ? 'Cairo'
                        : 'Inter',
                  ),
                ),
                Row(
                  children: [
                    Text(
                      context.money(before, decimals: 0),
                      style: TextStyle(
                        color: AppColor.LightActive,
                        fontSize: 11.sp,
                        decoration: TextDecoration.lineThrough,
                        fontFamily:
                            Localizations.localeOf(context).languageCode == 'ar'
                            ? 'Cairo'
                            : 'Inter',
                      ),
                    ),

                    const SizedBox(width: 6),
                    CustomSubTitle(
                      subtitle: context.money(after, decimals: 0),
                      color: AppColor.red,
                      fontsize: 12.sp,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.grey.shade800,
      alignment: Alignment.center,
      child: const Icon(Icons.fastfood, color: Colors.white70, size: 26),
    );
  }
}
